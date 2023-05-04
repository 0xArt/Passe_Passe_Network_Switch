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
    parameter NUMBER_OF_RMII_PORTS    = 2,
    parameter NUMBER_OF_VIRTUAL_PORTS = 0
)(
    input   wire                                        clock,
    input   wire                                        reset_n,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          port_recieve_data_enable,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0][8:0]     port_recieve_data,
    input   wire    [NUMBER_OF_RMII_PORTS-1:0]          port_transmit_data_enable,
    input   wire    [47:0]                              cam_table_read_data,

    output  reg     [NUMBER_OF_RMII_PORTS-1:0]          port_receive_data_ready,
    output  reg     [8:0]                               port_transmit_data,
    output  reg     [NUMBER_OF_RMII_PORTS-1:0]          port_transmit_data_valid,
    output  reg     [3:0]                               cam_table_read_address,
    output  reg     [3:0]                               cam_table_write_address,
    output  reg     [47:0]                              cam_table_write_data,
    output  reg                                         cam_table_write_data_valid
);

typedef enum
{
    S_IDLE,
    S_FIND_START_BIT,
    S_GET_MAC_DESTINATION,
    S_GET_MAC_SOURCE,
    S_UPDATE_TABLE,
    S_LOOKUP_DESTINATION_PORT,
    S_TRANSMIT_MAC_DESTINATION,
    S_TRANSMIT_MAC_SOURCE,
    S_TRANSMIT_DATA
} state_type;

integer                                         i;
state_type                                      _state;
state_type                                      state;
logic       [NUMBER_OF_RMII_PORTS-1:0]          _port_receive_data_ready;
logic       [8:0]                               _port_transmit_data;
logic       [NUMBER_OF_RMII_PORTS-1:0]          _port_transmit_data_valid;
logic       [3:0]                               _cam_table_read_address;
logic       [3:0]                               _cam_table_write_address;
logic       [47:0]                              _cam_table_write_data;
logic                                           _cam_table_write_data_valid;
logic       [47:0]                              _mac_destination;
reg         [47:0]                              mac_destination;
logic       [47:0]                              _mac_source;
reg         [47:0]                              mac_source;
logic       [$clog2(NUMBER_OF_RMII_PORTS)-1:0]  _port_select;
reg         [$clog2(NUMBER_OF_RMII_PORTS)-1:0]  port_select;
logic       [7:0]                               _process_counter;
reg         [7:0]                               process_counter;


