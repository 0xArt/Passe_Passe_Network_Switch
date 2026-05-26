`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 05/27/2023
// Design Name: 
// Module Name: generic_block_ram
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
//
//////////////////////////////////////////////////////////////////////////////////
module generic_block_ram#(
    parameter DATA_WIDTH            = 16,
    parameter DATA_DEPTH            = 4096,
    parameter PIPELINED_OUTPUT      = 0
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire                                    write_enable,
    input   wire    [DATA_WIDTH-1:0]                write_data,
    input   wire    [$clog2(DATA_DEPTH)-1:0]        write_address,
    input   wire    [$clog2(DATA_DEPTH)-1:0]        read_address,

    output  reg     [DATA_WIDTH-1:0]                read_data
);


reg     [DATA_WIDTH-1:0]    memory   [DATA_DEPTH-1:0];
logic   [DATA_WIDTH-1:0]    _memory  [DATA_DEPTH-1:0];
reg     [DATA_WIDTH-1:0]    pipelined_read_data;
logic   [DATA_WIDTH-1:0]    _pipelined_read_data;
reg     [DATA_WIDTH-1:0]    memory_read_data;
logic   [DATA_WIDTH-1:0]    _memory_read_data;
integer                     i;
integer                     j;


always_comb begin
    for (i=0; i<DATA_DEPTH; i=i+1) begin
        _memory[i]  = memory[i];
    end

    if  (write_enable) begin
        _memory[write_address] = write_data;
    end

    _memory_read_data   = memory[read_address];

    if (PIPELINED_OUTPUT) begin
        read_data   = memory_read_data;
    end
    else begin
        read_data   = memory[read_address];
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        memory_read_data    <=  0;

        for (j=0; j<DATA_DEPTH; j=j+1) begin
            memory[j]   <=  0;
        end
    end
    else begin
        memory_read_data    <=  _memory_read_data;

        for (j=0; j<DATA_DEPTH; j=j+1) begin
            memory[j]   <=  _memory[j];
        end
    end
end

endmodule