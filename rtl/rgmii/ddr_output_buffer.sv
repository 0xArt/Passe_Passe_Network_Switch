`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
// 
// Create Date: 09/02/2023
// Design Name: 
// Module Name: ddr_output_buffer
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
// 
//////////////////////////////////////////////////////////////////////////////////
module ddr_output_buffer #(
    parameter OUTPUT_WIDTH  = 4,
    parameter SWAP_ENABLE   = 0,
    parameter XILINX        = 0
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [(OUTPUT_WIDTH*2)-1:0]  ddr_input,
    
    output  logic   [OUTPUT_WIDTH-1:0]      ddr_output
);


genvar i;

generate
    if (XILINX) begin
        //ULTRASCALE ddr input buffer, replace with one for your fabric technology otherwise
        for (i = 0; i < OUTPUT_WIDTH; i = i + 1) begin
            ODDRE1 #(
                .IS_C_INVERTED  (0),                    
                .SRVAL          (0),                    
                .IS_D1_INVERTED (0),
                .IS_D2_INVERTED (0)
            ) ddr_output (
                .Q              (ddr_output[i]),      
                .C              (clock),              
                .D1             (ddr_input[(2*i)]),
                .D2             (ddr_input[(2*i)+1]),    
                .SR             (!reset_n)            
            );
        end
    end
    else begin
        always begin
            if (SWAP_ENABLE) begin
                @(posedge clock);
                ddr_output =   ddr_input[OUTPUT_WIDTH-1:0];
                @(negedge clock);
                ddr_output =   ddr_input[(OUTPUT_WIDTH*2)-1:OUTPUT_WIDTH];
            end
            else begin
                @(posedge clock);
                ddr_output =   ddr_input[(OUTPUT_WIDTH*2)-1:OUTPUT_WIDTH];
                @(negedge clock);
                ddr_output =   ddr_input[OUTPUT_WIDTH-1:0];
            end
        end
    end
endgenerate



endmodule