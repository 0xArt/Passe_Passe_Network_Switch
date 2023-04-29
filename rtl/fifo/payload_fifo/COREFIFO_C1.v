//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Fri Apr 28 10:40:28 2023
// Version: 2022.3 2022.3.0.8
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of COREFIFO_C1 to TCL
# Family: RTG4
# Part Number: RT4G150_ES-CG1657
# Create and Configure the core component COREFIFO_C1
create_and_configure_core -core_vlnv {Actel:DirectCore:COREFIFO:3.0.101} -component_name {COREFIFO_C1} -params {\
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
"RWIDTH:8"  \
"SYNC:1"  \
"SYNC_RESET:0"  \
"UNDERFLOW_EN:false"  \
"WDEPTH:1024"  \
"WE_POLARITY:0"  \
"WRCNT_EN:false"  \
"WRITE_ACK:false"  \
"WWIDTH:8"   }
# Exporting Component Description of COREFIFO_C1 to TCL done
*/

// COREFIFO_C1
module COREFIFO_C1(
    // Inputs
    CLK,
    DATA,
    RE,
    RESET_N,
    WE,
    // Outputs
    DVLD,
    EMPTY,
    FULL,
    Q
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input        CLK;
input  [7:0] DATA;
input        RE;
input        RESET_N;
input        WE;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output       DVLD;
output       EMPTY;
output       FULL;
output [7:0] Q;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire         CLK;
wire   [7:0] DATA;
wire         DVLD_net_0;
wire         EMPTY_net_0;
wire         FULL_net_0;
wire   [7:0] Q_net_0;
wire         RE;
wire         RESET_N;
wire         WE;
wire   [7:0] Q_net_1;
wire         FULL_net_1;
wire         EMPTY_net_1;
wire         DVLD_net_1;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire         GND_net;
wire   [7:0] MEMRD_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net           = 1'b0;
assign MEMRD_const_net_0 = 8'h00;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign Q_net_1     = Q_net_0;
assign Q[7:0]      = Q_net_1;
assign FULL_net_1  = FULL_net_0;
assign FULL        = FULL_net_1;
assign EMPTY_net_1 = EMPTY_net_0;
assign EMPTY       = EMPTY_net_1;
assign DVLD_net_1  = DVLD_net_0;
assign DVLD        = DVLD_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------COREFIFO_C1_COREFIFO_C1_0_COREFIFO   -   Actel:DirectCore:COREFIFO:3.0.101
COREFIFO_C1_COREFIFO_C1_0_COREFIFO #( 
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
        .RWIDTH       ( 8 ),
        .SYNC         ( 1 ),
        .SYNC_RESET   ( 0 ),
        .UNDERFLOW_EN ( 0 ),
        .WDEPTH       ( 1024 ),
        .WE_POLARITY  ( 0 ),
        .WRCNT_EN     ( 0 ),
        .WRITE_ACK    ( 0 ),
        .WWIDTH       ( 8 ) )
COREFIFO_C1_0(
        // Inputs
        .CLK        ( CLK ),
        .WCLOCK     ( GND_net ), // tied to 1'b0 from definition
        .RCLOCK     ( GND_net ), // tied to 1'b0 from definition
        .RESET_N    ( RESET_N ),
        .WRESET_N   ( GND_net ), // tied to 1'b0 from definition
        .RRESET_N   ( GND_net ), // tied to 1'b0 from definition
        .DATA       ( DATA ),
        .WE         ( WE ),
        .RE         ( RE ),
        .MEMRD      ( MEMRD_const_net_0 ), // tied to 8'h00 from definition
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
