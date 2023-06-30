`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: ethernet_packet_parser
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
module ethernet_packet_parser#(
    parameter               RECEIVE_QUE_SLOTS       = 1,
    parameter logic [1:0]   SPEED_CODE_GIGABIT      = 2,
    parameter logic [1:0]   SPEED_CODE_100_MEGABIT  = 1,
    parameter logic [1:0]   SPEED_CODE_10_MEGABIT   = 0
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [8:0]                   data,
    input   wire                            data_enable,
    input   wire    [31:0]                  checksum_result,
    input   wire                            checksum_result_enable,
    input   wire                            checksum_enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0] recieve_slot_enable,
    input   wire    [1:0]                   speed_code,

    output  reg                             data_ready,
    output  reg     [7:0]                   checksum_data,
    output  reg                             checksum_data_valid,
    output  reg                             checksum_data_last,
    output  reg     [7:0]                   packet_data,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] packet_data_valid,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] good_packet,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] bad_packet
);


typedef enum
{
    S_IDLE,
    S_PARSE_DATA,
    S_PARSE_CRC,
    S_CHECK_CRC,
    S_DROP_PACKET,
    S_RESTART
} state_type;

integer                                 i;
integer                                 j;
state_type                              _state;
state_type                              state;
reg     [7:0]                           process_counter;
logic   [7:0]                           _process_counter;
reg     [7:0]                           timeout_counter;
logic   [7:0]                           _timeout_counter;
reg     [7:0]                           timeout_counter_limit;
logic   [7:0]                           _timeout_counter_limit;
reg     [12:0][8:0]                     delayed_data;
logic   [12:0][8:0]                     _delayed_data;
logic   [7:0]                           _checksum_data;
logic   [RECEIVE_QUE_SLOTS-1:0]         _packet_data_valid;
logic   [7:0]                           _packet_data;
logic                                   _checksum_data_valid;
logic                                   _checksum_data_last;
reg     [$clog2(RECEIVE_QUE_SLOTS):0]   que_slot_select;
logic   [$clog2(RECEIVE_QUE_SLOTS):0]   _que_slot_select;
logic   [31:0]                          _frame_check_sequence;
reg     [31:0]                          frame_check_sequence;
logic   [RECEIVE_QUE_SLOTS-1:0]         _good_packet;
logic   [RECEIVE_QUE_SLOTS-1:0]         _bad_packet;
logic                                   _data_ready;

always_comb begin
    _state                              =   state;
    _process_counter                    =   process_counter;
    _timeout_counter                    =   timeout_counter;
    _timeout_counter_limit              =   timeout_counter_limit;
    _delayed_data[12:1]                 =   delayed_data[11:0];
    _delayed_data[0]                    =   data;
    _que_slot_select                    =   que_slot_select;
    _frame_check_sequence               =   frame_check_sequence;
    _data_ready                         =   data_ready;
    _checksum_data_valid                =   0;
    _checksum_data_last                 =   0;
    _packet_data_valid                  =   0;
    _good_packet                        =   0;
    _bad_packet                         =   0;

    case (speed_code)
        SPEED_CODE_10_MEGABIT: begin
            _timeout_counter_limit = 40;
        end
        SPEED_CODE_100_MEGABIT: begin
            _timeout_counter_limit = 4;
        end
        SPEED_CODE_GIGABIT: begin
            _timeout_counter_limit = 1;
        end
        default: begin
            _timeout_counter_limit = 0;
        end
    endcase

    case (state)
        S_IDLE: begin
            _data_ready                      = 1;
            _process_counter                 = 0;
            _timeout_counter                 = 0;

            for (j=0;i<RECEIVE_QUE_SLOTS;j=j+1) begin
                if (recieve_slot_enable[j] == 1) begin
                    _que_slot_select =  j;
                end
            end
            if (data_enable) begin
                if (data[8] == 1'b1)  begin

                    if (|recieve_slot_enable == 0) begin
                        _state       = S_DROP_PACKET;
                    end
                    else begin
                        _state                                  =   S_PARSE_DATA;
                        _packet_data                            =   data[7:0];
                        _packet_data_valid[que_slot_select]     =   1;
                    end
                end
            end
        end
        S_PARSE_DATA: begin
            if (data_enable) begin
                _timeout_counter    =   0;

                if(process_counter < 3) begin
                    _process_counter    = process_counter + 1;
                end
                else begin
                    _checksum_data_valid    =   1;
                end
            end
            else begin
                _timeout_counter    =   timeout_counter + 1;
            end

            if (data_enable) begin
                _frame_check_sequence[31:8]             =   frame_check_sequence[23:0];
                _frame_check_sequence[7:0]              =   data[7:0];
                _checksum_data                          =   delayed_data[12][7:0];
                _packet_data                            =   data[7:0];
                _packet_data_valid[que_slot_select]     =   1;
            end

            if ( (data_enable && data[8] == 1'b1) || (timeout_counter >= timeout_counter_limit) )  begin
                _checksum_data_last     =   1;
                _state                  =   S_CHECK_CRC;
                _data_ready             =   0;
                _process_counter        =   0;
            end
        end
        S_CHECK_CRC: begin
            if (checksum_result_enable) begin
                _state              =   S_IDLE;

                if (checksum_result == frame_check_sequence) begin
                    _good_packet[que_slot_select]   = 1;
                end
                else begin
                    _bad_packet[que_slot_select]   = 1;
                end
            end
        end
        S_DROP_PACKET: begin
            if (data_enable) begin
                if (data[8]) begin
                    _state      =   S_RESTART;
                    _data_ready =   0;
                end
            end
        end
        S_RESTART: begin
            _data_ready             =   1;
            _process_counter        =   0;
            _timeout_counter        =   0;

            for (j=0;i<RECEIVE_QUE_SLOTS;j=j+1) begin
                if (recieve_slot_enable[j] == 1) begin
                    _que_slot_select =  j;
                end
            end
            if (|recieve_slot_enable == 0) begin
                _state       = S_DROP_PACKET;
            end
            else begin
                _state                                  =   S_PARSE_DATA;
                _packet_data                            =   data[7:0];
                _packet_data_valid[que_slot_select]     =   1;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                           <=  S_IDLE;
        for (i=0;i< 13;i++) begin
            delayed_data[i]             <=  0;
        end
        checksum_data                   <=  0;
        checksum_data_valid             <=  0;
        checksum_data_last              <=  0;
        packet_data                     <=  0;
        packet_data_valid               <=  0;
        que_slot_select                 <=  0;
        frame_check_sequence            <=  0;
        good_packet                     <=  0;
        bad_packet                      <=  0;
        data_ready                      <=  0;
        process_counter                 <=  0;
        timeout_counter                 <=  0;
        timeout_counter_limit           <=  0;
    end
    else begin
        state                           <=  _state;
        delayed_data                    <=  _delayed_data;
        checksum_data                   <=  _checksum_data;
        checksum_data_valid             <=  _checksum_data_valid;
        checksum_data_last              <=  _checksum_data_last;
        packet_data                     <=  _packet_data;
        packet_data_valid               <=  _packet_data_valid;
        que_slot_select                 <=  _que_slot_select;
        frame_check_sequence            <=  _frame_check_sequence;
        good_packet                     <=  _good_packet;
        bad_packet                      <=  _bad_packet;
        data_ready                      <=  _data_ready;
        process_counter                 <=  _process_counter;
        timeout_counter                 <=  _timeout_counter;
        timeout_counter_limit           <=  _timeout_counter_limit;
    end
end


endmodule