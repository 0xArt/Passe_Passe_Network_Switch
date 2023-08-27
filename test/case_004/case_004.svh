`ifndef _case_004_svh_
`define _case_004_svh_

task case_004();

automatic integer   i = 0;
automatic integer   j = 0;

$display("Running case 004");

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
testbench.module_transmit_buffer[10]  = 9'h10; // udp payload size
testbench.module_transmit_buffer[11]  = 9'h00;
testbench.module_transmit_buffer[12]  = 9'h44; // udp source
testbench.module_transmit_buffer[13]  = 9'h44;
testbench.module_transmit_buffer[14]  = 9'h22; // udp destination
testbench.module_transmit_buffer[15]  = 9'h22;
for (i=0; i< 4096; i=i+1) begin
    testbench.module_transmit_buffer[16 + i]  = i[7:0];
end

for (i=0;i<(16+4096);i=i+1) begin
    @(posedge testbench.module_clock);
    testbench.module_transmit_data_valid       =   1;
    testbench.module_transmit_data             =   testbench.module_transmit_buffer[i];
end
@(posedge testbench.module_clock);
testbench.module_transmit_data_valid       =   0;
testbench.module_transmit_data             =   0;

#100;


endtask: case_004

`endif