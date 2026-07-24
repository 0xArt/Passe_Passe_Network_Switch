`ifndef _case_003_svh_
`define _case_003_svh_

task case_003();

automatic integer           i = 0;
automatic integer           j = 0;
automatic logic     [7:0]   egress_frame [0:127];
automatic integer           egress_count = 0;
automatic logic     [16:0]  sum = 0;
automatic integer           udp_length = 0;

$display("Running case 003");
$display("Transmitting a via the virtual port with a MAC destination of RMII port 0");

/*
1. MAC  Destination
2. IPV4 Destination
3. UDP  Payload Size
4. UDP  Source
5. UDP  Destination
6. UDP  Data
*/

testbench.module_transmit_buffer[0]   = 9'h1F6; // mac destination
testbench.module_transmit_buffer[1]   = 9'h90;
testbench.module_transmit_buffer[2]   = 9'h2A;
testbench.module_transmit_buffer[3]   = 9'h94;
testbench.module_transmit_buffer[4]   = 9'h2D;
testbench.module_transmit_buffer[5]   = 9'h5E;
testbench.module_transmit_buffer[6]   = 9'hF0; // ipv4 destination
testbench.module_transmit_buffer[7]   = 9'hF1;
testbench.module_transmit_buffer[8]   = 9'hF2;
testbench.module_transmit_buffer[9]   = 9'hF3;
testbench.module_transmit_buffer[10]  = 9'h00; // udp payload size
testbench.module_transmit_buffer[11]  = 9'h1A;
testbench.module_transmit_buffer[12]  = 9'h44; // udp source
testbench.module_transmit_buffer[13]  = 9'h44;
testbench.module_transmit_buffer[14]  = 9'h22; // udp destination
testbench.module_transmit_buffer[15]  = 9'h22;
testbench.module_transmit_buffer[16]  = 9'h01; // udp payload
testbench.module_transmit_buffer[17]  = 9'h02;
testbench.module_transmit_buffer[18]  = 9'h03;
testbench.module_transmit_buffer[19]  = 9'h04;
testbench.module_transmit_buffer[20]  = 9'h05;
testbench.module_transmit_buffer[21]  = 9'h06;
testbench.module_transmit_buffer[22]  = 9'h07;
testbench.module_transmit_buffer[23]  = 9'h08;
testbench.module_transmit_buffer[24]  = 9'h09;
testbench.module_transmit_buffer[25]  = 9'h0A;
testbench.module_transmit_buffer[26]  = 9'h0B;
testbench.module_transmit_buffer[27]  = 9'h0C;
testbench.module_transmit_buffer[28]  = 9'h0D;
testbench.module_transmit_buffer[29]  = 9'h0E;
testbench.module_transmit_buffer[30]  = 9'h0F;
testbench.module_transmit_buffer[31]  = 9'h10;
testbench.module_transmit_buffer[32]  = 9'h11;
testbench.module_transmit_buffer[33]  = 9'h12;
testbench.module_transmit_buffer[34]  = 9'h13;
testbench.module_transmit_buffer[35]  = 9'h14;
testbench.module_transmit_buffer[36]  = 9'h15;
testbench.module_transmit_buffer[37]  = 9'h16;
testbench.module_transmit_buffer[38]  = 9'h17;
testbench.module_transmit_buffer[39]  = 9'h18;
testbench.module_transmit_buffer[40]  = 9'h19;
testbench.module_transmit_buffer[41]  = 9'h1A;

//capture every byte RMII port 0 hands to its byte shipper (the egress wire
//content, framing byte [8] marks start of frame) so the generated frame can
//be validated field by field below
fork : egress_capture
    forever begin
        @(posedge testbench.rmii_clock);
        if (testbench.switch_core.genblk1[0].rmii_port.rmii_byte_shipper_data_ready &&
            testbench.switch_core.genblk1[0].rmii_port.rmii_byte_shipper_data_enable) begin
            if (egress_count != 0 ||
                testbench.switch_core.genblk1[0].rmii_port.rmii_byte_shipper_data[8]) begin
                egress_frame[egress_count] = testbench.switch_core.genblk1[0].rmii_port.rmii_byte_shipper_data[7:0];
                egress_count               = egress_count + 1;
            end
        end
    end
join_none

for (i=0;i<42;i=i+1) begin
    @(posedge testbench.module_clock);
    testbench.module_transmit_data_valid       = 1;
    testbench.module_transmit_data             = testbench.module_transmit_buffer[i];
end
@(posedge testbench.module_clock);
testbench.module_transmit_data_valid       = 0;
testbench.module_transmit_data             = 0;

fork : f0
    begin
        #1ms;
        $fatal(0, "%t : timeout while waiting for RMII port 0 to start trasmitting", $time);
        disable f0;
    end
    begin
        wait (testbench.switch_core.genblk1[0].rmii_port.rmii_transmit_data_valid == 1);
        $display("Switch routed packet correctly to RMII port 0");
        disable f0;
    end
join

//wait for the full frame on the egress: 14 ethernet + 20 ipv4 + 8 udp +
//26 payload + 4 crc = 72 bytes
fork : f1
    begin
        #1ms;
        $fatal(0, "%t : timeout while waiting for the full egress frame capture", $time);
        disable f1;
    end
    begin
        wait (egress_count >= 72);
        disable f1;
    end
join
disable egress_capture;

//validate the udp payload byte for byte (offset 42 = 14 ethernet + 20 ipv4 + 8 udp)
for (i=0;i<26;i=i+1) begin
    if (egress_frame[42+i] !== (i+1)) begin
        $fatal(0, "udp payload byte %0d is %02x, expected %02x", i, egress_frame[42+i], i+1);
    end
end
$display("UDP payload delivered intact on the RMII port 0 wire");

//validate the ipv4 header checksum the way a receiver does: the ones
//complement sum of the header including the checksum field folds to FFFF
sum = 0;
for (i=14;i<34;i=i+2) begin
    sum = sum[15:0] + sum[16] + {egress_frame[i], egress_frame[i+1]};
end
sum = sum[15:0] + sum[16];
if (sum[15:0] !== 16'hFFFF) begin
    $fatal(0, "ipv4 header checksum invalid, folded sum %04x", sum[15:0]);
end
$display("IPv4 header checksum valid");

//validate the udp checksum the way a receiver does: pseudo header + udp
//header (including the checksum field) + payload folds to FFFF
if ({egress_frame[40], egress_frame[41]} === 16'h0000) begin
    $fatal(0, "udp checksum field is zero (checksum disabled), expected a computed checksum");
end
udp_length = {egress_frame[38], egress_frame[39]};
sum        = 0;
for (i=26;i<34;i=i+2) begin //pseudo header: source and destination ip
    sum = sum[15:0] + sum[16] + {egress_frame[i], egress_frame[i+1]};
end
sum = sum[15:0] + sum[16] + {8'h00, egress_frame[23]};  //zero + protocol
sum = sum[15:0] + sum[16] + udp_length[15:0];           //pseudo header udp length
for (i=34;i<34+udp_length;i=i+2) begin                  //udp header + payload
    sum = sum[15:0] + sum[16] + {egress_frame[i], (i+1 < 34+udp_length) ? egress_frame[i+1] : 8'h00};
end
sum = sum[15:0] + sum[16];
if (sum[15:0] !== 16'hFFFF) begin
    $fatal(0, "udp checksum invalid, folded sum %04x (field %02x%02x)",
        sum[15:0], egress_frame[40], egress_frame[41]);
end
$display("UDP checksum valid");

endtask: case_003

`endif