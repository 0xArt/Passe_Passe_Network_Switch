`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: testbench
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "./case_000/case_000.svh"
`include "./case_002/case_002.svh"
`include "./case_003/case_003.svh"
`include "./case_004/case_004.svh"
`include "./case_005/case_005.svh"
`include "./case_006/case_006.svh"

module testbench;

localparam  CLOCK_FREQUENCY             =   100_000_000;
localparam  CLOCK_PERIOD                =   1e9/CLOCK_FREQUENCY;
localparam  MODULE_CLOCK_FREQUENCY      =   50_000_000;
localparam  MODULE_CLOCK_PERIOD         =   1e9/MODULE_CLOCK_FREQUENCY;

localparam  NUMBER_OF_RMII_PORTS        =   2;
localparam  NUMBER_OF_VIRTUAL_PORTS     =   1;
localparam  RECEIVE_QUE_SLOTS           =   4;

logic                                           clock                           =   0;
logic                                           reset_n                         =   1;
logic [7:0]                                     ethernet_message [0:888];
logic [NUMBER_OF_RMII_PORTS-1:0][1:0]           ethernet_transmit_data          =   0;
logic [NUMBER_OF_RMII_PORTS-1:0]                ethernet_transmit_data_valid    =   0;
logic [7:0]                                     udp_data [0:8888];

logic [8:0]                                     module_transmit_data            =   0;
logic                                           module_transmit_data_valid      =   0;
logic                                           module_clock                    =   0;
logic [8:0]                                     module_transmit_buffer [0:8888];

wire                                        switch_core_clock;
wire                                        switch_core_reset_n;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     switch_core_rmii_phy_receive_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          switch_core_rmii_phy_receive_data_enable;
wire    [NUMBER_OF_RMII_PORTS-1:0]          switch_core_rmii_phy_receive_data_error;
wire    [NUMBER_OF_RMII_PORTS-1:0][1:0]     switch_core_rmii_phy_transmit_data;
wire    [NUMBER_OF_RMII_PORTS-1:0]          switch_core_rmii_phy_transmit_data_valid;
wire    [NUMBER_OF_RMII_PORTS-1:0]          switch_core_rmii_phy_reference_clock;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]       switch_core_module_clock;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0]       switch_core_module_transmit_data_enable;
wire    [NUMBER_OF_VIRTUAL_PORTS-1:0][8:0]  switch_core_module_transmit_data;


switch_core #(
    .NUMBER_OF_RMII_PORTS       (NUMBER_OF_RMII_PORTS),
    .NUMBER_OF_VIRTUAL_PORTS    (NUMBER_OF_VIRTUAL_PORTS),
    .RECEIVE_QUE_SLOTS          (RECEIVE_QUE_SLOTS)
)
switch_core(
    .clock                          (switch_core_clock),
    .reset_n                        (switch_core_reset_n),
    .rmii_phy_receive_data          (switch_core_rmii_phy_receive_data),
    .rmii_phy_receive_data_enable   (switch_core_rmii_phy_receive_data_enable),
    .rmii_phy_receive_data_error    (switch_core_rmii_phy_receive_data_error),
    .module_clock                   (switch_core_module_clock),
    .module_transmit_data_enable    (switch_core_module_transmit_data_enable),
    .module_transmit_data           (switch_core_module_transmit_data),

    .rmii_phy_transmit_data         (switch_core_rmii_phy_transmit_data),
    .rmii_phy_transmit_data_vaid    (switch_core_rmii_phy_transmit_data_valid),
    .rmii_phy_reference_clock       (switch_core_rmii_phy_reference_clock)
);


wire            rmii_byte_packager_clock;
wire            rmii_byte_packager_reset_n;
wire    [1:0]   rmii_byte_packager_data;
wire            rmii_byte_packager_data_enable;
wire    [8:0]   rmii_byte_packager_packaged_data;
wire    [1:0]   rmii_byte_packager_speed_code;
wire            rmii_byte_packager_packaged_data_valid;
wire            rmii_byte_packager_data_error;

