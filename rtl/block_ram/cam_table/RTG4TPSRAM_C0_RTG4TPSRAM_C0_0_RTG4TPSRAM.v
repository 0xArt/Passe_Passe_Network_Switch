`timescale 1 ns/100 ps
// Version: 2022.3 2022.3.0.8


module RTG4TPSRAM_C0_RTG4TPSRAM_C0_0_RTG4TPSRAM(
       WD,
       RD,
       WADDR,
       RADDR,
       WEN,
       CLK
    );
input  [47:0] WD;
output [47:0] RD;
input  [3:0] WADDR;
input  [3:0] RADDR;
input  WEN;
input  CLK;

    wire VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    RAM1K18_RT RTG4TPSRAM_C0_RTG4TPSRAM_C0_0_RTG4TPSRAM_R0C1 (.BUSY(), 
        .A_DB_DETECT(), .B_DB_DETECT(), .A_DOUT({nc0, nc1, nc2, nc3, 
        nc4, nc5, nc6, nc7, nc8, nc9, RD[47], RD[46], RD[45], RD[44], 
        RD[43], RD[42], RD[41], RD[40]}), .B_DOUT({nc10, RD[39], 
        RD[38], RD[37], RD[36], RD[35], RD[34], RD[33], RD[32], nc11, 
        RD[31], RD[30], RD[29], RD[28], RD[27], RD[26], RD[25], RD[24]})
        , .A_SB_CORRECT(), .B_SB_CORRECT(), .A_ADDR({GND, GND, GND, 
        GND, GND, RADDR[3], RADDR[2], RADDR[1], RADDR[0], GND, GND}), 
        .B_ADDR({GND, GND, GND, GND, GND, WADDR[3], WADDR[2], WADDR[1], 
        WADDR[0], GND, GND}), .A_BLK({VCC, VCC, VCC}), .B_BLK({WEN, 
        VCC, VCC}), .A_CLK(CLK), .B_CLK(CLK), .A_DIN({GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, WD[47], WD[46], WD[45], 
        WD[44], WD[43], WD[42], WD[41], WD[40]}), .B_DIN({GND, WD[39], 
        WD[38], WD[37], WD[36], WD[35], WD[34], WD[33], WD[32], GND, 
        WD[31], WD[30], WD[29], WD[28], WD[27], WD[26], WD[25], WD[24]})
        , .A_DOUT_EN(VCC), .B_DOUT_EN(VCC), .A_REN(VCC), .B_REN(VCC), 
        .A_DOUT_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .A_WEN({VCC, VCC}), 
        .B_WEN({VCC, VCC}), .DELEN(GND), .SECURITY(GND), .ECC(GND), 
        .ECC_DOUT_BYPASS(GND), .A_WIDTH({VCC, GND}), .A_WMODE({GND, 
        GND}), .A_DOUT_BYPASS(GND), .B_WIDTH({VCC, GND}), .B_WMODE({
        GND, GND}), .B_DOUT_BYPASS(GND), .ARST_N(VCC));
    RAM1K18_RT RTG4TPSRAM_C0_RTG4TPSRAM_C0_0_RTG4TPSRAM_R0C0 (.BUSY(), 
        .A_DB_DETECT(), .B_DB_DETECT(), .A_DOUT({nc12, nc13, nc14, 
        nc15, nc16, nc17, nc18, nc19, nc20, nc21, RD[23], RD[22], 
        RD[21], RD[20], RD[19], RD[18], RD[17], RD[16]}), .B_DOUT({
        nc22, RD[15], RD[14], RD[13], RD[12], RD[11], RD[10], RD[9], 
        RD[8], nc23, RD[7], RD[6], RD[5], RD[4], RD[3], RD[2], RD[1], 
        RD[0]}), .A_SB_CORRECT(), .B_SB_CORRECT(), .A_ADDR({GND, GND, 
        GND, GND, GND, RADDR[3], RADDR[2], RADDR[1], RADDR[0], GND, 
        GND}), .B_ADDR({GND, GND, GND, GND, GND, WADDR[3], WADDR[2], 
        WADDR[1], WADDR[0], GND, GND}), .A_BLK({VCC, VCC, VCC}), 
        .B_BLK({WEN, VCC, VCC}), .A_CLK(CLK), .B_CLK(CLK), .A_DIN({GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, WD[23], WD[22], 
        WD[21], WD[20], WD[19], WD[18], WD[17], WD[16]}), .B_DIN({GND, 
        WD[15], WD[14], WD[13], WD[12], WD[11], WD[10], WD[9], WD[8], 
        GND, WD[7], WD[6], WD[5], WD[4], WD[3], WD[2], WD[1], WD[0]}), 
        .A_DOUT_EN(VCC), .B_DOUT_EN(VCC), .A_REN(VCC), .B_REN(VCC), 
        .A_DOUT_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .A_WEN({VCC, VCC}), 
        .B_WEN({VCC, VCC}), .DELEN(GND), .SECURITY(GND), .ECC(GND), 
        .ECC_DOUT_BYPASS(GND), .A_WIDTH({VCC, GND}), .A_WMODE({GND, 
        GND}), .A_DOUT_BYPASS(GND), .B_WIDTH({VCC, GND}), .B_WMODE({
        GND, GND}), .B_DOUT_BYPASS(GND), .ARST_N(VCC));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
