`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 10/27/2023
// Design Name: 
// Module Name: block_ram
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
module block_ram#(
    parameter DATA_WIDTH            = 16,
    parameter DATA_DEPTH            = 4096,
    parameter PIPELINED_OUTPUT      = 0,
    parameter XILINX                = 0
)(
    input   wire                                    clock,
    input   wire                                    reset_n,
    input   wire                                    write_enable,
    input   wire    [DATA_WIDTH-1:0]                write_data,
    input   wire    [$clog2(DATA_DEPTH)-1:0]        write_address,
    input   wire    [$clog2(DATA_DEPTH)-1:0]        read_address,

    output  reg     [DATA_WIDTH-1:0]                read_data
);


generate
    if (XILINX) begin
        localparam READ_LATENCY = PIPELINED_OUTPUT + 1;

        wire    [DATA_WIDTH-1:0]            xpm_memory_sdpram_dina;
        wire    [DATA_WIDTH-1:0]            xpm_memory_sdpram_doutb;
        wire    [$clog2(DATA_DEPTH)-1:0]    xpm_memory_sdpram_addra;
        wire    [$clog2(DATA_DEPTH)-1:0]    xpm_memory_sdpram_addrb;
        wire                                xpm_memory_sdpram_clka;
        wire                                xpm_memory_sdpram_clkb;
        wire                                xpm_memory_sdpram_rstb;
        wire                                xpm_memory_sdpram_wea;


        xpm_memory_sdpram #(
            .ADDR_WIDTH_A           ($clog2(DATA_DEPTH)),        
            .ADDR_WIDTH_B           ($clog2(DATA_DEPTH)),       
            .AUTO_SLEEP_TIME        (0),                     
            .BYTE_WRITE_WIDTH_A     (DATA_WIDTH),
            .CASCADE_HEIGHT         (0),             
            .CLOCKING_MODE          ("common_clock"), 
            .ECC_BIT_RANGE          ("7:0"),          
            .ECC_MODE               ("no_ecc"),            
            .ECC_TYPE               ("none"),             
            .IGNORE_INIT_SYNTH      (0),         
            .MEMORY_INIT_FILE       ("none"),     
            .MEMORY_INIT_PARAM      ("0"),       
            .MEMORY_OPTIMIZATION    ("true"),  
            .MEMORY_PRIMITIVE       ("auto"),     
            .MEMORY_SIZE            (DATA_DEPTH),            
            .MESSAGE_CONTROL        (0),           
            .RAM_DECOMP             ("auto"),           
            .READ_DATA_WIDTH_B      (DATA_WIDTH), 
            .READ_LATENCY_B         (READ_LATENCY),  
            .READ_RESET_VALUE_B     ("0"),      
            .RST_MODE_A             ("SYNC"),           
            .RST_MODE_B             ("SYNC"),           
            .SIM_ASSERT_CHK         (0),             
            .USE_EMBEDDED_CONSTRAINT(0),   
            .USE_MEM_INIT           (1),              
            .USE_MEM_INIT_MMI       (0),           
            .WAKEUP_TIME            ("disable_sleep"),
            .WRITE_DATA_WIDTH_A     (DATA_WIDTH),
            .WRITE_MODE_B           ("no_change"),
            .WRITE_PROTECT          (1)
        )
        xpm_memory_sdpram_inst (
            .dbiterrb       (),
            .doutb          (xpm_memory_sdpram_doutb),
            .sbiterrb       (),
            .addra          (xpm_memory_sdpram_addra),
            .addrb          (xpm_memory_sdpram_addrb),
            .clka           (xpm_memory_sdpram_clka),
            .clkb           (xpm_memory_sdpram_clkb),
            .dina           (xpm_memory_sdpram_dina),
            .ena            (1'b1),
            .enb            (1'b1),
            .injectdbiterra (),
            .injectsbiterra (),
            .regceb         (),
            .rstb           (xpm_memory_sdpram_rstb),
            .sleep          (),
            .wea            (xpm_memory_sdpram_wea)
        );


        assign  read_data               =   xpm_memory_sdpram_doutb;

        assign  xpm_memory_sdpram_dina  =   write_data; 
        assign  xpm_memory_sdpram_addra =   write_address;
        assign  xpm_memory_sdpram_addrb =   read_address;
        assign  xpm_memory_sdpram_clka  =   clock;
        assign  xpm_memory_sdpram_clkb  =   clock;
        assign  xpm_memory_sdpram_rstb  =   !reset_n;
        assign  xpm_memory_sdpram_wea   =   write_enable;
    end
    else begin
        wire                                generic_block_ram_clock;
        wire                                generic_block_ram_reset_n;
        wire                                generic_block_ram_write_enable;
        wire    [DATA_WIDTH-1:0]            generic_block_ram_write_data;
        wire    [$clog2(DATA_DEPTH)-1:0]    generic_block_ram_write_address;
        wire    [$clog2(DATA_DEPTH)-1:0]    generic_block_ram_read_address;

        wire   [DATA_WIDTH-1:0]             generic_block_ram_read_data;

        generic_block_ram#(
                .DATA_WIDTH        (DATA_WIDTH),
                .DATA_DEPTH        (DATA_DEPTH),
                .PIPELINED_OUTPUT  (PIPELINED_OUTPUT)
        )generic_block_ram(
            .clock              (generic_block_ram_clock),
            .reset_n            (generic_block_ram_reset_n),
            .write_enable       (generic_block_ram_write_enable),
            .write_data         (generic_block_ram_write_data),
            .write_address      (generic_block_ram_write_address),
            .read_address       (generic_block_ram_read_address),

            .read_data          (generic_block_ram_read_data)
        );


        assign  read_data                       =   generic_block_ram_read_data;

        assign  generic_block_ram_clock         =   clock;
        assign  generic_block_ram_reset_n       =   reset_n;
        assign  generic_block_ram_write_enable  =   write_enable;
        assign  generic_block_ram_write_data    =   write_data;
        assign  generic_block_ram_write_address =   write_address;
        assign  generic_block_ram_read_address  =   read_address;
    end
endgenerate

endmodule