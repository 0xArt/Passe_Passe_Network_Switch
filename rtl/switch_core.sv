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
    parameter RECEIVE_QUEUE_SLOTS             = 2,
    parameter CAM_TABLE_DEPTH               = 32,
    parameter UDP_TRANSMIT_BUFFER_SIZE      = 4096,
    parameter TECHNOLOGY                    = "SIMULATION",
    parameter PHASE_SHIFT_TX_CLOCK_ENABLE   = 0,
    parameter FABRIC_DATA_BYTES             = 1
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

genvar i;


wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_clock;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_core_clock;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_reset_n;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_core_reset_n;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     rmii_port_rmii_receive_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_rmii_receive_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_rmii_receive_data_error;
wire    [NUMBER_OF_RMII_PORTS-1:0][8:0]     rmii_port_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_transmit_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_receive_data_enable;

wire    [NUMBER_OF_RMII_PORTS-1:0]                                      rmii_port_transmit_data_ready;
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
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
        )rmii_port(
            .clock                          (rmii_port_clock[i]),
            .core_clock                     (rmii_port_core_clock[i]),
            .reset_n                        (rmii_port_reset_n[i]),
            .core_reset_n                   (rmii_port_core_reset_n[i]),
            .rmii_receive_data              (rmii_port_rmii_receive_data[i]),
            .rmii_receive_data_enable       (rmii_port_rmii_receive_data_enable[i]),
            .rmii_receive_data_error        (rmii_port_rmii_receive_data_error[i]),
            .transmit_data                  (rmii_port_transmit_data[i]),
            .transmit_data_enable           (rmii_port_transmit_data_enable[i]),
            .receive_data_enable            (rmii_port_receive_data_enable[i]),

            .transmit_data_ready            (rmii_port_transmit_data_ready[i]),
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
            .transmit_data                      (virtual_port_udp_transmit_data[i]),
            .transmit_data_valid                (virtual_port_udp_transmit_data_valid[i]),
            .transmit_data_last                 (virtual_port_udp_transmit_data_last[i]),
            .module_transmit_data_ready         (virtual_port_udp_module_transmit_data_ready[i])
        );
    end
endgenerate


wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_core_clock;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_core_reset_n;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_receive_reset_n;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_transmit_reset_n; 
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_receive_clock;
wire    [NUMBER_OF_RGMII_PORTS-1:0][3:0]    rgmii_port_phy_receive_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_receive_data_control;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_receive_data_enable;
wire    [NUMBER_OF_RGMII_PORTS-1:0][8:0]    rgmii_port_transmit_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_transmit_data_enable;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_transmit_clock;

wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_transmit_data_ready;
wire    [NUMBER_OF_RGMII_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]          rgmii_port_receive_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_receive_data_first;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_receive_data_valid;
wire    [NUMBER_OF_RGMII_PORTS-1:0]                                     rgmii_port_receive_data_last;
wire    [NUMBER_OF_RGMII_PORTS-1:0][$clog2(FABRIC_DATA_BYTES+1)-1:0]    rgmii_port_receive_data_byte_count;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_transmit_clock;
wire    [NUMBER_OF_RGMII_PORTS-1:0][3:0]    rgmii_port_phy_transmit_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_transmit_data_valid;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_transmit_clock_raw;


