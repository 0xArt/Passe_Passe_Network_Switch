`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 07/21/2026
// Module Name: port_header_engine
// Description: per ingress port switching engine. captures the 12 header
//              bytes (destination and source mac) from the incoming beat
//              stream, resolves the target port set through the shared cam
//              (unicast on match, flood on miss, drop on hairpin), requests
//              the target egress schedulers with a fixed two cycle grant
//              window, prunes to the granted set, then replays the captured
//              header beats and streams the payload. beats advance only when
//              every granted egress is ready; a stalled egress set is
//              abandoned through the cycle timer. learning (delete+write of
//              the source mac) is handed to the cam arbiter in parallel.
//
//              a frame that ends inside the header (runt) is dropped. if a
//              new frame arrives before the previous learn was acked the old
//              learn is abandoned; learning is opportunistic
///
// EDUCATIONAL USE ONLY
//
// This source file is provided solely for educational, research, and non-commercial purposes.
//
// Commercial use, redistribution, sublicensing, modification for commercial products,
// or incorporation into proprietary software or hardware is strictly prohibited without prior
// written permission and a valid commercial license from the original creator.
//
// Unauthorized commercial use violates intellectual property and copyright laws.
//
// For licensing inquiries and commercial permissions, contact the creator directly.
//
//////////////////////////////////////////////////////////////////////////////////
module port_header_engine#(
    parameter       NUMBER_OF_PORTS     = 4,
    parameter       PORT_INDEX          = 0,
    parameter       FABRIC_DATA_BYTES   = 1,
    logic [15:0]    TIMEOUT_LIMIT       = 16'h0FFF,
    //how long to keep asking for admission when every target egress is
    //busy. must cover draining one reserved frame through the slowest
    //wire (about 1.2 ms at 10 megabit), so it is much longer than the
    //streaming timeout
    logic [23:0]    RETRY_LIMIT         = 24'h0FFFFF
)(
    input   wire                                                clock,
    input   wire                                                reset_n,
    input   wire    [(FABRIC_DATA_BYTES*8)-1:0]                 in_data,
    input   wire                                                in_first,
    input   wire                                                in_last,
    input   wire    [$clog2(FABRIC_DATA_BYTES+1)-1:0]           in_byte_count,
    input   wire                                                in_enable,
    input   wire                                                match_ack,
    input   wire                                                match_response_enable,
    input   wire    [$clog2(NUMBER_OF_PORTS)-1:0]               match_response_index,
    input   wire                                                match_response_no_match,
    input   wire                                                learn_ack,
    input   wire    [NUMBER_OF_PORTS-1:0]                       port_grant,
    input   wire    [NUMBER_OF_PORTS-1:0]                       egress_enable,

    output  logic                                               in_ready,
    output  logic                                               match_request,
    output  logic   [47:0]                                      match_key,
    output  logic                                               learn_request,
    output  reg     [47:0]                                      learn_key,
    output  reg     [NUMBER_OF_PORTS-1:0]                       port_request,
    output  logic   [(FABRIC_DATA_BYTES*8)-1:0]                 out_data,
    output  logic                                               out_first,
    output  logic                                               out_last,
    output  logic   [$clog2(FABRIC_DATA_BYTES+1)-1:0]           out_byte_count,
    output  logic                                               out_valid
);

localparam HEADER_BYTES = 12;
localparam HEADER_BEATS = (HEADER_BYTES + FABRIC_DATA_BYTES - 1) / FABRIC_DATA_BYTES;


wire            timeout_cycle_timer_clock;
wire            timeout_cycle_timer_reset_n;
wire            timeout_cycle_timer_enable;
logic           timeout_cycle_timer_load_count;
wire  [15:0]    timeout_cycle_timer_count;
wire            timeout_cycle_timer_expired;

cycle_timer timeout_cycle_timer(
    .clock      (timeout_cycle_timer_clock),
    .reset_n    (timeout_cycle_timer_reset_n),
    .enable     (timeout_cycle_timer_enable),
    .load_count (timeout_cycle_timer_load_count),
    .count      (timeout_cycle_timer_count),

    .expired    (timeout_cycle_timer_expired)
);

assign  timeout_cycle_timer_clock   = clock;
assign  timeout_cycle_timer_reset_n = reset_n;
assign  timeout_cycle_timer_enable  = 1'b1;
assign  timeout_cycle_timer_count   = TIMEOUT_LIMIT;

typedef enum
{
    S_IDLE,
    S_CAPTURE,
    S_LOOKUP,
    S_REQUEST,
    S_REPLAY,
    S_STREAM,
    S_DRAIN
} state_type;

integer b;
integer c;
integer m;

state_type                                              _state;
state_type                                              state;
reg     [HEADER_BEATS-1:0][(FABRIC_DATA_BYTES*8)-1:0]   header_beats;
logic   [HEADER_BEATS-1:0][(FABRIC_DATA_BYTES*8)-1:0]   _header_beats;
reg     [$clog2(HEADER_BEATS+1)-1:0]                    capture_count;
logic   [$clog2(HEADER_BEATS+1)-1:0]                    _capture_count;
reg     [$clog2(HEADER_BEATS+1)-1:0]                    replay_index;
logic   [$clog2(HEADER_BEATS+1)-1:0]                    _replay_index;
reg     [NUMBER_OF_PORTS-1:0]                           _port_request;
reg     [1:0]                                           window_count;
logic   [1:0]                                           _window_count;
reg                                                     match_issued;
logic                                                   _match_issued;
reg                                                     learn_pending;
logic                                                   _learn_pending;
reg     [23:0]                                          retry_count;
logic   [23:0]                                          _retry_count;
logic   [47:0]                                          _learn_key;
logic   [47:0]                                          mac_destination;
logic   [47:0]                                          mac_source;
logic   [NUMBER_OF_PORTS-1:0]                           granted;
logic                                                   all_granted_ready;

always_comb begin
    //header byte extraction. byte 0 of beat 0 is first on the wire and maps
    //to the most significant mac byte, matching the orchestrator convention
    for (b=0; b<6; b=b+1) begin
        mac_destination[47-(8*b) -: 8]  = header_beats[b/FABRIC_DATA_BYTES][((b%FABRIC_DATA_BYTES)*8) +: 8];
        mac_source[47-(8*b) -: 8]       = header_beats[(b+6)/FABRIC_DATA_BYTES][(((b+6)%FABRIC_DATA_BYTES)*8) +: 8];
    end
end

always_comb begin
    _state                          = state;
    _capture_count                  = capture_count;
    _replay_index                   = replay_index;
    _port_request                   = port_request;
    _window_count                   = window_count;
    _match_issued                   = match_issued;
    _learn_pending                  = learn_pending;
    _learn_key                      = learn_key;
    _retry_count                    = retry_count;
    in_ready                        = '0;
    out_data                        = in_data;
    out_first                       = in_first;
    out_last                        = in_last;
    out_byte_count                  = in_byte_count;
    out_valid                       = '0;
    match_request                   = '0;
    match_key                       = mac_destination;
    learn_request                   = learn_pending;
    timeout_cycle_timer_load_count  = 1'b1;
    granted                         = port_grant & port_request;
    all_granted_ready               = (port_request != 0) && ((egress_enable & port_request) == port_request);

    for (m=0; m<HEADER_BEATS; m=m+1) begin
        _header_beats[m]    = header_beats[m];
    end

    if (learn_ack) begin
        _learn_pending  = '0;
    end

    case (state)
        S_IDLE: begin
            _capture_count  = '0;
            _replay_index   = '0;
            _match_issued   = '0;
            _port_request   = '0;

            if (in_enable) begin
                if (in_first) begin
                    _state  = S_CAPTURE;
                end
                else begin
                    //residue from an abandoned frame, discard it
                    in_ready    = 1'b1;
                end
            end
        end
        S_CAPTURE: begin
            in_ready    = 1'b1;

            if (in_enable) begin
                _header_beats[capture_count]    = in_data;
                _capture_count                  = capture_count + 1;

                if (in_last) begin
                    //frame ended inside the header, drop it
                    _state  = S_IDLE;
                end
                else if (capture_count == (HEADER_BEATS - 1)) begin
                    _state          = S_LOOKUP;
                end
            end
        end
        S_LOOKUP: begin
            match_request   = !match_issued;

            if (match_ack) begin
                _match_issued   = 1'b1;
            end

            _retry_count    = '0;

            if (match_response_enable) begin
                //arm the learn only now that the key register is loaded,
                //otherwise the arbiter can grant a learn that still carries
                //the previous frame's source mac
                _learn_key      = mac_source;
                _learn_pending  = 1'b1;
                _window_count   = 2'h2;
                _state          = S_REQUEST;

                if (match_response_no_match) begin
                    _port_request               = {NUMBER_OF_PORTS{1'b1}};
                    _port_request[PORT_INDEX]   = '0;
                end
                else if (match_response_index == PORT_INDEX) begin
                    //hairpin, drop the frame
                    _port_request   = '0;
                    _state          = S_DRAIN;
                end
                else begin
                    _port_request                           = '0;
                    _port_request[match_response_index]     = 1'b1;
                end
            end
        end
        S_REQUEST: begin
            _window_count   = window_count - 1'b1;

            if (window_count == 0) begin
                if (granted == 0) begin
                    //no egress can admit the frame right now. keep asking
                    //(nothing is held, so waiting cannot deadlock) and only
                    //drop when the retry limit expires
                    _window_count   = 2'h2;
                    _retry_count    = retry_count + 1'b1;

                    if (retry_count >= RETRY_LIMIT) begin
                        _port_request   = '0;
                        _state          = S_DRAIN;
                    end
                end
                else begin
                    //prune to the granted set. schedulers that granted late
                    //see their request drop and release without taking beats
                    _port_request   = granted;
                    _state          = S_REPLAY;
                end
            end
        end
        S_REPLAY: begin
            out_data    = header_beats[replay_index];
            out_first   = (replay_index == 0);
            out_last    = '0;
            //header beats are always full, runts never reach replay
            out_byte_count  = FABRIC_DATA_BYTES;

            if (all_granted_ready) begin
                out_valid       = 1'b1;
                _replay_index   = replay_index + 1'b1;

                if (replay_index == (HEADER_BEATS - 1)) begin
                    _state  = S_STREAM;
                end
            end
            else begin
                timeout_cycle_timer_load_count  = '0;

                if (timeout_cycle_timer_expired) begin
                    _port_request   = '0;
                    _state          = S_DRAIN;
                end
            end
        end
        S_STREAM: begin
            if (in_enable && all_granted_ready) begin
                out_valid   = 1'b1;
                in_ready    = 1'b1;

                if (in_last) begin
                    _port_request   = '0;
                    _state          = S_IDLE;
                end
            end
            else if (!all_granted_ready) begin
                timeout_cycle_timer_load_count  = '0;

                if (timeout_cycle_timer_expired) begin
                    _port_request   = '0;
                    _state          = S_DRAIN;
                end
            end
        end
        S_DRAIN: begin
            in_ready    = 1'b1;

            if (in_enable && in_last) begin
                _state  = S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state           <= S_IDLE;
        capture_count   <= '0;
        replay_index    <= '0;
        port_request    <= '0;
        window_count    <= '0;
        match_issued    <= '0;
        learn_pending   <= '0;
        learn_key       <= '0;
        retry_count     <= '0;

        for (c=0; c<HEADER_BEATS; c=c+1) begin
            header_beats[c] <= '0;
        end
    end
    else begin
        state           <= _state;
        capture_count   <= _capture_count;
        replay_index    <= _replay_index;
        port_request    <= _port_request;
        window_count    <= _window_count;
        match_issued    <= _match_issued;
        learn_pending   <= _learn_pending;
        learn_key       <= _learn_key;
        retry_count     <= _retry_count;

        for (c=0; c<HEADER_BEATS; c=c+1) begin
            header_beats[c] <= _header_beats[c];
        end
    end
end

endmodule
