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
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ddr_output_buffer #(
    parameter OUTPUT_WIDTH = 4
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [(OUTPUT_WIDTH*2)-1:0]  ddr_input,
    
    output  reg     [OUTPUT_WIDTH-1:0]      ddr_output
);


logic   [OUTPUT_WIDTH-1:0]  _ddr_output;


always_comb begin
    _ddr_output  =   ddr_output;
end


always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        ddr_output   <=  0;
    end
    else begin
        ddr_output   <=  ddr_input[(OUTPUT_WIDTH*2)-1:OUTPUT_WIDTH];
    end
end


always_ff @(negedge clock or negedge reset_n) begin
    if (!reset_n) begin
        ddr_output   <=  0;
    end
    else begin
        ddr_output   <=  ddr_input[OUTPUT_WIDTH-1:0];
    end
end


endmodule