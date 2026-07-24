`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_gap_shrink
// Description: proves the watermark gated gap shrink lets the rgmii egress
//              drain a saturating stream through a transmit clock that runs
//              slower than the sender. the read clock is 1 percent slow, an
//              enormously exaggerated oscillator mismatch, so the backlog
//              that a real 100 ppm part would build over seconds appears in
//              a couple of milliseconds. without the shrink the fifo fills
//              and drops writes; with it the fill stabilizes at the
//              watermark and every frame ships
//////////////////////////////////////////////////////////////////////////////////
module tb_gap_shrink;

localparam FRAMES       = 4000;
localparam FRAME_BYTES  = 64;
//the writer models the sender wire pacing. only frame bytes enter the
//fifo but the wire also spends eight byte times on preamble plus the
//twelve byte time minimum gap, so the writer idles twenty cycles
localparam GAP_BYTES    = 20;
localparam FIFO_DEPTH   = 512;
localparam WATERMARK    = 128;

//sender wire clock: exact gigabit byte time
logic write_clock = 0;
always #4ns write_clock = ~write_clock;

//transmit wire clock: 1 percent slow
logic read_clock = 0;
always #4.04ns read_clock = ~read_clock;

logic reset_n = 0;

logic   [8:0]   write_data      = '0;
logic           write_enable    = 0;

wire    [8:0]   fifo_read_data;
wire            fifo_read_data_valid;
wire            fifo_full;
wire            fifo_almost_full;
wire            fifo_programmable_full;
wire            fifo_empty;
wire            fifo_programmable_empty;

wire            shipper_data_ready;
wire    [3:0]   shipper_shipped_data;
wire            shipper_shipped_data_valid;

generic_asynchronous_fifo #(
    .DATA_WIDTH                     (9),
    .DATA_DEPTH                     (FIFO_DEPTH),
    .FIRST_WORD_FALL_THROUGH        (1),
    .PROGRAMMABLE_FULL_THRESHOLD    (FIFO_DEPTH - 8),
    .PROGRAMMABLE_EMPTY_THRESHOLD   (WATERMARK)
) fifo (
    .read_clock         (read_clock),
    .read_reset_n       (reset_n),
    .write_clock        (write_clock),
    .write_reset_n      (reset_n),
    .read_enable        (shipper_data_ready),
    .write_enable       (write_enable),
    .write_data         (write_data),

    .read_data          (fifo_read_data),
    .read_data_valid    (fifo_read_data_valid),
    .full               (fifo_full),
    .almost_full        (fifo_almost_full),
    .programmable_full  (fifo_programmable_full),
    .empty              (fifo_empty),
    .programmable_empty (fifo_programmable_empty)
);

rgmii_byte_shipper #(
    .TECHNOLOGY             ("SIMULATION"),
    .INTER_PACKET_GAP_CYCLES(10)
) shipper (
    .clock              (read_clock),
    .reset_n            (reset_n),
    .data               (fifo_read_data),
    .data_enable        (fifo_read_data_valid),
    .gap_shrink_enable  (!fifo_programmable_empty),
    .speed_code         (2'd2),

    .data_ready             (shipper_data_ready),
    .shipped_data           (shipper_shipped_data),
    .shipped_data_valid     (shipper_shipped_data_valid),
    .shipped_clock_pattern  ()
);

integer dropped_writes  = 0;
integer shipped_frames  = 0;
integer shrunk_gaps     = 0;
integer minimum_gap     = 9999;
integer gap;
time    gap_start;

//count writes the full fifo would swallow
always @(posedge write_clock) begin
    if (write_enable && fifo_full) begin
        dropped_writes = dropped_writes + 1;
    end
end

//frame counter and gap monitor on the shipped wire
initial begin
    forever begin
        @(negedge shipper_shipped_data_valid);
        if ($time > 0) begin
            shipped_frames = shipped_frames + 1;
            gap_start      = $time;
            @(posedge shipper_shipped_data_valid);
            gap = ($time - gap_start) / 8.08ns;
            if (gap < minimum_gap)  minimum_gap = gap;
            if (gap == 11)          shrunk_gaps = shrunk_gaps + 1;
        end
    end
end

initial begin
    repeat (4) @(posedge write_clock);
    reset_n = 1;
    repeat (4) @(posedge write_clock);

    for (int f = 0; f < FRAMES; f = f + 1) begin
        for (int b = 0; b < FRAME_BYTES; b = b + 1) begin
            @(posedge write_clock);
            write_data      = {(b == 0), b[7:0] ^ f[7:0]};
            write_enable    = 1;
        end
        @(posedge write_clock);
        write_enable = 0;
        repeat (GAP_BYTES - 1) @(posedge write_clock);
    end

    //let the slow side drain the tail
    wait (fifo_empty);
    repeat (200) @(posedge read_clock);

    if (dropped_writes != 0) begin
        $fatal(0, "FAIL: %0d writes dropped by a full egress fifo", dropped_writes);
    end
    if (shipped_frames < FRAMES) begin
        $fatal(0, "FAIL: only %0d of %0d frames shipped", shipped_frames, FRAMES);
    end
    if (shrunk_gaps == 0) begin
        $fatal(0, "FAIL: the gap shrink never engaged against a 1 percent slow transmit clock");
    end
    if (minimum_gap < 11) begin
        $fatal(0, "FAIL: wire gap of %0d byte times, shrink floor is 11", minimum_gap);
    end
    $display("PASS: tb_gap_shrink, %0d frames through a 1 percent slow transmit clock, 0 drops, %0d of %0d gaps shrunk to 11 byte times, minimum gap %0d",
             shipped_frames, shrunk_gaps, shipped_frames, minimum_gap);
    $finish;
end

//backstop
initial begin
    #20ms;
    $fatal(0, "FAIL: tb_gap_shrink timeout");
end

endmodule
