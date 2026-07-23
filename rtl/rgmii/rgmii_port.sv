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
// Description: rgmii port. bytes from the phy are packed into
//              FABRIC_DATA_BYTES wide beats in the phy receive clock domain
//              (which is wire rate by construction), so everything on the
//              core clock side of the receive fifo runs at beat rate and
//              the core clock can be reduced without losing line rate
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
    parameter RECEIVE_QUEUE_SLOTS           = 2,
    parameter PHASE_SHIFT_TX_CLOCK_ENABLE   = 0,
    parameter FABRIC_DATA_BYTES             = 1,
    logic [15:0] TIMEOUT_LIMIT      = 16'h0FFF
)(
    input   wire                                            core_clock,
    input   wire                                            core_reset_n,
    input   wire                                            phy_receive_reset_n,
    input   wire                                            phy_transmit_reset_n,
    input   wire    [3:0]                                   phy_receive_data,
    input   wire                                            phy_receive_data_control,
    input   wire                                            phy_receive_clock,
    input   wire    [(FABRIC_DATA_BYTES*8)-1:0]             transmit_data,
    input   wire                                            transmit_data_first,
    input   wire                                            transmit_data_last,
    input   wire    [$clog2(FABRIC_DATA_BYTES+1)-1:0]       transmit_data_byte_count,
    input   wire                                            transmit_data_enable,
    input   wire                                            receive_data_enable,
    input   wire                                            transmit_clock,

    output  reg                                             transmit_data_ready,
    output  wire                                            transmit_frame_ready,
    output  wire    [(FABRIC_DATA_BYTES*8)-1:0]             receive_data,
    output  wire                                            receive_data_first,
    output  wire                                            receive_data_valid,
    output  wire                                            receive_data_last,
    output  wire    [$clog2(FABRIC_DATA_BYTES+1)-1:0]       receive_data_byte_count,
    output  wire                                            phy_transmit_clock,
    output  wire                                            phy_transmit_clock_raw,
    output  wire                                            phy_transmit_data_valid,
    output  wire    [3:0]                                   phy_transmit_data
);

localparam FABRIC_BYTE_COUNT_WIDTH  = $clog2(FABRIC_DATA_BYTES+1);
localparam INGRESS_BUNDLE_WIDTH     = (FABRIC_DATA_BYTES*8) + FABRIC_BYTE_COUNT_WIDTH + 2;
//reserve one maximum frame of egress fifo space at frame admission so a
//granted frame can always stream in full without mid frame backpressure
localparam EGRESS_FIFO_DEPTH        = 32768 / FABRIC_DATA_BYTES;
localparam FRAME_RESERVE_BEATS      = 1536 / FABRIC_DATA_BYTES;
//backlog watermark for the gap shrink. a fill beyond half the fifo means
//either the transmit clock is running slower than the sender or a burst
//of converging traffic left a deep backlog. in both cases draining one
//byte time faster per frame is the right response
localparam GAP_SHRINK_WATERMARK     = 16384 / FABRIC_DATA_BYTES;

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
wire        rgmii_byte_packager_packaged_data_last;
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
    .packaged_data_last     (rgmii_byte_packager_packaged_data_last),
    .speed_code             (rgmii_byte_packager_packaged_data_speed_code)
);


//pack bytes into fabric beats in the phy receive clock domain, which only
//ever needs to keep up with the wire
wire                                        ingress_width_adapter_clock;
wire                                        ingress_width_adapter_reset_n;
wire    [8:0]                               ingress_width_adapter_byte_data;
wire                                        ingress_width_adapter_byte_data_enable;
wire                                        ingress_width_adapter_byte_data_last;
wire                                        ingress_width_adapter_beat_ready;

wire                                        ingress_width_adapter_byte_data_ready;
wire    [(FABRIC_DATA_BYTES*8)-1:0]         ingress_width_adapter_beat_data;
wire                                        ingress_width_adapter_beat_first;
wire                                        ingress_width_adapter_beat_last;
wire    [FABRIC_BYTE_COUNT_WIDTH-1:0]       ingress_width_adapter_beat_byte_count;
wire                                        ingress_width_adapter_beat_valid;

