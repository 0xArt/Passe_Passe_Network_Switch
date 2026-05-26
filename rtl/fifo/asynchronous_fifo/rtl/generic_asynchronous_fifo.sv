`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 05/28/2023
// Design Name: 
// Module Name: generic_asynchronous_fifo
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
// or incorporation into proprietary software is strictly prohibited without prior
// written permission and a valid commercial license from the original creator.
//
// Unauthorized commercial use violates intellectual property and copyright laws.
//
// For licensing inquiries and commercial permissions, contact the creator directly.
//
//////////////////////////////////////////////////////////////////////////////////
module generic_asynchronous_fifo#(
    parameter DATA_WIDTH                = 16,
    parameter DATA_DEPTH                = 4096,
    parameter FIRST_WORD_FALL_THROUGH   = 0
)(
    input   wire                            read_clock,
    input   wire                            read_reset_n,
    input   wire                            write_clock,
    input   wire                            write_reset_n,
    input   wire                            read_enable,
    input   wire                            write_enable,
    input   wire    [DATA_WIDTH-1:0]        write_data,

    output  reg     [DATA_WIDTH-1:0]        read_data,
    output  logic                           read_data_valid,
    output  wire                            full,
    output  wire                            almost_full,
    output  reg                             empty
);


wire                          asynchronous_fifo_write_pointer_clock;
wire                          asynchronous_fifo_write_pointer_reset_n;
wire                          asynchronous_fifo_write_pointer_enable;
wire [$clog2(DATA_DEPTH):0]   asynchronous_fifo_write_pointer_read_pointer;

wire                          asynchronous_fifo_write_pointer_full;
wire                          asynchronous_fifo_write_pointer_almost_full;
wire [$clog2(DATA_DEPTH)-1:0] asynchronous_fifo_write_pointer_address;
wire [$clog2(DATA_DEPTH):0]   asynchronous_fifo_write_pointer_write_pointer_gray;

asynchronous_fifo_write_pointer #(.ADDRESS_SIZE ($clog2(DATA_DEPTH)))
asynchronous_fifo_write_pointer(
  .clock                (asynchronous_fifo_write_pointer_clock),
  .reset_n              (asynchronous_fifo_write_pointer_reset_n),
  .enable               (asynchronous_fifo_write_pointer_enable),
  .read_pointer         (asynchronous_fifo_write_pointer_read_pointer),

  .full                 (asynchronous_fifo_write_pointer_full),
  .almost_full          (asynchronous_fifo_write_pointer_almost_full),
  .address              (asynchronous_fifo_write_pointer_address),
  .write_pointer_gray   (asynchronous_fifo_write_pointer_write_pointer_gray)
);


wire                          asynchronous_fifo_read_pointer_clock;
wire                          asynchronous_fifo_read_pointer_reset_n;
wire                          asynchronous_fifo_read_pointer_enable;
wire [$clog2(DATA_DEPTH):0]   asynchronous_fifo_read_pointer_write_pointer;

wire                          asynchronous_fifo_read_pointer_empty;
wire                          asynchronous_fifo_read_pointer_almost_empty;
wire [$clog2(DATA_DEPTH)-1:0] asynchronous_fifo_read_pointer_address;
wire [$clog2(DATA_DEPTH):0]   asynchronous_fifo_read_pointer_read_pointer_gray;

asynchronous_fifo_read_pointer  #(.ADDRESS_SIZE ($clog2(DATA_DEPTH)))
asynchronous_fifo_read_pointer(
  .clock                (asynchronous_fifo_read_pointer_clock),
  .reset_n              (asynchronous_fifo_read_pointer_reset_n),
  .enable               (asynchronous_fifo_read_pointer_enable),
  .write_pointer        (asynchronous_fifo_read_pointer_write_pointer),

  .empty                (asynchronous_fifo_read_pointer_empty),
  .almost_empty         (asynchronous_fifo_read_pointer_almost_empty),
  .address              (asynchronous_fifo_read_pointer_address),
  .read_pointer_gray    (asynchronous_fifo_read_pointer_read_pointer_gray)
);



wire                          variable_stage_synchronizer_write_pointer_clock;
wire                          variable_stage_synchronizer_write_pointer_reset_n;
wire [$clog2(DATA_DEPTH):0]   variable_stage_synchronizer_write_pointer_source_signal;

wire [$clog2(DATA_DEPTH):0]   variable_stage_synchronizer_write_pointer_destination_signal;
wire                          variable_stage_synchronizer_write_pointer_destination_signal_valid;

variable_stage_synchronizer #(.DATA_WIDTH ($clog2(DATA_DEPTH)+1))
variable_stage_synchronizer_write_pointer(
  .clock                      (variable_stage_synchronizer_write_pointer_clock),
  .reset_n                    (variable_stage_synchronizer_write_pointer_reset_n),
  .source_signal              (variable_stage_synchronizer_write_pointer_source_signal),
  
  .destination_signal         (variable_stage_synchronizer_write_pointer_destination_signal),
  .destination_signal_valid   (variable_stage_synchronizer_write_pointer_destination_signal_valid)
);


wire                          variable_stage_synchronizer_read_pointer_clock;
wire                          variable_stage_synchronizer_read_pointer_reset_n;
wire [$clog2(DATA_DEPTH):0]   variable_stage_synchronizer_read_pointer_source_signal;

wire [$clog2(DATA_DEPTH):0]   variable_stage_synchronizer_read_pointer_destination_signal;
wire                          variable_stage_synchronizer_read_pointer_destination_signal_valid;

variable_stage_synchronizer #(.DATA_WIDTH ($clog2(DATA_DEPTH)+1))
variable_stage_synchronizer_read_pointer(
  .clock                      (variable_stage_synchronizer_read_pointer_clock),
  .reset_n                    (variable_stage_synchronizer_read_pointer_reset_n),
  .source_signal              (variable_stage_synchronizer_read_pointer_source_signal),
  
  .destination_signal         (variable_stage_synchronizer_read_pointer_destination_signal),
  .destination_signal_valid   (variable_stage_synchronizer_read_pointer_destination_signal_valid)
);


wire                          generic_dual_port_ram_write_clock;
wire                          generic_dual_port_ram_read_clock;
wire                          generic_dual_port_ram_read_reset_n;
wire                          generic_dual_port_ram_write_reset_n;
wire                          generic_dual_port_ram_write_enable;
wire [DATA_WIDTH-1:0]         generic_dual_port_ram_write_data;
wire [$clog2(DATA_DEPTH)-1:0] generic_dual_port_ram_write_address;
wire [$clog2(DATA_DEPTH)-1:0] generic_dual_port_ram_read_address;

wire [DATA_WIDTH-1:0]         generic_dual_port_ram_read_data;

generic_dual_port_ram
#(.DATA_WIDTH       (DATA_WIDTH),
  .DATA_DEPTH       (DATA_DEPTH),
  .PIPELINED_OUTPUT (FIRST_WORD_FALL_THROUGH ? 0 : 1)
)
generic_dual_port_ram(
  .write_clock                (generic_dual_port_ram_write_clock),
  .read_clock                 (generic_dual_port_ram_read_clock),
  .read_reset_n               (generic_dual_port_ram_read_reset_n),
  .write_reset_n              (generic_dual_port_ram_write_reset_n),
  .write_enable               (generic_dual_port_ram_write_enable),
  .write_data                 (generic_dual_port_ram_write_data),
  .write_address              (generic_dual_port_ram_write_address),
  .read_address               (generic_dual_port_ram_read_address),

  .read_data                  (generic_dual_port_ram_read_data)
);


logic _memory_data_valid;
reg   memory_data_valid;

always_comb begin
  _memory_data_valid  = memory_data_valid;

  if (read_enable) begin
    _memory_data_valid  = !asynchronous_fifo_read_pointer_empty;
  end

  if (FIRST_WORD_FALL_THROUGH) begin
    read_data_valid = !asynchronous_fifo_read_pointer_empty;
  end
  else begin
    read_data_valid = memory_data_valid;
  end
end


always @ (posedge read_clock or negedge read_reset_n) begin
  if (!read_reset_n) begin
      memory_data_valid <= '0;
  end
  else begin
      memory_data_valid <= _memory_data_valid;
  end
end


assign read_data                                                = generic_dual_port_ram_read_data;
assign full                                                     = asynchronous_fifo_write_pointer_full;
assign almost_full                                              = asynchronous_fifo_write_pointer_almost_full;
assign empty                                                    = asynchronous_fifo_read_pointer_empty;

assign asynchronous_fifo_write_pointer_clock                    = write_clock;
assign asynchronous_fifo_write_pointer_reset_n                  = write_reset_n;
assign asynchronous_fifo_write_pointer_enable                   = write_enable;
assign asynchronous_fifo_write_pointer_read_pointer             = variable_stage_synchronizer_read_pointer_destination_signal;

assign asynchronous_fifo_read_pointer_clock                     = read_clock;
assign asynchronous_fifo_read_pointer_reset_n                   = read_reset_n;
assign asynchronous_fifo_read_pointer_enable                    = read_enable;
assign asynchronous_fifo_read_pointer_write_pointer             = variable_stage_synchronizer_write_pointer_destination_signal;

assign variable_stage_synchronizer_write_pointer_clock          = read_clock;
assign variable_stage_synchronizer_write_pointer_reset_n        = read_reset_n;
assign variable_stage_synchronizer_write_pointer_source_signal  = asynchronous_fifo_write_pointer_write_pointer_gray;

assign variable_stage_synchronizer_read_pointer_clock           = write_clock;
assign variable_stage_synchronizer_read_pointer_reset_n         = write_reset_n;
assign variable_stage_synchronizer_read_pointer_source_signal   = asynchronous_fifo_read_pointer_read_pointer_gray;

assign generic_dual_port_ram_write_clock                        = write_clock;
assign generic_dual_port_ram_read_clock                         = read_clock;
assign generic_dual_port_ram_read_reset_n                       = read_reset_n;
assign generic_dual_port_ram_write_reset_n                      = write_reset_n;
assign generic_dual_port_ram_write_enable                       = write_enable && !asynchronous_fifo_write_pointer_full;
assign generic_dual_port_ram_write_data                         = write_data;
assign generic_dual_port_ram_write_address                      = asynchronous_fifo_write_pointer_address;
assign generic_dual_port_ram_read_address                       = asynchronous_fifo_read_pointer_address;


endmodule