`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
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
// 
//////////////////////////////////////////////////////////////////////////////////
module generic_asynchronous_fifo#(
    parameter DATA_WIDTH                = 16,
    parameter DATA_DEPTH                = 4096,
    parameter FIRST_WORD_FALL_THROUGH   = 0,
    parameter PIPELINED_MEMORY          = "FALSE"
)(
    input   wire                            read_clock,
    input   wire                            read_reset_n,
    input   wire                            write_clock,
    input   wire                            write_reset_n,
    input   wire                            read_enable,
    input   wire                            write_enable,
    input   wire    [DATA_WIDTH-1:0]        write_data,

    output  reg     [DATA_WIDTH-1:0]        read_data,
    output  reg                             read_data_valid,
    output  reg                             full,
    output  reg                             empty
);


wire                            generic_dual_port_ram_write_clock;
wire                            generic_dual_port_ram_read_clock;
wire                            generic_dual_port_ram_read_reset_n;
wire                            generic_dual_port_ram_write_reset_n;
wire                            generic_dual_port_ram_write_enable;
wire [DATA_WIDTH-1:0]           generic_dual_port_ram_write_data;
wire [$clog2(DATA_DEPTH)-1:0]   generic_dual_port_ram_write_address;
wire [$clog2(DATA_DEPTH)-1:0]   generic_dual_port_ram_read_address;
wire [DATA_WIDTH-1:0]           generic_dual_port_ram_read_data;

generic_dual_port_ram
#(.DATA_WIDTH       (DATA_WIDTH),
  .DATA_DEPTH       (DATA_DEPTH),
  .PIPELINED_OUTPUT (PIPELINED_MEMORY)
)
generic_dual_port_ram(
    .write_clock    (generic_dual_port_ram_write_clock),
    .read_clock     (generic_dual_port_ram_read_clock),
    .read_reset_n   (generic_dual_port_ram_read_reset_n),
    .write_reset_n  (generic_dual_port_ram_write_reset_n),
    .write_enable   (generic_dual_port_ram_write_enable),
    .write_data     (generic_dual_port_ram_write_data),
    .write_address  (generic_dual_port_ram_write_address),
    .read_address   (generic_dual_port_ram_read_address),
    .read_data      (generic_dual_port_ram_read_data)
);


wire                            asynchronous_fifo_read_controller_clock;
wire                            asynchronous_fifo_read_controller_reset_n;
wire                            asynchronous_fifo_read_controller_read_enable;
wire [$clog2(DATA_DEPTH)-1:0]   asynchronous_fifo_read_controller_write_pointer_gray;
wire [DATA_WIDTH-1:0]           asynchronous_fifo_read_controller_memory_read_data;
wire [DATA_WIDTH-1:0]           asynchronous_fifo_read_controller_read_data;
wire                            asynchronous_fifo_read_controller_read_data_valid;
wire [$clog2(DATA_DEPTH)-1:0]   asynchronous_fifo_read_controller_memory_read_address;
wire [$clog2(DATA_DEPTH)-1:0]   asynchronous_fifo_read_controller_read_pointer_gray;
wire                            asynchronous_fifo_read_controller_empty;

asynchronous_fifo_read_controller
#(.DATA_WIDTH               (DATA_WIDTH),
  .DATA_DEPTH               (DATA_DEPTH),
  .FIRST_WORD_FALL_THROUGH  (FIRST_WORD_FALL_THROUGH),
  .PIPELINED_MEMORY         (PIPELINED_MEMORY)
)
asynchronous_fifo_read_controller(
    .clock                  (asynchronous_fifo_read_controller_clock),
    .reset_n                (asynchronous_fifo_read_controller_reset_n),
    .read_enable            (asynchronous_fifo_read_controller_read_enable),
    .write_pointer_gray     (asynchronous_fifo_read_controller_write_pointer_gray),
    .memory_read_data       (asynchronous_fifo_read_controller_memory_read_data),

    .read_data              (asynchronous_fifo_read_controller_read_data),
    .read_data_valid        (asynchronous_fifo_read_controller_read_data_valid),
    .memory_read_address    (asynchronous_fifo_read_controller_memory_read_address),
    .read_pointer_gray      (asynchronous_fifo_read_controller_read_pointer_gray),
    .empty                  (asynchronous_fifo_read_controller_empty)
);


wire                            asynchronous_fifo_write_controller_clock;
wire                            asynchronous_fifo_write_controller_reset_n;
wire                            asynchronous_fifo_write_controller_write_enable;
wire [$clog2(DATA_DEPTH)-1:0]   asynchronous_fifo_write_controller_read_pointer_gray;
wire [DATA_WIDTH-1:0]           asynchronous_fifo_write_controller_write_data;
wire [DATA_WIDTH-1:0]           asynchronous_fifo_write_controller_memory_write_data;
wire                            asynchronous_fifo_write_controller_memory_write_data_valid;
wire [$clog2(DATA_DEPTH)-1:0]   asynchronous_fifo_write_controller_memory_write_address;
wire [$clog2(DATA_DEPTH)-1:0]   asynchronous_fifo_write_controller_memory_write_pointer_gray;
wire                            asynchronous_fifo_write_controller_full;

asynchronous_fifo_write_controller
#(.DATA_WIDTH       (DATA_WIDTH),
  .DATA_DEPTH       (DATA_DEPTH)
)
asynchronous_fifo_write_controller(
    .clock                      (asynchronous_fifo_write_controller_clock),
    .reset_n                    (asynchronous_fifo_write_controller_reset_n),
    .write_enable               (asynchronous_fifo_write_controller_write_enable),
    .read_pointer_gray          (asynchronous_fifo_write_controller_read_pointer_gray),
    .write_data                 (asynchronous_fifo_write_controller_write_data),

    .memory_write_data          (asynchronous_fifo_write_controller_memory_write_data),
    .memory_write_data_valid    (asynchronous_fifo_write_controller_memory_write_data_valid),
    .memory_write_address       (asynchronous_fifo_write_controller_memory_write_address),
    .write_pointer_gray         (asynchronous_fifo_write_controller_memory_write_pointer_gray),
    .full                       (asynchronous_fifo_write_controller_full)
);


assign read_data                                            =   asynchronous_fifo_read_controller_read_data;
assign read_data_valid                                      =   asynchronous_fifo_read_controller_read_data_valid;
assign empty                                                =   asynchronous_fifo_read_controller_empty;
assign full                                                 =   asynchronous_fifo_write_controller_full;

assign generic_dual_port_ram_write_clock                    =   write_clock;
assign generic_dual_port_ram_write_reset_n                  =   write_reset_n;
assign generic_dual_port_ram_read_clock                     =   read_clock;
assign generic_dual_port_ram_read_reset_n                   =   read_reset_n;
assign generic_dual_port_ram_write_enable                   =   asynchronous_fifo_write_controller_memory_write_data_valid;
assign generic_dual_port_ram_write_data                     =   asynchronous_fifo_write_controller_memory_write_data;
assign generic_dual_port_ram_write_address                  =   asynchronous_fifo_write_controller_memory_write_address;
assign generic_dual_port_ram_read_address                   =   asynchronous_fifo_read_controller_memory_read_address;

assign asynchronous_fifo_read_controller_clock              =   read_clock;
assign asynchronous_fifo_read_controller_reset_n            =   read_reset_n;
assign asynchronous_fifo_read_controller_read_enable        =   read_enable;
assign asynchronous_fifo_read_controller_write_pointer_gray =   asynchronous_fifo_write_controller_memory_write_pointer_gray;
assign asynchronous_fifo_read_controller_memory_read_data   =   generic_dual_port_ram_read_data;

assign asynchronous_fifo_write_controller_clock             =   write_clock;
assign asynchronous_fifo_write_controller_reset_n           =   write_reset_n;
assign asynchronous_fifo_write_controller_write_data        =   write_data;
assign asynchronous_fifo_write_controller_write_enable      =   write_enable;
assign asynchronous_fifo_write_controller_read_pointer_gray =   asynchronous_fifo_read_controller_read_pointer_gray;

endmodule