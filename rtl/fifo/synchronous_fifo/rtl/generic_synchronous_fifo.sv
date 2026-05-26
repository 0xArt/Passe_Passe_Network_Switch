`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 05/28/2023
// Design Name: 
// Module Name: generic_synchronous_fifo
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
module generic_synchronous_fifo#(
    parameter DATA_WIDTH                = 16,
    parameter DATA_DEPTH                = 4096,
    parameter FIRST_WORD_FALL_THROUGH   = 0
)(
    input   wire                              clock,
    input   wire                              reset_n,
    input   wire                              read_enable,
    input   wire                              write_enable,
    input   wire    [DATA_WIDTH-1:0]          write_data,

    output  reg     [$clog2(DATA_DEPTH)-1:0]  available_words,
    output  reg     [DATA_WIDTH-1:0]          read_data,
    output  logic                             read_data_valid,
    output  logic                             full,
    output  logic                             almost_full,
    output  logic                             empty
);


wire                          generic_block_ram_clock;
wire                          generic_block_ram_reset_n;
wire                          generic_block_ram_write_enable;
wire [DATA_WIDTH-1:0]         generic_block_ram_write_data;
wire [$clog2(DATA_DEPTH)-1:0] generic_block_ram_write_address;
wire [$clog2(DATA_DEPTH)-1:0] generic_block_ram_read_address;

wire [DATA_WIDTH-1:0]         generic_block_ram_read_data;

generic_block_ram
#(.DATA_WIDTH       (DATA_WIDTH),
  .DATA_DEPTH       (DATA_DEPTH),
  .PIPELINED_OUTPUT (FIRST_WORD_FALL_THROUGH ? 0 : 1)
)
generic_block_ram(
  .clock          (generic_block_ram_clock),
  .reset_n        (generic_block_ram_reset_n),
  .write_enable   (generic_block_ram_write_enable),
  .write_data     (generic_block_ram_write_data),
  .write_address  (generic_block_ram_write_address),
  .read_address   (generic_block_ram_read_address),

  .read_data      (generic_block_ram_read_data)
);


logic [$clog2(DATA_DEPTH):0]    _write_pointer;
logic [$clog2(DATA_DEPTH)-1:0]  _available_words;
logic [$clog2(DATA_DEPTH):0]    _read_pointer;
logic [$clog2(DATA_DEPTH):0]    read_pointer;
logic [$clog2(DATA_DEPTH):0]    write_pointer;
logic                           _memory_data_valid;
reg                             memory_data_valid;

always_comb begin
  _memory_data_valid  = memory_data_valid;
  _available_words    = available_words;

  if (available_words == 0) begin
    empty = 1;
  end
  else begin
    empty = 0;
  end

  if (available_words == DATA_DEPTH) begin
    full = 1;
  end
  else begin
    full = 0;
  end

  if (available_words == (DATA_DEPTH-1)) begin
    almost_full = 1;
  end
  else begin
    almost_full = 0;
  end

  if (!full && write_enable && !read_enable) begin
    _available_words  = available_words + 1;
  end

  if (!empty && read_enable && !write_enable) begin
    _available_words  = available_words - 1;
  end


  _write_pointer  = write_pointer + ((write_enable && !full) ? 1 : 0);
  _read_pointer   = read_pointer + ((read_enable && !empty) ? 1 : 0);


  if (read_enable) begin
    _memory_data_valid  = !empty;
  end

  if (FIRST_WORD_FALL_THROUGH) begin
    read_data_valid = !empty;
  end
  else begin
    read_data_valid = memory_data_valid;
  end
end


always @ (posedge clock or negedge reset_n) begin
  if (!reset_n) begin
      available_words   <= '0;
      write_pointer     <= '0;
      read_pointer      <= '0;
      memory_data_valid <= '0;
  end
  else begin
      available_words   <= _available_words;
      write_pointer     <= _write_pointer;
      read_pointer      <= _read_pointer;
      memory_data_valid <= _memory_data_valid;
  end
end


assign read_data                                    = generic_block_ram_read_data;

assign generic_block_ram_clock                      = clock;
assign generic_block_ram_reset_n                    = reset_n;
assign generic_block_ram_write_enable               = write_enable && !full;
assign generic_block_ram_write_data                 = write_data;
assign generic_block_ram_write_address              = write_pointer[$clog2(DATA_DEPTH)-1:0];
assign generic_block_ram_read_address               = read_pointer[$clog2(DATA_DEPTH)-1:0];


endmodule