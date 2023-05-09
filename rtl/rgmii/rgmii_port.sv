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

wire            receive_clock;


wire    [3:0]   ddr_out_data_buffer_input_falling;
wire    [3:0]   ddr_out_data_buffer_input_rising;
wire    [3:0]   ddr_out_data_buffer_output;
wire            ddr_out_data_buffer_clock;

generate
    for (i=0;i<4;i=i+1) begin : generate_ddr_out
        DDR_OUT ddr_out_data_buffer(
            .DF     (ddr_out_data_buffer_input_falling),
            .DR     (ddr_out_data_buffer_input_rising),
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


wire    ddr_out_txctl_buffer_input_falling;
wire    ddr_out_txctl_buffer_input_rising;
wire    ddr_out_txctl_buffer_output;
wire    ddr_out_txctl_buffer_clock;

DDR_OUT ddr_out_txctl_buffer(
    .DF     (ddr_out_txctl_buffer_input_falling),
    .DR     (ddr_out_txctl_buffer_input_rising),
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


wire    [3:0]   ddr_in_receive_data_in;
wire            ddr_in_receive_data_clock;
wire    [3:0]   ddr_in_receive_data_out_rising;
wire    [3:0]   ddr_in_receive_data_out_falling;

generate
    for (i=0;i<4;i=i+1) begin : generate_ddr_in_receive_data
        DDR_IN ddr_in_receive_data(
            .D      (ddr_in_receive_data_in[i]),
            .CLK    (receive_clock),
            .EN     (1),
            .ALn    (1),
            .ADn    (1),
            .SLn    (1),
            .SD     (1),
            .QF     (ddr_in_receive_data_out_falling[i]),
            .QR     (ddr_in_receive_data_out_rising[i])
        );
    end
endgenerate


wire    ddr_in_rxctl_data_in;
wire    ddr_in_rxctl_clock;
wire    ddr_in_rxctl_data_out_falling;
wire    ddr_in_rxctl_data_out_rising;

DDR_IN ddr_in_rxctl(
    .D      (ddr_in_rxctl_data_in),
    .CLK    (ddr_in_rxctl_clock),
    .EN     (1),
    .ALn    (1),
    .ADn    (1),
    .SLn    (1),
    .SD     (1),
    .QF     (ddr_in_rxctl_data_out_falling),
    .QR     (ddr_in_rxctl_data_out_rising)
);


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