generate
    for (i=0; i<NUMBER_OF_RGMII_PORTS; i =i+1) begin
        rgmii_port #(
            .RECEIVE_QUEUE_SLOTS              (RECEIVE_QUEUE_SLOTS),
            .TECHNOLOGY                     (TECHNOLOGY),
            .PHASE_SHIFT_TX_CLOCK_ENABLE    (PHASE_SHIFT_TX_CLOCK_ENABLE),
            .FABRIC_DATA_BYTES              (FABRIC_DATA_BYTES)
        )rgmii_port(
            .core_clock                         (rgmii_port_core_clock[i]),
            .core_reset_n                       (rgmii_port_core_reset_n[i]),
            .phy_receive_reset_n                (rgmii_port_phy_receive_reset_n[i]),
            .phy_transmit_reset_n               (rgmii_port_phy_transmit_reset_n[i]),
            .phy_receive_data                   (rgmii_port_phy_receive_data[i]),
            .phy_receive_data_control           (rgmii_port_phy_receive_data_control[i]),
            .phy_receive_clock                  (rgmii_port_phy_receive_clock[i]),
            .transmit_data                      (rgmii_port_transmit_data[i]),
            .transmit_data_enable               (rgmii_port_transmit_data_enable[i]),
            .receive_data_enable                (rgmii_port_receive_data_enable[i]),
            .transmit_clock                     (rgmii_port_transmit_clock[i]),

            .transmit_data_ready                (rgmii_port_transmit_data_ready[i]),
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


//output queued fabric. one header engine per
//ingress port, one scheduler per egress port, one shared cam behind the
//arbiter. width adapters bridge the byte serial ports onto
//FABRIC_DATA_BYTES wide fabric beats and elaborate to wires at one byte
localparam FABRIC_BYTE_COUNT_WIDTH = $clog2(FABRIC_DATA_BYTES+1);

//port byte streams out of the fabric (bit 8 of data = first). phy ports
//produce beats natively on ingress; only virtual ports enter through a
//width adapter
wire    [NUMBER_OF_PORTS-1:0]                       port_transmit_ready;
wire    [NUMBER_OF_PORTS-1:0][8:0]                  egress_byte_data;
wire    [NUMBER_OF_PORTS-1:0]                       egress_byte_valid;
wire    [NUMBER_OF_PORTS-1:0]                       egress_byte_last;

//beat side of the width adapters
wire    [NUMBER_OF_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]        fabric_beat_in_data;
wire    [NUMBER_OF_PORTS-1:0]                                   fabric_beat_in_first;
wire    [NUMBER_OF_PORTS-1:0]                                   fabric_beat_in_last;
wire    [NUMBER_OF_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]      fabric_beat_in_byte_count;
wire    [NUMBER_OF_PORTS-1:0]                                   fabric_beat_in_valid;
wire    [NUMBER_OF_PORTS-1:0]                                   fabric_beat_in_ready;
wire    [NUMBER_OF_PORTS-1:0]                                   egress_beat_ready;

wire    [NUMBER_OF_PORTS-1:0][NUMBER_OF_PORTS-1:0]              engine_port_request;    //[ingress][egress]
wire    [NUMBER_OF_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]        engine_out_data;
wire    [NUMBER_OF_PORTS-1:0]                                   engine_out_first;
wire    [NUMBER_OF_PORTS-1:0]                                   engine_out_last;
wire    [NUMBER_OF_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]      engine_out_byte_count;
wire    [NUMBER_OF_PORTS-1:0]                                   engine_out_valid;
wire    [NUMBER_OF_PORTS-1:0]                       engine_match_request;
wire    [NUMBER_OF_PORTS-1:0][47:0]                 engine_match_key;
wire    [NUMBER_OF_PORTS-1:0]                       engine_learn_request;
wire    [NUMBER_OF_PORTS-1:0][47:0]                 engine_learn_key;
wire    [NUMBER_OF_PORTS-1:0]                       engine_match_ack;
wire    [NUMBER_OF_PORTS-1:0]                       engine_match_response_valid;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]               engine_match_response_index;
wire                                                engine_match_response_no_match;
wire    [NUMBER_OF_PORTS-1:0]                       engine_learn_ack;

wire    [NUMBER_OF_PORTS-1:0][NUMBER_OF_PORTS-1:0]              scheduler_grant;        //[egress][ingress]
wire    [NUMBER_OF_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]        scheduler_transmit_data;
wire    [NUMBER_OF_PORTS-1:0]                                   scheduler_transmit_first;
wire    [NUMBER_OF_PORTS-1:0]                                   scheduler_transmit_last;
wire    [NUMBER_OF_PORTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]      scheduler_transmit_byte_count;
wire    [NUMBER_OF_PORTS-1:0]                                   scheduler_transmit_valid;

