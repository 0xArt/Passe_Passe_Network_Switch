`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 04/22/2023 07:07:33 PM
// Design Name: 
// Module Name: rmii_byte_packager
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
    parameter XILINX    = 0
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [3:0]   data,
    input   wire            data_control,

    output  reg     [8:0]   packaged_data,
    output  reg             packaged_data_valid,
    output  reg     [1:0]   speed_code
);


wire            data_ddr_input_buffer_clock;
wire            data_ddr_input_buffer_reset_n;
wire    [3:0]   data_ddr_input_buffer_ddr_input;

wire    [7:0]   data_ddr_input_buffer_ddr_output;


ddr_input_buffer#(
  .INPUT_WIDTH              (4),
  .XILINX                   (XILINX)
)data_ddr_input_buffer(
    .clock          (data_ddr_input_buffer_clock),
    .reset_n        (data_ddr_input_buffer_reset_n),
    .ddr_input      (data_ddr_input_buffer_ddr_input),

    .ddr_output     (data_ddr_input_buffer_ddr_output)
);


wire            data_control_ddr_input_buffer_clock;
wire            data_control_ddr_input_buffer_reset_n;
wire            data_control_ddr_input_buffer_ddr_input;

wire    [1:0]   data_control_ddr_input_buffer_ddr_output;

ddr_input_buffer#(
  .INPUT_WIDTH              (1),
  .XILINX                   (XILINX)
)data_control_ddr_input_buffer(
    .clock          (data_control_ddr_input_buffer_clock),
    .reset_n        (data_control_ddr_input_buffer_reset_n),
    .ddr_input      (data_control_ddr_input_buffer_ddr_input),

    .ddr_output     (data_control_ddr_input_buffer_ddr_output)
);


typedef enum
{
    S_SYNC,
    S_PREMABLE,
    S_START_OF_FRAME,
    S_PACK
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


assign  data_ddr_input_buffer_clock                 =   clock;
assign  data_ddr_input_buffer_reset_n               =   reset_n;
assign  data_ddr_input_buffer_ddr_input             =   data;

assign  data_control_ddr_input_buffer_clock         =   clock;
assign  data_control_ddr_input_buffer_reset_n       =   reset_n;
assign  data_control_ddr_input_buffer_ddr_input     =   data_control;

always_comb  begin
    _state                  =   state;
    _counter                =   counter;
    _sample_counter         =   sample_counter;
    _packaged_data          =   packaged_data;
    _data_enable_delayed    =   data_control_ddr_input_buffer_ddr_output[0];
    _data_error_delayed     =   data_control_ddr_input_buffer_ddr_output[1];
    _data_delayed           =   data_ddr_input_buffer_ddr_output;
    _is_first_byte          =   is_first_byte;
    _packaged_data[8]       =   is_first_byte;
    _speed_code             =   speed_code;
    _packaged_data_valid    =   0;

    case (state)
        S_SYNC: begin
            if (data_enable_delayed) begin
                if (data_delayed == 8'h55) begin
                    _counter = 1;
                    _state   = S_PREMABLE;
                end
            end
        end
        S_PREMABLE: begin
            if (data_enable_delayed) begin
                if (data_delayed == 8'h55) begin
                    _counter = counter + 1;
                    
                    if (counter == 6) begin
                        _state = S_START_OF_FRAME;
                    end
                end
                else begin
                    _state = S_SYNC;
                end
            end
            else begin
                _state = S_SYNC;
            end
        end
        S_START_OF_FRAME: begin
            _counter = 0;

            if (data_enable_delayed) begin
                if (data_delayed == 8'hD5) begin

                    _state          = S_PACK;
                    _is_first_byte  = 1;
                end
                else begin
                    _state = S_SYNC;
                end
            end
            else begin
                _state = S_SYNC;
            end
        end
        S_PACK: begin
            if (data_enable_delayed) begin
                if (is_first_byte) begin
                    _is_first_byte = 0;
                end

                _packaged_data[7:0]     = data_delayed;
                _packaged_data_valid    = 1;
            end
            else begin
                _state = S_SYNC;
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
        speed_code          <=  0;
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