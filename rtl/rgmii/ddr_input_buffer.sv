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
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ddr_input_buffer #(
    parameter INPUT_WIDTH = 4
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [INPUT_WIDTH-1:0]       ddr_input,

    output  logic   [(INPUT_WIDTH*2)-1:0]   ddr_output
);


logic   [INPUT_WIDTH-1:0]   _positive_edge_capture;
logic   [INPUT_WIDTH-1:0]   _negative_edge_capture;
reg     [INPUT_WIDTH-1:0]   positive_edge_capture;
reg     [INPUT_WIDTH-1:0]   negative_edge_capture;

always_comb begin
    _positive_edge_capture  =   positive_edge_capture;
    _negative_edge_capture  =   negative_edge_capture;

    ddr_output              = {positive_edge_capture,negative_edge_capture};
end


always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        positive_edge_capture   <=  0;
    end
    else begin
        positive_edge_capture   <=  _positive_edge_capture;
    end
end

always_ff @(negedge clock or negedge reset_n) begin
    if (!reset_n) begin
        negative_edge_capture       <=  0;
    end
    else begin
        negative_edge_capture       <=  _negative_edge_capture;
    end
end


endmodule