generate
    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin : fabric_width_adapters
        width_adapter_down #(
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
        ) width_adapter_down (
            .clock              (clock),
            .reset_n            (reset_n),
            .beat_data          (scheduler_transmit_data[i]),
            .beat_first         (scheduler_transmit_first[i]),
            .beat_last          (scheduler_transmit_last[i]),
            .beat_byte_count    (scheduler_transmit_byte_count[i]),
            .beat_valid         (scheduler_transmit_valid[i]),
            .byte_data_ready    (port_transmit_ready[i]),

            .beat_ready         (egress_beat_ready[i]),
            .byte_data          (egress_byte_data[i]),
            .byte_data_valid    (egress_byte_valid[i]),
            .byte_data_last     (egress_byte_last[i])
        );
    end

    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin : header_engines
        wire [NUMBER_OF_PORTS-1:0] engine_grant;
        for (genvar e=0; e<NUMBER_OF_PORTS; e=e+1) begin
            assign engine_grant[e] = scheduler_grant[e][i];
        end

        port_header_engine #(
            .NUMBER_OF_PORTS    (NUMBER_OF_PORTS),
            .PORT_INDEX         (i),
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
        ) port_header_engine (
            .clock                      (clock),
            .reset_n                    (reset_n),
            .in_data                    (fabric_beat_in_data[i]),
            .in_first                   (fabric_beat_in_first[i]),
            .in_last                    (fabric_beat_in_last[i]),
            .in_byte_count              (fabric_beat_in_byte_count[i]),
            .in_valid                   (fabric_beat_in_valid[i]),
            .match_ack                  (engine_match_ack[i]),
            .match_response_valid       (engine_match_response_valid[i]),
            .match_response_index       (engine_match_response_index),
            .match_response_no_match    (engine_match_response_no_match),
            .learn_ack                  (engine_learn_ack[i]),
            .port_grant                 (engine_grant),
            .egress_ready               (egress_beat_ready),

            .in_ready                   (fabric_beat_in_ready[i]),
            .match_request              (engine_match_request[i]),
            .match_key                  (engine_match_key[i]),
            .learn_request              (engine_learn_request[i]),
            .learn_key                  (engine_learn_key[i]),
            .port_request               (engine_port_request[i]),
            .out_data                   (engine_out_data[i]),
            .out_first                  (engine_out_first[i]),
            .out_last                   (engine_out_last[i]),
            .out_byte_count             (engine_out_byte_count[i]),
            .out_valid                  (engine_out_valid[i])
        );
    end

    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin : egress_schedulers
        wire [NUMBER_OF_PORTS-1:0] egress_request;
        for (genvar e=0; e<NUMBER_OF_PORTS; e=e+1) begin
            assign egress_request[e] = engine_port_request[e][i];
        end

        egress_scheduler #(
            .NUMBER_OF_PORTS    (NUMBER_OF_PORTS),
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
        ) egress_scheduler (
            .clock                  (clock),
            .reset_n                (reset_n),
            .request                (egress_request),
            .ingress_data           (engine_out_data),
            .ingress_first          (engine_out_first),
            .ingress_last           (engine_out_last),
            .ingress_byte_count     (engine_out_byte_count),
            .ingress_valid          (engine_out_valid),
            .transmit_ready         (egress_beat_ready[i]),

            .grant                  (scheduler_grant[i]),
            .transmit_data          (scheduler_transmit_data[i]),
            .transmit_first         (scheduler_transmit_first[i]),
            .transmit_last          (scheduler_transmit_last[i]),
            .transmit_byte_count    (scheduler_transmit_byte_count[i]),
            .transmit_valid         (scheduler_transmit_valid[i])
        );
    end
endgenerate

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

cam_access_arbiter #(
    .NUMBER_OF_PORTS    (NUMBER_OF_PORTS)
) cam_access_arbiter (
    .clock                      (clock),
    .reset_n                    (reset_n),
    .match_request              (engine_match_request),
    .match_key                  (engine_match_key),
    .learn_request              (engine_learn_request),
    .learn_key                  (engine_learn_key),
    .cam_match_valid            (cam_table_match_valid),
    .cam_match_index            (cam_table_match_index),
    .cam_no_match               (cam_table_no_match),

    .match_ack                  (engine_match_ack),
    .match_response_valid       (engine_match_response_valid),
    .match_response_index       (engine_match_response_index),
    .match_response_no_match    (engine_match_response_no_match),
    .learn_ack                  (engine_learn_ack),
    .cam_key_match              (cam_table_key_match),
    .cam_key_match_valid        (cam_table_match_enable),
    .cam_key_delete             (cam_table_key_delete),
    .cam_key_delete_valid       (cam_table_delete_enable),
    .cam_key_write              (cam_table_key_write),
    .cam_index                  (cam_table_index),
    .cam_key_write_valid        (cam_table_write_enable)
);


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
        assign rmii_phy_transmit_data_valid[i]                       = rmii_port_rmii_transmit_data_valid[i];
        assign rmii_port_receive_data_enable[i]                     = fabric_beat_in_ready[i];
        assign rmii_port_transmit_data_enable[i]                    = egress_byte_valid[i] && port_transmit_ready[i];
        assign rmii_port_transmit_data[i]                           = egress_byte_data[i];
        assign fabric_beat_in_valid[i]                              = rmii_port_receive_data_valid[i];
        assign fabric_beat_in_data[i]                               = rmii_port_receive_data[i];
        assign fabric_beat_in_first[i]                              = rmii_port_receive_data_first[i];
        assign fabric_beat_in_last[i]                               = rmii_port_receive_data_last[i];
        assign fabric_beat_in_byte_count[i]                         = rmii_port_receive_data_byte_count[i];
        assign port_transmit_ready[i]                               = rmii_port_transmit_data_ready[i];
    end
endgenerate

