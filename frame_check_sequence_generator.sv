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

    output  reg     [7:0]   checksum,
    output  reg             checksum_valid
);


typedef enum
{
    S_IDLE,
    S_COMPUTE,
    S_FINISH
} state_type;

integer i;
reg [7:0]   _checksum;
reg         _checksum_valid;
reg [7:0]   data_binary_reverse;
reg [7:0]   _data_binary_reverse;
reg [31:0]  lfsr_out;
reg [31:0]  _lfsr_out;
reg [31:0]  lfsr_out_xor;
reg [31:0]  _lfsr_out_xor;
reg [31:0]  lfsr_out_xor_binary_reverse;
reg [31:0]  _lfsr_out_xor_binary_reverse;
reg [31:0]  lfsr_in;
reg [31:0]  _lfsr_in;
reg [31:0]  checksum_result;
reg [31:0]  _checksum_result;
reg [1:0]   _counter;
reg [1:0]   counter;

state_type  _state;
state_type  state;

always_comb begin

    for (i=0;i<8;i++) begin
        _data_binary_reverse[i]             = data[7-i];
    end
    for (i=0;i<32;i++) begin
        _lfsr_out_xor_binary_reverse[i]     = lfsr_out_xor[31-i];
    end

    _state                          = state;
    _checksum_result                = checksum_result;
    _checksum                       = checksum;
    _checksum_valid                 = 0;
    _counter                        = counter;
    _lfsr_out_xor                   = lfsr_out ^ 32'hFFFF_FFFF;
    _lfsr_out[0]                    = data_binary_reverse[6] ^ data_binary_reverse[0] ^ lfsr_in[24] ^ lfsr_in[30];
    _lfsr_out[1]                    = data_binary_reverse[7] ^ data_binary_reverse[6] ^ data_binary_reverse[1] ^ data_binary_reverse[0] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[30] ^ lfsr_in[31];
    _lfsr_out[2]                    = data_binary_reverse[7] ^ data_binary_reverse[6] ^ data_binary_reverse[2] ^ data_binary_reverse[1] ^ data_binary_reverse[0] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[30] ^ lfsr_in[31];
    _lfsr_out[3]                    = data_binary_reverse[7] ^ data_binary_reverse[3] ^ data_binary_reverse[2] ^ data_binary_reverse[1] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[31];
    _lfsr_out[4]                    = data_binary_reverse[6] ^ data_binary_reverse[4] ^ data_binary_reverse[3] ^ data_binary_reverse[2] ^ data_binary_reverse[0] ^ lfsr_in[24] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[30];
    _lfsr_out[5]                    = data_binary_reverse[7] ^ data_binary_reverse[6] ^ data_binary_reverse[5] ^ data_binary_reverse[4] ^ data_binary_reverse[3] ^ data_binary_reverse[1] ^ data_binary_reverse[0] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[30] ^ lfsr_in[31];
    _lfsr_out[6]                    = data_binary_reverse[7] ^ data_binary_reverse[6] ^ data_binary_reverse[5] ^ data_binary_reverse[4] ^ data_binary_reverse[2] ^ data_binary_reverse[1] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[30] ^ lfsr_in[31];
    _lfsr_out[7]                    = data_binary_reverse[7] ^ data_binary_reverse[5] ^ data_binary_reverse[3] ^ data_binary_reverse[2] ^ data_binary_reverse[0] ^ lfsr_in[24] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[29] ^ lfsr_in[31];
    _lfsr_out[8]                    = data_binary_reverse[4] ^ data_binary_reverse[3] ^ data_binary_reverse[1] ^ data_binary_reverse[0] ^ lfsr_in[0] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[27] ^ lfsr_in[28];
    _lfsr_out[9]                    = data_binary_reverse[5] ^ data_binary_reverse[4] ^ data_binary_reverse[2] ^ data_binary_reverse[1] ^ lfsr_in[1] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[28] ^ lfsr_in[29];
    _lfsr_out[10]                   = data_binary_reverse[5] ^ data_binary_reverse[3] ^ data_binary_reverse[2] ^ data_binary_reverse[0] ^ lfsr_in[2] ^ lfsr_in[24] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[29];
    _lfsr_out[11]                   = data_binary_reverse[4] ^ data_binary_reverse[3] ^ data_binary_reverse[1] ^ data_binary_reverse[0] ^ lfsr_in[3] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[27] ^ lfsr_in[28];
    _lfsr_out[12]                   = data_binary_reverse[6] ^ data_binary_reverse[5] ^ data_binary_reverse[4] ^ data_binary_reverse[2] ^ data_binary_reverse[1] ^ data_binary_reverse[0] ^ lfsr_in[4] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[30];
    _lfsr_out[13]                   = data_binary_reverse[7] ^ data_binary_reverse[6] ^ data_binary_reverse[5] ^ data_binary_reverse[3] ^ data_binary_reverse[2] ^ data_binary_reverse[1] ^ lfsr_in[5] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[29] ^ lfsr_in[30] ^ lfsr_in[31];
    _lfsr_out[14]                   = data_binary_reverse[7] ^ data_binary_reverse[6] ^ data_binary_reverse[4] ^ data_binary_reverse[3] ^ data_binary_reverse[2] ^ lfsr_in[6] ^ lfsr_in[26] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[30] ^ lfsr_in[31];
    _lfsr_out[15]                   = data_binary_reverse[7] ^ data_binary_reverse[5] ^ data_binary_reverse[4] ^ data_binary_reverse[3] ^ lfsr_in[7] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[31];
    _lfsr_out[16]                   = data_binary_reverse[5] ^ data_binary_reverse[4] ^ data_binary_reverse[0] ^ lfsr_in[8] ^ lfsr_in[24] ^ lfsr_in[28] ^ lfsr_in[29];
    _lfsr_out[17]                   = data_binary_reverse[6] ^ data_binary_reverse[5] ^ data_binary_reverse[1] ^ lfsr_in[9] ^ lfsr_in[25] ^ lfsr_in[29] ^ lfsr_in[30];
    _lfsr_out[18]                   = data_binary_reverse[7] ^ data_binary_reverse[6] ^ data_binary_reverse[2] ^ lfsr_in[10] ^ lfsr_in[26] ^ lfsr_in[30] ^ lfsr_in[31];
    _lfsr_out[19]                   = data_binary_reverse[7] ^ data_binary_reverse[3] ^ lfsr_in[11] ^ lfsr_in[27] ^ lfsr_in[31];
    _lfsr_out[20]                   = data_binary_reverse[4] ^ lfsr_in[12] ^ lfsr_in[28];
    _lfsr_out[21]                   = data_binary_reverse[5] ^ lfsr_in[13] ^ lfsr_in[29];
    _lfsr_out[22]                   = data_binary_reverse[0] ^ lfsr_in[14] ^ lfsr_in[24];
    _lfsr_out[23]                   = data_binary_reverse[6] ^ data_binary_reverse[1] ^ data_binary_reverse[0] ^ lfsr_in[15] ^ lfsr_in[24] ^ lfsr_in[25] ^ lfsr_in[30];
    _lfsr_out[24]                   = data_binary_reverse[7] ^ data_binary_reverse[2] ^ data_binary_reverse[1] ^ lfsr_in[16] ^ lfsr_in[25] ^ lfsr_in[26] ^ lfsr_in[31];
    _lfsr_out[25]                   = data_binary_reverse[3] ^ data_binary_reverse[2] ^ lfsr_in[17] ^ lfsr_in[26] ^ lfsr_in[27];
    _lfsr_out[26]                   = data_binary_reverse[6] ^ data_binary_reverse[4] ^ data_binary_reverse[3] ^ data_binary_reverse[0] ^ lfsr_in[18] ^ lfsr_in[24] ^ lfsr_in[27] ^ lfsr_in[28] ^ lfsr_in[30];
    _lfsr_out[27]                   = data_binary_reverse[7] ^ data_binary_reverse[5] ^ data_binary_reverse[4] ^ data_binary_reverse[1] ^ lfsr_in[19] ^ lfsr_in[25] ^ lfsr_in[28] ^ lfsr_in[29] ^ lfsr_in[31];
    _lfsr_out[28]                   = data_binary_reverse[6] ^ data_binary_reverse[5] ^ data_binary_reverse[2] ^ lfsr_in[20] ^ lfsr_in[26] ^ lfsr_in[29] ^ lfsr_in[30];
    _lfsr_out[29]                   = data_binary_reverse[7] ^ data_binary_reverse[6] ^ data_binary_reverse[3] ^ lfsr_in[21] ^ lfsr_in[27] ^ lfsr_in[30] ^ lfsr_in[31];
    _lfsr_out[30]                   = data_binary_reverse[7] ^ data_binary_reverse[4] ^ lfsr_in[22] ^ lfsr_in[28] ^ lfsr_in[31];
    _lfsr_out[31]                   = data_binary_reverse[5] ^ lfsr_in[23] ^ lfsr_in[29];

    case (state)
        S_IDLE: begin
            _lfsr_in    = '1;
            _counter    = 3;

            if (data_enable) begin
                _state      =   S_COMPUTE;
                _lfsr_in    =   lfsr_out;
            end
        end
        S_COMPUTE: begin
            if (data_enable) begin
                _lfsr_in         =  lfsr_out;
                _checksum_result =  lfsr_out_xor_binary_reverse;
            end
            else begin
                _state                       =  S_FINISH;
                _lfsr_out_xor_binary_reverse =  {8'h00,lfsr_out_xor_binary_reverse[31:8]};
                _checksum                    =  lfsr_out_xor_binary_reverse[7:0];
                _checksum_valid              =  1;
            end
        end
        S_FINISH: begin
            _counter                     = counter - 1;
            _checksum                    = lfsr_out_xor_binary_reverse[7:0];
            _checksum_valid              = 1;

            if (counter == 0) begin
                _state  = S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        checksum_result             <= 0;
        checksum                    <= 0;
        checksum_valid              <= 0;
        data_binary_reverse         <= 0;
        lfsr_out                    <= 0;
        lfsr_out_xor                <= 0;
        lfsr_out_xor_binary_reverse <= 0;
        counter                     <= 0;
        lfsr_in                     <= '1;
    end
    else begin
        state                       <= _state;
        checksum_result             <= _checksum_result;
        checksum                    <= _checksum;
        checksum_valid              <= _checksum_valid;
        data_binary_reverse         <= _data_binary_reverse;
        lfsr_out                    <= _lfsr_out;
        lfsr_out_xor                <= _lfsr_out_xor;
        lfsr_out_xor_binary_reverse <= _lfsr_out_xor_binary_reverse;
        counter                     <= _counter;
        lfsr_in                     <= _lfsr_in;
    end
end


endmodule