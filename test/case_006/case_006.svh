`ifndef _case_006_svh_
`define _case_006_svh_

task case_006();


automatic integer       i                       = 0;
automatic integer       j                       = 0;
automatic integer       k                       = 0;
automatic logic [15:0]  packet_id               = 16'h8888;
automatic logic [15:0]  udp_data_size           = 2000;
automatic logic [15:0]  udp_source              = 16'h2222;
automatic logic [15:0]  udp_destination         = 16'h4444;
automatic logic [15:0]  fragment_size           = 16'd512;
automatic logic [15:0]  udp_total_size          = udp_data_size + 8;
automatic logic [15:0]  udp_checksum            = 0;
automatic logic [15:0]  ipv4_checksum           = 0;
automatic logic [15:0]  this_fragment_size      = 0;
automatic logic [15:0]  ipv4_length             = 0;
automatic logic [15:0]  ethernet_frame_size     = 0;
automatic logic [31:0]  frame_check_sequence    = 0;
automatic logic [15:0]  ipv4_flags              = 0;

$display("Running case 006");


testbench.ethernet_message[0]   = 8'h55;
testbench.ethernet_message[1]   = 8'h55;
testbench.ethernet_message[2]   = 8'h55;
testbench.ethernet_message[3]   = 8'h55;
testbench.ethernet_message[4]   = 8'h55;
testbench.ethernet_message[5]   = 8'h55;
testbench.ethernet_message[6]   = 8'h55;

testbench.ethernet_message[7]   = 8'hD5;

testbench.ethernet_message[8]   = 8'hBE;
testbench.ethernet_message[9]   = 8'hAC;
testbench.ethernet_message[10]  = 8'hDC;
testbench.ethernet_message[11]  = 8'hEF;
testbench.ethernet_message[12]  = 8'hF0;
testbench.ethernet_message[13]  = 8'h00;

testbench.ethernet_message[14]  = 8'hB8;
testbench.ethernet_message[15]  = 8'h27;
testbench.ethernet_message[16]  = 8'hEB;
testbench.ethernet_message[17]  = 8'hBA;
testbench.ethernet_message[18]  = 8'h99;
testbench.ethernet_message[19]  = 8'hD6;
//type
testbench.ethernet_message[20]  = 8'h08;
testbench.ethernet_message[21]  = 8'h00;
//ipv4 version header len
testbench.ethernet_message[22]  = 8'h45;
//ipv4 tos
testbench.ethernet_message[23]  = 8'h00;
//ipv4 total length
testbench.ethernet_message[24]  = 8'h00;
testbench.ethernet_message[25]  = 8'h2A; //42
//ipv4 id
testbench.ethernet_message[26]  = packet_id[15:8];
testbench.ethernet_message[27]  = packet_id[7:0];
//ipv4 flags
testbench.ethernet_message[28]  = 8'h40;
testbench.ethernet_message[29]  = 8'h00;
//ipv4 ttl
testbench.ethernet_message[30]  = 8'h40;
//ipv4 protocol
testbench.ethernet_message[31]  = 8'h11;
//ipv4 header checksum
testbench.ethernet_message[32]  = 8'h66;
testbench.ethernet_message[33]  = 8'h76;
//ipv4 source ip
testbench.ethernet_message[34]  = 8'hAC;
testbench.ethernet_message[35]  = 8'h10;
testbench.ethernet_message[36]  = 8'h7C;
testbench.ethernet_message[37]  = 8'h6B;
//ipv4 destination ip
testbench.ethernet_message[38]  = 8'hAC;
testbench.ethernet_message[39]  = 8'h10;
testbench.ethernet_message[40]  = 8'h7C;
testbench.ethernet_message[41]  = 8'h71;

//ones compliment addition
//~((1 + 2) - 1)

