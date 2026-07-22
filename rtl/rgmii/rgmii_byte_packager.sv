`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
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
module rgmii_byte_packager#(
    parameter TECHNOLOGY    = "SIMULATION"
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [3:0]   data,
    input   wire            data_control,

    output  reg     [8:0]   packaged_data,
    output  reg             packaged_data_valid,
    output  reg             packaged_data_last,
    output  reg     [1:0]   speed_code
);


wire            data_ddr_input_buffer_clock;
wire            data_ddr_input_buffer_reset_n;
wire    [3:0]   data_ddr_input_buffer_ddr_input;

wire    [7:0]   data_ddr_input_buffer_ddr_output;


ddr_input_buffer#(
  .INPUT_WIDTH      (4),
  .TECHNOLOGY       (TECHNOLOGY)
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
  .INPUT_WIDTH      (1),
  .TECHNOLOGY       (TECHNOLOGY)
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
reg     [8:0]   byte_stage_data;
reg             byte_stage_valid;
reg     [8:0]   held_data;
logic   [8:0]   _held_data;
reg             held_valid;
logic           _held_valid;
reg             held_last;
logic           _held_last;
logic   [8:0]   _packaged_data;
logic           _packaged_data_valid;
logic           _packaged_data_last;
logic           frame_end;
reg     [7:0]   counter;
logic   [7:0]   _counter;
reg     [7:0]   sample_counter;
logic   [7:0]   _sample_counter;
logic   [8:0]   _byte_stage_data;
logic           _byte_stage_valid;
reg     [7:0]   data_delayed;
logic   [7:0]   _data_delayed;
reg             data_enable_delayed;
logic           _data_enable_delayed;
reg             data_error_delayed;
logic           _data_error_delayed;
logic           _is_first_byte;
reg             is_first_byte;
logic   [1:0]   _speed_code;

assign  data_ddr_input_buffer_clock                 = clock;
assign  data_ddr_input_buffer_reset_n               = reset_n;
assign  data_ddr_input_buffer_ddr_input             = data;

assign  data_control_ddr_input_buffer_clock         = clock;
assign  data_control_ddr_input_buffer_reset_n       = reset_n;
assign  data_control_ddr_input_buffer_ddr_input     = data_control;

always_comb  begin
    _state                  = state;
    _counter                = counter;
    _sample_counter         = sample_counter;
    _byte_stage_data          = byte_stage_data;
    _data_enable_delayed    = data_control_ddr_input_buffer_ddr_output[0];
    _data_error_delayed     = data_control_ddr_input_buffer_ddr_output[1];
    _data_delayed           = data_ddr_input_buffer_ddr_output;
    _is_first_byte          = is_first_byte;
    _byte_stage_data[8]       = is_first_byte;
    _speed_code             = speed_code;
    _byte_stage_valid    = 0;

    case (state)
        S_SYNC: begin
            _counter        = 0;
            _is_first_byte  = 1;

            if (data_enable_delayed) begin
                if (data_delayed == 8'h55) begin
                    _state   = S_PREMABLE;
                end
            end
        end
        S_PREMABLE: begin
            _state = S_SYNC;

            if (data_enable_delayed) begin
                if (data_delayed == 8'h55) begin
                    _state      = S_PREMABLE;
                    _counter    = counter + 1;
                    
                    if (counter == 5) begin
                        _state = S_START_OF_FRAME;
                    end
                end
            end
        end
        S_START_OF_FRAME: begin
            _state = S_SYNC;

            if (data_enable_delayed) begin
                if (data_delayed == 8'hD5) begin
                    _state  = S_PACK;
                end
            end
        end
        S_PACK: begin
            _state = S_SYNC;

            if (data_enable_delayed) begin
                _state  = S_PACK;
                
                if (is_first_byte) begin
                    _is_first_byte = 0;
                end

                _byte_stage_data[7:0]     = data_delayed;
                _byte_stage_valid    = 1;
            end
        end
    endcase
end

//one byte lookahead so the final byte of a frame is emitted with
//packaged_data_last already asserted. the frame ends when the pack state
//loses data enable, which at 10 megabit lands one cycle after the final
//byte completes, hence the held register instead of a direct decode
always_comb begin
    _held_data              = held_data;
    _held_valid             = held_valid;
    _held_last              = held_last;
    _packaged_data          = packaged_data;
    _packaged_data_valid    = 0;
    _packaged_data_last     = 0;
    frame_end               = (state == S_PACK) && !data_enable_delayed;

    if (held_valid && held_last) begin
        _packaged_data          = held_data;
        _packaged_data_valid    = 1;
        _packaged_data_last     = 1;
        _held_valid             = 0;
        _held_last              = 0;
    end
    else if (byte_stage_valid) begin
        if (held_valid) begin
            _packaged_data          = held_data;
            _packaged_data_valid    = 1;
        end
        _held_data  = byte_stage_data;
        _held_valid = 1;
        _held_last  = frame_end;
    end
    else if (frame_end && held_valid) begin
        _packaged_data          = held_data;
        _packaged_data_valid    = 1;
        _packaged_data_last     = 1;
        _held_valid             = 0;
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state               <=  S_SYNC;
        counter             <=  '0;
        sample_counter      <=  '0;
        byte_stage_data     <=  '0;
        byte_stage_valid    <=  '0;
        held_data           <=  '0;
        held_valid          <=  '0;
        held_last           <=  '0;
        packaged_data       <=  '0;
        packaged_data_valid <=  '0;
        packaged_data_last  <=  '0;
        data_enable_delayed <=  '0;
        data_delayed        <=  '0;
        data_error_delayed  <=  '0;
        is_first_byte       <=  '0;
        speed_code          <=  '0;
    end
    else begin
        state               <=  _state;
        counter             <=  _counter;
        sample_counter      <=  _sample_counter;
        byte_stage_data     <=  _byte_stage_data;
        byte_stage_valid    <=  _byte_stage_valid;
        held_data           <=  _held_data;
        held_valid          <=  _held_valid;
        held_last           <=  _held_last;
        packaged_data       <=  _packaged_data;
        packaged_data_valid <=  _packaged_data_valid;
        packaged_data_last  <=  _packaged_data_last;
        data_enable_delayed <=  _data_enable_delayed;
        data_delayed        <=  _data_delayed;
        data_error_delayed  <=  _data_error_delayed;
        is_first_byte       <=  _is_first_byte;
        speed_code          <=  _speed_code;
    end
end

endmodule