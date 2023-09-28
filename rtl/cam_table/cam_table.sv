`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 09/27/2023
// Design Name: 
// Module Name: cam_table
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
module cam_table#(
    parameter KEY_WIDTH             = 48,
    parameter TABLE_DEPTH           = 32
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire                                    write_enable,
    input   wire    [KEY_WIDTH-1:0]                 key,
    input   wire    [$clog2(TABLE_DEPTH)-1:0]       match_enable,

    output  reg     [$clog2(TABLE_DEPTH)-1:0]       match_index,
    output  reg                                     match_valid,
    output  reg                                     no_match
);


reg     [KEY_WIDTH-1:0]                key_list     [TABLE_DEPTH-1:0];
logic   [KEY_WIDTH-1:0]                _key_list    [TABLE_DEPTH-1:0];
reg     [$clog2(TABLE_DEPTH)-1:0]      index_list   [TABLE_DEPTH-1:0];
logic   [$clog2(TABLE_DEPTH)-1:0]      _index_list  [TABLE_DEPTH-1:0];
reg                                     filled      [TABLE_DEPTH-1:0];
logic                                   _filled     [TABLE_DEPTH-1:0];
logic                                   written;
logic   [$clog2(TABLE_DEPTH)-1:0]       _match_index;
logic                                   _match_valid;
logic                                   _no_match;

integer                                 i;
integer                                 j;


always_comb begin
    _match_index    =   match_index;
    _no_match       =   0;
    _match_valid    =   0;
    written         =   0;

    for (i=0; i<TABLE_DEPTH; i=i+1) begin
        _key_list[i]    =   key_list[i];
        _index_list[i]  =   index_list[i];
        _filled[i]      =   filled[i];
    end

    if (write_enable) begin
        for (i=0; i<TABLE_DEPTH; i=i+1) begin
            if (!written) begin
                if (!filled[i]) begin
                    _key_list[i]    = key;
                    _filled[i]      = 1;
                    written         = 1;
                end
            end
        end
    end

    if (match_enable) begin
        _no_match = 1;

        for (i=0; i<TABLE_DEPTH; i=i+1) begin
            if (key_list[i] == key) begin
                _no_match       = 0;
                _match_index    = index_list[i];
                _match_valid    = 1;
            end
        end
    end
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        no_match    <=  0;
        match_valid <=  0;
        match_index <=  0;

        for (j=0; j<TABLE_DEPTH; j=j+1) begin
            index_list[j]               <=  0;
            key_list[j]                 <=  0;
            filled[j]                   <=  0;
        end
    end
    else begin
        no_match    <=  _no_match;
        match_valid <=  _match_valid;
        match_index <=  _match_index;

        for (j=0; j<TABLE_DEPTH; j=j+1) begin
            index_list[j]               <=  _index_list[j];
            key_list[j]                 <=  _key_list[j];
            filled[j]                   <=  _filled[j];
        end
    end
end

endmodule