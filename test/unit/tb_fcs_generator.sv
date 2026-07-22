`timescale 1ns / 1ps
//unit test: frame_check_sequence_generator at DATA_BYTES = 4 against the
//byte serial DATA_BYTES = 1 instance and an independent software crc32.
//covers all tail residues (length mod 4 = 0..3) and random lengths
module tb_fcs_generator;

localparam W = 4;

logic clock   = 0;
logic reset_n = 0;

always #2 clock = ~clock;

//byte serial reference instance
logic   [7:0]   ref_data        = 0;
logic           ref_enable      = 0;
logic           ref_last        = 0;
wire            ref_ready;
wire    [31:0]  ref_checksum;
wire            ref_checksum_valid;

frame_check_sequence_generator #(.DATA_BYTES(1)) reference_generator(
    .clock              (clock),
    .reset_n            (reset_n),
    .data               (ref_data),
    .data_enable        (ref_enable),
    .data_last          (ref_last),
    .data_byte_count    (1'b1),

    .ready              (ref_ready),
    .checksum           (ref_checksum),
    .checksum_valid     (ref_checksum_valid)
);

//beat wide instance under test
logic   [(W*8)-1:0]         beat_data   = 0;
logic                       beat_enable = 0;
logic                       beat_last   = 0;
logic   [$clog2(W+1)-1:0]   beat_count  = 0;
wire                        beat_ready;
wire    [31:0]              beat_checksum;
wire                        beat_checksum_valid;

frame_check_sequence_generator #(.DATA_BYTES(W)) beat_generator(
    .clock              (clock),
    .reset_n            (reset_n),
    .data               (beat_data),
    .data_enable        (beat_enable),
    .data_last          (beat_last),
    .data_byte_count    (beat_count),

    .ready              (beat_ready),
    .checksum           (beat_checksum),
    .checksum_valid     (beat_checksum_valid)
);

//independent software reference: standard reflected crc32, byte swapped to
//match the generator output ordering (most significant output byte is the
//first byte on the wire)
function automatic logic [31:0] software_crc32(input logic [7:0] frame [0:2047], input int len);
    logic [31:0] crc;
    crc = 32'hFFFF_FFFF;
    for (int k = 0; k < len; k++) begin
        crc = crc ^ {24'h0, frame[k]};
        for (int b = 0; b < 8; b++) begin
            if (crc[0]) crc = (crc >> 1) ^ 32'hEDB8_8320;
            else        crc = crc >> 1;
        end
    end
    crc = crc ^ 32'hFFFF_FFFF;
    return {crc[7:0], crc[15:8], crc[23:16], crc[31:24]};
endfunction

logic [7:0] frame [0:2047];
int         checked = 0;

task automatic run_frame(input int len);
    logic [31:0] expected;
    int          beats;
    int          tail;

    for (int k = 0; k < len; k++) frame[k] = $urandom;
    expected = software_crc32(frame, len);

    //drive the byte serial reference
    for (int k = 0; k < len; k++) begin
        @(posedge clock);
        ref_data    <= frame[k];
        ref_enable  <= 1;
        ref_last    <= (k == len-1);
    end
    @(posedge clock);
    ref_enable  <= 0;
    ref_last    <= 0;
    while (!ref_checksum_valid) @(posedge clock);
    if (ref_checksum !== expected) begin
        $display("FAIL: byte serial checksum mismatch len %0d (got %08h want %08h)", len, ref_checksum, expected);
        $fatal(1);
    end

    //drive the beat wide instance
    beats = (len + W - 1) / W;
    tail  = len - ((beats - 1) * W);
    for (int k = 0; k < beats; k++) begin
        @(posedge clock);
        for (int b = 0; b < W; b++) begin
            beat_data[(b*8) +: 8] <= ((k*W + b) < len) ? frame[k*W + b] : 8'h00;
        end
        beat_enable <= 1;
        beat_last   <= (k == beats-1);
        beat_count  <= (k == beats-1) ? tail[$clog2(W+1)-1:0] : W[$clog2(W+1)-1:0];
    end
    @(posedge clock);
    beat_enable <= 0;
    beat_last   <= 0;
    while (!beat_checksum_valid) @(posedge clock);
    if (beat_checksum !== expected) begin
        $display("FAIL: beat checksum mismatch len %0d tail %0d (got %08h want %08h)", len, tail, beat_checksum, expected);
        $fatal(1);
    end

    checked++;
endtask

initial begin
    #2000000;
    $display("FAIL: watchdog timeout after %0d frames", checked);
    $fatal(1);
end

initial begin
    repeat (10) @(posedge clock);
    reset_n = 1;
    repeat (5) @(posedge clock);

    //every tail residue at small and frame-like sizes
    for (int len = 1; len <= 12; len++) run_frame(len);
    run_frame(59); run_frame(60); run_frame(61); run_frame(62);
    run_frame(1517); run_frame(1518);
    for (int f = 0; f < 20; f++) run_frame($urandom_range(1, 300));

    $display("PASS: tb_fcs_generator, %0d frames checked", checked);
    $finish;
end

endmodule
