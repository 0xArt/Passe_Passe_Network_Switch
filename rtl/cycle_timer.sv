`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
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

    output  reg                             expired
);


reg     [BIT_WIDTH-1:0]                 counter;
logic   [BIT_WIDTH-1:0]                 _counter;
logic                                   _expired;

always_comb begin
    _expired    =   0;
    _counter    =   counter;

    if (enable) begin
        if (load_count) begin
            _counter = count;
        end
        else begin
            if (counter == 0) begin
                _expired = 1;
            end
            else begin
                _counter    =   counter - 1;
            end
        end
    end
end


always_ff @(posedge clock) begin
    if (!reset_n) begin
        counter                         <=  0;
        expired                         <=  0;
    end
    else begin
        counter                         <=  _counter;
        expired                         <=  _expired;
    end
end

endmodule