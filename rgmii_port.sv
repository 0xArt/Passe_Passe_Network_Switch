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


module rgmii_port(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire            phy_rx_clock,
    input   wire            phy_rx_data_enable,
    input   wire    [3:0]   phy_rx_data,
    output  wire            phy_tx_clock,
    output  wire            phy_tx_data_valid,
    output  wire    [3:0]   phy_tx_data
);




    
endmodule
