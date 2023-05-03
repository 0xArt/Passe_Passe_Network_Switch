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
    S_GET_MAC_DESTINATION,
    S_UPDATE_TABLE,
    S_LOOKUP_DESTINATION_PORT,
    S_TRANSMIT_T0_DESTINATION_PORT
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
logic       [47:0]                          _   mac_source;
reg         [47:0]                              mac_source;
logic       [$clog2(NUMBER_OF_RMII_PORTS)-1:0]  _port_select;
reg         [$clog2(NUMBER_OF_RMII_PORTS)-1:0]  port_select;


always_comb begin
    _state                              =   state;
    _port_receive_data_ready            =   port_receive_data_ready;
    _port_transmit_data                 =   port_transmit_data;
    _port_transmit_data_valid           =   port_transmit_data_valid;
    _cam_table_read_address             =   cam_table_read_address;
    _cam_table_write_address            =   cam_table_write_address;
    _cam_table_write_data               =   cam_table_write_data;
    _cam_table_write_data_valid         =   cam_table_write_data_valid;
    _port_select                        =   port_select;
    _mac_source                         =   mac_source;
    _mac_destination                    =   mac_destination;

    case (state)
        S_IDLE: begin

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
    end
end


endmodule