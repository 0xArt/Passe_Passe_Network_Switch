`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: ethernet_packet_generator
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
module ethernet_packet_generator(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire    [7:0]   payload_data,
    input   wire            payload_data_enable,
    input   wire            pll_lock,

    output  wire    [7:0]   transmit_data,
    output  wire            transmit_data_valid
);


endmodule