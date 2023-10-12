`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  www.circuitden.com
// Engineer: Artin Isagholian
//           artinisagholian@gmail.com
//
// Create Date: 04/30/2023
// Design Name:
// Module Name: core_data_orchestrator
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
module core_data_orchestrator#(
    parameter       NUMBER_OF_PORTS     = 2,
    logic [15:0]    TIMEOUT_LIMIT       = 16'h000F,
    parameter       TABLE_DEPTH         = 32
)(
    input   wire                                        clock,
    input   wire                                        reset_n,
    input   wire    [NUMBER_OF_PORTS-1:0]               port_receive_data_enable,
    input   wire    [NUMBER_OF_PORTS-1:0][8:0]          port_receive_data,
    input   wire    [$clog2(NUMBER_OF_PORTS)-1:0]       cam_table_match_index,
    input   wire                                        cam_table_no_match,
    input   wire                                        cam_table_match_enable,

    output  logic   [NUMBER_OF_PORTS-1:0]               port_receive_data_ready,
    output  reg     [8:0]                               port_transmit_data,
    output  reg     [NUMBER_OF_PORTS-1:0]               port_transmit_data_valid,
    output  reg                                         cam_table_match_valid,
    output  reg     [47:0]                              cam_table_write_data,
    output  reg                                         cam_table_write_data_valid,
    output  reg     [$clog2(NUMBER_OF_PORTS)-1:0]       cam_table_index,
    output  reg                                         cam_table_delete_key
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
    S_GET_MAC_DESTINATION,
    S_GET_MAC_SOURCE,
    S_LOOKUP_SOURCE_PORT,
    S_DELETE_OLD_TABLE_ENTRY,
    S_UPDATE_TABLE,
    S_LOOKUP_DESTINATION_PORT,
    S_TRANSMIT_MAC_DESTINATION,
    S_TRANSMIT_MAC_SOURCE,
    S_TRANSMIT_DATA
} state_type;

integer                                         i;
state_type                                      _state;
state_type                                      state;
logic       [8:0]                               _port_transmit_data;
logic       [NUMBER_OF_PORTS-1:0]               _port_transmit_data_valid;
logic       [47:0]                              _cam_table_write_data;
logic                                           _cam_table_write_data_valid;
logic       [47:0]                              _mac_destination;
reg         [47:0]                              mac_destination;
logic       [47:0]                              _mac_source;
reg         [47:0]                              mac_source;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]       _port_select;
reg         [$clog2(NUMBER_OF_PORTS)-1:0]       port_select;
logic       [7:0]                               _process_counter;
reg         [7:0]                               process_counter;
logic       [NUMBER_OF_PORTS-1:0]               _target_transmit_port;
reg         [NUMBER_OF_PORTS-1:0]               target_transmit_port;
logic                                           _cam_table_match_valid;
logic       [$clog2(NUMBER_OF_PORTS)-1:0]       _cam_table_index;
logic                                           _cam_table_delete_key;

assign  timeout_cycle_timer_clock       =   clock;
assign  timeout_cycle_timer_reset_n     =   reset_n;
assign  timeout_cycle_timer_enable      =   1;
assign  timeout_cycle_timer_count       =   TIMEOUT_LIMIT;

always_comb begin
    _state                              =   state;
    _port_transmit_data                 =   port_transmit_data;
    _cam_table_write_data               =   cam_table_write_data;
    _port_select                        =   port_select;
    _mac_source                         =   mac_source;
    _mac_destination                    =   mac_destination;
    _process_counter                    =   process_counter;
    _target_transmit_port               =   target_transmit_port;
    _cam_table_index                    =   cam_table_index;
    _cam_table_match_valid              =   0;
    _port_transmit_data_valid           =   0;
    port_receive_data_ready             =   0;
    _cam_table_write_data_valid         =   0;
    timeout_cycle_timer_load_count      =   0;
    _cam_table_delete_key               =   0;

    case (state)
        S_FIND_START_BIT: begin
            _process_counter    =   5;

            if (port_receive_data_enable[port_select]) begin
                port_receive_data_ready[port_select]   = 1;

                if (port_receive_data[port_select][8]) begin
                    _mac_destination[47:8]  =   mac_destination[39:0];
                    _mac_destination[7:0]   =   port_receive_data[port_select];
                    _state                  =   S_GET_MAC_DESTINATION;
                end
            end
            else begin
                _port_select                            =   port_select + 1;
            end
        end
        S_GET_MAC_DESTINATION: begin
            if (port_receive_data_enable[port_select] ) begin
                port_receive_data_ready[port_select]    = 1;
                _mac_destination[47:8]                  = mac_destination[39:0];
                _mac_destination[7:0]                   = port_receive_data[port_select];
                _process_counter                        = process_counter - 1;
            end
            if(process_counter == 0) begin
                _process_counter    =   6;
                _state              =   S_GET_MAC_SOURCE;
            end
        end
        S_GET_MAC_SOURCE: begin
            if (port_receive_data_enable[port_select] ) begin
                port_receive_data_ready[port_select]    = 1;
                _mac_source[47:8]                       = mac_source[39:0];
                _mac_source[7:0]                        = port_receive_data[port_select];
                _process_counter                        = process_counter - 1;
            end
            if(process_counter == 0) begin
                _state                      =   S_LOOKUP_SOURCE_PORT;
            end
        end
        S_LOOKUP_SOURCE_PORT: begin
            case (process_counter)
                0: begin
                    _cam_table_write_data   =   mac_source;
                    _cam_table_match_valid  =   1;
                    _process_counter        =   1;
                end
                1: begin
                    if (cam_table_no_match) begin
                        _state              =  S_UPDATE_TABLE;
                        _process_counter    =   0;
                    end
                    if (cam_table_match_enable) begin
                        _process_counter    =   0;

                        if (port_select ==  cam_table_match_index) begin
                            _state          =  S_LOOKUP_DESTINATION_PORT;
                        end
                        else begin
                            _state          =   S_DELETE_OLD_TABLE_ENTRY;
                        end
                    end
                end
            endcase
        end
        S_DELETE_OLD_TABLE_ENTRY: begin
            _cam_table_write_data       =   mac_source;
            _cam_table_delete_key       =   1;
            _state                      =   S_UPDATE_TABLE;
        end
        S_UPDATE_TABLE: begin
            _process_counter            =   0;
            _cam_table_write_data       =   mac_source;
            _cam_table_index            =   port_select;
            _cam_table_write_data_valid =   1;
            _state                      =   S_LOOKUP_DESTINATION_PORT;
        end
        S_LOOKUP_DESTINATION_PORT: begin
            case (process_counter)
                0: begin
                    _cam_table_write_data   =   mac_destination;
                    _cam_table_match_valid  =   1;
                    _process_counter        =   1;
                end
                1: begin
                    if (cam_table_no_match) begin
                        _target_transmit_port                               =  '1;
                        _target_transmit_port[port_select]                  =   0;
                        _port_transmit_data_valid                           =  '1;
                        _port_transmit_data_valid[port_select]              =   0;
                        _port_transmit_data                                 =  {1'b1,mac_destination[47:40]};
                        _mac_destination                                    =  {mac_destination[39:0],8'h00};
                        _process_counter                                    =  4;
                        _state                                              =  S_TRANSMIT_MAC_DESTINATION;
                    end
                    if (cam_table_match_enable) begin
                        _target_transmit_port                               =  1 << cam_table_match_index;
                        _port_transmit_data_valid                           =  1 << cam_table_match_index;
                        _port_transmit_data                                 =  {1'b1,mac_destination[47:40]};
                        _mac_destination                                    =  {mac_destination[39:0],8'h00};
                        _process_counter                                    =  4;
                        _state                                              =  S_TRANSMIT_MAC_DESTINATION;
                    end
                end
            endcase
        end
        S_TRANSMIT_MAC_DESTINATION: begin
            _port_transmit_data         =  {1'b0,mac_destination[47:40]};
            _port_transmit_data_valid   =   target_transmit_port;
            _mac_destination            =  {mac_destination[39:0],8'h00};
            _process_counter            =  process_counter - 1;

            if(process_counter == 0) begin
                _process_counter    = 5;
                _state              = S_TRANSMIT_MAC_SOURCE;
            end
        end
        S_TRANSMIT_MAC_SOURCE: begin
            _port_transmit_data         =  {1'b0,mac_source[47:40]};
            _port_transmit_data_valid   =   target_transmit_port;
            _mac_source                 =  {mac_source[39:0],8'h00};
            _process_counter            =  process_counter - 1;

            if (process_counter == 0) begin
                _state                                  = S_TRANSMIT_DATA;
                timeout_cycle_timer_load_count          = 1;
            end
        end
        S_TRANSMIT_DATA: begin
            if (port_receive_data_enable[port_select]) begin
                timeout_cycle_timer_load_count          = 1;

                if (port_receive_data[port_select][8]) begin
                    _port_select                =   port_select + 1;
                    _state                      =   S_FIND_START_BIT;
                end
                else begin
                    port_receive_data_ready[port_select]    =   1;
                    _port_transmit_data                     =   {1'b0,port_receive_data[port_select][7:0]};
                    _port_transmit_data_valid               =   target_transmit_port;
                end
            end

            if (timeout_cycle_timer_expired) begin
                _port_transmit_data_valid   =   0;
                _port_select                =   port_select + 1;
                _state                      =   S_FIND_START_BIT;
            end
        end
    endcase
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        state                       <=  S_FIND_START_BIT;
        port_transmit_data          <=  0;
        port_transmit_data_valid    <=  0;
        cam_table_write_data        <=  0;
        cam_table_write_data_valid  <=  0;
        cam_table_match_valid       <=  0;
        mac_source                  <=  0;
        mac_destination             <=  0;
        port_select                 <=  0;
        process_counter             <=  0;
        target_transmit_port        <=  0;
        cam_table_index             <=  0;
        cam_table_delete_key        <=  0;
    end
    else begin
        state                       <=  _state;
        port_transmit_data          <=  _port_transmit_data;
        port_transmit_data_valid    <=  _port_transmit_data_valid;
        cam_table_write_data        <=  _cam_table_write_data;
        cam_table_write_data_valid  <=  _cam_table_write_data_valid;
        cam_table_match_valid       <=  _cam_table_match_valid;
        mac_source                  <=  _mac_source;
        mac_destination             <=  _mac_destination;
        port_select                 <=  _port_select;
        process_counter             <=  _process_counter;
        target_transmit_port        <=  _target_transmit_port;
        cam_table_index             <=  _cam_table_index;
        cam_table_delete_key        <=  _cam_table_delete_key;
    end
end


endmodule