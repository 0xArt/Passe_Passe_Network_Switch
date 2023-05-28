`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/29/2023
// Design Name:
// Module Name: rmii_port
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
module rmii_port#(
    parameter RECEIVE_QUE_SLOTS = 1
)(
    input   wire            clock,
    input   wire            core_clock,
    input   wire            reset_n,
    input   wire    [1:0]   rmii_receive_data,
    input   wire            rmii_receive_data_enable,
    input   wire            rmii_receive_data_error,
    input   wire    [8:0]   transmit_data,
    input   wire            transmit_data_enable,
    input   wire            receive_data_enable,

    output  wire    [8:0]   receive_data,
    output  wire            receive_data_valid,
    output  wire    [1:0]   rmii_transmit_data,
    output  wire            rmii_transmit_data_valid
);


genvar i;

wire            rmii_byte_packager_clock;
wire            rmii_byte_packager_reset_n;
wire    [1:0]   rmii_byte_packager_data;
wire            rmii_byte_packager_data_enable;
wire    [8:0]   rmii_byte_packager_packaged_data;
wire    [1:0]   rmii_byte_packager_speed_code;
wire            rmii_byte_packager_packaged_data_valid;
wire            rmii_byte_packager_data_error;

rmii_byte_packager rmii_byte_packager(
    .clock                  (rmii_byte_packager_clock),
    .reset_n                (rmii_byte_packager_reset_n),
    .data                   (rmii_byte_packager_data),
    .data_enable            (rmii_byte_packager_data_enable),
    .data_error             (rmii_byte_packager_data_error),

    .speed_code             (rmii_byte_packager_speed_code),
    .packaged_data          (rmii_byte_packager_packaged_data),
    .packaged_data_valid    (rmii_byte_packager_packaged_data_valid)
);


wire            frame_fifo_clock;
wire            frame_fifo_reset_n;
wire            frame_fifo_read_enable;
wire    [8:0]   frame_fifo_write_data;
wire            frame_fifo_write_enable;
wire    [8:0]   frame_fifo_read_data;
wire            frame_fifo_read_data_valid;
wire            frame_fifo_full;
wire            frame_fifo_empty;

synchronous_fifo
#(.DATA_WIDTH   (9),
  .DATA_DEPTH   (1500)
) frame_fifo(
    .clock              (frame_fifo_clock),
    .reset_n            (frame_fifo_reset_n),
    .read_enable        (frame_fifo_read_enable),
    .write_enable       (frame_fifo_write_enable),
    .write_data         (frame_fifo_write_data),

    .read_data          (frame_fifo_read_data),
    .read_data_valid    (frame_fifo_read_data_valid),
    .full               (frame_fifo_full),
    .empty              (frame_fifo_empty)
);


wire                                ethernet_packet_parser_clock;
wire                                ethernet_packet_parser_reset_n;
wire    [8:0]                       ethernet_packet_parser_data;
wire                                ethernet_packet_parser_data_enable;
wire    [31:0]                      ethernet_packet_parser_checksum_result;
wire                                ethernet_packet_parser_checksum_result_enable;
wire                                ethernet_packet_parser_checksum_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_recieve_slot_enable;
wire    [1:0]                       ethernet_packet_parser_speed_code;
wire                                ethernet_packet_parser_data_ready;
wire    [7:0]                       ethernet_packet_parser_checksum_data;
wire                                ethernet_packet_parser_checksum_data_valid;
wire                                ethernet_packet_parser_checksum_data_last;
wire    [7:0]                       ethernet_packet_parser_packet_data;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_packet_data_valid;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_good_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]     ethernet_packet_parser_bad_packet;

ethernet_packet_parser   #(.RECEIVE_QUE_SLOTS(RECEIVE_QUE_SLOTS))
ethernet_packet_parser(
    .clock                  (ethernet_packet_parser_clock),
    .reset_n                (ethernet_packet_parser_reset_n),
    .data                   (ethernet_packet_parser_data),
    .data_enable            (ethernet_packet_parser_data_enable),
    .checksum_result        (ethernet_packet_parser_checksum_result),
    .checksum_result_enable (ethernet_packet_parser_checksum_result_enable),
    .checksum_enable        (ethernet_packet_parser_checksum_enable),
    .recieve_slot_enable    (ethernet_packet_parser_recieve_slot_enable),
    .speed_code             (ethernet_packet_parser_speed_code),

    .data_ready             (ethernet_packet_parser_data_ready),
    .checksum_data          (ethernet_packet_parser_checksum_data),
    .checksum_data_valid    (ethernet_packet_parser_checksum_data_valid),
    .checksum_data_last     (ethernet_packet_parser_checksum_data_last),
    .packet_data            (ethernet_packet_parser_packet_data),
    .packet_data_valid      (ethernet_packet_parser_packet_data_valid),
    .good_packet            (ethernet_packet_parser_good_packet),
    .bad_packet             (ethernet_packet_parser_bad_packet)
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


wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_clock;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_reset_n;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_enable;
wire    [RECEIVE_QUE_SLOTS-1:0][7:0]   que_slot_receieve_handler_data;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_data_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_good_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_push_data_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_bad_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_fifo_reset_n;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_ready;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_push_data_ready;
wire    [RECEIVE_QUE_SLOTS-1:0][8:0]   que_slot_receieve_handler_push_data;
wire    [RECEIVE_QUE_SLOTS-1:0]        que_slot_receieve_handler_push_data_valid;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        que_slot_receieve_handler que_slot_receieve_handler(
            .clock              (que_slot_receieve_handler_clock[i]),
            .reset_n            (que_slot_receieve_handler_reset_n[i]),
            .enable             (que_slot_receieve_handler_enable[i]),
            .data               (que_slot_receieve_handler_data[i]),
            .data_enable        (que_slot_receieve_handler_data_enable[i]),
            .good_packet        (que_slot_receieve_handler_good_packet[i]),
            .bad_packet         (que_slot_receieve_handler_bad_packet[i]),
            .push_data_enable   (que_slot_receieve_handler_push_data_enable[i]),

            .fifo_reset_n       (que_slot_receieve_handler_fifo_reset_n[i]),
            .ready              (que_slot_receieve_handler_ready[i]),
            .push_data_ready    (que_slot_receieve_handler_push_data_ready[i]),
            .push_data          (que_slot_receieve_handler_push_data[i]),
            .push_data_valid    (que_slot_receieve_handler_push_data_valid[i])
        );
    end
endgenerate


wire                                    receive_slot_arbiter_clock;
wire                                    receive_slot_arbiter_reset_n;
wire    [RECEIVE_QUE_SLOTS-1:0]         receive_slot_arbiter_enable;
wire    [RECEIVE_QUE_SLOTS-1:0][8:0]    receive_slot_arbiter_data;
wire    [RECEIVE_QUE_SLOTS-1:0]         receive_slot_arbiter_data_enable;
wire                                    receive_slot_arbiter_push_data_ready;
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

wire    [8:0]   outbound_fifo_write_data;
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
    .DATA       (outbound_fifo_write_data),
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


wire            rmii_byte_shipper_clock;
wire            rmii_byte_shipper_reset_n;
wire    [8:0]   rmii_byte_shipper_data;
wire            rmii_byte_shipper_data_enable;
wire    [1:0]   rmii_byte_shipper_speed_code;
wire    [1:0]   rmii_byte_shipper_shipped_data;
wire            rmii_byte_shipper_shipped_data_valid;
wire            rmii_byte_shipper_data_ready;

rmii_byte_shipper rmii_byte_shipper(
    .clock              (rmii_byte_shipper_clock),
    .reset_n            (rmii_byte_shipper_reset_n),
    .data               (rmii_byte_shipper_data),
    .data_enable        (rmii_byte_shipper_data_enable),
    .speed_code         (rmii_byte_shipper_speed_code),

    .shipped_data       (rmii_byte_shipper_shipped_data),
    .shipped_data_valid (rmii_byte_shipper_shipped_data_valid),
    .data_ready         (rmii_byte_shipper_data_ready)
);


wire    [8:0]   inbound_fifo_write_data;
wire            inbound_fifo_read_clock;
wire            inbound_fifo_read_enable;
wire            inbound_fifo_read_reset_n;
wire            inbound_fifo_write_clock;
wire            inbound_fifo_write_enable;
wire            inbound_fifo_write_reset_n;
wire            inbound_fifo_read_data_valid;
wire            inbound_fifo_empty;
wire            inbound_fifo_full;
wire    [8:0]   inbound_fifo_read_data;

COREFIFO_C2 inbound_fifo(
    .DATA       (inbound_fifo_write_data),
    .RCLOCK     (inbound_fifo_read_clock),
    .RE         (inbound_fifo_read_enable),
    .RRESET_N   (inbound_fifo_read_reset_n),
    .WCLOCK     (inbound_fifo_write_clock),
    .WE         (inbound_fifo_write_enable),
    .WRESET_N   (inbound_fifo_write_reset_n),

    .DVLD       (inbound_fifo_read_data_valid),
    .EMPTY      (inbound_fifo_empty),
    .FULL       (inbound_fifo_full),
    .Q          (inbound_fifo_read_data)
);


assign  receive_data_valid                                      =   outbound_fifo_read_data_valid;
assign  receive_data                                            =   outbound_fifo_read_data;
assign  rmii_transmit_data                                      =   rmii_byte_shipper_shipped_data;
assign  rmii_transmit_data_valid                                =   rmii_byte_shipper_shipped_data_valid;

assign  inbound_fifo_write_data                                 =   transmit_data;
assign  inbound_fifo_read_clock                                 =   clock;
assign  inbound_fifo_read_enable                                =   rmii_byte_shipper_data_ready;
assign  inbound_fifo_read_reset_n                               =   reset_n;
assign  inbound_fifo_write_clock                                =   clock;
assign  inbound_fifo_write_enable                               =   transmit_data_enable;
assign  inbound_fifo_write_reset_n                              =   reset_n;

assign  rmii_byte_shipper_clock                                 =   clock;
assign  rmii_byte_shipper_reset_n                               =   reset_n;
assign  rmii_byte_shipper_data                                  =   inbound_fifo_read_data;
assign  rmii_byte_shipper_data_enable                           =   inbound_fifo_read_data_valid;
assign  rmii_byte_shipper_speed_code                            =   rmii_byte_packager_speed_code;

assign  receive_slot_arbiter_clock                              =   clock;
assign  receive_slot_arbiter_reset_n                            =   reset_n;
assign  receive_slot_arbiter_enable                             =   que_slot_receieve_handler_ready;
assign  receive_slot_arbiter_data                               =   que_slot_receieve_handler_push_data;
assign  receive_slot_arbiter_data_enable                        =   que_slot_receieve_handler_push_data_valid;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        assign  que_slot_receieve_handler_clock[i]              =   clock;
        assign  que_slot_receieve_handler_reset_n[i]            =   reset_n;
        assign  que_slot_receieve_handler_enable[i]             =   receive_slot_arbiter_ready[i];
        assign  que_slot_receieve_handler_data[i]               =   payload_fifo_read_data[i];
        assign  que_slot_receieve_handler_data_enable[i]        =   payload_fifo_read_data_valid[i];
        assign  que_slot_receieve_handler_good_packet[i]        =   ethernet_packet_parser_good_packet[i];
        assign  que_slot_receieve_handler_bad_packet[i]         =   ethernet_packet_parser_bad_packet[i];
        assign  que_slot_receieve_handler_push_data_enable[i]   =  !outbound_fifo_full;
    end
endgenerate

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        assign  payload_fifo_clock[i]                           =   clock;
        assign  payload_fifo_write_data[i]                      =   ethernet_packet_parser_packet_data;
        assign  payload_fifo_write_enable[i]                    =   ethernet_packet_parser_packet_data_valid[i];
        assign  payload_fifo_read_enable[i]                     =   que_slot_receieve_handler_push_data_ready[i];
        assign  payload_fifo_reset_n[i]                         =   que_slot_receieve_handler_fifo_reset_n[i];
    end
endgenerate

assign  frame_fifo_read_clock                                   =   clock;
assign  frame_fifo_reset_n                                      =   reset_n;
assign  frame_fifo_data                                         =   rmii_byte_packager_packaged_data;
assign  frame_fifo_read_enable                                  =   ethernet_packet_parser_data_ready;
assign  frame_fifo_write_clock                                  =   clock;
assign  frame_fifo_write_enable                                 =   rmii_byte_packager_packaged_data_valid;

assign  rmii_byte_packager_clock                                =   clock;
assign  rmii_byte_packager_reset_n                              =   reset_n;
assign  rmii_byte_packager_data                                 =   rmii_receive_data;
assign  rmii_byte_packager_data_enable                          =   rmii_receive_data_enable;
assign  rmii_byte_packager_data_error                           =   rmii_receive_data_error;

assign  ethernet_packet_parser_clock                            =   clock;
assign  ethernet_packet_parser_reset_n                          =   reset_n;
assign  ethernet_packet_parser_data                             =   frame_fifo_read_data;
assign  ethernet_packet_parser_data_enable                      =   frame_fifo_read_data_valid;
assign  ethernet_packet_parser_checksum_result                  =   frame_check_sequence_generator_checksum;
assign  ethernet_packet_parser_checksum_result_enable           =   frame_check_sequence_generator_checksum_valid;
assign  ethernet_packet_parser_checksum_enable                  =   frame_check_sequence_generator_ready;
assign  ethernet_packet_parser_speed_code                       =   rmii_byte_packager_speed_code;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i=i+1) begin
        assign  ethernet_packet_parser_recieve_slot_enable[i]   =    payload_fifo_empty[i];
    end
endgenerate

assign  frame_check_sequence_generator_clock                    =   clock;
assign  frame_check_sequence_generator_reset_n                  =   reset_n;
assign  frame_check_sequence_generator_data                     =   ethernet_packet_parser_checksum_data;
assign  frame_check_sequence_generator_data_enable              =   ethernet_packet_parser_checksum_data_valid;
assign  frame_check_sequence_generator_data_last                =   ethernet_packet_parser_checksum_data_last;

assign  outbound_fifo_write_data                                =   receive_slot_arbiter_push_data;
assign  outbound_fifo_read_clock                                =   core_clock;
assign  outbound_fifo_read_enable                               =   receive_data_enable;
assign  outbound_fifo_read_reset_n                              =   reset_n;
assign  outbound_fifo_write_clock                               =   clock;
assign  outbound_fifo_write_enable                              =   receive_slot_arbiter_push_data_valid;
assign  outbound_fifo_write_reset_n                             =   reset_n;

endmodule