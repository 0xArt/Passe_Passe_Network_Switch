`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 01/26/2024 07:07:33 PM
// Design Name: 
// Module Name: rgmii_byte_shipper
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
module rgmii_byte_shipper #(
    parameter TECHNOLOGY                = "SIMULATION",
    parameter INTER_PACKET_GAP_CYCLES   = 10 //enforced gap is this plus two byte times: 12 byte times, 96ns at gigabit
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [8:0]   data,
    input   wire            data_enable,
    //while asserted the enforced gap shrinks by one byte time so a backlog
    //behind a marginally slower transmit clock can drain. gate it on a fifo
    //fill watermark, never tie it high, so the wire only dips below the
    //802.3 minimum gap while the backlog is real
    input   wire            gap_shrink_enable,

    output  logic           data_ready,
    output  wire    [3:0]   shipped_data,
    output  wire            shipped_data_valid
);


wire            data_ddr_output_buffer_clock;
wire            data_ddr_output_buffer_reset_n;
wire    [7:0]   data_ddr_output_buffer_ddr_input;

wire    [3:0]   data_ddr_output_buffer_ddr_output;

ddr_output_buffer#(
  .OUTPUT_WIDTH     (4),
  .TECHNOLOGY       (TECHNOLOGY)
)data_ddr_output_buffer(
    .clock          (data_ddr_output_buffer_clock),
    .reset_n        (data_ddr_output_buffer_reset_n),
    .ddr_input      (data_ddr_output_buffer_ddr_input),

    .ddr_output     (data_ddr_output_buffer_ddr_output)
);


wire            data_valid_ddr_output_buffer_clock;
wire            data_valid_ddr_output_buffer_reset_n;
wire    [1:0]   data_valid_ddr_output_buffer_ddr_input;

wire            data_valid__ddr_output_buffer_ddr_output;

ddr_output_buffer#(
  .OUTPUT_WIDTH     (1),
  .TECHNOLOGY       (TECHNOLOGY)
)data_valid_ddr_output_buffer(
    .clock          (data_valid_ddr_output_buffer_clock),
    .reset_n        (data_valid_ddr_output_buffer_reset_n),
    .ddr_input      (data_valid_ddr_output_buffer_ddr_input),

    .ddr_output     (data_valid__ddr_output_buffer_ddr_output)
);

typedef enum
{
    S_FIND_START_BIT,
    S_PREMABLE,
    S_START_OF_FRAME,
    S_FRAME,
    S_GAP
} state_type;

state_type      state;
state_type      _state;
reg     [7:0]   counter;
logic   [7:0]   _counter;
reg     [7:0]   frame_data;
logic   [7:0]   _frame_data;
reg             frame_data_valid;
logic           _frame_data_valid;
reg             first_byte;
logic           _first_byte;


assign  data_ddr_output_buffer_clock                = clock;
assign  data_ddr_output_buffer_reset_n              = reset_n;
assign  data_ddr_output_buffer_ddr_input            = frame_data;

assign  data_valid_ddr_output_buffer_clock          = clock;
assign  data_valid_ddr_output_buffer_reset_n        = reset_n;
assign  data_valid_ddr_output_buffer_ddr_input      = {frame_data_valid,frame_data_valid};

assign  shipped_data                                = data_ddr_output_buffer_ddr_output;
assign  shipped_data_valid                          = data_valid__ddr_output_buffer_ddr_output;


always_comb  begin
    _state                          = state;
    _counter                        = counter;
    _first_byte                     = first_byte;
    _frame_data                     = frame_data;
    _frame_data_valid               = 0;
    data_ready                      = 0;

    case (state)
        S_FIND_START_BIT: begin
            _counter    = 6;
            _first_byte = 1;
            data_ready  = 1;
            _frame_data = 8'hDD;

            if (data_enable) begin
                if (data[8]) begin
                    data_ready  = 0;
                    _state      = S_PREMABLE;
                end
            end
        end
        S_PREMABLE: begin
            _frame_data         = 8'h55;
            _frame_data_valid   = 1;
            _counter            = counter - 1;

            if (counter == 0) begin
                _state  = S_START_OF_FRAME;
            end
        end
        S_START_OF_FRAME: begin
            _counter            = INTER_PACKET_GAP_CYCLES;
            _frame_data         = 8'hD5;
            _frame_data_valid   = 1;
            _state              = S_FRAME;
        end
        S_FRAME: begin
            if (data_enable) begin
                if (data[8] && !first_byte) begin
                    _state = S_GAP;
                end
                else begin
                    _first_byte         = 0;
                    _frame_data         = data[7:0];
                    _frame_data_valid   = 1;
                    data_ready          = 1;
                end
            end
            else begin
                _state  = S_GAP;
            end
        end
        S_GAP: begin
            _frame_data = 8'hDD;
            _counter    = counter - 1;

            if ((counter == 0) || (counter == 1 && gap_shrink_enable && data_enable && data[8])) begin
                if (data_enable && data[8]) begin
                    //the next frame is already waiting. start its preamble
                    //directly so a backlogged stream repeats at exactly the
                    //enforced gap, otherwise the find start cycle makes the
                    //drain period one byte time longer than the ingress
                    //minimum and a long saturating stream slowly fills every
                    //fifo upstream
                    _counter    = 6;
                    _first_byte = 1;
                    _state      = S_PREMABLE;
                end
                else begin
                    _state  = S_FIND_START_BIT;
                end
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_FIND_START_BIT;
        counter                     <= 0;
        frame_data                  <= 0;
        frame_data_valid            <= 0;
        first_byte                  <= 0;
    end
    else begin
        state                       <= _state;
        counter                     <= _counter;
        frame_data                  <= _frame_data;
        frame_data_valid            <= _frame_data_valid;
        first_byte                  <= _first_byte;
    end
end

endmodule