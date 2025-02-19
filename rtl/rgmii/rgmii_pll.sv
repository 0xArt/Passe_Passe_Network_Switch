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
// Additional Comments: NON XILINX IS SIMULATION ONLY
//                      PLL produces a 90 degree phase shifted version of the input clock
//                      Purspoed for gigabit transmit setup time requirements
//                      If your PHY has programmable delays, you can nix this altogether and use that instead
//////////////////////////////////////////////////////////////////////////////////
module rgmii_pll #(
    parameter XILINX    = 0
)(
    input   wire                            clock,
    input   wire                            reset_n,
    
    output  logic                           phase_shifted_clock,
    output  wire                            phase_shifted_clock_lock
);


generate
    if (XILINX) begin
        wire    rgmii_pll_clock_wiz_reset;
        wire    rgmii_pll_clock_wiz_clk_in1;
        wire    rgmii_pll_clock_wiz_locked;
        wire    rgmii_pll_clock_wiz_clk_out1;

        rgmii_pll_clock_wiz rgmii_pll_clock_wiz(
            .reset      (rgmii_pll_clock_wiz_reset),
            .clk_in1    (rgmii_pll_clock_wiz_clk_in1),

            .locked     (rgmii_pll_clock_wiz_locked),
            .clk_out1   (rgmii_pll_clock_wiz_clk_out1)
        );

        assign phase_shifted_clock          = rgmii_pll_clock_wiz_clk_out1;
        assign phase_shifted_clock_lock     = rgmii_pll_clock_wiz_locked;
        assign rgmii_pll_clock_wiz_reset    = !reset_n;
        assign rgmii_pll_clock_wiz_clk_in1  = clock; 
    end
    else begin
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
            phase_shifted_clock = _phase_shifted_clock;
        end

        assign phase_shifted_clock_lock  = 1;
    end
endgenerate




endmodule