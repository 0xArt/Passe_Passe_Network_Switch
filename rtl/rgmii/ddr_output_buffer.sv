`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
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
// SIMULATION ONLY
// 
//////////////////////////////////////////////////////////////////////////////////
module ddr_output_buffer #(
    parameter OUTPUT_WIDTH  = 4,
    parameter SWAP_ENABLE   = 0,
    parameter TECHNOLOGY    = "SIMULATION"
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [(OUTPUT_WIDTH*2)-1:0]  ddr_input,
    
    output  logic   [OUTPUT_WIDTH-1:0]      ddr_output
);


genvar i;

generate
    if ( TECHNOLOGY == "ULTRASCALE" ) begin
        for (i = 0; i < OUTPUT_WIDTH; i = i + 1) begin
            ODDRE1 #(
                .IS_C_INVERTED  (0),                    
                .SRVAL          (0),                    
                .IS_D1_INVERTED (0),
                .IS_D2_INVERTED (0),
                .SIM_DEVICE     ("ULTRASCALE_PLUS")
            ) ddr_output (
                .Q              (ddr_output[i]),      
                .C              (clock),              
                .D1             (ddr_input[i]),
                .D2             (ddr_input[OUTPUT_WIDTH+i]),    
                .SR             (!reset_n)            
            );
        end
    end
    else if ( TECHNOLOGY == "7_SERIES" ) begin
        for (i = 0; i < OUTPUT_WIDTH; i = i + 1) begin
        ODDR #(
            .DDR_CLK_EDGE("SAME_EDGE"),
            .INIT(1'b0),
            .SRTYPE("ASYNC")
        ) ddr_output (
                .Q              (ddr_output[i]),      
                .C              (clock),       
                .CE             (1'b1),
                .D1             (ddr_input[i]),
                .D2             (ddr_input[OUTPUT_WIDTH+i]),    
                .R              (!reset_n),
                .S              (1'b0)
        );
        end
    end
    else begin
        always begin
            if (SWAP_ENABLE) begin
                @(posedge clock);
                ddr_output = ddr_input[OUTPUT_WIDTH-1:0];
                @(negedge clock);
                ddr_output = ddr_input[(OUTPUT_WIDTH*2)-1:OUTPUT_WIDTH];
            end
            else begin
                @(posedge clock);
                ddr_output = ddr_input[(OUTPUT_WIDTH*2)-1:OUTPUT_WIDTH];
                @(negedge clock);
                ddr_output = ddr_input[OUTPUT_WIDTH-1:0];
            end
        end
    end
endgenerate


endmodule