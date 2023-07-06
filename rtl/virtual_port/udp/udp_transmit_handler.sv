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
    input   wire    [31:0]  ipv4_source,

    output  reg             data_ready,
    output  reg     [47:0]  mac_destination,
    output  reg     [31:0]  ipv4_destination,
    output  reg     [15:0]  udp_destination,
    output  reg     [15:0]  udp_source,
    output  reg     [15:0]  ipv4_identification,
    output  reg     [15:0]  ipv4_flags,
    output  reg     [15:0]  udp_fragment_size,
    output  reg     [15:0]  udp_total_payload_size,
    output  reg     [15:0]  udp_buffer_write_address,
    output  reg     [7:0]   udp_buffer_data,
    output  reg             udp_buffer_data_valid,
    output  reg     [7:0]   udp_checksum_data,
    output  reg             udp_checksum_data_valid,
    output  reg             udp_checksum_data_last,
    output  reg             transmit_valid
);

localparam logic [15:0] TIMEOUT_LIMIT       = 16'h00FF;
localparam logic [15:0] MAX_PAYLOAD_SIZE    = 16'd1472;


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
    S_GET_MAC_DESTINATION,
    S_CHECKSUM_IPV4_SOURCE,
    S_GET_IPV4_DESTINATION,
    S_CHECKSUM_ZEROS,
    S_CHECKSUM_IPV4_PROTOCOL,
    S_GET_UDP_TOTAL_PAYLOAD_SIZE,
    S_CHECKSUM_UDP_LENGTH_0,
    S_CHECKSUM_UDP_LENGTH_1,
    S_GET_UDP_SOURCE,
    S_GET_UDP_DESTINATION,
    S_CHECKSUM_UDP_LENGTH_AGAIN_0,
    S_CHECKSUM_UDP_LENGTH_AGAIN_1,
    S_GET_UDP_DATA,
    S_SET_FRAGMENT_SETTINGS,
    S_ENABLE_TRANSMIT,
    S_WAIT_TRANSMIT_BUSY,
    S_WAIT_TRANSMIT_DONE,
    S_RESTART
} state_type;

localparam IPV4_PROTOCOL_UDP            = 8'h11;
localparam UDP_HEADER_NUMBER_OF_BYTES   = 8;
localparam IPV4_HEADER_NUMBER_OF_BYTES  = 20;



state_type          _state;
state_type          state;
logic       [15:0]  _process_counter;
reg         [15:0]  process_counter;
logic       [47:0]  _mac_destination;
logic       [31:0]  _ipv4_destination;
logic       [15:0]  _udp_destination;
logic       [15:0]  _udp_source;
logic       [15:0]  _number_of_udp_bytes_left;
reg         [15:0]  number_of_udp_bytes_left;
logic       [7:0]   _udp_buffer_data;
logic               _udp_buffer_data_valid;
logic               _data_ready;
logic               _ready;
logic               _transmit_valid;
logic       [15:0]  _ipv4_identification;
logic       [15:0]  _ipv4_flags;
reg         [31:0]  saved_ipv4_source;
logic       [31:0]  _saved_ipv4_source;
logic       [15:0]  _udp_buffer_write_address;
logic       [7:0]   _udp_checksum_data;
logic               _udp_checksum_data_valid;
logic       [15:0]  _udp_total_payload_size;
logic       [15:0]  udp_header_size_field;
logic               _udp_checksum_data_last;
logic       [15:0]  _udp_fragment_size;


assign  timeout_cycle_timer_clock       =   clock;
assign  timeout_cycle_timer_reset_n     =   reset_n;
assign  timeout_cycle_timer_enable      =   1;
assign  timeout_cycle_timer_count       =   TIMEOUT_LIMIT;

