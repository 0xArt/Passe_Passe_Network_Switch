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
    parameter RECEIVE_QUE_SLOTS = 1
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [8:0]                   data,
    input   wire                            data_enable,
    input   wire    [31:0]                  checksum_result,
    input   wire                            checksum_result_enable,
    input   wire                            checksum_enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0] recieve_slot_enable,

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
    S_RESTART,
    S_DROP_PACKET,
    S_FINISH
} state_type;

integer                                 i;
integer                                 j;
state_type                              _state;
state_type                              state;
reg     [7:0]                           process_counter;
logic   [7:0]                           _process_counter;
reg     [3:0][8:0]                      delayed_data;
logic   [3:0][8:0]                      _delayed_data;
reg     [3:0]                           delayed_data_enable;
logic   [3:0]                           _delayed_data_enable;
logic   [7:0]                           _checksum_data;
logic   [RECEIVE_QUE_SLOTS-1:0]         _packet_data_valid;
logic   [7:0]                           _packet_data;
logic                                   _checksum_data_valid;
logic                                   _checksum_data_last;
reg     [$clog2(RECEIVE_QUE_SLOTS)-1:0] que_slot_select;
logic   [$clog2(RECEIVE_QUE_SLOTS)-1:0] _que_slot_select;
logic   [31:0]                          _frame_check_sequence;
reg     [31:0]                          frame_check_sequence;
logic                                   _good_packet;
logic                                   _bad_packet;
logic                                   _data_ready;
logic   [31:0]                          _calculated_frame_check_sequence;
reg     [31:0]                          calculated_frame_check_sequence;

always_comb begin
    _state                              =   state;
    _process_counter                    =   process_counter;
    _delayed_data[3:1]                  =   delayed_data[2:0];
    _delayed_data[0]                    =   data;
    _delayed_data_enable[3:1]           =   delayed_data_enable[2:0];
    _delayed_data_enable[0]             =   data_enable;
    _que_slot_select                    =   que_slot_select;
    _frame_check_sequence               =   frame_check_sequence;
    _calculated_frame_check_sequence    =   calculated_frame_check_sequence;
    _data_ready                         =   data_ready;
    _checksum_data_valid                =   0;
    _checksum_data_last                 =   0;
    _packet_data_valid                  =   0;
    _good_packet                        =   0;
    _bad_packet                         =   0;

    case (state)
        S_IDLE: begin
            _calculated_frame_check_sequence = 0;
            _data_ready                      = 1;


            for (j=0;i<RECEIVE_QUE_SLOTS;j=j+1) begin
                if (recieve_slot_enable[j] == 1) begin
                    _que_slot_select =  j;
                end
            end
            if (delayed_data_enable[3]) begin
                if (delayed_data[3][8] == 1'b1)  begin

                    if (|recieve_slot_enable == 0) begin
                        _state       = S_DROP_PACKET;
                    end
                    else begin
                        _state                                  =   S_PARSE_DATA;
                        _checksum_data                          =   delayed_data[3][7:0];
                        _checksum_data_valid                    =   1;
                        _packet_data                            =   delayed_data[3][7:0];
                        _packet_data_valid[que_slot_select]     =   1;
                    end
                end
            end
        end
        S_PARSE_DATA: begin
            if (data[8] == 1'b1) begin
                _checksum_data_last     =   1;
            end

            if (checksum_data_valid) begin
                _calculated_frame_check_sequence        =   checksum_result;
            end

            if (delayed_data_enable[3]) begin
                if (data_enable) begin
                    _checksum_data_valid                =   1;
                end
                _checksum_data                          =   delayed_data[3][7:0];
                _packet_data                            =   delayed_data[3][7:0];
                _packet_data_valid[que_slot_select]     =   1;
            end
            else begin
                _state  =   S_PARSE_CRC;
            end
        end
        S_PARSE_CRC: begin

        end
        S_CHECK_CRC: begin
            _data_ready =   0;
            //todo
        end
        S_DROP_PACKET: begin
            if (data_enable == 0) begin
                _state  =   S_IDLE;
            end
        end
        S_RESTART: begin

        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                           <=  S_IDLE;
        process_counter                 <=  0;
        for (i=0;i< 4;i++) begin
            delayed_data[i]             <=  0;
            delayed_data_enable[i]      <=  0;
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
        calculated_frame_check_sequence <=  0;
        data_ready                      <=  0;
    end
    else begin
        state                           <=  _state;
        process_counter                 <=  _process_counter;
        delayed_data                    <=  _delayed_data;
        checksum_data                   <=  _checksum_data;
        checksum_data_valid             <=  _checksum_data_valid;
        checksum_data_last              <=  _checksum_data_last;
        packet_data                     <=  _packet_data;
        packet_data_valid               <=  _packet_data_valid;
        que_slot_select                 <=  _que_slot_select;
        frame_check_sequence            <=  _frame_check_sequence;
        delayed_data                    <=  _delayed_data;
        delayed_data_enable             <=  _delayed_data_enable;
        good_packet                     <=  _good_packet;
        bad_packet                      <=  _bad_packet;
        calculated_frame_check_sequence <=  _calculated_frame_check_sequence;
        data_ready                      <=  _data_ready;
    end
end


endmodule