width_adapter_up #(
    .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
) ingress_width_adapter (
    .clock              (ingress_width_adapter_clock),
    .reset_n            (ingress_width_adapter_reset_n),
    .byte_data          (ingress_width_adapter_byte_data),
    .byte_data_enable   (ingress_width_adapter_byte_data_enable),
    .byte_data_last     (ingress_width_adapter_byte_data_last),
    .beat_ready         (ingress_width_adapter_beat_ready),

    .byte_data_ready    (ingress_width_adapter_byte_data_ready),
    .beat_data          (ingress_width_adapter_beat_data),
    .beat_first         (ingress_width_adapter_beat_first),
    .beat_last          (ingress_width_adapter_beat_last),
    .beat_byte_count    (ingress_width_adapter_beat_byte_count),
    .beat_valid         (ingress_width_adapter_beat_valid)
);


wire    [INGRESS_BUNDLE_WIDTH-1:0]  phy_received_bytes_fifo_write_data;
wire                                phy_received_bytes_fifo_read_clock;
wire                                phy_received_bytes_fifo_read_enable;
wire                                phy_received_bytes_fifo_read_reset_n;
wire                                phy_received_bytes_fifo_write_clock;
wire                                phy_received_bytes_fifo_write_enable;
wire                                phy_received_bytes_fifo_write_reset_n;
wire                                phy_received_bytes_fifo_read_data_valid;
wire                                phy_received_bytes_fifo_empty;
wire                                phy_received_bytes_fifo_full;
wire    [INGRESS_BUNDLE_WIDTH-1:0]  phy_received_bytes_fifo_read_data;

asynchronous_fifo#(
    .DATA_WIDTH                 (INGRESS_BUNDLE_WIDTH),
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


wire                                        ethernet_packet_parser_clock;
wire                                        ethernet_packet_parser_reset_n;
wire    [(FABRIC_DATA_BYTES*8)-1:0]         ethernet_packet_parser_data;
wire                                        ethernet_packet_parser_data_first;
wire                                        ethernet_packet_parser_data_last;
wire    [FABRIC_BYTE_COUNT_WIDTH-1:0]       ethernet_packet_parser_data_byte_count;
wire                                        ethernet_packet_parser_data_enable;
wire    [31:0]                              ethernet_packet_parser_checksum_result;
wire                                        ethernet_packet_parser_checksum_result_enable;
wire    [RECEIVE_QUEUE_SLOTS-1:0]           ethernet_packet_parser_receive_slot_enable;
wire    [1:0]                               ethernet_packet_parser_speed_code;

wire                                        ethernet_packet_parser_data_ready;
wire    [(FABRIC_DATA_BYTES*8)-1:0]         ethernet_packet_parser_checksum_data;
wire                                        ethernet_packet_parser_checksum_data_valid;
wire                                        ethernet_packet_parser_checksum_data_last;
wire    [FABRIC_BYTE_COUNT_WIDTH-1:0]       ethernet_packet_parser_checksum_data_byte_count;
wire    [(FABRIC_DATA_BYTES*8)-1:0]         ethernet_packet_parser_packet_data;
wire                                        ethernet_packet_parser_packet_data_first;
wire                                        ethernet_packet_parser_packet_data_last;
wire    [FABRIC_BYTE_COUNT_WIDTH-1:0]       ethernet_packet_parser_packet_data_byte_count;
wire    [RECEIVE_QUEUE_SLOTS-1:0]           ethernet_packet_parser_packet_data_valid;
wire    [RECEIVE_QUEUE_SLOTS-1:0]           ethernet_packet_parser_good_packet;
wire    [RECEIVE_QUEUE_SLOTS-1:0]           ethernet_packet_parser_bad_packet;
wire    [7:0]                               ethernet_packet_parser_next_queue_slot;

