`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
// 
// Create Date: 04/12/2023
// Design Name: 
// Module Name: rgmii_port
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
///
// EDUCATIONAL USE ONLY
//
// This source file is provided solely for educational, research, and non-commercial purposes.
//
// Commercial use, redistribution, sublicensing, modification for commercial products,
// or incorporation into proprietary software or hardware is strictly prohibited without prior
// written permission and a valid commercial license from the original creator.
//
// Unauthorized commercial use violates intellectual property and copyright laws.
//
// For licensing inquiries and commercial permissions, contact the creator directly.
//
//////////////////////////////////////////////////////////////////////////////////
module rgmii_port #(
    parameter TECHNOLOGY                    = "SIMULATION",
    parameter RECEIVE_QUE_SLOTS             = 2,
    parameter PHASE_SHIFT_TX_CLOCK_ENABLE   = 0
)(
    input   wire            core_clock,
    input   wire            core_reset_n,
    input   wire            phy_receive_reset_n,
    input   wire            phy_transmit_reset_n,
    input   wire    [3:0]   phy_receive_data,
    input   wire            phy_receive_data_control,
    input   wire            phy_receive_clock,
    input   wire    [8:0]   transmit_data,
    input   wire            transmit_data_enable,
    input   wire            receive_data_enable,
    input   wire            transmit_clock,

    output  reg             transmit_data_ready,
    output  wire    [8:0]   receive_data,
    output  wire            receive_data_valid,
    output  wire            phy_transmit_clock,
    output  wire            phy_transmit_clock_raw,
    output  wire            phy_transmit_data_valid,
    output  wire    [3:0]   phy_transmit_data
);

genvar i;

wire    rgmii_pll_clock;
wire    rgmii_pll_reset_n;

wire    rgmii_pll_phase_shifted_clock;
wire    rgmii_pll_lock;

generate 
    if (PHASE_SHIFT_TX_CLOCK_ENABLE) begin
        rgmii_pll#(
            .TECHNOLOGY                (TECHNOLOGY)
        )rgmii_pll(
            .clock                      (rgmii_pll_clock),
            .reset_n                    (rgmii_pll_reset_n),

            .phase_shifted_clock        (rgmii_pll_phase_shifted_clock),
            .lock                       (rgmii_pll_lock)
        );
    end
endgenerate


wire        rgmii_byte_packager_clock;
wire        rgmii_byte_packager_reset_n;
wire [3:0]  rgmii_byte_packager_data;
wire        rgmii_byte_packager_data_control;

wire [8:0]  rgmii_byte_packager_packaged_data;
wire        rgmii_byte_packager_packaged_data_valid;
wire [1:0]  rgmii_byte_packager_packaged_data_speed_code;

rgmii_byte_packager#(
    .TECHNOLOGY             (TECHNOLOGY) 
)rgmii_byte_packager(
    .clock                  (rgmii_byte_packager_clock),
    .reset_n                (rgmii_byte_packager_reset_n),
    .data                   (rgmii_byte_packager_data),
    .data_control           (rgmii_byte_packager_data_control),

    .packaged_data          (rgmii_byte_packager_packaged_data),
    .packaged_data_valid    (rgmii_byte_packager_packaged_data_valid),
    .speed_code             (rgmii_byte_packager_packaged_data_speed_code)
);


wire    [8:0]   phy_received_bytes_fifo_write_data;
wire            phy_received_bytes_fifo_read_clock;
wire            phy_received_bytes_fifo_read_enable;
wire            phy_received_bytes_fifo_read_reset_n;
wire            phy_received_bytes_fifo_write_clock;
wire            phy_received_bytes_fifo_write_enable;
wire            phy_received_bytes_fifo_write_reset_n;
wire            phy_received_bytes_fifo_read_data_valid;
wire            phy_received_bytes_fifo_empty;
wire            phy_received_bytes_fifo_full;
wire    [8:0]   phy_received_bytes_fifo_read_data;

asynchronous_fifo#(
    .DATA_WIDTH                 (9),
    .DATA_DEPTH                 (2048),
    .FIRST_WORD_FALL_THROUGH    (1),
    .TECHNOLOGY                 (TECHNOLOGY),
    .NUMBER_OF_CDC_STAGES       (2)
)
phy_received_bytes_fifo(
    .read_clock         (phy_received_bytes_fifo_read_clock),
    .read_reset_n       (phy_received_bytes_fifo_read_reset_n),
    .write_clock        (phy_received_bytes_fifo_write_clock),
    .write_reset_n      (phy_received_bytes_fifo_write_reset_n),
    .read_enable        (phy_received_bytes_fifo_read_enable),
    .write_enable       (phy_received_bytes_fifo_write_enable),
    .write_data         (phy_received_bytes_fifo_write_data),

    .read_data          (phy_received_bytes_fifo_read_data),
    .read_data_valid    (phy_received_bytes_fifo_read_data_valid),
    .full               (phy_received_bytes_fifo_full),
    .empty              (phy_received_bytes_fifo_empty)
);


wire                                    ethernet_packet_parser_clock;
wire                                    ethernet_packet_parser_reset_n;
wire    [8:0]                           ethernet_packet_parser_data;
wire                                    ethernet_packet_parser_data_enable;
wire    [31:0]                          ethernet_packet_parser_checksum_result;
wire                                    ethernet_packet_parser_checksum_result_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]         ethernet_packet_parser_receive_slot_enable;
wire    [1:0]                           ethernet_packet_parser_speed_code;

wire                                    ethernet_packet_parser_data_ready;
wire    [7:0]                           ethernet_packet_parser_checksum_data;
wire                                    ethernet_packet_parser_checksum_data_valid;
wire                                    ethernet_packet_parser_checksum_data_last;
wire    [7:0]                           ethernet_packet_parser_packet_data;
wire    [RECEIVE_QUE_SLOTS-1:0]         ethernet_packet_parser_packet_data_valid;
wire    [RECEIVE_QUE_SLOTS-1:0]         ethernet_packet_parser_good_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]         ethernet_packet_parser_bad_packet;
wire    [7:0]                           ethernet_packet_parser_next_que_slot;

ethernet_packet_parser   #(.RECEIVE_QUE_SLOTS(RECEIVE_QUE_SLOTS))
ethernet_packet_parser(
    .clock                  (ethernet_packet_parser_clock),
    .reset_n                (ethernet_packet_parser_reset_n),
    .data                   (ethernet_packet_parser_data),
    .data_enable            (ethernet_packet_parser_data_enable),
    .checksum_result        (ethernet_packet_parser_checksum_result),
    .checksum_result_enable (ethernet_packet_parser_checksum_result_enable),
    .receive_slot_enable    (ethernet_packet_parser_receive_slot_enable),
    .speed_code             (ethernet_packet_parser_speed_code),

    .data_ready             (ethernet_packet_parser_data_ready),
    .checksum_data          (ethernet_packet_parser_checksum_data),
    .checksum_data_valid    (ethernet_packet_parser_checksum_data_valid),
    .checksum_data_last     (ethernet_packet_parser_checksum_data_last),
    .packet_data            (ethernet_packet_parser_packet_data),
    .packet_data_valid      (ethernet_packet_parser_packet_data_valid),
    .good_packet            (ethernet_packet_parser_good_packet),
    .bad_packet             (ethernet_packet_parser_bad_packet),
    .next_que_slot          (ethernet_packet_parser_next_que_slot)
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


wire                                    que_slot_clock;
wire                                    que_slot_reset_n;
wire    [7:0]                           que_slot_data;
wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_data_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_good_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_bad_packet;
wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_push_data_enable;

wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_ready;
wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_data_ready;
wire    [RECEIVE_QUE_SLOTS-1:0][7:0]    que_slot_push_data;
wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_push_data_valid;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        que_slot#(
            .TECHNOLOGY (TECHNOLOGY)
        )que_slot(
            .clock                  (que_slot_clock),
            .reset_n                (que_slot_reset_n),
            .data                   (que_slot_data),
            .data_enable            (que_slot_data_enable[i]),
            .good_packet            (que_slot_good_packet[i]),
            .bad_packet             (que_slot_bad_packet[i]),
            .push_data_enable       (que_slot_push_data_enable[i]),

            .ready                  (que_slot_ready[i]),
            .data_ready             (que_slot_data_ready[i]),
            .push_data              (que_slot_push_data[i]),
            .push_data_valid        (que_slot_push_data_valid[i])
        );
    end
endgenerate


wire                                    que_slot_receieve_handler_clock;
wire                                    que_slot_receieve_handler_reset_n;
wire                                    que_slot_receieve_handler_enable;
wire    [RECEIVE_QUE_SLOTS-1:0][7:0]    que_slot_receieve_handler_data;
wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_receieve_handler_data_enable;
wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_receieve_handler_push_enable;
wire    [7:0]                           que_slot_receieve_handler_next_que_slot;
wire                                    que_slot_receieve_handler_next_que_slot_enable;

wire    [RECEIVE_QUE_SLOTS-1:0]         que_slot_receieve_handler_data_ready;
wire    [8:0]                           que_slot_receieve_handler_push_data;
wire                                    que_slot_receieve_handler_push_data_valid;

que_slot_receieve_handler  #(.RECEIVE_QUE_SLOTS(RECEIVE_QUE_SLOTS), .TECHNOLOGY(TECHNOLOGY))
que_slot_receieve_handler(
    .clock                  (que_slot_receieve_handler_clock),
    .reset_n                (que_slot_receieve_handler_reset_n),
    .enable                 (que_slot_receieve_handler_enable),
    .data                   (que_slot_receieve_handler_data),
    .data_enable            (que_slot_receieve_handler_data_enable),
    .push_enable            (que_slot_receieve_handler_push_enable),
    .next_que_slot          (que_slot_receieve_handler_next_que_slot),
    .next_que_slot_enable   (que_slot_receieve_handler_next_que_slot_enable),

    .data_ready             (que_slot_receieve_handler_data_ready),
    .push_data              (que_slot_receieve_handler_push_data),
    .push_data_valid        (que_slot_receieve_handler_push_data_valid)
);


wire        rgmii_byte_shipper_clock;
wire        rgmii_byte_shipper_reset_n;
wire [8:0]  rgmii_byte_shipper_data;
wire        rgmii_byte_shipper_data_enable;

wire        rgmii_byte_shipper_data_ready;
wire [3:0]  rgmii_byte_shipper_shipped_data;
wire        rgmii_byte_shipper_shipped_data_valid;

rgmii_byte_shipper#(
  .TECHNOLOGY               (TECHNOLOGY),
  .INTER_PACKET_GAP_CYCLES  (4)           
)   
rgmii_byte_shipper(
    .clock              (rgmii_byte_shipper_clock),
    .reset_n            (rgmii_byte_shipper_reset_n),
    .data               (rgmii_byte_shipper_data),
    .data_enable        (rgmii_byte_shipper_data_enable),

    .data_ready         (rgmii_byte_shipper_data_ready),
    .shipped_data       (rgmii_byte_shipper_shipped_data),
    .shipped_data_valid (rgmii_byte_shipper_shipped_data_valid)
);


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
wire            inbound_fifo_custom_full;
wire            inbound_fifo_almost_full;
wire            inbound_fifo_empty;

asynchronous_fifo#(
    .DATA_WIDTH                 (9),
    .DATA_DEPTH                 (4096),
    //.DATA_DEPTH                 (4096),
    .FIRST_WORD_FALL_THROUGH    (1),
    .TECHNOLOGY                 (TECHNOLOGY),
    .NUMBER_OF_CDC_STAGES       (2)
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
    .almost_full        (inbound_fifo_almost_full),
    .empty              (inbound_fifo_empty)
);


wire            data_clock_ddr_output_buffer_clock;
wire            data_clock_ddr_output_buffer_reset_n;
wire    [1:0]   data_clock_ddr_output_buffer_ddr_input;

wire            data_clock_ddr_output_buffer_ddr_output;

ddr_output_buffer#(
  .OUTPUT_WIDTH     (1),
  .TECHNOLOGY       (TECHNOLOGY)
)data_clock_ddr_output_buffer(
    .clock          (data_clock_ddr_output_buffer_clock),
    .reset_n        (data_clock_ddr_output_buffer_reset_n),
    .ddr_input      (data_clock_ddr_output_buffer_ddr_input),

    .ddr_output     (data_clock_ddr_output_buffer_ddr_output)
);


//pipelining registers
reg [1:0][8:0] transmit_data_delayed;
reg [1:0]      transmit_data_enable_delayed;

always_ff @(posedge core_clock) begin
    if (!core_reset_n) begin
        transmit_data_ready             <=  '0;
    end
    else begin
        transmit_data_ready             <=  !inbound_fifo_almost_full;
    end
end


assign receive_data_valid                                       = que_slot_receieve_handler_push_data_valid;
assign receive_data                                             = que_slot_receieve_handler_push_data;

assign rgmii_byte_packager_clock                                = phy_receive_clock;
assign rgmii_byte_packager_reset_n                              = phy_receive_reset_n;
assign rgmii_byte_packager_data                                 = phy_receive_data;
assign rgmii_byte_packager_data_control                         = phy_receive_data_control;

assign ethernet_packet_parser_clock                             = core_clock;
assign ethernet_packet_parser_reset_n                           = core_reset_n;
assign ethernet_packet_parser_data                              = phy_received_bytes_fifo_read_data;
assign ethernet_packet_parser_data_enable                       = phy_received_bytes_fifo_read_data_valid;
assign ethernet_packet_parser_checksum_result                   = frame_check_sequence_generator_checksum;
assign ethernet_packet_parser_checksum_result_enable            = frame_check_sequence_generator_checksum_valid;
assign ethernet_packet_parser_speed_code                        = 2;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i=i+1) begin
        assign  ethernet_packet_parser_receive_slot_enable[i]   = que_slot_ready[i];
    end
endgenerate

assign  frame_check_sequence_generator_clock                    = core_clock;
assign  frame_check_sequence_generator_reset_n                  = core_reset_n;
assign  frame_check_sequence_generator_data                     = ethernet_packet_parser_checksum_data;
assign  frame_check_sequence_generator_data_enable              = ethernet_packet_parser_checksum_data_valid;
assign  frame_check_sequence_generator_data_last                = ethernet_packet_parser_checksum_data_last;

assign  que_slot_clock                                          = core_clock;
assign  que_slot_reset_n                                        = core_reset_n;
assign  que_slot_data                                           = ethernet_packet_parser_packet_data;
generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        assign  que_slot_data_enable[i]                         = ethernet_packet_parser_packet_data_valid[i];
        assign  que_slot_good_packet[i]                         = ethernet_packet_parser_good_packet[i];
        assign  que_slot_bad_packet[i]                          = ethernet_packet_parser_bad_packet[i];
        assign  que_slot_push_data_enable[i]                    = que_slot_receieve_handler_data_ready[i];
    end
endgenerate

assign  que_slot_receieve_handler_clock                         = core_clock;
assign  que_slot_receieve_handler_reset_n                       = core_reset_n;
assign  que_slot_receieve_handler_enable                        = receive_data_enable;
assign  que_slot_receieve_handler_next_que_slot                 = ethernet_packet_parser_next_que_slot;
assign  que_slot_receieve_handler_next_que_slot_enable          = |ethernet_packet_parser_good_packet;

generate
    for (i=0; i<RECEIVE_QUE_SLOTS; i =i+1) begin
        assign  que_slot_receieve_handler_data[i]               = que_slot_push_data[i];
        assign  que_slot_receieve_handler_data_enable[i]        = que_slot_push_data_valid[i];
        assign  que_slot_receieve_handler_push_enable[i]        = que_slot_data_ready[i];
    end
endgenerate

assign phy_received_bytes_fifo_read_clock                       = core_clock;
assign phy_received_bytes_fifo_read_enable                      = ethernet_packet_parser_data_ready;
assign phy_received_bytes_fifo_read_reset_n                     = core_reset_n;
assign phy_received_bytes_fifo_write_clock                      = phy_receive_clock;
assign phy_received_bytes_fifo_write_data                       = rgmii_byte_packager_packaged_data;
assign phy_received_bytes_fifo_write_enable                     = rgmii_byte_packager_packaged_data_valid;
assign phy_received_bytes_fifo_write_reset_n                    = phy_receive_reset_n;

assign inbound_fifo_read_clock                                  = transmit_clock;
assign inbound_fifo_read_reset_n                                = phy_transmit_reset_n;
assign inbound_fifo_write_clock                                 = core_clock;
assign inbound_fifo_write_reset_n                               = core_reset_n;
assign inbound_fifo_read_enable                                 = rgmii_byte_shipper_data_ready;
assign inbound_fifo_write_enable                                = transmit_data_enable;
assign inbound_fifo_write_data                                  = transmit_data;

assign rgmii_byte_shipper_clock                                 = transmit_clock;
assign rgmii_byte_shipper_reset_n                               = phy_transmit_reset_n;
assign rgmii_byte_shipper_data                                  = inbound_fifo_read_data;
assign rgmii_byte_shipper_data_enable                           = inbound_fifo_read_data_valid;

assign phy_transmit_data                                        = rgmii_byte_shipper_shipped_data;
assign phy_transmit_data_valid                                  = rgmii_byte_shipper_shipped_data_valid;
assign phy_transmit_clock                                       = data_clock_ddr_output_buffer_ddr_output;
assign phy_transmit_clock_raw                                   = (PHASE_SHIFT_TX_CLOCK_ENABLE == 1) ? rgmii_pll_phase_shifted_clock : transmit_clock;

assign rgmii_pll_clock                                          = phy_receive_clock;
assign rgmii_pll_reset_n                                        = phy_receive_reset_n;

assign data_clock_ddr_output_buffer_clock                       = (PHASE_SHIFT_TX_CLOCK_ENABLE == 1) ? rgmii_pll_phase_shifted_clock : transmit_clock;
assign data_clock_ddr_output_buffer_reset_n                     = (PHASE_SHIFT_TX_CLOCK_ENABLE == 1) ? phy_receive_reset_n : phy_transmit_reset_n;
assign data_clock_ddr_output_buffer_ddr_input                   = {1'b0,1'b1};

endmodule