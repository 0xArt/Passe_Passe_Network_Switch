onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/clock}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/reset_n}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data_enable}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_result}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_result_enable}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_enable}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/recieve_slot_enable}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data_ready}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data_valid}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data_last}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/packet_data}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/packet_data_valid}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/good_packet}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/bad_packet}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/i}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/j}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_state}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/state}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/process_counter}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_process_counter}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/delayed_data}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_delayed_data}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_packet_data_valid}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_packet_data}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data_valid}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data_last}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/que_slot_select}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_que_slot_select}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_frame_check_sequence}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/frame_check_sequence}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_good_packet}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_bad_packet}
add wave -noupdate -expand -group packet_parser -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_data_ready}
add wave -noupdate -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/timeout_counter}
add wave -noupdate -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/timeout_counter_limit}
add wave -noupdate -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/speed_code}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/clock}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/reset_n}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/enable}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/data_enable}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/ready}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/push_data_valid}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_state}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/state}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_ready}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_push_data}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_push_data_valid}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/_que_slot_select}
add wave -noupdate -expand -group receive_arbiter -radix hexadecimal {/testbench/switch_core/genblk1[0]/rmii_port/receive_slot_arbiter/que_slot_select}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/clock}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/reset_n}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/enable}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/data}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/data_enable}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/good_packet}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/bad_packet}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/push_data_enable}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/fifo_reset_n}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/ready}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/push_data_ready}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/push_data}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/push_data_valid}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_state}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/state}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_push_data_ready}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_ready}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_push_data}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_push_data_valid}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_fifo_reset_n}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/_is_first_byte}
add wave -noupdate -expand -group que_slot_0 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[0]/que_slot_receieve_handler/is_first_byte}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/clock}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/reset_n}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/enable}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/data}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/data_enable}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/good_packet}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/bad_packet}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/push_data_enable}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/fifo_reset_n}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/ready}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/push_data_ready}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/push_data}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/push_data_valid}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_state}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/state}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_push_data_ready}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_ready}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_push_data}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_push_data_valid}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_fifo_reset_n}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/_is_first_byte}
add wave -noupdate -expand -group que_slot_1 {/testbench/switch_core/genblk1[0]/rmii_port/genblk2[1]/que_slot_receieve_handler/is_first_byte}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9469296 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {8697040 ps} {11082960 ps}
