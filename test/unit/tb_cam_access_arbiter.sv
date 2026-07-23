`timescale 1ns / 1ps
//unit test: cam_access_arbiter against the real cam_table.
//covers miss, learn+match, concurrent matches from two ports, simultaneous
//learns of the same mac from two ports (mac move atomicity: a duplicate
//entry would corrupt the one hot match index), and a mac move
module tb_cam_access_arbiter;

localparam N = 4;

logic clock   = 0;
logic reset_n = 0;

always #2 clock = ~clock;

logic   [N-1:0]             match_request = '0;
logic   [N-1:0][47:0]       match_key     = '0;
logic   [N-1:0]             learn_request = '0;
logic   [N-1:0][47:0]       learn_key     = '0;
wire    [N-1:0]             match_ack;
wire    [N-1:0]             match_response_valid;
wire    [$clog2(N)-1:0]     match_response_index;
wire                        match_response_no_match;
wire    [N-1:0]             learn_ack;

wire    [47:0]              cam_key_match;
wire                        cam_key_match_valid;
wire    [47:0]              cam_key_delete;
wire                        cam_key_delete_valid;
wire    [47:0]              cam_key_write;
wire    [$clog2(N)-1:0]     cam_index;
wire                        cam_key_write_valid;
wire    [$clog2(N)-1:0]     cam_match_index;
wire                        cam_match_valid;
wire                        cam_no_match;

cam_access_arbiter #(.NUMBER_OF_PORTS(N)) arbiter(
    .clock                      (clock),
    .reset_n                    (reset_n),
    .match_request              (match_request),
    .match_key                  (match_key),
    .learn_request              (learn_request),
    .learn_key                  (learn_key),
    .cam_match_enable           (cam_match_valid),
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

localparam logic [47:0] KEY_A = 48'hAA_BB_CC_DD_EE_01;
localparam logic [47:0] KEY_B = 48'h11_22_33_44_55_02;

task automatic do_learn(input int port, input logic [47:0] key);
    learn_key[port]     <= key;
    learn_request[port] <= 1;
    @(posedge clock);
    while (!learn_ack[port]) @(posedge clock);
    learn_request[port] <= 0;
    @(posedge clock);
endtask

task automatic do_match(input int port, input logic [47:0] key,
                        output logic no_match, output logic [$clog2(N)-1:0] idx);
    match_key[port]     <= key;
    match_request[port] <= 1;
    @(posedge clock);
    while (!match_ack[port]) @(posedge clock);
    match_request[port] <= 0;
    while (!match_response_valid[port]) @(posedge clock);
    no_match = match_response_no_match;
    idx      = match_response_index;
    @(posedge clock);
endtask

logic                   nm0, nm1, nm2, nm3;
logic [$clog2(N)-1:0]   idx0, idx1, idx2, idx3;

initial begin
    #100000;
    $display("FAIL: watchdog timeout");
    $fatal(1);
end

initial begin
    repeat (10) @(posedge clock);
    reset_n = 1;
    repeat (5) @(posedge clock);

    //1. miss on an empty table
    do_match(0, KEY_A, nm0, idx0);
    if (!nm0) begin $display("FAIL: expected no_match on empty table"); $fatal(1); end

    //2. learn then match from another port
    do_learn(0, KEY_A);
    repeat (8) @(posedge clock);
    do_match(1, KEY_A, nm1, idx1);
    if (nm1 || idx1 !== 0) begin $display("FAIL: expected match index 0, got nm=%0d idx=%0d", nm1, idx1); $fatal(1); end

    //3. concurrent matches from two ports (one hit, one miss)
    fork
        do_match(2, KEY_A, nm2, idx2);
        do_match(3, KEY_B, nm3, idx3);
    join
    if (nm2 || idx2 !== 0) begin $display("FAIL: concurrent hit wrong, nm=%0d idx=%0d", nm2, idx2); $fatal(1); end
    if (!nm3)              begin $display("FAIL: concurrent miss wrong"); $fatal(1); end

    //4. simultaneous learns of the same key from ports 1 and 2. a duplicate
    //   entry would or the indexes together (1|2 = 3) and be caught here
    fork
        do_learn(1, KEY_B);
        do_learn(2, KEY_B);
    join
    repeat (8) @(posedge clock);
    do_match(0, KEY_B, nm0, idx0);
    if (nm0 || !(idx0 == 1 || idx0 == 2)) begin
        $display("FAIL: mac move atomicity violated, nm=%0d idx=%0d", nm0, idx0);
        $fatal(1);
    end

    //5. mac move of KEY_A to port 3
    do_learn(3, KEY_A);
    repeat (8) @(posedge clock);
    do_match(1, KEY_A, nm1, idx1);
    if (nm1 || idx1 !== 3) begin $display("FAIL: mac move failed, nm=%0d idx=%0d", nm1, idx1); $fatal(1); end

    $display("PASS: tb_cam_access_arbiter");
    $finish;
end

endmodule
