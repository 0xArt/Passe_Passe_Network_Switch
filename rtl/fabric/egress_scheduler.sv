`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     circuitden
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//              www.circuitden.com
//
// Create Date: 07/21/2026
// Module Name: egress_scheduler
// Description: frame granular round robin arbiter for one egress port. locks
//              onto one ingress per frame and muxes its broadcast beat bus
//              into the egress transmit fifo. grants are only given while the
//              fifo is ready, which implements drop at frame start for a
//              congested egress. a grant whose request disappears before
//              streaming (the ingress pruned this egress after its grant
//              window closed) is released without passing any beats
///
// EDUCATIONAL USE ONLY
//
// This source file is provided solely for educational, research, and non-commercial purposes.
//
// Commercial use, redistribution, sublicensing, modification for commercial products,
// or incorporation into proprietary software or hardware is strictly prohibited without prior
// written permission and a valid commercial license from the original creator.
//
// Unauthorized commercial use violates intellectual property and copyright laws.
//
// For licensing inquiries and commercial permissions, contact the creator directly.
//
//////////////////////////////////////////////////////////////////////////////////
module egress_scheduler#(
    parameter NUMBER_OF_PORTS   = 4,
    parameter FABRIC_DATA_BYTES = 1
)(
    input   wire                                                                clock,
    input   wire                                                                reset_n,
    input   wire    [NUMBER_OF_PORTS-1:0]                                       request,
    input   wire    [NUMBER_OF_PORTS-1:0][(FABRIC_DATA_BYTES*8)-1:0]            ingress_data,
    input   wire    [NUMBER_OF_PORTS-1:0]                                       ingress_first,
    input   wire    [NUMBER_OF_PORTS-1:0]                                       ingress_last,
    input   wire    [NUMBER_OF_PORTS-1:0][$clog2(FABRIC_DATA_BYTES+1)-1:0]      ingress_byte_count,
    input   wire    [NUMBER_OF_PORTS-1:0]                                       ingress_enable,
    input   wire                                                                transmit_ready,

    output  reg     [NUMBER_OF_PORTS-1:0]                                       grant,
    output  logic   [(FABRIC_DATA_BYTES*8)-1:0]                                 transmit_data,
    output  logic                                                               transmit_first,
    output  logic                                                               transmit_last,
    output  logic   [$clog2(FABRIC_DATA_BYTES+1)-1:0]                           transmit_byte_count,
    output  logic                                                               transmit_valid
);

typedef enum
{
    S_IDLE,
    S_LOCKED
} state_type;

integer i;

state_type                                  _state;
state_type                                  state;
logic       [NUMBER_OF_PORTS-1:0]           _grant;
reg         [$clog2(NUMBER_OF_PORTS)-1:0]   source_select;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   _source_select;
reg         [$clog2(NUMBER_OF_PORTS)-1:0]   rr_pointer;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   _rr_pointer;

logic                                       request_found_high;
logic                                       request_found_low;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   request_select_high;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   request_select_low;
logic                                       request_found;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]   request_select;

always_comb begin
    _state          = state;
    _grant          = grant;
    _source_select  = source_select;
    _rr_pointer     = rr_pointer;

    request_found_high  = '0;
    request_found_low   = '0;
    request_select_high = '0;
    request_select_low  = '0;

    for (i=0; i<NUMBER_OF_PORTS; i=i+1) begin
        if (!request_found_high && (i > rr_pointer) && request[i]) begin
            request_select_high = i;
            request_found_high  = 1'b1;
        end
        if (!request_found_low && (i <= rr_pointer) && request[i]) begin
            request_select_low  = i;
            request_found_low   = 1'b1;
        end
    end

    request_found   = request_found_high || request_found_low;
    request_select  = request_found_high ? request_select_high : request_select_low;

    transmit_data       = ingress_data[source_select];
    transmit_first      = ingress_first[source_select];
    transmit_last       = ingress_last[source_select];
    transmit_byte_count = ingress_byte_count[source_select];
    transmit_valid      = (state == S_LOCKED) && request[source_select] && ingress_enable[source_select];

    case (state)
        S_IDLE: begin
            if (request_found && transmit_ready) begin
                _grant                  = '0;
                _grant[request_select]  = 1'b1;
                _source_select          = request_select;
                _rr_pointer             = request_select;
                _state                  = S_LOCKED;
            end
        end
        S_LOCKED: begin
            //frame complete, or the ingress pruned this egress after a late
            //grant. either way release the lock
            if ((transmit_valid && ingress_last[source_select]) || !request[source_select]) begin
                _grant  = '0;
                _state  = S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state           <= S_IDLE;
        grant           <= '0;
        source_select   <= '0;
        rr_pointer      <= '0;
    end
    else begin
        state           <= _state;
        grant           <= _grant;
        source_select   <= _source_select;
        rr_pointer      <= _rr_pointer;
    end
end

endmodule
