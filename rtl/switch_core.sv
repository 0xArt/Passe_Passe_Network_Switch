`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 04/29/2023
// Design Name:
// Module Name: switch_core
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
///
// EDUCATIONAL USE ONLY
//
// This source file is provided solely for educational, research, and non-commercial purposes.
//
// Commercial use, redistribution, sublicensing, modification for commercial products,
// or incorporation into proprietary software or hardware is strictly prohibited without prior
// written permission and a valid commercial license from the original creator.
//
// Unauthorized commercial use violates intellectual property and copyright laws.
//
// For licensing inquiries and commercial permissions, contact the creator directly.
//
//////////////////////////////////////////////////////////////////////////////////
module switch_core#(
    parameter NUMBER_OF_RMII_PORTS          = 2,
    parameter NUMBER_OF_RGMII_PORTS         = 1,
    parameter NUMBER_OF_VIRTUAL_PORTS       = 0,
    parameter RECEIVE_QUEUE_SLOTS           = 2,
    parameter CAM_TABLE_DEPTH               = 32,
    parameter UDP_TRANSMIT_BUFFER_SIZE      = 4096,
    parameter TECHNOLOGY                    = "SIMULATION",
    parameter PHASE_SHIFT_TX_CLOCK_ENABLE   = 0,
    parameter FABRIC_DATA_BYTES             = 1,
    parameter CORE_CLOCK_FREQUENCY          = 250_000_000
)(
    input   wire                                        clock,
    input   wire                                        reset_n,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_clock,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_reset_n,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     rmii_phy_receive_data,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_phy_receive_data_enable,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_phy_receive_data_error,
    input   wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]       module_clock,
    input   wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]       module_transmit_data_enable,
    input   wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]  module_transmit_data,
    input   wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_phy_receive_clock_reset_n,
    input   wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_phy_transmit_clock_reset_n,
    input   wire    [NUMBER_OF_RGMII_PORTS-1:0][3:0]    rgmii_phy_receive_data,
    input   wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_phy_receive_data_control,
    input   wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_phy_receive_clock,
    input   wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_transmit_clock,

    output  wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     rmii_phy_transmit_data,
    output  wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_phy_transmit_data_valid,
    output  wire    [NUMBER_OF_RGMII_PORTS-1:0][3:0]    rgmii_phy_transmit_data,
    output  wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_phy_transmit_data_control,
    output  wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_phy_transmit_clock,
    output  wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_phy_transmit_clock_raw,
    output  wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]  module_receive_data,
    output  wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]       module_receive_data_valid,
    output  wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]       module_transmit_data_ready
);

localparam NUMBER_OF_PORTS = NUMBER_OF_RMII_PORTS + NUMBER_OF_VIRTUAL_PORTS + NUMBER_OF_RGMII_PORTS;

//timeouts are wall clock requirements, so derive the cycle counts from the
//core clock. stall recovery is 100 us (a stream that makes no progress is
//abandoned); admission retry is 2 ms (long enough to drain one reserved
//frame through a 10 megabit wire before giving up)
localparam STALL_TIMEOUT_CYCLES     = CORE_CLOCK_FREQUENCY / 10_000;
localparam ADMISSION_RETRY_CYCLES   = CORE_CLOCK_FREQUENCY / 500;

genvar i;


wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_clock;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_core_clock;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_reset_n;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_core_reset_n;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]                                 rmii_port_rmii_receive_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_rmii_receive_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_rmii_receive_data_error;
wire    [NUMBER_OF_RMII_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]           rmii_port_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_transmit_data_first;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_transmit_data_last;
wire    [NUMBER_OF_RMII_PORTS-1:0][$clog2(FABRIC_DATA_BYTES+1)-1:0]     rmii_port_transmit_data_byte_count;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_transmit_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_receive_data_enable;

wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_transmit_data_ready;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_transmit_frame_ready;
wire    [NUMBER_OF_RMII_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]           rmii_port_receive_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_receive_data_first;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_receive_data_valid;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_receive_data_last;
wire    [NUMBER_OF_RMII_PORTS-1:0][$clog2(FABRIC_DATA_BYTES+1)-1:0]     rmii_port_receive_data_byte_count;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]                                 rmii_port_rmii_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_rmii_transmit_data_valid;

generate
    for (i=0; i<NUMBER_OF_RMII_PORTS; i =i+1) begin
        rmii_port #(
            .RECEIVE_QUEUE_SLOTS  (RECEIVE_QUEUE_SLOTS),
            .TECHNOLOGY         (TECHNOLOGY),
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES),
            .TIMEOUT_LIMIT      (16'(STALL_TIMEOUT_CYCLES))
        )rmii_port(
            .clock                          (rmii_port_clock[i]),
            .core_clock                     (rmii_port_core_clock[i]),
            .reset_n                        (rmii_port_reset_n[i]),
            .core_reset_n                   (rmii_port_core_reset_n[i]),
            .rmii_receive_data              (rmii_port_rmii_receive_data[i]),
            .rmii_receive_data_enable       (rmii_port_rmii_receive_data_enable[i]),
            .rmii_receive_data_error        (rmii_port_rmii_receive_data_error[i]),
            .transmit_data                  (rmii_port_transmit_data[i]),
            .transmit_data_first            (rmii_port_transmit_data_first[i]),
            .transmit_data_last             (rmii_port_transmit_data_last[i]),
            .transmit_data_byte_count       (rmii_port_transmit_data_byte_count[i]),
            .transmit_data_enable           (rmii_port_transmit_data_enable[i]),
            .receive_data_enable            (rmii_port_receive_data_enable[i]),

            .transmit_data_ready            (rmii_port_transmit_data_ready[i]),
            .transmit_frame_ready           (rmii_port_transmit_frame_ready[i]),
            .receive_data                   (rmii_port_receive_data[i]),
            .receive_data_first             (rmii_port_receive_data_first[i]),
            .receive_data_valid             (rmii_port_receive_data_valid[i]),
            .receive_data_last              (rmii_port_receive_data_last[i]),
            .receive_data_byte_count        (rmii_port_receive_data_byte_count[i]),
            .rmii_transmit_data             (rmii_port_rmii_transmit_data[i]),
            .rmii_transmit_data_valid       (rmii_port_rmii_transmit_data_valid[i])
        );
    end
endgenerate


wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_clock;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_reset_n;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][47:0]     virtual_port_udp_mac_source;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][31:0]     virtual_port_udp_ipv4_source;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]      virtual_port_udp_receive_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_receive_data_enable;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_transmit_data_enable;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_module_clock;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]      virtual_port_udp_module_transmit_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_module_transmit_data_enable;

wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_receive_data_ready;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_receive_frame_ready;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]      virtual_port_udp_transmit_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_transmit_data_valid;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_transmit_data_last;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]      virtual_port_udp_module_receive_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_module_receive_data_valid;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_module_transmit_data_ready;

generate
    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i =i+1) begin
        virtual_port_udp #(
            .RECEIVE_QUEUE_SLOTS  (RECEIVE_QUEUE_SLOTS),
            .TECHNOLOGY         (TECHNOLOGY)
        )virtual_port_udp(
            .clock                              (virtual_port_udp_clock[i]),
            .reset_n                            (virtual_port_udp_reset_n[i]),
            .mac_source                         (virtual_port_udp_mac_source[i]),
            .ipv4_source                        (virtual_port_udp_ipv4_source[i]),
            .receive_data                       (virtual_port_udp_receive_data[i]),
            .receive_data_enable                (virtual_port_udp_receive_data_enable[i]),
            .transmit_data_enable               (virtual_port_udp_transmit_data_enable[i]),
            .module_clock                       (virtual_port_udp_module_clock[i]),
            .module_transmit_data               (virtual_port_udp_module_transmit_data[i]),
            .module_transmit_data_enable        (virtual_port_udp_module_transmit_data_enable[i]),

            .module_receive_data                (virtual_port_udp_module_receive_data[i]),
            .module_receive_data_valid          (virtual_port_udp_module_receive_data_valid[i]),
            .receive_data_ready                 (virtual_port_udp_receive_data_ready[i]),
            .receive_frame_ready                (virtual_port_udp_receive_frame_ready[i]),
            .transmit_data                      (virtual_port_udp_transmit_data[i]),
            .transmit_data_valid                (virtual_port_udp_transmit_data_valid[i]),
            .transmit_data_last                 (virtual_port_udp_transmit_data_last[i]),
            .module_transmit_data_ready         (virtual_port_udp_module_transmit_data_ready[i])
        );
    end
endgenerate


wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_core_clock;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_core_reset_n;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_phy_receive_reset_n;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_phy_transmit_reset_n; 
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_phy_receive_clock;
wire    [NUMBER_OF_RGMII_PORTS-1:0][3:0]                                rgmii_port_phy_receive_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_phy_receive_data_control;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_receive_data_enable;
wire    [NUMBER_OF_RGMII_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]          rgmii_port_transmit_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_transmit_data_first;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_transmit_data_last;
wire    [NUMBER_OF_RGMII_PORTS-1:0][$clog2(FABRIC_DATA_BYTES+1)-1:0]    rgmii_port_transmit_data_byte_count;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_transmit_data_enable;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_transmit_clock;

wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_transmit_data_ready;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_transmit_frame_ready;
wire    [NUMBER_OF_RGMII_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]          rgmii_port_receive_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_receive_data_first;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_receive_data_valid;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_receive_data_last;
wire    [NUMBER_OF_RGMII_PORTS-1:0][$clog2(FABRIC_DATA_BYTES+1)-1:0]    rgmii_port_receive_data_byte_count;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_phy_transmit_clock;
wire    [NUMBER_OF_RGMII_PORTS-1:0][3:0]                                rgmii_port_phy_transmit_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_phy_transmit_data_valid;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_phy_transmit_clock_raw;


generate
    for (i=0; i<NUMBER_OF_RGMII_PORTS; i =i+1) begin
        rgmii_port #(
            .RECEIVE_QUEUE_SLOTS              (RECEIVE_QUEUE_SLOTS),
            .TECHNOLOGY                     (TECHNOLOGY),
            .PHASE_SHIFT_TX_CLOCK_ENABLE    (PHASE_SHIFT_TX_CLOCK_ENABLE),
            .FABRIC_DATA_BYTES              (FABRIC_DATA_BYTES),
            .TIMEOUT_LIMIT                  (16'(STALL_TIMEOUT_CYCLES))
        )rgmii_port(
            .core_clock                         (rgmii_port_core_clock[i]),
            .core_reset_n                       (rgmii_port_core_reset_n[i]),
            .phy_receive_reset_n                (rgmii_port_phy_receive_reset_n[i]),
            .phy_transmit_reset_n               (rgmii_port_phy_transmit_reset_n[i]),
            .phy_receive_data                   (rgmii_port_phy_receive_data[i]),
            .phy_receive_data_control           (rgmii_port_phy_receive_data_control[i]),
            .phy_receive_clock                  (rgmii_port_phy_receive_clock[i]),
            .transmit_data                      (rgmii_port_transmit_data[i]),
            .transmit_data_first                (rgmii_port_transmit_data_first[i]),
            .transmit_data_last                 (rgmii_port_transmit_data_last[i]),
            .transmit_data_byte_count           (rgmii_port_transmit_data_byte_count[i]),
            .transmit_data_enable               (rgmii_port_transmit_data_enable[i]),
            .receive_data_enable                (rgmii_port_receive_data_enable[i]),
            .transmit_clock                     (rgmii_port_transmit_clock[i]),

            .transmit_data_ready                (rgmii_port_transmit_data_ready[i]),
            .transmit_frame_ready               (rgmii_port_transmit_frame_ready[i]),
            .receive_data                       (rgmii_port_receive_data[i]),
            .receive_data_first                 (rgmii_port_receive_data_first[i]),
            .receive_data_valid                 (rgmii_port_receive_data_valid[i]),
            .receive_data_last                  (rgmii_port_receive_data_last[i]),
            .receive_data_byte_count            (rgmii_port_receive_data_byte_count[i]),
            .phy_transmit_clock                 (rgmii_port_phy_transmit_clock[i]),
            .phy_transmit_data                  (rgmii_port_phy_transmit_data[i]),
            .phy_transmit_data_valid            (rgmii_port_phy_transmit_data_valid[i]),
            .phy_transmit_clock_raw             (rgmii_port_phy_transmit_clock_raw[i])
        );
    end
endgenerate


//output queued fabric. one header engine per ingress port, one scheduler
//per egress port, one shared cam behind the arbiter. width adapters bridge
//the byte serial virtual ports onto FABRIC_DATA_BYTES wide fabric beats
//and elaborate to wires at one byte
localparam FABRIC_BYTE_COUNT_WIDTH = $clog2(FABRIC_DATA_BYTES+1);

//per port readiness rails driven by the port type assign blocks below
wire    [NUMBER_OF_PORTS-1:0]                       port_transmit_ready;
wire    [NUMBER_OF_PORTS-1:0]                       port_transmit_frame_ready;
wire    [NUMBER_OF_PORTS-1:0]                       egress_beat_ready;


wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_clock;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_reset_n;
wire    [NUMBER_OF_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]                port_header_engine_in_data;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_in_first;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_in_last;
wire    [NUMBER_OF_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]              port_header_engine_in_byte_count;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_in_enable;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_match_ack;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_match_response_enable;
wire    [NUMBER_OF_PORTS-1:0][$clog2(NUMBER_OF_PORTS)-1:0]              port_header_engine_match_response_index;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_match_response_no_match;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_learn_ack;
wire    [NUMBER_OF_PORTS-1:0][NUMBER_OF_PORTS-1:0]                      port_header_engine_port_grant;      //[ingress][egress]
wire    [NUMBER_OF_PORTS-1:0][NUMBER_OF_PORTS-1:0]                      port_header_engine_egress_enable;

wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_in_ready;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_match_request;
wire    [NUMBER_OF_PORTS-1:0][47:0]                                     port_header_engine_match_key;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_learn_request;
wire    [NUMBER_OF_PORTS-1:0][47:0]                                     port_header_engine_learn_key;
wire    [NUMBER_OF_PORTS-1:0][NUMBER_OF_PORTS-1:0]                      port_header_engine_port_request;    //[ingress][egress]
wire    [NUMBER_OF_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]                port_header_engine_out_data;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_out_first;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_out_last;
wire    [NUMBER_OF_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]              port_header_engine_out_byte_count;
wire    [NUMBER_OF_PORTS-1:0]                                           port_header_engine_out_valid;

generate
    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin : header_engines
        port_header_engine #(
            .NUMBER_OF_PORTS    (NUMBER_OF_PORTS),
            .PORT_INDEX         (i),
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES),
            .TIMEOUT_LIMIT      (16'(STALL_TIMEOUT_CYCLES)),
            .RETRY_LIMIT        (24'(ADMISSION_RETRY_CYCLES))
        ) port_header_engine (
            .clock                      (port_header_engine_clock[i]),
            .reset_n                    (port_header_engine_reset_n[i]),
            .in_data                    (port_header_engine_in_data[i]),
            .in_first                   (port_header_engine_in_first[i]),
            .in_last                    (port_header_engine_in_last[i]),
            .in_byte_count              (port_header_engine_in_byte_count[i]),
            .in_enable                  (port_header_engine_in_enable[i]),
            .match_ack                  (port_header_engine_match_ack[i]),
            .match_response_enable      (port_header_engine_match_response_enable[i]),
            .match_response_index       (port_header_engine_match_response_index[i]),
            .match_response_no_match    (port_header_engine_match_response_no_match[i]),
            .learn_ack                  (port_header_engine_learn_ack[i]),
            .port_grant                 (port_header_engine_port_grant[i]),
            .egress_enable              (port_header_engine_egress_enable[i]),

            .in_ready                   (port_header_engine_in_ready[i]),
            .match_request              (port_header_engine_match_request[i]),
            .match_key                  (port_header_engine_match_key[i]),
            .learn_request              (port_header_engine_learn_request[i]),
            .learn_key                  (port_header_engine_learn_key[i]),
            .port_request               (port_header_engine_port_request[i]),
            .out_data                   (port_header_engine_out_data[i]),
            .out_first                  (port_header_engine_out_first[i]),
            .out_last                   (port_header_engine_out_last[i]),
            .out_byte_count             (port_header_engine_out_byte_count[i]),
            .out_valid                  (port_header_engine_out_valid[i])
        );
    end
endgenerate


wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_clock;
wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_reset_n;
wire    [NUMBER_OF_PORTS-1:0][NUMBER_OF_PORTS-1:0]                      egress_scheduler_request;           //[egress][ingress]
wire    [NUMBER_OF_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]                egress_scheduler_ingress_data;
wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_ingress_first;
wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_ingress_last;
wire    [NUMBER_OF_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]              egress_scheduler_ingress_byte_count;
wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_ingress_enable;
wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_transmit_ready;

wire    [NUMBER_OF_PORTS-1:0][NUMBER_OF_PORTS-1:0]                      egress_scheduler_grant;             //[egress][ingress]
wire    [NUMBER_OF_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]                egress_scheduler_transmit_data;
wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_transmit_first;
wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_transmit_last;
wire    [NUMBER_OF_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]              egress_scheduler_transmit_byte_count;
wire    [NUMBER_OF_PORTS-1:0]                                           egress_scheduler_transmit_valid;

generate
    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin : egress_schedulers
        egress_scheduler #(
            .NUMBER_OF_PORTS    (NUMBER_OF_PORTS),
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
        ) egress_scheduler (
            .clock                  (egress_scheduler_clock[i]),
            .reset_n                (egress_scheduler_reset_n[i]),
            .request                (egress_scheduler_request[i]),
            .ingress_data           (egress_scheduler_ingress_data),
            .ingress_first          (egress_scheduler_ingress_first),
            .ingress_last           (egress_scheduler_ingress_last),
            .ingress_byte_count     (egress_scheduler_ingress_byte_count),
            .ingress_enable         (egress_scheduler_ingress_enable),
            .transmit_ready         (egress_scheduler_transmit_ready[i]),

            .grant                  (egress_scheduler_grant[i]),
            .transmit_data          (egress_scheduler_transmit_data[i]),
            .transmit_first         (egress_scheduler_transmit_first[i]),
            .transmit_last          (egress_scheduler_transmit_last[i]),
            .transmit_byte_count    (egress_scheduler_transmit_byte_count[i]),
            .transmit_valid         (egress_scheduler_transmit_valid[i])
        );
    end
endgenerate


wire                                    cam_access_arbiter_clock;
wire                                    cam_access_arbiter_reset_n;
wire    [NUMBER_OF_PORTS-1:0]           cam_access_arbiter_match_request;
wire    [NUMBER_OF_PORTS-1:0][47:0]     cam_access_arbiter_match_key;
wire    [NUMBER_OF_PORTS-1:0]           cam_access_arbiter_learn_request;
wire    [NUMBER_OF_PORTS-1:0][47:0]     cam_access_arbiter_learn_key;
wire                                    cam_access_arbiter_cam_match_enable;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]   cam_access_arbiter_cam_match_index;
wire                                    cam_access_arbiter_cam_no_match;

wire    [NUMBER_OF_PORTS-1:0]           cam_access_arbiter_match_ack;
wire    [NUMBER_OF_PORTS-1:0]           cam_access_arbiter_match_response_valid;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]   cam_access_arbiter_match_response_index;
wire                                    cam_access_arbiter_match_response_no_match;
wire    [NUMBER_OF_PORTS-1:0]           cam_access_arbiter_learn_ack;
wire    [47:0]                          cam_access_arbiter_cam_key_match;
wire                                    cam_access_arbiter_cam_key_match_valid;
wire    [47:0]                          cam_access_arbiter_cam_key_delete;
wire                                    cam_access_arbiter_cam_key_delete_valid;
wire    [47:0]                          cam_access_arbiter_cam_key_write;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]   cam_access_arbiter_cam_index;
wire                                    cam_access_arbiter_cam_key_write_valid;

cam_access_arbiter #(
    .NUMBER_OF_PORTS    (NUMBER_OF_PORTS)
) cam_access_arbiter (
    .clock                      (cam_access_arbiter_clock),
    .reset_n                    (cam_access_arbiter_reset_n),
    .match_request              (cam_access_arbiter_match_request),
    .match_key                  (cam_access_arbiter_match_key),
    .learn_request              (cam_access_arbiter_learn_request),
    .learn_key                  (cam_access_arbiter_learn_key),
    .cam_match_enable           (cam_access_arbiter_cam_match_enable),
    .cam_match_index            (cam_access_arbiter_cam_match_index),
    .cam_no_match               (cam_access_arbiter_cam_no_match),

    .match_ack                  (cam_access_arbiter_match_ack),
    .match_response_valid       (cam_access_arbiter_match_response_valid),
    .match_response_index       (cam_access_arbiter_match_response_index),
    .match_response_no_match    (cam_access_arbiter_match_response_no_match),
    .learn_ack                  (cam_access_arbiter_learn_ack),
    .cam_key_match              (cam_access_arbiter_cam_key_match),
    .cam_key_match_valid        (cam_access_arbiter_cam_key_match_valid),
    .cam_key_delete             (cam_access_arbiter_cam_key_delete),
    .cam_key_delete_valid       (cam_access_arbiter_cam_key_delete_valid),
    .cam_key_write              (cam_access_arbiter_cam_key_write),
    .cam_index                  (cam_access_arbiter_cam_index),
    .cam_key_write_valid        (cam_access_arbiter_cam_key_write_valid)
);


wire                                    cam_table_clock;
wire                                    cam_table_reset_n;
wire    [47:0]                          cam_table_key_match;
wire    [47:0]                          cam_table_key_delete;
wire    [47:0]                          cam_table_key_write;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]   cam_table_index;
wire                                    cam_table_match_enable;
wire                                    cam_table_delete_enable;
wire                                    cam_table_write_enable;

wire    [$clog2(NUMBER_OF_PORTS)-1:0]   cam_table_match_index;
wire                                    cam_table_match_valid;
wire                                    cam_table_no_match;

cam_table
#(.KEY_WIDTH    (48),
  .TABLE_DEPTH  (CAM_TABLE_DEPTH),
  .INDEX_DEPTH  (NUMBER_OF_PORTS)
)
cam_table(
    .clock          (cam_table_clock),
    .reset_n        (cam_table_reset_n),
    .key_match      (cam_table_key_match),
    .key_delete     (cam_table_key_delete),
    .key_write      (cam_table_key_write),
    .index          (cam_table_index),
    .match_enable   (cam_table_match_enable),
    .delete_enable  (cam_table_delete_enable),
    .write_enable   (cam_table_write_enable),
    .match_index    (cam_table_match_index),

    .match_valid    (cam_table_match_valid),
    .no_match       (cam_table_no_match)
);


wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_clock;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_reset_n;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]                              width_adapter_up_byte_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_byte_data_enable;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_byte_data_last;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_beat_ready;

wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_byte_data_ready;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]        width_adapter_up_beat_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_beat_first;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_beat_last;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]      width_adapter_up_beat_byte_count;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_up_beat_valid;

wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_clock;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_reset_n;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]        width_adapter_down_beat_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_beat_first;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_beat_last;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]      width_adapter_down_beat_byte_count;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_beat_enable;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_byte_data_ready;

wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_beat_ready;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]                              width_adapter_down_byte_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_byte_data_valid;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]                                   width_adapter_down_byte_data_last;

generate
    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i=i+1) begin : virtual_port_width_adapters
        //the virtual port stays byte serial, so it crosses into and out of
        //the fabric through width adapters (wires at one byte per beat)
        width_adapter_up #(
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
        ) width_adapter_up (
            .clock              (width_adapter_up_clock[i]),
            .reset_n            (width_adapter_up_reset_n[i]),
            .byte_data          (width_adapter_up_byte_data[i]),
            .byte_data_enable   (width_adapter_up_byte_data_enable[i]),
            .byte_data_last     (width_adapter_up_byte_data_last[i]),
            .beat_ready         (width_adapter_up_beat_ready[i]),

            .byte_data_ready    (width_adapter_up_byte_data_ready[i]),
            .beat_data          (width_adapter_up_beat_data[i]),
            .beat_first         (width_adapter_up_beat_first[i]),
            .beat_last          (width_adapter_up_beat_last[i]),
            .beat_byte_count    (width_adapter_up_beat_byte_count[i]),
            .beat_valid         (width_adapter_up_beat_valid[i])
        );

        width_adapter_down #(
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
        ) width_adapter_down (
            .clock              (width_adapter_down_clock[i]),
            .reset_n            (width_adapter_down_reset_n[i]),
            .beat_data          (width_adapter_down_beat_data[i]),
            .beat_first         (width_adapter_down_beat_first[i]),
            .beat_last          (width_adapter_down_beat_last[i]),
            .beat_byte_count    (width_adapter_down_beat_byte_count[i]),
            .beat_enable        (width_adapter_down_beat_enable[i]),
            .byte_data_ready    (width_adapter_down_byte_data_ready[i]),

            .beat_ready         (width_adapter_down_beat_ready[i]),
            .byte_data          (width_adapter_down_byte_data[i]),
            .byte_data_valid    (width_adapter_down_byte_data_valid[i]),
            .byte_data_last     (width_adapter_down_byte_data_last[i])
        );
    end
endgenerate


generate
    for (i=0; i<NUMBER_OF_RMII_PORTS; i=i+1) begin
        assign rmii_port_clock[i]                                   = rmii_clock[i];
        assign rmii_port_core_clock[i]                              = clock;
        assign rmii_port_reset_n[i]                                 = rmii_reset_n[i];
        assign rmii_port_core_reset_n[i]                            = reset_n;
        assign rmii_port_rmii_receive_data[i]                       = rmii_phy_receive_data[i];
        assign rmii_port_rmii_receive_data_enable[i]                = rmii_phy_receive_data_enable[i];
        assign rmii_port_rmii_receive_data_error[i]                 = rmii_phy_receive_data_error[i];
        assign rmii_phy_transmit_data[i]                            = rmii_port_rmii_transmit_data[i];
        assign rmii_phy_transmit_data_valid[i]                      = rmii_port_rmii_transmit_data_valid[i];
        assign rmii_port_receive_data_enable[i]                     = port_header_engine_in_ready[i];
        assign rmii_port_transmit_data_enable[i]                    = egress_scheduler_transmit_valid[i];
        assign rmii_port_transmit_data[i]                           = egress_scheduler_transmit_data[i];
        assign rmii_port_transmit_data_first[i]                     = egress_scheduler_transmit_first[i];
        assign rmii_port_transmit_data_last[i]                      = egress_scheduler_transmit_last[i];
        assign rmii_port_transmit_data_byte_count[i]                = egress_scheduler_transmit_byte_count[i];
        assign egress_beat_ready[i]                                 = port_transmit_ready[i];
        assign port_header_engine_in_enable[i]                      = rmii_port_receive_data_valid[i];
        assign port_header_engine_in_data[i]                        = rmii_port_receive_data[i];
        assign port_header_engine_in_first[i]                       = rmii_port_receive_data_first[i];
        assign port_header_engine_in_last[i]                        = rmii_port_receive_data_last[i];
        assign port_header_engine_in_byte_count[i]                  = rmii_port_receive_data_byte_count[i];
        assign port_transmit_ready[i]                               = rmii_port_transmit_data_ready[i];
        assign port_transmit_frame_ready[i]                         = rmii_port_transmit_frame_ready[i];
    end
endgenerate

generate
    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i=i+1) begin
        assign  virtual_port_udp_clock[i]                                   = clock;
        assign  virtual_port_udp_reset_n[i]                                 = reset_n;
        assign  virtual_port_udp_receive_data[i]                            = width_adapter_down_byte_data[i];
        assign  virtual_port_udp_receive_data_enable[i]                     = width_adapter_down_byte_data_valid[i] && port_transmit_ready[i+NUMBER_OF_RMII_PORTS];
        assign  virtual_port_udp_transmit_data_enable[i]                    = width_adapter_up_byte_data_ready[i];
        assign  virtual_port_udp_module_clock[i]                            = module_clock[i];
        assign  virtual_port_udp_module_transmit_data[i]                    = module_transmit_data[i];
        assign  virtual_port_udp_module_transmit_data_enable[i]             = module_transmit_data_enable[i];
        assign  virtual_port_udp_mac_source[i]                              = {40'hBE_AC_DC_EF_F0,i[7:0]};
        assign  virtual_port_udp_ipv4_source[i]                             = {24'hF0_0F_B8,i[7:0]};

        assign  module_receive_data[i]                                      = virtual_port_udp_module_receive_data[i];
        assign  module_receive_data_valid[i]                                = virtual_port_udp_module_receive_data_valid[i];
        assign  port_transmit_ready[i+NUMBER_OF_RMII_PORTS]                 = virtual_port_udp_receive_data_ready[i];
        assign  port_transmit_frame_ready[i+NUMBER_OF_RMII_PORTS]           = virtual_port_udp_receive_frame_ready[i];
        assign  module_transmit_data_ready[i]                               = virtual_port_udp_module_transmit_data_ready[i];

        assign  width_adapter_up_clock[i]                                   = clock;
        assign  width_adapter_up_reset_n[i]                                 = reset_n;
        assign  width_adapter_up_byte_data[i]                               = virtual_port_udp_transmit_data[i];
        assign  width_adapter_up_byte_data_enable[i]                        = virtual_port_udp_transmit_data_valid[i];
        assign  width_adapter_up_byte_data_last[i]                          = virtual_port_udp_transmit_data_last[i];
        assign  width_adapter_up_beat_ready[i]                              = port_header_engine_in_ready[i+NUMBER_OF_RMII_PORTS];
        assign  port_header_engine_in_data[i+NUMBER_OF_RMII_PORTS]          = width_adapter_up_beat_data[i];
        assign  port_header_engine_in_first[i+NUMBER_OF_RMII_PORTS]         = width_adapter_up_beat_first[i];
        assign  port_header_engine_in_last[i+NUMBER_OF_RMII_PORTS]          = width_adapter_up_beat_last[i];
        assign  port_header_engine_in_byte_count[i+NUMBER_OF_RMII_PORTS]    = width_adapter_up_beat_byte_count[i];
        assign  port_header_engine_in_enable[i+NUMBER_OF_RMII_PORTS]        = width_adapter_up_beat_valid[i];

        assign  width_adapter_down_clock[i]                                 = clock;
        assign  width_adapter_down_reset_n[i]                               = reset_n;
        assign  width_adapter_down_beat_data[i]                             = egress_scheduler_transmit_data[i+NUMBER_OF_RMII_PORTS];
        assign  width_adapter_down_beat_first[i]                            = egress_scheduler_transmit_first[i+NUMBER_OF_RMII_PORTS];
        assign  width_adapter_down_beat_last[i]                             = egress_scheduler_transmit_last[i+NUMBER_OF_RMII_PORTS];
        assign  width_adapter_down_beat_byte_count[i]                       = egress_scheduler_transmit_byte_count[i+NUMBER_OF_RMII_PORTS];
        assign  width_adapter_down_beat_enable[i]                           = egress_scheduler_transmit_valid[i+NUMBER_OF_RMII_PORTS];
        assign  width_adapter_down_byte_data_ready[i]                       = port_transmit_ready[i+NUMBER_OF_RMII_PORTS];
        assign  egress_beat_ready[i+NUMBER_OF_RMII_PORTS]                   = width_adapter_down_beat_ready[i];
    end
endgenerate

generate
    for (i=0; i<NUMBER_OF_RGMII_PORTS; i=i+1) begin
        assign  rgmii_port_core_clock[i]                                                            = clock;
        assign  rgmii_port_core_reset_n[i]                                                          = reset_n;
        assign  rgmii_port_phy_receive_reset_n[i]                                                   = rgmii_phy_receive_clock_reset_n[i];
        assign  rgmii_port_phy_transmit_reset_n[i]                                                  = rgmii_phy_transmit_clock_reset_n[i];
        assign  rgmii_port_phy_receive_data[i]                                                      = rgmii_phy_receive_data[i];
        assign  rgmii_port_phy_receive_data_control[i]                                              = rgmii_phy_receive_data_control[i];
        assign  rgmii_port_phy_receive_clock[i]                                                     = rgmii_phy_receive_clock[i];
        assign  rgmii_port_receive_data_enable[i]                                                   = port_header_engine_in_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_clock[i]                                                        = rgmii_transmit_clock[i];

        assign  rgmii_phy_transmit_data[i]                                                          = rgmii_port_phy_transmit_data[i];
        assign  rgmii_phy_transmit_data_control[i]                                                  = rgmii_port_phy_transmit_data_valid[i];
        assign  rgmii_phy_transmit_clock[i]                                                         = rgmii_port_phy_transmit_clock[i];
        assign  rgmii_phy_transmit_clock_raw[i]                                                     = rgmii_port_phy_transmit_clock_raw[i];

        assign  rgmii_port_transmit_data_enable[i]                                                  = egress_scheduler_transmit_valid[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_data[i]                                                         = egress_scheduler_transmit_data[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_data_first[i]                                                   = egress_scheduler_transmit_first[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_data_last[i]                                                    = egress_scheduler_transmit_last[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_data_byte_count[i]                                              = egress_scheduler_transmit_byte_count[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  egress_beat_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]                   = port_transmit_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  port_header_engine_in_enable[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]        = rgmii_port_receive_data_valid[i];
        assign  port_header_engine_in_data[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]          = rgmii_port_receive_data[i];
        assign  port_header_engine_in_first[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]         = rgmii_port_receive_data_first[i];
        assign  port_header_engine_in_last[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]          = rgmii_port_receive_data_last[i];
        assign  port_header_engine_in_byte_count[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]    = rgmii_port_receive_data_byte_count[i];
        assign  port_transmit_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]                 = rgmii_port_transmit_data_ready[i];
        assign  port_transmit_frame_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]           = rgmii_port_transmit_frame_ready[i];
    end
endgenerate

generate
    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin : fabric_interconnect
        assign  port_header_engine_clock[i]                         = clock;
        assign  port_header_engine_reset_n[i]                       = reset_n;
        assign  port_header_engine_match_ack[i]                     = cam_access_arbiter_match_ack[i];
        assign  port_header_engine_match_response_enable[i]         = cam_access_arbiter_match_response_valid[i];
        assign  port_header_engine_match_response_index[i]          = cam_access_arbiter_match_response_index;
        assign  port_header_engine_match_response_no_match[i]       = cam_access_arbiter_match_response_no_match;
        assign  port_header_engine_learn_ack[i]                     = cam_access_arbiter_learn_ack[i];
        assign  port_header_engine_egress_enable[i]                 = egress_beat_ready;

        assign  egress_scheduler_clock[i]                           = clock;
        assign  egress_scheduler_reset_n[i]                         = reset_n;
        assign  egress_scheduler_transmit_ready[i]                  = port_transmit_frame_ready[i] && egress_beat_ready[i];

        for (genvar e=0; e<NUMBER_OF_PORTS; e=e+1) begin
            assign  port_header_engine_port_grant[i][e]             = egress_scheduler_grant[e][i];
            assign  egress_scheduler_request[i][e]                  = port_header_engine_port_request[e][i];
        end
    end
endgenerate

assign  egress_scheduler_ingress_data                       = port_header_engine_out_data;
assign  egress_scheduler_ingress_first                      = port_header_engine_out_first;
assign  egress_scheduler_ingress_last                       = port_header_engine_out_last;
assign  egress_scheduler_ingress_byte_count                 = port_header_engine_out_byte_count;
assign  egress_scheduler_ingress_enable                     = port_header_engine_out_valid;

assign  cam_access_arbiter_clock                            = clock;
assign  cam_access_arbiter_reset_n                          = reset_n;
assign  cam_access_arbiter_match_request                    = port_header_engine_match_request;
assign  cam_access_arbiter_match_key                        = port_header_engine_match_key;
assign  cam_access_arbiter_learn_request                    = port_header_engine_learn_request;
assign  cam_access_arbiter_learn_key                        = port_header_engine_learn_key;
assign  cam_access_arbiter_cam_match_enable                 = cam_table_match_valid;
assign  cam_access_arbiter_cam_match_index                  = cam_table_match_index;
assign  cam_access_arbiter_cam_no_match                     = cam_table_no_match;

assign  cam_table_clock                                     = clock;
assign  cam_table_reset_n                                   = reset_n;
assign  cam_table_key_match                                 = cam_access_arbiter_cam_key_match;
assign  cam_table_match_enable                              = cam_access_arbiter_cam_key_match_valid;
assign  cam_table_key_delete                                = cam_access_arbiter_cam_key_delete;
assign  cam_table_delete_enable                             = cam_access_arbiter_cam_key_delete_valid;
assign  cam_table_key_write                                 = cam_access_arbiter_cam_key_write;
assign  cam_table_index                                     = cam_access_arbiter_cam_index;
assign  cam_table_write_enable                              = cam_access_arbiter_cam_key_write_valid;

endmodule
