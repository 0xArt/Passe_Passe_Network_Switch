`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 04/30/2023
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
// or incorporation into proprietary software or hardware is strictly prohibited without prior
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
    parameter INDEX_DEPTH           = 8,
    parameter COMPARE_BANK_SIZE     = 8
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

localparam NUMBER_OF_BANKS = (TABLE_DEPTH + COMPARE_BANK_SIZE - 1) / COMPARE_BANK_SIZE;

reg     [KEY_WIDTH-1:0]                             key_list    [TABLE_DEPTH-1:0];
logic   [KEY_WIDTH-1:0]                             _key_list   [TABLE_DEPTH-1:0];
reg     [$clog2(INDEX_DEPTH)-1:0]                   index_list  [TABLE_DEPTH-1:0];
logic   [$clog2(INDEX_DEPTH)-1:0]                   _index_list [TABLE_DEPTH-1:0];
reg                                                 filled      [TABLE_DEPTH-1:0];
logic                                               _filled     [TABLE_DEPTH-1:0];

//the match and delete keys are duplicated per compare bank so each register
//copy only drives COMPARE_BANK_SIZE comparators. the attributes stop
//synthesis from merging the duplicates back into one register
(* dont_touch = "true", preserve *)
reg     [NUMBER_OF_BANKS-1:0][KEY_WIDTH-1:0]        cached_key_match;
logic   [NUMBER_OF_BANKS-1:0][KEY_WIDTH-1:0]        _cached_key_match;
(* dont_touch = "true", preserve *)
reg     [NUMBER_OF_BANKS-1:0][KEY_WIDTH-1:0]        cached_key_delete;
logic   [NUMBER_OF_BANKS-1:0][KEY_WIDTH-1:0]        _cached_key_delete;
reg     [KEY_WIDTH-1:0]                             cached_key_write;
logic   [KEY_WIDTH-1:0]                             _cached_key_write;
reg     [$clog2(INDEX_DEPTH)-1:0]                   cached_index_write;
logic   [$clog2(INDEX_DEPTH)-1:0]                   _cached_index_write;
reg                                                 match_enable_delayed;
logic                                               _match_enable_delayed;
reg                                                 write_enable_delayed;
logic                                               _write_enable_delayed;
reg                                                 delete_enable_delayed;
logic                                               _delete_enable_delayed;

//free slot bookkeeping. the first free slot is scanned in the background and
//registered so the write path does not carry the priority chain
reg     [$clog2(TABLE_DEPTH)-1:0]                   free_index;
logic   [$clog2(TABLE_DEPTH)-1:0]                   _free_index;
reg                                                 free_index_valid;
logic                                               _free_index_valid;

//match pipeline. stage one registers the raw per entry hits, stage two
//encodes them. the hit vector is one hot because a learn always deletes a
//key before rewriting it, so the encode is an or tree instead of a
//priority chain
reg     [TABLE_DEPTH-1:0]                           hit;
logic   [TABLE_DEPTH-1:0]                           _hit;
reg                                                 hit_valid;
logic                                               _hit_valid;
logic   [$clog2(INDEX_DEPTH)-1:0]                   _match_index;
logic                                               _match_valid;
logic                                               _no_match;

integer i;
integer j;


always_comb begin
    for (i=0; i<NUMBER_OF_BANKS; i=i+1) begin
        _cached_key_match[i]    = key_match;
        _cached_key_delete[i]   = key_delete;
    end
    _cached_key_write       = key_write;
    _cached_index_write     = index;
    _match_enable_delayed   = match_enable;
    _write_enable_delayed   = write_enable;
    _delete_enable_delayed  = delete_enable;

    for (i=0; i<TABLE_DEPTH; i=i+1) begin
        _key_list[i]    = key_list[i];
        _index_list[i]  = index_list[i];
        _filled[i]      = filled[i];
    end

    if (write_enable_delayed && free_index_valid) begin
        _key_list[free_index]   = cached_key_write;
        _index_list[free_index] = cached_index_write;
        _filled[free_index]     = 1;
    end

    if (delete_enable_delayed) begin
        for (i=0; i<TABLE_DEPTH; i=i+1) begin
            if (filled[i] && (key_list[i] == cached_key_delete[i/COMPARE_BANK_SIZE])) begin
                _filled[i]  = 0;
            end
        end
    end

    _free_index         = free_index;
    _free_index_valid   = 0;
    for (i=TABLE_DEPTH-1; i>=0; i=i-1) begin
        if (!_filled[i]) begin
            _free_index         = i;
            _free_index_valid   = 1;
        end
    end

    _hit_valid  = match_enable_delayed;
    for (i=0; i<TABLE_DEPTH; i=i+1) begin
        _hit[i] = filled[i] && (key_list[i] == cached_key_match[i/COMPARE_BANK_SIZE]);
    end

    _match_index    = '0;
    for (i=0; i<TABLE_DEPTH; i=i+1) begin
        if (hit[i]) begin
            _match_index    = _match_index | index_list[i];
        end
    end
    _match_valid    = hit_valid && (|hit);
    _no_match       = hit_valid && !(|hit);
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        no_match                <= '0;
        match_valid             <= '0;
        match_index             <= '0;
        cached_key_delete       <= '0;
        cached_key_write        <= '0;
        cached_key_match        <= '0;
        cached_index_write      <= '0;
        match_enable_delayed    <= '0;
        write_enable_delayed    <= '0;
        delete_enable_delayed   <= '0;
        free_index              <= '0;
        free_index_valid        <= '0;
        hit                     <= '0;
        hit_valid               <= '0;

        for (j=0; j<TABLE_DEPTH; j=j+1) begin
            index_list[j]               <=  '0;
            key_list[j]                 <=  '0;
            filled[j]                   <=  '0;
        end
    end
    else begin
        no_match                <= _no_match;
        match_valid             <= _match_valid;
        match_index             <= _match_index;
        cached_key_delete       <= _cached_key_delete;
        cached_key_write        <= _cached_key_write;
        cached_key_match        <= _cached_key_match;
        cached_index_write      <= _cached_index_write;
        match_enable_delayed    <= _match_enable_delayed;
        write_enable_delayed    <= _write_enable_delayed;
        delete_enable_delayed   <= _delete_enable_delayed;
        free_index              <= _free_index;
        free_index_valid        <= _free_index_valid;
        hit                     <= _hit;
        hit_valid               <= _hit_valid;

        for (j=0; j<TABLE_DEPTH; j=j+1) begin
            index_list[j]               <=  _index_list[j];
            key_list[j]                 <=  _key_list[j];
            filled[j]                   <=  _filled[j];
        end
    end
end

endmodule
