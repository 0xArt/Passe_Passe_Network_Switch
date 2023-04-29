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
    input   wire            phy_rx_clock,
    input   wire            phy_rx_data_enable,
    input   wire    [3:0]   phy_rx_data,
    input   wire    [8:0]   transmit_data,
    input   wire            transmit_data_enable,

    output  wire            phy_tx_clock,
    output  wire            phy_tx_data_valid,
    output  wire    [3:0]   phy_tx_data,
    output  wire            transmit_data_ready,
    output  wire            rgmii_reference_clock,
    output  wire            valid_packet,
    output  wire            invalid_packet,
    output  wire    [47:0]  parsed_mac_destination,
    output  wire    [47:0]  parsed_mac_source
);

genvar i;

wire            rgmii_rx_clock;
wire            pll_clock;

wire    [7:0]   ddr_out_data_buffer_input;
wire    [3:0]   ddr_out_data_buffer_output;
wire            ddr_out_data_buffer_clock;

generate
    for (i=0;i<4;i=i+1) begin : generate_ddr_out
        DDR_OUT ddr_out_data_buffer(
            .DF     (ddr_out_data_buffer_input[i+4]),
            .DR     (ddr_out_data_buffer_input[i]),
            .EN     (1),
            .CLK    (ddr_out_data_clock),
            .ALn    (1),
            .ADn    (1),
            .SLn    (1),
            .SD     (1),
            .Q      (ddr_out_data_buffer_output[i])
        );
    end
endgenerate


wire    ddr_out_txctl_buffer_input;
wire    ddr_out_txctl_buffer_output;
wire    ddr_out_txctl_buffer_clock;

DDR_OUT ddr_out_txctl_buffer(
    .DF     (ddr_out_txctl_buffer_input),
    .DR     (ddr_out_txctl_buffer_input),
    .EN     (1),
    .CLK    (ddr_out_txctl_buffer_clock),
    .ALn    (1),
    .ADn    (1),
    .SLn    (1),
    .SD     (1),
    .Q      (ddr_out_txctl_buffer_output)
);


wire    ddr_out_tx_clock_buffer_out;
wire    ddr_out_tx_clock_buffer_clock;

DDR_OUT ddr_out_tx_clock_buffer(
    .DF     (0),
    .DR     (1),
    .EN     (1),
    .CLK    (ddr_out_tx_clock_buffer_clock),
    .ALn    (1),
    .ADn    (1),
    .SLn    (1),
    .SD     (1),
    .Q      (ddr_out_tx_clock_buffer_out)
);


/*
generate
    for (i=0;i<4;i=i+1) begin : generate_ddr_in
        DDR_IN ddr_in_rx_data(
            .D(phy_rx_data[i]),
            .CLK(rgmii_reference_clock),
            .EN (1),
            .ALn(1),
            .ADn(1),
            .SLn(1),
            .SD(1),
            .QF(rx_data[i+4]),
            .QR(rx_data[i])
        );
    end
endgenerate

        DDR_IN ddr_in_rxctl(
            .D(phy_rx_data_enable),
            .CLK(rgmii_reference_clock),
            .EN (1),
            .ALn(1),
            .ADn(1),
            .SLn(1),
            .SD(1),
            .QF(rx_error),
            .QR(rx_data_valid)
        );
    
*/

wire                                ethernet_packet_parser_clock;
wire                                ethernet_packet_parser_reset_n;
wire    [7:0]                       ethernet_packet_parser_data;
wire                                ethernet_packet_parser_data_enable;
wire    [7:0]                       ethernet_packet_parser_checksum_data;
wire                                ethernet_packet_parser_checksum_data_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_recieve_slot_enable;
wire                                ethernet_packet_parser_checksum_data_valid;
wire    [7:0]                       ethernet_packet_parser_packet_data;
wire                                ethernet_packet_parser_packet_data_valid;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_good_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_bad_packet;

ethernet_packet_parser ethernet_packet_parser(
    .clock                  (ethernet_packet_parser_clock),
    .reset_n                (ethernet_packet_parser_reset_n),
    .data                   (ethernet_packet_parser_data),
    .data_enable            (ethernet_packet_parser_data_enable),
    .checksum_data          (ethernet_packet_parser_checksum_data),
    .checksum_data_enable   (ethernet_packet_parser_checksum_data_enable),
    .recieve_slot_enable    (ethernet_packet_parser_recieve_slot_enable),

    .checksum_data_valid    (ethernet_packet_parser_checksum_data_valid),
    .packet_data            (ethernet_packet_parser_packet_data),
    .packet_data_valid      (ethernet_packet_parser_packet_data_valid),
    .good_packet            (ethernet_packet_parser_good_packet),
    .bad_packet             (ethernet_packet_parser_bad_packet)
);


wire            ethernet_packet_generator_clock;
wire            ethernet_packet_generator_reset_n;
wire            ethernet_packet_generator_enable;
wire    [7:0]   ethernet_packet_generator_payload_data;
wire            ethernet_packet_generator_payload_data_enable;
wire            ethernet_packet_generator_pll_lock;
wire    [7:0]   ethernet_packet_data_transmit_data;
wire            ethernet_packet_data_transmit_data_valid;

ethernet_packet_generator ethernet_packet_generator(
    .clock                  (ethernet_packet_generator_clock),
    .reset_n                (ethernet_packet_generator_reset_n),
    .enable                 (ethernet_packet_generator_enable),
    .payload_data           (ethernet_packet_generator_payload_data),
    .payload_data_enable    (ethernet_packet_generator_payload_data_enable),
    .pll_lock               (ethernet_packet_generator_pll_lock),

    .transmit_data          (ethernet_packet_data_transmit_data),
    .transmit_data_valid    (ethernet_packet_data_transmit_data_valid)
);


assign phy_tx_data                      = ddr_out_data_buffer_output;
assign phy_tx_data_valid                = ddr_out_txctl_buffer_output;
assign phy_tx_clock                     = ddr_out_tx_clock_buffer_out;

assign rgmii_reference_clock            = rgmii_rx_clock;

assign ddr_out_data_buffer_input        = ethernet_packet_data_transmit_data;

assign ddr_out_txctl_buffer_clock       = rgmii_rx_clock;
assign ddr_out_txctl_buffer_input       = ethernet_packet_data_transmit_data_valid;

assign ddr_out_tx_clock_buffer_clock    = pll_clock;

assign ethernet_packet_generator_clock  = clock;
assign ethernet_packet_parser_reset_n   = reset_n;

endmodule
