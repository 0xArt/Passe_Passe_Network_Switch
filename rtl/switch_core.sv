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
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]      rmii_phy_receive_data_error
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
wire    [NUMBER_OF_RMII_PORTS-1:0]          rmii_port_transmit_data_ready;
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

            .transmit_data_ready            (rmii_port_transmit_data_ready[i]),
            .receive_data                   (rmii_port_receive_data[i]),
            .receive_data_valid             (rmii_port_receive_data_valid[i]),
            .rmii_transmit_data             (rmii_port_rmii_transmit_data[i]),
            .rmii_transmit_data_valid       (rmii_port_rmii_transmit_data_valid[i])
        );
    end
endgenerate

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i=i+1) begin
        assign  rmii_port_clock[i]                       =   clock;
        assign  rmii_port_core_clock[i]                  =   clock;
        assign  rmii_port_reset_n[i]                     =   reset_n;
        assign  rmii_port_rmii_receive_data[i]           =   rmii_phy_receive_data[i];
        assign  rmii_port_rmii_receive_data_enable[i]    =   rmii_phy_receive_data_enable[i];
        assign  rmii_port_rmii_receive_data_error[i]     =   rmii_phy_receive_data_error[i];
        assign  rmii_port_transmit_data[i]               =   0;
        assign  rmii_port_transmit_data_enable[i]        =   0;
        assign  rmii_port_receive_data_enable[i]         =   0;
    end
endgenerate

endmodule