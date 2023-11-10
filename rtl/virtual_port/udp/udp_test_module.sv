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
    output  wire                            packet_data_valid,
    output  reg     [8:0]                   received_data,
    output  reg                             received_data_valid,
    output  reg                             blink
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


wire            receive_fifo_clock;
wire            receive_fifo_reset_n;
wire    [8:0]   receive_fifo_write_data;
wire            receive_fifo_read_enable;
wire            receive_fifo_write_enable;
wire            receive_fifo_read_data_valid;
wire            receive_fifo_empty;
wire            receive_fifo_full;
wire    [8:0]   receive_fifo_read_data;

synchronous_fifo
#(  .DATA_WIDTH                 (9),
    .DATA_DEPTH                 (1024),
    .FIRST_WORD_FALL_THROUGH    (1),
    .XILINX                     (XILINX)
) receive_fifo(
    .clock              (receive_fifo_clock),
    .reset_n            (receive_fifo_reset_n),
    .read_enable        (receive_fifo_read_enable),
    .write_enable       (receive_fifo_write_enable),
    .write_data         (receive_fifo_write_data),

    .read_data          (receive_fifo_read_data),
    .read_data_valid    (receive_fifo_read_data_valid),
    .full               (receive_fifo_full),
    .empty              (receive_fifo_empty)
);


typedef enum
{
    S_IDLE,
    S_PARSE_MAC_SOURCE,
    S_PARSE_IPV4_SOURCE,
    S_PARSE_IPV4_DESTINATION,
    S_PARSE_UDP_SOURCE,
    S_PARSE_UDP_DESTINATION,
    S_PARSE_UDP_LENGTH,
    S_PARSE_UDP_DATA
} state_type;

state_type      _state;
state_type      state;
logic   [7:0]   _byte_counter;
reg     [7:0]   byte_counter;
logic   [8:0]   _internal_packet_data;
reg     [8:0]   internal_packet_data;
logic           _internal_packet_data_valid;
reg             internal_packet_data_valid;
logic           data_ready;
logic   [7:0]   _process_counter;
reg     [7:0]   process_counter;
logic   [47:0]  _received_mac_source;
reg     [47:0]  received_mac_source;
logic   [31:0]  _received_ipv4_source;
reg     [31:0]  received_ipv4_source;
logic   [31:0]  _received_ipv4_destination;
reg     [31:0]  received_ipv4_destination;
logic   [15:0]  _received_udp_source;
reg     [15:0]  received_udp_source;
logic   [15:0]  _received_udp_destination;
reg     [15:0]  received_udp_destination;
logic   [15:0]  _received_udp_length;
reg     [15:0]  received_udp_length;
logic   [15:0]  udp_payload_size;
logic           _blink;
logic   [8:0]   _received_data;
logic           _received_data_valid;

assign packet_data                  =   transmit_fifo_read_data;
assign packet_data_valid            =   transmit_fifo_read_data_valid;

assign transmit_fifo_clock          =   clock;
assign transmit_fifo_reset_n        =   reset_n;
assign transmit_fifo_read_enable    =   packet_data_enable && transmit_fifo_read_data_valid;
assign transmit_fifo_write_enable   =   internal_packet_data_valid;
assign transmit_fifo_write_data     =   internal_packet_data;