ethernet_packet_parser   #(
    .RECEIVE_QUEUE_SLOTS    (RECEIVE_QUEUE_SLOTS),
    .DATA_BYTES             (FABRIC_DATA_BYTES),
    .TIMEOUT_LIMIT          (TIMEOUT_LIMIT)
)
ethernet_packet_parser(
    .clock                      (ethernet_packet_parser_clock),
    .reset_n                    (ethernet_packet_parser_reset_n),
    .data                       (ethernet_packet_parser_data),
    .data_first                 (ethernet_packet_parser_data_first),
    .data_last                  (ethernet_packet_parser_data_last),
    .data_byte_count            (ethernet_packet_parser_data_byte_count),
    .data_enable                (ethernet_packet_parser_data_enable),
    .checksum_result            (ethernet_packet_parser_checksum_result),
    .checksum_result_enable     (ethernet_packet_parser_checksum_result_enable),
    .receive_slot_enable        (ethernet_packet_parser_receive_slot_enable),
    .speed_code                 (ethernet_packet_parser_speed_code),

    .data_ready                 (ethernet_packet_parser_data_ready),
    .checksum_data              (ethernet_packet_parser_checksum_data),
    .checksum_data_valid        (ethernet_packet_parser_checksum_data_valid),
    .checksum_data_last         (ethernet_packet_parser_checksum_data_last),
    .checksum_data_byte_count   (ethernet_packet_parser_checksum_data_byte_count),
    .packet_data                (ethernet_packet_parser_packet_data),
    .packet_data_first          (ethernet_packet_parser_packet_data_first),
    .packet_data_last           (ethernet_packet_parser_packet_data_last),
    .packet_data_byte_count     (ethernet_packet_parser_packet_data_byte_count),
    .packet_data_valid          (ethernet_packet_parser_packet_data_valid),
    .good_packet                (ethernet_packet_parser_good_packet),
    .bad_packet                 (ethernet_packet_parser_bad_packet),
    .next_queue_slot            (ethernet_packet_parser_next_queue_slot)
);


wire                                        frame_check_sequence_generator_clock;
wire                                        frame_check_sequence_generator_reset_n;
wire    [(FABRIC_DATA_BYTES*8)-1:0]         frame_check_sequence_generator_data;
wire                                        frame_check_sequence_generator_data_enable;
wire                                        frame_check_sequence_generator_data_last;
wire    [FABRIC_BYTE_COUNT_WIDTH-1:0]       frame_check_sequence_generator_data_byte_count;
wire                                        frame_check_sequence_generator_ready;
wire    [31:0]                              frame_check_sequence_generator_checksum;
wire                                        frame_check_sequence_generator_checksum_valid;

frame_check_sequence_generator #(
    .DATA_BYTES (FABRIC_DATA_BYTES)
) frame_check_sequence_generator(
    .clock                  (frame_check_sequence_generator_clock),
    .reset_n                (frame_check_sequence_generator_reset_n),
    .data                   (frame_check_sequence_generator_data),
    .data_enable            (frame_check_sequence_generator_data_enable),
    .data_last              (frame_check_sequence_generator_data_last),
    .data_byte_count        (frame_check_sequence_generator_data_byte_count),

    .ready                  (frame_check_sequence_generator_ready),
    .checksum               (frame_check_sequence_generator_checksum),
    .checksum_valid         (frame_check_sequence_generator_checksum_valid)
);


wire                                                            queue_slot_clock;
wire                                                            queue_slot_reset_n;
wire    [(FABRIC_DATA_BYTES*8)-1:0]                             queue_slot_data;
wire                                                            queue_slot_data_first;
wire                                                            queue_slot_data_last;
wire    [FABRIC_BYTE_COUNT_WIDTH-1:0]                           queue_slot_data_byte_count;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_data_enable;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_good_packet;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_bad_packet;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_push_data_enable;

wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_ready;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_data_ready;
wire    [RECEIVE_QUEUE_SLOTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]    queue_slot_push_data;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_push_data_first;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_push_data_last;
wire    [RECEIVE_QUEUE_SLOTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]  queue_slot_push_data_byte_count;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_push_data_valid;

