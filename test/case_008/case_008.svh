`ifndef _case_008_svh_
`define _case_008_svh_

//system test: two frames enter the switch simultaneously on
//different ingress ports bound for different egress ports. stream a repeats
//case 007 (rgmii port 0 -> rmii port 0). stream b sends a udp frame from
//rmii port 1 to the virtual port with a unique source mac. both cam lookups
//land in the same window and both frames must be delivered
task case_008();

automatic integer       i                       = 0;
automatic logic [7:0]   frame_rgmii  [0:71];
automatic logic [7:0]   frame_rmii1  [0:71];
automatic logic [7:0]   crc_message  [0:888];
automatic logic [31:0]  frame_check_sequence    = 0;
automatic time          rgmii_stream_delivered  = 0;
automatic time          rmii1_stream_delivered  = 0;

$display("Running case 008");
$display("Transmitting simultaneously: RGMII port 0 -> RMII port 0 and RMII port 1 -> virtual port");

//stream a: byte for byte the case 007 frame (destination learned at rmii
//port 0, static crc)
frame_rgmii[0]  = 8'h55; frame_rgmii[1]  = 8'h55; frame_rgmii[2]  = 8'h55; frame_rgmii[3]  = 8'h55;
frame_rgmii[4]  = 8'h55; frame_rgmii[5]  = 8'h55; frame_rgmii[6]  = 8'h55; frame_rgmii[7]  = 8'hD5;
//mac destination
frame_rgmii[8]  = 8'hF6; frame_rgmii[9]  = 8'h90; frame_rgmii[10] = 8'h2A; frame_rgmii[11] = 8'h94;
frame_rgmii[12] = 8'h2D; frame_rgmii[13] = 8'h5E;
//mac source
frame_rgmii[14] = 8'hB8; frame_rgmii[15] = 8'h27; frame_rgmii[16] = 8'hEB; frame_rgmii[17] = 8'hBA;
frame_rgmii[18] = 8'h99; frame_rgmii[19] = 8'hD6;
//type + ipv4 header
frame_rgmii[20] = 8'h08; frame_rgmii[21] = 8'h00; frame_rgmii[22] = 8'h45; frame_rgmii[23] = 8'h00;
frame_rgmii[24] = 8'h00; frame_rgmii[25] = 8'h2A; frame_rgmii[26] = 8'h83; frame_rgmii[27] = 8'h4F;
frame_rgmii[28] = 8'h40; frame_rgmii[29] = 8'h00; frame_rgmii[30] = 8'h40; frame_rgmii[31] = 8'h11;
frame_rgmii[32] = 8'h66; frame_rgmii[33] = 8'h76;
frame_rgmii[34] = 8'hAC; frame_rgmii[35] = 8'h10; frame_rgmii[36] = 8'h7C; frame_rgmii[37] = 8'h6B;
frame_rgmii[38] = 8'hAC; frame_rgmii[39] = 8'h10; frame_rgmii[40] = 8'h7C; frame_rgmii[41] = 8'h71;
//udp header + payload + pad
frame_rgmii[42] = 8'h44; frame_rgmii[43] = 8'h44; frame_rgmii[44] = 8'h44; frame_rgmii[45] = 8'h44;
frame_rgmii[46] = 8'h00; frame_rgmii[47] = 8'h16; frame_rgmii[48] = 8'h4E; frame_rgmii[49] = 8'h59;
frame_rgmii[50] = 8'hAB; frame_rgmii[51] = 8'hCD; frame_rgmii[52] = 8'h61; frame_rgmii[53] = 8'h97;
frame_rgmii[54] = 8'hE1; frame_rgmii[55] = 8'hC2; frame_rgmii[56] = 8'h04; frame_rgmii[57] = 8'hA6;
frame_rgmii[58] = 8'hE3; frame_rgmii[59] = 8'h12; frame_rgmii[60] = 8'h01; frame_rgmii[61] = 8'h00;
frame_rgmii[62] = 8'h00; frame_rgmii[63] = 8'h02;
frame_rgmii[64] = 8'h00; frame_rgmii[65] = 8'h00; frame_rgmii[66] = 8'h00; frame_rgmii[67] = 8'h00;
//crc32 (unchanged from case 007)
frame_rgmii[68] = 8'h2F; frame_rgmii[69] = 8'hB0; frame_rgmii[70] = 8'hDF; frame_rgmii[71] = 8'hC5;

