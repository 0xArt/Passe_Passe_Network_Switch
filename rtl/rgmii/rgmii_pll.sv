`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
// 
// Create Date: 07/06/2024
// Design Name: 
// Module Name: rgmii_pll
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: SIMULATION ONLY
// 
//////////////////////////////////////////////////////////////////////////////////
module rgmii_pll #(
    parameter XILINX    = 0
)(
    input   wire                            clock,
    input   wire                            enable,
    
    output  logic                           phase_shifted_clock
);

logic _phase_shifted_clock;

always begin
    @(posedge clock);
    #2ns;
    _phase_shifted_clock   =   0;
    @(negedge clock);
    #2ns
    _phase_shifted_clock   =   1;
end

always_comb begin
    phase_shifted_clock = 0;

    if (enable) begin
        phase_shifted_clock = _phase_shifted_clock;
    end
end


endmodule