`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
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
// 
//////////////////////////////////////////////////////////////////////////////////
module generic_block_ram#(
    parameter DATA_WIDTH            = 16,
    parameter DATA_DEPTH            = 4096,
    parameter PIPELINED_OUTPUT      = "TRUE"
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire                                    write_enable,
    input   wire    [DATA_WIDTH-1:0]                write_data,
    input   wire    [$clog2(DATA_DEPTH)-1:0]        write_address,
    input   wire    [$clog2(DATA_DEPTH)-1:0]        read_address,

    output  reg     [DATA_WIDTH-1:0]                read_data
);


reg     [DATA_WIDTH-1:0]                memory   [DATA_DEPTH-1:0];
logic   [DATA_WIDTH-1:0]                _memory  [DATA_DEPTH-1:0];
reg     [DATA_WIDTH-1:0]                pipelined_read_data;
logic   [DATA_WIDTH-1:0]                _pipelined_read_data;
reg     [DATA_WIDTH-1:0]                memory_read_data;
logic   [DATA_WIDTH-1:0]                _memory_read_data;
integer                                 i;
integer                                 j;


always_comb begin

    for (i=0; i<DATA_DEPTH; i=i+1) begin
        _memory[i]      =   memory[i];
    end

    _memory_read_data       =   memory[read_address];
    _pipelined_read_data    =   memory_read_data;

    if (PIPELINED_OUTPUT) begin
        read_data   =   pipelined_read_data;
    end
    else begin
        read_data   =   memory_read_data;
    end

    if  (write_enable) begin
        _memory[write_address] = write_data;
    end
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        memory_read_data                <=  0;
        pipelined_read_data             <=  0;

        for (j=0; j<DATA_DEPTH; j=j+1) begin
            memory[j]                   <=  0;
        end
    end
    else begin
        memory_read_data                <=  _memory_read_data;
        pipelined_read_data             <=  _pipelined_read_data;

        for (j=0; j<DATA_DEPTH; j=j+1) begin
            memory[j]                   <=  _memory[j];
        end
    end
end

endmodule