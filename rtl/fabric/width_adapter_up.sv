`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 07/21/2026
// Module Name: width_adapter_up
// Description: packs a 9 bit byte stream (bit 8 = first) with an explicit
//              last flag into FABRIC_DATA_BYTES wide fabric beats. byte 0 of
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
module width_adapter_up#(
    parameter FABRIC_DATA_BYTES = 1
)(
    input   wire                                            clock,
    input   wire                                            reset_n,
    input   wire    [8:0]                                   byte_data,
    input   wire                                            byte_data_enable,
    input   wire                                            byte_data_last,
    input   wire                                            beat_ready,

    output  logic                                           byte_data_ready,
    output  logic   [(FABRIC_DATA_BYTES*8)-1:0]             beat_data,
    output  logic                                           beat_first,
    output  logic                                           beat_last,
    output  logic   [$clog2(FABRIC_DATA_BYTES+1)-1:0]       beat_byte_count,
    output  logic                                           beat_valid
);

generate
    if (FABRIC_DATA_BYTES == 1) begin
        assign beat_data        = byte_data[7:0];
        assign beat_first       = byte_data[8];
        assign beat_last        = byte_data_last;
        assign beat_byte_count  = 1;
        assign beat_valid       = byte_data_enable;
        assign byte_data_ready  = beat_ready;
    end
    else begin
        reg     [(FABRIC_DATA_BYTES*8)-1:0]             accumulator_data;
        logic   [(FABRIC_DATA_BYTES*8)-1:0]             _accumulator_data;
        reg     [$clog2(FABRIC_DATA_BYTES+1)-1:0]       fill_count;
        logic   [$clog2(FABRIC_DATA_BYTES+1)-1:0]       _fill_count;
        reg                                             accumulator_first;
        logic                                           _accumulator_first;
        reg                                             accumulator_last;
        logic                                           _accumulator_last;
        reg                                             accumulator_done;
        logic                                           _accumulator_done;
        reg     [(FABRIC_DATA_BYTES*8)-1:0]             output_data;
        logic   [(FABRIC_DATA_BYTES*8)-1:0]             _output_data;
        reg                                             output_first;
        logic                                           _output_first;
        reg                                             output_last;
        logic                                           _output_last;
        reg     [$clog2(FABRIC_DATA_BYTES+1)-1:0]       output_byte_count;
        logic   [$clog2(FABRIC_DATA_BYTES+1)-1:0]       _output_byte_count;
        reg                                             output_valid;
        logic                                           _output_valid;
        logic                                           output_consumed;
        logic                                           transferred;
        logic   [$clog2(FABRIC_DATA_BYTES+1)-1:0]       lane;

        always_comb begin
            _accumulator_data   = accumulator_data;
            _fill_count         = fill_count;
            _accumulator_first  = accumulator_first;
            _accumulator_last   = accumulator_last;
            _accumulator_done   = accumulator_done;
            _output_data        = output_data;
            _output_first       = output_first;
            _output_last        = output_last;
            _output_byte_count  = output_byte_count;
            _output_valid       = output_valid;
            output_consumed     = output_valid && beat_ready;
            transferred         = '0;
            lane                = fill_count;

            if (output_consumed) begin
                _output_valid   = 0;
            end

            if (accumulator_done && (!output_valid || output_consumed)) begin
                _output_data        = accumulator_data;
                _output_first       = accumulator_first;
                _output_last        = accumulator_last;
                _output_byte_count  = fill_count;
                _output_valid       = 1'b1;
                _accumulator_done   = '0;
                _accumulator_last   = '0;
                _fill_count         = '0;
                transferred         = 1'b1;
                lane                = '0;
            end

            byte_data_ready = !accumulator_done || transferred;

            if (byte_data_enable && byte_data_ready) begin
                _accumulator_data[lane*8 +: 8]  = byte_data[7:0];

                if (lane == 0) begin
                    _accumulator_first  = byte_data[8];
                end

                _fill_count = lane + 1'b1;

                if (byte_data_last || (lane == FABRIC_DATA_BYTES-1)) begin
                    _accumulator_done   = 1'b1;
                    _accumulator_last   = byte_data_last;
                end
            end
        end

        always_ff @(posedge clock) begin
            if (!reset_n) begin
                accumulator_data    <= '0;
                fill_count          <= '0;
                accumulator_first   <= '0;
                accumulator_last    <= '0;
                accumulator_done    <= '0;
                output_data         <= '0;
                output_first        <= '0;
                output_last         <= '0;
                output_byte_count   <= '0;
                output_valid        <= '0;
            end
            else begin
                accumulator_data    <= _accumulator_data;
                fill_count          <= _fill_count;
                accumulator_first   <= _accumulator_first;
                accumulator_last    <= _accumulator_last;
                accumulator_done    <= _accumulator_done;
                output_data         <= _output_data;
                output_first        <= _output_first;
                output_last         <= _output_last;
                output_byte_count   <= _output_byte_count;
                output_valid        <= _output_valid;
            end
        end

        assign beat_data        = output_data;
        assign beat_first       = output_first;
        assign beat_last        = output_last;
        assign beat_byte_count  = output_byte_count;
        assign beat_valid       = output_valid;
    end
endgenerate

endmodule
