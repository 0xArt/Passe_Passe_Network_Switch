`ifndef _case_011_svh_
`define _case_011_svh_

//iperf3 style udp throughput test. the client behind rgmii port 1 streams
//udp datagrams at gigabit line rate to the server behind rgmii port 0
//(stations learned in case 009). like real iperf3 udp, every datagram
//carries a sequence number and a send timestamp in its payload; the server
//side monitor decodes each datagram at the wire and measures loss,
//reordering, and rfc 1889 smoothed jitter at the receiver. udp checksum is
//zero, which is legal for udp over ipv4
task case_011();

localparam DATAGRAMS        = 200;    //714 datagrams of 1470 bytes is the ~1 MB long soak
localparam UDP_PAYLOAD      = 1470;                             //classic iperf udp datagram size
localparam UDP_WIRE_BYTES   = 8 + 14 + 20 + 8 + UDP_PAYLOAD + 4;   //1524
localparam SEQUENCE_OFFSET  = 42;                               //frame offset of the payload (14 + 20 + 8)

automatic integer       s;
automatic logic [7:0]   datagram [0:1525];
automatic integer       rx_datagrams        = 0;
automatic integer       lost_datagrams      = 0;
automatic integer       reordered_datagrams = 0;
automatic integer       ingress_bad         = 0;
automatic real          jitter_ns           = 0.0;
automatic real          previous_transit    = 0.0;
automatic bit           have_transit        = 0;
automatic time          blast_start         = 0;
automatic time          blast_end           = 0;
automatic real          bandwidth_gbps;

$display("Running case 011");
$display("Emulating an iperf3 UDP test: client on RGMII port 1 -> server on RGMII port 0, %0d datagrams of %0d bytes", DATAGRAMS, UDP_PAYLOAD);

