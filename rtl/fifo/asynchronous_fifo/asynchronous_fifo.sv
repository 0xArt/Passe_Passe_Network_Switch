`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 05/28/2023
// Design Name: 
// Module Name: asynchronous_fifo
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
module asynchronous_fifo#(
    parameter DATA_WIDTH                = 16,
    parameter DATA_DEPTH                = 4096,
    parameter FIRST_WORD_FALL_THROUGH   = 0,
    parameter PIPELINED_MEMORY          = 0,
    parameter XILINX                    = 0
)(
    input   wire                            read_clock,
    input   wire                            read_reset_n,
    input   wire                            write_clock,
    input   wire                            write_reset_n,
    input   wire                            read_enable,
    input   wire                            write_enable,
    input   wire    [DATA_WIDTH-1:0]        write_data,

    output  wire     [DATA_WIDTH-1:0]       read_data,
    output  wire                            read_data_valid,
    output  wire                            full,
    output  wire                            empty
);


generate
    if (XILINX && !FIRST_WORD_FALL_THROUGH) begin
      wire                    xpm_fifo_async_data_valid;
      wire  [DATA_WIDTH-1:0]  xpm_fifo_async_dout;
      wire                    xpm_fifo_async_empty;
      wire                    xpm_fifo_async_full;
      wire  [DATA_WIDTH-1:0]  xpm_fifo_async_din;
      wire                    xpm_fifo_async_rd_clk;
      wire                    xpm_fifo_async_rd_en;
      wire                    xpm_fifo_async_rst;
      wire                    xpm_fifo_async_wr_clk;
      wire                    xpm_fifo_async_wr_en;

      xpm_fifo_async #(
        .CASCADE_HEIGHT        (0),       
        .CDC_SYNC_STAGES       (2),      
        .DOUT_RESET_VALUE      ("0"),   
        .ECC_MODE              ("no_ecc"),      
        .FIFO_MEMORY_TYPE      ("auto"),
        .FIFO_READ_LATENCY     (PIPELINED_MEMORY),
        .FIFO_WRITE_DEPTH      (DATA_DEPTH),
        .FULL_RESET_VALUE      (0),   
        .PROG_EMPTY_THRESH     (10), 
        .PROG_FULL_THRESH      (10),  
        .RD_DATA_COUNT_WIDTH   (1),
        .READ_DATA_WIDTH       (DATA_WIDTH),
        .READ_MODE             ("std"),        
        .RELATED_CLOCKS        (0),       
        .SIM_ASSERT_CHK        (0),
        .USE_ADV_FEATURES      ("1707"),
        .WAKEUP_TIME           (0),          
        .WRITE_DATA_WIDTH      (DATA_WIDTH),    
        .WR_DATA_COUNT_WIDTH   (1)   
      )
      xpm_fifo_async_inst(
        .almost_empty          (),
        .almost_full           (),
        .data_valid            (xpm_fifo_async_data_valid),
        .dbiterr               (),
        .dout                  (xpm_fifo_async_dout),
        .empty                 (xpm_fifo_async_empty),
        .full                  (xpm_fifo_async_full),
        .overflow              (),
        .prog_empty            (),
        .prog_full             (),
        .rd_data_count         (),
        .rd_rst_busy           (),
        .sbiterr               (),
        .underflow             (),
        .wr_ack                (),
        .wr_data_count         (),
        .wr_rst_busy           (),
        .din                   (xpm_fifo_async_din),
        .injectdbiterr         (1'b0),
        .injectsbiterr         (1'b0),
        .rd_clk                (xpm_fifo_async_rd_clk),
        .rd_en                 (xpm_fifo_async_rd_en),
        .rst                   (xpm_fifo_async_rst),
        .sleep                 (1'b0),
        .wr_clk                (xpm_fifo_async_wr_clk),
        .wr_en                 (xpm_fifo_async_wr_en)
      );
      

      assign  read_data_valid       = xpm_fifo_async_data_valid;
      assign  read_data             = xpm_fifo_async_dout;
      assign  full                  = xpm_fifo_async_full;
      assign  empty                 = xpm_fifo_async_empty;

      assign  xpm_fifo_async_din    = write_data;
      assign  xpm_fifo_async_rd_clk = read_clock;
      assign  xpm_fifo_async_rd_en  = read_enable;
      assign  xpm_fifo_async_rst    = !write_reset_n;
      assign  xpm_fifo_async_wr_en  = write_enable;
      assign  xpm_fifo_async_wr_clk = write_clock;
    end
    else if (XILINX && FIRST_WORD_FALL_THROUGH) begin
      wire                    xpm_fifo_async_data_valid;
      wire  [DATA_WIDTH-1:0]  xpm_fifo_async_dout;
      wire                    xpm_fifo_async_empty;
      wire                    xpm_fifo_async_full;
      wire  [DATA_WIDTH-1:0]  xpm_fifo_async_din;
      wire                    xpm_fifo_async_rd_clk;
      wire                    xpm_fifo_async_rd_en;
      wire                    xpm_fifo_async_rst;
      wire                    xpm_fifo_async_wr_clk;
      wire                    xpm_fifo_async_wr_en;

      xpm_fifo_async #(
        .CASCADE_HEIGHT        (0),       
        .CDC_SYNC_STAGES       (2),      
        .DOUT_RESET_VALUE      ("0"),   
        .ECC_MODE              ("no_ecc"),      
        .FIFO_MEMORY_TYPE      ("auto"),
        .FIFO_READ_LATENCY     (0),
        .FIFO_WRITE_DEPTH      (DATA_DEPTH),
        .FULL_RESET_VALUE      (0),   
        .PROG_EMPTY_THRESH     (10), 
        .PROG_FULL_THRESH      (10),  
        .RD_DATA_COUNT_WIDTH   (1),
        .READ_DATA_WIDTH       (DATA_WIDTH),
        .READ_MODE             ("fwft"),        
        .RELATED_CLOCKS        (0),       
        .SIM_ASSERT_CHK        (0),
        .USE_ADV_FEATURES      ("1707"),
        .WAKEUP_TIME           (0),          
        .WRITE_DATA_WIDTH      (DATA_WIDTH),    
        .WR_DATA_COUNT_WIDTH   (1)   
      )
      xpm_fifo_async_inst(
        .almost_empty          (),
        .almost_full           (),
        .data_valid            (xpm_fifo_async_data_valid),
        .dbiterr               (),
        .dout                  (xpm_fifo_async_dout),
        .empty                 (xpm_fifo_async_empty),
        .full                  (xpm_fifo_async_full),
        .overflow              (),
        .prog_empty            (),
        .prog_full             (),
        .rd_data_count         (),
        .rd_rst_busy           (),
        .sbiterr               (),
        .underflow             (),
        .wr_ack                (),
        .wr_data_count         (),
        .wr_rst_busy           (),
        .din                   (xpm_fifo_async_din),
        .injectdbiterr         (1'b0),
        .injectsbiterr         (1'b0),
        .rd_clk                (xpm_fifo_async_rd_clk),
        .rd_en                 (xpm_fifo_async_rd_en),
        .rst                   (xpm_fifo_async_rst),
        .sleep                 (1'b0),
        .wr_clk                (xpm_fifo_async_wr_clk),
        .wr_en                 (xpm_fifo_async_wr_en)
      );


      assign  read_data_valid       = xpm_fifo_async_data_valid;
      assign  read_data             = xpm_fifo_async_dout;
      assign  full                  = xpm_fifo_async_full;
      assign  empty                 = xpm_fifo_async_empty;

      assign  xpm_fifo_async_din    = write_data;
      assign  xpm_fifo_async_rd_clk = read_clock;
      assign  xpm_fifo_async_rd_en  = read_enable;
      assign  xpm_fifo_async_rst    = !write_reset_n;
      assign  xpm_fifo_async_wr_en  = write_enable;
      assign  xpm_fifo_async_wr_clk = write_clock;
    end
    else begin
        wire                    generic_asynchronous_fifo_read_clock;
        wire                    generic_asynchronous_fifo_read_reset_n;
        wire                    generic_asynchronous_fifo_write_clock;
        wire                    generic_asynchronous_fifo_write_reset_n;
        wire                    generic_asynchronous_fifo_read_enable;
        wire                    generic_asynchronous_fifo_write_enable;
        wire  [DATA_WIDTH-1:0]  generic_asynchronous_fifo_write_data;
        wire  [DATA_WIDTH-1:0]  generic_asynchronous_fifo_read_data;
        wire                    generic_asynchronous_fifo_read_data_valid;
        wire                    generic_asynchronous_fifo_full;
        wire                    generic_asynchronous_fifo_empty;


        generic_asynchronous_fifo#(
            .DATA_WIDTH               (DATA_WIDTH),
            .DATA_DEPTH               (DATA_DEPTH),
            .FIRST_WORD_FALL_THROUGH  (FIRST_WORD_FALL_THROUGH),
            .PIPELINED_MEMORY         (PIPELINED_MEMORY)
        )generic_asynchronous_fifo(
          .read_clock        (generic_asynchronous_fifo_read_clock),
          .read_reset_n      (generic_asynchronous_fifo_read_reset_n),
          .write_clock       (generic_asynchronous_fifo_write_clock),
          .write_reset_n     (generic_asynchronous_fifo_write_reset_n),
          .read_enable       (generic_asynchronous_fifo_read_enable),
          .write_enable      (generic_asynchronous_fifo_write_enable),
          .write_data        (generic_asynchronous_fifo_write_data),
          
          .read_data         (generic_asynchronous_fifo_read_data),
          .read_data_valid   (generic_asynchronous_fifo_read_data_valid),
          .full              (generic_asynchronous_fifo_full),
          .empty             (generic_asynchronous_fifo_empty)
        );


        assign  read_data                               = generic_asynchronous_fifo_read_data;
        assign  read_data_valid                         = generic_asynchronous_fifo_read_data_valid;
        assign  full                                    = generic_asynchronous_fifo_full;
        assign  empty                                   = generic_asynchronous_fifo_empty;

        assign  generic_asynchronous_fifo_read_clock    = read_clock;
        assign  generic_asynchronous_fifo_read_reset_n  = read_reset_n;
        assign  generic_asynchronous_fifo_write_clock   = write_clock;
        assign  generic_asynchronous_fifo_write_reset_n = write_reset_n;
        assign  generic_asynchronous_fifo_read_enable   = read_enable;
        assign  generic_asynchronous_fifo_write_enable  = write_enable;
        assign  generic_asynchronous_fifo_write_data    = write_data;
    end
endgenerate

endmodule