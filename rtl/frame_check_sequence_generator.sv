`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: frame_check_sequence_generator
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
module frame_check_sequence_generator(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [7:0]   data,
    input   wire            data_enable,
    input   wire            data_last,

    output  reg             ready,
    output  reg     [31:0]  checksum,
    output  reg             checksum_valid
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
logic   [7:0]       data_binary_reverse;
reg     [31:0]      lfsr_in;
logic   [31:0]      _lfsr_in;
logic   [31:0]      lfsr_out;
logic   [31:0]      lfsr_in_xor;
logic   [31:0]      lfsr_in_xor_binary_reverse;
logic               _ready;


always_comb begin
    _state                          =   state;
    _checksum                       =   checksum;
    _lfsr_in                        =   lfsr_in;
    _checksum_valid                 =   0;
    _ready                          =   ready;

    for (i=0;i<8;i++) begin
        data_binary_reverse[i]      = data[7-i];
    end

    lfsr_out[0]     =   lfsr_in[24] ^ lfsr_in[30] ^ data_binary_reverse[0] ^ data_binary_reverse[6];
    lfsr_out[1]     =   lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[30] ^ lfsr_in[31] ^ data_binary_reverse[0] ^ data_binary_reverse[1] ^ data_binary_reverse[6] ^ data_binary_reverse[7];
    lfsr_out[2]     =   lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[30] ^ lfsr_in[31] ^ data_binary_reverse[0] ^ data_binary_reverse[1] ^ data_binary_reverse[2] ^ data_binary_reverse[6] ^ data_binary_reverse[7];
    lfsr_out[3]     =   lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[31] ^ data_binary_reverse[1] ^ data_binary_reverse[2] ^ data_binary_reverse[3] ^ data_binary_reverse[7];
    lfsr_out[4]     =   lfsr_in[24] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[30] ^ data_binary_reverse[0] ^ data_binary_reverse[2] ^ data_binary_reverse[3] ^ data_binary_reverse[4] ^ data_binary_reverse[6];
    lfsr_out[5]     =   lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[30] ^ lfsr_in[31] ^ data_binary_reverse[0] ^ data_binary_reverse[1] ^ data_binary_reverse[3] ^ data_binary_reverse[4] ^ data_binary_reverse[5] ^ data_binary_reverse[6] ^ data_binary_reverse[7];
    lfsr_out[6]     =   lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[30] ^ lfsr_in[31] ^ data_binary_reverse[1] ^ data_binary_reverse[2] ^ data_binary_reverse[4] ^ data_binary_reverse[5] ^ data_binary_reverse[6] ^ data_binary_reverse[7];
    lfsr_out[7]     =   lfsr_in[24] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[29] ^ lfsr_in[31] ^ data_binary_reverse[0] ^ data_binary_reverse[2] ^ data_binary_reverse[3] ^ data_binary_reverse[5] ^ data_binary_reverse[7];
    lfsr_out[8]     =   lfsr_in[0] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[27] ^ lfsr_in[28] ^ data_binary_reverse[0] ^ data_binary_reverse[1] ^ data_binary_reverse[3] ^ data_binary_reverse[4];
    lfsr_out[9]     =   lfsr_in[1] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[28] ^ lfsr_in[29] ^ data_binary_reverse[1] ^ data_binary_reverse[2] ^ data_binary_reverse[4] ^ data_binary_reverse[5];
    lfsr_out[10]    =   lfsr_in[2] ^ lfsr_in[24] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[29] ^ data_binary_reverse[0] ^ data_binary_reverse[2] ^ data_binary_reverse[3] ^ data_binary_reverse[5];
    lfsr_out[11]    =   lfsr_in[3] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[27] ^ lfsr_in[28] ^ data_binary_reverse[0] ^ data_binary_reverse[1] ^ data_binary_reverse[3] ^ data_binary_reverse[4];
    lfsr_out[12]    =   lfsr_in[4] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[30] ^ data_binary_reverse[0] ^ data_binary_reverse[1] ^ data_binary_reverse[2] ^ data_binary_reverse[4] ^ data_binary_reverse[5] ^ data_binary_reverse[6];
    lfsr_out[13]    =   lfsr_in[5] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[29] ^ lfsr_in[30] ^ lfsr_in[31] ^ data_binary_reverse[1] ^ data_binary_reverse[2] ^ data_binary_reverse[3] ^ data_binary_reverse[5] ^ data_binary_reverse[6] ^ data_binary_reverse[7];
    lfsr_out[14]    =   lfsr_in[6] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[30] ^ lfsr_in[31] ^ data_binary_reverse[2] ^ data_binary_reverse[3] ^ data_binary_reverse[4] ^ data_binary_reverse[6] ^ data_binary_reverse[7];
    lfsr_out[15]    =   lfsr_in[7] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[31] ^ data_binary_reverse[3] ^ data_binary_reverse[4] ^ data_binary_reverse[5] ^ data_binary_reverse[7];
    lfsr_out[16]    =   lfsr_in[8] ^ lfsr_in[24] ^ lfsr_in[28] ^ lfsr_in[29] ^ data_binary_reverse[0] ^ data_binary_reverse[4] ^ data_binary_reverse[5];
    lfsr_out[17]    =   lfsr_in[9] ^ lfsr_in[25] ^ lfsr_in[29] ^ lfsr_in[30] ^ data_binary_reverse[1] ^ data_binary_reverse[5] ^ data_binary_reverse[6];
    lfsr_out[18]    =   lfsr_in[10] ^ lfsr_in[26] ^ lfsr_in[30] ^ lfsr_in[31] ^ data_binary_reverse[2] ^ data_binary_reverse[6] ^ data_binary_reverse[7];
    lfsr_out[19]    =   lfsr_in[11] ^ lfsr_in[27] ^ lfsr_in[31] ^ data_binary_reverse[3] ^ data_binary_reverse[7];
    lfsr_out[20]    =   lfsr_in[12] ^ lfsr_in[28] ^ data_binary_reverse[4];
    lfsr_out[21]    =   lfsr_in[13] ^ lfsr_in[29] ^ data_binary_reverse[5];
    lfsr_out[22]    =   lfsr_in[14] ^ lfsr_in[24] ^ data_binary_reverse[0];
    lfsr_out[23]    =   lfsr_in[15] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[30] ^ data_binary_reverse[0] ^ data_binary_reverse[1] ^ data_binary_reverse[6];
    lfsr_out[24]    =   lfsr_in[16] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[31] ^ data_binary_reverse[1] ^ data_binary_reverse[2] ^ data_binary_reverse[7];
    lfsr_out[25]    =   lfsr_in[17] ^ lfsr_in[26] ^ lfsr_in[27] ^ data_binary_reverse[2] ^ data_binary_reverse[3];
    lfsr_out[26]    =   lfsr_in[18] ^ lfsr_in[24] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[30] ^ data_binary_reverse[0] ^ data_binary_reverse[3] ^ data_binary_reverse[4] ^ data_binary_reverse[6];
    lfsr_out[27]    =   lfsr_in[19] ^ lfsr_in[25] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[31] ^ data_binary_reverse[1] ^ data_binary_reverse[4] ^ data_binary_reverse[5] ^ data_binary_reverse[7];
    lfsr_out[28]    =   lfsr_in[20] ^ lfsr_in[26] ^ lfsr_in[29] ^ lfsr_in[30] ^ data_binary_reverse[2] ^ data_binary_reverse[5] ^ data_binary_reverse[6];
    lfsr_out[29]    =   lfsr_in[21] ^ lfsr_in[27] ^ lfsr_in[30] ^ lfsr_in[31] ^ data_binary_reverse[3] ^ data_binary_reverse[6] ^ data_binary_reverse[7];
    lfsr_out[30]    =   lfsr_in[22] ^ lfsr_in[28] ^ lfsr_in[31] ^ data_binary_reverse[4] ^ data_binary_reverse[7];
    lfsr_out[31]    =   lfsr_in[23] ^ lfsr_in[29] ^ data_binary_reverse[5];

    lfsr_in_xor     =   lfsr_in ^ 32'hFFFF_FFFF;

    for (j=0;j<32;j++) begin
        lfsr_in_xor_binary_reverse[j]   = lfsr_in_xor[31-j];
    end

    _checksum = {lfsr_in_xor_binary_reverse[7:0],lfsr_in_xor_binary_reverse[15:8], lfsr_in_xor_binary_reverse[23:16], lfsr_in_xor_binary_reverse[31:24]};

    case (state)
        S_CALCULATE: begin
            if (data_enable) begin
                _lfsr_in         =  lfsr_out;
                _ready           =  0;
            end
            if (data_last) begin
                _checksum_valid     = 1;
                _state              = S_FINISH;
            end
        end
        S_FINISH: begin
            _state                  = S_CALCULATE;
            _lfsr_in                = '1;
            _ready                  = 1;
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <= S_CALCULATE;
        checksum                    <= 0;
        checksum_valid              <= 0;
        lfsr_in                     <= '1;
        ready                       <=  1;
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