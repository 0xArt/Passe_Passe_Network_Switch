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
    input   wire    [7:0]                   data,
    input   wire                            data_enable,
    input   wire    [7:0]                   checksum_data,
    input   wire                            checksum_data_enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0] recieve_slot_enable,

    output  reg                             checksum_data_valid,
    output  reg     [7:0]                   packet_data,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] packet_data_valid,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] good_packet,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] bad_packet
);


typedef enum
{
    S_IDLE,
    S_PREAMBLE,
    S_START_OF_FRAME,
    S_MAC_DESTINATION,
    S_MAC_SOURCE,
    S_PAYLOAD,
    S_CHECK_CRC,
    S_DROP_PACKET,
    S_FINISH
} state_type;

integer                                 i;
integer                                 j;
reg     [7:0]                           process_counter;
logic   [7:0]                           _process_counter;
reg     [3:0][7:0]                      delayed_data;
logic   [3:0][7:0]                      _delayed_data;
reg     [3:0][7:0]                      delayed_data_enable;
logic   [3:0][7:0]                      _delayed_data_enable;
logic                                   _checksum_data_ready;
logic   [RECEIVE_QUE_SLOTS-1:0]         _packet_data_valid;
logic   [7:0]                           _packet_data;
logic                                   _checksum_data_valid;
reg     [$clog2(RECEIVE_QUE_SLOTS)-1:0] que_slot_select;
logic   [$clog2(RECEIVE_QUE_SLOTS)-1:0] _que_slot_select;
logic   [47:0]                          _mac_destination;
reg     [47:0]                          mac_destination;
logic   [47:0]                          _mac_source;
reg     [47:0]                          mac_source;
logic   [31:0]                          _frame_check_sequence;
reg     [31:0]                          frame_check_sequence;
logic                                   _good_packet;
logic                                   _bad_packet;
logic   [31:0]                          _calculated_frame_check_sequence;
reg     [31:0]                          calculated_frame_check_sequence;

state_type  _state;
state_type  state;

always_comb begin
    _state                              =   state;
    _process_counter                    =   process_counter;
    _delayed_data[3:1]                  =   delayed_data[2:0];
    _delayed_data[0]                    =   data;
    _delayed_data_enable[3:1]           =   delayed_data_enable[2:0];
    _delayed_data_enable[0]             =   data_enable;
    _checksum_data_valid                =   checksum_data_valid;
    _que_slot_select                    =   que_slot_select;
    _mac_destination                    =   mac_destination;
    _mac_source                         =   mac_source;
    _frame_check_sequence               =   frame_check_sequence;
    _calculated_frame_check_sequence    =   calculated_frame_check_sequence;
    _packet_data_valid                  =   0;
    _good_packet                        =   0;
    _bad_packet                         =   0;

    case (state)
        S_IDLE: begin
            if (delayed_data_enable[3]) begin
                for (j=0;i<RECEIVE_QUE_SLOTS;j=j+1) begin
                    if (recieve_slot_enable[j] == 1) begin
                        _que_slot_select =  j;
                    end
                end
                if (delayed_data[3] == 8'h55)  begin
                    if (|recieve_slot_enable == 0) begin
                        _state       = S_DROP_PACKET;
                    end
                    else begin
                        _state           = S_PREAMBLE;
                        _process_counter = 6;
                    end
                end
            end
        end
        S_PREAMBLE: begin
            if (delayed_data_enable[3]) begin
                if (delayed_data[3] ==  8'h55) begin
                    _process_counter = process_counter - 1;
                    if(process_counter == 0) begin
                        _state = S_START_OF_FRAME;
                    end
                end
                else begin
                    _state = S_DROP_PACKET;
                end
            end
        end
        S_START_OF_FRAME: begin
            if (delayed_data_enable[3]) begin
                if (delayed_data[3] ==  8'hD5) begin
                    _state           = S_MAC_DESTINATION;
                    _process_counter = 6;
                end
                else begin
                    _state = S_DROP_PACKET;
                end
            end
        end
        S_MAC_DESTINATION: begin
            if (delayed_data_enable[3]) begin
                _process_counter                    =   process_counter - 1;
                _mac_destination[7:0]               =   delayed_data[3];
                _mac_destination[47:8]              =   mac_destination[39:0];
                _packet_data_valid[que_slot_select] =   1;

                if (process_counter == 0) begin
                    _state                              =   S_MAC_SOURCE;
                    _packet_data_valid[que_slot_select] = 1;
                end
            end
            else begin
                _state                          =   S_DROP_PACKET;
                _bad_packet[que_slot_select]    =   1;
            end
        end
        S_MAC_SOURCE: begin
            if (delayed_data_enable[3]) begin
                _process_counter                    =   process_counter - 1;
                _mac_source[7:0]                    =   delayed_data[3];
                _mac_source[47:8]                   =   mac_source[39:0];
                _packet_data_valid[que_slot_select] =   1;

                if (process_counter == 0) begin
                    _state  =   S_PAYLOAD;
                end
            end
            else begin
                _state                          =   S_DROP_PACKET;
                _bad_packet[que_slot_select]    =   1;
            end
        end
        S_PAYLOAD: begin
            if (data_enable == 0) begin
                _checksum_data_valid    =   0;
            end

            if (checksum_data_enable) begin
                _calculated_frame_check_sequence[7:0]   =   checksum_data;
                _calculated_frame_check_sequence[31:8]  =   calculated_frame_check_sequence[23:0];
            end

            if (delayed_data_enable[3]) begin
                _frame_check_sequence[7:0]              =   delayed_data[3];
                _frame_check_sequence[31:8]             =   frame_check_sequence[23:0];
                _process_counter                        =   process_counter - 1;
                _packet_data_valid[que_slot_select]     =   1;
            end
            else begin
                _state  =   S_CHECK_CRC;
            end
        end
        S_CHECK_CRC: begin
            //todo
        end
        S_DROP_PACKET: begin
            if (data_enable == 0) begin
                _state  =   S_IDLE;
            end
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
        checksum_data_valid             <=  0;
        packet_data                     <=  0;
        packet_data_valid               <=  0;
        que_slot_select                 <=  0;
        mac_destination                 <=  0;
        mac_source                      <=  0;
        frame_check_sequence            <=  0;
        good_packet                     <=  0;
        bad_packet                      <=  0;
        calculated_frame_check_sequence  <=  0;
    end
    else begin
        state                           <=  _state;
        process_counter                 <=  _process_counter;
        delayed_data                    <=  _delayed_data;
        checksum_data_valid             <=  _checksum_data_valid;
        packet_data                     <=  _packet_data;
        packet_data_valid               <=  _packet_data_valid;
        que_slot_select                 <=  _que_slot_select;
        mac_destination                 <=  _mac_destination;
        mac_source                      <=  _mac_source;
        frame_check_sequence            <=  _frame_check_sequence;
        delayed_data                    <=  _delayed_data;
        delayed_data_enable             <=  _delayed_data_enable;
        good_packet                     <=  _good_packet;
        bad_packet                      <=  _bad_packet;
        calculated_frame_check_sequence <=  _calculated_frame_check_sequence;
    end
end


endmodule