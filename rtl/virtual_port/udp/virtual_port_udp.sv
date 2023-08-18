//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
//
// Create Date: 04/29/2023
// Design Name:
// Module Name: virutal_port_udp
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
module virutal_port_udp#(
    parameter RECEIVE_QUE_SLOTS = 1
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [47:0]  mac_source,
    input   wire    [31:0]  ipv4_source,
    input   wire    [8:0]   receive_data,                       //from switch data orch
    input   wire            receive_data_enable,                //from switch data orch
    input   wire            transmit_data_enable,               //from switch data orch
    input   wire            module_clock,                       //clock domain of frabic modules
    input   wire    [8:0]   module_transmit_data,               //from fabric modules
    input   wire            module_transmit_data_enable,        //from fabric modules

    output  wire    [8:0]   module_receive_data,
    output  wire            module_receive_data_valid,
    output  wire            receive_data_ready,
    output  wire    [8:0]   transmit_data,                      //to switch data orch
    output  wire            transmit_data_valid                 //to switch data orch
);

genvar i;


wire            inbound_fifo_read_clock;
wire            inbound_fifo_read_reset_n;
wire            inbound_fifo_write_clock;
wire            inbound_fifo_write_reset_n;
wire            inbound_fifo_read_enable;
wire            inbound_fifo_write_enable;
wire    [8:0]   inbound_fifo_write_data;

wire    [8:0]   inbound_fifo_read_data;
wire            inbound_fifo_read_data_valid;
wire            inbound_fifo_full;
wire            inbound_fifo_empty;

asynchronous_fifo#(
    .DATA_WIDTH                 (9),
    .DATA_DEPTH                 (8192),
    .FIRST_WORD_FALL_THROUGH    (1)
)
inbound_fifo(
    .read_clock         (inbound_fifo_read_clock),
    .read_reset_n       (inbound_fifo_read_reset_n),
    .write_clock        (inbound_fifo_write_clock),
    .write_reset_n      (inbound_fifo_write_reset_n),
    .read_enable        (inbound_fifo_read_enable),
    .write_enable       (inbound_fifo_write_enable),
    .write_data         (inbound_fifo_write_data),

    .read_data          (inbound_fifo_read_data),
    .read_data_valid    (inbound_fifo_read_data_valid),
    .full               (inbound_fifo_full),
    .empty              (inbound_fifo_empty)
);


wire            udp_transmit_handler_clock;
wire            udp_transmit_handler_reset_n;
wire            udp_transmit_handler_enable;
wire    [8:0]   udp_transmit_handler_data;
wire            udp_transmit_handler_data_enable;
wire    [31:0]  udp_transmit_handler_ipv4_source;

wire            udp_transmit_handler_data_ready;
wire    [47:0]  udp_transmit_handler_mac_destination;
wire    [31:0]  udp_transmit_handler_ipv4_destination;
wire    [15:0]  udp_transmit_handler_udp_destination;
wire    [15:0]  udp_transmit_handler_udp_source;
wire    [15:0]  udp_transmit_handler_ipv4_identification;
wire    [15:0]  udp_transmit_handler_ipv4_flags;
wire    [15:0]  udp_transmit_handler_udp_fragment_size;
wire    [15:0]  udp_transmit_handler_udp_total_payload_size;
wire    [15:0]  udp_transmit_handler_udp_buffer_write_address;
wire    [7:0]   udp_transmit_handler_udp_buffer_data;
wire            udp_transmit_handler_udp_buffer_data_valid;
wire    [7:0]   udp_transmit_handler_udp_checksum_data;
wire            udp_transmit_handler_udp_checksum_data_valid;
wire            udp_transmit_handler_udp_checksum_data_last;
wire            udp_transmit_handler_transmit_valid;

