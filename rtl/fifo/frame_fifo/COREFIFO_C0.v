//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Tue Apr 25 21:17:53 2023
// Version: 2022.3 2022.3.0.8
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of COREFIFO_C0 to TCL
# Family: RTG4
# Part Number: RT4G150_ES-CG1657
# Create and Configure the core component COREFIFO_C0
create_and_configure_core -core_vlnv {Actel:DirectCore:COREFIFO:3.0.101} -component_name {COREFIFO_C0} -params {\
"AE_STATIC_EN:false"  \
"AEVAL:4"  \
"AF_STATIC_EN:false"  \
"AFVAL:1020"  \
"CTRL_TYPE:2"  \
"DIE_SIZE:28"  \
"ECC:0"  \
"ESTOP:true"  \
"FSTOP:true"  \
"FWFT:true"  \
"NUM_STAGES:2"  \
"OVERFLOW_EN:false"  \
"PIPE:1"  \
"PREFETCH:false"  \
"RAM_OPT:0"  \
"RDCNT_EN:false"  \
"RDEPTH:1024"  \
"RE_POLARITY:0"  \
"READ_DVALID:true"  \
"RWIDTH:9"  \
"SYNC:0"  \
"SYNC_RESET:0"  \
"UNDERFLOW_EN:false"  \
"WDEPTH:1024"  \
"WE_POLARITY:0"  \
"WRCNT_EN:false"  \
"WRITE_ACK:false"  \
"WWIDTH:9"   }
# Exporting Component Description of COREFIFO_C0 to TCL done
*/

// COREFIFO_C0
module COREFIFO_C0(
    // Inputs
    DATA,
    RCLOCK,
    RE,
    RRESET_N,
    WCLOCK,
    WE,
    WRESET_N,
    // Outputs
    DVLD,
    EMPTY,
    FULL,
    Q
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [8:0] DATA;
input        RCLOCK;
input        RE;
input        RRESET_N;
input        WCLOCK;
input        WE;
input        WRESET_N;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output       DVLD;
output       EMPTY;
output       FULL;
output [8:0] Q;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [8:0] DATA;
wire         DVLD_net_0;
wire         EMPTY_net_0;
wire         FULL_net_0;
wire   [8:0] Q_net_0;
wire         RCLOCK;
wire         RE;
wire         RRESET_N;
wire         WCLOCK;
wire         WE;
wire         WRESET_N;
wire   [8:0] Q_net_1;
wire         FULL_net_1;
wire         EMPTY_net_1;
wire         DVLD_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire         GND_net;
wire   [8:0] MEMRD_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net           = 1'b0;
assign MEMRD_const_net_0 = 9'h000;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign Q_net_1     = Q_net_0;
assign Q[8:0]      = Q_net_1;
assign FULL_net_1  = FULL_net_0;
assign FULL        = FULL_net_1;
assign EMPTY_net_1 = EMPTY_net_0;
assign EMPTY       = EMPTY_net_1;
assign DVLD_net_1  = DVLD_net_0;
assign DVLD        = DVLD_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------COREFIFO_C0_COREFIFO_C0_0_COREFIFO   -   Actel:DirectCore:COREFIFO:3.0.101
COREFIFO_C0_COREFIFO_C0_0_COREFIFO #( 
        .AE_STATIC_EN ( 0 ),
        .AEVAL        ( 4 ),
        .AF_STATIC_EN ( 0 ),
        .AFVAL        ( 1020 ),
        .CTRL_TYPE    ( 2 ),
        .DIE_SIZE     ( 28 ),
        .ECC          ( 0 ),
        .ESTOP        ( 1 ),
        .FAMILY       ( 25 ),
        .FSTOP        ( 1 ),
        .FWFT         ( 1 ),
        .NUM_STAGES   ( 2 ),
        .OVERFLOW_EN  ( 0 ),
        .PIPE         ( 1 ),
        .PREFETCH     ( 0 ),
        .RAM_OPT      ( 0 ),
        .RDCNT_EN     ( 0 ),
        .RDEPTH       ( 1024 ),
        .RE_POLARITY  ( 0 ),
        .READ_DVALID  ( 1 ),
        .RWIDTH       ( 9 ),
        .SYNC         ( 0 ),
        .SYNC_RESET   ( 0 ),
        .UNDERFLOW_EN ( 0 ),
        .WDEPTH       ( 1024 ),
        .WE_POLARITY  ( 0 ),
        .WRCNT_EN     ( 0 ),
        .WRITE_ACK    ( 0 ),
        .WWIDTH       ( 9 ) )
COREFIFO_C0_0(
        // Inputs
        .CLK        ( GND_net ), // tied to 1'b0 from definition
        .WCLOCK     ( WCLOCK ),
        .RCLOCK     ( RCLOCK ),
        .RESET_N    ( GND_net ), // tied to 1'b0 from definition
        .WRESET_N   ( WRESET_N ),
        .RRESET_N   ( RRESET_N ),
        .DATA       ( DATA ),
        .WE         ( WE ),
        .RE         ( RE ),
        .MEMRD      ( MEMRD_const_net_0 ), // tied to 9'h000 from definition
        // Outputs
        .Q          ( Q_net_0 ),
        .FULL       ( FULL_net_0 ),
        .EMPTY      ( EMPTY_net_0 ),
        .AFULL      (  ),
        .AEMPTY     (  ),
        .OVERFLOW   (  ),
        .UNDERFLOW  (  ),
        .WACK       (  ),
        .DVLD       ( DVLD_net_0 ),
        .WRCNT      (  ),
        .RDCNT      (  ),
        .MEMWE      (  ),
        .MEMRE      (  ),
        .MEMWADDR   (  ),
        .MEMRADDR   (  ),
        .MEMWD      (  ),
        .SB_CORRECT (  ),
        .DB_DETECT  (  ) 
        );


endmodule
