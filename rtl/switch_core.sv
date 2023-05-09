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
    parameter RECEIVE_QUE_SLOTS       = 2
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0][1:0] rmii_phy_receive_data,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]      rmii_phy_receive_data_enable,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]      rmii_phy_receive_data_error,

    output  wire    [NUMBER_OF_RMII_PORTS-1:0][1:0] rmii_phy_transmit_data,
    output  wire    [NUMBER_OF_RMII_PORTS-1:0]      rmii_phy_transmit_data_vaid,
    output  wire    [NUMBER_OF_RMII_PORTS-1:0]      rmii_phy_reference_clock
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

wire                                    core_data_orchestrator_clock;
wire                                    core_data_orchestraotr_reset_n;
wire    [NUMBER_OF_RMII_PORTS-1:0]      core_data_orchestrator_port_recieve_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0][8:0] core_data_orchestrator_port_recieve_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]      core_data_orchestrator_port_transmit_data_enable;
wire    [47:0]                          core_data_orchestrator_cam_table_read_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]      core_data_orchestrator_port_receive_data_ready;
wire    [8:0]                           core_data_orchestrator_port_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]      core_data_orchestrator_port_transmit_data_valid;
wire    [3:0]                           core_data_orchestrator_cam_table_read_address;
wire    [3:0]                           core_data_orchestrator_cam_table_write_address;
wire    [47:0]                          core_data_orchestrator_cam_table_write_data;
wire                                    core_data_orchestrator_cam_table_write_data_valid;

core_data_orchestrator  core_data_orchestrator(
    .clock                      (core_data_orchestrator_clock),
    .reset_n                    (core_data_orchestraotr_reset_n),
    .port_recieve_data_enable   (core_data_orchestrator_port_recieve_data_enable),
    .port_recieve_data          (core_data_orchestrator_port_recieve_data),
    .port_transmit_data_enable  (core_data_orchestrator_port_transmit_data_enable),
    .cam_table_read_data        (core_data_orchestrator_cam_table_read_data),

    .port_receive_data_ready    (core_data_orchestrator_port_receive_data_ready),
    .port_transmit_data         (core_data_orchestrator_port_transmit_data),
    .port_transmit_data_valid   (core_data_orchestrator_port_transmit_data_valid),
    .cam_table_read_address     (core_data_orchestrator_cam_table_read_address),
    .cam_table_write_address    (core_data_orchestrator_cam_table_write_address),
    .cam_table_write_data       (core_data_orchestrator_cam_table_write_data),
    .cam_table_write_data_valid (core_data_orchestrator_cam_table_write_data_valid)
);


wire            cam_table_clock;
wire    [3:0]   cam_table_read_address;
wire    [3:0]   cam_table_write_address;
wire    [47:0]  cam_table_write_data;
wire            cam_table_write_enable;
wire    [47:0]  cam_table_read_data;

RTG4TPSRAM_C0   cam_table(
    .CLK    (cam_table_clock),
    .RADDR  (cam_table_read_address),
    .WADDR  (cam_table_write_address),
    .WD     (cam_table_write_data),
    .WEN    (cam_table_write_enable),

    .RD     (cam_table_read_data)
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
        assign  core_data_orchestrator_port_recieve_data_enable[i]  =   rmii_port_receive_data_valid[i];
        assign  core_data_orchestrator_port_recieve_data[i]         =   rmii_port_receive_data[i];
    end
endgenerate

assign  core_data_orchestrator_clock                        =   clock;
assign  core_data_orchestraotr_reset_n                      =   reset_n;
assign  core_data_orchestrator_cam_table_read_data          =   cam_table_read_data;

assign  cam_table_clock                                     =   clock;
assign  cam_table_read_address                              =   core_data_orchestrator_cam_table_read_address;
assign  cam_table_write_address                             =   core_data_orchestrator_cam_table_write_address;
assign  cam_table_write_data                                =   core_data_orchestrator_cam_table_write_data;
assign  cam_table_write_enable                              =   core_data_orchestrator_cam_table_write_data_valid;


endmodule