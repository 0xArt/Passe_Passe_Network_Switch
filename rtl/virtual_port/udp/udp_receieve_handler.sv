`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
//
// Create Date: 04/27/2023
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
module udp_receieve_handler#(
    parameter FRAGMENT_SLOTS    = 4,
    parameter RECEIVE_QUE_SLOTS = 4
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0][7:0]    data,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         data_enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0][15:0]   ipv4_identification,
    input   wire    [RECEIVE_QUE_SLOTS-1:0][15:0]   ipv4_flags,
    input   wire    [FRAGMENT_SLOTS-1:0]            fragment_slot_empty,
    input   wire    [FRAGMENT_SLOTS-1:0][15:0]      fragment_slot_packet_id,

    output  logic   [RECEIVE_QUE_SLOTS-1:0]         data_ready,
    output  reg     [7:0]                           push_data,
    output  reg     [FRAGMENT_SLOTS-1:0]            push_data_valid,
    output  reg     [FRAGMENT_SLOTS-1:0]            push_data_last,
    output  reg     [15:0]                          packet_id
);


localparam logic [15:0] TIMEOUT_LIMIT       = 16'h004;


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
    S_CHECK_FRAGMENT_STATUS,
    S_FIND_EMPTY_FRAGMENT_SLOT,
    S_FIND_MATCHING_FRAGMENT_SLOT,
    S_FLUSH_NON_DATAGRAM_DATA,
    S_PUSH_DATA
} state_type;

state_type                                  _state;
state_type                                  state;
logic   [7:0]                               _push_data;
logic   [FRAGMENT_SLOTS-1:0]                _push_data_valid;
logic   [15:0]                              _packet_id;
reg     [15:0]                              more_fragments;
logic   [15:0]                              _more_fragments;
logic   [$clog2(FRAGMENT_SLOTS)-1:0]        _fragment_slot_select;
reg     [$clog2(FRAGMENT_SLOTS)-1:0]        fragment_slot_select;
logic   [12:0]                              _fragment_offset;
reg     [12:0]                              fragment_offset;
logic   [FRAGMENT_SLOTS-1:0]                _push_data_last;
logic   [$clog2(RECEIVE_QUE_SLOTS)-1:0]     _receive_slot_select;
reg     [$clog2(RECEIVE_QUE_SLOTS)-1:0]     receive_slot_select;
logic   [7:0]                               _process_counter;
reg     [7:0]                               process_counter;

assign  timeout_cycle_timer_clock       =   clock;
assign  timeout_cycle_timer_reset_n     =   reset_n;
assign  timeout_cycle_timer_enable      =   1;
assign  timeout_cycle_timer_count       =   TIMEOUT_LIMIT;

always_comb begin
    _state                          =   state;
    _push_data                      =   push_data;
    _fragment_offset                =   fragment_offset;
    _more_fragments                 =   more_fragments;
    _fragment_slot_select           =   fragment_slot_select;
    _receive_slot_select            =   receive_slot_select;
    _process_counter                =   process_counter;
    _packet_id                      =   packet_id;
    data_ready                      =   0;
    _push_data_last                 =   0;
    _push_data_valid                =   0;
    timeout_cycle_timer_load_count  =   0;

    case (state)
        S_IDLE: begin
            _packet_id              =   ipv4_identification[receive_slot_select];
            _more_fragments         =   ipv4_flags[receive_slot_select][13];
            _fragment_offset        =   ipv4_flags[receive_slot_select][12:0];

            if (enable[receive_slot_select]) begin
                _state  =   S_CHECK_FRAGMENT_STATUS;
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
        S_CHECK_FRAGMENT_STATUS: begin
            _fragment_slot_select   =   0;

            if (fragment_offset == 0) begin
                _state  =   S_FIND_EMPTY_FRAGMENT_SLOT;
            end
            else begin
                _state  =   S_FIND_MATCHING_FRAGMENT_SLOT;
            end
        end
        S_FIND_EMPTY_FRAGMENT_SLOT: begin
            timeout_cycle_timer_load_count  =   1;

            if (fragment_slot_empty[fragment_slot_select]) begin
                _state  =   S_PUSH_DATA;
            end
            else begin
                if (fragment_slot_select == (FRAGMENT_SLOTS - 1)) begin
                    _fragment_slot_select   =   0;
                end
                else begin
                    _fragment_slot_select   =   fragment_slot_select + 1;
                end
            end
        end
        S_FIND_MATCHING_FRAGMENT_SLOT: begin
            timeout_cycle_timer_load_count  =   1;

            if (fragment_slot_packet_id[fragment_slot_select] == packet_id) begin
                _state                          =   S_FLUSH_NON_DATAGRAM_DATA;
                _process_counter                =   14;
            end
            else begin
                if (fragment_slot_select == (FRAGMENT_SLOTS - 1)) begin
                    _fragment_slot_select   =   0;
                end
                else begin
                    _fragment_slot_select   =   fragment_slot_select + 1;
                end
            end
        end
        S_FLUSH_NON_DATAGRAM_DATA: begin
            if (data_enable[receive_slot_select]) begin
                _process_counter                =   process_counter - 1;
                data_ready                      =   1 << receive_slot_select;
                timeout_cycle_timer_load_count  =   1;
            end

            if (process_counter == 0) begin
                _state      =   S_PUSH_DATA;
                data_ready  =   0;
            end
        end
        S_PUSH_DATA: begin
            if (timeout_cycle_timer_expired) begin
                _state          =   S_IDLE;

                if (more_fragments == 0) begin
                    _push_data_last =   1 << fragment_slot_select;
                end
            end
            if (data_enable[receive_slot_select]) begin
                data_ready                      =   1 << receive_slot_select;
                _push_data                      =   data[receive_slot_select];
                _push_data_valid                =   1 << fragment_slot_select;
                timeout_cycle_timer_load_count  =   1;
            end
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        push_data                   <=  0;
        push_data_valid             <=  0;
        packet_id                   <=  0;
        more_fragments              <=  0;
        fragment_offset             <=  0;
        push_data_last              <=  0;
        receive_slot_select         <=  0;
        fragment_slot_select        <=  0;
        process_counter             <=  0;
    end
    else begin
        state                       <=  _state;
        push_data                   <=  _push_data;
        push_data_valid             <=  _push_data_valid;
        packet_id                   <=  _packet_id;
        more_fragments              <=  _more_fragments;
        fragment_offset             <=  _fragment_offset;
        push_data_last              <=  _push_data_last;
        receive_slot_select         <=  _receive_slot_select;
        fragment_slot_select        <=  _fragment_slot_select;
        process_counter             <=  _process_counter;
    end
end

endmodule