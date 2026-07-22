`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 07/21/2026
// Module Name: width_adapter_down
// Description: unpacks FABRIC_DATA_BYTES wide fabric beats into a 9 bit byte
//              stream (bit 8 = first) with an explicit last flag. byte 0 of
//              a beat is first on the wire. elaborates to wires when
//              FABRIC_DATA_BYTES is 1
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
module width_adapter_down#(
    parameter FABRIC_DATA_BYTES = 1
)(
    input   wire                                            clock,
    input   wire                                            reset_n,
    input   wire    [(FABRIC_DATA_BYTES*8)-1:0]             beat_data,
    input   wire                                            beat_first,
    input   wire                                            beat_last,
    input   wire    [$clog2(FABRIC_DATA_BYTES+1)-1:0]       beat_byte_count,
    input   wire                                            beat_valid,
    input   wire                                            byte_data_ready,

    output  logic                                           beat_ready,
    output  logic   [8:0]                                   byte_data,
    output  logic                                           byte_data_valid,
    output  logic                                           byte_data_last
);

generate
    if (FABRIC_DATA_BYTES == 1) begin
        assign byte_data[7:0]   = beat_data;
        assign byte_data[8]     = beat_first;
        assign byte_data_last   = beat_last;
        assign byte_data_valid  = beat_valid;
        assign beat_ready       = byte_data_ready;
    end
    else begin
        reg     [(FABRIC_DATA_BYTES*8)-1:0]             held_data;
        logic   [(FABRIC_DATA_BYTES*8)-1:0]             _held_data;
        reg                                             held_first;
        logic                                           _held_first;
        reg                                             held_last;
        logic                                           _held_last;
        reg     [$clog2(FABRIC_DATA_BYTES+1)-1:0]       held_byte_count;
        logic   [$clog2(FABRIC_DATA_BYTES+1)-1:0]       _held_byte_count;
        reg                                             held_valid;
        logic                                           _held_valid;
        reg     [$clog2(FABRIC_DATA_BYTES+1)-1:0]       byte_index;
        logic   [$clog2(FABRIC_DATA_BYTES+1)-1:0]       _byte_index;
        logic                                           last_byte_of_beat;

        always_comb begin
            _held_data          = held_data;
            _held_first         = held_first;
            _held_last          = held_last;
            _held_byte_count    = held_byte_count;
            _held_valid         = held_valid;
            _byte_index         = byte_index;
            last_byte_of_beat   = (byte_index == (held_byte_count - 1));

            byte_data[7:0]      = held_data[byte_index*8 +: 8];
            byte_data[8]        = held_first && (byte_index == 0);
            byte_data_last      = held_last && last_byte_of_beat;
            byte_data_valid     = held_valid;

            if (held_valid && byte_data_ready) begin
                if (last_byte_of_beat) begin
                    _held_valid = 0;
                    _byte_index = 0;
                end
                else begin
                    _byte_index = byte_index + 1;
                end
            end

            beat_ready = !_held_valid;

            if (beat_valid && beat_ready) begin
                _held_data          = beat_data;
                _held_first         = beat_first;
                _held_last          = beat_last;
                _held_byte_count    = beat_byte_count;
                _held_valid         = 1;
                _byte_index         = 0;
            end
        end

        always_ff @(posedge clock) begin
            if (!reset_n) begin
                held_data       <= '0;
                held_first      <= '0;
                held_last       <= '0;
                held_byte_count <= '0;
                held_valid      <= '0;
                byte_index      <= '0;
            end
            else begin
                held_data       <= _held_data;
                held_first      <= _held_first;
                held_last       <= _held_last;
                held_byte_count <= _held_byte_count;
                held_valid      <= _held_valid;
                byte_index      <= _byte_index;
            end
        end
    end
endgenerate

endmodule