udp_transmit_handler udp_transmit_handler(
    .clock                      (udp_transmit_handler_clock),
    .reset_n                    (udp_transmit_handler_reset_n),
    .enable                     (udp_transmit_handler_enable),
    .data                       (udp_transmit_handler_data),
    .data_enable                (udp_transmit_handler_data_enable),
    .ipv4_source                (udp_transmit_handler_ipv4_source),

    .data_ready                 (udp_transmit_handler_data_ready),
    .mac_destination            (udp_transmit_handler_mac_destination),
    .ipv4_destination           (udp_transmit_handler_ipv4_destination),
    .udp_destination            (udp_transmit_handler_udp_destination),
    .udp_source                 (udp_transmit_handler_udp_source),
    .ipv4_identification        (udp_transmit_handler_ipv4_identification),
    .ipv4_flags                 (udp_transmit_handler_ipv4_flags),
    .udp_fragment_size          (udp_transmit_handler_udp_fragment_size),
    .udp_total_payload_size     (udp_transmit_handler_udp_total_payload_size),
    .udp_buffer_write_address   (udp_transmit_handler_udp_buffer_write_address),
    .udp_buffer_data            (udp_transmit_handler_udp_buffer_data),
    .udp_buffer_data_valid      (udp_transmit_handler_udp_buffer_data_valid),
    .udp_checksum_data          (udp_transmit_handler_udp_checksum_data),
    .udp_checksum_data_valid    (udp_transmit_handler_udp_checksum_data_valid),
    .udp_checksum_data_last     (udp_transmit_handler_udp_checksum_data_last),
    .transmit_valid             (udp_transmit_handler_transmit_valid)
);


wire            udp_checksum_calculator_clock;
wire            udp_checksum_calculator_reset_n;
wire    [7:0]   udp_checksum_calculator_data;
wire            udp_checksum_calculator_data_enable;
wire            udp_checksum_calculator_data_last;

wire    [15:0]  udp_checksum_calculator_result;
wire            udp_checksum_calculator_result_valid;
wire            udp_checksum_calculator_ready;

internet_checksum_calculator    udp_checksum_calculator(
    .clock                      (udp_checksum_calculator_clock),
    .reset_n                    (udp_checksum_calculator_reset_n),
    .data                       (udp_checksum_calculator_data),
    .data_enable                (udp_checksum_calculator_data_enable),
    .data_last                  (udp_checksum_calculator_data_last),

    .result                     (udp_checksum_calculator_result),
    .result_valid               (udp_checksum_calculator_result_valid),
    .ready                      (udp_checksum_calculator_ready)
);


wire            udp_data_buffer_clock;
wire            udp_data_buffer_reset_n;
wire            udp_data_buffer_write_enable;
wire    [7:0]   udp_data_buffer_write_data;
wire    [15:0]  udp_data_buffer_write_address;
wire    [15:0]  udp_data_buffer_read_address;

wire    [7:0]   udp_data_buffer_read_data;

generic_block_ram
#(.DATA_WIDTH       (8),
  .DATA_DEPTH       (65535),
  .PIPELINED_OUTPUT (0)
)
udp_data_buffer(
    .clock                  (udp_data_buffer_clock),
    .reset_n                (udp_data_buffer_reset_n),
    .write_enable           (udp_data_buffer_write_enable),
    .write_data             (udp_data_buffer_write_data),
    .write_address          (udp_data_buffer_write_address),
    .read_address           (udp_data_buffer_read_address),

    .read_data              (udp_data_buffer_read_data)
);


wire            ethernet_frame_generator_clock;
wire            ethernet_frame_generator_reset_n;
wire            ethernet_frame_generator_enable;
wire    [31:0]  ethenret_frame_generator_checksum_result;
wire            ethernet_frame_generator_checksum_result_enable;
wire    [15:0]  ethernet_frame_generator_ipv4_checksum_result;
wire            ethernet_frame_generator_ipv4_checksum_result_enable;
wire    [7:0]   ethernet_frame_generator_udp_buffer_read_data;
wire    [47:0]  ethernet_frame_generator_mac_destination;
wire    [47:0]  ethernet_frame_generator_mac_source;
wire    [31:0]  ethernet_frame_generator_ipv4_destination;
wire    [31:0]  ethernet_frame_generator_ipv4_source;
wire    [15:0]  ethernet_frame_generator_udp_checksum;
wire    [15:0]  ethernet_frame_generator_udp_destination;
wire    [15:0]  ethernet_frame_generator_udp_source;
wire    [15:0]  ethernet_frame_generator_udp_payload_size;
wire    [15:0]  ethernet_frame_generator_udp_fragment_size;
wire    [15:0]  ethernet_frame_generator_ipv4_flags;
wire    [15:0]  ethernet_frame_generator_ipv4_identification;

