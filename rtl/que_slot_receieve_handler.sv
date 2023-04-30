`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/29/2023
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
module que_slot_receieve_handler(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire    [7:0]   data,
    input   wire            data_enable,
    input   wire            good_packet,
    input   wire            bad_packet,

    output  reg             fifo_reset_n,
    output  reg             ready,
    output  reg             push_data_ready,
    output  reg     [8:0]   push_data,
    output  reg             push_data_valid
);

typedef enum
{
    S_IDLE,
    S_ADVERTISTE,
    S_PUSH_DATA
} state_type;

state_type          _state;
state_type          state;
logic               _push_data_ready;
logic               _ready;
logic   [8:0]       _push_data;
logic               _push_data_valid;
logic               _fifo_reset_n;
logic               _is_first_byte;
reg                 is_first_byte;

always_comb begin
    _state                          =   state;
    _is_first_byte                  =   is_first_byte;
    _push_data_ready                =   push_data_ready;
    _ready                          =   ready;
    _push_data[7:0]                 =   push_data[7:0];
    _push_data[8]                   =   is_first_byte;
    _push_data_valid                =   0;
    _fifo_reset_n                   =   1;

    case (state)
        S_IDLE: begin
            _ready          =   0;
            _is_first_byte  =   1;

            if (bad_packet) begin
                _fifo_reset_n = 0;
            end
            else if (good_packet) begin
                _state                  =   S_ADVERTISTE;
            end
        end
        S_ADVERTISTE:  begin
            _ready  =   1;

            if (enable) begin
                _state              =   S_PUSH_DATA;
                _push_data_ready    =   1;
            end
        end
        S_PUSH_DATA: begin
            if (data_enable) begin
                _push_data[7:0]     =   data;
                _push_data_valid    =   1;

                if (is_first_byte) begin
                    _is_first_byte  =   0;
                end
            end
            else begin
                _state              =   S_IDLE;
                _push_data_ready    =   0;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        push_data                   <=  0;
        push_data_valid             <=  0;
        fifo_reset_n                <=  0;
        push_data_ready             <=  0;
        ready                       <=  0;
        is_first_byte               <=  0;
    end
    else begin
        state                       <=  _state;
        push_data                   <=  _push_data;
        push_data_valid             <=  _push_data_valid;
        fifo_reset_n                <=  _fifo_reset_n;
        push_data_ready             <=  _push_data_ready;
        ready                       <=  _ready;
        is_first_byte               <=  _is_first_byte;
    end
end

endmodule