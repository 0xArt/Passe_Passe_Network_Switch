`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 06/25/2023
// Design Name: 
// Module Name: asynchronous_fifo_read_controller
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
module asynchronous_fifo_read_controller#(
    parameter DATA_WIDTH                = 16,
    parameter DATA_DEPTH                = 4096,
    parameter FIRST_WORD_FALL_THROUGH   = 1
)(
    input   wire                                clock,
    input   wire                                reset_n,
    input   wire                                read_enable,
    input   wire    [$clog2(DATA_DEPTH)-1:0]    write_pointer_gray, //write domain clock
    input   wire    [DATA_WIDTH-1:0]            memory_read_data,

    output  reg     [DATA_WIDTH-1:0]            read_data,
    output  reg                                 read_data_valid,
    output  reg     [$clog2(DATA_DEPTH)-1:0]    memory_read_address,
    output  reg     [$clog2(DATA_DEPTH)-1:0]    read_pointer_gray,
    output  reg                                 empty
);

reg     [$clog2(DATA_DEPTH)-1:0]        read_pointer;
logic   [$clog2(DATA_DEPTH)-1:0]        _read_pointer;
logic   [$clog2(DATA_DEPTH)-1:0]        write_pointer;
reg     [$clog2(DATA_DEPTH)-1:0]        write_pointer_gray_sync_0;
logic   [$clog2(DATA_DEPTH)-1:0]        _write_pointer_gray_sync_0;
reg     [$clog2(DATA_DEPTH)-1:0]        write_pointer_gray_sync_1;
logic   [$clog2(DATA_DEPTH)-1:0]        _write_pointer_gray_sync_1;
logic   [DATA_WIDTH-1:0]                _read_data;
logic                                   _read_data_valid;
logic                                   _empty;
logic                                   _internal_full;
reg                                     internal_full;
reg                                     read_enable_delayed;
logic                                   _read_enable_delayed;
reg                                     internal_read_data_valid;
logic                                   _internal_read_data_valid;
integer i;


always_comb begin

    for (i=0; i<$clog2(DATA_DEPTH); i=i+1) begin
        write_pointer[i] = ^(write_pointer_gray_sync_1 >> i);
    end
    _write_pointer_gray_sync_0                  =   write_pointer_gray;
    _write_pointer_gray_sync_1                  =   write_pointer_gray_sync_0;
    _read_data                                  =   read_data;
    _read_data_valid                            =   internal_read_data_valid;
    _read_pointer                               =   read_pointer;
    memory_read_address                         =   _read_pointer;
    _read_enable_delayed                        =   read_enable;
    _internal_full                              =   0;
    _empty                                      =   ( (write_pointer == read_pointer) && !internal_full) ? 1 : 0;
    read_pointer_gray[$clog2(DATA_DEPTH)-1:0]   =   read_pointer[$clog2(DATA_DEPTH)-1:0] ^ {1'b0, read_pointer[$clog2(DATA_DEPTH)-1:1]};

    if (write_pointer == (DATA_DEPTH - 1)) begin
        if (read_pointer == 0) begin
            _internal_full = 1;
        end
    end
    else if (write_pointer == read_pointer) begin
        if (!_empty) begin
            _internal_full = 1;
        end
    end
    else begin
        if ((write_pointer + 1) == read_pointer) begin
            _internal_full = 1;
        end
    end


    if (read_data_valid && read_enable) begin
        _internal_read_data_valid        = 0;
    end

    if (read_enable) begin
        if(_empty && !empty)begin
            _read_data                  =   memory_read_data;
            _internal_read_data_valid   =   1;
        end
        if(!_empty) begin
            _read_data                  =   memory_read_data;
            _internal_read_data_valid   =   1;

            if (read_pointer == (DATA_DEPTH -1)) begin
                _read_pointer  =   0;
            end
            else begin
                _read_pointer  = read_pointer + 1;
            end
        end
        else begin
            _internal_read_data_valid    =   0;
        end
    end

    if (!read_enable && read_enable_delayed) begin
        if (!empty) begin
            _read_data          =   memory_read_data;
        end
    end

    if (FIRST_WORD_FALL_THROUGH) begin
        if (!read_enable && !read_enable_delayed && !read_data_valid) begin
            if (!empty) begin
                _read_data                  =   memory_read_data;
                _internal_read_data_valid   =   1;

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
        read_data                   <=  0;
        read_data_valid             <=  0;
        read_pointer                <=  0;
        empty                       <=  1;
        internal_full               <=  0;
        read_enable_delayed         <=  0;
        write_pointer_gray_sync_0   <=  0;
        write_pointer_gray_sync_1   <=  0;
        internal_read_data_valid    <=  0;
    end
    else begin
        read_data                   <=  _read_data;
        read_data_valid             <=  _read_data_valid;
        read_pointer                <=  _read_pointer;
        empty                       <=  _empty;
        internal_full               <=  _internal_full;
        read_enable_delayed         <=  _read_enable_delayed;
        write_pointer_gray_sync_0   <= _write_pointer_gray_sync_0;
        write_pointer_gray_sync_1   <=  _write_pointer_gray_sync_1;
        internal_read_data_valid    <=  _internal_read_data_valid;
    end
end


endmodule