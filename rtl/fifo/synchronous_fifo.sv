`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 05/25/2023
// Design Name: 
// Module Name: synchronous_fifo
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
module synchronous_fifo#(
    parameter DATA_WIDTH                = 16,
    parameter DATA_DEPTH                = 4096,
    parameter FIRST_WORD_FALL_THROUGH   = 0,
    parameter XILINX                    = 0
)(
    input   wire                            clock,
    input   wire                            reset_n,
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
        wire                        xpm_fifo_sync_data_valid;
        wire    [DATA_WIDTH-1:0]    xpm_fifo_sync_dout;
        wire                        xpm_fifo_sync_empty;
        wire                        xpm_fifo_sync_full;
        wire    [DATA_WIDTH-1:0]    xpm_fifo_sync_din;
        wire                        xpm_fifo_sync_rd_en;
        wire                        xpm_fifo_sync_rst;
        wire                        xpm_fifo_sync_wr_clk;
        wire                        xpm_fifo_sync_wr_en;

        xpm_fifo_sync #(
            .CASCADE_HEIGHT         (0),
            .DOUT_RESET_VALUE       ("0"),
            .ECC_MODE               ("no_ecc"),
            .FIFO_MEMORY_TYPE       ("auto"),
            .FIFO_READ_LATENCY      (0),
            .FIFO_WRITE_DEPTH       (DATA_DEPTH),
            .FULL_RESET_VALUE       (0),
            .PROG_EMPTY_THRESH      (10),
            .PROG_FULL_THRESH       (10),
            .RD_DATA_COUNT_WIDTH    (1),
            .READ_DATA_WIDTH        (DATA_WIDTH),
            .READ_MODE              ("std"),
            .SIM_ASSERT_CHK         (0),
            .USE_ADV_FEATURES       ("1707"),
            .WAKEUP_TIME            (0),
            .WRITE_DATA_WIDTH       (DATA_WIDTH),
            .WR_DATA_COUNT_WIDTH    (1)
        )xpm_fifo_sync_inst(
            .almost_empty           (),
            .almost_full            (),
            .data_valid             (xpm_fifo_sync_data_valid), 
            .dbiterr                (),
            .dout                   (xpm_fifo_sync_dout),
            .empty                  (xpm_fifo_sync_empty),
            .full                   (xpm_fifo_sync_full),
            .overflow               (),
            .prog_empty             (),
            .prog_full              (),
            .rd_data_count          (),
            .rd_rst_busy            (),
            .sbiterr                (),
            .underflow              (),
            .wr_ack                 (),
            .wr_data_count          (),
            .wr_rst_busy            (),
            .din                    (xpm_fifo_sync_din),
            .injectdbiterr          (1'b0),
            .injectsbiterr          (1'b0),
            .rd_en                  (xpm_fifo_sync_rd_en),
            .rst                    (xpm_fifo_sync_rst),
            .sleep                  (1'b0),
            .wr_clk                 (xpm_fifo_sync_wr_clk),
            .wr_en                  (xpm_fifo_sync_wr_en)
        );


        assign  read_data_valid         =   xpm_fifo_sync_data_valid;
        assign  read_data               =   xpm_fifo_sync_dout;
        assign  full                    =   xpm_fifo_sync_full;
        assign  empty                   =   xpm_fifo_sync_empty;

        assign  xpm_fifo_sync_din       =   write_data;
        assign  xpm_fifo_sync_rd_en     =   read_enable;
        assign  xpm_fifo_sync_rst       =   !reset_n;
        assign  xpm_fifo_sync_wr_clk    =   clock;
        assign  xpm_fifo_sync_wr_en     =   write_enable;
    end
    else if (XILINX && FIRST_WORD_FALL_THROUGH) begin
        wire                        xpm_fifo_sync_data_valid;
        wire    [DATA_WIDTH-1:0]    xpm_fifo_sync_dout;
        wire                        xpm_fifo_sync_empty;
        wire                        xpm_fifo_sync_full;
        wire    [DATA_WIDTH-1:0]    xpm_fifo_sync_din;
        wire                        xpm_fifo_sync_rd_en;
        wire                        xpm_fifo_sync_rst;
        wire                        xpm_fifo_sync_wr_clk;
        wire                        xpm_fifo_sync_wr_en;

        xpm_fifo_sync #(
            .CASCADE_HEIGHT         (0),
            .DOUT_RESET_VALUE       ("0"),
            .ECC_MODE               ("no_ecc"),
            .FIFO_MEMORY_TYPE       ("auto"),
            .FIFO_READ_LATENCY      (0),
            .FIFO_WRITE_DEPTH       (DATA_DEPTH),
            .FULL_RESET_VALUE       (0),
            .PROG_EMPTY_THRESH      (10),
            .PROG_FULL_THRESH       (10),
            .RD_DATA_COUNT_WIDTH    (1),
            .READ_DATA_WIDTH        (DATA_WIDTH),
            .READ_MODE              ("fwft"),
            .SIM_ASSERT_CHK         (0),
            .USE_ADV_FEATURES       ("1707"),
            .WAKEUP_TIME            (0),
            .WRITE_DATA_WIDTH       (DATA_WIDTH),
            .WR_DATA_COUNT_WIDTH    (1)
        )xpm_fifo_sync_inst(
            .almost_empty           (),
            .almost_full            (),
            .data_valid             (xpm_fifo_sync_data_valid), 
            .dbiterr                (),
            .dout                   (xpm_fifo_sync_dout),
            .empty                  (xpm_fifo_sync_empty),
            .full                   (xpm_fifo_sync_full),
            .overflow               (),
            .prog_empty             (),
            .prog_full              (),
            .rd_data_count          (),
            .rd_rst_busy            (),
            .sbiterr                (),
            .underflow              (),
            .wr_ack                 (),
            .wr_data_count          (),
            .wr_rst_busy            (),
            .din                    (xpm_fifo_sync_din),
            .injectdbiterr          (1'b0),
            .injectsbiterr          (1'b0),
            .rd_en                  (xpm_fifo_sync_rd_en),
            .rst                    (xpm_fifo_sync_rst),
            .sleep                  (1'b0),
            .wr_clk                 (xpm_fifo_sync_wr_clk),
            .wr_en                  (xpm_fifo_sync_wr_en)
        );
        

        assign  read_data_valid         =   xpm_fifo_sync_data_valid;
        assign  read_data               =   xpm_fifo_sync_dout;
        assign  full                    =   xpm_fifo_sync_full;
        assign  empty                   =   xpm_fifo_sync_empty;

        assign  xpm_fifo_sync_din       =   write_data;
        assign  xpm_fifo_sync_rd_en     =   read_enable;
        assign  xpm_fifo_sync_rst       =   !reset_n;
        assign  xpm_fifo_sync_wr_clk    =   clock;
        assign  xpm_fifo_sync_wr_en     =   write_enable;
    end
    else begin
        wire                        generic_synchronous_fifo_clock;
        wire                        generic_synchronous_fifo_reset_n;
        wire                        generic_synchronous_fifo_read_enable;
        wire                        generic_synchronous_fifo_write_enable;
        wire    [DATA_WIDTH-1:0]    generic_synchronous_fifo_write_data;

        wire    [DATA_WIDTH-1:0]    generic_synchronous_fifo_read_data;
        wire                        generic_synchronous_fifo_read_data_valid;
        wire                        generic_synchronous_fifo_full;
        wire                        generic_synchronous_fifo_empty;

        generic_synchronous_fifo#(
            .DATA_WIDTH               (DATA_WIDTH),
            .DATA_DEPTH               (DATA_DEPTH),
            .FIRST_WORD_FALL_THROUGH  (FIRST_WORD_FALL_THROUGH)
        )generic_synchronous_fifo(
            .clock              (generic_synchronous_fifo_clock),
            .reset_n            (generic_synchronous_fifo_reset_n),
            .read_enable        (generic_synchronous_fifo_read_enable),
            .write_enable       (generic_synchronous_fifo_write_enable),
            .write_data         (generic_synchronous_fifo_write_data),

            .read_data          (generic_synchronous_fifo_read_data),
            .read_data_valid    (generic_synchronous_fifo_read_data_valid),
            .full               (generic_synchronous_fifo_full),
            .empty              (generic_synchronous_fifo_empty)
        );

        
        assign  read_data                               =   generic_synchronous_fifo_read_data;
        assign  read_data_valid                         =   generic_synchronous_fifo_read_data_valid;
        assign  full                                    =   generic_synchronous_fifo_full;
        assign  empty                                   =   generic_synchronous_fifo_empty;

        assign  generic_synchronous_fifo_clock          =   clock;
        assign  generic_synchronous_fifo_reset_n        =   reset_n;
        assign  generic_synchronous_fifo_read_enable    =   read_enable;
        assign  generic_synchronous_fifo_write_enable   =   write_enable;
        assign  generic_synchronous_fifo_write_data     =   write_data;
    end
endgenerate

endmodule