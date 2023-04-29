`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/14/2023
// Design Name:
// Module Name: ethernet_packet_pusher
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
module ethernet_packet_pusher#(
    parameter RECEIVE_QUE_SLOTS = 1
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         good_packet,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         bad_packet,
    input   wire    [RECEIVE_QUE_SLOTS-1:0][7:0]    packet_data,
    input   wire    [RECEIVE_QUE_SLOTS-1:0]         packet_data_enable,

    output  reg             packet_data_ready,
    output  reg     [8:0]   pushed_data,
    output  reg             pushed_data_valid

);



endmodule