`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
// 
// Create Date: 05/05/2023
// Design Name: 
// Module Name: rgmii_byte_packager
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
module rgmii_byte_packager#(
    parameter logic [1:0]   SPEED_CODE_GIGABIT      = 2,
    parameter logic [1:0]   SPEED_CODE_100_MEGABIT  = 1,
    parameter logic [1:0]   SPEED_CODE_10_MEGABIT   = 0
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [7:0]   data,
    input   wire            data_enable,
    input   wire            data_error,

    output  reg     [8:0]   packaged_data,
    output  reg             packaged_data_valid,
    output  reg     [1:0]   speed_code
);


typedef enum
{
    S_SYNC,
    S_SPEED_CHECK
} state_type;

state_type      state;
state_type      _state;
reg     [7:0]   counter;
logic   [7:0]   _counter;
reg     [7:0]   sample_counter;
logic   [7:0]   _sample_counter;
logic   [8:0]   _packaged_data;
logic           _packaged_data_valid;
reg     [7:0]   data_delayed;
logic   [7:0]   _data_delayed;
reg             data_enable_delayed;
logic           _data_enable_delayed;
reg             data_error_delayed;
logic           _data_error_delayed;
logic           _is_first_byte;
reg             is_first_byte;
logic   [1:0]   _speed_code;


always_comb  begin
    _state                  =   state;
    _counter                =   counter;
    _sample_counter         =   sample_counter;
    _packaged_data          =   packaged_data;
    _data_enable_delayed    =   data_enable;
    _data_error_delayed     =   data_error_delayed;
    _data_delayed           =   data;
    _is_first_byte          =   is_first_byte;
    _packaged_data[8]       =   is_first_byte;
    _speed_code             =   speed_code;
    _packaged_data_valid    =   0;

    case (state)
        S_SYNC: begin
            _is_first_byte   =   1;

            if (data_enable_delayed && !data_error_delayed) begin
                if (data_delayed == 8'h55) begin
                    if (counter == 7) begin
                        _state      =   S_SPEED_CHECK;
                        _counter    =   0;
                    end
                    else begin
                        _counter    =   counter + 1;
                    end
                end
                else begin
                    _counter    =   0;
                end
            end
            else  begin
                _counter    =   0;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state               <=  S_SYNC;
        counter             <=  0;
        sample_counter      <=  0;
        packaged_data       <=  0;
        packaged_data_valid <=  0;
        data_enable_delayed <=  0;
        data_delayed        <=  0;
        data_error_delayed  <=  0;
        is_first_byte       <=  0;
        speed_code          <=  SPEED_CODE_100_MEGABIT;
    end
    else begin
        state               <=  _state;
        counter             <=  _counter;
        sample_counter      <=  _sample_counter;
        packaged_data       <=  _packaged_data;
        packaged_data_valid <=  _packaged_data_valid;
        data_enable_delayed <=  _data_enable_delayed;
        data_delayed        <=  _data_delayed;
        data_error_delayed  <=  _data_error_delayed;
        is_first_byte       <=  _is_first_byte;
        speed_code          <=  _speed_code;
    end
end

endmodule