generate
    for (i=0; i<RECEIVE_QUEUE_SLOTS; i =i+1) begin
        queue_slot#(
            .TECHNOLOGY (TECHNOLOGY),
            .DATA_BYTES (FABRIC_DATA_BYTES)
        )queue_slot(
            .clock                  (queue_slot_clock),
            .reset_n                (queue_slot_reset_n),
            .data                   (queue_slot_data),
            .data_first             (queue_slot_data_first),
            .data_last              (queue_slot_data_last),
            .data_byte_count        (queue_slot_data_byte_count),
            .data_enable            (queue_slot_data_enable[i]),
            .good_packet            (queue_slot_good_packet[i]),
            .bad_packet             (queue_slot_bad_packet[i]),
            .push_data_enable       (queue_slot_push_data_enable[i]),

            .ready                  (queue_slot_ready[i]),
            .data_ready             (queue_slot_data_ready[i]),
            .push_data              (queue_slot_push_data[i]),
            .push_data_first        (queue_slot_push_data_first[i]),
            .push_data_last         (queue_slot_push_data_last[i]),
            .push_data_byte_count   (queue_slot_push_data_byte_count[i]),
            .push_data_valid        (queue_slot_push_data_valid[i])
        );
    end
endgenerate


wire                                                            queue_slot_receive_handler_clock;
wire                                                            queue_slot_receive_handler_reset_n;
wire                                                            queue_slot_receive_handler_enable;
wire    [RECEIVE_QUEUE_SLOTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]    queue_slot_receive_handler_data;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_receive_handler_data_first;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_receive_handler_data_last;
wire    [RECEIVE_QUEUE_SLOTS-1:0][FABRIC_BYTE_COUNT_WIDTH-1:0]  queue_slot_receive_handler_data_byte_count;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_receive_handler_data_enable;
wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_receive_handler_push_enable;
wire    [7:0]                                                   queue_slot_receive_handler_next_queue_slot;
wire                                                            queue_slot_receive_handler_next_queue_slot_enable;

wire    [RECEIVE_QUEUE_SLOTS-1:0]                               queue_slot_receive_handler_data_ready;
wire    [(FABRIC_DATA_BYTES*8)-1:0]                             queue_slot_receive_handler_push_data;
wire                                                            queue_slot_receive_handler_push_data_first;
wire                                                            queue_slot_receive_handler_push_data_valid;
wire                                                            queue_slot_receive_handler_push_data_last;
wire    [FABRIC_BYTE_COUNT_WIDTH-1:0]                           queue_slot_receive_handler_push_data_byte_count;

queue_slot_receive_handler  #(
    .RECEIVE_QUEUE_SLOTS    (RECEIVE_QUEUE_SLOTS),
    .TECHNOLOGY             (TECHNOLOGY),
    .DATA_BYTES             (FABRIC_DATA_BYTES)
)
queue_slot_receive_handler(
    .clock                  (queue_slot_receive_handler_clock),
    .reset_n                (queue_slot_receive_handler_reset_n),
    .enable                 (queue_slot_receive_handler_enable),
    .data                   (queue_slot_receive_handler_data),
    .data_first             (queue_slot_receive_handler_data_first),
    .data_last              (queue_slot_receive_handler_data_last),
    .data_byte_count        (queue_slot_receive_handler_data_byte_count),
    .data_enable            (queue_slot_receive_handler_data_enable),
    .push_enable            (queue_slot_receive_handler_push_enable),
    .next_queue_slot          (queue_slot_receive_handler_next_queue_slot),
    .next_queue_slot_enable   (queue_slot_receive_handler_next_queue_slot_enable),

    .data_ready             (queue_slot_receive_handler_data_ready),
    .push_data              (queue_slot_receive_handler_push_data),
    .push_data_first        (queue_slot_receive_handler_push_data_first),
    .push_data_valid        (queue_slot_receive_handler_push_data_valid),
    .push_data_last         (queue_slot_receive_handler_push_data_last),
    .push_data_byte_count   (queue_slot_receive_handler_push_data_byte_count)
);


wire        rgmii_byte_shipper_clock;
wire        rgmii_byte_shipper_reset_n;
wire [8:0]  rgmii_byte_shipper_data;
wire        rgmii_byte_shipper_data_enable;
wire        rgmii_byte_shipper_gap_shrink_enable;

wire        rgmii_byte_shipper_data_ready;
wire [3:0]  rgmii_byte_shipper_shipped_data;
wire        rgmii_byte_shipper_shipped_data_valid;

