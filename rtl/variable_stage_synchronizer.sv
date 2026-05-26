`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 11/27/2025
// Design Name: 
// Module Name: variable_stage_synchronizer
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
// SIMULATION ONLY
// 
//////////////////////////////////////////////////////////////////////////////////
module variable_stage_synchronizer#(
    parameter DATA_WIDTH    = 16,
    parameter STAGES        = 2
)(
    input   wire                        clock,
    input   wire                        reset_n,
    input   wire    [DATA_WIDTH-1:0]    source_signal,

    output  logic   [DATA_WIDTH-1:0]    destination_signal,
    output  reg                         destination_signal_valid
);


logic [STAGES-1:0][DATA_WIDTH-1:0]  _retimed_signal;
reg   [STAGES-1:0][DATA_WIDTH-1:0]  retimed_signal;
logic [$clog2(STAGES):0]            _counter;
reg   [$clog2(STAGES):0]            counter;
logic                               _destination_signal_valid;

always_comb begin
    _destination_signal_valid   = 0;
    _retimed_signal[0]          = source_signal;
    destination_signal          = retimed_signal[STAGES-1];

    for (int i = 1; i < STAGES; i = i + 1) begin
        _retimed_signal[i] = retimed_signal[i-1];
    end

    _counter = counter + 1;

    if (counter >= (STAGES-1)) begin
        _counter                    = 0;
        _destination_signal_valid   = 1;
    end
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        retimed_signal              <= '0;
        destination_signal_valid    <= '0;
        counter                     <= '0;
    end
    else begin
        retimed_signal              <= _retimed_signal;
        destination_signal_valid    <= _destination_signal_valid;
        counter                     <= _counter;
    end
end



endmodule