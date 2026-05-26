`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 05/06/2023
// Design Name: 
// Module Name: cycle_timer
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
module cycle_timer#(
    parameter BIT_WIDTH = 16
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire                            enable,
    input   wire                            load_count,
    input   wire    [BIT_WIDTH-1:0]         count,

    output  logic                           expired
);


reg     [BIT_WIDTH-1:0]                 counter;
logic   [BIT_WIDTH-1:0]                 _counter;

always_comb begin
    _counter    = counter;

    if (counter == 0) begin
        expired = 1;
    end
    else begin
        expired = 0;
    end

    if (enable) begin
        if (load_count) begin
            _counter = count;
        end
        else begin
            if (counter == 0) begin
            end
            else begin
                _counter    = counter - 1;
            end
        end
    end
end


always_ff @(posedge clock) begin
    if (!reset_n) begin
        counter <= 0;
    end
    else begin
        counter <= _counter;
    end
end

endmodule