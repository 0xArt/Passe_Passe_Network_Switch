`ifndef _case_013_svh_
`define _case_013_svh_

//case 013: rgmii tri speed. rgmii port 1 renegotiates to 100 megabit: the
//phy receive clock drops to 25 MHz, the idle lines carry the in band status,
//and frames move one duplicated nibble per clock. the case checks both
//directions: a 100 megabit frame from port 1 forwards to the gigabit port 0
//wire intact, and a gigabit frame from port 0 egresses port 1 at 100
//megabit, decoded nibble by nibble against the generated 25 MHz transmit
//clock

//drive one frame into rgmii port 1 at 100 megabit: one nibble per 25 MHz
//clock, duplicated across both edges, low nibble first
task automatic drive_case_013_frame_100m(ref logic [7:0] frame [0:1525], input integer wire_bytes);
    for (int k = 0; k < wire_bytes; k = k + 1) begin
        @(posedge testbench.rgmii_clock_25);
        testbench.rgmii_data_control[1] = 1;
        testbench.rgmii_data[1]         = frame[k][3:0];
        @(posedge testbench.rgmii_clock_25);
        testbench.rgmii_data[1]         = frame[k][7:4];
    end
    @(posedge testbench.rgmii_clock_25);
    testbench.rgmii_data_control[1] = 0;
    //back to the idle in band status: link up at 100 megabit
    testbench.rgmii_data[1]         = 4'b0011;
    repeat (24) @(posedge testbench.rgmii_clock_25);
endtask

