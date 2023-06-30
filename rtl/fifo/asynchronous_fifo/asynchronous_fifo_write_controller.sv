`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 06/25/2023
// Design Name: 
// Module Name: asynchronous_fifo_write_controller
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
module asynchronous_fifo_write_controller#(
    parameter DATA_WIDTH = 16,
    parameter DATA_DEPTH = 4096
)(
    input   wire                                clock,
    input   wire                                reset_n,
    input   wire                                write_enable,
    input   wire    [$clog2(DATA_DEPTH)-1:0]    read_pointer_gray, //read domain clock
    input   wire                                read_enable,       //read domain clock
    input   wire    [DATA_WIDTH-1:0]            write_data,

    output  reg     [DATA_WIDTH-1:0]            memory_write_data,
    output  reg                                 memory_write_data_valid,
    output  reg     [$clog2(DATA_DEPTH)-1:0]    memory_write_address,
    output  reg     [$clog2(DATA_DEPTH)-1:0]    write_pointer_gray,
    output  reg                                 full
);

reg     [$clog2(DATA_DEPTH)-1:0]                read_pointer;
logic   [$clog2(DATA_DEPTH)-1:0]                _read_pointer;
reg     [$clog2(DATA_DEPTH)-1:0]                write_pointer;
logic   [$clog2(DATA_DEPTH)-1:0]                _write_pointer;
reg                                             read_enable_sync;
logic                                           _read_enable_sync;
logic   [DATA_WIDTH-1:0]                        _memory_write_data;
logic                                           _memory_write_data_valid;
logic   [$clog2(DATA_DEPTH)-1:0]                _memory_write_address;
logic                                           _full;
logic                                           internal_empty;
integer i;


always_comb begin

    for (i=0; i<$clog2(DATA_DEPTH); i=i+1) begin
        _read_pointer[i] = ^(read_pointer_gray >> i);
    end
    _read_enable_sync                           =   read_enable;
    _write_pointer                              =   write_pointer;
    _memory_write_address                       =   write_pointer;
    _memory_write_data                          =   write_data;
    _memory_write_data_valid                    =   0;
    _full                                       =   0;
    internal_empty                              =    ( (write_pointer == read_pointer) && !full) ? 1 : 0;
    write_pointer_gray[$clog2(DATA_DEPTH)-1:0]  =   write_pointer[$clog2(DATA_DEPTH)-1:0] ^ {1'b0, write_pointer[$clog2(DATA_DEPTH)-1:1]};

    if (write_pointer == (DATA_DEPTH - 1)) begin
        if (read_pointer == 0) begin
            _full = 1;
        end
    end
    else if (write_pointer == read_pointer) begin
        if (!internal_empty) begin
            _full = 1;
        end
    end
    else begin
        if ((write_pointer + 1) == read_pointer) begin
            _full = 1;
        end
    end


    if (write_enable) begin
        if (!full) begin
            _memory_write_data_valid = 1;

            if (write_pointer == (DATA_DEPTH -1)) begin
                _write_pointer  =   0;
            end
            else begin
                _write_pointer  = write_pointer + 1;
            end
        end
    end

end


always_ff @(posedge clock) begin
    if (!reset_n) begin
        write_pointer           <=  0;
        read_enable_sync        <=  0;
        memory_write_data       <=  0;
        read_pointer            <=  0;
        full                    <=  0;
    end
    else begin
        write_pointer           <=  _write_pointer;
        read_enable_sync        <=  _read_enable_sync;
        memory_write_data       <=  _memory_write_data;
        memory_write_data_valid <=  _memory_write_data_valid;
        memory_write_address    <=  _memory_write_address;
        read_pointer            <=  _read_pointer;
        full                    <=  _full;
    end
end


endmodule