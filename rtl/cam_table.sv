`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
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
module cam_table#(
    parameter KEY_WIDTH             = 48,
    parameter TABLE_DEPTH           = 32,
    parameter INDEX_DEPTH           = 8
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire    [KEY_WIDTH-1:0]                 key_match,
    input   wire    [KEY_WIDTH-1:0]                 key_delete,
    input   wire    [KEY_WIDTH-1:0]                 key_write,
    input   wire    [$clog2(INDEX_DEPTH)-1:0]       index,
    input   wire                                    match_enable,
    input   wire                                    write_enable,
    input   wire                                    delete_enable,

    output  reg     [$clog2(INDEX_DEPTH)-1:0]       match_index,
    output  reg                                     match_valid,
    output  reg                                     no_match
);

typedef enum
{
    S_IDLE,
    S_MATCH
} state_type;

state_type  _state;
state_type  state;

reg     [KEY_WIDTH-1:0]                 key_list    [TABLE_DEPTH-1:0];
logic   [KEY_WIDTH-1:0]                 _key_list   [TABLE_DEPTH-1:0];
reg     [$clog2(INDEX_DEPTH)-1:0]       index_list  [TABLE_DEPTH-1:0];
logic   [$clog2(INDEX_DEPTH)-1:0]       _index_list [TABLE_DEPTH-1:0];
reg     [$clog2(TABLE_DEPTH)-1:0]       target_index;
logic   [$clog2(TABLE_DEPTH)-1:0]       _target_index;
reg                                     filled      [TABLE_DEPTH-1:0];
logic                                   _filled     [TABLE_DEPTH-1:0];
logic                                   written;
logic   [$clog2(INDEX_DEPTH)-1:0]       _match_index;
logic                                   _match_valid;
logic                                   _no_match;
logic   [KEY_WIDTH-1:0]                 _cached_key_delete;
reg     [KEY_WIDTH-1:0]                 cached_key_delete;
logic                                   _delete_enable_delayed;
reg                                     delete_enable_delayed;
logic   [KEY_WIDTH-1:0]                 _cached_key_write;
reg     [KEY_WIDTH-1:0]                 cached_key_write;
logic   [$clog2(INDEX_DEPTH)-1:0]       _cached_index_write;
reg     [$clog2(INDEX_DEPTH)-1:0]       cached_index_write;
logic                                   _write_enable_delayed;
reg                                     write_enable_delayed;
reg                                     match_enable_delayed;
logic                                   _match_enable_delayed;
logic   [KEY_WIDTH-1:0]                 _cached_key_match;
reg     [KEY_WIDTH-1:0]                 cached_key_match;
integer                                 i;
integer                                 j;


always_comb begin
    _cached_index_write     = index;
    _cached_key_write       = key_write;
    _write_enable_delayed   = write_enable;
    _match_enable_delayed   = match_enable;
    _cached_key_delete      = key_delete;
    _cached_key_match       = key_match;
    _delete_enable_delayed  = delete_enable;
    _match_index            = index_list[target_index];
    _target_index           = target_index;
    _no_match               = 0;
    _match_valid            = 0;
    written                 = 0;

    for (i=0; i<TABLE_DEPTH; i=i+1) begin
        _key_list[i]    = key_list[i];
        _index_list[i]  = index_list[i];
        _filled[i]      = filled[i];
    end

    if (write_enable_delayed) begin
        for (i=0; i<TABLE_DEPTH; i=i+1) begin
            if (!written) begin
                if (!filled[i]) begin
                    _key_list[i]    = cached_key_write;
                    _index_list[i]  = cached_index_write;
                    _filled[i]      = 1;
                    written         = 1;
                end
            end
        end
    end

    if (delete_enable_delayed) begin
        for (i=0; i<TABLE_DEPTH; i=i+1) begin
            if (filled[i] && (key_list[i] == cached_key_delete)) begin
                _filled[i]  = 0;
            end
        end
    end

    case (state)
        S_IDLE: begin            
            if (match_enable_delayed) begin
                _no_match   = 1;

                for (i=0; i<TABLE_DEPTH; i=i+1) begin
                    if (filled[i] && (key_list[i] == cached_key_match)) begin
                        _target_index   = i;
                        _state          = S_MATCH;
                    end
                end
            end
        end
        S_MATCH: begin
            _no_match       = 0;
            _match_valid    = 1;
            _state          = S_IDLE;
        end
    endcase


end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                   <= S_IDLE;
        no_match                <= '0;
        match_valid             <= '0;
        match_index             <= '0;
        cached_key_delete       <= '0;
        cached_key_write        <= '0;
        cached_key_match        <= '0;
        delete_enable_delayed   <= '0;
        cached_index_write      <= '0;
        write_enable_delayed    <= '0;
        match_enable_delayed    <= '0;
        target_index            <= '0;

        for (j=0; j<TABLE_DEPTH; j=j+1) begin
            index_list[j]               <=  '0;
            key_list[j]                 <=  '0;
            filled[j]                   <=  '0;
        end
    end
    else begin
        state                   <= _state;
        no_match                <= _no_match;
        match_valid             <= _match_valid;
        match_index             <= _match_index;
        cached_key_delete       <= _cached_key_delete;
        cached_key_write        <= _cached_key_write;
        cached_key_match        <= _cached_key_match;
        delete_enable_delayed   <= _delete_enable_delayed;
        cached_index_write      <= _cached_index_write;
        write_enable_delayed    <= _write_enable_delayed;
        match_enable_delayed    <= _match_enable_delayed;
        target_index            <= _target_index;

        for (j=0; j<TABLE_DEPTH; j=j+1) begin
            index_list[j]               <=  _index_list[j];
            key_list[j]                 <=  _key_list[j];
            filled[j]                   <=  _filled[j];
        end
    end
end

endmodule