//server side receiver: reassemble the byte stream entering the rgmii port 0
//shipper (frame content without preamble, after all switch processing),
//decode the sequence number and send timestamp of every datagram, and run
//the iperf3 receiver statistics
fork : monitors
    begin
        automatic integer       byte_index = 0;
        automatic logic [7:0]   capture [0:63];
        automatic logic [31:0]  sequence_number;
        automatic logic [63:0]  send_time;
        automatic integer       expected_sequence = 0;
        automatic real          transit;
        automatic real          delta;
        forever begin
            @(posedge testbench.rgmii_clock);
            if (testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper_data_ready
                && testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper_data_enable) begin
                if (testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper_data[8]) begin
                    byte_index = 0;
                end
                else begin
                    byte_index = byte_index + 1;
                end
                if (byte_index < 64) begin
                    capture[byte_index] = testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper_data[7:0];
                end
                //sequence and timestamp are fully captured at this offset
                if (byte_index == SEQUENCE_OFFSET + 11) begin
                    sequence_number = {capture[SEQUENCE_OFFSET],   capture[SEQUENCE_OFFSET+1],
                                       capture[SEQUENCE_OFFSET+2], capture[SEQUENCE_OFFSET+3]};
                    send_time       = {capture[SEQUENCE_OFFSET+4], capture[SEQUENCE_OFFSET+5],
                                       capture[SEQUENCE_OFFSET+6], capture[SEQUENCE_OFFSET+7],
                                       capture[SEQUENCE_OFFSET+8], capture[SEQUENCE_OFFSET+9],
                                       capture[SEQUENCE_OFFSET+10],capture[SEQUENCE_OFFSET+11]};
                    rx_datagrams    = rx_datagrams + 1;

                    if (integer'(sequence_number) > expected_sequence) begin
                        lost_datagrams      = lost_datagrams + (integer'(sequence_number) - expected_sequence);
                        expected_sequence   = integer'(sequence_number) + 1;
                    end
                    else if (integer'(sequence_number) < expected_sequence) begin
                        reordered_datagrams = reordered_datagrams + 1;
                    end
                    else begin
                        expected_sequence   = expected_sequence + 1;
                    end

                    //rfc 1889 smoothed interarrival jitter over the transit
                    //time derived from the embedded send timestamp
                    transit = real'($time) - real'(send_time);
                    if (have_transit) begin
                        delta = transit - previous_transit;
                        if (delta < 0) delta = -delta;
                        jitter_ns = jitter_ns + (delta - jitter_ns) / 16.0;
                    end
                    previous_transit = transit;
                    have_transit     = 1;
                end
            end
        end
    end
    begin
        forever begin
            @(posedge testbench.core_clock);
            if (testbench.switch_core.genblk3[0].rgmii_port.ethernet_packet_parser.bad_packet != 0
                || testbench.switch_core.genblk3[1].rgmii_port.ethernet_packet_parser.bad_packet != 0) begin
                ingress_bad = ingress_bad + 1;
            end
        end
    end
join_none

//client: stream datagrams back to back at line rate with the standard
//inter packet gap, sequence numbered and timestamped like iperf3
blast_start = $time;
for (s = 0; s < DATAGRAMS; s = s + 1) begin
    build_case_011_datagram(datagram, s);
    drive_case_010_frame(1, datagram, UDP_WIRE_BYTES);
end
blast_end = $time;

fork : f0
    begin
        #10ms;
        $fatal(0, "%t : udp receive timeout, %0d / %0d datagrams (lost %0d, ingress bad %0d)",
               $time, rx_datagrams, DATAGRAMS, lost_datagrams, ingress_bad);
        disable f0;
    end
    begin
        wait (rx_datagrams >= DATAGRAMS);
        disable f0;
    end
join
disable monitors;

if (ingress_bad != 0) begin
    $fatal(0, "%0d frames failed crc at ingress during the udp test", ingress_bad);
end
if (lost_datagrams != 0) begin
    $fatal(0, "udp datagram loss: %0d / %0d", lost_datagrams, DATAGRAMS);
end
if (reordered_datagrams != 0) begin
    $fatal(0, "udp datagram reordering: %0d datagrams arrived out of order", reordered_datagrams);
end

bandwidth_gbps = (DATAGRAMS * UDP_PAYLOAD * 8.0) / real'(blast_end - blast_start);
if (bandwidth_gbps < 0.9) begin
    $fatal(0, "udp bandwidth %.3f Gbps is below the 0.9 Gbps line rate expectation", bandwidth_gbps);
end
$display("Emulated iperf3 UDP test complete: %0d bytes, bandwidth %.3f Gbps, jitter %.1f ns, lost/total %0d/%0d datagrams",
         DATAGRAMS*UDP_PAYLOAD, bandwidth_gbps, jitter_ns, lost_datagrams, DATAGRAMS);

endtask: case_011

//build one udp datagram frame: sequence number then a 64 bit send timestamp
//at the start of the payload, pattern fill after, matching the shape of an
//iperf3 udp test packet
task automatic build_case_011_datagram(ref logic [7:0] frame [0:1525], input integer sequence_number);
    automatic logic [7:0]  ipv4_header [0:19];
    automatic logic [31:0] crc;
    automatic logic [63:0] now;
    automatic integer      ip_total;
    automatic integer      frame_bytes;
    automatic integer      k;

    ip_total    = 20 + 8 + 1470;
    frame_bytes = 14 + ip_total;
    now         = $time;

    for (k=0; k<7; k=k+1) frame[k] = 8'h55;
    frame[7] = 8'hD5;

    //client -> server
    frame[8]  = 8'h0D; frame[9]  = 8'hF0; frame[10] = 8'h0D; frame[11] = 8'h00; frame[12] = 8'h00; frame[13] = 8'hA0;
    frame[14] = 8'h0D; frame[15] = 8'hF0; frame[16] = 8'h0D; frame[17] = 8'h00; frame[18] = 8'h00; frame[19] = 8'hB1;
    frame[20] = 8'h08; frame[21] = 8'h00;

    ipv4_header[0]  = 8'h45;                        ipv4_header[1]  = 8'h00;
    ipv4_header[2]  = ip_total[15:8];               ipv4_header[3]  = ip_total[7:0];
    ipv4_header[4]  = sequence_number[15:8];        ipv4_header[5]  = sequence_number[7:0];
    ipv4_header[6]  = 8'h40;                        ipv4_header[7]  = 8'h00;
    ipv4_header[8]  = 8'h40;                        ipv4_header[9]  = 8'h11;               //ttl, udp
    ipv4_header[10] = 8'h00;                        ipv4_header[11] = 8'h00;
    ipv4_header[12] = 8'h0A; ipv4_header[13] = 8'h00; ipv4_header[14] = 8'h00; ipv4_header[15] = 8'h02;
    ipv4_header[16] = 8'h0A; ipv4_header[17] = 8'h00; ipv4_header[18] = 8'h00; ipv4_header[19] = 8'h01;
    {ipv4_header[10], ipv4_header[11]} = case_010_ipv4_checksum(ipv4_header);
    for (k=0; k<20; k=k+1) frame[22+k] = ipv4_header[k];

    //udp header, checksum zero (legal for udp over ipv4)
    frame[42] = 8'hC3; frame[43] = 8'h50;                       //source 50000
    frame[44] = 8'h14; frame[45] = 8'h51;                       //destination 5201
    frame[46] = 8'h05; frame[47] = 8'hC6;                       //length 1478
    frame[48] = 8'h00; frame[49] = 8'h00;

    //payload: sequence number, send timestamp, then pattern
    frame[50] = sequence_number[31:24]; frame[51] = sequence_number[23:16];
    frame[52] = sequence_number[15:8];  frame[53] = sequence_number[7:0];
    for (k=0; k<8; k=k+1) frame[54+k] = now[63-8*k -: 8];
    for (k=12; k<1470; k=k+1) frame[50+k] = k[7:0] ^ sequence_number[7:0];

    crc = case_009_crc32(frame, 8, frame_bytes);
    frame[8+frame_bytes]   = crc[31:24];
    frame[8+frame_bytes+1] = crc[23:16];
    frame[8+frame_bytes+2] = crc[15:8];
    frame[8+frame_bytes+3] = crc[7:0];
endtask

`endif
