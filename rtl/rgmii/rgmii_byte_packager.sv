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
    parameter TECHNOLOGY                    = "SIMULATION",
    parameter logic [1:0]   SPEED_CODE_1000_MEGABIT = 2,
    parameter logic [1:0]   SPEED_CODE_100_MEGABIT  = 1,
    parameter logic [1:0]   SPEED_CODE_10_MEGABIT   = 0
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
reg             byte_valid_delayed;
logic           _byte_valid_delayed;
reg             nibble_phase;
logic           _nibble_phase;
reg     [3:0]   low_nibble;
logic   [3:0]   _low_nibble;

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
    _data_delayed           = data_delayed;
    _is_first_byte          = is_first_byte;
    _byte_stage_data[8]       = is_first_byte;
    _speed_code             = speed_code;
    _byte_stage_valid    = 0;
    _byte_valid_delayed     = 0;
    _nibble_phase           = nibble_phase;
    _low_nibble             = low_nibble;

    //speed aware byte assembly. at gigabit the ddr buffer hands over a full
    //byte every clock. at 10 and 100 megabit the phy duplicates one nibble
    //across both edges, so a byte is assembled from two clocks, low nibble
    //first, and the byte strobe fires on the second
    if (speed_code == SPEED_CODE_1000_MEGABIT) begin
        _data_delayed       = data_ddr_input_buffer_ddr_output;
        _byte_valid_delayed = data_control_ddr_input_buffer_ddr_output[0];
        _nibble_phase       = 0;
    end
    else begin
        if (data_control_ddr_input_buffer_ddr_output[0]) begin
            if (!nibble_phase) begin
                _low_nibble     = data_ddr_input_buffer_ddr_output[3:0];
                _nibble_phase   = 1;
            end
            else begin
                _data_delayed       = {data_ddr_input_buffer_ddr_output[3:0], low_nibble};
                _byte_valid_delayed = 1;
                _nibble_phase       = 0;
            end
        end
        else begin
            _nibble_phase   = 0;
        end
    end

    //rgmii in band status: while receive control is low the phy drives link
    //status on the data lines, bit 0 link up and bits 2:1 the speed. the
    //code only updates on a link up status, so a testbench that idles the
    //lines at zero leaves the reset default of gigabit in place
    if (!data_control_ddr_input_buffer_ddr_output[0] && data_ddr_input_buffer_ddr_output[0]) begin
        case (data_ddr_input_buffer_ddr_output[2:1])
            2'b00:      _speed_code = SPEED_CODE_10_MEGABIT;
            2'b01:      _speed_code = SPEED_CODE_100_MEGABIT;
            default:    _speed_code = SPEED_CODE_1000_MEGABIT;
        endcase
    end

    case (state)
        S_SYNC: begin
            _counter        = 0;
            _is_first_byte  = 1;

            if (byte_valid_delayed) begin
                if (data_delayed == 8'h55) begin
                    _state   = S_PREMABLE;
                end
            end
        end
        S_PREMABLE: begin
            if (!data_enable_delayed) begin
                _state = S_SYNC;
            end
            else if (byte_valid_delayed) begin
                if (data_delayed == 8'h55) begin
                    _counter    = counter + 1;

                    if (counter == 5) begin
                        _state = S_START_OF_FRAME;
                    end
                end
                else begin
                    _state = S_SYNC;
                end
            end
        end
        S_START_OF_FRAME: begin
            if (!data_enable_delayed) begin
                _state = S_SYNC;
            end
            else if (byte_valid_delayed) begin
                if (data_delayed == 8'hD5) begin
                    _state  = S_PACK;
                end
                else begin
                    _state = S_SYNC;
                end
            end
        end
        S_PACK: begin
            if (!data_enable_delayed) begin
                _state = S_SYNC;
            end
            else if (byte_valid_delayed) begin
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
        byte_valid_delayed  <=  '0;
        nibble_phase        <=  '0;
        low_nibble          <=  '0;
        //gigabit until an in band status with the link up says otherwise
        speed_code          <=  SPEED_CODE_1000_MEGABIT;
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
        byte_valid_delayed  <=  _byte_valid_delayed;
        nibble_phase        <=  _nibble_phase;
        low_nibble          <=  _low_nibble;
        speed_code          <=  _speed_code;
    end
end

endmodule