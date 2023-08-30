`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 04/25/2023
// Design Name: 
// Module Name: ethernet_frame_parser
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
module ethernet_frame_parser#(
    parameter RECEIVE_QUE_SLOTS = 1
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [8:0]                   data,
    input   wire                            data_enable,
    input   wire    [31:0]                  checksum_result,
    input   wire                            checksum_result_enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0] recieve_slot_enable,

    output  logic                           data_ready,
    output  reg     [7:0]                   checksum_data,
    output  reg                             checksum_data_valid,
    output  reg                             checksum_data_last,
    output  reg     [7:0]                   packet_data,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] packet_data_valid,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] good_packet,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] bad_packet,
    output  reg     [15:0]                  udp_destination,
    output  reg     [15:0]                  ipv4_flags,
    output  reg     [15:0]                  ipv4_identification
);


localparam IPV4_ETHER_TYPE   = 16'h0800;
localparam IPV4_PROTOCOL_UDP = 8'h11;

typedef enum
{
    S_IDLE,
    S_MAC_DESTINATION,
    S_MAC_SOURCE,
    S_TYPE,
    S_IPV4_VERSION,
    S_IPV4_SERVICES,
    S_IPV4_TOTAL_LENGTH,
    S_IPV4_FLAGS,
    S_IPV4_IDENTIFICATION,
    S_IPV4_TIME_TO_LIVE,
    S_IPV4_PROTOCOL,
    S_IPV4_HEADER_CHECKSUM,
    S_IPV4_SOURCE_ADDRESS,
    S_IPV4_DESTINATION_ADDRESS,
    S_UDP_SOURCE_PORT,
    S_UDP_DESTINATION_PORT,
    S_UDP_LENGTH,
    S_UDP_CHECKSUM,
    S_UDP_PAYLOAD,
    S_PAD,
    S_FRAME_CHECK_SEQUENCE,
    S_CHECK_CRC,
    S_RESTART,
    S_DROP_PACKET,
    S_FINISH
} state_type;

state_type                              _state;
state_type                              state;
integer                                 index;
reg     [15:0]                          process_counter;
logic   [15:0]                          _process_counter;
logic   [RECEIVE_QUE_SLOTS-1:0]         _packet_data_valid;
logic   [7:0]                           _packet_data;
logic   [7:0]                           _checksum_data;
logic                                   _checksum_data_valid;
logic                                   _checksum_data_last;
reg     [$clog2(RECEIVE_QUE_SLOTS)-1:0] que_slot_select;
logic   [$clog2(RECEIVE_QUE_SLOTS)-1:0] _que_slot_select;
logic   [31:0]                          _calculated_frame_check_sequence;
reg     [31:0]                          calculated_frame_check_sequence;
logic   [RECEIVE_QUE_SLOTS-1:0]         _good_packet;
logic   [RECEIVE_QUE_SLOTS-1:0]         _bad_packet;
logic   [47:0]                          _mac_destination;
reg     [47:0]                          mac_destination;
logic   [47:0]                          _mac_source;
reg     [47:0]                          mac_source;
logic   [15:0]                          _ether_type;
reg     [15:0]                          ether_type;
logic   [3:0]                           _ipv4_version;
reg     [3:0]                           ipv4_version;
logic   [3:0]                           _ipv4_header_length;
reg     [3:0]                           ipv4_header_length;
logic   [15:0]                          _ipv4_total_length;
reg     [15:0]                          ipv4_total_length;
logic   [15:0]                          _ipv4_identification;
logic   [15:0]                          _ipv4_flags;
logic   [7:0]                           _ipv4_time_to_live;
reg     [7:0]                           ipv4_time_to_live;
logic   [7:0]                           _ipv4_protocol;
reg     [7:0]                           ipv4_protocol;
logic   [7:0]                           _ipv4_services;
reg     [7:0]                           ipv4_services;
logic   [15:0]                          _ipv4_header_checksum;
reg     [15:0]                          ipv4_header_checksum;
logic   [31:0]                          _ipv4_source_address;
reg     [31:0]                          ipv4_source_address;
logic   [31:0]                          _ipv4_destination_address;
reg     [31:0]                          ipv4_destination_address;
logic   [15:0]                          _udp_source_port;
reg     [15:0]                          udp_source_port;
logic   [15:0]                          _udp_destination_port;
reg     [15:0]                          udp_destination_port;
logic   [15:0]                          _udp_length;
reg     [15:0]                          udp_length;
logic   [15:0]                          _udp_checksum;
reg     [15:0]                          udp_checksum;
logic   [31:0]                          _frame_check_sequence;
reg     [31:0]                          frame_check_sequence;
reg     [7:0]                           udp_payload_pad_byte_count;
logic   [7:0]                           _udp_payload_pad_byte_count;
reg     [15:0]                          udp_payload_byte_count;
logic   [15:0]                          _udp_payload_byte_count;

always_comb begin
    _state                              =   state;
    _process_counter                    =   process_counter;
    _checksum_data_valid                =   checksum_data_valid;
    _que_slot_select                    =   que_slot_select;
    _mac_destination                    =   mac_destination;
    _mac_source                         =   mac_source;
    _frame_check_sequence               =   frame_check_sequence;
    _calculated_frame_check_sequence    =   calculated_frame_check_sequence;
    _ether_type                         =   ether_type;
    _ipv4_version                       =   ipv4_version;
    _ipv4_header_length                 =   ipv4_header_length;
    _ipv4_source_address                =   ipv4_source_address;
    _ipv4_destination_address           =   ipv4_destination_address;
    _ipv4_total_length                  =   ipv4_total_length;
    _ipv4_identification                =   ipv4_identification;
    _ipv4_flags                         =   ipv4_flags;
    _ipv4_time_to_live                  =   ipv4_time_to_live;
    _ipv4_protocol                      =   ipv4_protocol;
    _ipv4_services                      =   ipv4_services;
    _ipv4_header_checksum               =   ipv4_header_checksum;
    _udp_source_port                    =   udp_source_port;
    _udp_destination_port               =   udp_destination_port;
    _udp_length                         =   udp_length;
    _udp_checksum                       =   udp_checksum;
    _udp_payload_pad_byte_count         =   udp_payload_pad_byte_count;
    _udp_payload_byte_count             =   udp_payload_byte_count;
    _checksum_data                      =   checksum_data;
    _packet_data                        =   packet_data;
    _checksum_data_valid                =   0;
    _checksum_data_last                 =   0;
    _packet_data_valid                  =   0;
    _good_packet                        =   0;
    _bad_packet                         =   0;
    data_ready                          =   0;
    udp_destination                     =   udp_destination_port;

    case (state)
        S_IDLE: begin
            _calculated_frame_check_sequence = 0;

            for (index=0; index<RECEIVE_QUE_SLOTS; index=index+1) begin
                if (recieve_slot_enable[index]) begin
                    _que_slot_select =  index;
                end
            end
            if (data_enable) begin
                data_ready = 1;

                if (data[8]) begin
                    _mac_destination[7:0]   =   data;
                    _mac_destination[47:8]  =   mac_destination[39:0];
                    _process_counter        =   4;
                    _state                  =   S_MAC_DESTINATION;
                    _checksum_data          =   data;
                    _checksum_data_valid    =   1;
                end

                if (|recieve_slot_enable == 0) begin
                    _state       = S_DROP_PACKET;
                end
            end
        end
        S_MAC_DESTINATION: begin
            if (data_enable) begin
                data_ready                          =   1;
                _process_counter                    =   process_counter - 1;
                _mac_destination[7:0]               =   data;
                _mac_destination[47:8]              =   mac_destination[39:0];
                _checksum_data                      =   data;
                _checksum_data_valid                =   1;

                if (process_counter == 0) begin
                    _state                              =   S_MAC_SOURCE;
                    _process_counter                    =   5;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_MAC_SOURCE: begin
            if (data_enable) begin
                data_ready                          =   1;
                _process_counter                    =   process_counter - 1;
                _mac_source[7:0]                    =   data;
                _mac_source[47:8]                   =   mac_source[39:0];
                _checksum_data                      =   data;
                _checksum_data_valid                =   1;

                if (process_counter == 0) begin
                    _state              =   S_TYPE;
                    _process_counter    =   1;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_TYPE: begin
            if (data_enable) begin
                data_ready                          =   1;
                _process_counter                    =   process_counter - 1;
                _ether_type[7:0]                    =   data;
                _ether_type[15:8]                   =   ether_type[7:0];
                _checksum_data                      =   data;
                _checksum_data_valid                =   1;

                if (process_counter == 0) begin
                    _state              =   S_IPV4_VERSION;
                    _process_counter    =   1;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_IPV4_VERSION: begin
            if (data_enable) begin
                _ipv4_version           =   data[7:4];
                _ipv4_header_length     =   data[3:0];
                _checksum_data          =   data;
                _checksum_data_valid    =   1;
                _state                  =   S_IPV4_SERVICES;
                data_ready              =   1;

                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
            if (ether_type != IPV4_ETHER_TYPE) begin
                _checksum_data_valid    =   1;
                _checksum_data_last     =   1;
                _state                  =   S_DROP_PACKET;
            end
        end
        S_IPV4_SERVICES: begin
            if (data_enable) begin
                _ipv4_services          =   data;
                _state                  =   S_IPV4_TOTAL_LENGTH;
                _process_counter        =   1;
                _checksum_data          =   data;
                _checksum_data_valid    =   1;
                data_ready              =   1;

                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_IPV4_TOTAL_LENGTH: begin
            if (data_enable) begin
                _process_counter            =   process_counter - 1;
                _ipv4_total_length[7:0]     =   data;
                _ipv4_total_length[15:8]    =   ipv4_total_length[7:0];
                _checksum_data              =   data;
                _checksum_data_valid        =   1;
                data_ready                  =   1;

                if (process_counter == 0) begin
                    _process_counter    =   1;
                    _state              =   S_IPV4_IDENTIFICATION;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_IPV4_IDENTIFICATION: begin
            if (data_enable) begin
                _process_counter                    =   process_counter - 1;
                _ipv4_identification[7:0]           =   data;
                _ipv4_identification[15:8]          =   ipv4_identification[7:0];
                _checksum_data                      =   data;
                _checksum_data_valid                =   1;
                data_ready                          =   1;

                if (process_counter == 0) begin
                    _process_counter    =   1;
                    _state              =   S_IPV4_FLAGS;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_IPV4_FLAGS: begin
            if (data_enable) begin
                _process_counter                    =   process_counter - 1;
                _ipv4_flags[7:0]                    =   data;
                _ipv4_flags[15:8]                   =   ipv4_flags[7:0];
                _checksum_data                      =   data;
                _checksum_data_valid                =   1;
                data_ready                          =   1;

                if(process_counter == 0) begin
                    _process_counter    =   1;
                    _state              =   S_IPV4_TIME_TO_LIVE;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_IPV4_TIME_TO_LIVE: begin
            if (data_enable) begin
                _ipv4_time_to_live          =   data;
                _checksum_data              =   data;
                _checksum_data_valid        =   1;
                _state                      =   S_IPV4_PROTOCOL;
                data_ready                  =   1;

                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_IPV4_PROTOCOL: begin
            if (data_enable) begin
                _process_counter            =   1;
                _ipv4_protocol              =   data;
                _checksum_data              =   data;
                _checksum_data_valid        =   1;
                _state                      =   S_IPV4_HEADER_CHECKSUM;
                data_ready                  =   1;

                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_IPV4_HEADER_CHECKSUM: begin
            if (data_enable) begin
                _process_counter                =   process_counter - 1;
                _ipv4_header_checksum[7:0]      =   data;
                _ipv4_header_checksum[15:8]     =   ipv4_header_checksum[7:0];
                _checksum_data                  =   data;
                _checksum_data_valid            =   1;
                data_ready                      =   1;

                if (process_counter == 0) begin
                    _process_counter    =   3;
                    _state              =   S_IPV4_SOURCE_ADDRESS;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
            if (ipv4_protocol != IPV4_PROTOCOL_UDP) begin
                _checksum_data_valid    =   1;
                _checksum_data_last     =   1;
                _state                  =   S_DROP_PACKET;
            end
        end
        S_IPV4_SOURCE_ADDRESS: begin
            if (data_enable) begin
                _process_counter                =   process_counter - 1;
                _ipv4_source_address[7:0]       =   data;
                _ipv4_source_address[31:8]      =   ipv4_source_address[23:0];
                _checksum_data                  =   data;
                _checksum_data_valid            =   1;
                data_ready                      =   1;

                if (process_counter == 0) begin
                    _process_counter    =   3;
                    _state              =   S_IPV4_DESTINATION_ADDRESS;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_IPV4_DESTINATION_ADDRESS: begin
            if (data_enable) begin
                _process_counter                    =   process_counter - 1;
                _ipv4_destination_address[7:0]      =   data;
                _ipv4_destination_address[31:8]     =   ipv4_destination_address[23:0];
                _checksum_data                      =   data;
                _checksum_data_valid                =   1;
                data_ready                          =   1;

                if (process_counter == 0) begin
                    _process_counter    =   1;

                    if (ipv4_flags[12:0] == 0) begin
                        _state              =   S_UDP_SOURCE_PORT;
                    end
                    else begin
                        _process_counter    =   ipv4_total_length - 21;
                        _state              =   S_UDP_PAYLOAD;
                    end
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_UDP_SOURCE_PORT: begin
            if (data_enable) begin
                _process_counter           =   process_counter - 1;
                _udp_source_port[7:0]      =   data;
                _udp_source_port[15:8]     =   udp_source_port[7:0];
                _checksum_data             =   data;
                _checksum_data_valid       =   1;
                data_ready                 =   1;

                if (process_counter == 0) begin
                    _process_counter    =   1;
                    _state              =   S_UDP_DESTINATION_PORT;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_UDP_DESTINATION_PORT: begin
            if (data_enable) begin
                _process_counter                =   process_counter - 1;
                _udp_destination_port[7:0]      =   data;
                _udp_destination_port[15:8]     =   udp_destination_port[7:0];
                _checksum_data                  =   data;
                _checksum_data_valid            =   1;
                data_ready                      =   1;

                if (process_counter == 0) begin
                    _process_counter    =   1;
                    _state              =   S_UDP_LENGTH;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_UDP_LENGTH: begin
            if (data_enable) begin
                _process_counter                =   process_counter - 1;
                _udp_length[7:0]                =   data;
                _udp_length[15:8]               =   udp_length[7:0];
                _checksum_data                  =   data;
                _checksum_data_valid            =   1;
                data_ready                      =   1;

                if (process_counter == 0) begin
                    _process_counter    =   1;
                    _state              =   S_UDP_CHECKSUM;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_UDP_CHECKSUM: begin
            if (ipv4_total_length < 46) begin
                _udp_payload_pad_byte_count =   46 - ipv4_total_length;
                _udp_payload_byte_count     =   ipv4_total_length - 28;
            end
            else begin
                _udp_payload_pad_byte_count =   0;
                _udp_payload_byte_count     =   ipv4_total_length  -  28;
            end

            if (data_enable) begin
                _process_counter                =   process_counter - 1;
                _udp_checksum[7:0]              =   data;
                _udp_checksum[15:8]             =   udp_checksum[7:0];
                _checksum_data                  =   data;
                _checksum_data_valid            =   1;
                data_ready                      =   1;

                if (process_counter == 0) begin
                    _process_counter    =   udp_payload_byte_count - 1;
                    _state              =   S_UDP_PAYLOAD;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_UDP_PAYLOAD: begin
            if (data_enable) begin
                _process_counter                    =   process_counter - 1;
                _packet_data                        =   data;
                _packet_data_valid[que_slot_select] =   1;
                _checksum_data                      =   data;
                _checksum_data_valid                =   1;
                data_ready                          =   1;

                if (process_counter == 0) begin
                    if (udp_payload_byte_count < 18) begin
                        _process_counter    =   18 - udp_payload_byte_count - 1;
                        _state              =   S_PAD;
                    end
                    else begin
                        _process_counter    =   3;
                        _checksum_data_last =   1;
                        _state              =   S_FRAME_CHECK_SEQUENCE;

                    end
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_PAD: begin
            if (data_enable) begin
                _process_counter                    =   process_counter - 1;
                _checksum_data                      =   data;
                _checksum_data_valid                =   1;
                data_ready                          =   1;

                if (process_counter == 0) begin
                    _process_counter    =   3;
                    _checksum_data_last =   1;
                    _state              =   S_FRAME_CHECK_SEQUENCE;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_FRAME_CHECK_SEQUENCE: begin
            if (checksum_result_enable) begin
                _calculated_frame_check_sequence = checksum_result;
            end

            if (data_enable) begin
                _process_counter                    = process_counter - 1;
                _frame_check_sequence[7:0]          = data;
                _frame_check_sequence[31:8]         = frame_check_sequence[23:0];
                data_ready                          =   1;

                if (process_counter == 0) begin
                    _state      =   S_CHECK_CRC;
                end
                if (data[8]) begin
                    _state                          =   S_RESTART;
                    _bad_packet[que_slot_select]    =   1;
                    data_ready                      =   0;
                    _checksum_data_last             =   1;
                end
            end
        end
        S_CHECK_CRC: begin
            _state      =   S_IDLE;

            if (calculated_frame_check_sequence == frame_check_sequence) begin
                _good_packet[que_slot_select]   = 1;
            end
            else begin
                _bad_packet[que_slot_select]    = 1;
            end
        end
        S_DROP_PACKET: begin
            if (data_enable) begin
                data_ready  =   1;

                if (data[8]) begin
                    _state      =   S_RESTART;
                    data_ready =   0;
                end
            end
        end
        S_RESTART: begin
            /*
            for (index=0; index<RECEIVE_QUE_SLOTS; index=index+1 ) begin
                if (recieve_slot_enable[index]) begin
                    _que_slot_select =  index;
                end
            end
            */
            if (checksum_result_enable) begin
                data_ready =   1;

                if (|recieve_slot_enable == 0) begin
                    _state       = S_DROP_PACKET;
                end
                else begin
                    _mac_destination[7:0]   =   data;
                    _mac_destination[47:8]  =   mac_destination[39:0];
                    _process_counter        =   4;
                    _state                  =   S_MAC_DESTINATION;
                    _checksum_data          =   data;
                    _checksum_data_valid    =   1;
                end
            end
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                           <=  S_IDLE;
        process_counter                 <=  0;
        packet_data                     <=  0;
        packet_data_valid               <=  0;
        que_slot_select                 <=  0;
        mac_destination                 <=  0;
        mac_source                      <=  0;
        frame_check_sequence            <=  0;
        good_packet                     <=  0;
        bad_packet                      <=  0;
        calculated_frame_check_sequence <=  0;
        ether_type                      <=  0;
        ipv4_version                    <=  0;
        ipv4_header_length              <=  0;
        ipv4_total_length               <=  0;
        ipv4_source_address             <=  0;
        ipv4_destination_address        <=  0;
        ipv4_services                   <=  0;
        ipv4_identification             <=  0;
        ipv4_flags                      <=  0;
        ipv4_time_to_live               <=  0;
        ipv4_protocol                   <=  0;
        ipv4_header_checksum            <=  0;
        udp_destination_port            <=  0;
        udp_source_port                 <=  0;
        udp_length                      <=  0;
        udp_checksum                    <=  0;
        udp_payload_pad_byte_count      <=  0;
        udp_payload_byte_count          <=  0;
        checksum_data                   <=  0;
        checksum_data_valid             <=  0;
        checksum_data_last              <=  0;
    end
    else begin
        state                           <=  _state;
        process_counter                 <=  _process_counter;
        packet_data                     <=  _packet_data;
        packet_data_valid               <=  _packet_data_valid;
        que_slot_select                 <=  _que_slot_select;
        mac_destination                 <=  _mac_destination;
        mac_source                      <=  _mac_source;
        frame_check_sequence            <=  _frame_check_sequence;
        good_packet                     <=  _good_packet;
        bad_packet                      <=  _bad_packet;
        calculated_frame_check_sequence <=  _calculated_frame_check_sequence;
        ether_type                      <=  _ether_type;
        ipv4_version                    <=  _ipv4_version;
        ipv4_header_length              <=  _ipv4_header_length;
        ipv4_total_length               <=  _ipv4_total_length;
        ipv4_source_address             <=  _ipv4_source_address;
        ipv4_destination_address        <=  _ipv4_destination_address;
        ipv4_services                   <=  _ipv4_services;
        ipv4_identification             <=  _ipv4_identification;
        ipv4_flags                      <=  _ipv4_flags;
        ipv4_time_to_live               <=  _ipv4_time_to_live;
        ipv4_protocol                   <=  _ipv4_protocol;
        ipv4_header_checksum            <=  _ipv4_header_checksum;
        udp_destination_port            <=  _udp_destination_port;
        udp_source_port                 <=  _udp_source_port;
        udp_length                      <=  _udp_length;
        udp_checksum                    <=  _udp_checksum;
        udp_payload_pad_byte_count      <=  _udp_payload_pad_byte_count;
        udp_payload_byte_count          <=  _udp_payload_byte_count;
        checksum_data                   <=  _checksum_data;
        checksum_data_valid             <=  _checksum_data_valid;
        checksum_data_last              <=  _checksum_data_last;
    end
end

endmodule