rgmii_byte_shipper#(
  .TECHNOLOGY               (TECHNOLOGY),
  //the shipper idles INTER_PACKET_GAP_CYCLES + 2 byte times between frames
  //(gap counter plus the start bit search cycle), so 10 enforces the 802.3
  //minimum of 12 even when the egress fifo drains a backlog back to back
  .INTER_PACKET_GAP_CYCLES  (10)
)
rgmii_byte_shipper(
    .clock              (rgmii_byte_shipper_clock),
    .reset_n            (rgmii_byte_shipper_reset_n),
    .data               (rgmii_byte_shipper_data),
    .data_enable        (rgmii_byte_shipper_data_enable),
    .gap_shrink_enable  (rgmii_byte_shipper_gap_shrink_enable),

    .data_ready         (rgmii_byte_shipper_data_ready),
    .shipped_data       (rgmii_byte_shipper_shipped_data),
    .shipped_data_valid (rgmii_byte_shipper_shipped_data_valid)
);


wire                                inbound_fifo_read_clock;
wire                                inbound_fifo_read_reset_n;
wire                                inbound_fifo_write_clock;
wire                                inbound_fifo_write_reset_n;
wire                                inbound_fifo_read_enable;
wire                                inbound_fifo_write_enable;
wire    [INGRESS_BUNDLE_WIDTH-1:0]  inbound_fifo_write_data;

wire    [INGRESS_BUNDLE_WIDTH-1:0]  inbound_fifo_read_data;
wire                                inbound_fifo_read_data_valid;
wire                                inbound_fifo_full;
wire                                inbound_fifo_almost_full;
wire                                inbound_fifo_programmable_full;
wire                                inbound_fifo_empty;
wire                                inbound_fifo_programmable_empty;

asynchronous_fifo#(
    .DATA_WIDTH                     (INGRESS_BUNDLE_WIDTH),
    .DATA_DEPTH                     (EGRESS_FIFO_DEPTH),
    .FIRST_WORD_FALL_THROUGH        (1),
    .TECHNOLOGY                     (TECHNOLOGY),
    .NUMBER_OF_CDC_STAGES           (2),
    .PROGRAMMABLE_FULL_THRESHOLD    (EGRESS_FIFO_DEPTH - FRAME_RESERVE_BEATS),
    .PROGRAMMABLE_EMPTY_THRESHOLD   (GAP_SHRINK_WATERMARK)
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
    .programmable_full  (inbound_fifo_programmable_full),
    .empty              (inbound_fifo_empty),
    .programmable_empty (inbound_fifo_programmable_empty)
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


//unpack beats back to bytes in the phy transmit clock domain, which only
//ever needs to keep up with the wire
wire                                        egress_width_adapter_clock;
wire                                        egress_width_adapter_reset_n;
wire    [(FABRIC_DATA_BYTES*8)-1:0]         egress_width_adapter_beat_data;
wire                                        egress_width_adapter_beat_first;
wire                                        egress_width_adapter_beat_last;
wire    [FABRIC_BYTE_COUNT_WIDTH-1:0]       egress_width_adapter_beat_byte_count;
wire                                        egress_width_adapter_beat_enable;
wire                                        egress_width_adapter_byte_data_ready;

wire                                        egress_width_adapter_beat_ready;
wire    [8:0]                               egress_width_adapter_byte_data;
wire                                        egress_width_adapter_byte_data_valid;
wire                                        egress_width_adapter_byte_data_last;

width_adapter_down #(
    .FABRIC_DATA_BYTES  (FABRIC_DATA_BYTES)
) egress_width_adapter (
    .clock              (egress_width_adapter_clock),
    .reset_n            (egress_width_adapter_reset_n),
    .beat_data          (egress_width_adapter_beat_data),
    .beat_first         (egress_width_adapter_beat_first),
    .beat_last          (egress_width_adapter_beat_last),
    .beat_byte_count    (egress_width_adapter_beat_byte_count),
    .beat_enable        (egress_width_adapter_beat_enable),
    .byte_data_ready    (egress_width_adapter_byte_data_ready),

    .beat_ready         (egress_width_adapter_beat_ready),
    .byte_data          (egress_width_adapter_byte_data),
    .byte_data_valid    (egress_width_adapter_byte_data_valid),
    .byte_data_last     (egress_width_adapter_byte_data_last)
);


