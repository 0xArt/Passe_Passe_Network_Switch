`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: frame_check_sequence_generator
// Project Name:
// Target Devices:
// Tool Versions:
// Description: ethernet crc32 generator. processes DATA_BYTES bytes per
//              cycle by cascading the byte step; data_byte_count limits the
//              cascade on the final beat of a frame. byte 0 of the data bus
//              is first on the wire. at DATA_BYTES = 1 this behaves exactly
//              like the original byte serial implementation
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
module frame_check_sequence_generator#(
    parameter DATA_BYTES = 1
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire    [(DATA_BYTES*8)-1:0]            data,
    input   wire                                    data_enable,
    input   wire                                    data_last,
    input   wire    [$clog2(DATA_BYTES+1)-1:0]      data_byte_count,

    output  reg                                     ready,
    output  reg     [31:0]                          checksum,
    output  reg                                     checksum_valid
);


typedef enum
{
    S_IDLE,
    S_CALCULATE,
    S_FINISH
} state_type;

state_type          _state;
state_type          state;
integer             i;
integer             j;
logic   [31:0]      _checksum;
logic               _checksum_valid;
reg     [31:0]      lfsr_in;
logic   [31:0]      _lfsr_in;
logic   [31:0]      lfsr_next;
logic   [31:0]      lfsr_in_xor;
logic   [31:0]      lfsr_in_xor_binary_reverse;
logic               _ready;

//one crc32 byte step of the 802.3 lfsr (data bits enter reversed)
function automatic logic [31:0] lfsr_byte_step(input logic [31:0] c, input logic [7:0] d);
    logic [7:0]     r;
    logic [31:0]    o;

    for (int k = 0; k < 8; k = k + 1) begin
        r[k]    = d[7-k];
    end

    o[0]     = c[24] ^ c[30] ^ r[0] ^ r[6];
    o[1]     = c[24] ^ c[25] ^ c[30] ^ c[31] ^ r[0] ^ r[1] ^ r[6] ^ r[7];
    o[2]     = c[24] ^ c[25] ^ c[26] ^ c[30] ^ c[31] ^ r[0] ^ r[1] ^ r[2] ^ r[6] ^ r[7];
    o[3]     = c[25] ^ c[26] ^ c[27] ^ c[31] ^ r[1] ^ r[2] ^ r[3] ^ r[7];
    o[4]     = c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ r[0] ^ r[2] ^ r[3] ^ r[4] ^ r[6];
    o[5]     = c[24] ^ c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31] ^ r[0] ^ r[1] ^ r[3] ^ r[4] ^ r[5] ^ r[6] ^ r[7];
    o[6]     = c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31] ^ r[1] ^ r[2] ^ r[4] ^ r[5] ^ r[6] ^ r[7];
    o[7]     = c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31] ^ r[0] ^ r[2] ^ r[3] ^ r[5] ^ r[7];
    o[8]     = c[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ r[0] ^ r[1] ^ r[3] ^ r[4];
    o[9]     = c[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ r[1] ^ r[2] ^ r[4] ^ r[5];
    o[10]    = c[2] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ r[0] ^ r[2] ^ r[3] ^ r[5];
    o[11]    = c[3] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ r[0] ^ r[1] ^ r[3] ^ r[4];
    o[12]    = c[4] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ r[0] ^ r[1] ^ r[2] ^ r[4] ^ r[5] ^ r[6];
    o[13]    = c[5] ^ c[25] ^ c[26] ^ c[27] ^ c[29] ^ c[30] ^ c[31] ^ r[1] ^ r[2] ^ r[3] ^ r[5] ^ r[6] ^ r[7];
    o[14]    = c[6] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ c[31] ^ r[2] ^ r[3] ^ r[4] ^ r[6] ^ r[7];
    o[15]    = c[7] ^ c[27] ^ c[28] ^ c[29] ^ c[31] ^ r[3] ^ r[4] ^ r[5] ^ r[7];
    o[16]    = c[8] ^ c[24] ^ c[28] ^ c[29] ^ r[0] ^ r[4] ^ r[5];
    o[17]    = c[9] ^ c[25] ^ c[29] ^ c[30] ^ r[1] ^ r[5] ^ r[6];
    o[18]    = c[10] ^ c[26] ^ c[30] ^ c[31] ^ r[2] ^ r[6] ^ r[7];
    o[19]    = c[11] ^ c[27] ^ c[31] ^ r[3] ^ r[7];
    o[20]    = c[12] ^ c[28] ^ r[4];
    o[21]    = c[13] ^ c[29] ^ r[5];
    o[22]    = c[14] ^ c[24] ^ r[0];
    o[23]    = c[15] ^ c[24] ^ c[25] ^ c[30] ^ r[0] ^ r[1] ^ r[6];
    o[24]    = c[16] ^ c[25] ^ c[26] ^ c[31] ^ r[1] ^ r[2] ^ r[7];
    o[25]    = c[17] ^ c[26] ^ c[27] ^ r[2] ^ r[3];
    o[26]    = c[18] ^ c[24] ^ c[27] ^ c[28] ^ c[30] ^ r[0] ^ r[3] ^ r[4] ^ r[6];
    o[27]    = c[19] ^ c[25] ^ c[28] ^ c[29] ^ c[31] ^ r[1] ^ r[4] ^ r[5] ^ r[7];
    o[28]    = c[20] ^ c[26] ^ c[29] ^ c[30] ^ r[2] ^ r[5] ^ r[6];
    o[29]    = c[21] ^ c[27] ^ c[30] ^ c[31] ^ r[3] ^ r[6] ^ r[7];
    o[30]    = c[22] ^ c[28] ^ c[31] ^ r[4] ^ r[7];
    o[31]    = c[23] ^ c[29] ^ r[5];

    return o;
endfunction


always_comb begin
    _state                          = state;
    _checksum                       = checksum;
    _lfsr_in                        = lfsr_in;
    _checksum_valid                 = '0;
    _ready                          = ready;

    //cascade the byte step across the beat. the byte count only shortens
    //the cascade on the last beat of a frame
    lfsr_next   = lfsr_in;

    for (i = 0; i < DATA_BYTES; i = i + 1) begin
        if (!data_last || (i < data_byte_count)) begin
            lfsr_next   = lfsr_byte_step(lfsr_next, data[(i*8) +: 8]);
        end
    end

    lfsr_in_xor     = lfsr_in ^ 32'hFFFF_FFFF;

    for (j=0;j<32;j++) begin
        lfsr_in_xor_binary_reverse[j]   = lfsr_in_xor[31-j];
    end

    _checksum = {lfsr_in_xor_binary_reverse[7:0],lfsr_in_xor_binary_reverse[15:8], lfsr_in_xor_binary_reverse[23:16], lfsr_in_xor_binary_reverse[31:24]};

    case (state)
        S_CALCULATE: begin
            if (data_enable) begin
                _lfsr_in         =  lfsr_next;
                _ready           =  '0;
            end
            if (data_last) begin
                _state              = S_FINISH;
            end
        end
        S_FINISH: begin
            _checksum_valid         = 1'b1;
            _state                  = S_CALCULATE;
            _lfsr_in                = '1;
            _ready                  = 1'b1;
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_CALCULATE;
        checksum                    <= '0;
        checksum_valid              <= '0;
        lfsr_in                     <= '1;
        ready                       <=  1'b1;
    end
    else begin
        state                       <= _state;
        checksum                    <= _checksum;
        checksum_valid              <= _checksum_valid;
        lfsr_in                     <= _lfsr_in;
        ready                       <= _ready;
    end
end

endmodule