rmii_byte_packager rmii_byte_packager(
    .clock                  (rmii_byte_packager_clock),
    .reset_n                (rmii_byte_packager_reset_n),
    .data                   (rmii_byte_packager_data),
    .data_enable            (rmii_byte_packager_data_enable),
    .data_error             (rmii_byte_packager_data_error),

    .speed_code             (rmii_byte_packager_speed_code),
    .packaged_data          (rmii_byte_packager_packaged_data),
    .packaged_data_valid    (rmii_byte_packager_packaged_data_valid)
);


assign  switch_core_clock                               =   clock;
assign  switch_core_reset_n                             =   reset_n;
assign  switch_core_rmii_phy_receive_data[0]            =   ethernet_transmit_data[0];
assign  switch_core_rmii_phy_receive_data_enable[0]     =   ethernet_transmit_data_valid[0];
assign  switch_core_rmii_phy_receive_data_error[0]      =   0;

assign  switch_core_rmii_phy_receive_data[1]            =   ethernet_transmit_data[1];
assign  switch_core_rmii_phy_receive_data_enable[1]     =   ethernet_transmit_data_valid[1];
assign  switch_core_rmii_phy_receive_data_error[1]      =   0;

assign  switch_core_module_transmit_data                =   module_transmit_data;
assign  switch_core_module_transmit_data_enable         =   module_transmit_data_valid;
assign  switch_core_module_clock                        =   module_clock;

assign  rmii_byte_packager_clock                        =   clock;
assign  rmii_byte_packager_reset_n                      =   reset_n;
assign  rmii_byte_packager_data                         =   switch_core_rmii_phy_transmit_data[0];
assign  rmii_byte_packager_data_enable                  =   switch_core_rmii_phy_transmit_data_valid[0];
assign  rmii_byte_packager_data_error                   =   0;


initial begin
    clock   =   0;

    forever begin
        #(CLOCK_PERIOD/2);
        clock   =   ~clock;
    end
end

initial begin
    module_clock   =   0;

    forever begin
        #(MODULE_CLOCK_PERIOD/2);
        module_clock   =   ~module_clock;
    end
end

initial begin
    reset_n =   0;
    repeat(100) @(posedge module_clock);
    reset_n =   1;
end

initial begin
    wait(reset_n);
    repeat(100) @(posedge clock);
    case_000();
    case_002();
    case_003();
    //case_004();
    //case_005();
    case_006();
    $stop();
end