always_ff @(posedge core_clock) begin
    if (!core_reset_n) begin
        transmit_data_ready             <=  '0;
    end
    else begin
        transmit_data_ready             <=  !inbound_fifo_almost_full;
    end
end


assign transmit_frame_ready                                     = !inbound_fifo_programmable_full;

assign receive_data_valid                                       = queue_slot_receive_handler_push_data_valid;
assign receive_data                                             = queue_slot_receive_handler_push_data;
assign receive_data_first                                       = queue_slot_receive_handler_push_data_first;
assign receive_data_last                                        = queue_slot_receive_handler_push_data_last;
assign receive_data_byte_count                                  = queue_slot_receive_handler_push_data_byte_count;

assign rgmii_byte_packager_clock                                = phy_receive_clock;
assign rgmii_byte_packager_reset_n                              = phy_receive_reset_n;
assign rgmii_byte_packager_data                                 = phy_receive_data;
assign rgmii_byte_packager_data_control                         = phy_receive_data_control;

assign ingress_width_adapter_clock                              = phy_receive_clock;
assign ingress_width_adapter_reset_n                            = phy_receive_reset_n;
assign ingress_width_adapter_byte_data                          = rgmii_byte_packager_packaged_data;
assign ingress_width_adapter_byte_data_enable                   = rgmii_byte_packager_packaged_data_valid;
assign ingress_width_adapter_byte_data_last                     = rgmii_byte_packager_packaged_data_last;
assign ingress_width_adapter_beat_ready                         = !phy_received_bytes_fifo_full;

assign egress_width_adapter_clock                               = transmit_clock;
assign egress_width_adapter_reset_n                             = phy_transmit_reset_n;
assign egress_width_adapter_beat_data                           = inbound_fifo_read_data[(FABRIC_DATA_BYTES*8)-1:0];
assign egress_width_adapter_beat_first                          = inbound_fifo_read_data[INGRESS_BUNDLE_WIDTH-2];
assign egress_width_adapter_beat_last                           = inbound_fifo_read_data[INGRESS_BUNDLE_WIDTH-1];
assign egress_width_adapter_beat_byte_count                     = inbound_fifo_read_data[(FABRIC_DATA_BYTES*8) +: FABRIC_BYTE_COUNT_WIDTH];
assign egress_width_adapter_beat_enable                         = inbound_fifo_read_data_valid;
assign egress_width_adapter_byte_data_ready                     = rgmii_byte_shipper_data_ready;
assign rgmii_byte_shipper_gap_shrink_enable                     = !inbound_fifo_programmable_empty;

assign ethernet_packet_parser_clock                             = core_clock;
assign ethernet_packet_parser_reset_n                           = core_reset_n;
assign ethernet_packet_parser_data                              = phy_received_bytes_fifo_read_data[(FABRIC_DATA_BYTES*8)-1:0];
assign ethernet_packet_parser_data_byte_count                   = phy_received_bytes_fifo_read_data[(FABRIC_DATA_BYTES*8) +: FABRIC_BYTE_COUNT_WIDTH];
assign ethernet_packet_parser_data_first                        = phy_received_bytes_fifo_read_data[INGRESS_BUNDLE_WIDTH-2];
assign ethernet_packet_parser_data_last                         = phy_received_bytes_fifo_read_data[INGRESS_BUNDLE_WIDTH-1];
assign ethernet_packet_parser_data_enable                       = phy_received_bytes_fifo_read_data_valid;
assign ethernet_packet_parser_checksum_result                   = frame_check_sequence_generator_checksum;
assign ethernet_packet_parser_checksum_result_enable            = frame_check_sequence_generator_checksum_valid;
assign ethernet_packet_parser_speed_code                        = 2;

generate
    for (i=0; i<RECEIVE_QUEUE_SLOTS; i=i+1) begin
        assign  ethernet_packet_parser_receive_slot_enable[i]   = queue_slot_ready[i];
    end
endgenerate

