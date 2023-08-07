`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 05/07/2023
// Design Name: 
// Module Name: internet_checksum_calculator
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
module internet_checksum_calculator(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [7:0]                   data,
    input   wire                            data_enable,
    input   wire                            data_last,

    output  reg     [15:0]                  result,
    output  reg                             result_valid,
    output  reg                             ready
);


typedef enum
{
    S_IDLE,
    S_PACK_MSB,
    S_PACK_LSB,
    S_LAST_ACCUMULATE,
    S_PACK_PAD,
    S_FINISH
} state_type;

state_type          _state;
state_type          state;
logic   [15:0]      _result;
logic               _result_valid;
reg     [16:0]      accumulator;
logic   [16:0]      _accumulator;
logic   [15:0]      accumator_carry;
reg     [15:0]      packed_bytes;
logic   [15:0]      _packed_bytes;
logic               _ready;

always_comb begin
    _state          =   state;
    _packed_bytes   =   packed_bytes;
    _result         =   result;
    _accumulator    =   accumulator;
    _ready          =   ready;
    _result_valid   =   0;
    accumator_carry =   accumulator[15:0] + accumulator[16];

    case (state)
        S_IDLE: begin
            _ready  =   1;

            if (data_enable) begin
                _packed_bytes[15:8] = data;
                _state              = S_PACK_LSB;
            end
        end
        S_PACK_LSB: begin
            if (data_enable) begin
                _packed_bytes[7:0]  = data;

                if (data_last) begin
                    _state  =   S_LAST_ACCUMULATE;
                    _ready  =   0;
                end
                else begin
                    _state  =   S_PACK_MSB;
                end
            end
        end
        S_PACK_MSB: begin
            if (data_enable) begin
                _accumulator        =   accumator_carry + packed_bytes;
                _packed_bytes[15:8] =   data;

                if (data_last) begin
                    _state = S_PACK_PAD;
                    _ready = 0;
                end
                else begin
                    _state  = S_PACK_LSB;
                end
            end
        end
        S_PACK_PAD: begin
            _packed_bytes[7:0]  =   0;
            _state              =   S_LAST_ACCUMULATE;
        end
        S_LAST_ACCUMULATE: begin
            _accumulator    =   accumator_carry + packed_bytes;
            _state          =   S_FINISH;
        end
        S_FINISH: begin
            _result         =   accumator_carry;
            _result_valid   =   1;
            _state          =   S_IDLE;
        end
    endcase
end


always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        result                      <=  0;
        result_valid                <=  0;
        packed_bytes                <=  0;
        accumulator                 <=  0;
        ready                       <=  0;
    end
    else begin
        state                       <=  _state;
        result                      <=  _result;
        result_valid                <=  _result_valid;
        packed_bytes                <=  _packed_bytes;
        accumulator                 <=  _accumulator;
        ready                       <=  _ready;
    end
end

endmodule