function logic [31:0] calc_crc(logic [7:0] cmd [0:888], logic [15:0] number_of_bytes);
    automatic logic [31:0]  crc                 = '1;
    automatic logic [31:0]  crc_binary_reversed = 0;
    automatic logic [31:0]  c                   = '1;
    automatic logic [31:0]  result              = 0;
    automatic logic [7:0]   d                   = 0;
    automatic int           i                   = 0;
    automatic int           j                   = 0;

    $display("CRC32 Number of Bytes: %d",number_of_bytes);

    for (i=8; i<number_of_bytes; i++) begin
        for (j=0; j<8; j=j+1) begin
            d[j] =   cmd[i][7-j];
        end
        c           =   crc;
        crc[0]      =   d[7] ^ d[6] ^ d[0] ^ c[0] ^ c[6] ^ c[7];
        crc[1]      =   d[6] ^ d[1] ^ d[0] ^ c[0] ^ c[1] ^ c[6];
        crc[2]      =   d[6] ^ d[2] ^ d[1] ^ d[0] ^ c[0] ^ c[1] ^ c[2] ^ c[6];
        crc[3]      =   d[7] ^ d[3] ^ d[2] ^ d[1] ^ c[1] ^ c[2] ^ c[3] ^ c[7];
        crc[4]      =   d[4] ^ d[3] ^ d[2] ^ c[2] ^ c[3] ^ c[4];
        crc[5]      =   d[5] ^ d[4] ^ d[3] ^ c[3] ^ c[4] ^ c[5];
        crc[6]      =   d[6] ^ d[5] ^ d[4] ^ c[4] ^ c[5] ^ c[6];
        crc[7]      =   d[7] ^ d[6] ^ d[5] ^ c[5] ^ c[6] ^ c[7];
        crc[0]      =   c[24] ^ c[30] ^ d[0] ^ d[6];
        crc[1]      =   c[24] ^ c[25] ^ c[30] ^ c[31] ^ d[0] ^ d[1] ^ d[6] ^ d[7];
        crc[2]      =   c[24] ^ c[25] ^ c[26] ^ c[30] ^ c[31] ^ d[0] ^ d[1] ^ d[2] ^ d[6] ^ d[7];
        crc[3]      =   c[25] ^ c[26] ^ c[27] ^ c[31] ^ d[1] ^ d[2] ^ d[3] ^ d[7];
        crc[4]      =   c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ d[0] ^ d[2] ^ d[3] ^ d[4] ^ d[6];
        crc[5]      =   c[24] ^ c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31] ^ d[0] ^ d[1] ^ d[3] ^ d[4] ^ d[5] ^ d[6] ^ d[7];
        crc[6]      =   c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31] ^ d[1] ^ d[2] ^ d[4] ^ d[5] ^ d[6] ^ d[7];
        crc[7]      =   c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31] ^ d[0] ^ d[2] ^ d[3] ^ d[5] ^ d[7];
        crc[8]      =   c[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ d[0] ^ d[1] ^ d[3] ^ d[4];
        crc[9]      =   c[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ d[1] ^ d[2] ^ d[4] ^ d[5];
        crc[10]     =   c[2] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ d[0] ^ d[2] ^ d[3] ^ d[5];
        crc[11]     =   c[3] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ d[0] ^ d[1] ^ d[3] ^ d[4];
        crc[12]     =   c[4] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ d[0] ^ d[1] ^ d[2] ^ d[4] ^ d[5] ^ d[6];
        crc[13]     =   c[5] ^ c[25] ^ c[26] ^ c[27] ^ c[29] ^ c[30] ^ c[31] ^ d[1] ^ d[2] ^ d[3] ^ d[5] ^ d[6] ^ d[7];
        crc[14]     =   c[6] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ c[31] ^ d[2] ^ d[3] ^ d[4] ^ d[6] ^ d[7];
        crc[15]     =   c[7] ^ c[27] ^ c[28] ^ c[29] ^ c[31] ^ d[3] ^ d[4] ^ d[5] ^ d[7];
        crc[16]     =   c[8] ^ c[24] ^ c[28] ^ c[29] ^ d[0] ^ d[4] ^ d[5];
        crc[17]     =   c[9] ^ c[25] ^ c[29] ^ c[30] ^ d[1] ^ d[5] ^ d[6];
        crc[18]     =   c[10] ^ c[26] ^ c[30] ^ c[31] ^ d[2] ^ d[6] ^ d[7];
        crc[19]     =   c[11] ^ c[27] ^ c[31] ^ d[3] ^ d[7];
        crc[20]     =   c[12] ^ c[28] ^ d[4];
        crc[21]     =   c[13] ^ c[29] ^ d[5];
        crc[22]     =   c[14] ^ c[24] ^ d[0];
        crc[23]     =   c[15] ^ c[24] ^ c[25] ^ c[30] ^ d[0] ^ d[1] ^ d[6];
        crc[24]     =   c[16] ^ c[25] ^ c[26] ^ c[31] ^ d[1] ^ d[2] ^ d[7];
        crc[25]     =   c[17] ^ c[26] ^ c[27] ^ d[2] ^ d[3];
        crc[26]     =   c[18] ^ c[24] ^ c[27] ^ c[28] ^ c[30] ^ d[0] ^ d[3] ^ d[4] ^ d[6];
        crc[27]     =   c[19] ^ c[25] ^ c[28] ^ c[29] ^ c[31] ^ d[1] ^ d[4] ^ d[5] ^ d[7];
        crc[28]     =   c[20] ^ c[26] ^ c[29] ^ c[30] ^ d[2] ^ d[5] ^ d[6];
        crc[29]     =   c[21] ^ c[27] ^ c[30] ^ c[31] ^ d[3] ^ d[6] ^ d[7];
        crc[30]     =   c[22] ^ c[28] ^ c[31] ^ d[4] ^ d[7];
        crc[31]     =   c[23] ^ c[29] ^ d[5];
    end

    crc = crc ^ 32'hFFFF_FFFF;

    for (i=0;i<32;i++) begin
        crc_binary_reversed[i]   = crc[31-i];
    end

    result = {crc_binary_reversed[7:0],crc_binary_reversed[15:8], crc_binary_reversed[23:16], crc_binary_reversed[31:24]};

    $display("CRC32 Result: %h",result);
    return result;
endfunction

endmodule