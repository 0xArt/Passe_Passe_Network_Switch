`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: queue_slot
// Project Name:
// Target Devices:
// Tool Versions:
// Description: store and forward buffer for one frame, held as DATA_BYTES
//              wide beats with their first/last flags and byte count. a bad
//              frame is discarded by resetting the fifo, a good frame drains
//              out through the receive handler
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
module queue_slot#(
    parameter TECHNOLOGY    = "SIMULATION",
    parameter DATA_BYTES    = 1
)(
    input   wire                                        clock,
    input   wire                                        reset_n,
    input   wire    [(DATA_BYTES*8)-1:0]                data,
    input   wire                                        data_first,
    input   wire                                        data_last,
    input   wire    [$clog2(DATA_BYTES+1)-1:0]          data_byte_count,
    input   wire                                        data_enable,
    input   wire                                        good_packet,
    input   wire                                        bad_packet,
    input   wire                                        push_data_enable,

    output  reg                                         ready,
    output  reg                                         data_ready,
    output  logic   [(DATA_BYTES*8)-1:0]                push_data,
    output  logic                                       push_data_first,
    output  logic                                       push_data_last,
    output  logic   [$clog2(DATA_BYTES+1)-1:0]          push_data_byte_count,
    output  logic                                       push_data_valid
);

localparam BYTE_COUNT_WIDTH = $clog2(DATA_BYTES+1);
localparam BUNDLE_WIDTH     = (DATA_BYTES*8) + BYTE_COUNT_WIDTH + 2;
localparam FIFO_DEPTH       = 2048 / DATA_BYTES;


wire                        receive_fifo_clock;
wire                        receive_fifo_reset_n;
wire    [BUNDLE_WIDTH-1:0]  receive_fifo_write_data;
wire                        receive_fifo_read_enable;
wire                        receive_fifo_write_enable;
wire                        receive_fifo_read_data_valid;
wire                        receive_fifo_empty;
wire                        receive_fifo_full;
wire    [BUNDLE_WIDTH-1:0]  receive_fifo_read_data;

synchronous_fifo
#(  .DATA_WIDTH                 (BUNDLE_WIDTH),
    .DATA_DEPTH                 (FIFO_DEPTH),
    .FIRST_WORD_FALL_THROUGH    (1),
    .TECHNOLOGY                 (TECHNOLOGY)
) receive_fifo(
    .clock              (receive_fifo_clock),
    .reset_n            (receive_fifo_reset_n),
    .read_enable        (receive_fifo_read_enable),
    .write_enable       (receive_fifo_write_enable),
    .write_data         (receive_fifo_write_data),

    .read_data          (receive_fifo_read_data),
    .read_data_valid    (receive_fifo_read_data_valid),
    .full               (receive_fifo_full),
    .empty              (receive_fifo_empty)
);


typedef enum
{
    S_IDLE,
    S_FILLING_SLOT,
    S_WAIT_EMPTY,
    S_DRAIN_SLOT
} state_type;

state_type          _state;
state_type          state;
logic               _ready;
reg                 fifo_reset_n;
logic               _fifo_reset_n;
logic               _data_ready;

assign  receive_fifo_clock          = clock;
assign  receive_fifo_reset_n        = fifo_reset_n;
assign  receive_fifo_write_data     = {data_last, data_first, data_byte_count, data};
assign  receive_fifo_write_enable   = data_enable;
assign  receive_fifo_read_enable    = push_data_enable;

always_comb begin
    _state                          = state;
    push_data                       = receive_fifo_read_data[(DATA_BYTES*8)-1:0];
    push_data_byte_count            = receive_fifo_read_data[(DATA_BYTES*8) +: BYTE_COUNT_WIDTH];
    push_data_first                 = receive_fifo_read_data[BUNDLE_WIDTH-2];
    push_data_last                  = receive_fifo_read_data[BUNDLE_WIDTH-1];
    push_data_valid                 = receive_fifo_read_data_valid;
    _fifo_reset_n                   = 1;
    _ready                          = 0;
    _data_ready                     = 0;

    case (state)
        S_IDLE: begin
            _ready  = 1;

            if (data_enable) begin
                _state  = S_FILLING_SLOT;
            end
            if (good_packet) begin
                _state  = S_DRAIN_SLOT;
            end
            if (bad_packet) begin
                _fifo_reset_n   = 0;
                _ready          = 0;
                _state          = S_WAIT_EMPTY;
            end
        end
        S_FILLING_SLOT: begin
            if (good_packet) begin
                _state  = S_DRAIN_SLOT;
            end
            if (bad_packet) begin
                _fifo_reset_n   = 0;
                _state          = S_WAIT_EMPTY;
            end
        end
        S_DRAIN_SLOT: begin
            _data_ready = 1;

            if (receive_fifo_empty) begin
                _state  = S_IDLE;
            end
        end
        S_WAIT_EMPTY: begin
            if (receive_fifo_empty) begin
                _state  = S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state           <=  S_IDLE;
        ready           <=  0;
        fifo_reset_n    <=  0;
        data_ready      <=  0;
    end
    else begin
        state           <=  _state;
        ready           <=  _ready;
        fifo_reset_n    <=  _fifo_reset_n;
        data_ready      <=  _data_ready;
    end
end

endmodule