wire    [7:0]   ethernet_frame_generator_checksum_data;
wire            ethernet_frame_generator_checksum_data_valid;
wire            ethernet_frame_generator_checksum_data_last;
wire    [8:0]   ethernet_frame_generator_frame_data;
wire            ethernet_frame_generator_frame_data_valid;
wire    [7:0]   ethernet_frame_generator_ipv4_checksum_data;
wire            ethernet_frame_generator_ipv4_checksum_data_valid;
wire            ethernet_frame_generator_ipv4_checksum_data_last;
wire    [15:0]  ethernet_frame_generator_udp_buffer_read_address;
wire            ethernet_frame_generator_ready;


ethernet_frame_generator    ethernet_frame_generator(
    .clock                          (ethernet_frame_generator_clock),
    .reset_n                        (ethernet_frame_generator_reset_n),
    .enable                         (ethernet_frame_generator_enable),
    .checksum_result                (ethenret_frame_generator_checksum_result),
    .checksum_result_enable         (ethernet_frame_generator_checksum_result_enable),
    .ipv4_checksum_result           (ethernet_frame_generator_ipv4_checksum_result),
    .ipv4_checksum_result_enable    (ethernet_frame_generator_ipv4_checksum_result_enable),
    .udp_buffer_read_data           (ethernet_frame_generator_udp_buffer_read_data),
    .mac_destination                (ethernet_frame_generator_mac_destination),
    .mac_source                     (ethernet_frame_generator_mac_source),
    .ipv4_destination               (ethernet_frame_generator_ipv4_destination),
    .ipv4_source                    (ethernet_frame_generator_ipv4_source),
    .udp_checksum                   (ethernet_frame_generator_udp_checksum),
    .udp_destination                (ethernet_frame_generator_udp_destination),
    .udp_source                     (ethernet_frame_generator_udp_source),
    .udp_payload_size               (ethernet_frame_generator_udp_payload_size),
    .udp_fragment_size              (ethernet_frame_generator_udp_fragment_size),
    .ipv4_flags                     (ethernet_frame_generator_ipv4_flags),
    .ipv4_identification            (ethernet_frame_generator_ipv4_identification),

    .checksum_data                  (ethernet_frame_generator_checksum_data),
    .checksum_data_valid            (ethernet_frame_generator_checksum_data_valid),
    .checksum_data_last             (ethernet_frame_generator_checksum_data_last),
    .frame_data                     (ethernet_frame_generator_frame_data),
    .frame_data_valid               (ethernet_frame_generator_frame_data_valid),
    .ipv4_checksum_data             (ethernet_frame_generator_ipv4_checksum_data),
    .ipv4_checksum_data_valid       (ethernet_frame_generator_ipv4_checksum_data_valid),
    .ipv4_checksum_data_last        (ethernet_frame_generator_ipv4_checksum_data_last),
    .udp_buffer_read_address        (ethernet_frame_generator_udp_buffer_read_address),
    .ready                          (ethernet_frame_generator_ready)
);


wire            ipv4_checksum_calculator_clock;
wire            ipv4_checksum_calculator_reset_n;
wire    [7:0]   ipv4_checksum_calculator_data;
wire            ipv4_checksum_calculator_data_enable;
wire            ipv4_checksum_calculator_data_last;

wire    [15:0]  ipv4_checksum_calculator_result;
wire            ipv4_checksum_calculator_result_valid;
wire            ipv4_checksum_calculator_ready;

internet_checksum_calculator    ipv4_checksum_calculator(
    .clock                      (ipv4_checksum_calculator_clock),
    .reset_n                    (ipv4_checksum_calculator_reset_n),
    .data                       (ipv4_checksum_calculator_data),
    .data_enable                (ipv4_checksum_calculator_data_enable),
    .data_last                  (ipv4_checksum_calculator_data_last),

    .result                     (ipv4_checksum_calculator_result),
    .result_valid               (ipv4_checksum_calculator_result_valid),
    .ready                      (ipv4_checksum_calculator_ready)
);


