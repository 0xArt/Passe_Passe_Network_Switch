`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
// 
// Create Date: 09/02/2023
// Design Name: 
// Module Name: ddr_input_buffer
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
module ddr_input_buffer #(
    parameter INPUT_WIDTH   = 4,
    parameter XILINX        = 0  
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [INPUT_WIDTH-1:0]       ddr_input,

    output  reg     [(INPUT_WIDTH*2)-1:0]   ddr_output
);



genvar i;

generate 
    if (XILINX) begin
        for (i = 0; i < INPUT_WIDTH; i = i + 1) begin
            IDDRE1 #(
                .DDR_CLK_EDGE   ("SAME_EDGE_PIPELINED"),
                .IS_C_INVERTED  (1'b0),                 
                .IS_CB_INVERTED (1'b0)                  
            ) ddr_input (
                .Q1             (ddr_output[2*i]),   
                .Q2             (ddr_output[(2*i)+1]),
                .C              (clock),             
                .CB             (!clock),                 
                .D              (ddr_input[i]),      
                .R              (!reset_n)
            );
        end
    end
    else begin
        logic     [INPUT_WIDTH-1:0]     positive_edge_capture;
        logic     [INPUT_WIDTH-1:0]     negative_edge_capture;
        logic     [(INPUT_WIDTH*2)-1:0] _ddr_output;


        always_comb begin
            _ddr_output              = {positive_edge_capture,negative_edge_capture};
        end


        always begin
            @(posedge clock);
            positive_edge_capture   =   ddr_input;
            @(negedge clock);
            negative_edge_capture   =   ddr_input;
        end


        always_ff @(negedge clock or negedge reset_n) begin
            if (!reset_n) begin
                ddr_output   <=  0;
            end
            else begin
                ddr_output   <=  _ddr_output;
            end
        end
    end
endgenerate



endmodule