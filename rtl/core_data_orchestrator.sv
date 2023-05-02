//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/30/2023
// Design Name:
// Module Name: core_data_orchestrator
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
module core_data_orchestrator#(
    parameter NUMBER_OF_RMII_PORTS    = 2,
    parameter NUMBER_OF_VIRTUAL_PORTS = 0
)(
    input   wire                                        clock,
    input   wire                                        reset_n
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          port_recieve_data_enable,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0][8:0]     port_recieve_data,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          port_transmit_data_enable,

    output  reg     [NUMBER_OF_RMII_PORTS-1:0]          port_receive_data_ready,
    output  reg     [8:0]                               port_transmit_data,
    output  reg     [NUMBER_OF_RMII_PORTS-1:0]          port_transmit_data_valid
);

typedef enum
{
    S_IDLE,
    S_GET_MAC_DESTINATION,
    S_UPDATE_TABLE,
    S_LOOKUP_DESTINATION_PORT,
    S_TRANSMIT_T0_DESTINATION_PORT
} state_type;

endmodule