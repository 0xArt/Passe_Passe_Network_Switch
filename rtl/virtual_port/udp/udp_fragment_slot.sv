`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
//
// Create Date: 08/19/2023
// Design Name:
// Module Name: udp_receieve_handler
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
//
//////////////////////////////////////////////////////////////////////////////////
module udp_fragment_slot#(
    parameter XILINX    = 0
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [7:0]   data,
    input   wire            data_enable,
    input   wire            data_last,
    input   wire            push_data_enable,
    input   wire    [15:0]  fragment_id,

    output  reg             ready,
    output  reg             data_ready,
    output  logic   [8:0]   push_data,
    output  logic           push_data_valid,
    output  reg     [15:0]  current_packet_id
);


wire            fragment_fifo_clock;
wire            fragment_fifo_reset_n;
wire    [8:0]   fragment_fifo_write_data;
wire            fragment_fifo_read_enable;
wire            fragment_fifo_write_enable;
wire            fragment_fifo_read_data_valid;
wire            fragment_fifo_empty;
wire            fragment_fifo_full;
wire    [8:0]   fragment_fifo_read_data;

synchronous_fifo
#(  .DATA_WIDTH                 (9),
    .DATA_DEPTH                 (4096),
    .FIRST_WORD_FALL_THROUGH    (1),
    .XILINX                     (XILINX)
) fragment_fifo(
    .clock              (fragment_fifo_clock),
    .reset_n            (fragment_fifo_reset_n),
    .read_enable        (fragment_fifo_read_enable),
    .write_enable       (fragment_fifo_write_enable),
    .write_data         (fragment_fifo_write_data),

    .read_data          (fragment_fifo_read_data),
    .read_data_valid    (fragment_fifo_read_data_valid),
    .full               (fragment_fifo_full),
    .empty              (fragment_fifo_empty)
);


typedef enum
{
    S_IDLE,
    S_CAPTURE_FRAGMENTS,
    S_DRAIN_SLOT
} state_type;

state_type          _state;
state_type          state;
logic               _ready;
logic   [15:0]      _current_packet_id;
logic               _data_ready;
reg     [8:0]       buffer_data;
logic   [8:0]       _buffer_data;
reg                 buffer_data_valid;
logic               _buffer_data_valid;


assign  fragment_fifo_clock         =   clock;
assign  fragment_fifo_reset_n       =   reset_n;
assign  fragment_fifo_write_data    =   buffer_data;
assign  fragment_fifo_write_enable  =   buffer_data_valid;
assign  fragment_fifo_read_enable   =   push_data_enable;

always_comb begin
    _state                          =   state;
    _current_packet_id              =   current_packet_id;
    _buffer_data                    =   buffer_data;
    push_data                       =   fragment_fifo_read_data;
    push_data_valid                 =   fragment_fifo_read_data_valid;
    _data_ready                     =   0;
    _buffer_data_valid              =   0;
    _ready                          =   0;

    case (state)
        S_IDLE: begin
            _ready              =   1;
            _current_packet_id  =   0;

            if (data_enable) begin
                _state              =   S_CAPTURE_FRAGMENTS;
                _current_packet_id  =   fragment_id;
                _buffer_data        =   {1'b1,data};
                _buffer_data_valid  =   1;
            end
        end
        S_CAPTURE_FRAGMENTS:  begin
            if (data_enable) begin
                _buffer_data        =   {1'b0,data};
                _buffer_data_valid  =   1;
            end
            if (data_last) begin
                _state  =   S_DRAIN_SLOT;
            end
        end
        S_DRAIN_SLOT: begin
            _data_ready =   1;

            if (fragment_fifo_empty) begin
                _state  =   S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        ready                       <=  0;
        current_packet_id           <=  0;
        data_ready                  <=  0;
        buffer_data                 <=  0;
        buffer_data_valid           <=  0;
    end
    else begin
        state                       <=  _state;
        ready                       <=  _ready;
        current_packet_id           <=  _current_packet_id;
        data_ready                  <=  _data_ready;
        buffer_data                 <=  _buffer_data;
        buffer_data_valid           <=  _buffer_data_valid;
    end
end

endmodule