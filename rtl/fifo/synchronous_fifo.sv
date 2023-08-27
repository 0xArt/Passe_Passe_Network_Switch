`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 05/25/2023
// Design Name: 
// Module Name: synchronous_fifo
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
module synchronous_fifo#(
    parameter DATA_WIDTH                = 16,
    parameter DATA_DEPTH                = 4096,
    parameter FIRST_WORD_FALL_THROUGH   = "FALSE"
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire                            read_enable,
    input   wire                            write_enable,
    input   wire    [DATA_WIDTH-1:0]        write_data,

    output  reg     [DATA_WIDTH-1:0]        read_data,
    output  reg                             read_data_valid,
    output  reg                             full,
    output  reg                             empty
);


reg     [DATA_DEPTH-1:0]                read_pointer;
logic   [DATA_DEPTH-1:0]                _read_pointer;
reg     [DATA_DEPTH-1:0]                write_pointer;
logic   [DATA_DEPTH-1:0]                _write_pointer;
logic   [DATA_WIDTH-1:0]                _read_data;
logic                                   _read_data_valid;
reg     [DATA_WIDTH-1:0]                memory   [DATA_DEPTH-1:0];
logic   [DATA_WIDTH-1:0]                _memory  [DATA_DEPTH-1:0];
integer                                 i;
integer                                 j;


always_comb begin
    _read_data          =   read_data;
    _read_data_valid    =   read_data_valid;
    _read_pointer       =   read_pointer;
    _write_pointer      =   write_pointer;
    full                =   0;
    empty               =   ( (write_pointer == read_pointer) && !full ) ? 1 : 0;

    for (i=0; i<DATA_DEPTH; i=i+1) begin
        _memory[i]      =   memory[i];
    end

    if (write_pointer == (DATA_DEPTH - 1)) begin
        if (read_pointer == 0) begin
            full = 1;
        end
    end
    else begin
        if ((write_pointer + 1) == read_pointer) begin
            full = 1;
        end
    end

    if (read_enable && read_data_valid) begin
        _read_data_valid    =   0;
    end

    if (write_enable && !read_enable) begin
        if (!full) begin
            _memory[write_pointer] = write_data;

            if (write_pointer == (DATA_DEPTH -1)) begin
                _write_pointer  =   0;
            end
            else begin
                _write_pointer  = write_pointer + 1;
            end
        end
    end

    if (read_enable && !write_enable) begin
        if(!empty) begin
            _read_data          =   memory[read_pointer];
            _read_data_valid    =   1;

            if (read_pointer == (DATA_DEPTH -1)) begin
                _read_pointer  =   0;
            end
            else begin
                _read_pointer  = read_pointer + 1;
            end
        end
        else begin
            _read_data_valid    =   0;
        end
    end

    if (read_enable && write_enable) begin
        if (empty) begin
            _read_data       =   write_data;
            _read_data_valid =   1;
        end
        else begin
            _read_data          =   memory[read_pointer];
            _read_data_valid    =   1;

            if (read_pointer == (DATA_DEPTH -1)) begin
                _read_pointer  =   0;
            end
            else begin
                _read_pointer  = read_pointer + 1;
            end

            _memory[write_pointer] = write_data;

            if (write_pointer == (DATA_DEPTH -1)) begin
                _write_pointer  =   0;
            end
            else begin
                _write_pointer  = write_pointer + 1;
            end
        end
    end

    if (FIRST_WORD_FALL_THROUGH) begin
        if (!empty) begin
            if (!read_enable && !read_data_valid) begin
                _read_data          =   memory[read_pointer];
                _read_data_valid    =   1;

                if (read_pointer == (DATA_DEPTH -1)) begin
                    _read_pointer  =   0;
                end
                else begin
                    _read_pointer  = read_pointer + 1;
                end
            end
        end
    end
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        read_data                       <=  0;
        read_data_valid                 <=  0;
        read_pointer                    <=  0;
        write_pointer                   <=  0;

        for (j=0; j<DATA_DEPTH; j=j+1) begin
            memory[j]                   <=  0;
        end
    end
    else begin
        read_data                       <=  _read_data;
        read_data_valid                 <=  _read_data_valid;
        read_pointer                    <=  _read_pointer;
        write_pointer                   <=  _write_pointer;

        for (j=0; j<DATA_DEPTH; j=j+1) begin
            memory[j]                   <=  _memory[j];
        end
    end
end

endmodule