testbench.udp_data[0] = udp_source[15:8];
testbench.udp_data[1] = udp_source[7:0];
testbench.udp_data[2] = udp_destination[15:8];
testbench.udp_data[3] = udp_destination[7:0];
testbench.udp_data[4] = udp_total_size[15:8];
testbench.udp_data[5] = udp_total_size[7:0];
testbench.udp_data[6] = 0;
testbench.udp_data[7] = 0;

for (i=0; i<udp_data_size; i=i+1) begin
    testbench.udp_data[8+i] =  $urandom();
end

for (i=0; i<udp_total_size; i=i+2) begin
    if (i != 6) begin
        udp_checksum = ~((udp_checksum + {testbench.udp_data[i],testbench.udp_data[i+1]}) - 1);
    end
end

if (udp_total_size %2 !=0) begin
    udp_checksum = ~( (udp_checksum + {testbench.udp_data[udp_total_size-1],8'h00}) - 1);
end

testbench.udp_data[6] = udp_checksum[15:8];
testbench.udp_data[7] = udp_checksum[7:0];

for (i=0; i<udp_total_size; i=i+fragment_size) begin
    ipv4_checksum = 0;

    if ( (udp_total_size-i) < fragment_size) begin
        this_fragment_size = (udp_total_size-i);
    end
    else begin
        this_fragment_size = fragment_size;
    end

    for (j = 0; j < this_fragment_size; j=j+1) begin
        testbench.ethernet_message[42+j] = testbench.udp_data[i+j];
    end

    ipv4_flags[12:0] = i;

    if (i+fragment_size >= udp_total_size) begin
        ipv4_flags[15:13] = 3'b000;
    end
    else begin
        ipv4_flags[15:13] = 3'b001;
    end

    testbench.ethernet_message[28]  = ipv4_flags[15:8];
    testbench.ethernet_message[29]  = ipv4_flags[7:0];

    ipv4_length                     = this_fragment_size + 20;
    testbench.ethernet_message[24]  = ipv4_length[15:8];
    testbench.ethernet_message[25]  = ipv4_length[7:0];

    for (j = 22; j<42; j = j+2) begin
        if (j != 32) begin
            ipv4_checksum = ~((ipv4_checksum + {testbench.ethernet_message[j],testbench.ethernet_message[j+1]}) - 1);
        end
    end

    testbench.ethernet_message[32]  = ipv4_checksum[15:8];
    testbench.ethernet_message[33]  = ipv4_checksum[7:0];

    //802.3 header + ip header + ip payload + FCS
    ethernet_frame_size                                 = 42 + this_fragment_size;
    frame_check_sequence                                = testbench.calc_crc(testbench.ethernet_message, ethernet_frame_size);
    testbench.ethernet_message[ethernet_frame_size]     = frame_check_sequence[31:24];
    testbench.ethernet_message[ethernet_frame_size+1]   = frame_check_sequence[23:16];
    testbench.ethernet_message[ethernet_frame_size+2]   = frame_check_sequence[15:8];
    testbench.ethernet_message[ethernet_frame_size+3]   = frame_check_sequence[7:0];
    ethernet_frame_size                                 = ethernet_frame_size + 4;

    for (k=0; k<ethernet_frame_size; k=k+1) begin
        @(posedge testbench.clock);
        testbench.ethernet_transmit_data_valid[0]       =   1;
        testbench.ethernet_transmit_data[0]             =   testbench.ethernet_message[k][1:0];
        @(posedge testbench.clock);
        testbench.ethernet_transmit_data[0]             =   testbench.ethernet_message[k][3:2];
        @(posedge testbench.clock);
        testbench.ethernet_transmit_data[0]             =   testbench.ethernet_message[k][5:4];
        @(posedge testbench.clock);
        testbench.ethernet_transmit_data[0]             =   testbench.ethernet_message[k][7:6];
    end
    @(posedge testbench.clock);
    testbench.ethernet_transmit_data[0]          =   0;
    testbench.ethernet_transmit_data_valid[0]    =   0;

    repeat(40) begin
        @(posedge testbench.clock);
    end
end


#100;


endtask: case_006

`endif