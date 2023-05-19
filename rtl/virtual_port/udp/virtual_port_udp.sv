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
    input   wire    [8:0]   virtual_port_receive_data,
    input   wire            virtual_port_receive_data_enable,
    input   wire    [8:0]   transmit_data,
    input   wire            transmit_data_enable,
    input   wire            receive_data_enable,

    output  wire            transmit_data_ready,
    output  wire     [8:0]  receive_data,
    output  wire            receive_data_valid,
);


genvar i;


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


wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_clock;
wire    [RECEIVE_QUE_SLOTS-1:0][7:0]   payload_fifo_write_data;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_read_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_reset_n;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_write_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_read_data_valid;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_empty;
wire    [RECEIVE_QUE_SLOTS-1:0]        payload_fifo_full;
wire    [RECEIVE_QUE_SLOTS-1:0][7:0]   payload_fifo_read_data;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        COREFIFO_C1 payload_fifo(
            .CLK        (payload_fifo_clock[i]),
            .DATA       (payload_fifo_write_data[i]),
            .RE         (payload_fifo_read_enable[i]),
            .RESET_N    (payload_fifo_reset_n[i]),
            .WE         (payload_fifo_write_enable[i]),

            .DVLD       (payload_fifo_read_data_valid[i]),
            .EMPTY      (payload_fifo_empty[i]),
            .FULL       (payload_fifo_full[i]),
            .Q          (payload_fifo_read_data[i])
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


wire    [8:0]   outbound_fifo_data;
wire            outbound_fifo_read_clock;
wire            outbound_fifo_read_enable;
wire            outbound_fifo_read_reset_n;
wire            outbound_fifo_write_clock;
wire            outbound_fifo_write_enable;
wire            outbound_fifo_write_reset_n;
wire            outbound_fifo_read_data_valid;
wire            outbound_fifo_empty;
wire            outbound_fifo_full;
wire    [8:0]   outbound_fifo_read_data;

COREFIFO_C2 outbound_fifo(
    .DATA       (outbound_fifo_data),
    .RCLOCK     (outbound_fifo_read_clock),
    .RE         (outbound_fifo_read_enable),
    .RRESET_N   (outbound_fifo_read_reset_n),
    .WCLOCK     (outbound_fifo_write_clock),
    .WE         (outbound_fifo_write_enable),
    .WRESET_N   (outbound_fifo_write_reset_n),

    .DVLD       (outbound_fifo_read_data_valid),
    .EMPTY      (outbound_fifo_empty),
    .FULL       (outbound_fifo_full),
    .Q          (outbound_fifo_read_data)
);


wire            udp_transmit_handler_clock;
wire            udp_transmit_handler_reset_n;
wire            udp_transmit_handler_enable;
wire            udp_transmit_handler_data_enable;
wire            udp_transmit_handler_udp_data_enable;
wire            udp_transmit_handler_data_ready;
wire    [47:0]  udp_transmit_handler_mac_destination;
wire    [31:0]  udp_transmit_handler_ipv4_destination;
wire    [15:0]  udp_transmit_handler_udp_destination;
wire    [15:0]  udp_transmit_handler_udp_source;
wire    [15:0]  udp_transmit_handler_ipv4_identification;
wire    [15:0]  udp_transmit_handler_ipv4_flags;
wire    [15:0]  udp_transmit_handler_udp_data_size;
wire    [7:0]   udp_transmit_handler_udp_data;
wire            udp_transmit_handler_udp_data_valid;
wire            udp_transmit_handler_transmit_valid;
wire            udp_transmit_handler_ready;

udp_transmit_handler udp_transmit_handler(
    .clock                  (udp_transmit_handler_clock),
    .reset_n                (udp_transmit_handler_reset_n),
    .enable                 (udp_transmit_handler_enable),
    .data_enable            (udp_transmit_handler_data_enable),
    .udp_data_enable        (udp_transmit_handler_udp_data_enable),

    .data_ready             (udp_transmit_handler_data_ready),
    .mac_destination        (udp_transmit_handler_mac_destination),
    .ipv4_destination       (udp_transmit_handler_ipv4_destination),
    .udp_destination        (udp_transmit_handler_udp_destination),
    .udp_source             (udp_transmit_handler_udp_source),
    .ipv4_identification    (udp_transmit_handler_ipv4_identification),
    .ipv4_flags             (udp_transmit_handler_ipv4_flags),
    .udp_data_size          (udp_transmit_handler_udp_data_size),
    .udp_data               (udp_transmit_handler_udp_data),
    .udp_data_valid         (udp_transmit_handler_udp_data_valid),
    .transmit_valid         (udp_transmit_handler_transmit_valid),
    .ready                  (udp_transmit_handler_ready)
);


assign  receive_data_valid                                      =   outbound_fifo_read_data_valid;
assign  receive_data                                            =   outbound_fifo_read_data;
assign  transmit_data_ready                                     =   0;

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
        assign  udp_receieve_handler_push_data_enable           =   !outbound_fifo_full
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
assign  ethernet_frame_parser_data                              =   virtual_port_receive_data;
assign  ethernet_frame_parser_data_enable                       =   virtual_port_receive_data_enable;
assign  ethernet_frame_parser_checksum_result                   =   frame_check_sequence_generator_checksum;
assign  ethernet_frame_parser_checksum_result_enable            =   frame_check_sequence_generator_checksum_valid;
assign  ethernet_frame_parser_checksum_enable                   =   frame_check_sequence_generator_ready;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i=i+1) begin
        assign  ethernet_frame_parser_recieve_slot_enable[i]    =    payload_fifo_empty[i];
    end
endgenerate

assign  frame_check_sequence_generator_clock                    =   clock;
assign  frame_check_sequence_generator_reset_n                  =   reset_n;
assign  frame_check_sequence_generator_data                     =   ethernet_frame_parser_checksum_data;
assign  frame_check_sequence_generator_data_enable              =   ethernet_frame_parser_checksum_data_valid;
assign  frame_check_sequence_generator_data_last                =   ethernet_frame_parser_checksum_data_last;

assign  outbound_fifo_data                                      =   receive_slot_arbiter_push_data;
assign  outbound_fifo_read_clock                                =   clock;
assign  outbound_fifo_read_enable                               =   receive_data_enable;
assign  outbound_fifo_read_reset_n                              =   reset_n;
assign  outbound_fifo_write_clock                               =   clock;
assign  outbound_fifo_write_enable                              =   receive_slot_arbiter_push_data_valid;
assign  outbound_fifo_write_reset_n                             =   reset_n;

assign  udp_transmit_handler_clock                              =   clock;
assign  udp_transmit_handler_reset_n                            =   reset_n;
assign  udp_transmit_handler_enable                             =   0; //TODO ready from frame pusher
assign  udp_transmit_handler_data_enable                        =   transmit_data_enable;
assign  udp_transmit_handler_data                               =   transmit_data;
assign  udp_transmit_handler_udp_data_enable                    =   0; //TODO from frame pusher

endmodule