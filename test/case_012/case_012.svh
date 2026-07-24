//case 012: multicast flood integrity at gigabit line rate. broadcast frames
//flood to every egress port including the byte serial virtual port. the
//fabric must keep streaming at full beat rate regardless of how slowly the
//virtual port drains, so every flooded copy on the gigabit wire has to
//arrive complete and crc clean. a virtual port that paces the fabric
//handshake instead of buffering shows up here as truncated wire frames
task case_012;
    automatic logic [7:0]   frame [0:1525];
    automatic logic [7:0]   crc_message [0:1521];
    automatic logic [31:0]  frame_check_sequence;
    automatic integer       i;
    automatic integer       f;
    automatic integer       wire_frames_received = 0;
    automatic integer       bad_frames = 0;
    localparam FRAME_COUNT = 20;

    $display("Running case 012");
    $display("Flooding %0d broadcast mtu frames at line rate: RGMII port 1 -> all ports", FRAME_COUNT);

    //wire monitor on rgmii port 0: sample the shipper byte stream just
    //before the ddr buffers and check the length and frame check sequence
    //of every flooded copy. a stalled fabric stream makes the shipper run
    //dry mid frame and abandon it, which lands here as a short frame
    fork : case_012_monitors
        begin
            automatic logic [7:0]   wire_bytes [0:1525];
            automatic logic [7:0]   wire_byte;
            automatic bit           wire_valid;
            automatic integer       count = 0;
            automatic integer       quiet = 0;
            automatic logic [31:0]  wire_crc;
            //the previous case can return while its final frame is still
            //going out on the wire, so wait for the line to sit idle
            //before arming. otherwise the tail of that frame is counted
            //as a truncated flood copy
            while (quiet < 64) begin
                @(negedge testbench.rgmii_clock);
                if (testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper.frame_data_valid) begin
                    quiet = 0;
                end
                else begin
                    quiet = quiet + 1;
                end
            end
            forever begin
                @(negedge testbench.rgmii_clock);
                wire_valid  = testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper.frame_data_valid;
                wire_byte   = testbench.switch_core.genblk3[0].rgmii_port.rgmii_byte_shipper.frame_data;
                if (wire_valid) begin
                    if (count < 1526) begin
                        wire_bytes[count] = wire_byte;
                    end
                    count = count + 1;
                end
                else if (count != 0) begin
                    //frame ended. preamble plus an mtu frame is 1526 bytes
                    if (count != 1526) begin
                        bad_frames = bad_frames + 1;
                        $display("%t : case 012 flooded copy truncated: %0d of 1526 bytes on the wire",
                                 $time, count);
                    end
                    else begin
                        wire_crc = case_009_crc32(wire_bytes, 8, 1514);
                        if ({wire_bytes[1522], wire_bytes[1523], wire_bytes[1524], wire_bytes[1525]} != wire_crc) begin
                            bad_frames = bad_frames + 1;
                            $display("%t : case 012 flooded copy failed the frame check sequence", $time);
                        end
                    end
                    wire_frames_received = wire_frames_received + 1;
                    count = 0;
                end
            end
        end
    join_none

    //build a broadcast mtu frame: flood on the cam miss reaches every port
    frame[0] = 8'h55; frame[1] = 8'h55; frame[2] = 8'h55; frame[3] = 8'h55;
    frame[4] = 8'h55; frame[5] = 8'h55; frame[6] = 8'h55; frame[7] = 8'hD5;
    for (i=8;  i<14; i=i+1) frame[i] = 8'hFF;
    frame[14] = 8'h0D; frame[15] = 8'hF0; frame[16] = 8'h0D; frame[17] = 8'h00;
    frame[18] = 8'h00; frame[19] = 8'hB1;

    for (f=0; f<FRAME_COUNT; f=f+1) begin
        for (i=20; i<1522; i=i+1) frame[i] = i[7:0] ^ f[7:0];
        for (i=0;  i<1522; i=i+1) crc_message[i] = frame[i];
        frame_check_sequence = case_009_crc32(frame, 8, 1514);
        frame[1522] = frame_check_sequence[31:24];
        frame[1523] = frame_check_sequence[23:16];
        frame[1524] = frame_check_sequence[15:8];
        frame[1525] = frame_check_sequence[7:0];
        drive_case_010_frame(1, frame, 1526);
    end

    fork : case_012_wait
        begin
            #5ms;
            $fatal(0, "%t : case 012 timeout, %0d / %0d flooded copies on the rgmii 0 wire (%0d bad)",
                   $time, wire_frames_received, FRAME_COUNT, bad_frames);
            disable case_012_wait;
        end
        begin
            wait (wire_frames_received >= FRAME_COUNT);
            disable case_012_wait;
        end
    join
    disable case_012_monitors;

    if (bad_frames != 0) begin
        $fatal(0, "case 012 flood corrupted %0d of %0d gigabit copies", bad_frames, FRAME_COUNT);
    end

    $display("Flood sustained: %0d/%0d broadcast mtu frames delivered intact on the gigabit wire with the virtual port in the flood set",
             wire_frames_received, FRAME_COUNT);
endtask