generate
    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i=i+1) begin : virtual_port_ingress_adapters
        //the virtual port stays byte serial, so it enters the fabric
        //through a width adapter (wires at one byte per beat)
        width_adapter_up #(
            .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
        ) width_adapter_up (
            .clock              (clock),
            .reset_n            (reset_n),
            .byte_data          (virtual_port_udp_transmit_data[i]),
            .byte_data_valid    (virtual_port_udp_transmit_data_valid[i]),
            .byte_data_last     (virtual_port_udp_transmit_data_last[i]),
            .beat_ready         (fabric_beat_in_ready[i+NUMBER_OF_RMII_PORTS]),

            .byte_data_ready    (virtual_port_udp_transmit_data_enable[i]),
            .beat_data          (fabric_beat_in_data[i+NUMBER_OF_RMII_PORTS]),
            .beat_first         (fabric_beat_in_first[i+NUMBER_OF_RMII_PORTS]),
            .beat_last          (fabric_beat_in_last[i+NUMBER_OF_RMII_PORTS]),
            .beat_byte_count    (fabric_beat_in_byte_count[i+NUMBER_OF_RMII_PORTS]),
            .beat_valid         (fabric_beat_in_valid[i+NUMBER_OF_RMII_PORTS])
        );
    end

    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i=i+1) begin
        assign  virtual_port_udp_clock[i]                                                   = clock;
        assign  virtual_port_udp_reset_n[i]                                                 = reset_n;
        assign  virtual_port_udp_receive_data[i]                                            = egress_byte_data[i+NUMBER_OF_RMII_PORTS];
        assign  virtual_port_udp_receive_data_enable[i]                                     = egress_byte_valid[i+NUMBER_OF_RMII_PORTS] && port_transmit_ready[i+NUMBER_OF_RMII_PORTS];
        assign  virtual_port_udp_module_clock[i]                                            = module_clock[i];
        assign  virtual_port_udp_module_transmit_data[i]                                    = module_transmit_data[i];
        assign  virtual_port_udp_module_transmit_data_enable[i]                             = module_transmit_data_enable[i];
        assign  virtual_port_udp_mac_source[i]                                              = {40'hBE_AC_DC_EF_F0,i[7:0]};
        assign  virtual_port_udp_ipv4_source[i]                                             = {24'hF0_0F_B8,i[7:0]};

        assign  module_receive_data[i]                                                      = virtual_port_udp_module_receive_data[i];
        assign  module_receive_data_valid[i]                                                = virtual_port_udp_module_receive_data_valid[i];
        assign  port_transmit_ready[i+NUMBER_OF_RMII_PORTS]                                 = virtual_port_udp_receive_data_ready[i];
        assign  module_transmit_data_ready[i]                                               = virtual_port_udp_module_transmit_data_ready[i];
    end
endgenerate

generate
    for (i=0; i<NUMBER_OF_RGMII_PORTS; i=i+1) begin
        assign  rgmii_port_core_clock[i]                                                                            = clock;
        assign  rgmii_port_core_reset_n[i]                                                                          = reset_n;
        assign  rgmii_port_phy_receive_reset_n[i]                                                                   = rgmii_phy_receive_clock_reset_n[i];
        assign  rgmii_port_phy_transmit_reset_n[i]                                                                  = rgmii_phy_transmit_clock_reset_n[i];
        assign  rgmii_port_phy_receive_data[i]                                                                      = rgmii_phy_receive_data[i];
        assign  rgmii_port_phy_receive_data_control[i]                                                              = rgmii_phy_receive_data_control[i];
        assign  rgmii_port_phy_receive_clock[i]                                                                     = rgmii_phy_receive_clock[i];
        assign  rgmii_port_receive_data_enable[i]                                                                   = fabric_beat_in_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_clock[i]                                                                        = rgmii_transmit_clock[i];

        assign  rgmii_phy_transmit_data[i]                                                                          = rgmii_port_phy_transmit_data[i];
        assign  rgmii_phy_transmit_data_control[i]                                                                  = rgmii_port_phy_transmit_data_valid[i];
        assign  rgmii_phy_transmit_clock[i]                                                                         = rgmii_port_phy_transmit_clock[i];
        assign  rgmii_phy_transmit_clock_raw[i]                                                                     = rgmii_port_phy_transmit_clock_raw[i];

        assign  rgmii_port_transmit_data_enable[i]                                                                  = egress_byte_valid[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS] && port_transmit_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_data[i]                                                                         = egress_byte_data[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  fabric_beat_in_valid[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]                                = rgmii_port_receive_data_valid[i];
        assign  fabric_beat_in_data[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]                                 = rgmii_port_receive_data[i];
        assign  fabric_beat_in_first[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]                                = rgmii_port_receive_data_first[i];
        assign  fabric_beat_in_last[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]                                 = rgmii_port_receive_data_last[i];
        assign  fabric_beat_in_byte_count[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]                           = rgmii_port_receive_data_byte_count[i];
        assign  port_transmit_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]                                 = rgmii_port_transmit_data_ready[i];

    end
endgenerate

assign  cam_table_clock                                     = clock;
assign  cam_table_reset_n                                   = reset_n;

endmodule