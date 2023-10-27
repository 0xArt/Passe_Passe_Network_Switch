`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
//
// Create Date: 04/28/2023
// Design Name:
// Module Name: receive_slot_arbiter
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
module receive_slot_arbiter#(
    parameter RECEIVE_QUE_SLOTS = 1
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0][8:0]    data,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         data_enable,

    output  logic   [RECEIVE_QUE_SLOTS-1:0]         ready,
    output  reg     [8:0]                           push_data,
    output  reg                                     push_data_valid
);

typedef enum
{
    S_IDLE,
    S_PASSTHROUGH
} state_type;

state_type                                   _state;
state_type                                   state;
logic   [8:0]                                _push_data;
logic                                        _push_data_valid;
logic   [$clog2(RECEIVE_QUE_SLOTS)-1:0]      _que_slot_select;
reg     [$clog2(RECEIVE_QUE_SLOTS)-1:0]      que_slot_select;


always_comb begin
    _state                          =   state;
    _push_data                      =   push_data;
    _que_slot_select                =   que_slot_select;
    _push_data_valid                =   0;
    ready                           =   0;

    case (state)
        S_IDLE: begin
            if (enable[que_slot_select]) begin
                _state                  =   S_PASSTHROUGH;
            end
            else begin
                if (que_slot_select == (RECEIVE_QUE_SLOTS - 1)) begin
                    _que_slot_select = 0;
                end
                else begin
                    _que_slot_select = que_slot_select + 1;
                end
            end
        end
        S_PASSTHROUGH:  begin
            if (!enable[que_slot_select]) begin
                _state                  =   S_IDLE;
                ready                   =   0;

                if (que_slot_select == (RECEIVE_QUE_SLOTS - 1)) begin
                    _que_slot_select = 0;
                end
                else begin
                    _que_slot_select = que_slot_select + 1;
                end
            end
            else begin

                if (data_enable[que_slot_select]) begin
                    _push_data                      =   data[que_slot_select];
                    _push_data_valid                =   data_enable[que_slot_select];
                    ready                           =   1 << que_slot_select;
                end
            end
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        push_data                   <=  0;
        push_data_valid             <=  0;
        que_slot_select             <=  0;
    end
    else begin
        state                       <=  _state;
        push_data                   <=  _push_data;
        push_data_valid             <=  _push_data_valid;
        que_slot_select             <=  _que_slot_select;
    end
end

endmodule