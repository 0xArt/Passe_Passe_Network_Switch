`ifndef _case_010_svh_
`define _case_010_svh_

//iperf3 style tcp throughput emulation. the client station sits behind
//rgmii port 1 and the server behind rgmii port 0 (both macs were learned
//during case 009). a tcp handshake is followed by a windowed bulk transfer
//of mss sized segments from client to server, ack clocked by actual frame
//delivery at the server wire (delayed ack, one ack per two segments), then
//a fin exchange. data and acks flow through the switch simultaneously in
//opposite directions between the same two ports, which no other case
//exercises. the switch is layer 2, so tcp fields are realistic but the tcp
//checksum is not validated by anything and is left zero
function logic [15:0] case_010_ipv4_checksum(input logic [7:0] header [0:19]);
    logic [31:0] sum;
    sum = 0;
    for (int k = 0; k < 20; k = k + 2) begin
        sum = sum + {header[k], header[k+1]};
    end
    sum = (sum & 32'hFFFF) + (sum >> 16);
    sum = (sum & 32'hFFFF) + (sum >> 16);
    return ~sum[15:0];
endfunction

task case_010();

localparam SEGMENTS         = 40;     //keep even for the delayed ack pump. 720 gives the ~1 MB long soak
localparam MSS              = 1460;
localparam WINDOW_SEGMENTS  = 8;
localparam DATA_WIRE_BYTES  = 8 + 14 + 20 + 20 + MSS + 4;   //1526
localparam ACK_WIRE_BYTES   = 72;                           //minimum frame

automatic integer       s;
automatic logic [7:0]   data_frame [0:1525];
automatic logic [7:0]   ack_frame  [0:1525];
automatic logic [31:0]  client_seq;
automatic logic [31:0]  server_seq;
automatic integer       server_wire_frames      = 0;
automatic integer       client_wire_frames      = 0;
automatic integer       ingress_bad             = 0;
automatic integer       server_rx_base          = 0;
automatic integer       client_rx_base          = 0;
automatic integer       acks_sent               = 0;
automatic time          transfer_start          = 0;
automatic time          transfer_end            = 0;
automatic real          goodput_gbps;
automatic integer       client_request_cycles   = 0;
automatic integer       server_request_cycles   = 0;

$display("Running case 010");
$display("Emulating an iperf3 TCP transfer: client on RGMII port 1 -> server on RGMII port 0, %0d segments of %0d bytes", SEGMENTS, MSS);

//frames leaving the switch toward each station, and crc health at ingress
fork : monitors
    begin
        forever begin
            @(negedge testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper_shipped_data_valid);
            server_wire_frames = server_wire_frames + 1;
        end
    end
    begin
        forever begin
            @(negedge testbench.switch_core.genblk3[1].rgmii_port.rgmii_byte_shipper_shipped_data_valid);
            client_wire_frames = client_wire_frames + 1;
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
    begin
        //admission pressure: cycles the ingress engines spend asking the
        //egress schedulers for a grant. the minimum is three per frame; any
        //excess means the frame reserving threshold deferred admission
        forever begin
            @(posedge testbench.core_clock);
            if (integer'(testbench.switch_core.header_engines[4].port_header_engine.state) == 3) begin
                client_request_cycles = client_request_cycles + 1;
            end
            if (integer'(testbench.switch_core.header_engines[3].port_header_engine.state) == 3) begin
                server_request_cycles = server_request_cycles + 1;
            end
        end
    end
join_none

//---------------------------------------------------------------- handshake
client_seq = 32'h0000_1000;
server_seq = 32'h0000_2000;

//client SYN
begin
    automatic logic [7:0] syn_frame [0:1525];
    build_case_010_frame(syn_frame, 1, client_seq, 32'h0, 8'h02, 0);
    drive_case_010_frame(1, syn_frame, ACK_WIRE_BYTES);
    wait (server_wire_frames >= 1);

    //server SYN-ACK
    build_case_010_frame(syn_frame, 0, server_seq, client_seq + 1, 8'h12, 0);
    drive_case_010_frame(0, syn_frame, ACK_WIRE_BYTES);
    wait (client_wire_frames >= 1);

    //client ACK, connection established
    client_seq = client_seq + 1;
    server_seq = server_seq + 1;
    build_case_010_frame(syn_frame, 1, client_seq, server_seq, 8'h10, 0);
    drive_case_010_frame(1, syn_frame, ACK_WIRE_BYTES);
    wait (server_wire_frames >= 2);
end

$display("TCP handshake complete");
server_rx_base = server_wire_frames;
client_rx_base = client_wire_frames;

//----------------------------------------------------- windowed bulk transfer
transfer_start = $time;
fork : transfer
    begin
        //both pumps must finish; the watchdog races the pair, not either one
        fork
            begin : client_data_pump
                for (s = 0; s < SEGMENTS; s = s + 1) begin
                    //respect the congestion window: unacked segments stay below it
                    wait ((s - 2*acks_sent) < WINDOW_SEGMENTS);
                    build_case_010_frame(data_frame, 1, client_seq + s*MSS, server_seq, 8'h18, MSS);
                    drive_case_010_frame(1, data_frame, DATA_WIRE_BYTES);
                end
            end
            begin : server_ack_pump
                while (acks_sent*2 < SEGMENTS) begin
                    //delayed ack: acknowledge every second segment actually
                    //delivered on the server wire
                    wait ((server_wire_frames - server_rx_base) >= (acks_sent + 1)*2);
                    build_case_010_frame(ack_frame, 0, server_seq, client_seq + (acks_sent + 1)*2*MSS, 8'h10, 0);
                    drive_case_010_frame(0, ack_frame, ACK_WIRE_BYTES);
                    acks_sent = acks_sent + 1;
                end
            end
        join
    end
    begin : transfer_watchdog
        #15ms;
        $fatal(0, "%t : tcp transfer timeout, server rx %0d / %0d segments, acks %0d",
               $time, server_wire_frames - server_rx_base, SEGMENTS, acks_sent);
    end
join_any
disable transfer;

//wait for the final segments and acks to drain to both wires
fork : f0
    begin
        #2ms;
        $fatal(0, "%t : tcp drain timeout, server rx %0d / %0d, client rx acks %0d / %0d",
               $time, server_wire_frames - server_rx_base, SEGMENTS, client_wire_frames - client_rx_base, SEGMENTS/2);
        disable f0;
    end
    begin
        wait ((server_wire_frames - server_rx_base) >= SEGMENTS
              && (client_wire_frames - client_rx_base) >= SEGMENTS/2);
        disable f0;
    end
join
transfer_end = $time;

//--------------------------------------------------------------------- fin
begin
    automatic logic [7:0] fin_frame [0:1525];
    build_case_010_frame(fin_frame, 1, client_seq + SEGMENTS*MSS, server_seq, 8'h11, 0);
    drive_case_010_frame(1, fin_frame, ACK_WIRE_BYTES);
    build_case_010_frame(fin_frame, 0, server_seq, client_seq + SEGMENTS*MSS + 1, 8'h11, 0);
    drive_case_010_frame(0, fin_frame, ACK_WIRE_BYTES);
    build_case_010_frame(fin_frame, 1, client_seq + SEGMENTS*MSS + 1, server_seq + 1, 8'h10, 0);
    drive_case_010_frame(1, fin_frame, ACK_WIRE_BYTES);
end

fork : f1
    begin
        #2ms;
        $fatal(0, "%t : fin exchange timeout", $time);
        disable f1;
    end
    begin
        wait ((server_wire_frames - server_rx_base) >= SEGMENTS + 2
              && (client_wire_frames - client_rx_base) >= SEGMENTS/2 + 1);
        disable f1;
    end
join
disable monitors;

if (ingress_bad != 0) begin
    $fatal(0, "%0d frames failed crc at ingress during the tcp transfer", ingress_bad);
end
if ((server_wire_frames - server_rx_base) != SEGMENTS + 2) begin
    $fatal(0, "server received %0d frames, expected %0d segments plus fin and final ack", server_wire_frames - server_rx_base, SEGMENTS + 2);
end
if ((client_wire_frames - client_rx_base) != SEGMENTS/2 + 1) begin
    $fatal(0, "client received %0d frames, expected %0d acks plus fin ack", client_wire_frames - client_rx_base, SEGMENTS/2 + 1);
end

goodput_gbps = (SEGMENTS * MSS * 8.0) / real'(transfer_end - transfer_start);
if (goodput_gbps < 0.9) begin
    $fatal(0, "tcp goodput %.3f Gbps is below the 0.9 Gbps line rate expectation", goodput_gbps);
end
$display("Emulated iperf3 TCP transfer complete: %0d bytes in %0t, goodput %.3f Gbps, full duplex with %0d acks",
         SEGMENTS*MSS, transfer_end - transfer_start, goodput_gbps, acks_sent);
//lossless by assertion above, so the iperf3 retransmission counter is zero
//by construction. admission deferral shows how hard the frame reserving
//egress threshold pushed back (minimum is 3 request cycles per frame)
$display("Retransmissions: 0 (asserted lossless). Admission request cycles: client->server %0d for %0d frames, server->client %0d for %0d frames",
         client_request_cycles, SEGMENTS + 4, server_request_cycles, SEGMENTS/2 + 2);

endtask: case_010

//build one tcp frame. to_server picks direction (macs, ips, ports). the
//frame includes preamble and fcs and is padded to the minimum size when
//the tcp payload is empty
task automatic build_case_010_frame(ref logic [7:0] frame [0:1525],
                                    input bit to_server,
                                    input logic [31:0] sequence_number,
                                    input logic [31:0] ack_number,
                                    input logic [7:0]  tcp_flags,
                                    input integer      payload_length);
    automatic logic [7:0]  ipv4_header [0:19];
    automatic logic [31:0] crc;
    automatic integer      ip_total;
    automatic integer      frame_bytes;
    automatic integer      wire_bytes;
    automatic integer      k;

    ip_total    = 20 + 20 + payload_length;
    frame_bytes = 14 + ip_total;
    if (frame_bytes < 60) frame_bytes = 60;
    wire_bytes  = 8 + frame_bytes + 4;

    for (k=0; k<7; k=k+1) frame[k] = 8'h55;
    frame[7] = 8'hD5;

    if (to_server) begin
        //client -> server
        frame[8]  = 8'h0D; frame[9]  = 8'hF0; frame[10] = 8'h0D; frame[11] = 8'h00; frame[12] = 8'h00; frame[13] = 8'hA0;
        frame[14] = 8'h0D; frame[15] = 8'hF0; frame[16] = 8'h0D; frame[17] = 8'h00; frame[18] = 8'h00; frame[19] = 8'hB1;
    end
    else begin
        //server -> client
        frame[8]  = 8'h0D; frame[9]  = 8'hF0; frame[10] = 8'h0D; frame[11] = 8'h00; frame[12] = 8'h00; frame[13] = 8'hB1;
        frame[14] = 8'h0D; frame[15] = 8'hF0; frame[16] = 8'h0D; frame[17] = 8'h00; frame[18] = 8'h00; frame[19] = 8'hA0;
    end
    frame[20] = 8'h08; frame[21] = 8'h00;

    //ipv4 header
    ipv4_header[0]  = 8'h45;                    ipv4_header[1]  = 8'h00;
    ipv4_header[2]  = ip_total[15:8];           ipv4_header[3]  = ip_total[7:0];
    ipv4_header[4]  = sequence_number[15:8];    ipv4_header[5]  = sequence_number[7:0];    //identification, varies per frame
    ipv4_header[6]  = 8'h40;                    ipv4_header[7]  = 8'h00;
    ipv4_header[8]  = 8'h40;                    ipv4_header[9]  = 8'h06;                   //ttl, tcp
    ipv4_header[10] = 8'h00;                    ipv4_header[11] = 8'h00;
    if (to_server) begin
        ipv4_header[12] = 8'h0A; ipv4_header[13] = 8'h00; ipv4_header[14] = 8'h00; ipv4_header[15] = 8'h02;
        ipv4_header[16] = 8'h0A; ipv4_header[17] = 8'h00; ipv4_header[18] = 8'h00; ipv4_header[19] = 8'h01;
    end
    else begin
        ipv4_header[12] = 8'h0A; ipv4_header[13] = 8'h00; ipv4_header[14] = 8'h00; ipv4_header[15] = 8'h01;
        ipv4_header[16] = 8'h0A; ipv4_header[17] = 8'h00; ipv4_header[18] = 8'h00; ipv4_header[19] = 8'h02;
    end
    {ipv4_header[10], ipv4_header[11]} = case_010_ipv4_checksum(ipv4_header);
    for (k=0; k<20; k=k+1) frame[22+k] = ipv4_header[k];

    //tcp header (iperf3 control/data port 5201). checksum left zero, the
    //layer 2 switch does not validate it
    if (to_server) begin
        frame[42] = 8'hC3; frame[43] = 8'h50;   //source 50000
        frame[44] = 8'h14; frame[45] = 8'h51;   //destination 5201
    end
    else begin
        frame[42] = 8'h14; frame[43] = 8'h51;
        frame[44] = 8'hC3; frame[45] = 8'h50;
    end
    frame[46] = sequence_number[31:24]; frame[47] = sequence_number[23:16];
    frame[48] = sequence_number[15:8];  frame[49] = sequence_number[7:0];
    frame[50] = ack_number[31:24];      frame[51] = ack_number[23:16];
    frame[52] = ack_number[15:8];       frame[53] = ack_number[7:0];
    frame[54] = 8'h50;                  frame[55] = tcp_flags;
    frame[56] = 8'hFF;                  frame[57] = 8'hFF;
    frame[58] = 8'h00;                  frame[59] = 8'h00;
    frame[60] = 8'h00;                  frame[61] = 8'h00;

    //payload pattern, then pad to the minimum frame size
    for (k=0; k<payload_length; k=k+1) begin
        frame[62+k] = k[7:0] ^ sequence_number[7:0];
    end
    for (k=22+ip_total; k<8+frame_bytes; k=k+1) begin
        frame[k] = 8'h00;
    end

    crc = case_009_crc32(frame, 8, frame_bytes);
    frame[8+frame_bytes]   = crc[31:24];
    frame[8+frame_bytes+1] = crc[23:16];
    frame[8+frame_bytes+2] = crc[15:8];
    frame[8+frame_bytes+3] = crc[7:0];
endtask

//drive one frame onto an rgmii port at line rate with the standard
//12 byte time inter packet gap
task automatic drive_case_010_frame(input integer port, ref logic [7:0] frame [0:1525], input integer wire_bytes);
    for (int k = 0; k < wire_bytes; k = k + 1) begin
        @(posedge testbench.rgmii_clock);
        testbench.rgmii_data_control[port] = 1;
        testbench.rgmii_data[port]         = frame[k][3:0];
        @(negedge testbench.rgmii_clock);
        testbench.rgmii_data[port]         = frame[k][7:4];
    end
    @(posedge testbench.rgmii_clock);
    testbench.rgmii_data_control[port] = 0;
    testbench.rgmii_data[port]         = 0;
    repeat (11) @(posedge testbench.rgmii_clock);
endtask

`endif
