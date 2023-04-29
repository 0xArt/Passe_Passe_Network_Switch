`timescale 1 ns/100 ps
// Version: 2022.3 2022.3.0.8


module COREFIFO_C0_COREFIFO_C0_0_LSRAM_top(
       WD,
       RD,
       WADDR,
       RADDR,
       WEN,
       REN,
       WCLK,
       RCLK
    );
input  [8:0] WD;
output [8:0] RD;
input  [9:0] WADDR;
input  [9:0] RADDR;
input  WEN;
input  REN;
input  WCLK;
input  RCLK;

    wire VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    RAM1K18_RT COREFIFO_C0_COREFIFO_C0_0_LSRAM_top_R0C0 (.BUSY(), 
        .A_DB_DETECT(), .B_DB_DETECT(), .A_DOUT({nc0, nc1, nc2, nc3, 
        nc4, nc5, nc6, nc7, nc8, RD[8], RD[7], RD[6], RD[5], RD[4], 
        RD[3], RD[2], RD[1], RD[0]}), .B_DOUT({nc9, nc10, nc11, nc12, 
        nc13, nc14, nc15, nc16, nc17, nc18, nc19, nc20, nc21, nc22, 
        nc23, nc24, nc25, nc26}), .A_SB_CORRECT(), .B_SB_CORRECT(), 
        .A_ADDR({GND, RADDR[9], RADDR[8], RADDR[7], RADDR[6], RADDR[5], 
        RADDR[4], RADDR[3], RADDR[2], RADDR[1], RADDR[0]}), .B_ADDR({
        GND, WADDR[9], WADDR[8], WADDR[7], WADDR[6], WADDR[5], 
        WADDR[4], WADDR[3], WADDR[2], WADDR[1], WADDR[0]}), .A_BLK({
        VCC, VCC, VCC}), .B_BLK({WEN, VCC, VCC}), .A_CLK(RCLK), .B_CLK(
        WCLK), .A_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND}), .B_DIN({GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, WD[8], WD[7], WD[6], 
        WD[5], WD[4], WD[3], WD[2], WD[1], WD[0]}), .A_DOUT_EN(VCC), 
        .B_DOUT_EN(VCC), .A_REN(REN), .B_REN(VCC), .A_DOUT_SRST_N(VCC), 
        .B_DOUT_SRST_N(VCC), .A_WEN({GND, GND}), .B_WEN({VCC, VCC}), 
        .DELEN(GND), .SECURITY(GND), .ECC(GND), .ECC_DOUT_BYPASS(GND), 
        .A_WIDTH({GND, GND}), .A_WMODE({GND, GND}), .A_DOUT_BYPASS(VCC)
        , .B_WIDTH({GND, GND}), .B_WMODE({GND, GND}), .B_DOUT_BYPASS(
        VCC), .ARST_N(VCC));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
