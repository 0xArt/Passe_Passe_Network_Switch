`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/29/2023
// Design Name:
// Module Name: udp_receieve_handler
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
module que_slot_receieve_handler(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire    [7:0]   data,
    input   wire            data_enable,
    input   wire            good_packet,
    input   wire            bad_packet,
    input   wire            push_data_enable,

    output  reg             fifo_reset_n,
    output  reg             ready,
    output  reg             push_data_ready,
    output  reg     [8:0]   push_data,
    output  reg             push_data_valid
);


localparam logic [15:0] TIMEOUT_LIMIT       = 16'h0008;

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
    S_IDLE,
    S_ADVERTISTE,
    S_PUSH_DATA,
    S_WAIT_WITH_PUSH,
    S_WAIT
} state_type;

state_type          _state;
state_type          state;
logic               _push_data_ready;
logic               _ready;
logic   [8:0]       _push_data;
logic               _push_data_valid;
logic               _fifo_reset_n;
logic               _is_first_byte;
reg                 is_first_byte;
logic   [8:0]       _wait_data;
reg     [8:0]       wait_data;


assign  timeout_cycle_timer_clock       =   clock;
assign  timeout_cycle_timer_reset_n     =   reset_n;
assign  timeout_cycle_timer_enable      =   1;
assign  timeout_cycle_timer_count       =   TIMEOUT_LIMIT;


always_comb begin
    _state                          =   state;
    _is_first_byte                  =   is_first_byte;
    _push_data_ready                =   push_data_ready;
    _ready                          =   ready;
    _push_data[7:0]                 =   push_data[7:0];
    _push_data[8]                   =   is_first_byte;
    _wait_data                      =   wait_data;
    _push_data_valid                =   0;
    _fifo_reset_n                   =   1;
    timeout_cycle_timer_load_count  =   0;

    case (state)
        S_IDLE: begin
            _ready          =   0;
            _is_first_byte  =   1;

            if (bad_packet) begin
                _fifo_reset_n = 0;
            end
            else if (good_packet) begin
                _state                  =   S_ADVERTISTE;
            end
        end
        S_ADVERTISTE:  begin
            _ready                          =   1;
            timeout_cycle_timer_load_count  =   1;

            if (enable && push_data_enable) begin
                _state              =   S_PUSH_DATA;
                _push_data_ready    =   1;
            end
        end
        S_PUSH_DATA: begin
            if (timeout_cycle_timer_expired) begin
                _state              =   S_IDLE;
                _push_data_ready    =   0;
            end
            if (push_data_enable) begin
                if (enable) begin
                    _push_data_ready                = 1;

                    if (data_enable) begin
                        _push_data[7:0]                 =   data;
                        _push_data_valid                =   1;
                        timeout_cycle_timer_load_count  =   1;

                        if (is_first_byte) begin
                            _is_first_byte  =   0;
                        end
                    end
                end
                else begin
                    _push_data_ready    =   0;
                end
            end
            else begin
                _push_data_ready    =   0;

                if (data_enable) begin
                    _wait_data  =   data;
                    _state      =   S_WAIT_WITH_PUSH;
                end
                else begin
                    _state      =   S_WAIT;
                end
            end
        end
        S_WAIT_WITH_PUSH: begin
            if (push_data_enable) begin
                _push_data_ready                =   1;
                _push_data[7:0]                 =   wait_data;
                _push_data_valid                =   1;
                timeout_cycle_timer_load_count  =   1;
                _state                          =   S_PUSH_DATA;
            end
        end
        S_WAIT: begin
            if (push_data_enable) begin
                _push_data_ready                =   1;
                timeout_cycle_timer_load_count  =   1;
                _state                          =   S_PUSH_DATA;
            end
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        push_data                   <=  0;
        push_data_valid             <=  0;
        fifo_reset_n                <=  0;
        push_data_ready             <=  0;
        ready                       <=  0;
        is_first_byte               <=  0;
        wait_data                   <=  0;
    end
    else begin
        state                       <=  _state;
        push_data                   <=  _push_data;
        push_data_valid             <=  _push_data_valid;
        fifo_reset_n                <=  _fifo_reset_n;
        push_data_ready             <=  _push_data_ready;
        ready                       <=  _ready;
        is_first_byte               <=  _is_first_byte;
        wait_data                   <=  _wait_data;
    end
end

endmodule