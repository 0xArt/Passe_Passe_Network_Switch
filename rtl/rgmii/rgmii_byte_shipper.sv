`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
// 
// Create Date: 01/26/2024 07:07:33 PM
// Design Name: 
// Module Name: rgmii_byte_shipper
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
module rgmii_byte_shipper #(
    parameter XILINX                    = 0,
    parameter INTER_PACKET_GAP_CYCLES   = 10
)(
    input   wire            clock,
    input   wire            reset_n,
    input   wire    [8:0]   data,
    input   wire            data_enable,

    output  logic           data_ready,
    output  wire    [3:0]   shipped_data,
    output  wire            shipped_data_valid
);

localparam logic [15:0] TIMEOUT_LIMIT       = 16'h004;

wire            stage_fifo_clock;
logic           stage_fifo_reset_n;
logic           stage_fifo_read_enable;
wire            stage_fifo_write_enable;
wire    [7:0]   stage_fifo_write_data;

wire    [7:0]   stage_fifo_read_data;
wire            stage_fifo_read_data_valid;
wire            stage_fifo_full;
wire            stage_fifo_empty;


synchronous_fifo
#(.DATA_WIDTH               (8),
  .DATA_DEPTH               (2048),
  .FIRST_WORD_FALL_THROUGH  (1),
  .XILINX                   (XILINX)                
) stage_fifo(
    .clock              (stage_fifo_clock),
    .reset_n            (stage_fifo_reset_n),
    .read_enable        (stage_fifo_read_enable),
    .write_enable       (stage_fifo_write_enable),
    .write_data         (stage_fifo_write_data),

    .read_data          (stage_fifo_read_data),
    .read_data_valid    (stage_fifo_read_data_valid),
    .full               (stage_fifo_full),
    .empty              (stage_fifo_empty)
);


wire            data_ddr_output_buffer_clock;
wire            data_ddr_output_buffer_reset_n;
wire    [7:0]   data_ddr_output_buffer_ddr_input;

wire    [3:0]   data_ddr_output_buffer_ddr_output;

ddr_output_buffer#(
  .OUTPUT_WIDTH             (4),
  .XILINX                   (XILINX)
)data_ddr_output_buffer(
    .clock          (data_ddr_output_buffer_clock),
    .reset_n        (data_ddr_output_buffer_reset_n),
    .ddr_input      (data_ddr_output_buffer_ddr_input),

    .ddr_output     (data_ddr_output_buffer_ddr_output)
);


wire            data_valid_ddr_output_buffer_clock;
wire            data_valid_ddr_output_buffer_reset_n;
wire    [1:0]   data_valid_ddr_output_buffer_ddr_input;

wire            data_valid__ddr_output_buffer_ddr_output;

ddr_output_buffer#(
  .OUTPUT_WIDTH             (1),
  .XILINX                   (XILINX)
)data_valid_ddr_output_buffer(
    .clock          (data_valid_ddr_output_buffer_clock),
    .reset_n        (data_valid_ddr_output_buffer_reset_n),
    .ddr_input      (data_valid_ddr_output_buffer_ddr_input),

    .ddr_output     (data_valid__ddr_output_buffer_ddr_output)
);


wire            timeout_cycle_timer_clock;
wire            timeout_cycle_timer_reset_n;
wire            timeout_cycle_timer_enable;
logic           timeout_cycle_timer_load_count;
wire  [15:0]    timeout_cycle_timer_count;
wire            timeout_cycle_timer_expired;

cycle_timer timeout_cycle_timer(
    .clock      (timeout_cycle_timer_clock),
    .reset_n    (timeout_cycle_timer_reset_n),
    .enable     (timeout_cycle_timer_enable),
    .load_count (timeout_cycle_timer_load_count),
    .count      (timeout_cycle_timer_count),

    .expired    (timeout_cycle_timer_expired)
);


typedef enum
{
    S_FIND_START_BIT,
    S_STAGE,
    S_PREMABLE,
    S_START_OF_FRAME,
    S_FRAME,
    S_GAP
} state_type;

state_type      state;
state_type      _state;
reg     [7:0]   stage_data;
logic   [7:0]   _stage_data;
reg             stage_data_valid;
logic           _stage_data_valid;
reg     [7:0]   counter;
logic   [7:0]   _counter;
reg     [7:0]   frame_data;
logic   [7:0]   _frame_data;
reg             frame_data_valid;
logic           _frame_data_valid;
reg             stage_fifo_flush;
logic           _stage_fifo_flush;


assign  stage_fifo_clock                            = clock;
assign  stage_fifo_write_enable                     = stage_data_valid;
assign  stage_fifo_write_data                       = stage_data;

assign  data_ddr_output_buffer_clock                = clock;
assign  data_ddr_output_buffer_reset_n              = reset_n;
assign  data_ddr_output_buffer_ddr_input            = frame_data;

assign  data_valid_ddr_output_buffer_clock          = clock;
assign  data_valid_ddr_output_buffer_reset_n        = reset_n;
assign  data_valid_ddr_output_buffer_ddr_input      = {frame_data_valid,frame_data_valid};

assign  shipped_data                                = data_ddr_output_buffer_ddr_output;
assign  shipped_data_valid                          = data_valid__ddr_output_buffer_ddr_output;

assign  timeout_cycle_timer_clock                   = clock;
assign  timeout_cycle_timer_reset_n                 = reset_n;
assign  timeout_cycle_timer_enable                  = 1;
assign  timeout_cycle_timer_count                   = TIMEOUT_LIMIT;



always_comb  begin
    _state                          = state;
    _counter                        = counter;
    _stage_data                     = stage_data;
    _frame_data                     = frame_data;
    _frame_data_valid               = 0;
    data_ready                      = 0;
    _stage_data_valid               = 0;
    _stage_fifo_flush               = 0;
    stage_fifo_reset_n              = 1;
    timeout_cycle_timer_load_count  = 0;
    stage_fifo_read_enable          = 0;

    if (stage_fifo_flush || !reset_n) begin
        stage_fifo_reset_n      = 0;
    end


    case (state)
        S_FIND_START_BIT: begin
            _counter                        = 7;
            timeout_cycle_timer_load_count  = 1;

            if (data_enable) begin
                data_ready  = 1;

                if (data[8]) begin
                    _stage_data         = data;
                    _stage_data_valid   = 1;
                    _state              = S_STAGE;
                end
            end
        end
        S_STAGE: begin
            if (data_enable) begin
                if (data[8]) begin
                    _state  =   S_PREMABLE;
                end
                else begin
                    data_ready                      = 1;
                    _stage_data                     = data;
                    _stage_data_valid               = 1;
                    timeout_cycle_timer_load_count  = 1;
                end
            end

            if (timeout_cycle_timer_expired) begin
                if (!stage_fifo_empty) begin
                    _state  = S_PREMABLE;
                end
                else begin
                    _state  = S_FIND_START_BIT;
                end
            end
        end
        S_PREMABLE: begin
            _frame_data         =   8'h55;
            _frame_data_valid   =   1;
            _counter            =   counter - 1;

            if (counter == 0) begin
                _state  =   S_START_OF_FRAME;
            end
        end
        S_START_OF_FRAME: begin
            _counter            =   INTER_PACKET_GAP_CYCLES;
            _frame_data         =   8'hD5;
            _frame_data_valid   =   1;
            _state              =   S_FRAME;
        end
        S_FRAME: begin
            if (stage_fifo_read_data_valid) begin
                _frame_data             = stage_fifo_read_data;
                _frame_data_valid       = 1;
                stage_fifo_read_enable  = 1;
            end
            else begin
                _stage_fifo_flush   = 1;
                _state              = S_GAP;
            end
        end
        S_GAP: begin
            _counter = counter - 1;

            if (counter == 0) begin
                _state  =   S_FIND_START_BIT;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <=  S_FIND_START_BIT;
        stage_data                  <=  0;
        stage_data_valid            <=  0;
        counter                     <=  0;
        frame_data                  <=  0;
        frame_data_valid            <=  0;
        stage_fifo_flush            <=  0;
    end
    else begin
        state                       <=  _state;
        stage_data                  <=  _stage_data;
        stage_data_valid            <=  _stage_data_valid;
        counter                     <=  _counter;
        frame_data                  <=  _frame_data;
        frame_data_valid            <=  _frame_data_valid;
        stage_fifo_flush            <=  _stage_fifo_flush; 
    end
end

endmodule