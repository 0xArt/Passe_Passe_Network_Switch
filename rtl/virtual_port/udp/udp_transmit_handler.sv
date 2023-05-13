`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
//
// Create Date: 05/07/2023
// Design Name:
// Module Name: udp_transmit_handler
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
module udp_transmit_handler(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire    [8:0]   data,
    input   wire            data_enable,
    input   wire            udp_data_enable,

    output  reg             data_ready,
    output  reg     [47:0]  mac_destination,
    output  reg     [31:0]  ipv4_destination,
    output  reg     [15:0]  udp_destination,
    output  reg     [15:0]  udp_source,
    output  reg     [15:0]  udp_data_size,
    output  reg     [7:0]   udp_data,
    output  reg             udp_data_valid,
    output  reg             transmit_valid,
    output  reg             ready
);

localparam logic [15:0] TIMEOUT_LIMIT   = 16'h00FF;


wire            timeout_cycle_timer_clock;
wire            timeout_cycle_timer_reset_n;
wire            timeout_cycle_timer_enable;
logic           timeout_cycle_timer_load_count;
wire  [15:0]    timeout_cycle_timer_count;
wire            timeout_cycle_timer_expired;

cycle_timer timeout_cycle_timer(
    .clock      (timeout_cycle_timer_clock),
    .reset_n    (timeout_cycle_timer_reset_n),
    .enable     (timeout_cycle_timer_enable),
    .load_count (timeout_cycle_timer_load_count),
    .count      (timeout_cycle_timer_count),

    .expired    (timeout_cycle_timer_expired)
);


typedef enum
{
    S_IDLE,
    S_FIND_START_BIT,
    S_GET_MAC_DESTINATION,
    S_GET_IPV4_DESTINATION,
    S_GET_UDP_DESTINATION,
    S_GET_UDP_SOURCE,
    S_GET_UDP_DATA_SIZE,
    S_ENABLE_TRANSMIT,
    S_WAIT_UDP_DATA_REQUEST,
    S_PUSH_UDP_DATA,
    S_RESTART
} state_type;


state_type          _state;
state_type          state;
logic       [15:0]  _process_counter;
reg         [15:0]  process_counter;
logic       [47:0]  _mac_destination;
logic       [31:0]  _ipv4_destination;
logic       [15:0]  _udp_destination;
logic       [15:0]  _udp_source;
logic       [15:0]  _udp_data_size;
logic       [7:0]   _udp_data;
logic               _udp_data_valid;
logic               _data_ready;
logic               _ready;
logic               _transmit_valid;

assign  timeout_cycle_timer_clock       =   clock;
assign  timeout_cycle_timer_reset_n     =   reset_n;
assign  timeout_cycle_timer_enable      =   1;
assign  timeout_cycle_timer_count       =   TIMEOUT_LIMIT;

always_comb begin
    _state                          =   state;
    _mac_destination                =   mac_destination;
    _ipv4_destination               =   ipv4_destination;
    _udp_destination                =   udp_destination;
    _udp_source                     =   udp_source;
    _udp_data_size                  =   udp_data_size;
    _udp_data                       =   udp_data;
    _data_ready                     =   data_ready;
    _ready                          =   ready;
    _process_counter                =   process_counter;
    _udp_data_valid                 =   0;
    _transmit_valid                 =   0;
    timeout_cycle_timer_load_count  =   0;

    case (state)
        S_IDLE: begin
            _data_ready                     =   1;
            _process_counter                =   4;
            _ready                          =   1;
            timeout_cycle_timer_load_count  =   1;

            if (data_enable) begin
                if (data[8]) begin
                    _mac_destination[47:8]          =   mac_destination[39:0];
                    _mac_destination[7:0]           =   data[7:0];
                    _state                          =   S_GET_MAC_DESTINATION;
                    _ready                          =   0;
                end
            end
        end
        S_GET_MAC_DESTINATION: begin
            if (data_enable) begin
                _mac_destination[47:8]          =   mac_destination[39:0];
                _mac_destination[7:0]           =   data[7:0];
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _state              =   S_GET_IPV4_DESTINATION;
                    _process_counter    =   3;
                end
                if (data[8]) begin
                    _data_ready     =   0;
                    _state          =   S_RESTART;
                end
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_GET_IPV4_DESTINATION: begin
            if (data_enable) begin
                _ipv4_destination[31:8]         =   ipv4_destination[23:0];
                _ipv4_destination[7:0]          =   data[7:0];
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _state              =   S_GET_UDP_DESTINATION;
                    _process_counter    =   1;
                end
                if (data[8]) begin
                    _data_ready     = 0;
                    _state          =   S_RESTART;
                end
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_GET_UDP_DESTINATION: begin
            if (data_enable) begin
                _udp_destination[15:8]          =   udp_destination[7:0];
                _udp_destination[7:0]           =   data[7:0];
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _state              =   S_GET_UDP_SOURCE;
                    _process_counter    =   1;
                end
                if (data[8]) begin
                    _data_ready             = 0;
                    _mac_destination[47:8]  =   mac_destination[39:0];
                    _mac_destination[7:0]   =   data[7:0];
                    _state                  =   S_RESTART;
                end
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_GET_UDP_SOURCE: begin
            if (data_enable) begin
                _udp_source[15:8]               =   udp_source[7:0];
                _udp_source[7:0]                =   data[7:0];
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _state              =   S_GET_UDP_DATA_SIZE;
                    _process_counter    =   1;
                end
                if (data[8]) begin
                    _data_ready             = 0;
                    _mac_destination[47:8]  =   mac_destination[39:0];
                    _mac_destination[7:0]   =   data[7:0];
                    _state                  =   S_RESTART;
                end
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_GET_UDP_DATA_SIZE: begin
            if (data_enable) begin
                _udp_data_size[15:8]            =   udp_data_size[7:0];
                _udp_data_size[7:0]             =   data[7:0];
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _data_ready         =   0;
                    _state              =   S_ENABLE_TRANSMIT;
                end
                if (data[8]) begin
                    _data_ready             = 0;
                    _mac_destination[47:8]  =   mac_destination[39:0];
                    _mac_destination[7:0]   =   data[7:0];
                    _state                  =   S_RESTART;
                end
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_ENABLE_TRANSMIT: begin
            if (enable) begin
                _transmit_valid                 =   1;
                _process_counter                =   udp_data_size - 1;
                timeout_cycle_timer_load_count  =   1;
                _state                          =   S_WAIT_UDP_DATA_REQUEST;
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_WAIT_UDP_DATA_REQUEST: begin
            if (udp_data_enable) begin
                timeout_cycle_timer_load_count  =   1;
                _data_ready                     =   1;
                _state                          =   S_PUSH_UDP_DATA;
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_PUSH_UDP_DATA: begin
            if (udp_data_enable) begin
                _data_ready = 1;

                if (data_enable) begin
                    _udp_data                       = data[7:0];
                    _udp_data_valid                 = 1;
                    _process_counter                = process_counter - 1;
                    timeout_cycle_timer_load_count  =   1;

                    if (data[8]) begin
                        _data_ready             = 0;
                        _mac_destination[47:8]  =   mac_destination[39:0];
                        _mac_destination[7:0]   =   data[7:0];
                        _state                  =   S_RESTART;
                    end
                end
            end
            else begin
                _data_ready = 0;
            end
            if (process_counter == 0) begin
                _state      = S_IDLE;
                _data_ready =   0;
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_RESTART: begin
            _data_ready                     =   1;
            _process_counter                =   4;
            timeout_cycle_timer_load_count  =   1;
            _state                          =   S_GET_MAC_DESTINATION;
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <=  S_IDLE;
        process_counter             <=  0;
        mac_destination             <=  0;
        ipv4_destination            <=  0;
        udp_destination             <=  0;
        udp_source                  <=  0;
        udp_data_size               <=  0;
        udp_data                    <=  0;
        udp_data_valid              <=  0;
        data_ready                  <=  0;
        transmit_valid              <=  0;
        ready                       <=  0;
    end
    else begin
        state                       <=  _state;
        process_counter             <=  _process_counter;
        mac_destination             <=  _mac_destination;
        ipv4_destination            <=  _ipv4_destination;
        udp_destination             <=  _udp_destination;
        udp_source                  <=  _udp_source;
        udp_data_size               <=  _udp_data_size;
        udp_data                    <=  _udp_data;
        udp_data_valid              <=  _udp_data_valid;
        data_ready                  <=  _data_ready;
        transmit_valid              <=  _transmit_valid;
        ready                       <=  _ready;
    end
end

endmodule