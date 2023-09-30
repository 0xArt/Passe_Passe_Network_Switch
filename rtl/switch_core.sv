`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
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
//
//////////////////////////////////////////////////////////////////////////////////
module switch_core#(
    parameter NUMBER_OF_RMII_PORTS    = 2,
    parameter NUMBER_OF_VIRTUAL_PORTS = 0,
    parameter RECEIVE_QUE_SLOTS       = 2,
    parameter CAM_TABLE_DEPTH         = 32
)(
    input   wire                                        clock,
    input   wire                                        reset_n,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     rmii_phy_receive_data,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_phy_receive_data_enable,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_phy_receive_data_error,
    input   wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]       module_clock,
    input   wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]       module_transmit_data_enable,
    input   wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]  module_transmit_data,

    output  wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     rmii_phy_transmit_data,
    output  wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_phy_transmit_data_vaid,
    output  wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_phy_reference_clock
);

localparam NUMBER_OF_PORTS = NUMBER_OF_RMII_PORTS + NUMBER_OF_VIRTUAL_PORTS;

genvar i;


wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_clock;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_core_clock;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_reset_n;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     rmii_port_rmii_receive_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_rmii_receive_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_rmii_receive_data_error;
wire    [NUMBER_OF_RMII_PORTS-1:0][8:0]     rmii_port_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_transmit_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_receive_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0][8:0]     rmii_port_receive_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_receive_data_valid;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     rmii_port_rmii_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_rmii_transmit_data_valid;

generate
    for (i=0; i<NUMBER_OF_RMII_PORTS; i =i+1) begin
        rmii_port #(.RECEIVE_QUE_SLOTS(RECEIVE_QUE_SLOTS))
        rmii_port(
            .clock                          (rmii_port_clock[i]),
            .core_clock                     (rmii_port_core_clock[i]),
            .reset_n                        (rmii_port_reset_n[i]),
            .rmii_receive_data              (rmii_port_rmii_receive_data[i]),
            .rmii_receive_data_enable       (rmii_port_rmii_receive_data_enable[i]),
            .rmii_receive_data_error        (rmii_port_rmii_receive_data_error[i]),
            .transmit_data                  (rmii_port_transmit_data[i]),
            .transmit_data_enable           (rmii_port_transmit_data_enable[i]),
            .receive_data_enable            (rmii_port_receive_data_enable[i]),

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

generate
    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i =i+1) begin
        virutal_port_udp #(.RECEIVE_QUE_SLOTS(RECEIVE_QUE_SLOTS))
        virutal_port_udp(
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

            .receive_data_ready                 (virutal_port_udp_receive_data_ready[i]),
            .transmit_data                      (virutal_port_udp_transmit_data[i]),
            .transmit_data_valid                (virutal_port_udp_transmit_data_valid[i])
        );
    end
endgenerate


wire                                    core_data_orchestrator_clock;
wire                                    core_data_orchestraotr_reset_n;
wire    [NUMBER_OF_PORTS-1:0]           core_data_orchestrator_port_receive_data_enable;
wire    [NUMBER_OF_PORTS-1:0][8:0]      core_data_orchestrator_port_receive_data;
wire    [$clog2(CAM_TABLE_DEPTH)-1:0]   core_data_orchestrator_cam_table_match_index;
wire                                    core_data_orchestrator_cam_table_no_match;
wire                                    core_data_orchestrator_cam_table_match_enable;

wire    [NUMBER_OF_PORTS-1:0]           core_data_orchestrator_port_receive_data_ready;
wire    [8:0]                           core_data_orchestrator_port_transmit_data;
wire    [NUMBER_OF_PORTS-1:0]           core_data_orchestrator_port_transmit_data_valid;
wire                                    core_data_orchestrator_cam_table_match_valid;
wire    [47:0]                          core_data_orchestrator_cam_table_write_data;
wire                                    core_data_orchestrator_cam_table_write_data_valid;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]   core_data_orchestrator_cam_table_index;

core_data_orchestrator #(.NUMBER_OF_PORTS(NUMBER_OF_PORTS))
core_data_orchestrator(
    .clock                      (core_data_orchestrator_clock),
    .reset_n                    (core_data_orchestraotr_reset_n),
    .port_receive_data_enable   (core_data_orchestrator_port_receive_data_enable),
    .port_receive_data          (core_data_orchestrator_port_receive_data),
    .cam_table_match_index      (core_data_orchestrator_cam_table_match_index),
    .cam_table_no_match         (core_data_orchestrator_cam_table_no_match),
    .cam_table_match_enable     (core_data_orchestrator_cam_table_match_enable),

    .port_receive_data_ready    (core_data_orchestrator_port_receive_data_ready),
    .port_transmit_data         (core_data_orchestrator_port_transmit_data),
    .port_transmit_data_valid   (core_data_orchestrator_port_transmit_data_valid),
    .cam_table_match_valid      (core_data_orchestrator_cam_table_match_valid),
    .cam_table_write_data       (core_data_orchestrator_cam_table_write_data),
    .cam_table_write_data_valid (core_data_orchestrator_cam_table_write_data_valid),
    .cam_table_index            (core_data_orchestrator_cam_table_index)
);


wire                                    cam_table_clock;
wire                                    cam_table_reset_n;
wire                                    cam_table_write_enable;
wire    [47:0]                          cam_table_key;
wire    [$clog2(NUMBER_OF_PORTS)-1:0]   cam_table_index;
wire                                    cam_table_match_enable;

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
    .write_enable   (cam_table_write_enable),
    .key            (cam_table_key),
    .index          (cam_table_index),
    .match_enable   (cam_table_match_enable),

    .match_index    (cam_table_match_index),
    .match_valid    (cam_table_match_valid),
    .no_match       (cam_table_no_match)
);

generate
    for (i=0; i<NUMBER_OF_RMII_PORTS; i=i+1) begin
        assign  rmii_port_clock[i]                                  =   clock;
        assign  rmii_port_core_clock[i]                             =   clock;
        assign  rmii_port_reset_n[i]                                =   reset_n;
        assign  rmii_port_rmii_receive_data[i]                      =   rmii_phy_receive_data[i];
        assign  rmii_port_rmii_receive_data_enable[i]               =   rmii_phy_receive_data_enable[i];
        assign  rmii_port_rmii_receive_data_error[i]                =   rmii_phy_receive_data_error[i];
        assign  rmii_phy_transmit_data[i]                           =   rmii_port_rmii_transmit_data[i];
        assign  rmii_phy_transmit_data_vaid[i]                      =   rmii_port_rmii_transmit_data_valid[i];
        assign  rmii_port_receive_data_enable[i]                    =   core_data_orchestrator_port_receive_data_ready[i];
        assign  rmii_port_transmit_data_enable[i]                   =   core_data_orchestrator_port_transmit_data_valid[i];
        assign  rmii_port_transmit_data[i]                          =   core_data_orchestrator_port_transmit_data;
        assign  core_data_orchestrator_port_receive_data_enable[i]  =   rmii_port_receive_data_valid[i];
        assign  core_data_orchestrator_port_receive_data[i]         =   rmii_port_receive_data[i];
    end
endgenerate

generate
    for (i=0; i<NUMBER_OF_VIRTUAL_PORTS; i=i+1) begin
        assign  virutal_port_udp_clock[i]                                               =   clock;
        assign  virutal_port_udp_reset_n[i]                                             =   reset_n;
        assign  virutal_port_udp_receive_data[i]                                        =   core_data_orchestrator_port_transmit_data;
        assign  virutal_port_udp_receive_data_enable[i]                                 =   core_data_orchestrator_port_transmit_data_valid[i+NUMBER_OF_RMII_PORTS];
        assign  virtual_port_udp_transmit_data_enable[i]                                =   core_data_orchestrator_port_receive_data_ready[i+NUMBER_OF_RMII_PORTS];
        assign  virutal_port_udp_module_clock[i]                                        =   module_clock[i];
        assign  virutal_port_udp_module_transmit_data[i]                                =   module_transmit_data[i];
        assign  virutal_port_udp_module_transmit_data_enable[i]                         =   module_transmit_data_enable[i];
        assign  virutal_port_udp_mac_source[i]                                          =   {40'hBE_AC_DC_EF_F0,i[7:0]};
        assign  virutal_port_udp_ipv4_source[i]                                          =  {24'hF0_0F_B8,i[7:0]};

        assign  core_data_orchestrator_port_receive_data_enable[i+NUMBER_OF_RMII_PORTS] =   virutal_port_udp_transmit_data_valid[i];
        assign  core_data_orchestrator_port_receive_data[i+NUMBER_OF_RMII_PORTS]        =   virutal_port_udp_transmit_data[i];
    end
endgenerate

assign  core_data_orchestrator_clock                        =   clock;
assign  core_data_orchestraotr_reset_n                      =   reset_n;
assign  core_data_orchestrator_cam_table_match_index        =   cam_table_match_index;
assign  core_data_orchestrator_cam_table_match_enable       =   cam_table_match_valid;
assign  core_data_orchestrator_cam_table_no_match           =   cam_table_no_match;

assign  cam_table_clock                                     =   clock;
assign  cam_table_reset_n                                   =   reset_n;
assign  cam_table_match_enable                              =   core_data_orchestrator_cam_table_match_valid;
assign  cam_table_key                                       =   core_data_orchestrator_cam_table_write_data;
assign  cam_table_index                                     =   core_data_orchestrator_cam_table_index;
assign  cam_table_write_enable                              =   core_data_orchestrator_cam_table_write_data_valid;


endmodule