wire            frame_check_sequence_generator_clock;
wire            frame_check_sequence_generator_reset_n;
wire    [7:0]   frame_check_sequence_generator_data;
wire            frame_check_sequence_generator_data_enable;
wire            frame_check_sequence_generator_data_last;

wire            frame_check_sequence_generator_ready;
wire    [31:0]  frame_check_sequence_generator_checksum;
wire            frame_check_sequence_generator_checksum_valid;

frame_check_sequence_generator  frame_check_sequence_generator(
    .clock                  (frame_check_sequence_generator_clock),
    .reset_n                (frame_check_sequence_generator_reset_n),
    .data                   (frame_check_sequence_generator_data),
    .data_enable            (frame_check_sequence_generator_data_enable),
    .data_last              (frame_check_sequence_generator_data_last),

    .ready                  (frame_check_sequence_generator_ready),
    .checksum               (frame_check_sequence_generator_checksum),
    .checksum_valid         (frame_check_sequence_generator_checksum_valid)
);


wire                                ethernet_frame_parser_clock;
wire                                ethernet_frame_parser_reset_n;
wire    [8:0]                       ethernet_frame_parser_data;
wire                                ethernet_frame_parser_data_enable;
wire    [31:0]                      ethernet_frame_parser_checksum_result;
wire                                ethernet_frame_parser_checksum_result_enable;
wire                                ethernet_frame_parser_checksum_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_frame_parser_recieve_slot_enable;

wire                                ethernet_frame_parser_data_ready;
wire    [7:0]                       ethernet_frame_parser_checksum_data;
wire                                ethernet_frame_parser_checksum_data_valid;
wire                                ethernet_frame_parser_checksum_data_last;
wire    [7:0]                       ethernet_frame_parser_packet_data;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_frame_parser_packet_data_valid;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_frame_parser_good_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_frame_parser_bad_packet;
wire    [15:0]                      ethernet_frame_parser_udp_destination;

ethernet_frame_parser   #(.RECEIVE_QUE_SLOTS(RECEIVE_QUE_SLOTS))
ethernet_frame_parser(
    .clock                  (ethernet_frame_parser_clock),
    .reset_n                (ethernet_frame_parser_reset_n),
    .data                   (ethernet_frame_parser_data),
    .data_enable            (ethernet_frame_parser_data_enable),
    .checksum_result        (ethernet_frame_parser_checksum_result),
    .checksum_result_enable (ethernet_frame_parser_checksum_result_enable),
    .checksum_enable        (ethernet_frame_parser_checksum_enable),
    .recieve_slot_enable    (ethernet_frame_parser_recieve_slot_enable),

    .data_ready             (ethernet_frame_parser_data_ready),
    .checksum_data          (ethernet_frame_parser_checksum_data),
    .checksum_data_valid    (ethernet_frame_parser_checksum_data_valid),
    .checksum_data_last     (ethernet_frame_parser_checksum_data_last),
    .packet_data            (ethernet_frame_parser_packet_data),
    .packet_data_valid      (ethernet_frame_parser_packet_data_valid),
    .good_packet            (ethernet_frame_parser_good_packet),
    .bad_packet             (ethernet_frame_parser_bad_packet),
    .udp_destination        (ethernet_frame_parser_udp_destination)
);


wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_clock;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_reset_n;
wire    [RECEIVE_QUE_SLOTS-1:0][7:0]   payload_fifo_write_data;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_read_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_write_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_read_data_valid;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_empty;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_full;
wire    [RECEIVE_QUE_SLOTS-1:0][7:0]   payload_fifo_read_data;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        synchronous_fifo
        #(  .DATA_WIDTH   (8),
            .DATA_DEPTH   (1024)
        ) payload_fifo(
            .clock              (payload_fifo_clock[i]),
            .reset_n            (payload_fifo_reset_n[i]),
            .read_enable        (payload_fifo_read_enable[i]),
            .write_enable       (payload_fifo_write_enable[i]),
            .write_data         (payload_fifo_write_data[i]),

            .read_data          (payload_fifo_read_data[i]),
            .read_data_valid    (payload_fifo_read_data_valid[i]),
            .full               (payload_fifo_full[i]),
            .empty              (payload_fifo_empty[i])
        );
    end
