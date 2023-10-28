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
    parameter FIRST_WORD_FALL_THROUGH   = 1,
    parameter PIPELINED_MEMORY          = 0
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

integer i;
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
reg                                     empty_delay_0;
logic                                   _empty_delay_0;
logic                                   _empty_delay_1;
reg                                     empty_delay_1;
reg                                     read_data_valid_delay_0;
logic                                   _read_data_valid_delay_0;
logic                                   _read_data_valid_delay_1;
reg                                     read_data_valid_delay_1;
logic                                   increment_read_pointer;
logic                                   memory_data_valid;
reg     [$clog2(DATA_DEPTH)-1:0]        available_bytes;
logic   [$clog2(DATA_DEPTH)-1:0]        _available_bytes;

wire            memory_data_valid_timer_clock;
wire            memory_data_valid_timer_reset_n;
wire            memory_data_valid_timer_enable;
logic           memory_data_valid_timer_load_count;
wire    [15:0]  memory_data_valid_timer_count;
wire            memory_data_valid_timer_expired;


cycle_timer memory_data_valid_timer(
    .clock              (memory_data_valid_timer_clock),
    .reset_n            (memory_data_valid_timer_reset_n),
    .enable             (memory_data_valid_timer_enable),
    .load_count         (memory_data_valid_timer_load_count),
    .count              (memory_data_valid_timer_count),

    .expired            (memory_data_valid_timer_expired)
);


assign memory_data_valid_timer_clock    =   clock;
assign memory_data_valid_timer_reset_n  =   reset_n;
assign memory_data_valid_timer_enable   =   1;
assign memory_data_valid_timer_count    =   PIPELINED_MEMORY ? 2 : 1;

always_comb begin

    for (i=0; i<$clog2(DATA_DEPTH); i=i+1) begin
        write_pointer[i] = ^(write_pointer_gray_sync_1 >> i);
    end

    _write_pointer_gray_sync_0                  =   write_pointer_gray;
    _write_pointer_gray_sync_1                  =   write_pointer_gray_sync_0;
    _empty_delay_0                              =   empty;
    _empty_delay_1                              =   empty_delay_0;
    _read_data_valid_delay_0                    =   read_data_valid;
    _read_data_valid_delay_1                    =   read_data_valid_delay_0;
    _read_data                                  =   read_data;
    _read_data_valid                            =   read_data_valid;
    _read_pointer                               =   read_pointer;
    _internal_read_data_valid                   =   0;
    memory_read_address                         =   _read_pointer;
    _read_enable_delayed                        =   read_enable;
    _internal_full                              =   0;
    increment_read_pointer                      =   0;
    _available_bytes                            =   available_bytes;
    _empty                                      =   ((write_pointer == read_pointer) && !internal_full) ? 1 : 0;
    read_pointer_gray[$clog2(DATA_DEPTH)-1:0]   =   read_pointer[$clog2(DATA_DEPTH)-1:0] ^ {1'b0, read_pointer[$clog2(DATA_DEPTH)-1:1]};
    memory_data_valid_timer_load_count          =   0;

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


    if (write_pointer > read_pointer) begin
        _available_bytes =   write_pointer - read_pointer;
    end
    else if (read_pointer > write_pointer) begin
        _available_bytes = DATA_DEPTH - read_pointer + write_pointer;
    end
    else begin
        _available_bytes = 0;
    end

    if (memory_data_valid_timer_expired && !empty) begin
        memory_data_valid   =   1;
    end
    else begin
       memory_data_valid    =   0;
    end

    //handshake
    if (read_enable && read_data_valid) begin
        _read_data_valid = 0;
    end

    //pop data out
    if (memory_data_valid) begin
        if (read_enable) begin
            _read_data_valid        = 1;
            _read_data              = memory_read_data;
            increment_read_pointer  = 1;
        end
        else if (FIRST_WORD_FALL_THROUGH) begin
            if (!_read_data_valid) begin
                _read_data_valid        = 1;
                _read_data              = memory_read_data;
                increment_read_pointer  =   1;
            end
        end
    end

    //incrememnt read pointer
    if (increment_read_pointer) begin
        if (read_pointer == (DATA_DEPTH -1)) begin
            _read_pointer  =   0;
        end
        else begin
            _read_pointer  = read_pointer + 1;
        end
    end

    if (increment_read_pointer || empty) begin
        memory_data_valid_timer_load_count = 1;
    end
end


always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        read_data                   <=  0;
        read_data_valid             <=  0;
        read_pointer                <=  0;
        internal_full               <=  0;
        read_enable_delayed         <=  0;
        write_pointer_gray_sync_0   <=  0;
        write_pointer_gray_sync_1   <=  0;
        internal_read_data_valid    <=  0;
        read_data_valid_delay_0     <=  0;
        read_data_valid_delay_1     <=  0;
        available_bytes             <=  0;
        empty                       <=  1;
        empty_delay_0               <=  1;
        empty_delay_1               <=  1;
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
        empty_delay_0               <=  _empty_delay_0;
        empty_delay_1               <=  _empty_delay_1;
        read_data_valid_delay_0     <=  _read_data_valid_delay_0;
        read_data_valid_delay_1     <=  _read_data_valid_delay_1;
        available_bytes             <=  _available_bytes;
    end
end


endmodule