assign  frame_check_sequence_generator_clock                    = core_clock;
assign  frame_check_sequence_generator_reset_n                  = core_reset_n;
assign  frame_check_sequence_generator_data                     = ethernet_packet_parser_checksum_data;
assign  frame_check_sequence_generator_data_enable              = ethernet_packet_parser_checksum_data_valid;
assign  frame_check_sequence_generator_data_last                = ethernet_packet_parser_checksum_data_last;
assign  frame_check_sequence_generator_data_byte_count          = ethernet_packet_parser_checksum_data_byte_count;

assign  queue_slot_clock                                        = core_clock;
assign  queue_slot_reset_n                                      = core_reset_n;
assign  queue_slot_data                                         = ethernet_packet_parser_packet_data;
assign  queue_slot_data_first                                   = ethernet_packet_parser_packet_data_first;
assign  queue_slot_data_last                                    = ethernet_packet_parser_packet_data_last;
assign  queue_slot_data_byte_count                              = ethernet_packet_parser_packet_data_byte_count;
generate
    for (i=0; i<RECEIVE_QUEUE_SLOTS; i =i+1) begin
        assign  queue_slot_data_enable[i]                       = ethernet_packet_parser_packet_data_valid[i];
        assign  queue_slot_good_packet[i]                       = ethernet_packet_parser_good_packet[i];
        assign  queue_slot_bad_packet[i]                        = ethernet_packet_parser_bad_packet[i];
        assign  queue_slot_push_data_enable[i]                  = queue_slot_receive_handler_data_ready[i];
    end
endgenerate

assign  queue_slot_receive_handler_clock                        = core_clock;
assign  queue_slot_receive_handler_reset_n                      = core_reset_n;
assign  queue_slot_receive_handler_enable                       = receive_data_enable;
assign  queue_slot_receive_handler_next_queue_slot              = ethernet_packet_parser_next_queue_slot;
assign  queue_slot_receive_handler_next_queue_slot_enable       = |ethernet_packet_parser_good_packet;

generate
    for (i=0; i<RECEIVE_QUEUE_SLOTS; i =i+1) begin
        assign  queue_slot_receive_handler_data[i]              = queue_slot_push_data[i];
        assign  queue_slot_receive_handler_data_first[i]        = queue_slot_push_data_first[i];
        assign  queue_slot_receive_handler_data_last[i]         = queue_slot_push_data_last[i];
        assign  queue_slot_receive_handler_data_byte_count[i]   = queue_slot_push_data_byte_count[i];
        assign  queue_slot_receive_handler_data_enable[i]       = queue_slot_push_data_valid[i];
        assign  queue_slot_receive_handler_push_enable[i]       = queue_slot_data_ready[i];
    end
endgenerate

assign phy_received_bytes_fifo_read_clock                       = core_clock;
assign phy_received_bytes_fifo_read_enable                      = ethernet_packet_parser_data_ready;
assign phy_received_bytes_fifo_read_reset_n                     = core_reset_n;
assign phy_received_bytes_fifo_write_clock                      = phy_receive_clock;
assign phy_received_bytes_fifo_write_data                       = {ingress_width_adapter_beat_last, ingress_width_adapter_beat_first, ingress_width_adapter_beat_byte_count, ingress_width_adapter_beat_data};
assign phy_received_bytes_fifo_write_enable                     = ingress_width_adapter_beat_valid && !phy_received_bytes_fifo_full;
assign phy_received_bytes_fifo_write_reset_n                    = phy_receive_reset_n;

assign inbound_fifo_read_clock                                  = transmit_clock;
assign inbound_fifo_read_reset_n                                = phy_transmit_reset_n;
assign inbound_fifo_write_clock                                 = core_clock;
assign inbound_fifo_write_reset_n                               = core_reset_n;
assign inbound_fifo_read_enable                                 = egress_width_adapter_beat_ready;
assign inbound_fifo_write_enable                                = transmit_data_enable;
assign inbound_fifo_write_data                                  = {transmit_data_last, transmit_data_first, transmit_data_byte_count, transmit_data};

assign rgmii_byte_shipper_clock                                 = transmit_clock;
assign rgmii_byte_shipper_reset_n                               = phy_transmit_reset_n;
assign rgmii_byte_shipper_data                                  = egress_width_adapter_byte_data;
assign rgmii_byte_shipper_data_enable                           = egress_width_adapter_byte_data_valid;

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
