`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Phantom Motorsports
//              www.phantomtuned.com
// Engineer:    Artin Isagholian
//
// Create Date: 04/27/2023
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
module udp_receieve_handler(
    input   wire            clock,
    input   wire            reset_n,
    input   wire            enable,
    input   wire    [7:0]   data,
    input   wire            data_enable,
    input   wire            good_packet,
    input   wire            bad_packet,
    input   wire    [15:0]  udp_destination,
    input   wire            push_data_enable,

    output  reg             fifo_reset_n,
    output  reg             ready,
    output  reg             push_data_ready,
    output  reg     [8:0]   push_data,
    output  reg             push_data_valid
);

typedef enum
{
    S_IDLE,
    S_ADVERTISTE,
    S_PUSH_UDP_DESTINATION_MSB,
    S_PUSH_UDP_DESTINATION_LSB,
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
logic   [15:0]      _saved_udp_destination;
reg     [15:0]      saved_udp_destination;
logic   [7:0]       _wait_data;
reg     [7:0]       wait_data;


always_comb begin
    _state                          =   state;
    _saved_udp_destination          =   saved_udp_destination;
    _push_data_ready                =   push_data_ready;
    _ready                          =   ready;
    _push_data                      =   push_data;
    _wait_data                      =   wait_data;
    _push_data_valid                =   0;
    _fifo_reset_n                   =   1;

    case (state)
        S_IDLE: begin
            _ready  =   0;

            if (bad_packet) begin
                _fifo_reset_n = 0;
            end
            else if (good_packet) begin
                _state                  =   S_ADVERTISTE;
                _saved_udp_destination  =   udp_destination;
            end
        end
        S_ADVERTISTE:  begin
            _ready  =   1;

            if (enable) begin
                _state  =   S_PUSH_UDP_DESTINATION_MSB;
            end
        end
        S_PUSH_UDP_DESTINATION_MSB: begin
            if (enable && push_data_enable) begin
                _push_data          =   {1'b1,saved_udp_destination[15:8]};
                _push_data_valid    =   1;
                _state              =   S_PUSH_UDP_DESTINATION_LSB;
            end
        end
        S_PUSH_UDP_DESTINATION_LSB: begin
            if (enable && push_data_enable) begin
                _push_data          =   {1'b0,saved_udp_destination[7:0]};
                _push_data_valid    =   1;
                _state              =   S_PUSH_DATA;
                _push_data_ready    =   1;
            end
        end
        S_PUSH_DATA: begin
            if (push_data_enable) begin
                if (enable) begin
                    _push_data_ready    =   1;

                    if (data_enable) begin
                        _push_data          =   {1'b0,data};
                        _push_data_valid    =   1;
                    end
                    else begin
                        _state              =   S_IDLE;
                        _push_data_ready    =   0;
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
                _push_data_ready    =   1;
                _push_data[7:0]     =   wait_data;
                _push_data_valid    =   1;
                _state              =   S_PUSH_DATA;
            end
        end
        S_WAIT: begin
            if (push_data_enable) begin
                _push_data_ready    =   1;
                _state              =   S_PUSH_DATA;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        saved_udp_destination       <=  0;
        push_data                   <=  0;
        push_data_valid             <=  0;
        fifo_reset_n                <=  0;
        push_data_ready             <=  0;
        ready                       <=  0;
        wait_data                   <=  0;
    end
    else begin
        state                       <=  _state;
        saved_udp_destination       <=  _saved_udp_destination;
        push_data                   <=  _push_data;
        push_data_valid             <=  _push_data_valid;
        fifo_reset_n                <=  _fifo_reset_n;
        push_data_ready             <=  _push_data_ready;
        ready                       <=  _ready;
        wait_data                   <=  _wait_data;
    end
end

endmodule