`ifndef _case_009_svh_
`define _case_009_svh_

//saturation test: minimum size frames back to back at gigabit line rate
//(standard 12 byte-time inter packet gap) from rgmii port 1, unicast to a
//station learned behind rgmii port 0. every frame must survive the whole
//path at line rate: validated at the ingress parser, delivered into the
//egress fifo by the fabric, and transmitted on the wire. any rate shortfall
//anywhere in the chain shows up as a missing frame
//standard reflected crc32, output bytes ordered first-on-wire high, matching
//the hardware generator (see tb_fcs_generator)
function logic [31:0] case_009_crc32(input logic [7:0] frame [0:1525], input int start_index, input int length);
    logic [31:0] crc;
    crc = 32'hFFFF_FFFF;
    for (int k = start_index; k < start_index + length; k++) begin
        crc = crc ^ {24'h0, frame[k]};
        for (int b = 0; b < 8; b++) begin
            if (crc[0]) crc = (crc >> 1) ^ 32'hEDB8_8320;
            else        crc = crc >> 1;
        end
    end
    crc = crc ^ 32'hFFFF_FFFF;
    return {crc[7:0], crc[15:8], crc[23:16], crc[31:24]};
endfunction

task case_009();

localparam FRAME_COUNT      = 50;
localparam MTU_FRAME_COUNT  = 50;
localparam MTU_WIRE_BYTES   = 1526;    //8 preamble + 14 header + 1500 mtu payload + 4 fcs

automatic integer       i;
automatic integer       f;
automatic logic [7:0]   frame        [0:71];
automatic logic [7:0]   crc_message  [0:888];
automatic logic [31:0]  frame_check_sequence;
automatic integer       ingress_good_frames     = 0;
automatic integer       ingress_bad_frames      = 0;
automatic integer       engine_drop_drains      = 0;
automatic bit           phy_fifo_full_seen      = 0;
automatic bit           slot_starved_seen       = 0;
automatic bit           egress_fifo_backpressure_seen = 0;
automatic integer       egress_fifo_frames      = 0;
automatic integer       wire_frames             = 0;
automatic integer       minimum_wire_gap        = 9999;
automatic time          blast_start             = 0;
automatic time          blast_end               = 0;
automatic real          effective_gbps;
automatic logic [7:0]   mtu_frame [0:1525];
automatic logic [31:0]  mtu_crc;

$display("Running case 009");
$display("Blasting %0d minimum size frames at gigabit line rate: RGMII port 1 -> RGMII port 0", FRAME_COUNT);

//teach the cam that station 0D:F0:0D:00:00:G0 lives behind rgmii port 0 by
//sourcing one broadcast frame from it
frame[0] = 8'h55; frame[1] = 8'h55; frame[2] = 8'h55; frame[3] = 8'h55;
frame[4] = 8'h55; frame[5] = 8'h55; frame[6] = 8'h55; frame[7] = 8'hD5;
//mac destination: broadcast
for (i=8;  i<14; i=i+1) frame[i] = 8'hFF;
//mac source: rgmii port 0 station
frame[14] = 8'h0D; frame[15] = 8'hF0; frame[16] = 8'h0D; frame[17] = 8'h00;
frame[18] = 8'h00; frame[19] = 8'hA0;
for (i=20; i<68; i=i+1) frame[i] = i[7:0];
for (i=0;  i<72; i=i+1) crc_message[i] = frame[i];
frame_check_sequence = testbench.calc_crc(crc_message, 68);
frame[68] = frame_check_sequence[31:24];
frame[69] = frame_check_sequence[23:16];
frame[70] = frame_check_sequence[15:8];
frame[71] = frame_check_sequence[7:0];

for (i=0; i<72; i=i+1) begin
    @(posedge testbench.rgmii_clock);
    testbench.rgmii_data_control[0] = 1;
    testbench.rgmii_data[0]         = frame[i][3:0];
    @(negedge testbench.rgmii_clock);
    testbench.rgmii_data[0]         = frame[i][7:4];
end
@(posedge testbench.rgmii_clock);
testbench.rgmii_data_control[0] = 0;
testbench.rgmii_data[0]         = 0;

//let the learn commit and the flood drain
repeat (2000) @(posedge testbench.rgmii_clock);

//count frames at the three measurement points while blasting
fork : monitors
    begin
        forever begin
            @(posedge testbench.core_clock);
            if (testbench.switch_core.genblk3[1].rgmii_port.ethernet_packet_parser.good_packet != 0) begin
                ingress_good_frames = ingress_good_frames + 1;
            end
        end
    end
    begin
        forever begin
            @(posedge testbench.core_clock);
            if (testbench.switch_core.genblk3[1].rgmii_port.ethernet_packet_parser.bad_packet != 0) begin
                ingress_bad_frames = ingress_bad_frames + 1;
            end
            if (testbench.switch_core.genblk3[1].rgmii_port.phy_received_bytes_fifo_full) begin
                phy_fifo_full_seen = 1;
            end
            if (testbench.switch_core.genblk3[1].rgmii_port.ethernet_packet_parser_receive_slot_enable == 0) begin
                slot_starved_seen = 1;
            end
            if (testbench.switch_core.genblk3[0].rgmii_port.inbound_fifo_almost_full) begin
                egress_fifo_backpressure_seen = 1;
            end
        end
    end
    begin
        forever begin
            @(posedge testbench.core_clock);
            if (testbench.switch_core.genblk3[0].rgmii_port.inbound_fifo_write_enable
                && testbench.switch_core.genblk3[0].rgmii_port.transmit_data_last) begin
                egress_fifo_frames = egress_fifo_frames + 1;
            end
        end
    end
    begin
        forever begin
            @(negedge testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper_shipped_data_valid);
            wire_frames = wire_frames + 1;
        end
    end
    begin
        //measure the actual inter frame gap on the wire in byte times. the
        //valid edges land on clock edges so the timestamp delta divided by
        //the 8ns gigabit byte time is exact
        automatic time    gap_start;
        automatic integer idle_cycles;
        forever begin
            @(negedge testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper_shipped_data_valid);
            gap_start   = $time;
            @(posedge testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper_shipped_data_valid);
            idle_cycles = ($time - gap_start) / 8ns;
            if (idle_cycles < minimum_wire_gap) minimum_wire_gap = idle_cycles;
        end
    end
join_none

//blast: unicast frames to the learned station, unique payload per frame,
//exactly 12 byte times of inter packet gap (96 ns, the 802.3 minimum)
blast_start = $time;
for (f=0; f<FRAME_COUNT; f=f+1) begin
    //mac destination: the station learned behind rgmii port 0
    frame[8]  = 8'h0D; frame[9]  = 8'hF0; frame[10] = 8'h0D; frame[11] = 8'h00;
    frame[12] = 8'h00; frame[13] = 8'hA0;
    //mac source: the station behind rgmii port 1
    frame[14] = 8'h0D; frame[15] = 8'hF0; frame[16] = 8'h0D; frame[17] = 8'h00;
    frame[18] = 8'h00; frame[19] = 8'hB1;
    //unique payload
    for (i=20; i<68; i=i+1) frame[i] = i[7:0] ^ f[7:0];
    for (i=0;  i<72; i=i+1) crc_message[i] = frame[i];
    frame_check_sequence = testbench.calc_crc(crc_message, 68);
    frame[68] = frame_check_sequence[31:24];
    frame[69] = frame_check_sequence[23:16];
    frame[70] = frame_check_sequence[15:8];
    frame[71] = frame_check_sequence[7:0];

    for (i=0; i<72; i=i+1) begin
        @(posedge testbench.rgmii_clock);
        testbench.rgmii_data_control[1] = 1;
        testbench.rgmii_data[1]         = frame[i][3:0];
        @(negedge testbench.rgmii_clock);
        testbench.rgmii_data[1]         = frame[i][7:4];
    end
    @(posedge testbench.rgmii_clock);
    testbench.rgmii_data_control[1] = 0;
    testbench.rgmii_data[1]         = 0;
    //11 more idle byte times for the standard 12 byte inter packet gap
    repeat (11) @(posedge testbench.rgmii_clock);
end
blast_end = $time;

//wait for the tail of the stream to reach the wire
fork : f0
    begin
        #2ms;
        $fatal(0, "%t : timeout, wire frames %0d / %0d (ingress good %0d bad %0d, egress fifo %0d, phy fifo full %0d, slot starved %0d, egress fifo backpressure %0d)",
               $time, wire_frames, FRAME_COUNT, ingress_good_frames, ingress_bad_frames, egress_fifo_frames, phy_fifo_full_seen, slot_starved_seen, egress_fifo_backpressure_seen);
        disable f0;
    end
    begin
        wait (wire_frames >= FRAME_COUNT);
        disable f0;
    end
join

if (ingress_good_frames != FRAME_COUNT) begin
    $fatal(0, "ingress fell behind line rate: %0d / %0d frames validated", ingress_good_frames, FRAME_COUNT);
end
if (egress_fifo_frames != FRAME_COUNT) begin
    $fatal(0, "fabric dropped frames: %0d / %0d delivered to the egress fifo", egress_fifo_frames, FRAME_COUNT);
end
if (wire_frames != FRAME_COUNT) begin
    $fatal(0, "egress fell behind line rate: %0d / %0d frames on the wire", wire_frames, FRAME_COUNT);
end

//$time is in the module time unit (ns), so bits per ns is gigabits per second
effective_gbps = (FRAME_COUNT * 64.0 * 8.0) / real'(blast_end - blast_start);
$display("Saturation sustained: %0d/%0d minimum size frames at line rate (%.3f Gbps of frame data offered and delivered)",
         wire_frames, FRAME_COUNT, effective_gbps);

//second phase: maximum mtu frames back to back at line rate. large frames
//stress storage occupancy (queue slots, egress fifo against the admission
//reserve) instead of per frame overhead
$display("Blasting %0d maximum mtu frames at gigabit line rate: RGMII port 1 -> RGMII port 0", MTU_FRAME_COUNT);

blast_start = $time;
for (f=0; f<MTU_FRAME_COUNT; f=f+1) begin
    for (i=0; i<8;  i=i+1) mtu_frame[i] = 8'h55;
    mtu_frame[7]  = 8'hD5;
    //mac destination: the station learned behind rgmii port 0
    mtu_frame[8]  = 8'h0D; mtu_frame[9]  = 8'hF0; mtu_frame[10] = 8'h0D; mtu_frame[11] = 8'h00;
    mtu_frame[12] = 8'h00; mtu_frame[13] = 8'hA0;
    //mac source: the station behind rgmii port 1
    mtu_frame[14] = 8'h0D; mtu_frame[15] = 8'hF0; mtu_frame[16] = 8'h0D; mtu_frame[17] = 8'h00;
    mtu_frame[18] = 8'h00; mtu_frame[19] = 8'hB1;
    //type and 1500 bytes of payload
    mtu_frame[20] = 8'h08; mtu_frame[21] = 8'h00;
    for (i=22; i<MTU_WIRE_BYTES-4; i=i+1) mtu_frame[i] = i[7:0] ^ (f[7:0] + 8'h5A);
    mtu_crc = case_009_crc32(mtu_frame, 8, 1514);
    mtu_frame[MTU_WIRE_BYTES-4] = mtu_crc[31:24];
    mtu_frame[MTU_WIRE_BYTES-3] = mtu_crc[23:16];
    mtu_frame[MTU_WIRE_BYTES-2] = mtu_crc[15:8];
    mtu_frame[MTU_WIRE_BYTES-1] = mtu_crc[7:0];

    for (i=0; i<MTU_WIRE_BYTES; i=i+1) begin
        @(posedge testbench.rgmii_clock);
        testbench.rgmii_data_control[1] = 1;
        testbench.rgmii_data[1]         = mtu_frame[i][3:0];
        @(negedge testbench.rgmii_clock);
        testbench.rgmii_data[1]         = mtu_frame[i][7:4];
    end
    @(posedge testbench.rgmii_clock);
    testbench.rgmii_data_control[1] = 0;
    testbench.rgmii_data[1]         = 0;
    repeat (11) @(posedge testbench.rgmii_clock);
end
blast_end = $time;

fork : f1
    begin
        #2ms;
        $fatal(0, "%t : timeout, mtu wire frames %0d / %0d (ingress good %0d bad %0d, egress fifo %0d)",
               $time, wire_frames - FRAME_COUNT, MTU_FRAME_COUNT, ingress_good_frames - FRAME_COUNT, ingress_bad_frames, egress_fifo_frames - FRAME_COUNT);
        disable f1;
    end
    begin
        wait (wire_frames >= FRAME_COUNT + MTU_FRAME_COUNT);
        disable f1;
    end
join
disable monitors;

if (ingress_good_frames != FRAME_COUNT + MTU_FRAME_COUNT) begin
    $fatal(0, "mtu ingress fell behind line rate: %0d / %0d frames validated", ingress_good_frames - FRAME_COUNT, MTU_FRAME_COUNT);
end
if (egress_fifo_frames != FRAME_COUNT + MTU_FRAME_COUNT) begin
    $fatal(0, "mtu fabric dropped frames: %0d / %0d delivered to the egress fifo", egress_fifo_frames - FRAME_COUNT, MTU_FRAME_COUNT);
end
if (wire_frames != FRAME_COUNT + MTU_FRAME_COUNT) begin
    $fatal(0, "mtu egress fell behind line rate: %0d / %0d frames on the wire", wire_frames - FRAME_COUNT, MTU_FRAME_COUNT);
end

effective_gbps = (MTU_FRAME_COUNT * 1518.0 * 8.0) / real'(blast_end - blast_start);
$display("Saturation sustained: %0d/%0d maximum mtu frames at line rate (%.3f Gbps of frame data offered and delivered)",
         wire_frames - FRAME_COUNT, MTU_FRAME_COUNT, effective_gbps);
$display("Minimum inter frame gap observed on the rgmii 0 wire: %0d byte times (802.3 requires 12)", minimum_wire_gap);

endtask: case_009

`endif
