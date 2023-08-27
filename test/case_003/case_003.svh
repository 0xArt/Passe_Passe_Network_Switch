`ifndef _case_003_svh_
`define _case_003_svh_

task case_003();

automatic integer   i = 0;
automatic integer   j = 0;

$display("Running case 003");

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

for (i=0;i<42;i=i+1) begin
    @(posedge testbench.module_clock);
    testbench.module_transmit_data_valid       =   1;
    testbench.module_transmit_data             =   testbench.module_transmit_buffer[i];
end
@(posedge testbench.module_clock);
testbench.module_transmit_data_valid       =   0;
testbench.module_transmit_data             =   0;

#100;


endtask: case_003

`endif