endgenerate


wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_clock;
wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_reset_n;
wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_enable;
wire    [RECEIVE_QUE_SLOTS-1:0][7:0]   udp_receieve_handler_data;
wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_data_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_good_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_bad_packet;
wire    [RECEIVE_QUE_SLOTS-1:0][15:0]  udp_receieve_handler_udp_destination;
wire    [RECEIVE_QUE_SLOTS-1:0][15:0]  udp_receieve_handler_push_data_enable;

wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_fifo_reset_n;
wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_ready;
wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_push_data_ready;
wire    [RECEIVE_QUE_SLOTS-1:0][8:0]   udp_receieve_handler_push_data;
wire    [RECEIVE_QUE_SLOTS-1:0]        udp_receieve_handler_push_data_valid;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        udp_receieve_handler udp_receieve_handler(
            .clock              (udp_receieve_handler_clock[i]),
            .reset_n            (udp_receieve_handler_reset_n[i]),
            .enable             (udp_receieve_handler_enable[i]),
            .data               (udp_receieve_handler_data[i]),
            .data_enable        (udp_receieve_handler_data_enable[i]),
            .good_packet        (udp_receieve_handler_good_packet[i]),
            .bad_packet         (udp_receieve_handler_bad_packet[i]),
            .udp_destination    (udp_receieve_handler_udp_destination[i]),
            .push_data_enable   (udp_receieve_handler_push_data_enable[i]),

            .fifo_reset_n       (udp_receieve_handler_fifo_reset_n[i]),
            .ready              (udp_receieve_handler_ready[i]),
            .push_data_ready    (udp_receieve_handler_push_data_ready[i]),
            .push_data          (udp_receieve_handler_push_data[i]),
            .push_data_valid    (udp_receieve_handler_push_data_valid[i])
        );
    end
endgenerate


wire                                    receive_slot_arbiter_clock;
wire                                    receive_slot_arbiter_reset_n;
wire    [RECEIVE_QUE_SLOTS-1:0]         receive_slot_arbiter_enable;
wire    [RECEIVE_QUE_SLOTS-1:0][8:0]    receive_slot_arbiter_data;
wire    [RECEIVE_QUE_SLOTS-1:0]         receive_slot_arbiter_data_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]         receive_slot_arbiter_ready;
wire    [8:0]                           receive_slot_arbiter_push_data;
wire                                    receive_slot_arbiter_push_data_valid;

receive_slot_arbiter #(.RECEIVE_QUE_SLOTS(RECEIVE_QUE_SLOTS))
receive_slot_arbiter(
    .clock              (receive_slot_arbiter_clock),
    .reset_n            (receive_slot_arbiter_reset_n),
    .enable             (receive_slot_arbiter_enable),
    .data               (receive_slot_arbiter_data),
    .data_enable        (receive_slot_arbiter_data_enable),

    .ready              (receive_slot_arbiter_ready),
    .push_data          (receive_slot_arbiter_push_data),
    .push_data_valid    (receive_slot_arbiter_push_data_valid)
);


wire            outbound_fifo_read_clock;
wire            outbound_fifo_read_reset_n;
wire            outbound_fifo_write_clock;
wire            outbound_fifo_write_reset_n;
wire            outbound_fifo_read_enable;
wire            outbound_fifo_write_enable;
wire    [8:0]   outbound_fifo_write_data;

wire    [8:0]   outbound_fifo_read_data;
wire            outbound_fifo_read_data_valid;
wire            outbound_fifo_full;
wire            outbound_fifo_empty;

asynchronous_fifo#(
    .DATA_WIDTH                 (9),
    .DATA_DEPTH                 (8192),
    .FIRST_WORD_FALL_THROUGH    (1)
)
outbound_fifo(
    .read_clock         (outbound_fifo_read_clock),
    .read_reset_n       (outbound_fifo_read_reset_n),
    .write_clock        (outbound_fifo_write_clock),
    .write_reset_n      (outbound_fifo_write_reset_n),
    .read_enable        (outbound_fifo_read_enable),
    .write_enable       (outbound_fifo_write_enable),
    .write_data         (outbound_fifo_write_data),

    .read_data          (outbound_fifo_read_data),
    .read_data_valid    (outbound_fifo_read_data_valid),
    .full               (outbound_fifo_full),
    .empty              (outbound_fifo_empty)
);

