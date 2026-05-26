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
// or incorporation into proprietary software is strictly prohibited without prior
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
    parameter RECEIVE_QUE_SLOTS             = 2,
    parameter CAM_TABLE_DEPTH               = 32,
    parameter UDP_TRANSMIT_BUFFER_SIZE      = 4096,
    parameter TECHNOLOGY                    = "SIMULATION",
    parameter PHASE_SHIFT_TX_CLOCK_ENABLE   = 0
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
    output  wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_phy_transmit_data_vaid,
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

wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_transmit_data_ready;
wire    [NUMBER_OF_RMII_PORTS-1:0][8:0]     rmii_port_receive_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_receive_data_valid;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     rmii_port_rmii_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_rmii_transmit_data_valid;

generate
    for (i=0; i<NUMBER_OF_RMII_PORTS; i =i+1) begin
        rmii_port #(
            .RECEIVE_QUE_SLOTS  (RECEIVE_QUE_SLOTS),
            .TECHNOLOGY         (TECHNOLOGY)
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
            .receive_data_valid             (rmii_port_receive_data_valid[i]),
            .rmii_transmit_data             (rmii_port_rmii_transmit_data[i]),
            .rmii_transmit_data_valid       (rmii_port_rmii_transmit_data_valid[i])
        );
    end
endgenerate


wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_clock;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_reset_n;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][47:0]     virutal_port_udp_mac_source;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][31:0]     virutal_port_udp_ipv4_source;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]      virutal_port_udp_receive_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_receive_data_enable;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virtual_port_udp_transmit_data_enable;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_module_clock;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]      virutal_port_udp_module_transmit_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_module_transmit_data_enable;

wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_receive_data_ready;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]      virutal_port_udp_transmit_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_transmit_data_valid;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]      virutal_port_udp_module_receive_data;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_module_receive_data_valid;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]           virutal_port_udp_module_transmit_data_ready;

generate
    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i =i+1) begin
        virutal_port_udp #(
            .RECEIVE_QUE_SLOTS  (RECEIVE_QUE_SLOTS),
            .TECHNOLOGY         (TECHNOLOGY)
        )virutal_port_udp(
            .clock                              (virutal_port_udp_clock[i]),
            .reset_n                            (virutal_port_udp_reset_n[i]),
            .mac_source                         (virutal_port_udp_mac_source[i]),
            .ipv4_source                        (virutal_port_udp_ipv4_source[i]),
            .receive_data                       (virutal_port_udp_receive_data[i]),
            .receive_data_enable                (virutal_port_udp_receive_data_enable[i]),
            .transmit_data_enable               (virtual_port_udp_transmit_data_enable[i]),
            .module_clock                       (virutal_port_udp_module_clock[i]),
            .module_transmit_data               (virutal_port_udp_module_transmit_data[i]),
            .module_transmit_data_enable        (virutal_port_udp_module_transmit_data_enable[i]),

            .module_receive_data                (virutal_port_udp_module_receive_data),
            .module_receive_data_valid          (virutal_port_udp_module_receive_data_valid),
            .receive_data_ready                 (virutal_port_udp_receive_data_ready[i]),
            .transmit_data                      (virutal_port_udp_transmit_data[i]),
            .transmit_data_valid                (virutal_port_udp_transmit_data_valid[i]),
            .module_transmit_data_ready         (virutal_port_udp_module_transmit_data_ready[i])
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

wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_transmit_data_ready;
wire    [NUMBER_OF_RGMII_PORTS-1:0][8:0]    rgmii_port_receive_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_receive_data_valid;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_transmit_clock;
wire    [NUMBER_OF_RGMII_PORTS-1:0][3:0]    rgmii_port_phy_transmit_data;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_transmit_data_valid;
wire    [NUMBER_OF_RGMII_PORTS-1:0]         rgmii_port_phy_transmit_clock_raw;


generate
    for (i=0; i<NUMBER_OF_RGMII_PORTS; i =i+1) begin
        rgmii_port #(
            .RECEIVE_QUE_SLOTS              (RECEIVE_QUE_SLOTS),
            .TECHNOLOGY                     (TECHNOLOGY),
            .PHASE_SHIFT_TX_CLOCK_ENABLE    (PHASE_SHIFT_TX_CLOCK_ENABLE)
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
            .receive_data_valid                 (rgmii_port_receive_data_valid[i]),
            .phy_transmit_clock                 (rgmii_port_phy_transmit_clock[i]),
            .phy_transmit_data                  (rgmii_port_phy_transmit_data[i]),
            .phy_transmit_data_valid            (rgmii_port_phy_transmit_data_valid[i]),
            .phy_transmit_clock_raw             (rgmii_port_phy_transmit_clock_raw[i])
        );
    end