task case_013;
    automatic logic [7:0]   frame [0:1525];
    automatic logic [7:0]   crc_message [0:1521];
    automatic logic [31:0]  frame_check_sequence;
    automatic integer       i;
    automatic integer       gigabit_frame_done = 0;
    automatic integer       gigabit_frame_good = 0;
    automatic integer       fast_ethernet_frame_done = 0;
    automatic integer       fast_ethernet_frame_good = 0;
    automatic time          transmit_clock_period = 0;
    automatic time          transmit_clock_rise = 0;
    automatic time          transmit_clock_high_time = 0;
    localparam PAYLOAD_BYTES = 46;
    localparam FRAME_BYTES   = 14 + PAYLOAD_BYTES + 4;   //64 byte minimum frame
    localparam WIRE_BYTES    = 8 + FRAME_BYTES;

    $display("Running case 013");
    $display("RGMII port 1 renegotiates to 100 megabit; forwarding is checked in both directions");

    //renegotiate: drop the link, switch the receive clock to 25 MHz, then
    //advertise 100 megabit through the in band status during idle
    testbench.rgmii_data[1]                 = 4'b0000;
    testbench.rgmii_data_control[1]         = 0;
    repeat (10) @(posedge testbench.rgmii_clock);
    testbench.rgmii_1_100_megabit_mode      = 1;
    testbench.rgmii_data[1]                 = 4'b0011;
    repeat (20) @(posedge testbench.rgmii_clock_25);

    //monitor the gigabit port 0 wire for the forwarded frame
    fork : case_013_monitors
        begin
            automatic logic [7:0]   wire_bytes [0:1525];
            automatic logic [7:0]   wire_byte;
            automatic bit           wire_valid;
            automatic integer       count = 0;
            automatic integer       quiet = 0;
            automatic logic [31:0]  wire_crc;
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
                    gigabit_frame_done = 1;
                    if (count == WIRE_BYTES) begin
                        wire_crc = case_009_crc32(wire_bytes, 8, FRAME_BYTES - 4);
                        if ({wire_bytes[WIRE_BYTES-4], wire_bytes[WIRE_BYTES-3], wire_bytes[WIRE_BYTES-2], wire_bytes[WIRE_BYTES-1]} == wire_crc) begin
                            gigabit_frame_good = 1;
                        end
                        else begin
                            $display("%t : case 013 forwarded frame failed the frame check sequence", $time);
                        end
                    end
                    else begin
                        $display("%t : case 013 forwarded frame is %0d wire bytes, expected %0d", $time, count, WIRE_BYTES);
                    end
                    count = 0;
                end
            end
        end
        //monitor the port 1 transmit clock and decode the 100 megabit
        //nibble stream: one nibble per generated 25 MHz clock period
        begin
            automatic logic [7:0]   wire_bytes [0:1525];
            automatic logic [3:0]   nibble;
            automatic bit           low_half = 1;
            automatic integer       count = 0;
            automatic time          previous_edge = 0;
            automatic logic [31:0]  wire_crc;
            forever begin
                @(posedge testbench.switch_core.rgmii_phy_transmit_clock[1]);
                if (testbench.switch_core.rgmii_phy_transmit_data_control[1]) begin
                    if (previous_edge != 0 && transmit_clock_period == 0) begin
                        transmit_clock_period = $time - previous_edge;
                    end
                    nibble = testbench.switch_core.rgmii_phy_transmit_data[1];
                    if (low_half) begin
                        if (count < 1526) wire_bytes[count][3:0] = nibble;
                        low_half = 0;
                    end
                    else begin
                        if (count < 1526) wire_bytes[count][7:4] = nibble;
                        count    = count + 1;
                        low_half = 1;
                    end
                end
                else begin
                    if (count != 0) begin
                        fast_ethernet_frame_done = 1;
                        if (count == WIRE_BYTES) begin
                            wire_crc = case_009_crc32(wire_bytes, 8, FRAME_BYTES - 4);
                            if ({wire_bytes[WIRE_BYTES-4], wire_bytes[WIRE_BYTES-3], wire_bytes[WIRE_BYTES-2], wire_bytes[WIRE_BYTES-1]} == wire_crc) begin
                                fast_ethernet_frame_good = 1;
                            end
                            else begin
                                $display("%t : case 013 100 megabit frame failed the frame check sequence", $time);
                            end
                        end
                        else begin
                            $display("%t : case 013 100 megabit frame is %0d wire bytes, expected %0d", $time, count, WIRE_BYTES);
                        end
                        count    = 0;
                        low_half = 1;
                    end
                end
                previous_edge = $time;
            end
        end
    join_none

    //direction one: a 100 megabit frame from port 1 unicast to the station
    //behind gigabit port 0, sourcing a station that port 1 will learn
    frame[0] = 8'h55; frame[1] = 8'h55; frame[2] = 8'h55; frame[3] = 8'h55;
    frame[4] = 8'h55; frame[5] = 8'h55; frame[6] = 8'h55; frame[7] = 8'hD5;
    frame[8]  = 8'h0D; frame[9]  = 8'hF0; frame[10] = 8'h0D; frame[11] = 8'h00;
    frame[12] = 8'h00; frame[13] = 8'hA0;
    frame[14] = 8'h0D; frame[15] = 8'hF0; frame[16] = 8'h0D; frame[17] = 8'h00;
    frame[18] = 8'h00; frame[19] = 8'hC1;
    for (i=20; i<8+FRAME_BYTES-4; i=i+1) frame[i] = i[7:0];
    frame_check_sequence = case_009_crc32(frame, 8, FRAME_BYTES - 4);
    frame[8+FRAME_BYTES-4] = frame_check_sequence[31:24];
    frame[8+FRAME_BYTES-3] = frame_check_sequence[23:16];
    frame[8+FRAME_BYTES-2] = frame_check_sequence[15:8];
    frame[8+FRAME_BYTES-1] = frame_check_sequence[7:0];
    drive_case_013_frame_100m(frame, WIRE_BYTES);

    fork : f0
        begin
            #2ms;
            $fatal(0, "%t : case 013 timeout waiting for the forwarded gigabit frame", $time);
            disable f0;
        end
        begin
            wait (gigabit_frame_done != 0);
            disable f0;
        end
    join

    if (!gigabit_frame_good) begin
        $fatal(0, "case 013: the 100 megabit ingress frame did not arrive intact on the gigabit wire");
    end
    $display("100 megabit ingress frame forwarded intact to the gigabit port 0 wire");

    //direction two: a gigabit frame from port 0 unicast to the station just
    //learned behind the 100 megabit port 1
    frame[8]  = 8'h0D; frame[9]  = 8'hF0; frame[10] = 8'h0D; frame[11] = 8'h00;
    frame[12] = 8'h00; frame[13] = 8'hC1;
    frame[14] = 8'h0D; frame[15] = 8'hF0; frame[16] = 8'h0D; frame[17] = 8'h00;
    frame[18] = 8'h00; frame[19] = 8'hA0;
    for (i=20; i<8+FRAME_BYTES-4; i=i+1) frame[i] = ~i[7:0];
    frame_check_sequence = case_009_crc32(frame, 8, FRAME_BYTES - 4);
    frame[8+FRAME_BYTES-4] = frame_check_sequence[31:24];
    frame[8+FRAME_BYTES-3] = frame_check_sequence[23:16];
    frame[8+FRAME_BYTES-2] = frame_check_sequence[15:8];
    frame[8+FRAME_BYTES-1] = frame_check_sequence[7:0];
    drive_case_010_frame(0, frame, WIRE_BYTES);

    fork : f1
        begin
            #2ms;
            $fatal(0, "%t : case 013 timeout waiting for the 100 megabit egress frame", $time);
            disable f1;
        end
        begin
            wait (fast_ethernet_frame_done != 0);
            disable f1;
        end
    join
    disable case_013_monitors;

    if (!fast_ethernet_frame_good) begin
        $fatal(0, "case 013: the gigabit ingress frame did not egress port 1 intact at 100 megabit");
    end
    if (transmit_clock_period != 40ns) begin
        $fatal(0, "case 013: port 1 transmit clock period is %0t, expected 40ns", transmit_clock_period);
    end

    //the generated clock free runs, so its duty can be measured on any
    //clean pair of edges after the link has settled at 100 megabit
    @(posedge testbench.switch_core.rgmii_phy_transmit_clock[1]);
    transmit_clock_rise = $time;
    @(negedge testbench.switch_core.rgmii_phy_transmit_clock[1]);
    transmit_clock_high_time = $time - transmit_clock_rise;
    if (transmit_clock_high_time != 20ns) begin
        $fatal(0, "case 013: port 1 transmit clock high time is %0t, expected 20ns for a fifty percent duty", transmit_clock_high_time);
    end
    $display("Gigabit ingress frame egressed intact at 100 megabit, transmit clock at 25 MHz with fifty percent duty");

    //restore the link to gigabit for any case that follows
    testbench.rgmii_data[1]             = 4'b0101;
    repeat (20) @(posedge testbench.rgmii_clock_25);
    testbench.rgmii_1_100_megabit_mode  = 0;
    testbench.rgmii_data[1]             = 4'b0000;
    repeat (20) @(posedge testbench.rgmii_clock);

    $display("Tri speed forwarding verified in both directions on RGMII port 1");
endtask

`endif
