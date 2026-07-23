`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 11/28/2026
// Design Name: 
// Module Name: asynchronous_fifo_read_pointer
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
module asynchronous_fifo_read_pointer
#(
parameter ADDRESS_SIZE                  = 4,
parameter PROGRAMMABLE_EMPTY_THRESHOLD  = 8
)(
    input  wire                     clock,
    input  wire                     reset_n,
    input  wire                     enable,
    input  wire [ADDRESS_SIZE:0]    write_pointer,

    output logic                    empty,
    output logic                    almost_empty,
    output logic                    programmable_empty,
    output logic [ADDRESS_SIZE-1:0] address,
    output logic [ADDRESS_SIZE:0]   read_pointer_gray
);

logic [ADDRESS_SIZE:0]  read_pointer_binary;
logic [ADDRESS_SIZE:0]  read_pointer_gray_next;
logic [ADDRESS_SIZE:0]  read_pointer_binary_next;
logic [ADDRESS_SIZE:0]  read_pointer_gray_nextm1;
logic                   _almost_empty;
logic                   _empty;
logic                   _programmable_empty;
logic [ADDRESS_SIZE:0]  _read_pointer_gray;
logic [ADDRESS_SIZE:0]  _read_pointer_binary;
logic [ADDRESS_SIZE:0]  write_pointer_binary;
logic [ADDRESS_SIZE:0]  fill_count;
integer k;


always_comb begin
    address                     = read_pointer_binary[ADDRESS_SIZE-1:0];
    read_pointer_binary_next    = read_pointer_binary + ((enable && !empty) ? 1 : 0);
    read_pointer_gray_next      = (read_pointer_binary_next >> 1) ^ read_pointer_binary_next;
    read_pointer_gray_nextm1    = ((read_pointer_binary_next + 1'b1) >> 1) ^ (read_pointer_binary_next + 1'b1);
    _empty                      = (read_pointer_gray_next == write_pointer);
    _almost_empty               = (read_pointer_gray_nextm1 == write_pointer) || _empty;
    _read_pointer_gray          = read_pointer_gray_next;
    _read_pointer_binary        = read_pointer_binary_next;

    //fill level in the read domain from the synchronized (gray) write
    //pointer, for the backlog watermark programmable empty flag. the
    //synchronized pointer lags the true write pointer so the fill count
    //never overstates the backlog
    write_pointer_binary[ADDRESS_SIZE]  = write_pointer[ADDRESS_SIZE];

    for (k = ADDRESS_SIZE-1; k >= 0; k = k - 1) begin
        write_pointer_binary[k] = write_pointer_binary[k+1] ^ write_pointer[k];
    end
    
    fill_count          = write_pointer_binary - read_pointer_binary_next;
    _programmable_empty = (fill_count <= PROGRAMMABLE_EMPTY_THRESHOLD);
end


always @ (posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        almost_empty        <= '1;
        empty               <= '1;
        programmable_empty  <= '1;
        read_pointer_binary <= '0;
        read_pointer_gray   <= '0;
    end
    else begin
        almost_empty        <= _almost_empty;
        empty               <= _empty;
        programmable_empty  <= _programmable_empty;
        read_pointer_binary <= _read_pointer_binary;
        read_pointer_gray   <= _read_pointer_gray;
    end
end

endmodule