endgenerate


wire                                    core_data_orchestrator_clock;
wire                                    core_data_orchestraotr_reset_n;
wire    [NUMBER_OF_PORTS-1:0]           core_data_orchestrator_port_receive_data_enable;
wire    [NUMBER_OF_PORTS-1:0][8:0]      core_data_orchestrator_port_receive_data;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]   core_data_orchestrator_cam_table_match_index;
wire                                    core_data_orchestrator_cam_table_no_match;
wire                                    core_data_orchestrator_cam_table_match_enable;
wire    [NUMBER_OF_PORTS-1:0]           core_data_orchestrator_port_transmit_data_enable;

wire    [NUMBER_OF_PORTS-1:0]           core_data_orchestrator_port_receive_data_ready;
wire    [8:0]                           core_data_orchestrator_port_transmit_data;
wire    [NUMBER_OF_PORTS-1:0]           core_data_orchestrator_port_transmit_data_valid;
wire    [47:0]                          core_data_orchestrator_cam_table_key_write;
wire                                    core_data_orchestrator_cam_table_key_write_valid;
wire    [47:0]                          core_data_orchestrator_cam_table_key_delete;
wire                                    core_data_orchestrator_cam_table_key_delete_valid;
wire    [47:0]                          core_data_orchestrator_cam_table_key_match;
wire                                    core_data_orchestrator_cam_table_key_match_valid;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]   core_data_orchestrator_cam_table_index;