//stream b: the case 005 udp frame (destination = virtual port mac) with a
//unique source mac so no learned station moves ports during this test
for (i=0; i<72; i=i+1) begin
    frame_rmii1[i] = frame_rgmii[i];
end
//mac destination: virtual port
frame_rmii1[8]  = 8'hBE; frame_rmii1[9]  = 8'hAC; frame_rmii1[10] = 8'hDC; frame_rmii1[11] = 8'hEF;
frame_rmii1[12] = 8'hF0; frame_rmii1[13] = 8'h00;
//mac source: unique station behind rmii port 1
frame_rmii1[14] = 8'hCA; frame_rmii1[15] = 8'hFE; frame_rmii1[16] = 8'h00; frame_rmii1[17] = 8'h00;
frame_rmii1[18] = 8'h00; frame_rmii1[19] = 8'h08;
//recompute the frame check sequence for the modified macs
for (i=0; i<72; i=i+1) begin
    crc_message[i] = frame_rmii1[i];
end
frame_check_sequence = testbench.calc_crc(crc_message, 68);
frame_rmii1[68] = frame_check_sequence[31:24];
frame_rmii1[69] = frame_check_sequence[23:16];
frame_rmii1[70] = frame_check_sequence[15:8];
frame_rmii1[71] = frame_check_sequence[7:0];

//let rmii port 0 finish draining the case 007 frame so stream a's arrival
//can be detected cleanly
begin
    automatic integer idle_count = 0;
    while (idle_count < 200) begin
        @(posedge testbench.rmii_clock);
        if (testbench.switch_core.genblk1[0].rmii_port.rmii_transmit_data_valid == 0) begin
            idle_count = idle_count + 1;
        end
        else begin
            idle_count = 0;
        end
    end
end

//drive both ingress ports at the same time
fork
    begin
        for (i=0; i<72; i=i+1) begin
            @(posedge testbench.rgmii_clock);
            testbench.rgmii_data_control    = 1;
            testbench.rgmii_data            = frame_rgmii[i][3:0];
            @(negedge testbench.rgmii_clock);
            testbench.rgmii_data            = frame_rgmii[i][7:4];
        end
        @(posedge testbench.rgmii_clock);
        testbench.rgmii_data_control        = 0;
        testbench.rgmii_data                = 0;
    end
    begin
        automatic integer k;
        for (k=0; k<72; k=k+1) begin
            @(posedge testbench.rmii_clock);
            testbench.ethernet_transmit_data_valid[1]   = 1;
            testbench.ethernet_transmit_data[1]         = frame_rmii1[k][1:0];
            @(posedge testbench.rmii_clock);
            testbench.ethernet_transmit_data[1]         = frame_rmii1[k][3:2];
            @(posedge testbench.rmii_clock);
            testbench.ethernet_transmit_data[1]         = frame_rmii1[k][5:4];
            @(posedge testbench.rmii_clock);
            testbench.ethernet_transmit_data[1]         = frame_rmii1[k][7:6];
        end
        @(posedge testbench.rmii_clock);
        testbench.ethernet_transmit_data[1]         = 0;
        testbench.ethernet_transmit_data_valid[1]   = 0;
    end
join

//both frames must be delivered
fork : f0
    begin
        #1ms;
        $fatal(0, "%t : timeout while waiting for both concurrent streams to deliver", $time);
        disable f0;
    end
    begin
        fork
            begin
                wait (testbench.switch_core.genblk1[0].rmii_port.rmii_transmit_data_valid == 1);
                rgmii_stream_delivered = $time;
                $display("Concurrent stream RGMII -> RMII port 0 delivered");
            end
            begin
                wait (testbench.switch_core.genblk2[0].virtual_port_udp.module_receive_data_valid == 1);
                rmii1_stream_delivered = $time;
                $display("Concurrent stream RMII port 1 -> virtual port delivered");
            end
        join
        $display("Both concurrent streams delivered (rgmii->rmii0 at %0t, rmii1->virtual at %0t)", rgmii_stream_delivered, rmii1_stream_delivered);
        disable f0;
    end
join

endtask: case_008

`endif
