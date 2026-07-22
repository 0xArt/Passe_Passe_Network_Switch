`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: ethernet_packet_parser
// Project Name:
// Target Devices:
// Tool Versions:
// Description: receives frames as DATA_BYTES wide beats with explicit
//              first/last delimiting from the byte packager, streams them
//              into a free queue slot unchanged (frames keep their fcs), and
//              validates each frame by running the whole frame including the
//              fcs through the crc generator: a good frame always leaves the
//              fixed crc32 residue. a frame that arrives while no queue slot
//              is free is consumed and dropped. a stalled stream is abandoned
//              through the cycle timer and marked bad
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
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
module ethernet_packet_parser#(
    parameter               RECEIVE_QUEUE_SLOTS     = 1,
    parameter               DATA_BYTES              = 1,
    logic [15:0]            TIMEOUT_LIMIT           = 16'h0FFF
)(
    input   wire                                        clock,
    input   wire                                        reset_n,
    input   wire    [(DATA_BYTES*8)-1:0]                data,
    input   wire                                        data_first,
    input   wire                                        data_last,
    input   wire    [$clog2(DATA_BYTES+1)-1:0]          data_byte_count,
    input   wire                                        data_enable,
    input   wire    [31:0]                              checksum_result,
    input   wire                                        checksum_result_enable,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0]           receive_slot_enable,
    input   wire    [1:0]                               speed_code,     //retained for waveform compatibility, unused

    output  logic                                       data_ready,
    output  reg     [(DATA_BYTES*8)-1:0]                checksum_data,
    output  reg                                         checksum_data_valid,
    output  reg                                         checksum_data_last,
    output  reg     [$clog2(DATA_BYTES+1)-1:0]          checksum_data_byte_count,
    output  reg     [(DATA_BYTES*8)-1:0]                packet_data,
    output  reg                                         packet_data_first,
    output  reg                                         packet_data_last,
    output  reg     [$clog2(DATA_BYTES+1)-1:0]          packet_data_byte_count,
    output  reg     [RECEIVE_QUEUE_SLOTS-1:0]           packet_data_valid,
    output  reg     [RECEIVE_QUEUE_SLOTS-1:0]           good_packet,
    output  reg     [RECEIVE_QUEUE_SLOTS-1:0]           bad_packet,
    output  reg     [7:0]                               next_queue_slot
);

//crc32 of a complete frame including its own fcs always leaves this residue
localparam logic [31:0] RESIDUE = 32'h1CDF4421;


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
assign  timeout_cycle_timer_enable  = 1;
assign  timeout_cycle_timer_count   = TIMEOUT_LIMIT;

typedef enum
{
    S_IDLE,
    S_STREAM,
    S_CHECK,
    S_DROP
} state_type;

integer                                             index;
state_type                                          _state;
state_type                                          state;
reg     [$clog2(RECEIVE_QUEUE_SLOTS):0]             queue_slot_select;
logic   [$clog2(RECEIVE_QUEUE_SLOTS):0]             _queue_slot_select;
reg                                                 frame_aborted;
logic                                               _frame_aborted;
logic   [(DATA_BYTES*8)-1:0]                        _checksum_data;
logic                                               _checksum_data_valid;
logic                                               _checksum_data_last;
logic   [$clog2(DATA_BYTES+1)-1:0]                  _checksum_data_byte_count;
logic   [(DATA_BYTES*8)-1:0]                        _packet_data;
logic                                               _packet_data_first;
logic                                               _packet_data_last;
logic   [$clog2(DATA_BYTES+1)-1:0]                  _packet_data_byte_count;
logic   [RECEIVE_QUEUE_SLOTS-1:0]                   _packet_data_valid;
logic   [RECEIVE_QUEUE_SLOTS-1:0]                   _good_packet;
logic   [RECEIVE_QUEUE_SLOTS-1:0]                   _bad_packet;
logic   [7:0]                                       _next_queue_slot;

always_comb begin
    _state                          = state;
    _queue_slot_select              = queue_slot_select;
    _frame_aborted                  = frame_aborted;
    _checksum_data                  = checksum_data;
    _checksum_data_byte_count       = checksum_data_byte_count;
    _packet_data                    = packet_data;
    _packet_data_first              = packet_data_first;
    _packet_data_last               = packet_data_last;
    _packet_data_byte_count         = packet_data_byte_count;
    _next_queue_slot                = next_queue_slot;
    _checksum_data_valid            = 0;
    _checksum_data_last             = 0;
    _packet_data_valid              = 0;
    _good_packet                    = 0;
    _bad_packet                     = 0;
    data_ready                      = 0;
    timeout_cycle_timer_load_count  = 1;

    case (state)
        S_IDLE: begin
            _frame_aborted  = 0;

            for (index=0; index<RECEIVE_QUEUE_SLOTS; index=index+1) begin
                if (receive_slot_enable[index]) begin
                    _queue_slot_select  = index;
                end
            end

            if (data_enable) begin
                if (data_first && (|receive_slot_enable)) begin
                    data_ready                              = 1;
                    _packet_data                            = data;
                    _packet_data_first                      = data_first;
                    _packet_data_last                       = data_last;
                    _packet_data_byte_count                 = data_byte_count;
                    _packet_data_valid[_queue_slot_select]  = 1;
                    _checksum_data                          = data;
                    _checksum_data_byte_count               = data_byte_count;
                    _checksum_data_valid                    = 1;
                    _checksum_data_last                     = data_last;

                    if (data_last) begin
                        _state  = S_CHECK;
                    end
                    else begin
                        _state  = S_STREAM;
                    end
                end
                else if (data_first) begin
                    //no free queue slot, consume and drop the frame
                    data_ready  = 1;

                    if (!data_last) begin
                        _state  = S_DROP;
                    end
                end
                else begin
                    //residue from an abandoned frame, discard it
                    data_ready  = 1;
                end
            end
        end
        S_STREAM: begin
            if (data_enable) begin
                data_ready                              = 1;
                _packet_data                            = data;
                _packet_data_first                      = data_first;
                _packet_data_last                       = data_last;
                _packet_data_byte_count                 = data_byte_count;
                _packet_data_valid[queue_slot_select]   = 1;
                _checksum_data                          = data;
                _checksum_data_byte_count               = data_byte_count;
                _checksum_data_valid                    = 1;
                _checksum_data_last                     = data_last;

                if (data_last) begin
                    _state  = S_CHECK;
                end
            end
            else begin
                timeout_cycle_timer_load_count  = 0;

                if (timeout_cycle_timer_expired) begin
                    //stalled stream. flush the crc generator and mark the
                    //frame bad when the result comes back
                    _checksum_data_last = 1;
                    _frame_aborted      = 1;
                    _state              = S_CHECK;
                end
            end
        end
        S_CHECK: begin
            timeout_cycle_timer_load_count  = 0;

            if (checksum_result_enable) begin
                if (!frame_aborted && (checksum_result == RESIDUE)) begin
                    _good_packet[queue_slot_select] = 1;
                    _next_queue_slot                = queue_slot_select;
                end
                else begin
                    _bad_packet[queue_slot_select]  = 1;
                end

                _state  = S_IDLE;
            end
            else if (timeout_cycle_timer_expired) begin
                _bad_packet[queue_slot_select]  = 1;
                _state                          = S_IDLE;
            end
        end
        S_DROP: begin
            if (data_enable) begin
                data_ready  = 1;

                if (data_last) begin
                    _state  = S_IDLE;
                end
            end
            else begin
                timeout_cycle_timer_load_count  = 0;

                if (timeout_cycle_timer_expired) begin
                    _state  = S_IDLE;
                end
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        queue_slot_select           <= '0;
        frame_aborted               <= '0;
        checksum_data               <= '0;
        checksum_data_valid         <= '0;
        checksum_data_last          <= '0;
        checksum_data_byte_count    <= '0;
        packet_data                 <= '0;
        packet_data_first           <= '0;
        packet_data_last            <= '0;
        packet_data_byte_count      <= '0;
        packet_data_valid           <= '0;
        good_packet                 <= '0;
        bad_packet                  <= '0;
        next_queue_slot             <= '0;
    end
    else begin
        state                       <= _state;
        queue_slot_select           <= _queue_slot_select;
        frame_aborted               <= _frame_aborted;
        checksum_data               <= _checksum_data;
        checksum_data_valid         <= _checksum_data_valid;
        checksum_data_last          <= _checksum_data_last;
        checksum_data_byte_count    <= _checksum_data_byte_count;
        packet_data                 <= _packet_data;
        packet_data_first           <= _packet_data_first;
        packet_data_last            <= _packet_data_last;
        packet_data_byte_count      <= _packet_data_byte_count;
        packet_data_valid           <= _packet_data_valid;
        good_packet                 <= _good_packet;
        bad_packet                  <= _bad_packet;
        next_queue_slot             <= _next_queue_slot;
    end
end

endmodule
