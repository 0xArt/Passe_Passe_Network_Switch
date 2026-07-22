`timescale 1ns / 1ps
//unit test: egress_scheduler with two modeled ingress engines.
//covers grant+lock+stream+release on last, round robin alternation under
//contention, release of a revoked request without beat leakage, and
//no grant while the transmit fifo is not ready
module tb_egress_scheduler;

localparam N = 2;
localparam W = 1;

logic clock   = 0;
logic reset_n = 0;

always #2 clock = ~clock;

logic   [N-1:0]                     request       = '0;
logic   [N-1:0][(W*8)-1:0]          ingress_data  = '0;
logic   [N-1:0]                     ingress_first = '0;
logic   [N-1:0]                     ingress_last  = '0;
logic   [N-1:0][$clog2(W+1)-1:0]    ingress_count = '0;
logic   [N-1:0]                     ingress_valid = '0;
logic                               transmit_ready = 1;

wire    [N-1:0]                     grant;
wire    [(W*8)-1:0]                 transmit_data;
wire                                transmit_first;
wire                                transmit_last;
wire    [$clog2(W+1)-1:0]           transmit_byte_count;
wire                                transmit_valid;

egress_scheduler #(.NUMBER_OF_PORTS(N), .FABRIC_DATA_BYTES(W)) scheduler(
    .clock                  (clock),
    .reset_n                (reset_n),
    .request                (request),
    .ingress_data           (ingress_data),
    .ingress_first          (ingress_first),
    .ingress_last           (ingress_last),
    .ingress_byte_count     (ingress_count),
    .ingress_valid          (ingress_valid),
    .transmit_ready         (transmit_ready),

    .grant                  (grant),
    .transmit_data          (transmit_data),
    .transmit_first         (transmit_first),
    .transmit_last          (transmit_last),
    .transmit_byte_count    (transmit_byte_count),
    .transmit_valid         (transmit_valid)
);

logic [7:0] collected[$];
int leaked = 0;

always @(posedge clock) begin
    if (transmit_valid) collected.push_back(transmit_data);
end

//stream one frame of len beats from ingress port after it holds the grant
task automatic stream_frame(input int port, input logic [7:0] base, input int len);
    for (int k = 0; k < len; k++) begin
        ingress_data[port]  <= base + k;
        ingress_first[port] <= (k == 0);
        ingress_last[port]  <= (k == len-1);
        ingress_count[port] <= 1;
        ingress_valid[port] <= 1;
        @(posedge clock);
        ingress_valid[port] <= 0;
        //one gap cycle between beats to mimic all_granted_ready gating
        @(posedge clock);
    end
    request[port] <= 0;
    @(posedge clock);
endtask

task automatic wait_grant(input int port);
    while (!grant[port]) @(posedge clock);
endtask

initial begin
    #100000;
    $display("FAIL: watchdog timeout");
    $fatal(1);
end

initial begin
    repeat (10) @(posedge clock);
    reset_n = 1;
    repeat (5) @(posedge clock);

    //1. no grant while transmit fifo not ready
    transmit_ready = 0;
    request[0]     = 1;
    repeat (5) @(posedge clock);
    if (grant != 0) begin $display("FAIL: granted while not ready"); $fatal(1); end
    transmit_ready = 1;
    wait_grant(0);

    //2. stream a frame, grant must clear after last
    stream_frame(0, 8'h10, 4);
    repeat (3) @(posedge clock);
    if (grant != 0) begin $display("FAIL: grant held after last"); $fatal(1); end
    if (collected.size() != 4) begin $display("FAIL: expected 4 beats, got %0d", collected.size()); $fatal(1); end
    if (collected[0] !== 8'h10 || collected[3] !== 8'h13) begin $display("FAIL: beat data wrong"); $fatal(1); end
    collected.delete();

    //3. contention: both request, served one at a time, round robin
    request[0] = 1;
    request[1] = 1;
    @(posedge clock);
    while (grant == 0) @(posedge clock);
    if (grant == 2'b01) begin
        stream_frame(0, 8'h20, 2);
        wait_grant(1);
        stream_frame(1, 8'h30, 2);
    end
    else begin
        stream_frame(1, 8'h30, 2);
        wait_grant(0);
        stream_frame(0, 8'h20, 2);
    end
    repeat (3) @(posedge clock);
    if (collected.size() != 4) begin $display("FAIL: contention beats %0d", collected.size()); $fatal(1); end
    if (grant != 0) begin $display("FAIL: grant stuck after contention"); $fatal(1); end
    collected.delete();

    //4. revoked request: grant then drop the request without streaming.
    //   lock must release and nothing may leak into the fifo
    request[0] = 1;
    wait_grant(0);
    request[0] = 0;
    repeat (4) @(posedge clock);
    if (grant != 0) begin $display("FAIL: grant held after revoke"); $fatal(1); end
    if (collected.size() != 0) begin $display("FAIL: %0d beats leaked on revoke", collected.size()); $fatal(1); end

    //5. scheduler still serviceable after the revoke
    request[1] = 1;
    wait_grant(1);
    stream_frame(1, 8'h40, 3);
    repeat (3) @(posedge clock);
    if (collected.size() != 3) begin $display("FAIL: post revoke beats %0d", collected.size()); $fatal(1); end

    $display("PASS: tb_egress_scheduler");
    $finish;
end

endmodule