core_data_orchestrator
#(  .NUMBER_OF_PORTS    (NUMBER_OF_PORTS),
    .TABLE_DEPTH        (CAM_TABLE_DEPTH)
)
core_data_orchestrator(
    .clock                      (core_data_orchestrator_clock),
    .reset_n                    (core_data_orchestraotr_reset_n),
    .port_receive_data_enable   (core_data_orchestrator_port_receive_data_enable),
    .port_receive_data          (core_data_orchestrator_port_receive_data),
    .cam_table_match_index      (core_data_orchestrator_cam_table_match_index),
    .cam_table_no_match         (core_data_orchestrator_cam_table_no_match),
    .cam_table_match_enable     (core_data_orchestrator_cam_table_match_enable),
    .port_transmit_data_enable  (core_data_orchestrator_port_transmit_data_enable),

    .port_receive_data_ready    (core_data_orchestrator_port_receive_data_ready),
    .port_transmit_data         (core_data_orchestrator_port_transmit_data),
    .port_transmit_data_valid   (core_data_orchestrator_port_transmit_data_valid),
    .cam_table_index            (core_data_orchestrator_cam_table_index),
    .cam_table_key_write        (core_data_orchestrator_cam_table_key_write),
    .cam_table_key_write_valid  (core_data_orchestrator_cam_table_key_write_valid),
    .cam_table_key_delete       (core_data_orchestrator_cam_table_key_delete),
    .cam_table_key_delete_valid (core_data_orchestrator_cam_table_key_delete_valid),
    .cam_table_key_match        (core_data_orchestrator_cam_table_key_match),
    .cam_table_key_match_valid  (core_data_orchestrator_cam_table_key_match_valid)
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
        assign rmii_phy_transmit_data_vaid[i]                       = rmii_port_rmii_transmit_data_valid[i];
        assign rmii_port_receive_data_enable[i]                     = core_data_orchestrator_port_receive_data_ready[i];
        assign rmii_port_transmit_data_enable[i]                    = core_data_orchestrator_port_transmit_data_valid[i];
        assign rmii_port_transmit_data[i]                           = core_data_orchestrator_port_transmit_data;
        assign core_data_orchestrator_port_receive_data_enable[i]   = rmii_port_receive_data_valid[i];
        assign core_data_orchestrator_port_receive_data[i]          = rmii_port_receive_data[i];
        assign core_data_orchestrator_port_transmit_data_enable[i]  = rmii_port_transmit_data_ready[i];
    end
endgenerate

generate
    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i=i+1) begin
        assign  virutal_port_udp_clock[i]                                                   = clock;
        assign  virutal_port_udp_reset_n[i]                                                 = reset_n;
        assign  virutal_port_udp_receive_data[i]                                            = core_data_orchestrator_port_transmit_data;
        assign  virutal_port_udp_receive_data_enable[i]                                     = core_data_orchestrator_port_transmit_data_valid[i+NUMBER_OF_RMII_PORTS];
        assign  virtual_port_udp_transmit_data_enable[i]                                    = core_data_orchestrator_port_receive_data_ready[i+NUMBER_OF_RMII_PORTS];
        assign  virutal_port_udp_module_clock[i]                                            = module_clock[i];
        assign  virutal_port_udp_module_transmit_data[i]                                    = module_transmit_data[i];
        assign  virutal_port_udp_module_transmit_data_enable[i]                             = module_transmit_data_enable[i];
        assign  virutal_port_udp_mac_source[i]                                              = {40'hBE_AC_DC_EF_F0,i[7:0]};
        assign  virutal_port_udp_ipv4_source[i]                                             = {24'hF0_0F_B8,i[7:0]};

        assign  module_receive_data[i]                                                      = virutal_port_udp_module_receive_data[i];
        assign  module_receive_data_valid[i]                                                = virutal_port_udp_module_receive_data_valid[i];
        assign  core_data_orchestrator_port_receive_data_enable[i+NUMBER_OF_RMII_PORTS]     = virutal_port_udp_transmit_data_valid[i];
        assign  core_data_orchestrator_port_receive_data[i+NUMBER_OF_RMII_PORTS]            = virutal_port_udp_transmit_data[i];
        assign  core_data_orchestrator_port_transmit_data_enable[i+NUMBER_OF_RMII_PORTS]    = virutal_port_udp_receive_data_ready[i];
        assign  module_transmit_data_ready[i]                                               = virutal_port_udp_module_transmit_data_ready[i];
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
        assign  rgmii_port_receive_data_enable[i]                                                                   = core_data_orchestrator_port_receive_data_ready[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_clock[i]                                                                        = rgmii_transmit_clock[i];

        assign  rgmii_phy_transmit_data[i]                                                                          = rgmii_port_phy_transmit_data[i];
        assign  rgmii_phy_transmit_data_control[i]                                                                  = rgmii_port_phy_transmit_data_valid[i];
        assign  rgmii_phy_transmit_clock[i]                                                                         = rgmii_port_phy_transmit_clock[i];
        assign  rgmii_phy_transmit_clock_raw[i]                                                                     = rgmii_port_phy_transmit_clock_raw[i];

        assign  rgmii_port_transmit_data_enable[i]                                                                  = core_data_orchestrator_port_transmit_data_valid[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS];
        assign  rgmii_port_transmit_data[i]                                                                         = core_data_orchestrator_port_transmit_data;
        assign  core_data_orchestrator_port_receive_data_enable[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]     = rgmii_port_receive_data_valid[i];
        assign  core_data_orchestrator_port_receive_data[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]            = rgmii_port_receive_data[i];
        assign  core_data_orchestrator_port_transmit_data_enable[i+NUMBER_OF_RMII_PORTS+NUMBER_OF_VIRTUAL_PORTS]    = rgmii_port_transmit_data_ready[i];

    end
endgenerate

assign  core_data_orchestrator_clock                        = clock;
assign  core_data_orchestraotr_reset_n                      = reset_n;
assign  core_data_orchestrator_cam_table_match_index        = cam_table_match_index;
assign  core_data_orchestrator_cam_table_match_enable       = cam_table_match_valid;
assign  core_data_orchestrator_cam_table_no_match           = cam_table_no_match;

assign  cam_table_clock                                     = clock;
assign  cam_table_reset_n                                   = reset_n;
assign  cam_table_index                                     = core_data_orchestrator_cam_table_index;
assign  cam_table_key_match                                 = core_data_orchestrator_cam_table_key_match;
assign  cam_table_match_enable                              = core_data_orchestrator_cam_table_key_match_valid;
assign  cam_table_key_delete                                = core_data_orchestrator_cam_table_key_delete;
assign  cam_table_delete_enable                             = core_data_orchestrator_cam_table_key_delete_valid;
assign  cam_table_key_write                                 = core_data_orchestrator_cam_table_key_write;
assign  cam_table_write_enable                              = core_data_orchestrator_cam_table_key_write_valid;

endmodule