`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
//
// Create Date: 04/27/2023
// Design Name:
// Module Name: que_slot_receieve_handler
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
module que_slot_receieve_handler#(
    parameter RECEIVE_QUE_SLOTS = 4
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire                                    enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0][7:0]    data,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         data_enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         push_enable,

    output  logic   [RECEIVE_QUE_SLOTS-1:0]         data_ready,
    output  reg     [8:0]                           push_data,
    output  reg                                     push_data_valid,
    output  reg                                     push_data_last
);


localparam logic [15:0] TIMEOUT_LIMIT       = 16'h00F;


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


typedef enum
{
    S_IDLE,
    S_PUSH_DATA,
    S_WAIT
} state_type;

state_type                                  _state;
state_type                                  state;
logic   [8:0]                               _push_data;
logic                                       _push_data_valid;
logic                                       _push_data_last;
logic   [$clog2(RECEIVE_QUE_SLOTS)-1:0]     _receive_slot_select;
reg     [$clog2(RECEIVE_QUE_SLOTS)-1:0]     receive_slot_select;
reg                                         first_byte;
logic                                       _first_byte;

assign  timeout_cycle_timer_clock       =   clock;
assign  timeout_cycle_timer_reset_n     =   reset_n;
assign  timeout_cycle_timer_enable      =   1;
assign  timeout_cycle_timer_count       =   TIMEOUT_LIMIT;

always_comb begin
    _state                          =   state;
    _push_data                      =   push_data;
    _receive_slot_select            =   receive_slot_select;
    _first_byte                     =   first_byte;
    _push_data[8]                   =   first_byte;
    data_ready                      =   0;
    _push_data_last                 =   0;
    _push_data_valid                =   0;
    timeout_cycle_timer_load_count  =   0;

    case (state)
        S_IDLE: begin
            _first_byte             =   1;

            if (enable  && push_enable[receive_slot_select]) begin
                _state  =   S_PUSH_DATA;
            end
            else begin
                if (receive_slot_select == RECEIVE_QUE_SLOTS-1) begin
                    _receive_slot_select    =   0;
                end
                else begin
                    _receive_slot_select    =   receive_slot_select + 1;
                end
            end
        end
        S_PUSH_DATA: begin
            if (timeout_cycle_timer_expired) begin
                _state          =   S_IDLE;
                _push_data_last =   1;
            end
            if (enable && data_enable[receive_slot_select]) begin
                data_ready                      =   1 << receive_slot_select;
                _push_data[7:0]                 =   data[receive_slot_select];
                _push_data_valid                =   1;
                timeout_cycle_timer_load_count  =   1;

                if (first_byte) begin
                    _first_byte =   0;
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
        push_data_last              <=  0;
        receive_slot_select         <=  0;
        first_byte                  <=  0;
    end
    else begin
        state                       <=  _state;
        push_data                   <=  _push_data;
        push_data_valid             <=  _push_data_valid;
        push_data_last              <=  _push_data_last;
        receive_slot_select         <=  _receive_slot_select;
        first_byte                  <=  _first_byte;
    end
end

endmodule