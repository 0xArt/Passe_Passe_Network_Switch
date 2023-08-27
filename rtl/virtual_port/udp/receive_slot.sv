`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
//
// Create Date: 08/19/2023
// Design Name:
// Module Name: receive_slot
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
module receive_slot(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [7:0]   data,
    input   wire            data_enable,
    input   wire            good_packet,
    input   wire            bad_packet,
    input   wire    [15:0]  ipv4_flags,
    input   wire    [15:0]  ipv4_identification,
    input   wire            push_data_enable,

    output  reg             ready,
    output  reg             data_ready,
    output  reg     [15:0]  current_ipv4_flags,
    output  reg     [15:0]  current_ipv4_identification,
    output  logic   [7:0]   push_data,
    output  logic           push_data_valid
);


wire            receive_fifo_clock;
wire            receive_fifo_reset_n;
wire    [7:0]   receive_fifo_write_data;
wire            receive_fifo_read_enable;
wire            receive_fifo_write_enable;
wire            receive_fifo_read_data_valid;
wire            receive_fifo_empty;
wire            receive_fifo_full;
wire    [7:0]   receive_fifo_read_data;

synchronous_fifo
#(  .DATA_WIDTH                 (8),
    .DATA_DEPTH                 (1024),
    .FIRST_WORD_FALL_THROUGH    ("TRUE")
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
    S_DRAIN_SLOT
} state_type;

state_type          _state;
state_type          state;
logic               _ready;
logic   [15:0]      _current_ipv4_identification;
logic   [15:0]      _current_ipv4_flags;
reg                 fifo_reset_n;
logic               _fifo_reset_n;
logic               _data_ready;

assign  receive_fifo_clock          =   clock;
assign  receive_fifo_reset_n        =   fifo_reset_n;
assign  receive_fifo_write_data     =   data;
assign  receive_fifo_write_enable   =   data_enable;
assign  receive_fifo_read_enable    =   push_data_enable;

always_comb begin
    _state                          =   state;
    _current_ipv4_identification    =   current_ipv4_identification;
    _current_ipv4_flags             =   current_ipv4_flags;
    push_data                       =   receive_fifo_read_data;
    push_data_valid                 =   receive_fifo_read_data_valid;
    _fifo_reset_n                   =   1;
    _ready                          =   0;
    _data_ready                     =   0;

    case (state)
        S_IDLE: begin
            _ready                          =   1;
            _current_ipv4_identification    =   ipv4_identification;
            _current_ipv4_flags             =   ipv4_flags;

            if (good_packet) begin
                _state              =   S_DRAIN_SLOT;
            end
            if (bad_packet) begin
                _fifo_reset_n = 0;
            end
        end
        S_DRAIN_SLOT: begin
            _data_ready =   1;

            if (receive_fifo_empty) begin
                _state  =   S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <=  S_IDLE;
        ready                       <=  0;
        fifo_reset_n                <=  0;
        current_ipv4_flags          <=  0;
        current_ipv4_identification <=  0;
        data_ready                  <=  0;
    end
    else begin
        state                       <=  _state;
        ready                       <=  _ready;
        fifo_reset_n                <=  _fifo_reset_n;
        current_ipv4_flags          <=  _current_ipv4_flags;
        current_ipv4_identification <=  _current_ipv4_identification;
        data_ready                  <=  _data_ready;
    end
end

endmodule