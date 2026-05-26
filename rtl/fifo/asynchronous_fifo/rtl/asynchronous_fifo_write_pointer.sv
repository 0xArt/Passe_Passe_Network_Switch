`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 11/28/2026
// Design Name: 
// Module Name: asynchronous_fifo_write_pointer
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
module asynchronous_fifo_write_pointer#(
    parameter ADDRESS_SIZE = 4
)(
    input  wire                     clock,
    input  wire                     reset_n,
    input  wire                     enable,
    input  wire [ADDRESS_SIZE:0]    read_pointer,

    output reg                      full,
    output reg                      almost_full,
    output reg [ADDRESS_SIZE-1:0]   address,
    output reg [ADDRESS_SIZE:0]     write_pointer_gray
);

logic [ADDRESS_SIZE:0]  write_pointer_binary;
logic [ADDRESS_SIZE:0]  _write_pointer_binary;
logic [ADDRESS_SIZE:0]  write_pointer_gray_next;
logic [ADDRESS_SIZE:0]  _write_pointer_gray;
logic [ADDRESS_SIZE:0]  write_pointer_binary_next;
logic [ADDRESS_SIZE:0]  write_pointer_gray_next_next;
logic                   _almost_full;
logic                   _full;


always_comb begin
    address                         = write_pointer_binary[ADDRESS_SIZE-1:0];
    write_pointer_binary_next       = write_pointer_binary + ((enable && !full) ? 1 : 0);
    write_pointer_gray_next         = (write_pointer_binary_next >> 1) ^ write_pointer_binary_next;
    write_pointer_gray_next_next    = ((write_pointer_binary_next + 1'b1) >> 1) ^ (write_pointer_binary_next + 1'b1);
    _full                           = (write_pointer_gray_next == {~read_pointer[ADDRESS_SIZE:ADDRESS_SIZE-1],read_pointer[ADDRESS_SIZE-2:0]});
    _almost_full                    = (write_pointer_gray_next_next == {~read_pointer[ADDRESS_SIZE:ADDRESS_SIZE-1],read_pointer[ADDRESS_SIZE-2:0]});
    _write_pointer_binary           = write_pointer_binary_next;
    _write_pointer_gray             = write_pointer_gray_next;
end

   

always @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        full                    <= '0;
        almost_full             <= '0;
        write_pointer_binary    <= '0;
        write_pointer_gray      <= '0;
    end 
    else begin
        almost_full             <= _almost_full;
        full                    <= _full;
        write_pointer_binary    <= _write_pointer_binary;
        write_pointer_gray      <= _write_pointer_gray;
    end
end

endmodule