always_comb begin
    _state                          =   state;
    _mac_destination                =   mac_destination;
    _ipv4_destination               =   ipv4_destination;
    _saved_ipv4_source              =   saved_ipv4_source;
    _udp_destination                =   udp_destination;
    _udp_source                     =   udp_source;
    _data_ready                     =   data_ready;
    _process_counter                =   process_counter;
    _ipv4_flags                     =   ipv4_flags;
    _ipv4_identification            =   ipv4_identification;
    _number_of_udp_bytes_left       =   number_of_udp_bytes_left;
    _udp_buffer_write_address       =   udp_buffer_write_address;
    _udp_checksum_data              =   udp_checksum_data;
    _udp_total_payload_size         =   udp_total_payload_size;
    udp_header_size_field           =   udp_total_payload_size + UDP_HEADER_NUMBER_OF_BYTES;
    _udp_fragment_size              =   udp_fragment_size;
    _udp_checksum_data_valid        =   0;
    _transmit_valid                 =   0;
    timeout_cycle_timer_load_count  =   0;

    case (state)
        S_IDLE: begin
            _data_ready                     =   1;
            _process_counter                =   4;
            _ready                          =   1;
            _ipv4_flags                     =   0;
            timeout_cycle_timer_load_count  =   1;
            _saved_ipv4_source              =   ipv4_source;

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
        S_CHECKSUM_IPV4_SOURCE: begin
            _saved_ipv4_source              =   {saved_ipv4_source[23:0],8'h00};
            _udp_checksum_data              =   saved_ipv4_source[31:24];
            _udp_checksum_data_valid        =   1;
            _process_counter                =   process_counter - 1;
            timeout_cycle_timer_load_count  =   1;

            if  (process_counter == 0) begin
                _state              =   S_GET_UDP_DESTINATION;
                _process_counter    =   3;
            end
        end
        S_GET_IPV4_DESTINATION: begin
            if (data_enable) begin
                _ipv4_destination[31:8]         =   ipv4_destination[23:0];
                _ipv4_destination[7:0]          =   data[7:0];
                _udp_checksum_data              =   data[7:0];
                _udp_checksum_data_valid        =   1;
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
        S_CHECKSUM_ZEROS: begin
            _udp_checksum_data              =   0;
            _udp_checksum_data_valid        =   1;
            _state                          =   S_CHECKSUM_IPV4_PROTOCOL;
        end
        S_CHECKSUM_IPV4_PROTOCOL: begin
            _udp_checksum_data              =   IPV4_PROTOCOL_UDP;
            _udp_checksum_data_valid        =   1;
            _state                          =   S_GET_UDP_TOTAL_PAYLOAD_SIZE;
        end
        S_GET_UDP_TOTAL_PAYLOAD_SIZE: begin
            if (data_enable) begin
                _udp_total_payload_size[15:8]   =   udp_total_payload_size[7:0];
                _udp_total_payload_size[7:0]    =   data[7:0];
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _data_ready         =   0;
                    _state              =   S_CHECKSUM_UDP_LENGTH_0;
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
        S_CHECKSUM_UDP_LENGTH_0: begin
            _number_of_udp_bytes_left       =   udp_total_payload_size;
            _udp_checksum_data              =   udp_header_size_field[15:8];
            _udp_checksum_data_valid        =   1;
            _state                          =   S_CHECKSUM_UDP_LENGTH_1;
        end
        S_CHECKSUM_UDP_LENGTH_1: begin
            _udp_checksum_data              =   udp_header_size_field[7:0];
            _udp_checksum_data_valid        =   1;
            _state                          =   S_GET_UDP_SOURCE;
        end
        S_GET_UDP_SOURCE: begin
            if (data_enable) begin
                _udp_source[15:8]               =   udp_source[7:0];
                _udp_source[7:0]                =   data[7:0];
                _udp_checksum_data              =   data;
                _udp_checksum_data_valid        =   1;
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _state              =   S_GET_UDP_DESTINATION;
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
        S_GET_UDP_DESTINATION: begin
            if (data_enable) begin
                _udp_destination[15:8]          =   udp_destination[7:0];
                _udp_destination[7:0]           =   data[7:0];
                _udp_checksum_data              =   data;
                _udp_checksum_data_valid        =   1;
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _state              =   S_CHECKSUM_UDP_LENGTH_AGAIN_0;
                    _process_counter    =   1;
                end
                if (data[8]) begin
                    _data_ready             =   0;
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
        S_CHECKSUM_UDP_LENGTH_AGAIN_0: begin
            _udp_checksum_data              =   udp_header_size_field[15:8];
            _udp_checksum_data_valid        =   1;
            _state                          =   S_CHECKSUM_UDP_LENGTH_AGAIN_1;
        end
        S_CHECKSUM_UDP_LENGTH_AGAIN_1: begin
            _udp_checksum_data              =   udp_header_size_field[7:0];
            _udp_checksum_data_valid        =   1;
            _process_counter                =   udp_total_payload_size;
            _udp_buffer_write_address       =   '1;
            _state                          =   S_GET_UDP_DATA;
        end
        S_GET_UDP_DATA: begin
            if (data_enable) begin
                _data_ready                     =   1;
                _udp_checksum_data              =   data[7:0];
                _udp_checksum_data_valid        =   1;
                _udp_buffer_data                =   data[7:0];
                _udp_buffer_data_valid          =   1;
                _udp_buffer_write_address       =   udp_buffer_write_address + 1;
                _process_counter                =   process_counter - 1;
                timeout_cycle_timer_load_count  =   1;

                if  (process_counter == 0) begin
                    _state                  =   S_SET_FRAGMENT_SETTINGS;
                    _udp_checksum_data_last =   1;
                    _process_counter        =   1;
                end
                if (data[8]) begin
                    _data_ready             =   0;
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
        S_SET_FRAGMENT_SETTINGS: begin
            if (number_of_udp_bytes_left > MAX_PAYLOAD_SIZE) begin
                _udp_fragment_size          = MAX_PAYLOAD_SIZE;
                _number_of_udp_bytes_left   = number_of_udp_bytes_left - MAX_PAYLOAD_SIZE;
                _ipv4_flags[15:13]          = 3'b001;
            end
            else begin
                _ipv4_flags[15:13]          = 3'b000;
                _udp_fragment_size          = number_of_udp_bytes_left;
                _number_of_udp_bytes_left   = 0;
            end

                timeout_cycle_timer_load_count  =   1;
            _state                              = S_ENABLE_TRANSMIT;
        end
        S_ENABLE_TRANSMIT: begin
            if (enable) begin
                _transmit_valid                 =   1;
                timeout_cycle_timer_load_count  =   1;
                _state                          =   S_WAIT_TRANSMIT_BUSY;
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_WAIT_TRANSMIT_BUSY: begin
            if (!enable) begin
                timeout_cycle_timer_load_count  =   1;
                _state  =   S_WAIT_TRANSMIT_DONE;
            end
            if (timeout_cycle_timer_expired) begin
                _data_ready = 0;
                _state      = S_IDLE;
            end
        end
        S_WAIT_TRANSMIT_DONE: begin
            if (enable) begin
                if (number_of_udp_bytes_left == 0) begin
                    _ipv4_identification = ipv4_identification + 1;
                    _state               =  S_IDLE;
                end
                else begin
                    _ipv4_flags[12:0]   = ipv4_flags[12:0] + 184;
                    _state              = S_SET_FRAGMENT_SETTINGS;
                end
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
        udp_buffer_data             <=  0;
        udp_buffer_data_valid       <=  0;
        data_ready                  <=  0;
        transmit_valid              <=  0;
        ipv4_flags                  <=  0;
        ipv4_identification         <=  0;
        number_of_udp_bytes_left    <=  0;
        saved_ipv4_source           <=  0;
        udp_buffer_write_address    <=  0;
        udp_checksum_data           <=  0;
        udp_checksum_data_valid     <=  0;
        udp_total_payload_size      <=  0;
        udp_checksum_data_last      <=  0;
        udp_fragment_size           <=  0;
    end
    else begin
        state                       <=  _state;
        process_counter             <=  _process_counter;
        mac_destination             <=  _mac_destination;
        ipv4_destination            <=  _ipv4_destination;
        udp_destination             <=  _udp_destination;
        udp_source                  <=  _udp_source;
        udp_buffer_data             <=  _udp_buffer_data;
        udp_buffer_data_valid       <=  _udp_buffer_data_valid;
        data_ready                  <=  _data_ready;
        transmit_valid              <=  _transmit_valid;
        ipv4_flags                  <=  _ipv4_flags;
        ipv4_identification         <=  _ipv4_identification;
        number_of_udp_bytes_left    <=  _number_of_udp_bytes_left;
        saved_ipv4_source           <=  _saved_ipv4_source;
        udp_buffer_write_address    <=  _udp_buffer_write_address;
        udp_checksum_data           <=  _udp_checksum_data;
        udp_checksum_data_valid     <=  _udp_checksum_data_valid;
        udp_checksum_data_last      <=  _udp_checksum_data_last;
        udp_total_payload_size      <=  _udp_total_payload_size;
        udp_fragment_size           <=  _udp_fragment_size;
    end
end

endmodule