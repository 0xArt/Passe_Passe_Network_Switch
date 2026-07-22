`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 04/27/2023
// Design Name:
// Module Name: queue_slot_receive_handler
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
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
    parameter RECEIVE_QUEUE_SLOTS = 4,
    parameter TECHNOLOGY        = "SIMULATION"
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire                                    enable,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0][7:0]    data,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0]         data_enable,
    input   wire    [RECEIVE_QUEUE_SLOTS-1:0]         push_enable,
    input   wire    [7:0]                           next_queue_slot,
    input   wire                                    next_queue_slot_enable,

    output  logic   [RECEIVE_QUEUE_SLOTS-1:0]         data_ready,
    output  logic   [8:0]                           push_data,
    output  logic                                   push_data_valid,
    output  logic                                   push_data_last
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

localparam QUEUE_SLOT_FIFO_DEPTH = (RECEIVE_QUEUE_SLOTS < 16) ? 16 : RECEIVE_QUEUE_SLOTS;

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
logic   [$clog2(RECEIVE_QUEUE_SLOTS):0]       _receive_slot_select;
reg     [$clog2(RECEIVE_QUEUE_SLOTS):0]       receive_slot_select;
reg                                         first_byte;
logic                                       _first_byte;
reg     [8:0]                               held_data;
logic   [8:0]                               _held_data;
reg                                         held_valid;
logic                                       _held_valid;

assign  next_queue_slot_fifo_clock        = clock;
assign  next_queue_slot_fifo_reset_n      = reset_n;
assign  next_queue_slot_fifo_write_enable = next_queue_slot_enable;
assign  next_queue_slot_fifo_write_data   = next_queue_slot;

always_comb begin
    _state                              = state;
    _receive_slot_select                = receive_slot_select;
    _first_byte                         = first_byte;
    _held_data                          = held_data;
    _held_valid                         = held_valid;
    push_data                           = held_data;
    push_data_valid                     = held_valid;
    push_data_last                      = 0;
    next_queue_slot_fifo_read_enable    = 0;
    data_ready                          = 0;

    case (state)
        S_IDLE: begin
            _first_byte = 1;

            if (next_queue_slot_fifo_read_data_valid) begin
                _receive_slot_select            = next_queue_slot_fifo_read_data;
                next_queue_slot_fifo_read_enable  = 1;
                _state                          = S_PUSH_DATA;
            end
        end
        S_PUSH_DATA: begin
            //the held register gives one byte of lookahead so the final byte
            //of a frame is presented with push_data_last already asserted.
            //the queue slot drains without gaps, so an empty slot while a
            //byte is held means the held byte is the final one
            push_data_last  = held_valid && !data_enable[receive_slot_select];

            if (data_enable[receive_slot_select] && (!held_valid || enable)) begin
                data_ready          = 1 << receive_slot_select;
                _held_data[7:0]     = data[receive_slot_select];
                _held_data[8]       = first_byte;
                _held_valid         = 1;
                _first_byte         = 0;
            end
            else if (held_valid && enable) begin
                _held_valid = 0;
            end

            if (!held_valid && !data_enable[receive_slot_select]) begin
                _state  = S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        receive_slot_select         <= '0;
        first_byte                  <= '0;
        held_data                   <= '0;
        held_valid                  <= '0;
    end
    else begin
        state                       <= _state;
        receive_slot_select         <= _receive_slot_select;
        first_byte                  <= _first_byte;
        held_data                   <= _held_data;
        held_valid                  <= _held_valid;
    end
end

endmodule