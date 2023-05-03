//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Tue May  2 19:11:05 2023
// Version: 2022.3 2022.3.0.8
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of RTG4TPSRAM_C0 to TCL
# Family: RTG4
# Part Number: RT4G150_ES-CG1657
# Create and Configure the core component RTG4TPSRAM_C0
create_and_configure_core -core_vlnv {Actel:SgCore:RTG4TPSRAM:1.1.110} -component_name {RTG4TPSRAM_C0} -params {\
"A_DOUT_EN_PN:RD_EN"  \
"A_DOUT_EN_POLARITY:2"  \
"A_DOUT_SRST_PN:RD_SRST_N"  \
"A_DOUT_SRST_POLARITY:2"  \
"A_WBYTE_EN_PN:WBYTE_EN"  \
"ARST_N_POLARITY:2"  \
"BYTE_ENABLE_WIDTH:0"  \
"BYTEENABLES:0"  \
"CASCADE:0"  \
"CLK_EDGE:RISE"  \
"CLKS:1"  \
"CLOCK_PN:CLK"  \
"DATA_IN_PN:WD"  \
"DATA_OUT_PN:RD"  \
"ECC:0"  \
"IMPORT_FILE:"  \
"INIT_RAM:F"  \
"LPMTYPE:LPM_RAM"  \
"PTYPE:1"  \
"RADDRESS_PN:RADDR"  \
"RCLK_EDGE:RISE"  \
"RCLOCK_PN:RCLK"  \
"RDEPTH:12"  \
"RE_PN:REN"  \
"RE_POLARITY:2"  \
"RESET_PN:ARST_N"  \
"RPMODE:1"  \
"RWIDTH:48"  \
"WADDRESS_PN:WADDR"  \
"WCLK_EDGE:RISE"  \
"WCLOCK_PN:WCLK"  \
"WDEPTH:12"  \
"WE_PN:WEN"  \
"WE_POLARITY:1"  \
"WWIDTH:48"   }
# Exporting Component Description of RTG4TPSRAM_C0 to TCL done
*/

// RTG4TPSRAM_C0
module RTG4TPSRAM_C0(
    // Inputs
    CLK,
    RADDR,
    WADDR,
    WD,
    WEN,
    // Outputs
    RD
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         CLK;
input  [3:0]  RADDR;
input  [3:0]  WADDR;
input  [47:0] WD;
input         WEN;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [47:0] RD;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          CLK;
wire   [3:0]  RADDR;
wire   [47:0] RD_net_0;
wire   [3:0]  WADDR;
wire   [47:0] WD;
wire          WEN;
wire   [47:0] RD_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net    = 1'b0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign RD_net_1 = RD_net_0;
assign RD[47:0] = RD_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------RTG4TPSRAM_C0_RTG4TPSRAM_C0_0_RTG4TPSRAM   -   Actel:SgCore:RTG4TPSRAM:1.1.110
RTG4TPSRAM_C0_RTG4TPSRAM_C0_0_RTG4TPSRAM RTG4TPSRAM_C0_0(
        // Inputs
        .WD    ( WD ),
        .WADDR ( WADDR ),
        .RADDR ( RADDR ),
        .WEN   ( WEN ),
        .CLK   ( CLK ),
        // Outputs
        .RD    ( RD_net_0 ) 
        );


endmodule
