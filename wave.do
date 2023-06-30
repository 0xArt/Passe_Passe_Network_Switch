onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/clock}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/reset_n}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data_enable}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_result}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_result_enable}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_enable}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/recieve_slot_enable}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data_ready}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data_valid}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data_last}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/packet_data}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/packet_data_valid}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/good_packet}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/bad_packet}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/i}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/j}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_state}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/state}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/process_counter}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_process_counter}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/delayed_data}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_delayed_data}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_packet_data_valid}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_packet_data}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data_valid}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data_last}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/que_slot_select}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_que_slot_select}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_frame_check_sequence}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/frame_check_sequence}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_good_packet}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_bad_packet}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_data_ready}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/timeout_counter}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/timeout_counter_limit}
add wave -noupdate -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/speed_code}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/clock}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/reset_n}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/enable}
add wave -noupdate -group receive_arbiter -radix hexadecimal -childformat {{{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data[1]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data[0]} -radix hexadecimal}} -subitemconfig {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data[1]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data[0]} {-height 23 -radix hexadecimal}} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data}
add wave -noupdate -group receive_arbiter -radix hexadecimal -childformat {{{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data_enable[1]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data_enable[0]} -radix hexadecimal}} -subitemconfig {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data_enable[1]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data_enable[0]} {-height 23 -radix hexadecimal}} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data_enable}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/ready}
add wave -noupdate -group receive_arbiter -radix hexadecimal -childformat {{{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[8]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[7]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[6]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[5]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[4]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[3]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[2]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[1]} -radix hexadecimal} {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[0]} -radix hexadecimal}} -subitemconfig {{/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[8]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[7]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[6]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[5]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[4]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[3]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[2]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[1]} {-height 23 -radix hexadecimal} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data[0]} {-height 23 -radix hexadecimal}} {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data_valid}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_state}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/state}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_ready}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_push_data}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_push_data_valid}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_que_slot_select}
add wave -noupdate -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/que_slot_select}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/clock}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/reset_n}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/enable}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/data}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/data_enable}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/good_packet}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/bad_packet}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/push_data_enable}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/fifo_reset_n}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/ready}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/push_data_ready}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/push_data}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/push_data_valid}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_state}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/state}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_push_data_ready}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_ready}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_push_data}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_push_data_valid}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_fifo_reset_n}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_is_first_byte}
add wave -noupdate -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/is_first_byte}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/clock}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/reset_n}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/enable}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/data}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/data_enable}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/good_packet}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/bad_packet}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/push_data_enable}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/fifo_reset_n}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/ready}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/push_data_ready}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/push_data}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/push_data_valid}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_state}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/state}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_push_data_ready}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_ready}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_push_data}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_push_data_valid}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_fifo_reset_n}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_is_first_byte}
add wave -noupdate -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/is_first_byte}
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/clock
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/reset_n
add wave -noupdate -expand -group core_data_orch -expand /testbench/switch_core/core_data_orchestrator/port_recieve_data_enable
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/port_recieve_data
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/port_transmit_data_enable
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/cam_table_read_data
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/port_receive_data_ready
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/port_transmit_data
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/port_transmit_data_valid
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/cam_table_read_address
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/cam_table_write_address
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/cam_table_write_data
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/cam_table_write_data_valid
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/i
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/_state
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/state
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/_port_receive_data_ready
add wave -noupdate -expand -group core_data_orch -radix hexadecimal /testbench/switch_core/core_data_orchestrator/_port_transmit_data
add wave -noupdate -expand -group core_data_orch -radix hexadecimal /testbench/switch_core/core_data_orchestrator/_port_transmit_data_valid
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/_cam_table_read_address
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/_cam_table_write_address
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/_cam_table_write_data
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/_cam_table_write_data_valid
add wave -noupdate -expand -group core_data_orch -radix hexadecimal /testbench/switch_core/core_data_orchestrator/_mac_destination
add wave -noupdate -expand -group core_data_orch -radix hexadecimal /testbench/switch_core/core_data_orchestrator/mac_destination
add wave -noupdate -expand -group core_data_orch -radix hexadecimal /testbench/switch_core/core_data_orchestrator/_mac_source
add wave -noupdate -expand -group core_data_orch -radix hexadecimal /testbench/switch_core/core_data_orchestrator/mac_source
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/_port_select
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/port_select
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/_process_counter
add wave -noupdate -expand -group core_data_orch /testbench/switch_core/core_data_orchestrator/process_counter
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/clock}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/reset_n}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/data}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/data_enable}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/speed_code}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/shipped_data}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/shipped_data_valid}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/data_ready}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/state}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/_state}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/counter}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/_counter}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/sample_counter}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/_sample_counter}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/_shipped_data}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/_shipped_data_valid}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/_byte_to_ship}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/byte_to_ship}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/sample_counter_limit}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/_sample_counter_limit}
add wave -noupdate -group rmii_byte_shipper {/testbench/switch_core/genblk1[1]/rmii_port/rmii_byte_shipper/_data_ready}
add wave -noupdate -group switch_core /testbench/switch_core/clock
add wave -noupdate -group switch_core /testbench/switch_core/reset_n
add wave -noupdate -group switch_core /testbench/switch_core/rmii_phy_receive_data
add wave -noupdate -group switch_core /testbench/switch_core/rmii_phy_receive_data_enable
add wave -noupdate -group switch_core /testbench/switch_core/rmii_phy_receive_data_error
add wave -noupdate -group switch_core -expand /testbench/switch_core/rmii_phy_transmit_data
add wave -noupdate -group switch_core -expand /testbench/switch_core/rmii_phy_transmit_data_vaid
add wave -noupdate -group switch_core /testbench/switch_core/rmii_phy_reference_clock
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_clock
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_core_clock
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_reset_n
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_enable
add wave -noupdate -group switch_core -expand /testbench/switch_core/rmii_port_rmii_receive_data
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_rmii_receive_data_enable
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_rmii_receive_data_error
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_transmit_data
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_transmit_data_enable
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_receive_data_enable
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_receive_data
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_receive_data_valid
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_rmii_transmit_data
add wave -noupdate -group switch_core /testbench/switch_core/rmii_port_rmii_transmit_data_valid
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_clock
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestraotr_reset_n
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_port_recieve_data_enable
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_port_recieve_data
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_port_transmit_data_enable
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_read_data
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_port_receive_data_ready
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_port_transmit_data
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_port_transmit_data_valid
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_read_address
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_write_address
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_write_data
add wave -noupdate -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_write_data_valid
add wave -noupdate -group switch_core /testbench/switch_core/cam_table_clock
add wave -noupdate -group switch_core /testbench/switch_core/cam_table_read_address
add wave -noupdate -group switch_core /testbench/switch_core/cam_table_write_address
add wave -noupdate -group switch_core /testbench/switch_core/cam_table_write_data
add wave -noupdate -group switch_core /testbench/switch_core/cam_table_write_enable
add wave -noupdate -group switch_core /testbench/switch_core/cam_table_read_data
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/clock}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/reset_n}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/data}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/data_enable}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/checksum_result}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/checksum_result_enable}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/checksum_enable}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/recieve_slot_enable}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/speed_code}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/data_ready}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/checksum_data}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/checksum_data_valid}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/checksum_data_last}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/packet_data}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/packet_data_valid}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/good_packet}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/bad_packet}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/i}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/j}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_state}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/state}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/process_counter}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_process_counter}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/timeout_counter}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_timeout_counter}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/timeout_counter_limit}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_timeout_counter_limit}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/delayed_data}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_delayed_data}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_checksum_data}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_packet_data_valid}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_packet_data}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_checksum_data_valid}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_checksum_data_last}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/que_slot_select}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_que_slot_select}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_frame_check_sequence}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/frame_check_sequence}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_good_packet}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_bad_packet}
add wave -noupdate -group frame_parser_1 {/testbench/switch_core/genblk1[1]/rmii_port/ethernet_packet_parser/_data_ready}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/read_clock}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/read_reset_n}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/write_clock}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/write_reset_n}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/read_enable}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/write_enable}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/write_data}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/read_data}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/read_data_valid}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/full}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/empty}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_write_clock}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_read_clock}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_read_reset_n}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_write_reset_n}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_write_enable}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_write_data}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_write_address}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_read_address}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/generic_dual_port_ram_read_data}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_clock}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_reset_n}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_read_enable}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_write_pointer_gray}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_write_enable}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_memory_read_data}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_read_data}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_read_data_valid}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_memory_read_address}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_read_pointer_gray}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_empty}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_clock}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_reset_n}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_write_enable}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_read_pointer_gray}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_read_enable}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_write_data}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_memory_write_data}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_memory_write_data_valid}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_memory_write_address}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_memory_write_pointer_gray}
add wave -noupdate -group rmii_inbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_full}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/read_clock}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/read_reset_n}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/write_clock}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/write_reset_n}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/read_enable}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/write_enable}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/write_data}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/read_data}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/read_data_valid}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/full}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/empty}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_write_clock}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_read_clock}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_read_reset_n}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_write_reset_n}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_write_enable}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_write_data}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_write_address}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_read_address}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/generic_dual_port_ram_read_data}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_clock}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_reset_n}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_read_enable}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_write_pointer_gray}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_write_enable}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_memory_read_data}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_read_data}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_read_data_valid}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_memory_read_address}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_read_pointer_gray}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_read_controller_empty}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_clock}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_reset_n}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_write_enable}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_read_pointer_gray}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_read_enable}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_write_data}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_memory_write_data}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_memory_write_data_valid}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_memory_write_address}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_memory_write_pointer_gray}
add wave -noupdate -group rmii_inbound_fifo_1 {/testbench/switch_core/genblk1[1]/rmii_port/inbound_fifo/asynchronous_fifo_write_controller_full}
add wave -noupdate -group testbench /testbench/clock
add wave -noupdate -group testbench /testbench/reset_n
add wave -noupdate -group testbench /testbench/ethernet_transmit_data
add wave -noupdate -group testbench /testbench/ethernet_transmit_data_valid
add wave -noupdate -group testbench /testbench/switch_core_clock
add wave -noupdate -group testbench /testbench/switch_core_reset_n
add wave -noupdate -group testbench /testbench/switch_core_rmii_phy_receive_data
add wave -noupdate -group testbench /testbench/switch_core_rmii_phy_receive_data_enable
add wave -noupdate -group testbench /testbench/switch_core_rmii_phy_receive_data_error
add wave -noupdate -group testbench /testbench/switch_core_rmii_phy_transmit_data
add wave -noupdate -group testbench /testbench/switch_core_rmii_phy_transmit_data_valid
add wave -noupdate -group testbench /testbench/switch_core_rmii_phy_reference_clock
add wave -noupdate -group testbench /testbench/rmii_byte_packager_clock
add wave -noupdate -group testbench /testbench/rmii_byte_packager_reset_n
add wave -noupdate -group testbench /testbench/rmii_byte_packager_data
add wave -noupdate -group testbench /testbench/rmii_byte_packager_data_enable
add wave -noupdate -group testbench /testbench/rmii_byte_packager_packaged_data
add wave -noupdate -group testbench /testbench/rmii_byte_packager_speed_code
add wave -noupdate -group testbench /testbench/rmii_byte_packager_packaged_data_valid
add wave -noupdate -group testbench /testbench/rmii_byte_packager_data_error
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/clock
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/reset_n
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/data
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/data_enable
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/data_error
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/packaged_data
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/packaged_data_valid
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/speed_code
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/state
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_state
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/counter
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_counter
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/sample_counter
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_sample_counter
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_packaged_data
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_packaged_data_valid
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/data_delayed
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_data_delayed
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/data_enable_delayed
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_data_enable_delayed
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/data_error_delayed
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_data_error_delayed
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_is_first_byte
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/is_first_byte
add wave -noupdate -group testbench_rmii_byte_packager /testbench/rmii_byte_packager/_speed_code
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/clock}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/reset_n}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data_enable}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data_error}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/packaged_data}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/packaged_data_valid}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/speed_code}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/state}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_state}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/counter}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_counter}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/sample_counter}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_sample_counter}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_packaged_data}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_packaged_data_valid}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_data_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data_enable_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_data_enable_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data_error_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_data_error_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_is_first_byte}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/is_first_byte}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_speed_code}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/clock}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/reset_n}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/read_enable}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/write_enable}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/write_data}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/read_data}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/read_data_valid}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/full}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/empty}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/read_pointer}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/_read_pointer}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/write_pointer}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/_write_pointer}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/_read_data}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/_read_data_valid}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/i}
add wave -noupdate -group frame_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/frame_fifo/j}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/read_clock}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/read_reset_n}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/write_clock}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/write_reset_n}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/read_enable}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/write_enable}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/write_data}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/read_data}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/read_data_valid}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/full}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/empty}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_write_clock}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_read_clock}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_read_reset_n}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_write_reset_n}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_write_enable}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_write_data}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_write_address}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_read_address}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/generic_dual_port_ram_read_data}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_clock}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_reset_n}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_read_enable}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_write_pointer_gray}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_write_enable}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_memory_read_data}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_read_data}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_read_data_valid}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_memory_read_address}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_read_pointer_gray}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_read_controller_empty}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_clock}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_reset_n}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_write_enable}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_read_pointer_gray}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_read_enable}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_write_data}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_memory_write_data}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_memory_write_data_valid}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_memory_write_address}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_memory_write_pointer_gray}
add wave -noupdate -group outbound_fifo_0 {/testbench/switch_core/genblk1[0]/rmii_port/outbound_fifo/asynchronous_fifo_write_controller_full}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10214733 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 343
configure wave -valuecolwidth 102
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {9932486 ps} {10447514 ps}
