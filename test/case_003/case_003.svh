`ifndef _case_003_svh_
`define _case_003_svh_

task case_003();

automatic integer   i = 0;
automatic integer   j = 0;

/*
1. MAC  Destination
2. IPV4 Destination
3. UDP  Payload Size
4. UDP  Source
5. UDP  Destination
6. UDP  Data
*/

testbench.module_transmit_buffer[0]   = 9'h111; // mac destination
testbench.module_transmit_buffer[1]   = 9'h22;
testbench.module_transmit_buffer[2]   = 9'h33;
testbench.module_transmit_buffer[3]   = 9'h44;
testbench.module_transmit_buffer[4]   = 9'h55;
testbench.module_transmit_buffer[5]   = 9'h66;
testbench.module_transmit_buffer[6]   = 9'hF0; // ipv4 destination
testbench.module_transmit_buffer[7]   = 9'hF1;
testbench.module_transmit_buffer[8]   = 9'hF2;
testbench.module_transmit_buffer[9]   = 9'hF4;
testbench.module_transmit_buffer[10]  = 9'h00; // udp payload size
testbench.module_transmit_buffer[11]  = 9'h04;
testbench.module_transmit_buffer[12]  = 9'h44; // udp source
testbench.module_transmit_buffer[13]  = 9'h44;
testbench.module_transmit_buffer[14]  = 9'h22; // udp destination
testbench.module_transmit_buffer[15]  = 9'h22;
testbench.module_transmit_buffer[16]  = 9'hA0; // udp payload
testbench.module_transmit_buffer[17]  = 9'hA1;
testbench.module_transmit_buffer[18]  = 9'hA2;
testbench.module_transmit_buffer[19]  = 9'hA3;

for (i=0;i<20;i=i+1) begin
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