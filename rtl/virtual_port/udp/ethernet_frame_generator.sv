`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 07/02/2023
// Design Name: 
// Module Name: ethernet_frame_generator
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
module ethernet_frame_generator(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire                            enable,
    input   wire    [31:0]                  checksum_result,
    input   wire                            checksum_result_enable,
    input   wire    [15:0]                  ipv4_checksum_result,
    input   wire                            ipv4_checksum_result_enable,
    input   wire    [7:0]                   udp_buffer_read_data,
    input   wire    [47:0]                  mac_destination,
    input   wire    [47:0]                  mac_source,
    input   wire    [31:0]                  ipv4_destination,
    input   wire    [31:0]                  ipv4_source,
    input   wire    [15:0]                  udp_checksum,
    input   wire    [15:0]                  udp_destination,
    input   wire    [15:0]                  udp_source,
    input   wire    [15:0]                  ipv4_flags,
    input   wire    [15:0]                  ipv4_identification,
    input   wire    [15:0]                  udp_payload_size,
    input   wire    [15:0]                  udp_fragment_size,

    output  logic   [7:0]                   checksum_data,
    output  logic                           checksum_data_valid,
    output  reg                             checksum_data_last,
    output  logic   [7:0]                   frame_data,
    output  logic                           frame_data_valid,
    output  reg     [7:0]                   ipv4_checksum_data,
    output  reg                             ipv4_checksum_data_valid,
    output  reg                             ipv4_checksum_data_last,
    output  reg     [15:0]                  udp_buffer_read_address,
    output  reg                             ready
);


localparam logic [15:0] TIMEOUT_LIMIT                       = 16'h000F;
localparam logic [15:0] IPV4_ETHERNET_TYPE                  = 16'h0800;
localparam logic [7:0]  IPV4_VERSION_HEADER_LNEGTH          = 8'h45;
localparam logic [7:0]  IPV4_DIFFERENTIATED_SERVICES_FIELD  = 8'h00;
localparam logic [7:0]  IPV4_TIME_TO_LIVE                   = 8'h80;
localparam logic [7:0]  IPV4_PROTOCOL_UDP                   = 8'h11;


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


wire            process_cycle_timer_clock;
wire            process_cycle_timer_reset_n;
wire            process_cycle_timer_enable;
logic           process_cycle_timer_load_count;
logic  [15:0]   process_cycle_timer_count;
wire            process_cycle_timer_expired;

cycle_timer process_cycle_timer(
    .clock      (process_cycle_timer_clock),
    .reset_n    (process_cycle_timer_reset_n),
    .enable     (process_cycle_timer_enable),
    .load_count (process_cycle_timer_load_count),
    .count      (process_cycle_timer_count),

    .expired    (process_cycle_timer_expired)
);


typedef enum
{
    S_IDLE,
    S_CHECKSUM_IPV4_VERSION_HEADER_LNEGTH,
    S_CHECKSUM_IPV4_DIFFERENTIATED_SERVICES_FIELD,
    S_CHECKSUM_IPV4_TOTAL_LENGTH,
    S_CHECKSUM_IPV4_TOTAL_LENGTH_0,
    S_CHECKSUM_IPV4_TOTAL_LENGTH_1,
    S_CHECKSUM_IPV4_IDENTIFICATION_MSB,
    S_CHECKSUM_IPV4_IDENTIFICATION_LSB,
    S_CHECKSUM_IPV4_FLAGS_MSB,
    S_CHECKSUM_IPV4_FLAGS_LSB,
    S_CHECKSUM_IPV4_TIME_TO_LIVE,
    S_CHECKSUM_IPV4_PROTOCOL,
    S_CHECKSUM_IPV4_SOURCE_ADDRESS_0,
    S_CHECKSUM_IPV4_SOURCE_ADDRESS_1,
    S_CHECKSUM_IPV4_SOURCE_ADDRESS_2,
    S_CHECKSUM_IPV4_SOURCE_ADDRESS_3,
    S_CHECKSUM_IPV4_DESTINATION_ADDRESS_0,
    S_CHECKSUM_IPV4_DESTINATION_ADDRESS_1,
    S_CHECKSUM_IPV4_DESTINATION_ADDRESS_2,
    S_CHECKSUM_IPV4_DESTINATION_ADDRESS_3,
    S_MAC_DESINTATION,
    S_MAC_SOURCE,
    S_ETHERNET_TYPE_MSB,
    S_ETHERNET_TYPE_LSB,
    S_IPV4_VERSION_HEADER_LNEGTH,
    S_IPV4_DIFFERENTIATED_SERVICES_FIELD,
    S_IPV4_TOTAL_LENGTH,
    S_IPV4_IDENTIFICATION_MSB,
    S_IPV4_IDENTIFICATION_LSB,
    S_IPV4_FLAGS_MSB,
    S_IPV4_FLAGS_LSB,
    S_IPV4_TIME_TO_LIVE,
    S_IPV4_PROTOCOL,
    S_IPV4_CHECKSUM_MSB,
    S_IPV4_CHECKSUM_LSB,
    S_IPV4_SOURCE_ADDRESS,
    S_IPV4_DESTINATION_ADDRESS,
    S_UDP_SOURCE_PORT,
    S_UDP_DESTINATION_PORT,
    S_UDP_LENGTH,
    S_UDP_CHECKSUM_MSB,
    S_UDP_CHECKSUM_LSB,
    S_UDP_DATA,
    S_PUSH_CRC,
    S_PAD
} state_type;

state_type                              _state;
state_type                              state;
integer                                 i;
integer                                 j;
logic                                   _ready;
reg     [7:0]                           process_counter;
logic   [7:0]                           _process_counter;
reg     [47:0]                          saved_mac_destination;
logic   [47:0]                          _saved_mac_destination;
reg     [47:0]                          saved_mac_source;
logic   [47:0]                          _saved_mac_source;
reg     [31:0]                          saved_ipv4_destination;
logic   [31:0]                          _saved_ipv4_destination;
reg     [31:0]                          saved_ipv4_source;
logic   [31:0]                          _saved_ipv4_source;
reg     [15:0]                          saved_udp_destination;
logic   [15:0]                          _saved_udp_destination;
reg     [15:0]                          saved_ipv4_checksum;
logic   [15:0]                          _saved_ipv4_checksum;
reg     [15:0]                          saved_udp_source;
logic   [15:0]                          _saved_udp_source;
reg     [15:0]                          saved_udp_payload_size;
logic   [15:0]                          _saved_udp_payload_size;
reg     [15:0]                          saved_udp_fragment_size;
logic   [15:0]                          _saved_udp_fragment_size;
reg     [15:0]                          ipv4_total_length;
logic   [15:0]                          _ipv4_total_length;
reg     [15:0]                          udp_total_length;
logic   [15:0]                          _udp_total_length;
logic                                   _ipv4_checksum_data_last;
logic                                   _udp_checksum_data_last;
logic                                   _ipv4_checksum_data_valid;
reg     [15:0]                          frame_total_length;
logic   [15:0]                          _frame_total_length;
reg     [31:0]                          saved_checksum_result;
logic   [31:0]                          _saved_checksum_result;
reg     [15:0]                          saved_ipv4_flags;
logic   [15:0]                          _saved_ipv4_flags;
reg     [15:0]                          saved_ipv4_identification;
logic   [15:0]                          _saved_ipv4_identification;
logic                                   _checksum_data_last;
reg     [15:0]                          _saved_udp_checksum;
logic   [15:0]                          saved_udp_checksum;
logic   [15:0]                          _ipv4_checksum_data;
logic   [15:0]                          _udp_buffer_read_address;
logic   [2:0][7:0]                      _frame_byte;
reg     [2:0][7:0]                      frame_byte;
logic   [2:0]                           _frame_byte_valid;
reg     [2:0]                           frame_byte_valid;


assign  process_cycle_timer_clock       =   clock;
assign  process_cycle_timer_reset_n     =   reset_n;
assign  process_cycle_timer_enable      =   1;

assign  timeout_cycle_timer_clock       =   clock;
assign  timeout_cycle_timer_reset_n     =   reset_n;
assign  timeout_cycle_timer_enable      =   1;
assign  timeout_cycle_timer_count       =   TIMEOUT_LIMIT;


always_comb begin
    _state                              =   state;
    _process_counter                    =   process_counter;
    _ready                              =   ready;
    _saved_mac_destination              =   saved_mac_destination;
    _saved_mac_source                   =   saved_mac_source;
    _saved_ipv4_destination             =   saved_ipv4_destination;
    _saved_ipv4_source                  =   saved_ipv4_source;
    _saved_udp_destination              =   saved_udp_destination;
    _saved_udp_source                   =   saved_udp_source;
    _saved_udp_payload_size             =   saved_udp_payload_size;
    _saved_udp_fragment_size            =   saved_udp_fragment_size;
    _ipv4_total_length                  =   ipv4_total_length;
    _udp_total_length                   =   udp_total_length;
    _udp_buffer_read_address            =   udp_buffer_read_address;
    _frame_total_length                 =   frame_total_length;
    _saved_checksum_result              =   saved_checksum_result;
    _saved_ipv4_flags                   =   saved_ipv4_flags;
    _saved_ipv4_identification          =   saved_ipv4_identification;
    _saved_ipv4_checksum                =   saved_ipv4_checksum;
    _saved_udp_checksum                 =   saved_udp_checksum;
    _ipv4_checksum_data                 =   ipv4_checksum_data;
    _frame_byte[2]                      =   frame_byte[1];
    _frame_byte[1]                      =   frame_byte[0];
    _frame_byte[0]                      =   frame_byte[0];
    _frame_byte_valid[2]                =   frame_byte_valid[1];
    _frame_byte_valid[1]                =   frame_byte_valid[0];
    _frame_byte_valid[0]                =   0;
    checksum_data                       =   frame_byte[0];
    _checksum_data_last                 =   0;
    _ipv4_checksum_data_valid           =   0;
    _ipv4_checksum_data_last            =   0;
    _udp_checksum_data_last             =   0;
    process_cycle_timer_load_count      =   0;
    process_cycle_timer_count           =   0;
    timeout_cycle_timer_load_count      =   0;

    frame_data          =   frame_byte[2];
    frame_data_valid    =   frame_byte_valid[2];

    if (state == S_PUSH_CRC && process_counter != 0) begin
        frame_data          =   frame_byte[0];
        frame_data_valid    =   frame_byte_valid[0];
    end

    checksum_data_valid =   0;

    if (state != S_PUSH_CRC && state != S_IDLE) begin
        checksum_data_valid =   frame_byte_valid[0];
    end
    if (state == S_PUSH_CRC && process_counter == 0) begin
        checksum_data_valid =   frame_byte_valid[0];
    end

    case (state)
        S_IDLE: begin
            _ready                              =   1;
            _saved_mac_destination              =   mac_destination;
            _saved_mac_source                   =   mac_source;
            _saved_ipv4_destination             =   ipv4_destination;
            _saved_ipv4_source                  =   ipv4_source;
            _saved_udp_destination              =   udp_destination;
            _saved_udp_source                   =   udp_source;
            _saved_udp_payload_size             =   udp_payload_size;
            _saved_udp_fragment_size            =   udp_fragment_size;
            _frame_total_length                 =   frame_total_length;
            _saved_ipv4_flags                   =   ipv4_flags;
            _saved_ipv4_identification          =   ipv4_identification;
            _saved_udp_checksum                 =   udp_checksum;
            _udp_buffer_read_address            =   0;

            if (enable) begin
                process_cycle_timer_count       =   7;
                process_cycle_timer_load_count  =   1;
                _ready                          =   0;
                _state                          =   S_CHECKSUM_IPV4_VERSION_HEADER_LNEGTH;
            end
        end
        S_CHECKSUM_IPV4_VERSION_HEADER_LNEGTH: begin
            _ipv4_checksum_data         =   IPV4_VERSION_HEADER_LNEGTH;
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_DIFFERENTIATED_SERVICES_FIELD;
        end
        S_CHECKSUM_IPV4_DIFFERENTIATED_SERVICES_FIELD: begin
            _ipv4_checksum_data         =   IPV4_DIFFERENTIATED_SERVICES_FIELD;
            _ipv4_checksum_data_valid   =   1;
            _ipv4_total_length          =   saved_udp_fragment_size + 28;
            _state                      =   S_CHECKSUM_IPV4_TOTAL_LENGTH_0;
        end
        S_CHECKSUM_IPV4_TOTAL_LENGTH_0: begin
            _ipv4_checksum_data         =   ipv4_total_length[15:8];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_TOTAL_LENGTH_1;
        end
        S_CHECKSUM_IPV4_TOTAL_LENGTH_1: begin
            _ipv4_checksum_data         =   ipv4_total_length[7:0];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_IDENTIFICATION_MSB;
        end
        S_CHECKSUM_IPV4_IDENTIFICATION_MSB: begin
            _ipv4_checksum_data         =   saved_ipv4_identification[15:8];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_IDENTIFICATION_LSB;
        end
        S_CHECKSUM_IPV4_IDENTIFICATION_LSB: begin
            _ipv4_checksum_data         =   saved_ipv4_identification[7:0];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_FLAGS_MSB;
        end
        S_CHECKSUM_IPV4_FLAGS_MSB: begin
            _ipv4_checksum_data         =   saved_ipv4_flags[15:8];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_FLAGS_LSB;
        end
        S_CHECKSUM_IPV4_FLAGS_LSB: begin
            _ipv4_checksum_data         =   saved_ipv4_flags[7:0];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_TIME_TO_LIVE;
        end
        S_CHECKSUM_IPV4_TIME_TO_LIVE: begin
            _ipv4_checksum_data         =   IPV4_TIME_TO_LIVE;
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_PROTOCOL;
        end
        S_CHECKSUM_IPV4_PROTOCOL: begin
            _ipv4_checksum_data         =   IPV4_PROTOCOL_UDP;
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_SOURCE_ADDRESS_0;
        end
        S_CHECKSUM_IPV4_SOURCE_ADDRESS_0: begin
            _ipv4_checksum_data         =   saved_ipv4_source[31:24];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_SOURCE_ADDRESS_1;
        end
        S_CHECKSUM_IPV4_SOURCE_ADDRESS_1: begin
            _ipv4_checksum_data         =   saved_ipv4_source[23:16];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_SOURCE_ADDRESS_2;
        end
        S_CHECKSUM_IPV4_SOURCE_ADDRESS_2: begin
            _ipv4_checksum_data         =   saved_ipv4_source[15:8];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_SOURCE_ADDRESS_3;
        end
        S_CHECKSUM_IPV4_SOURCE_ADDRESS_3: begin
            _ipv4_checksum_data         =   saved_ipv4_source[7:0];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_DESTINATION_ADDRESS_0;
        end
        S_CHECKSUM_IPV4_DESTINATION_ADDRESS_0: begin
            _ipv4_checksum_data         =   saved_ipv4_destination[31:24];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_DESTINATION_ADDRESS_1;
        end
        S_CHECKSUM_IPV4_DESTINATION_ADDRESS_1: begin
            _ipv4_checksum_data         =   saved_ipv4_destination[23:16];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_DESTINATION_ADDRESS_2;
        end
        S_CHECKSUM_IPV4_DESTINATION_ADDRESS_2: begin
            _ipv4_checksum_data         =   saved_ipv4_destination[15:8];
            _ipv4_checksum_data_valid   =   1;
            _state                      =   S_CHECKSUM_IPV4_DESTINATION_ADDRESS_3;
        end
        S_CHECKSUM_IPV4_DESTINATION_ADDRESS_3: begin
            _ipv4_checksum_data             =   saved_ipv4_destination[7:0];
            _ipv4_checksum_data_valid       =   1;
            _ipv4_checksum_data_last        =   1;
            process_cycle_timer_count       =   5;
            process_cycle_timer_load_count  =   1;
            _state                          =   S_MAC_DESINTATION;
        end
        S_MAC_DESINTATION: begin
            if (ipv4_checksum_result_enable) begin
                _saved_ipv4_checksum    =   ipv4_checksum_result;
            end
            _frame_byte[0]          =   saved_mac_destination[47:40];
            _frame_byte_valid[0]    =   1;
            _saved_mac_destination  =   {saved_mac_destination[39:0],8'h00};

            if (process_cycle_timer_expired) begin
                _state                          =   S_MAC_SOURCE;
                process_cycle_timer_count       =   5;
                process_cycle_timer_load_count  =   1;
            end
        end
        S_MAC_SOURCE: begin
            _frame_byte[0]          =   saved_mac_source[47:40];
            _frame_byte_valid[0]    =   1;
            _saved_mac_source       =   {saved_mac_source[39:0],8'h00};

            if (process_cycle_timer_expired) begin
                _state              =   S_ETHERNET_TYPE_MSB;
            end
        end
        S_ETHERNET_TYPE_MSB: begin
            _frame_byte[0]          =   IPV4_ETHERNET_TYPE[15:8];
            _frame_byte_valid[0]    =   1;
            _state                  =   S_ETHERNET_TYPE_LSB;
        end
        S_ETHERNET_TYPE_LSB: begin
            _frame_byte[0]          =   IPV4_ETHERNET_TYPE[7:0];
            _frame_byte_valid[0]    =   1;
            _state                  =   S_IPV4_VERSION_HEADER_LNEGTH;
        end
        S_IPV4_VERSION_HEADER_LNEGTH: begin
            _frame_byte[0]          =   IPV4_VERSION_HEADER_LNEGTH;
            _frame_byte_valid[0]    =   1;
            _state                  =   S_IPV4_DIFFERENTIATED_SERVICES_FIELD;
        end
        S_IPV4_DIFFERENTIATED_SERVICES_FIELD: begin
            _frame_byte[0]                  =   IPV4_DIFFERENTIATED_SERVICES_FIELD;
            _frame_byte_valid[0]            =   1;
            process_cycle_timer_count       =   1;
            process_cycle_timer_load_count  =   1;
            _state                          =   S_IPV4_TOTAL_LENGTH;
        end
        S_IPV4_TOTAL_LENGTH: begin
            _frame_byte[0]              =   ipv4_total_length[15:8];
            _frame_byte_valid[0]        =   1;
            _ipv4_total_length          =   {ipv4_total_length[7:0],8'h00};

            if (process_cycle_timer_expired) begin
                _state              =   S_IPV4_IDENTIFICATION_MSB;
            end
        end
        S_IPV4_IDENTIFICATION_MSB: begin
            _frame_byte[0]              =   saved_ipv4_identification[15:8];
            _frame_byte_valid[0]        =   1;
            _state                      =   S_IPV4_IDENTIFICATION_LSB;
        end
        S_IPV4_IDENTIFICATION_LSB: begin
            _frame_byte[0]              =   saved_ipv4_identification[7:0];
            _frame_byte_valid[0]        =   1;
            _state                      =   S_IPV4_FLAGS_MSB;
        end
        S_IPV4_FLAGS_MSB: begin
            _frame_byte[0]              =   saved_ipv4_flags[15:8];
            _frame_byte_valid[0]        =   1;
            _state                      =   S_IPV4_FLAGS_LSB;
        end
        S_IPV4_FLAGS_LSB: begin
            _frame_byte[0]              =   saved_ipv4_flags[7:0];
            _frame_byte_valid[0]        =   1;
            _state                      =   S_IPV4_TIME_TO_LIVE;
        end
        S_IPV4_TIME_TO_LIVE: begin
            _frame_byte[0]              =   IPV4_TIME_TO_LIVE;
            _frame_byte_valid[0]        =   1;
            _state                      =   S_IPV4_PROTOCOL;
        end
        S_IPV4_PROTOCOL: begin
            _frame_byte[0]              =   IPV4_PROTOCOL_UDP;
            _frame_byte_valid[0]        =   1;
            _state                      =   S_IPV4_CHECKSUM_MSB;
        end
        S_IPV4_CHECKSUM_MSB: begin
            _frame_byte[0]          =   saved_ipv4_checksum[15:8];
            _frame_byte_valid[0]    =   1;
            _state                  =   S_IPV4_CHECKSUM_LSB;
        end
        S_IPV4_CHECKSUM_LSB: begin
            _frame_byte[0]                  =   saved_ipv4_checksum[7:0];
            _frame_byte_valid[0]            =   1;
            process_cycle_timer_count       =   4;
            process_cycle_timer_load_count  =   1;
            _state                          =   S_IPV4_SOURCE_ADDRESS;
        end
        S_IPV4_SOURCE_ADDRESS: begin
            _frame_byte[0]              =   saved_ipv4_source[31:24];
            _frame_byte_valid[0]        =   1;
            _saved_ipv4_source          =   {saved_ipv4_source[23:0],8'h00};

            if (process_cycle_timer_expired) begin
                process_cycle_timer_count       =   3;
                process_cycle_timer_load_count  =   1;
                _state                          =   S_IPV4_DESTINATION_ADDRESS;
            end
        end
        S_IPV4_DESTINATION_ADDRESS: begin
            _frame_byte[0]              =   saved_ipv4_destination[31:24];
            _frame_byte_valid[0]        =   1;
            _saved_ipv4_destination     =   {saved_ipv4_destination[23:0],8'h00};

            if (process_cycle_timer_expired) begin
                process_cycle_timer_count       =   1;
                process_cycle_timer_load_count  =   1;

                if (saved_ipv4_flags[12:0] == 0) begin
                    _state  =   S_UDP_SOURCE_PORT;
                end
                else begin
                    process_cycle_timer_count       =   saved_udp_fragment_size - 1;
                    timeout_cycle_timer_load_count  =   1;
                    _state                          =   S_UDP_DATA;
                end
            end
        end
        S_UDP_SOURCE_PORT: begin
            _frame_byte[0]              =   saved_udp_source[15:8];
            _frame_byte_valid[0]        =   1;
            _saved_udp_source           =   {saved_udp_source[7:0],8'h00};

            if (process_cycle_timer_expired) begin
                process_cycle_timer_count       =   1;
                process_cycle_timer_load_count  =   1;
                _state                          =   S_UDP_DESTINATION_PORT;
            end
        end
        S_UDP_DESTINATION_PORT: begin
            _frame_byte[0]                  =   saved_udp_destination[15:8];
            _frame_byte_valid[0]            =   1;
            _saved_udp_destination          =   {saved_udp_destination[7:0],8'h00};
            _udp_total_length               =   saved_udp_payload_size + 8;

            if (process_cycle_timer_expired) begin
                process_cycle_timer_count       =   1;
                process_cycle_timer_load_count  =   1;
                _state                          =   S_UDP_LENGTH;
            end
        end
        S_UDP_LENGTH: begin
            _frame_byte[0]              =   udp_total_length[15:8];
            _frame_byte_valid[0]        =   1;
            _udp_total_length           =   {udp_total_length[7:0],8'h00};

            if (process_cycle_timer_expired) begin
                _state              =   S_UDP_CHECKSUM_MSB;
            end
        end
        S_UDP_CHECKSUM_MSB: begin
            _frame_byte[0]              =   saved_udp_checksum[15:8];
            _frame_byte_valid[0]        =   1;
            _state                      =   S_UDP_CHECKSUM_LSB;
        end
        S_UDP_CHECKSUM_LSB: begin
            _frame_byte[0]                  =   saved_udp_checksum[7:0];
            _frame_byte_valid[0]            =   1;
            process_cycle_timer_count       =   saved_udp_fragment_size - 1;
            process_cycle_timer_load_count  =   1;
            timeout_cycle_timer_load_count  =   1;
            _udp_buffer_read_address        =   udp_buffer_read_address + 1;
            _state                          =   S_UDP_DATA;
        end
        S_UDP_DATA: begin
            _frame_byte[0]                 =   udp_buffer_read_data;
            _frame_byte_valid[0]           =   1;
            _udp_buffer_read_address       =   udp_buffer_read_address + 1;

            if (process_cycle_timer_expired) begin
                if (saved_udp_fragment_size < 26) begin
                    process_cycle_timer_count       =   26 - saved_udp_fragment_size;
                    process_cycle_timer_load_count  =   1;
                    _state                          =   S_PAD;
                end
                else begin
                    _process_counter                =   0;
                    _checksum_data_last             =   1;
                    _state                          =   S_PUSH_CRC;
                end
            end
        end
        S_PAD: begin
            _frame_byte[0]                 =   0;
            _frame_byte_valid[0]           =   1;

            if (process_cycle_timer_expired) begin
                _process_counter                =   0;
                _checksum_data_last             =   1;
                _state                          =   S_PUSH_CRC;
            end
        end
        S_PUSH_CRC: begin
            case (process_counter)
                0: begin
                    if (checksum_result_enable) begin
                        _frame_byte[0]          =   checksum_result[31:24];
                        _frame_byte_valid[0]    =   1;
                        _saved_checksum_result  =   checksum_result;
                        _process_counter        =   1;
                    end
                end
                1: begin
                    _frame_byte[0]          =   saved_checksum_result[23:16];
                    _frame_byte_valid[0]    =   1;
                    _process_counter        =   2;
                end
                2: begin
                    _frame_byte[0]          =   saved_checksum_result[15:8];
                    _frame_byte_valid[0]    =   1;
                    _process_counter        =   3;
                end
                3: begin
                    _frame_byte[0]          =   saved_checksum_result[7:0];
                    _frame_byte_valid[0]    =   1;
                    _process_counter        =   0;
                    _state                  =   S_IDLE;
                end
            endcase
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                           <=  S_IDLE;
        process_counter                 <=  0;
        saved_mac_destination           <=  0;
        saved_mac_source                <=  0;
        saved_ipv4_destination          <=  0;
        saved_ipv4_source               <=  0;
        saved_udp_destination           <=  0;
        saved_udp_source                <=  0;
        saved_udp_fragment_size         <=  0;
        saved_udp_payload_size          <=  0;
        ipv4_total_length               <=  0;
        udp_total_length                <=  0;
        ready                           <=  0;
        ipv4_checksum_data              <=  0;
        ipv4_checksum_data_last         <=  0;
        ipv4_checksum_data_valid        <=  0;
        udp_buffer_read_address         <=  0;
        frame_total_length              <=  0;
        saved_checksum_result           <=  0;
        saved_ipv4_flags                <=  0;
        checksum_data_last              <=  0;
        saved_udp_checksum              <=  0;
        saved_ipv4_checksum             <=  0;
        frame_byte[0]                   <=  0;
        frame_byte[1]                   <=  0;
        frame_byte[2]                   <=  0;
        frame_byte[3]                   <=  0;
        frame_byte_valid[0]             <=  0;
        frame_byte_valid[1]             <=  0;
        frame_byte_valid[2]             <=  0;
        frame_byte_valid[3]             <=  0;
    end
    else begin
        state                           <=  _state;
        process_counter                 <=  _process_counter;
        saved_mac_destination           <=  _saved_mac_destination;
        saved_mac_source                <=  _saved_mac_source;
        saved_ipv4_destination          <=  _saved_ipv4_destination;
        saved_ipv4_source               <=  _saved_ipv4_source;
        saved_udp_destination           <=  _saved_udp_destination;
        saved_udp_source                <=  _saved_udp_source;
        saved_udp_fragment_size         <=  _saved_udp_fragment_size;
        saved_udp_payload_size          <=  _saved_udp_payload_size;
        ipv4_total_length               <=  _ipv4_total_length;
        udp_total_length                <=  _udp_total_length;
        ready                           <=  _ready;
        ipv4_checksum_data              <=  _ipv4_checksum_data;
        ipv4_checksum_data_last         <=  _ipv4_checksum_data_last;
        ipv4_checksum_data_valid        <=  _ipv4_checksum_data_valid;
        udp_buffer_read_address         <=  _udp_buffer_read_address;
        frame_total_length              <=  _frame_total_length;
        saved_checksum_result           <=  _saved_checksum_result;
        saved_ipv4_flags                <=  _saved_ipv4_flags;
        saved_ipv4_identification       <=  _saved_ipv4_identification;
        checksum_data_last              <=  _checksum_data_last;
        saved_udp_checksum              <=  _saved_udp_checksum;
        saved_ipv4_checksum             <=  _saved_ipv4_checksum;
        frame_byte[0]                   <=  _frame_byte[0];
        frame_byte[1]                   <=  _frame_byte[1];
        frame_byte[2]                   <=  _frame_byte[2];
        frame_byte_valid[0]             <=  _frame_byte_valid[0];
        frame_byte_valid[1]             <=  _frame_byte_valid[1];
        frame_byte_valid[2]             <=  _frame_byte_valid[2];
    end
end

endmodule