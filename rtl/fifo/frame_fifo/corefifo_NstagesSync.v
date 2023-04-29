// ********************************************************************/
// Actel Corporation Proprietary and Confidential
//  Copyright 2011 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: doubleSync.v
//               
//
//
// Revision Information:
// Date     Description
//
// SVN Revision Information:
// SVN $Revision: 4805 $
// SVN $Date: 2012-06-21 17:48:48 +0530 (Thu, 21 Jun 2012) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ********************************************************************/

`timescale 1ns / 100ps

module COREFIFO_C0_COREFIFO_C0_0_corefifo_NstagesSync(
                  clk,
                  //rstn,
                  arstn,//added in v3.0
                  srstn,//added in v3.0
                  inp,
                  sync_out
                  );

   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
  parameter NUM_STAGES = 2;
  parameter ADDRWIDTH = 3;

input clk;
//input rstn;commented in v3.0
input arstn;//added in v3.0
input srstn;//added in v3.0
input [ADDRWIDTH : 0 ] inp;
output [ADDRWIDTH : 0 ] sync_out;

//reg [WIDTH -1:0] signal_out;

reg [ADDRWIDTH : 0 ] shift_reg ;
 reg [ADDRWIDTH : 0 ] shift_mem_reg [NUM_STAGES-1:0] ;


always @ ( posedge clk or negedge arstn) 
  begin	
    if (!arstn | !srstn) 
		shift_reg <= 'h0;
	else
		shift_reg <= inp;

  end 


always @ (*)
 	shift_mem_reg[0] = shift_reg;

integer i;
always @ ( posedge clk or negedge arstn) 
  begin	
    if (!arstn | !srstn) 
      begin
        for(i = NUM_STAGES-1; i >0 ; i = i-1) 
          begin
		    shift_mem_reg[i] <= 'h0;
          end
      end
 /// signal_out <= 'h0;
  else
    begin

	  for(i = NUM_STAGES-1; i > 0; i = i-1) 
		shift_mem_reg[i] <= shift_mem_reg[i-1];


//end
    //signal_out <= shift_reg[NUM_STAGES-1];
    end
end 

assign sync_out = shift_mem_reg[NUM_STAGES-1];

   
   
endmodule // corefifo_doubleSync

   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
