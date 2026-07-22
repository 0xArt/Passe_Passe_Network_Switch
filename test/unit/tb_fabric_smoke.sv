`timescale 1ns / 1ps
//unit test: fabric smoke. two port_header_engines, the cam_access_arbiter,
//the real cam_table and two egress_schedulers wired exactly as the switch core will
//wire them, at FABRIC_DATA_BYTES = 1.
//covers: flood on unknown destination, learning, unicast after learning in
//both directions, hairpin drop, and recovery after the drop
module tb_fabric_smoke;

localparam N = 2;
localparam W = 1;

logic clock   = 0;
logic reset_n = 0;

always #2 clock = ~clock;

//engine ingress streams (driven by the test)
logic   [N-1:0][(W*8)-1:0]          in_data  = '0;
logic   [N-1:0]                     in_first = '0;
logic   [N-1:0]                     in_last  = '0;
logic   [N-1:0]                     in_valid = '0;
wire    [N-1:0]                     in_ready;

//engine <-> cam arbiter
wire    [N-1:0]                     match_request;
wire    [N-1:0][47:0]               match_key;
wire    [N-1:0]                     match_ack;
wire    [N-1:0]                     match_response_valid;
wire    [$clog2(N)-1:0]             match_response_index;
wire                                match_response_no_match;
wire    [N-1:0]                     learn_request;
wire    [N-1:0][47:0]               learn_key;
wire    [N-1:0]                     learn_ack;

//arbiter <-> cam
wire    [47:0]                      cam_key_match;
wire                                cam_key_match_valid;
wire    [47:0]                      cam_key_delete;
wire                                cam_key_delete_valid;
wire    [47:0]                      cam_key_write;
wire    [$clog2(N)-1:0]             cam_index;
wire                                cam_key_write_valid;
wire    [$clog2(N)-1:0]             cam_match_index;
wire                                cam_match_valid;
wire                                cam_no_match;

//engine fabric side
wire    [N-1:0][N-1:0]              port_request;   //[engine][egress]
wire    [N-1:0][(W*8)-1:0]          out_data;
wire    [N-1:0]                     out_first;
wire    [N-1:0]                     out_last;
wire    [N-1:0][$clog2(W+1)-1:0]    out_byte_count;
wire    [N-1:0]                     out_valid;

//schedulers
wire    [N-1:0][N-1:0]              sched_grant;    //[egress][engine]
logic   [N-1:0]                     egress_fifo_ready = '1;
wire    [N-1:0][(W*8)-1:0]          transmit_data;
wire    [N-1:0]                     transmit_first;
wire    [N-1:0]                     transmit_last;
wire    [N-1:0][$clog2(W+1)-1:0]    transmit_byte_count;
wire    [N-1:0]                     transmit_valid;

genvar g;
generate
    for (g=0; g<N; g=g+1) begin : engines
        wire [N-1:0] engine_grant;
        for (genvar e=0; e<N; e=e+1) begin
            assign engine_grant[e] = sched_grant[e][g];
        end

        port_header_engine #(
            .NUMBER_OF_PORTS    (N),
            .PORT_INDEX         (g),
            .FABRIC_DATA_BYTES  (W)
        ) engine (
            .clock                      (clock),
            .reset_n                    (reset_n),
            .in_data                    (in_data[g]),
            .in_first                   (in_first[g]),
            .in_last                    (in_last[g]),
            .in_byte_count              (1'b1),
            .in_valid                   (in_valid[g]),
            .match_ack                  (match_ack[g]),
            .match_response_valid       (match_response_valid[g]),
            .match_response_index       (match_response_index),
            .match_response_no_match    (match_response_no_match),
            .learn_ack                  (learn_ack[g]),
            .port_grant                 (engine_grant),
            .egress_ready               (egress_fifo_ready),

            .in_ready                   (in_ready[g]),
            .match_request              (match_request[g]),
            .match_key                  (match_key[g]),
            .learn_request              (learn_request[g]),
            .learn_key                  (learn_key[g]),
            .port_request               (port_request[g]),
            .out_data                   (out_data[g]),
            .out_first                  (out_first[g]),
            .out_last                   (out_last[g]),
            .out_byte_count             (out_byte_count[g]),
            .out_valid                  (out_valid[g])
        );
    end

    for (g=0; g<N; g=g+1) begin : schedulers
        wire [N-1:0] egress_request;
        for (genvar e=0; e<N; e=e+1) begin
            assign egress_request[e] = port_request[e][g];
        end

        egress_scheduler #(
            .NUMBER_OF_PORTS    (N),
            .FABRIC_DATA_BYTES  (W)
        ) scheduler (
            .clock                  (clock),
            .reset_n                (reset_n),
            .request                (egress_request),
            .ingress_data           (out_data),
            .ingress_first          (out_first),
            .ingress_last           (out_last),
            .ingress_byte_count     (out_byte_count),
            .ingress_valid          (out_valid),
            .transmit_ready         (egress_fifo_ready[g]),

            .grant                  (sched_grant[g]),
            .transmit_data          (transmit_data[g]),
            .transmit_first         (transmit_first[g]),
            .transmit_last          (transmit_last[g]),
            .transmit_byte_count    (transmit_byte_count[g]),
            .transmit_valid         (transmit_valid[g])
        );
    end
endgenerate

cam_access_arbiter #(.NUMBER_OF_PORTS(N)) arbiter(
    .clock                      (clock),
    .reset_n                    (reset_n),
    .match_request              (match_request),
    .match_key                  (match_key),
    .learn_request              (learn_request),
    .learn_key                  (learn_key),
    .cam_match_valid            (cam_match_valid),
    .cam_match_index            (cam_match_index),
    .cam_no_match               (cam_no_match),

    .match_ack                  (match_ack),
    .match_response_valid       (match_response_valid),
    .match_response_index       (match_response_index),
    .match_response_no_match    (match_response_no_match),
    .learn_ack                  (learn_ack),
    .cam_key_match              (cam_key_match),
    .cam_key_match_valid        (cam_key_match_valid),
    .cam_key_delete             (cam_key_delete),
    .cam_key_delete_valid       (cam_key_delete_valid),
    .cam_key_write              (cam_key_write),
    .cam_index                  (cam_index),
    .cam_key_write_valid        (cam_key_write_valid)
);

cam_table #(.KEY_WIDTH(48), .TABLE_DEPTH(16), .INDEX_DEPTH(N)) cam(
    .clock          (clock),
    .reset_n        (reset_n),
    .key_match      (cam_key_match),
    .key_delete     (cam_key_delete),
    .key_write      (cam_key_write),
    .index          (cam_index),
    .match_enable   (cam_key_match_valid),
    .delete_enable  (cam_key_delete_valid),
    .write_enable   (cam_key_write_valid),

    .match_index    (cam_match_index),
    .match_valid    (cam_match_valid),
    .no_match       (cam_no_match)
);

localparam logic [47:0] MAC0      = 48'h02_00_00_00_00_A0;
localparam logic [47:0] MAC1      = 48'h02_00_00_00_00_B1;
localparam logic [47:0] BROADCAST = 48'hFF_FF_FF_FF_FF_FF;
localparam FRAME_LEN = 60;

logic [7:0] collected_data  [N-1:0][$];
bit         collected_first [N-1:0][$];
bit         collected_last  [N-1:0][$];

always @(posedge clock) begin
    for (int e = 0; e < N; e++) begin
        if (transmit_valid[e]) begin
            collected_data[e].push_back(transmit_data[e]);
            collected_first[e].push_back(transmit_first[e]);
            collected_last[e].push_back(transmit_last[e]);
        end
    end
end

logic [7:0] frame [0:FRAME_LEN-1];

task automatic build_frame(input logic [47:0] mac_destination, input logic [47:0] mac_source, input logic [7:0] seed);
    for (int k = 0; k < 6; k++) begin
        frame[k]     = mac_destination[47-(8*k) -: 8];
        frame[k+6]   = mac_source[47-(8*k) -: 8];
    end
    for (int k = 12; k < FRAME_LEN; k++) begin
        frame[k] = seed + k;
    end
endtask

task automatic send_frame(input int port);
    for (int k = 0; k < FRAME_LEN; k++) begin
        in_data[port]  <= frame[k];
        in_first[port] <= (k == 0);
        in_last[port]  <= (k == FRAME_LEN-1);
        in_valid[port] <= 1;
        do @(posedge clock); while (!in_ready[port]);
        in_valid[port] <= 0;
    end
endtask

task automatic check_frame(input int egress, input string label);
    if (collected_data[egress].size() != FRAME_LEN) begin
        $display("FAIL: %s expected %0d bytes at egress %0d, got %0d", label, FRAME_LEN, egress, collected_data[egress].size());
        $fatal(1);
    end
    for (int k = 0; k < FRAME_LEN; k++) begin
        if (collected_data[egress][k] !== frame[k]) begin
            $display("FAIL: %s data mismatch at byte %0d (got %02h want %02h)", label, k, collected_data[egress][k], frame[k]);
            $fatal(1);
        end
        if (collected_first[egress][k] !== (k == 0)) begin
            $display("FAIL: %s first flag wrong at byte %0d", label, k);
            $fatal(1);
        end
        if (collected_last[egress][k] !== (k == FRAME_LEN-1)) begin
            $display("FAIL: %s last flag wrong at byte %0d", label, k);
            $fatal(1);
        end
    end
    collected_data[egress].delete();
    collected_first[egress].delete();
    collected_last[egress].delete();
endtask

task automatic check_empty(input int egress, input string label);
    if (collected_data[egress].size() != 0) begin
        $display("FAIL: %s expected nothing at egress %0d, got %0d bytes", label, egress, collected_data[egress].size());
        $fatal(1);
    end
endtask

task automatic wait_frame(input int egress);
    while (collected_data[egress].size() < FRAME_LEN) @(posedge clock);
    repeat (5) @(posedge clock);
endtask

initial begin
    #500000;
    $display("FAIL: watchdog timeout");
    $fatal(1);
end

initial begin
    repeat (10) @(posedge clock);
    reset_n = 1;
    repeat (5) @(posedge clock);

    //1. unknown destination from port 0 floods to port 1 only
    build_frame(BROADCAST, MAC0, 8'h10);
    send_frame(0);
    wait_frame(1);
    check_frame(1, "flood");
    check_empty(0, "flood");
    repeat (20) @(posedge clock);

    //2. port 1 sends to the mac port 0 just taught the cam: unicast to egress 0
    build_frame(MAC0, MAC1, 8'h20);
    send_frame(1);
    wait_frame(0);
    check_frame(0, "unicast to 0");
    check_empty(1, "unicast to 0");
    repeat (20) @(posedge clock);

    //3. port 0 sends to mac learned from port 1: unicast to egress 1
    build_frame(MAC1, MAC0, 8'h30);
    send_frame(0);
    wait_frame(1);
    check_frame(1, "unicast to 1");
    check_empty(0, "unicast to 1");
    repeat (20) @(posedge clock);

    //4. hairpin: port 0 sends to its own learned mac, frame must be dropped
    build_frame(MAC0, MAC0, 8'h40);
    send_frame(0);
    repeat (100) @(posedge clock);
    check_empty(0, "hairpin");
    check_empty(1, "hairpin");

    //5. recovery: flood again after the drop
    build_frame(BROADCAST, MAC0, 8'h50);
    send_frame(0);
    wait_frame(1);
    check_frame(1, "recovery flood");
    check_empty(0, "recovery flood");

    $display("PASS: tb_fabric_smoke");
    $finish;
end

endmodule
