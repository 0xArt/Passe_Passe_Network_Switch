`timescale 1ns / 1ps
//unit test: width_adapter_up -> width_adapter_down loopback at W=4.
//random frame lengths, random input gaps, random output backpressure.
//checks byte data, first and last flags survive the round trip unchanged
module tb_width_adapter;

localparam W = 4;

logic clock   = 0;
logic reset_n = 0;

always #2 clock = ~clock;

logic   [8:0]               in_byte  = 0;
logic                       in_valid = 0;
logic                       in_last  = 0;
wire                        in_ready;
wire    [(W*8)-1:0]         beat_data;
wire                        beat_first;
wire                        beat_last;
wire    [$clog2(W+1)-1:0]   beat_count;
wire                        beat_valid;
wire                        beat_ready;
wire    [8:0]               out_byte;
wire                        out_valid;
wire                        out_last;
logic                       out_ready = 0;

width_adapter_up #(.FABRIC_DATA_BYTES(W)) up(
    .clock              (clock),
    .reset_n            (reset_n),
    .byte_data          (in_byte),
    .byte_data_valid    (in_valid),
    .byte_data_last     (in_last),
    .beat_ready         (beat_ready),

    .byte_data_ready    (in_ready),
    .beat_data          (beat_data),
    .beat_first         (beat_first),
    .beat_last          (beat_last),
    .beat_byte_count    (beat_count),
    .beat_valid         (beat_valid)
);

width_adapter_down #(.FABRIC_DATA_BYTES(W)) down(
    .clock              (clock),
    .reset_n            (reset_n),
    .beat_data          (beat_data),
    .beat_first         (beat_first),
    .beat_last          (beat_last),
    .beat_byte_count    (beat_count),
    .beat_valid         (beat_valid),
    .byte_data_ready    (out_ready),

    .beat_ready         (beat_ready),
    .byte_data          (out_byte),
    .byte_data_valid    (out_valid),
    .byte_data_last     (out_last)
);

logic [7:0] expected_data  [$];
bit         expected_first [$];
bit         expected_last  [$];
int         checked = 0;

always @(posedge clock) out_ready <= ($urandom_range(0,3) != 0);

always @(posedge clock) begin
    if (out_valid && out_ready) begin
        if (expected_data.size() == 0) begin
            $display("FAIL: unexpected output byte %02h", out_byte[7:0]);
            $fatal(1);
        end
        if (out_byte[7:0] !== expected_data.pop_front()) begin
            $display("FAIL: data mismatch at byte %0d", checked);
            $fatal(1);
        end
        if (out_byte[8] !== expected_first.pop_front()) begin
            $display("FAIL: first flag mismatch at byte %0d", checked);
            $fatal(1);
        end
        if (out_last !== expected_last.pop_front()) begin
            $display("FAIL: last flag mismatch at byte %0d", checked);
            $fatal(1);
        end
        checked++;
    end
end

task automatic send_frame(input int len);
    logic [7:0] payload;
    for (int k = 0; k < len; k++) begin
        while ($urandom_range(0,3) == 0) @(posedge clock);
        payload  = $urandom;
        in_byte  <= {(k == 0), payload};
        in_last  <= (k == len-1);
        in_valid <= 1;
        expected_data.push_back(payload);
        expected_first.push_back(k == 0);
        expected_last.push_back(k == len-1);
        do @(posedge clock); while (!in_ready);
        in_valid <= 0;
    end
endtask

initial begin
    #100000;
    $display("FAIL: watchdog timeout, %0d bytes checked", checked);
    $fatal(1);
end

initial begin
    repeat (10) @(posedge clock);
    reset_n = 1;
    repeat (5) @(posedge clock);

    //boundary lengths around the beat size, then random lengths
    for (int len = 1; len <= 10; len++) send_frame(len);
    send_frame(15); send_frame(16); send_frame(17); send_frame(60);
    for (int f = 0; f < 20; f++) send_frame($urandom_range(1, 80));

    while (expected_data.size() != 0) @(posedge clock);
    repeat (10) @(posedge clock);
    $display("PASS: tb_width_adapter, %0d bytes checked", checked);
    $finish;
end

endmodule