assign receive_fifo_clock           =   clock;
assign receive_fifo_reset_n         =   reset_n;
assign receive_fifo_read_enable     =   data_ready;
assign receive_fifo_write_enable    =   data_enable;
assign receive_fifo_write_data      =   data;


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
    _state                      =   state;
    _process_counter            =   process_counter;
    _byte_counter               =   byte_counter;
    _received_mac_source        =   received_mac_source;
    _internal_packet_data       =   internal_packet_data;
    _received_mac_source        =   received_mac_source;
    _received_ipv4_source       =   received_ipv4_source;
    _received_ipv4_destination  =   received_ipv4_destination;
    _received_udp_destination   =   received_udp_destination;
    _received_udp_source        =   received_udp_source;
    _received_udp_length        =   received_udp_length;
    _received_data              =   received_data;
    _received_data_valid        =   0;
    udp_payload_size            =   received_udp_length - 8;
    _blink                      =   blink;
    _internal_packet_data_valid =   0;
    data_ready                  =   0;

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

    case (state) 
        S_IDLE: begin
            if (receive_fifo_read_data_valid) begin
                data_ready  = 1;

                if (receive_fifo_read_data[8]) begin
                    _state                  = S_PARSE_MAC_SOURCE;
                    _received_mac_source    = {received_mac_source[39:0], receive_fifo_read_data[7:0]};
                    _process_counter        = 4;
                end
            end
        end
        S_PARSE_MAC_SOURCE: begin
            if (receive_fifo_read_data_valid) begin
                data_ready              = 1;
                _received_mac_source    = {received_mac_source[39:0], receive_fifo_read_data[7:0]};
                _process_counter        = process_counter - 1;

                if (process_counter == 0) begin
                    _state              = S_PARSE_IPV4_SOURCE;
                    _process_counter    = 3; 
                end

                if (receive_fifo_read_data[8]) begin
                    _state                  = S_PARSE_MAC_SOURCE;
                    _process_counter        = 4;
                end
            end
        end
        S_PARSE_IPV4_SOURCE: begin
            if (receive_fifo_read_data_valid) begin
                data_ready              = 1;
                _process_counter        = process_counter - 1;
                _received_ipv4_source   = {received_ipv4_source[23:0], receive_fifo_read_data[7:0]};

                if (process_counter == 0) begin
                    _state              = S_PARSE_IPV4_DESTINATION;
                    _process_counter    = 3; 
                end

                if (receive_fifo_read_data[8]) begin
                    _received_mac_source    = {received_mac_source[39:0], receive_fifo_read_data[7:0]};
                    _state                  = S_PARSE_MAC_SOURCE;
                    _process_counter        = 4;
                end
            end
        end
        S_PARSE_IPV4_DESTINATION: begin
            if (receive_fifo_read_data_valid) begin
                data_ready                  = 1;
                _process_counter            = process_counter - 1;
                _received_ipv4_destination  = {received_ipv4_destination[23:0], receive_fifo_read_data[7:0]};

                if (process_counter == 0) begin
                    _state              = S_PARSE_UDP_SOURCE;
                    _process_counter    = 1; 
                end

                if (receive_fifo_read_data[8]) begin
                    _received_mac_source    = {received_mac_source[39:0], receive_fifo_read_data[7:0]};
                    _state                  = S_PARSE_MAC_SOURCE;
                    _process_counter        = 4;
                end
            end
        end
        S_PARSE_UDP_SOURCE: begin
            if (receive_fifo_read_data_valid) begin
                data_ready                  = 1;
                _process_counter            = process_counter - 1;
                _received_udp_source        = {received_udp_source[7:0], receive_fifo_read_data[7:0]};

                if (process_counter == 0) begin
                    _state              = S_PARSE_UDP_DESTINATION;
                    _process_counter    = 1; 
                end

                if (receive_fifo_read_data[8]) begin
                    _received_mac_source    = {received_mac_source[39:0], receive_fifo_read_data[7:0]};
                    _state                  = S_PARSE_MAC_SOURCE;
                    _process_counter        = 4;
                end
            end
        end
        S_PARSE_UDP_DESTINATION: begin
            if (receive_fifo_read_data_valid) begin
                data_ready                  = 1;
                _process_counter            = process_counter - 1;
                _received_udp_destination   = {received_udp_destination[7:0], receive_fifo_read_data[7:0]};

                if (process_counter == 0) begin
                    _state              = S_PARSE_UDP_LENGTH;
                    _process_counter    = 1; 
                end

                if (receive_fifo_read_data[8]) begin
                    _received_mac_source    = {received_mac_source[39:0], receive_fifo_read_data[7:0]};
                    _state                  = S_PARSE_MAC_SOURCE;
                    _process_counter        = 4;
                end
            end
        end
        S_PARSE_UDP_LENGTH: begin
            if (receive_fifo_read_data_valid) begin
                data_ready                  = 1;
                _process_counter            = process_counter - 1;
                _received_udp_length        = {received_udp_length[7:0], receive_fifo_read_data[7:0]};

                if (process_counter == 0) begin
                    _state              = S_PARSE_UDP_DATA;
                    _process_counter    = 0; 
                end

                if (receive_fifo_read_data[8]) begin
                    _received_mac_source    = {received_mac_source[39:0], receive_fifo_read_data[7:0]};
                    _state                  = S_PARSE_MAC_SOURCE;
                    _process_counter        = 4;
                end
            end
        end
        S_PARSE_UDP_DATA: begin
            if (receive_fifo_read_data_valid) begin
                data_ready                  = 1;
                _process_counter            = process_counter + 1;
                _received_data              = receive_fifo_read_data;
                _received_data_valid        = 1;

                if (receive_fifo_read_data[8]) begin
                    _received_mac_source    = {received_mac_source[39:0], receive_fifo_read_data[7:0]};
                    _state                  = S_PARSE_MAC_SOURCE;
                    _process_counter        = 4;
                    _received_data_valid    = 0;
                end
            end
            if (process_counter == udp_payload_size) begin
                _state              = S_IDLE;
                _blink              = !blink;
                data_ready          = 0;
            end
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <=  S_IDLE;
        byte_counter                <=  0;
        internal_packet_data        <=  0;
        internal_packet_data_valid  <=  0;
        process_counter             <=  0;
        received_mac_source         <=  0;
        received_ipv4_source        <=  0;
        received_ipv4_destination   <=  0;
        received_udp_source         <=  0;
        received_udp_destination    <=  0;
        received_udp_length         <=  0;
        blink                       <=  0;
        received_data               <=  0;
        received_data_valid         <=  0;
    end
    else begin
        state                       <=  _state;
        byte_counter                <=  _byte_counter;
        internal_packet_data        <=  _internal_packet_data;
        internal_packet_data_valid  <=  _internal_packet_data_valid;
        process_counter             <=  _process_counter;
        received_mac_source         <=  _received_mac_source;
        received_ipv4_source        <=  _received_ipv4_source;
        received_ipv4_destination   <=  _received_ipv4_destination;
        received_udp_source         <=  _received_udp_source;
        received_udp_destination    <=  _received_udp_destination;
        received_udp_length         <=  _received_udp_length;
        blink                       <=  _blink;
        received_data               <=  _received_data;
        received_data_valid         <=  _received_data_valid;
    end
end


endmodule