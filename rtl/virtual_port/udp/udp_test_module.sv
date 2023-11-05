`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 11/02/2023
// Design Name: 
// Module Name: udp_test_module
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
module udp_test_module#(
    parameter logic [15:0]  UDP_SOURCE   = 16'h8888,
    parameter               XILINX       = 0
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire                            enable,
    input   wire    [8:0]                   data,
    input   wire                            data_enable,
    input   wire                            packet_data_enable,
    input   wire    [47:0]                  mac_destination,
    input   wire    [31:0]                  ipv4_destination,
    input   wire    [15:0]                  udp_destination,

    output  wire    [8:0]                   packet_data,
    output  wire                            packet_data_valid
);


wire            transmit_fifo_clock;
wire            transmit_fifo_reset_n;
wire    [8:0]   transmit_fifo_write_data;
wire            transmit_fifo_read_enable;
wire            transmit_fifo_write_enable;
wire            transmit_fifo_read_data_valid;
wire            transmit_fifo_empty;
wire            transmit_fifo_full;
wire    [8:0]   transmit_fifo_read_data;

synchronous_fifo
#(  .DATA_WIDTH                 (9),
    .DATA_DEPTH                 (1024),
    .FIRST_WORD_FALL_THROUGH    (1),
    .XILINX                     (XILINX)
) transmit_fifo(
    .clock              (transmit_fifo_clock),
    .reset_n            (transmit_fifo_reset_n),
    .read_enable        (transmit_fifo_read_enable),
    .write_enable       (transmit_fifo_write_enable),
    .write_data         (transmit_fifo_write_data),

    .read_data          (transmit_fifo_read_data),
    .read_data_valid    (transmit_fifo_read_data_valid),
    .full               (transmit_fifo_full),
    .empty              (transmit_fifo_empty)
);


logic   [7:0]   _byte_counter;
reg     [7:0]   byte_counter;
logic   [8:0]   _internal_packet_data;
reg     [8:0]   internal_packet_data;
logic           _internal_packet_data_valid;
reg             internal_packet_data_valid;


assign packet_data                  =   transmit_fifo_read_data;
assign packet_data_valid            =   transmit_fifo_read_data_valid;

assign transmit_fifo_clock          =   clock;
assign transmit_fifo_reset_n        =   reset_n;
assign transmit_fifo_read_enable    =   packet_data_enable && transmit_fifo_read_data_valid;
assign transmit_fifo_write_enable   =   internal_packet_data_valid;
assign transmit_fifo_write_data     =   internal_packet_data;


wire [8:0] transmit_que [0:23]  =   
{   
    {1'b1, mac_destination[47:40]}, {1'b0, mac_destination[39:32]}, {1'b0, mac_destination[31:24]},     {1'b0, mac_destination[23:16]}, 
    {1'b0, mac_destination[15:8]},  {1'b0, mac_destination[7:0]},   {1'b0, ipv4_destination[31:24]},    {1'b0, ipv4_destination[23:16]},
    {1'b0, ipv4_destination[15:8]}, {1'b0, ipv4_destination[7:0]},  {1'b0, 8'h00},                      {1'b0, 8'h08}, 
    {1'b0, UDP_SOURCE[15:8]},       {1'b0, UDP_SOURCE[7:0]},        {1'b0, udp_destination[15:8]},      {1'b0,udp_destination[7:0]},    
    {1'b0, 8'h00},                  {1'b0, 8'h01},                  {1'b0, 8'h02},                      {1'b0, 8'h03}, 
    {1'b0, 8'h04},                  {1'b0, 8'h05},                  {1'b0, 8'h06},                      {1'b0, 8'h07} 
};

always_comb begin
    _byte_counter               =   byte_counter;
    _internal_packet_data       =   internal_packet_data;
    _internal_packet_data_valid =   0;

    if (enable && packet_data_enable) begin
        _internal_packet_data       = transmit_que[byte_counter];
        _internal_packet_data_valid = 1;
        _byte_counter               = byte_counter + 1;
    end

    if (byte_counter != 0 && packet_data_enable) begin
        _internal_packet_data       = transmit_que[byte_counter];
        _internal_packet_data_valid = 1;
        _byte_counter               = byte_counter + 1;

        if (byte_counter == 23) begin
            _byte_counter   = 0;
        end
    end
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        byte_counter                <=  0;
        internal_packet_data        <=  0;
        internal_packet_data_valid  <=  0;
    end
    else begin
        byte_counter                <=  _byte_counter;
        internal_packet_data        <=  _internal_packet_data;
        internal_packet_data_valid  <=  _internal_packet_data_valid;
    end
end


endmodule