assign  receive_data_ready                                      =   0;
assign  transmit_data                                           =   outbound_fifo_read_data;
assign  transmit_data_valid                                     =   outbound_fifo_read_data_valid;

assign  receive_slot_arbiter_clock                              =   clock;
assign  receive_slot_arbiter_reset_n                            =   reset_n;
assign  receive_slot_arbiter_enable                             =   udp_receieve_handler_ready;
assign  receive_slot_arbiter_data                               =   udp_receieve_handler_push_data;
assign  receive_slot_arbiter_data_enable                        =   udp_receieve_handler_push_data_valid;
assign  receive_slot_arbiter_push_data_ready                    =   !outbound_fifo_full;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        assign  udp_receieve_handler_clock[i]                   =   clock;
        assign  udp_receieve_handler_reset_n[i]                 =   reset_n;
        assign  udp_receieve_handler_enable[i]                  =   receive_slot_arbiter_ready[i];
        assign  udp_receieve_handler_data[i]                    =   payload_fifo_read_data[i];
        assign  udp_receieve_handler_data_enable[i]             =   payload_fifo_read_data_valid[i];
        assign  udp_receieve_handler_good_packet[i]             =   ethernet_frame_parser_good_packet[i];
        assign  udp_receieve_handler_bad_packet[i]              =   ethernet_frame_parser_bad_packet[i];
        assign  udp_receieve_handler_udp_destination[i]         =   ethernet_frame_parser_udp_destination;
        assign  udp_receieve_handler_push_data_enable[i]        =   !outbound_fifo_full;
    end
endgenerate

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        assign  payload_fifo_clock[i]                           =   clock;
        assign  payload_fifo_write_data[i]                      =   ethernet_frame_parser_packet_data;
        assign  payload_fifo_write_enable[i]                    =   ethernet_frame_parser_packet_data_valid[i];
        assign  payload_fifo_read_enable[i]                     =   udp_receieve_handler_push_data_ready[i];
        assign  payload_fifo_reset_n[i]                         =   udp_receieve_handler_fifo_reset_n[i];
    end
endgenerate

assign  ethernet_frame_parser_clock                             =   clock;
assign  ethernet_frame_parser_reset_n                           =   reset_n;
assign  ethernet_frame_parser_data                              =   receive_data;
assign  ethernet_frame_parser_data_enable                       =   receive_data_enable;
assign  ethernet_frame_parser_checksum_result                   =   frame_check_sequence_generator_checksum;
assign  ethernet_frame_parser_checksum_result_enable            =   frame_check_sequence_generator_checksum_valid;
assign  ethernet_frame_parser_checksum_enable                   =   frame_check_sequence_generator_ready;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i=i+1) begin
        assign  ethernet_frame_parser_recieve_slot_enable[i]    =   payload_fifo_empty[i];
    end
endgenerate

assign  outbound_fifo_read_clock                                =   clock;
assign  outbound_fifo_read_enable                               =   transmit_data_enable;
assign  outbound_fifo_read_reset_n                              =   reset_n;
assign  outbound_fifo_write_clock                               =   clock;
assign  outbound_fifo_write_data                                =   ethernet_frame_generator_frame_data;
assign  outbound_fifo_write_enable                              =   ethernet_frame_generator_frame_data_valid;
assign  outbound_fifo_write_reset_n                             =   reset_n;

assign  udp_transmit_handler_clock                              =   clock;
assign  udp_transmit_handler_reset_n                            =   reset_n;
assign  udp_transmit_handler_enable                             =   ethernet_frame_generator_ready;
assign  udp_transmit_handler_data_enable                        =   inbound_fifo_read_data_valid;
assign  udp_transmit_handler_data                               =   inbound_fifo_read_data;
assign  udp_transmit_handler_ipv4_source                        =   ipv4_source;

