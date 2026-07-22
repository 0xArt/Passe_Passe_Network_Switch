`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 04/29/2023
// Design Name:
// Module Name: queue_slot_receive_handler
// Project Name:
// Target Devices:
// Tool Versions:
// Description: replays completed frames from the queue slots toward the
//              switching fabric in arrival order, one DATA_BYTES wide beat
//              at a time. first/last delimiting travels with each stored
//              beat, so the final beat of a frame is presented with
//              push_data_last already asserted
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
module queue_slot_receive_handler#(
    parameter RECEIVE_QUEUE_SLOTS   = 4,
    parameter TECHNOLOGY            = "SIMULATION",
    parameter DATA_BYTES            = 1
)(
    input   wire                                                            clock,
    input   wire                                                            reset_n,
    input   wire                                                            enable,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0][(DATA_BYTES*8)-1:0]           data,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0]                               data_first,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0]                               data_last,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0][$clog2(DATA_BYTES+1)-1:0]     data_byte_count,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0]                               data_enable,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0]                               push_enable,
    input   wire    [7:0]                                                   next_queue_slot,
    input   wire                                                            next_queue_slot_enable,

    output  logic   [RECEIVE_QUEUE_SLOTS-1:0]                               data_ready,
    output  logic   [(DATA_BYTES*8)-1:0]                                    push_data,
    output  logic                                                           push_data_first,
    output  logic                                                           push_data_valid,
    output  logic                                                           push_data_last,
    output  logic   [$clog2(DATA_BYTES+1)-1:0]                              push_data_byte_count
);



wire                                    next_queue_slot_fifo_clock;
logic                                   next_queue_slot_fifo_reset_n;
logic                                   next_queue_slot_fifo_read_enable;
wire                                    next_queue_slot_fifo_write_enable;
wire    [7:0]                           next_queue_slot_fifo_write_data;

wire    [7:0]                           next_queue_slot_fifo_read_data;
wire                                    next_queue_slot_fifo_read_data_valid;
wire                                    next_queue_slot_fifo_full;
wire                                    next_queue_slot_fifo_empty;

synchronous_fifo
#(.DATA_WIDTH               (8),
  .DATA_DEPTH               (64),
  .FIRST_WORD_FALL_THROUGH  (1),
  .TECHNOLOGY               (TECHNOLOGY)
) next_queue_slot_fifo(
    .clock              (next_queue_slot_fifo_clock),
    .reset_n            (next_queue_slot_fifo_reset_n),
    .read_enable        (next_queue_slot_fifo_read_enable),
    .write_enable       (next_queue_slot_fifo_write_enable),
    .write_data         (next_queue_slot_fifo_write_data),

    .read_data          (next_queue_slot_fifo_read_data),
    .read_data_valid    (next_queue_slot_fifo_read_data_valid),
    .full               (next_queue_slot_fifo_full),
    .empty              (next_queue_slot_fifo_empty)
);

typedef enum
{
    S_IDLE,
    S_PUSH_DATA
} state_type;

state_type                                  _state;
state_type                                  state;
logic   [$clog2(RECEIVE_QUEUE_SLOTS):0]     _receive_slot_select;
reg     [$clog2(RECEIVE_QUEUE_SLOTS):0]     receive_slot_select;

assign  next_queue_slot_fifo_clock        = clock;
assign  next_queue_slot_fifo_reset_n      = reset_n;
assign  next_queue_slot_fifo_write_enable = next_queue_slot_enable;
assign  next_queue_slot_fifo_write_data   = next_queue_slot;

always_comb begin
    _state                              = state;
    _receive_slot_select                = receive_slot_select;
    push_data                           = data[receive_slot_select];
    push_data_first                     = data_first[receive_slot_select];
    push_data_last                      = data_last[receive_slot_select];
    push_data_byte_count                = data_byte_count[receive_slot_select];
    push_data_valid                     = 0;
    next_queue_slot_fifo_read_enable    = 0;
    data_ready                          = 0;

    case (state)
        S_IDLE: begin
            if (next_queue_slot_fifo_read_data_valid) begin
                _receive_slot_select                = next_queue_slot_fifo_read_data;
                next_queue_slot_fifo_read_enable    = 1;
                _state                              = S_PUSH_DATA;
            end
        end
        S_PUSH_DATA: begin
            push_data_valid = data_enable[receive_slot_select];

            if (enable && data_enable[receive_slot_select]) begin
                data_ready  = 1 << receive_slot_select;

                //last travels with the stored beat, frame hand off is done
                if (data_last[receive_slot_select]) begin
                    _state  = S_IDLE;
                end
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        receive_slot_select         <= '0;
    end
    else begin
        state                       <= _state;
        receive_slot_select         <= _receive_slot_select;
    end
end

endmodule