always_comb begin
    _state                              =   state;
    _port_receive_data_ready            =   port_receive_data_ready;
    _port_transmit_data                 =   port_transmit_data;
    _port_transmit_data_valid           =   port_transmit_data_valid;
    _cam_table_read_address             =   cam_table_read_address;
    _cam_table_write_address            =   cam_table_write_address;
    _cam_table_write_data               =   cam_table_write_data;
    _port_select                        =   port_select;
    _mac_source                         =   mac_source;
    _mac_destination                    =   mac_destination;
    _process_counter                    =   process_counter;
    _cam_table_write_data_valid         =   0;

    case (state)
        S_IDLE: begin
            _process_counter    =   5;

            if (port_recieve_data_enable[port_select]) begin
                _port_receive_data_ready[port_select]   = 1;
                _state                                  = S_GET_MAC_DESTINATION;
            end
            else begin
                _port_select    =   port_select + 1;
            end
        end
        S_FIND_START_BIT: begin
            if (port_recieve_data_enable[port_select]) begin
                if (port_recieve_data[port_select][8]) begin
                    _mac_destination[47:8]  =   mac_destination[39:0];
                    _mac_destination[7:0]   =   port_recieve_data[port_select];
                    _state                  =   S_GET_MAC_DESTINATION;
                end
            end
            else begin
                _port_receive_data_ready[port_select]   =   0;
                _port_select                            =   port_select + 1;
                _state                                  =   S_IDLE;
            end
        end
        S_GET_MAC_DESTINATION: begin
            if (port_recieve_data_enable[port_select] ) begin
                _mac_destination[47:8]  =   mac_destination[39:0];
                _mac_destination[7:0]   =   port_recieve_data[port_select];
                _process_counter        =   process_counter - 1;
            end
            if(process_counter == 0) begin
                _process_counter    =   5;
                _state              =   S_GET_MAC_SOURCE;
            end
        end
        S_GET_MAC_SOURCE: begin
            if(process_counter == 0) begin
                _port_receive_data_ready    =   0;
                _state                      =   S_UPDATE_TABLE;
            end

            if (port_recieve_data_enable[port_select] ) begin
                _mac_source[47:8]  =    mac_source[39:0];
                _mac_source[7:0]   =    port_recieve_data[port_select];
                _process_counter   =    process_counter - 1;
            end
        end
        S_UPDATE_TABLE: begin
            _process_counter            =   0;
            _cam_table_write_address    =   port_select;
            _cam_table_write_data       =   mac_source;
            _cam_table_write_data_valid =   1;
            _state                      =   S_LOOKUP_DESTINATION_PORT;
            _cam_table_read_address     =   0;
        end
        S_LOOKUP_DESTINATION_PORT: begin
            if (cam_table_read_data == mac_destination) begin
                _port_transmit_data_valid[cam_table_read_address] = 1;
                _port_transmit_data         =  {1'b1,mac_destination[47:40]};
                _mac_destination            =  {mac_destination[39:0],8'h00};
                _state                      =  S_TRANSMIT_MAC_DESTINATION;
            end
            else begin
                if (cam_table_read_address < NUMBER_OF_RMII_PORTS) begin
                    _cam_table_read_address = cam_table_read_address + 1;
                end
                else begin
                    //not in table...transmit out of all ports
                    _port_transmit_data_valid   = '1;
                    _port_transmit_data         =  {1'b1,mac_destination[47:40]};
                    _mac_destination            =  {mac_destination[39:0],8'h00};
                    _state                      =  S_TRANSMIT_MAC_DESTINATION;
                end
            end
        end
        S_TRANSMIT_MAC_DESTINATION: begin
            _port_transmit_data         =  {1'b0,mac_destination[47:40]};
            _mac_destination            =  {mac_destination[39:0],8'h00};
            _process_counter            =  process_counter - 1;

            if(process_counter == 0) begin
                _process_counter    = 6;
                _state              = S_TRANSMIT_MAC_SOURCE;
            end
        end
        S_TRANSMIT_SOURCE: begin
            _port_transmit_data         =  {1'b0,mac_source[47:40]};
            _mac_source                 =  {mac_source[39:0],8'h00};
            _process_counter            =  process_counter - 1;

            if(process_counter == 0) begin
                _process_counter    = 6;
                _state              = S_TRANSMIT_DATA;
            end
        end
        S_TRANSMIT_DATA: begin

        end
    endcase
end

always_ff @(posedge clock) begin
    if (!reset_n) begin
        state                       <=  S_IDLE;
        port_receive_data_ready     <=  0;
        port_transmit_data          <=  0;
        port_transmit_data_valid    <=  0;
        cam_table_read_address      <=  0;
        cam_table_write_address     <=  0;
        cam_table_write_data        <=  0;
        cam_table_write_data_valid  <=  0;
        mac_source                  <=  0;
        mac_destination             <=  0;
        port_select                 <=  0;
        process_counter             <=  0;
    end
    else begin
        state                       <=  _state;
        port_receive_data_ready     <=  _port_receive_data_ready;
        port_transmit_data          <=  _port_transmit_data;
        port_transmit_data_valid    <=  _port_transmit_data_valid;
        cam_table_read_address      <=  _cam_table_read_address;
        cam_table_write_address     <=  _cam_table_write_address;
        cam_table_write_data        <=  _cam_table_write_data;
        cam_table_write_data_valid  <=  _cam_table_write_data_valid;
        mac_source                  <=  _mac_source;
        mac_destination             <=  _mac_destination;
        port_select                 <=  _port_select;
        process_counter             <=  _process_counter;
    end
end


endmodule