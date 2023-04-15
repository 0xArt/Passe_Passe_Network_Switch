`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/12/2023
// Design Name:
// Module Name: ethernet_packet_parser
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
module ethernet_packet_parser#(
    parameter RECEIVE_QUE_SLOTS = 1
)(
    input   wire                            clock,
    input   wire                            reset_n,
    input   wire    [7:0]                   data,
    input   wire                            data_enable,
    input   wire    [7:0]                   checksum_data,
    input   wire                            checksum_data_enable,
    input   wire    [RECEIVE_QUE_SLOTS-1:0] recieve_slot_enable,

    output  reg                             checksum_data_valid,
    output  reg     [7:0]                   packet_data,
    output  reg     [RECEIVE_QUE_SLOTS-1:0] packet_data_valid
);


typedef enum
{
    S_IDLE,
    S_PREAMBLE,
    S_START_OF_FRAME,
    S_MAC_DESTINATION,
    S_DROP_PACKET,
    S_FINISH
} state_type;

integer          i;
reg [7:0]        process_counter;
reg [7:0]        _process_counter;
reg [1:0][7:0]   delayed_data;
reg [1:0][7:0]   _delayed_data;
reg              _checksum_data_ready;
reg              _packet_data_valid;
reg [7:0]        _packet_data;
reg              _checksum_data_valid;

state_type  _state;
state_type  state;

always_comb begin
    _state                  =   state;
    _process_counter        =   process_counter;
    _delayed_data[1]        =   delayed_data[0];
    _delayed_data[0]        =   data;
    _checksum_data_valid    =   checksum_data_valid;

    case (state)
        S_IDLE: begin
            if (data_enable) begin
                if (data == 8'h55)  begin
                    if (|recieve_slot_enable == 0) begin
                        _state       = S_DROP_PACKET;
                    end
                    else begin
                        _state           = S_PREAMBLE;
                        _process_counter = 6;
                    end
                end
            end
        end
        S_PREAMBLE: begin
            if (data_enable) begin
                if (data ==  8'h55) begin
                    _process_counter = process_counter - 1;
                    if(process_counter == 0) begin
                        _state = S_START_OF_FRAME;
                    end
                end
                else begin
                    _state = S_DROP_PACKET;
                end
            end
        end
        S_START_OF_FRAME: begin
            if (data_enable) begin
                if (data ==  8'hD5) begin
                    _state           = S_MAC_DESTINATION;
                    _process_counter = 6;
                end
                else begin
                    _state = S_DROP_PACKET;
                end
            end
        end
        S_MAC_DESTINATION: begin
            //todo
        end
    endcase

end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <= S_IDLE;
        process_counter             <= 0;
        for (i=0;i< 2;i++) begin
            delayed_data[i]         <= 0;
        end
        checksum_data_valid         <= 0;
        packet_data                 <= 0;
        packet_data_valid           <= 0;
    end
    else begin
        state                       <= _state;
        process_counter             <= _process_counter;
        delayed_data                <= _delayed_data;
        checksum_data_valid         <= _checksum_data_valid;
        packet_data                 <= _packet_data;
        packet_data_valid           <= _packet_data_valid;
    end
end


endmodule