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
    parameter RMII_PORTS    = 1,
    parameter VIRTUAL_PORTS = 0
)(
    input   wire            clock,
    input   wire            reset_n
);

localparam NUMBER_OF_PORTS = RMII_PORTS + VIRTUAL_PORTS;



endmodule