`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 07/21/2026
// Module Name: cam_access_arbiter
// Description: shares one cam_table between NUMBER_OF_PORTS header engines.
//              matches and learns use independent cam channels so they never
//              contend. a learn is issued as an atomic delete+write pair for
//              the same key on consecutive cycles, which preserves the cam
//              one hot invariant when two ports learn the same mac (mac move).
//              match responses return in issue order, so a tag fifo routes
//              each response back to its requester regardless of cam latency.
//
//              request protocol per port (both channels): assert request with
//              the key held until the matching ack pulse, then deassert.
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
module cam_access_arbiter#(
    parameter NUMBER_OF_PORTS   = 4,
    parameter KEY_WIDTH         = 48,
    parameter TAG_DEPTH         = 8
)(
    input   wire                                                clock,
    input   wire                                                reset_n,
    input   wire    [NUMBER_OF_PORTS-1:0]                       match_request,
    input   wire    [NUMBER_OF_PORTS-1:0][KEY_WIDTH-1:0]        match_key,
    input   wire    [NUMBER_OF_PORTS-1:0]                       learn_request,
    input   wire    [NUMBER_OF_PORTS-1:0][KEY_WIDTH-1:0]        learn_key,
    input   wire                                                cam_match_enable,
    input   wire    [$clog2(NUMBER_OF_PORTS)-1:0]               cam_match_index,
    input   wire                                                cam_no_match,

    output  reg     [NUMBER_OF_PORTS-1:0]                       match_ack,
    output  reg     [NUMBER_OF_PORTS-1:0]                       match_response_valid,
    output  reg     [$clog2(NUMBER_OF_PORTS)-1:0]               match_response_index,
    output  reg                                                 match_response_no_match,
    output  reg     [NUMBER_OF_PORTS-1:0]                       learn_ack,
    output  reg     [KEY_WIDTH-1:0]                             cam_key_match,
    output  reg                                                 cam_key_match_valid,
    output  reg     [KEY_WIDTH-1:0]                             cam_key_delete,
    output  reg                                                 cam_key_delete_valid,
    output  reg     [KEY_WIDTH-1:0]                             cam_key_write,
    output  reg     [$clog2(NUMBER_OF_PORTS)-1:0]               cam_index,
    output  reg                                                 cam_key_write_valid
);

typedef enum
{
    S_LEARN_IDLE,
    S_LEARN_WRITE
} learn_state_type;

integer i;
integer j;

learn_state_type                            _learn_state;
learn_state_type                            learn_state;
logic       [NUMBER_OF_PORTS-1:0]           _match_ack;
logic       [NUMBER_OF_PORTS-1:0]           _match_response_valid;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   _match_response_index;
logic                                       _match_response_no_match;
logic       [NUMBER_OF_PORTS-1:0]           _learn_ack;
logic       [KEY_WIDTH-1:0]                 _cam_key_match;
logic                                       _cam_key_match_valid;
logic       [KEY_WIDTH-1:0]                 _cam_key_delete;
logic                                       _cam_key_delete_valid;
logic       [KEY_WIDTH-1:0]                 _cam_key_write;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   _cam_index;
logic                                       _cam_key_write_valid;

reg         [$clog2(NUMBER_OF_PORTS)-1:0]   match_rr_pointer;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   _match_rr_pointer;
reg         [$clog2(NUMBER_OF_PORTS)-1:0]   learn_rr_pointer;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   _learn_rr_pointer;
reg         [$clog2(NUMBER_OF_PORTS)-1:0]   learn_select;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   _learn_select;
reg         [KEY_WIDTH-1:0]                 learn_key_cached;
logic       [KEY_WIDTH-1:0]                 _learn_key_cached;

//match response tag fifo. responses come back in issue order
reg         [TAG_DEPTH-1:0][$clog2(NUMBER_OF_PORTS)-1:0]    tag_list;
logic       [TAG_DEPTH-1:0][$clog2(NUMBER_OF_PORTS)-1:0]    _tag_list;
reg         [$clog2(TAG_DEPTH)-1:0]                         tag_write_pointer;
logic       [$clog2(TAG_DEPTH)-1:0]                         _tag_write_pointer;
reg         [$clog2(TAG_DEPTH)-1:0]                         tag_read_pointer;
logic       [$clog2(TAG_DEPTH)-1:0]                         _tag_read_pointer;

//round robin selection scratch
logic       [NUMBER_OF_PORTS-1:0]           match_pending;
logic                                       match_found_high;
logic                                       match_found_low;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   match_select_high;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   match_select_low;
logic                                       match_found;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   match_select;
logic       [NUMBER_OF_PORTS-1:0]           learn_pending;
logic                                       learn_found_high;
logic                                       learn_found_low;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   learn_select_high;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   learn_select_low;
logic                                       learn_found;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   learn_select_next;

always_comb begin
    _learn_state                = learn_state;
    _match_ack                  = '0;
    _match_response_valid       = '0;
    _match_response_index       = match_response_index;
    _match_response_no_match    = match_response_no_match;
    _learn_ack                  = '0;
    _cam_key_match              = cam_key_match;
    _cam_key_match_valid        = '0;
    _cam_key_delete             = cam_key_delete;
    _cam_key_delete_valid       = '0;
    _cam_key_write              = cam_key_write;
    _cam_index                  = cam_index;
    _cam_key_write_valid        = '0;
    _match_rr_pointer           = match_rr_pointer;
    _learn_rr_pointer           = learn_rr_pointer;
    _learn_select               = learn_select;
    _learn_key_cached           = learn_key_cached;
    _tag_write_pointer          = tag_write_pointer;
    _tag_read_pointer           = tag_read_pointer;

    for (i=0; i<TAG_DEPTH; i=i+1) begin
        _tag_list[i]    = tag_list[i];
    end

    //mask out ports that were acked last cycle so a request that has not
    //dropped yet is not granted twice
    match_pending   = match_request & ~match_ack;
    learn_pending   = learn_request & ~learn_ack;

    //match channel round robin
    match_found_high    = '0;
    match_found_low     = '0;
    match_select_high   = '0;
    match_select_low    = '0;

    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin
        if (!match_found_high && (i > match_rr_pointer) && match_pending[i]) begin
            match_select_high   = i;
            match_found_high    = 1'b1;
        end
        if (!match_found_low && (i <= match_rr_pointer) && match_pending[i]) begin
            match_select_low    = i;
            match_found_low     = 1'b1;
        end
    end

    match_found     = match_found_high || match_found_low;
    match_select    = match_found_high ? match_select_high : match_select_low;

    if (match_found) begin
        _match_ack[match_select]        = 1'b1;
        _cam_key_match                  = match_key[match_select];
        _cam_key_match_valid            = 1'b1;
        _match_rr_pointer               = match_select;
        _tag_list[tag_write_pointer]    = match_select;
        _tag_write_pointer              = tag_write_pointer + 1'b1;
    end

    //route the cam response back to the requester in issue order
    if (cam_match_enable || cam_no_match) begin
        _match_response_valid[tag_list[tag_read_pointer]]   = 1'b1;
        _match_response_index                               = cam_match_index;
        _match_response_no_match                            = cam_no_match;
        _tag_read_pointer                                   = tag_read_pointer + 1'b1;
    end

    //learn channel round robin. delete then write on consecutive cycles
    learn_found_high    = 0;
    learn_found_low     = 0;
    learn_select_high   = '0;
    learn_select_low    = '0;

    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin
        if (!learn_found_high && (i > learn_rr_pointer) && learn_pending[i]) begin
            learn_select_high   = i;
            learn_found_high    = 1'b1;
        end
        if (!learn_found_low && (i <= learn_rr_pointer) && learn_pending[i]) begin
            learn_select_low    = i;
            learn_found_low     = 1'b1;
        end
    end

    learn_found         = learn_found_high || learn_found_low;
    learn_select_next   = learn_found_high ? learn_select_high : learn_select_low;

    case (learn_state)
        S_LEARN_IDLE: begin
            if (learn_found) begin
                _learn_ack[learn_select_next]   = 1'b1;
                _cam_key_delete                 = learn_key[learn_select_next];
                _cam_key_delete_valid           = 1'b1;
                _learn_key_cached               = learn_key[learn_select_next];
                _learn_select                   = learn_select_next;
                _learn_rr_pointer               = learn_select_next;
                _learn_state                    = S_LEARN_WRITE;
            end
        end
        S_LEARN_WRITE: begin
            _cam_key_write          = learn_key_cached;
            _cam_index              = learn_select;
            _cam_key_write_valid    = 1'b1;
            _learn_state            = S_LEARN_IDLE;
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        learn_state                 <= S_LEARN_IDLE;
        match_ack                   <= '0;
        match_response_valid        <= '0;
        match_response_index        <= '0;
        match_response_no_match     <= '0;
        learn_ack                   <= '0;
        cam_key_match               <= '0;
        cam_key_match_valid         <= '0;
        cam_key_delete              <= '0;
        cam_key_delete_valid        <= '0;
        cam_key_write               <= '0;
        cam_index                   <= '0;
        cam_key_write_valid         <= '0;
        match_rr_pointer            <= '0;
        learn_rr_pointer            <= '0;
        learn_select                <= '0;
        learn_key_cached            <= '0;
        tag_write_pointer           <= '0;
        tag_read_pointer            <= '0;

        for (j=0; j<TAG_DEPTH; j=j+1) begin
            tag_list[j]             <= '0;
        end
    end
    else begin
        learn_state                 <= _learn_state;
        match_ack                   <= _match_ack;
        match_response_valid        <= _match_response_valid;
        match_response_index        <= _match_response_index;
        match_response_no_match     <= _match_response_no_match;
        learn_ack                   <= _learn_ack;
        cam_key_match               <= _cam_key_match;
        cam_key_match_valid         <= _cam_key_match_valid;
        cam_key_delete              <= _cam_key_delete;
        cam_key_delete_valid        <= _cam_key_delete_valid;
        cam_key_write               <= _cam_key_write;
        cam_index                   <= _cam_index;
        cam_key_write_valid         <= _cam_key_write_valid;
        match_rr_pointer            <= _match_rr_pointer;
        learn_rr_pointer            <= _learn_rr_pointer;
        learn_select                <= _learn_select;
        learn_key_cached            <= _learn_key_cached;
        tag_write_pointer           <= _tag_write_pointer;
        tag_read_pointer            <= _tag_read_pointer;

        for (j=0; j<TAG_DEPTH; j=j+1) begin
            tag_list[j]             <= _tag_list[j];
        end
    end
end

endmodule
