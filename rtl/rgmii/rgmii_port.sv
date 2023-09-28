`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
// 
// Create Date: 04/12/2023
// Design Name: 
// Module Name: rgmii_port
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
module rgmii_port #(
    parameter RECEIVE_QUE_SLOTS = 1
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire    [3:0]   phy_receive_data,
    input   wire            phy_receive_clock,
    input   wire            phy_receive_data_enable,
    input   wire    [8:0]   transmit_data,
    input   wire            transmit_data_enable,

    output  wire            phy_transmit_clock,
    output  wire            phy_transmit_data_valid,
    output  wire    [3:0]   phy_transmit_data,
    output  wire            transmit_data_ready
);

genvar i;


wire                                ethernet_packet_parser_clock;
wire                                ethernet_packet_parser_reset_n;
wire    [8:0]                       ethernet_packet_parser_data;
wire                                ethernet_packet_parser_data_enable;
wire    [31:0]                      ethernet_packet_parser_checksum_result;
wire                                ethernet_packet_parser_checksum_result_enable;
wire                                ethernet_packet_parser_checksum_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_recieve_slot_enable;
wire    [1:0]                       ethernet_packet_parser_speed_code;
wire                                ethernet_packet_parser_data_ready;
wire    [7:0]                       ethernet_packet_parser_checksum_data;
wire                                ethernet_packet_parser_checksum_data_valid;
wire                                ethernet_packet_parser_checksum_data_last;
wire    [7:0]                       ethernet_packet_parser_packet_data;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_packet_data_valid;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_good_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_bad_packet;

ethernet_packet_parser   #(.RECEIVE_QUE_SLOTS(RECEIVE_QUE_SLOTS))
ethernet_packet_parser(
    .clock                  (ethernet_packet_parser_clock),
    .reset_n                (ethernet_packet_parser_reset_n),
    .data                   (ethernet_packet_parser_data),
    .data_enable            (ethernet_packet_parser_data_enable),
    .checksum_result        (ethernet_packet_parser_checksum_result),
    .checksum_result_enable (ethernet_packet_parser_checksum_result_enable),
    .checksum_enable        (ethernet_packet_parser_checksum_enable),
    .recieve_slot_enable    (ethernet_packet_parser_recieve_slot_enable),
    .speed_code             (ethernet_packet_parser_speed_code),

    .data_ready             (ethernet_packet_parser_data_ready),
    .checksum_data          (ethernet_packet_parser_checksum_data),
    .checksum_data_valid    (ethernet_packet_parser_checksum_data_valid),
    .checksum_data_last     (ethernet_packet_parser_checksum_data_last),
    .packet_data            (ethernet_packet_parser_packet_data),
    .packet_data_valid      (ethernet_packet_parser_packet_data_valid),
    .good_packet            (ethernet_packet_parser_good_packet),
    .bad_packet             (ethernet_packet_parser_bad_packet)
);



endmodule