assign  inbound_fifo_read_clock                                 =   clock;
assign  inbound_fifo_read_reset_n                               =   reset_n;
assign  inbound_fifo_write_clock                                =   module_clock;
assign  inbound_fifo_write_reset_n                              =   reset_n;
assign  inbound_fifo_read_enable                                =   udp_transmit_handler_data_ready;
assign  inbound_fifo_write_enable                               =   module_transmit_data_enable;
assign  inbound_fifo_write_data                                 =   module_transmit_data;

assign  udp_data_buffer_clock                                   =   clock;
assign  udp_data_buffer_reset_n                                 =   reset_n;
assign  udp_data_buffer_write_enable                            =   udp_transmit_handler_udp_buffer_data_valid;
assign  udp_data_buffer_write_data                              =   udp_transmit_handler_udp_buffer_data;
assign  udp_data_buffer_write_address                           =   udp_transmit_handler_udp_buffer_write_address;
assign  udp_data_buffer_read_address                            =   ethernet_frame_generator_udp_buffer_read_address;

assign  udp_checksum_calculator_clock                           =   clock;
assign  udp_checksum_calculator_reset_n                         =   reset_n;
assign  udp_checksum_calculator_data                            =   udp_transmit_handler_udp_checksum_data;
assign  udp_checksum_calculator_data_enable                     =   udp_transmit_handler_udp_checksum_data_valid;
assign  udp_checksum_calculator_data_last                       =   udp_transmit_handler_udp_checksum_data_last;

assign  ethernet_frame_generator_clock                          =   clock;
assign  ethernet_frame_generator_reset_n                        =   reset_n;
assign  ethernet_frame_generator_enable                         =   udp_transmit_handler_transmit_valid;
assign  ethenret_frame_generator_checksum_result                =   frame_check_sequence_generator_checksum;
assign  ethernet_frame_generator_checksum_result_enable         =   frame_check_sequence_generator_checksum_valid;
assign  ethernet_frame_generator_ipv4_checksum_result           =   ipv4_checksum_calculator_result;
assign  ethernet_frame_generator_ipv4_checksum_result_enable    =   ipv4_checksum_calculator_result_valid;
assign  ethernet_frame_generator_udp_buffer_read_data           =   udp_data_buffer_read_data;
assign  ethernet_frame_generator_mac_destination                =   udp_transmit_handler_mac_destination;
assign  ethernet_frame_generator_mac_source                     =   mac_source;
assign  ethernet_frame_generator_ipv4_destination               =   udp_transmit_handler_ipv4_destination;
assign  ethernet_frame_generator_ipv4_source                    =   ipv4_source;
assign  ethernet_frame_generator_udp_checksum                   =   udp_checksum_calculator_result;
assign  ethernet_frame_generator_udp_destination                =   udp_transmit_handler_udp_destination;
assign  ethernet_frame_generator_udp_source                     =   udp_transmit_handler_udp_source;
assign  ethernet_frame_generator_udp_payload_size               =   udp_transmit_handler_udp_total_payload_size;
assign  ethernet_frame_generator_udp_fragment_size              =   udp_transmit_handler_udp_fragment_size;
assign  ethernet_frame_generator_ipv4_flags                     =   udp_transmit_handler_ipv4_flags;
assign  ethernet_frame_generator_ipv4_identification            =   udp_transmit_handler_ipv4_identification;

assign  ipv4_checksum_calculator_clock                          =   clock;
assign  ipv4_checksum_calculator_reset_n                        =   reset_n;
assign  ipv4_checksum_calculator_data                           =   ethernet_frame_generator_ipv4_checksum_data;
assign  ipv4_checksum_calculator_data_enable                    =   ethernet_frame_generator_ipv4_checksum_data_valid;
assign  ipv4_checksum_calculator_data_last                      =   ethernet_frame_generator_ipv4_checksum_data_last;

assign  frame_check_sequence_generator_clock                    =   clock;
assign  frame_check_sequence_generator_reset_n                  =   reset_n;
assign  frame_check_sequence_generator_data                     =   ethernet_frame_generator_checksum_data;
assign  frame_check_sequence_generator_data_enable              =   ethernet_frame_generator_checksum_data_valid;
assign  frame_check_sequence_generator_data_last                =   ethernet_frame_generator_checksum_data_last;

endmodule