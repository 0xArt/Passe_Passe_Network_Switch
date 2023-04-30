`timescale 1 ns/100 ps
// Version: 2022.3 2022.3.0.8


module COREFIFO_C2_COREFIFO_C2_0_LSRAM_top(
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
input  [12:0] WADDR;
input  [12:0] RADDR;
input  WEN;
input  REN;
input  WCLK;
input  RCLK;

    wire \QX_TEMPR0[0] , \QX_TEMPR1[0] , \QX_TEMPR2[0] , 
        \QX_TEMPR3[0] , \QX_TEMPR0[1] , \QX_TEMPR1[1] , \QX_TEMPR2[1] , 
        \QX_TEMPR3[1] , \QX_TEMPR0[2] , \QX_TEMPR1[2] , \QX_TEMPR2[2] , 
        \QX_TEMPR3[2] , \QX_TEMPR0[3] , \QX_TEMPR1[3] , \QX_TEMPR2[3] , 
        \QX_TEMPR3[3] , \QX_TEMPR0[4] , \QX_TEMPR1[4] , \QX_TEMPR2[4] , 
        \QX_TEMPR3[4] , \QX_TEMPR0[5] , \QX_TEMPR1[5] , \QX_TEMPR2[5] , 
        \QX_TEMPR3[5] , \QX_TEMPR0[6] , \QX_TEMPR1[6] , \QX_TEMPR2[6] , 
        \QX_TEMPR3[6] , \QX_TEMPR0[7] , \QX_TEMPR1[7] , \QX_TEMPR2[7] , 
        \QX_TEMPR3[7] , \QX_TEMPR0[8] , \QX_TEMPR1[8] , \QX_TEMPR2[8] , 
        \QX_TEMPR3[8] , \BLKX0[0] , \BLKY0[0] , \BLKX1[0] , \BLKY1[0] , 
        VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    INV \INVBLKX0[0]  (.A(WADDR[11]), .Y(\BLKX0[0] ));
    INV \INVBLKY1[0]  (.A(RADDR[12]), .Y(\BLKY1[0] ));
    OR4 \OR4_RD[6]  (.A(\QX_TEMPR0[6] ), .B(\QX_TEMPR1[6] ), .C(
        \QX_TEMPR2[6] ), .D(\QX_TEMPR3[6] ), .Y(RD[6]));
    RAM1K18_RT COREFIFO_C2_COREFIFO_C2_0_LSRAM_top_R2C0 (.BUSY(), 
        .A_DB_DETECT(), .B_DB_DETECT(), .A_DOUT({nc0, nc1, nc2, nc3, 
        nc4, nc5, nc6, nc7, nc8, \QX_TEMPR2[8] , \QX_TEMPR2[7] , 
        \QX_TEMPR2[6] , \QX_TEMPR2[5] , \QX_TEMPR2[4] , \QX_TEMPR2[3] , 
        \QX_TEMPR2[2] , \QX_TEMPR2[1] , \QX_TEMPR2[0] }), .B_DOUT({nc9, 
        nc10, nc11, nc12, nc13, nc14, nc15, nc16, nc17, nc18, nc19, 
        nc20, nc21, nc22, nc23, nc24, nc25, nc26}), .A_SB_CORRECT(), 
        .B_SB_CORRECT(), .A_ADDR({RADDR[10], RADDR[9], RADDR[8], 
        RADDR[7], RADDR[6], RADDR[5], RADDR[4], RADDR[3], RADDR[2], 
        RADDR[1], RADDR[0]}), .B_ADDR({WADDR[10], WADDR[9], WADDR[8], 
        WADDR[7], WADDR[6], WADDR[5], WADDR[4], WADDR[3], WADDR[2], 
        WADDR[1], WADDR[0]}), .A_BLK({REN, RADDR[12], \BLKY0[0] }), 
        .B_BLK({WEN, WADDR[12], \BLKX0[0] }), .A_CLK(RCLK), .B_CLK(
        WCLK), .A_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND}), .B_DIN({GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, WD[8], WD[7], WD[6], 
        WD[5], WD[4], WD[3], WD[2], WD[1], WD[0]}), .A_DOUT_EN(VCC), 
        .B_DOUT_EN(VCC), .A_REN(VCC), .B_REN(VCC), .A_DOUT_SRST_N(VCC), 
        .B_DOUT_SRST_N(VCC), .A_WEN({GND, GND}), .B_WEN({VCC, VCC}), 
        .DELEN(GND), .SECURITY(GND), .ECC(GND), .ECC_DOUT_BYPASS(GND), 
        .A_WIDTH({GND, GND}), .A_WMODE({GND, GND}), .A_DOUT_BYPASS(VCC)
        , .B_WIDTH({GND, GND}), .B_WMODE({GND, GND}), .B_DOUT_BYPASS(
        VCC), .ARST_N(VCC));
    OR4 \OR4_RD[0]  (.A(\QX_TEMPR0[0] ), .B(\QX_TEMPR1[0] ), .C(
        \QX_TEMPR2[0] ), .D(\QX_TEMPR3[0] ), .Y(RD[0]));
    OR4 \OR4_RD[7]  (.A(\QX_TEMPR0[7] ), .B(\QX_TEMPR1[7] ), .C(
        \QX_TEMPR2[7] ), .D(\QX_TEMPR3[7] ), .Y(RD[7]));
    INV \INVBLKX1[0]  (.A(WADDR[12]), .Y(\BLKX1[0] ));
    OR4 \OR4_RD[4]  (.A(\QX_TEMPR0[4] ), .B(\QX_TEMPR1[4] ), .C(
        \QX_TEMPR2[4] ), .D(\QX_TEMPR3[4] ), .Y(RD[4]));
    OR4 \OR4_RD[3]  (.A(\QX_TEMPR0[3] ), .B(\QX_TEMPR1[3] ), .C(
        \QX_TEMPR2[3] ), .D(\QX_TEMPR3[3] ), .Y(RD[3]));
    OR4 \OR4_RD[5]  (.A(\QX_TEMPR0[5] ), .B(\QX_TEMPR1[5] ), .C(
        \QX_TEMPR2[5] ), .D(\QX_TEMPR3[5] ), .Y(RD[5]));
    OR4 \OR4_RD[8]  (.A(\QX_TEMPR0[8] ), .B(\QX_TEMPR1[8] ), .C(
        \QX_TEMPR2[8] ), .D(\QX_TEMPR3[8] ), .Y(RD[8]));
    RAM1K18_RT COREFIFO_C2_COREFIFO_C2_0_LSRAM_top_R0C0 (.BUSY(), 
        .A_DB_DETECT(), .B_DB_DETECT(), .A_DOUT({nc27, nc28, nc29, 
        nc30, nc31, nc32, nc33, nc34, nc35, \QX_TEMPR0[8] , 
        \QX_TEMPR0[7] , \QX_TEMPR0[6] , \QX_TEMPR0[5] , \QX_TEMPR0[4] , 
        \QX_TEMPR0[3] , \QX_TEMPR0[2] , \QX_TEMPR0[1] , \QX_TEMPR0[0] })
        , .B_DOUT({nc36, nc37, nc38, nc39, nc40, nc41, nc42, nc43, 
        nc44, nc45, nc46, nc47, nc48, nc49, nc50, nc51, nc52, nc53}), 
        .A_SB_CORRECT(), .B_SB_CORRECT(), .A_ADDR({RADDR[10], RADDR[9], 
        RADDR[8], RADDR[7], RADDR[6], RADDR[5], RADDR[4], RADDR[3], 
        RADDR[2], RADDR[1], RADDR[0]}), .B_ADDR({WADDR[10], WADDR[9], 
        WADDR[8], WADDR[7], WADDR[6], WADDR[5], WADDR[4], WADDR[3], 
        WADDR[2], WADDR[1], WADDR[0]}), .A_BLK({REN, \BLKY1[0] , 
        \BLKY0[0] }), .B_BLK({WEN, \BLKX1[0] , \BLKX0[0] }), .A_CLK(
        RCLK), .B_CLK(WCLK), .A_DIN({GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND}), 
        .B_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, WD[8], 
        WD[7], WD[6], WD[5], WD[4], WD[3], WD[2], WD[1], WD[0]}), 
        .A_DOUT_EN(VCC), .B_DOUT_EN(VCC), .A_REN(VCC), .B_REN(VCC), 
        .A_DOUT_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .A_WEN({GND, GND}), 
        .B_WEN({VCC, VCC}), .DELEN(GND), .SECURITY(GND), .ECC(GND), 
        .ECC_DOUT_BYPASS(GND), .A_WIDTH({GND, GND}), .A_WMODE({GND, 
        GND}), .A_DOUT_BYPASS(VCC), .B_WIDTH({GND, GND}), .B_WMODE({
        GND, GND}), .B_DOUT_BYPASS(VCC), .ARST_N(VCC));
    RAM1K18_RT COREFIFO_C2_COREFIFO_C2_0_LSRAM_top_R3C0 (.BUSY(), 
        .A_DB_DETECT(), .B_DB_DETECT(), .A_DOUT({nc54, nc55, nc56, 
        nc57, nc58, nc59, nc60, nc61, nc62, \QX_TEMPR3[8] , 
        \QX_TEMPR3[7] , \QX_TEMPR3[6] , \QX_TEMPR3[5] , \QX_TEMPR3[4] , 
        \QX_TEMPR3[3] , \QX_TEMPR3[2] , \QX_TEMPR3[1] , \QX_TEMPR3[0] })
        , .B_DOUT({nc63, nc64, nc65, nc66, nc67, nc68, nc69, nc70, 
        nc71, nc72, nc73, nc74, nc75, nc76, nc77, nc78, nc79, nc80}), 
        .A_SB_CORRECT(), .B_SB_CORRECT(), .A_ADDR({RADDR[10], RADDR[9], 
        RADDR[8], RADDR[7], RADDR[6], RADDR[5], RADDR[4], RADDR[3], 
        RADDR[2], RADDR[1], RADDR[0]}), .B_ADDR({WADDR[10], WADDR[9], 
        WADDR[8], WADDR[7], WADDR[6], WADDR[5], WADDR[4], WADDR[3], 
        WADDR[2], WADDR[1], WADDR[0]}), .A_BLK({REN, RADDR[12], 
        RADDR[11]}), .B_BLK({WEN, WADDR[12], WADDR[11]}), .A_CLK(RCLK), 
        .B_CLK(WCLK), .A_DIN({GND, GND, GND, GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND}), .B_DIN({
        GND, GND, GND, GND, GND, GND, GND, GND, GND, WD[8], WD[7], 
        WD[6], WD[5], WD[4], WD[3], WD[2], WD[1], WD[0]}), .A_DOUT_EN(
        VCC), .B_DOUT_EN(VCC), .A_REN(VCC), .B_REN(VCC), 
        .A_DOUT_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .A_WEN({GND, GND}), 
        .B_WEN({VCC, VCC}), .DELEN(GND), .SECURITY(GND), .ECC(GND), 
        .ECC_DOUT_BYPASS(GND), .A_WIDTH({GND, GND}), .A_WMODE({GND, 
        GND}), .A_DOUT_BYPASS(VCC), .B_WIDTH({GND, GND}), .B_WMODE({
        GND, GND}), .B_DOUT_BYPASS(VCC), .ARST_N(VCC));
    OR4 \OR4_RD[2]  (.A(\QX_TEMPR0[2] ), .B(\QX_TEMPR1[2] ), .C(
        \QX_TEMPR2[2] ), .D(\QX_TEMPR3[2] ), .Y(RD[2]));
    RAM1K18_RT COREFIFO_C2_COREFIFO_C2_0_LSRAM_top_R1C0 (.BUSY(), 
        .A_DB_DETECT(), .B_DB_DETECT(), .A_DOUT({nc81, nc82, nc83, 
        nc84, nc85, nc86, nc87, nc88, nc89, \QX_TEMPR1[8] , 
        \QX_TEMPR1[7] , \QX_TEMPR1[6] , \QX_TEMPR1[5] , \QX_TEMPR1[4] , 
        \QX_TEMPR1[3] , \QX_TEMPR1[2] , \QX_TEMPR1[1] , \QX_TEMPR1[0] })
        , .B_DOUT({nc90, nc91, nc92, nc93, nc94, nc95, nc96, nc97, 
        nc98, nc99, nc100, nc101, nc102, nc103, nc104, nc105, nc106, 
        nc107}), .A_SB_CORRECT(), .B_SB_CORRECT(), .A_ADDR({RADDR[10], 
        RADDR[9], RADDR[8], RADDR[7], RADDR[6], RADDR[5], RADDR[4], 
        RADDR[3], RADDR[2], RADDR[1], RADDR[0]}), .B_ADDR({WADDR[10], 
        WADDR[9], WADDR[8], WADDR[7], WADDR[6], WADDR[5], WADDR[4], 
        WADDR[3], WADDR[2], WADDR[1], WADDR[0]}), .A_BLK({REN, 
        \BLKY1[0] , RADDR[11]}), .B_BLK({WEN, \BLKX1[0] , WADDR[11]}), 
        .A_CLK(RCLK), .B_CLK(WCLK), .A_DIN({GND, GND, GND, GND, GND, 
        GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        GND}), .B_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        WD[8], WD[7], WD[6], WD[5], WD[4], WD[3], WD[2], WD[1], WD[0]})
        , .A_DOUT_EN(VCC), .B_DOUT_EN(VCC), .A_REN(VCC), .B_REN(VCC), 
        .A_DOUT_SRST_N(VCC), .B_DOUT_SRST_N(VCC), .A_WEN({GND, GND}), 
        .B_WEN({VCC, VCC}), .DELEN(GND), .SECURITY(GND), .ECC(GND), 
        .ECC_DOUT_BYPASS(GND), .A_WIDTH({GND, GND}), .A_WMODE({GND, 
        GND}), .A_DOUT_BYPASS(VCC), .B_WIDTH({GND, GND}), .B_WMODE({
        GND, GND}), .B_DOUT_BYPASS(VCC), .ARST_N(VCC));
    INV \INVBLKY0[0]  (.A(RADDR[11]), .Y(\BLKY0[0] ));
    OR4 \OR4_RD[1]  (.A(\QX_TEMPR0[1] ), .B(\QX_TEMPR1[1] ), .C(
        \QX_TEMPR2[1] ), .D(\QX_TEMPR3[1] ), .Y(RD[1]));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
