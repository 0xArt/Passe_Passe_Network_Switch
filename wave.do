onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/mac_source}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/transmit_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/module_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/module_transmit_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/module_transmit_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_data_ready}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/transmit_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/transmit_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_ipv4_source}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_data_ready}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_mac_destination}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_ipv4_destination}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_destination}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_source}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_ipv4_identification}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_ipv4_flags}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_fragment_size}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_total_payload_size}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_buffer_write_address}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_buffer_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_buffer_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_checksum_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_checksum_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_udp_checksum_data_last}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler_transmit_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator_data_last}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator_result}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator_result_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator_ready}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer_write_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer_write_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer_write_address}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer_read_address}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer_read_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethenret_frame_generator_checksum_result}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_checksum_result_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_checksum_result}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_checksum_result_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_udp_buffer_read_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_mac_destination}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_mac_source}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_destination}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_source}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_udp_checksum}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_udp_destination}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_udp_source}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_udp_payload_size}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_udp_fragment_size}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_flags}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_identification}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_checksum_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_checksum_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_checksum_data_last}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_frame_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_frame_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_checksum_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_checksum_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ipv4_checksum_data_last}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_udp_buffer_read_address}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator_ready}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator_data_last}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator_result}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator_result_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator_ready}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/frame_check_sequence_generator_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/frame_check_sequence_generator_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/frame_check_sequence_generator_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/frame_check_sequence_generator_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/frame_check_sequence_generator_data_last}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/frame_check_sequence_generator_ready}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/frame_check_sequence_generator_checksum}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/frame_check_sequence_generator_checksum_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_checksum_result}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_checksum_result_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_data_ready}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_checksum_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_checksum_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_checksum_data_last}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_packet_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_packet_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_good_packet}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_bad_packet}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser_udp_destination}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler_push_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler_push_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter_data_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter_ready}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter_push_data}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter_push_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_read_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_read_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_read_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_write_clock}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_write_enable}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_write_reset_n}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_read_data_valid}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_empty}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_full}
add wave -noupdate -group virtual_port_udp {/testbench/switch_core/genblk2[0]/virutal_port_udp/outbound_fifo_read_data}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/clock}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/reset_n}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/enable}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/data}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/data_enable}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/data_ready}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_state}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/ipv4_source}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/mac_destination}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/ipv4_destination}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_destination}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_source}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/ipv4_identification}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/ipv4_flags}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_fragment_size}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_total_payload_size}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_buffer_write_address}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_buffer_data}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_buffer_data_valid}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_checksum_data}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_checksum_data_valid}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_checksum_data_last}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/transmit_valid}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/timeout_cycle_timer_clock}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/timeout_cycle_timer_reset_n}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/timeout_cycle_timer_enable}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/timeout_cycle_timer_load_count}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/timeout_cycle_timer_count}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/timeout_cycle_timer_expired}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/state}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_process_counter}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/process_counter}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_mac_destination}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_ipv4_destination}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_destination}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_source}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_number_of_udp_bytes_left}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/number_of_udp_bytes_left}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_buffer_data}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_buffer_data_valid}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_ready}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_transmit_valid}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_ipv4_identification}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_ipv4_flags}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/saved_ipv4_source}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_saved_ipv4_source}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_buffer_write_address}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_checksum_data}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_checksum_data_valid}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_total_payload_size}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/udp_header_size_field}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_checksum_data_last}
add wave -noupdate -group virtual_port_udp_transmit_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_transmit_handler/_udp_fragment_size}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/clock}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/reset_n}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/data}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/data_enable}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/data_last}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/result}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/result_valid}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/ready}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/_state}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/state}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/_result}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/_result_valid}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/accumulator}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/_accumulator}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/accumator_carry}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/packed_bytes}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/_packed_bytes}
add wave -noupdate -group virtual_port_transmit_udp_checksum_calc {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_checksum_calculator/_ready}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/clock}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/reset_n}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/data}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/data_enable}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/data_last}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/result}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/result_valid}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/ready}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/_state}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/state}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/_result}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/_result_valid}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/accumulator}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/_accumulator}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/accumator_carry}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/packed_bytes}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/_packed_bytes}
add wave -noupdate -group virtual_port_udp_ipv4_checksum_calculator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ipv4_checksum_calculator/_ready}
add wave -noupdate -group virtual_port_udp_buffer_data {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer/clock}
add wave -noupdate -group virtual_port_udp_buffer_data {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer/reset_n}
add wave -noupdate -group virtual_port_udp_buffer_data {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer/write_enable}
add wave -noupdate -group virtual_port_udp_buffer_data {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer/write_data}
add wave -noupdate -group virtual_port_udp_buffer_data {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer/write_address}
add wave -noupdate -group virtual_port_udp_buffer_data {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer/read_address}
add wave -noupdate -group virtual_port_udp_buffer_data {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_data_buffer/read_data}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/clock}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/reset_n}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/enable}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/checksum_result}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/checksum_result_enable}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_checksum_result}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_checksum_result_enable}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/udp_buffer_read_data}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/mac_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/mac_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/udp_checksum}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/udp_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/udp_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_flags}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_identification}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/udp_payload_size}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/udp_fragment_size}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/checksum_data}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/checksum_data_valid}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/checksum_data_last}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/frame_data}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/frame_data_valid}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_checksum_data}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_checksum_data_valid}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_checksum_data_last}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/udp_buffer_read_address}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ready}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/process_cycle_timer_clock}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/process_cycle_timer_reset_n}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/process_cycle_timer_enable}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/process_cycle_timer_load_count}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/process_cycle_timer_count}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/process_cycle_timer_expired}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_state}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/state}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/i}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/j}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_ready}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/process_counter}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_process_counter}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_mac_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_mac_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_mac_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_mac_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_ipv4_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_ipv4_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_ipv4_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_ipv4_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_udp_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_udp_destination}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_ipv4_checksum}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_ipv4_checksum}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_udp_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_udp_source}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_udp_payload_size}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_udp_payload_size}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_udp_fragment_size}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_udp_fragment_size}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/ipv4_total_length}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_ipv4_total_length}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/udp_total_length}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_udp_total_length}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_ipv4_checksum_data_last}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_udp_checksum_data_last}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_ipv4_checksum_data_valid}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/frame_total_length}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_frame_total_length}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_checksum_result}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_checksum_result}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_ipv4_flags}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_ipv4_flags}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_ipv4_identification}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_ipv4_identification}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_checksum_data_last}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_saved_udp_checksum}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/saved_udp_checksum}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_ipv4_checksum_data}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_udp_buffer_read_address}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_frame_byte}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/frame_byte}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_frame_byte_valid}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/frame_byte_valid}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_frame_start}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/frame_start}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/_fragment_offset}
add wave -noupdate -group virtual_port_udp_frame_generator {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_generator/fragment_offset}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/clock}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/reset_n}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/data}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/data_enable}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/checksum_result}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/checksum_result_enable}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/data_ready}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/checksum_data}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/checksum_data_valid}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/checksum_data_last}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/packet_data}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/packet_data_valid}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/good_packet}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/bad_packet}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/udp_destination}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_flags}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_identification}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_state}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/state}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/process_counter}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_process_counter}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_packet_data_valid}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_packet_data}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_checksum_data}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_checksum_data_valid}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_checksum_data_last}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/que_slot_select}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_que_slot_select}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_calculated_frame_check_sequence}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/calculated_frame_check_sequence}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_good_packet}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_bad_packet}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_mac_destination}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/mac_destination}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_mac_source}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/mac_source}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ether_type}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ether_type}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_version}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_version}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_header_length}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_header_length}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_total_length}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_total_length}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_identification}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_flags}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_time_to_live}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_time_to_live}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_protocol}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_protocol}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_services}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_services}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_header_checksum}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_header_checksum}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_source_address}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_source_address}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_ipv4_destination_address}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/ipv4_destination_address}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_udp_source_port}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/udp_source_port}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_udp_destination_port}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/udp_destination_port}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_udp_length}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/udp_length}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_udp_checksum}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/udp_checksum}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_frame_check_sequence}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/frame_check_sequence}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/udp_payload_pad_byte_count}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_udp_payload_pad_byte_count}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/udp_payload_byte_count}
add wave -noupdate -group udp_ethernet_frame_parser {/testbench/switch_core/genblk2[0]/virutal_port_udp/ethernet_frame_parser/_udp_payload_byte_count}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/read_clock}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/read_reset_n}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/write_clock}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/write_reset_n}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/read_enable}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/write_enable}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/write_data}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/read_data}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/read_data_valid}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/full}
add wave -noupdate -group virtual_port_switch_inbound_fifo {/testbench/switch_core/genblk2[0]/virutal_port_udp/switch_inbound_fifo/empty}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/clock}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/reset_n}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/data}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/data_enable}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/good_packet}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/bad_packet}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/ipv4_flags}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/ipv4_identification}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/push_data_enable}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/ready}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/data_ready}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/current_ipv4_flags}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/current_ipv4_identification}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/push_data}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/push_data_valid}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_clock}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_reset_n}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_write_data}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_read_enable}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_write_enable}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_read_data_valid}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_empty}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_full}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/receive_fifo_read_data}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/_state}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/state}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/_ready}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/_current_ipv4_identification}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/_current_ipv4_flags}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/fifo_reset_n}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/_fifo_reset_n}
add wave -noupdate -group receive_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[0]/receive_slot/_data_ready}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/clock}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/reset_n}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/data}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/data_enable}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/good_packet}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/bad_packet}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/ipv4_flags}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/ipv4_identification}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/push_data_enable}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/ready}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/data_ready}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/current_ipv4_flags}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/current_ipv4_identification}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/push_data}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/push_data_valid}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_clock}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_reset_n}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_write_data}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_read_enable}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_write_enable}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_read_data_valid}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_empty}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_full}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/receive_fifo_read_data}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/_state}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/state}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/_ready}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/_current_ipv4_identification}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/_current_ipv4_flags}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/fifo_reset_n}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/_fifo_reset_n}
add wave -noupdate -group receive_slot_1 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk1[1]/receive_slot/_data_ready}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/clock}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/reset_n}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/data}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/data_enable}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/data_last}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/push_data_enable}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_id}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/ready}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/data_ready}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/push_data}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/push_data_valid}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/current_packet_id}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_clock}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_reset_n}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_write_data}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_read_enable}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_write_enable}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_read_data_valid}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_empty}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_full}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/fragment_fifo_read_data}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/_state}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/state}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/_ready}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/_current_packet_id}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/_data_ready}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/buffer_data}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/_buffer_data}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/buffer_data_valid}
add wave -noupdate -group fragment_slot_0 {/testbench/switch_core/genblk2[0]/virutal_port_udp/genblk2[0]/udp_fragment_slot/_buffer_data_valid}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/clock}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/reset_n}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/enable}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/data}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/data_enable}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/ready}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/push_data}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/push_data_valid}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/_state}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/state}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/_push_data}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/_push_data_valid}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/_que_slot_select}
add wave -noupdate -group receive_slot_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/que_slot_select}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/clock}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/reset_n}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data_enable}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_result}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_result_enable}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/speed_code}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/data_ready}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data_valid}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/checksum_data_last}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/packet_data}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/packet_data_valid}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/good_packet}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/bad_packet}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/i}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_state}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/state}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/process_counter}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_process_counter}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/timeout_counter}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_timeout_counter}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/timeout_counter_limit}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_timeout_counter_limit}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/delayed_data}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_delayed_data}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_packet_data_valid}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_packet_data}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data_valid}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_checksum_data_last}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/que_slot_select}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_que_slot_select}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_frame_check_sequence}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/frame_check_sequence}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_good_packet}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/_bad_packet}
add wave -noupdate -group ethernet_packet_parser_rmii_0 {/testbench/switch_core/genblk1[0]/rmii_port/ethernet_packet_parser/timeout_flag}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/clock}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/reset_n}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/enable}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/data}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/data_enable}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/ready}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/push_data}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/push_data_valid}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/_state}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/state}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/_push_data}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/_push_data_valid}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/_que_slot_select}
add wave -noupdate -group fragment_arbiter {/testbench/switch_core/genblk2[0]/virutal_port_udp/receive_slot_arbiter/que_slot_select}
add wave -noupdate /testbench/ethernet_message
add wave -noupdate /testbench/udp_data
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/clock
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/reset_n
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/port_receive_data_enable
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/port_receive_data
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/cam_table_match_index
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/cam_table_no_match
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/cam_table_match_enable
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/port_receive_data_ready
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/port_transmit_data
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/port_transmit_data_valid
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/cam_table_match_valid
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/cam_table_write_data
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/cam_table_write_data_valid
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/cam_table_index
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/timeout_cycle_timer_clock
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/timeout_cycle_timer_reset_n
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/timeout_cycle_timer_enable
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/timeout_cycle_timer_load_count
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/timeout_cycle_timer_count
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/timeout_cycle_timer_expired
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/i
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_state
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/state
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_port_transmit_data
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_port_transmit_data_valid
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_cam_table_write_data
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_cam_table_write_data_valid
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_mac_destination
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/mac_destination
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_mac_source
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/mac_source
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_port_select
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/port_select
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_process_counter
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/process_counter
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_target_transmit_port
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/target_transmit_port
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_cam_table_match_valid
add wave -noupdate -group core_data_orchestrator /testbench/switch_core/core_data_orchestrator/_cam_table_index
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/clock
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/reset_n
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/write_enable
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/key
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/index
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/match_enable
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/match_index
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/match_valid
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/no_match
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/written
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/_match_index
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/_match_valid
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/_no_match
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/i
add wave -noupdate -group cam_table /testbench/switch_core/cam_table/j
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/clock}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/reset_n}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/enable}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/data}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/data_enable}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/ipv4_identification}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/ipv4_flags}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/fragment_slot_empty}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/fragment_slot_packet_id}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/data_ready}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/push_data}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/push_data_valid}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/push_data_last}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/packet_id}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/timeout_cycle_timer_clock}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/timeout_cycle_timer_reset_n}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/timeout_cycle_timer_enable}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/timeout_cycle_timer_load_count}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/timeout_cycle_timer_count}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/timeout_cycle_timer_expired}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_state}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/state}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_push_data}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_push_data_valid}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_packet_id}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/more_fragments}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_more_fragments}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_fragment_slot_select}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/fragment_slot_select}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_fragment_offset}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/fragment_offset}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_push_data_last}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_receive_slot_select}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/receive_slot_select}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/_process_counter}
add wave -noupdate -group udp_receive_handler {/testbench/switch_core/genblk2[0]/virutal_port_udp/udp_receieve_handler/process_counter}
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
add wave -noupdate -group rmii_byte_packager_0 -radix decimal {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/counter}
add wave -noupdate -group rmii_byte_packager_0 -radix unsigned {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_counter}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/sample_counter}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_sample_counter}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_packaged_data}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_packaged_data_valid}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data_enable_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_data_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_data_enable_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/data_error_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_data_error_delayed}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_is_first_byte}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/is_first_byte}
add wave -noupdate -group rmii_byte_packager_0 {/testbench/switch_core/genblk1[0]/rmii_port/rmii_byte_packager/_speed_code}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/core_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/phy_receive_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/phy_receive_data_control}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/phy_receive_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/transmit_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/transmit_data_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/receive_data_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/phy_transmit_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/phy_transmit_data_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/phy_transmit_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/transmit_data_ready}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager_reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager_data_control}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager_packaged_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager_packaged_data_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager_packaged_data_speed_code}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_read_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_write_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_write_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_read_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_read_data_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_full}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo_empty}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_data_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_checksum_result}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_checksum_result_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_receive_slot_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_speed_code}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_data_ready}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_checksum_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_checksum_data_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_checksum_data_last}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_packet_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_packet_data_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_good_packet}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser_bad_packet}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_check_sequence_generator_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_check_sequence_generator_reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_check_sequence_generator_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_check_sequence_generator_data_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_check_sequence_generator_data_last}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_check_sequence_generator_ready}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_check_sequence_generator_checksum}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/frame_check_sequence_generator_checksum_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_data_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_good_packet}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_bad_packet}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_push_data_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_ready}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_data_ready}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_push_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_push_data_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_data_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_push_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_ready}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_data_ready}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_push_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/que_slot_receieve_handler_push_data_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_write_data}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_read_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_read_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_read_reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_write_clock}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_write_enable}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_write_reset_n}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_read_data_valid}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_empty}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_full}
add wave -noupdate -group rgmii_port {/testbench/switch_core/genblk3[0]/rgmii_port/outbound_fifo_read_data}
add wave -noupdate -group rgmii_ddr_data_input {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer/clock}
add wave -noupdate -group rgmii_ddr_data_input {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer/reset_n}
add wave -noupdate -group rgmii_ddr_data_input {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer/ddr_input}
add wave -noupdate -group rgmii_ddr_data_input {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer/ddr_output}
add wave -noupdate -group rgmii_ddr_data_input {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer/positive_edge_capture}
add wave -noupdate -group rgmii_ddr_data_input {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer/negative_edge_capture}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/clock}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/reset_n}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_control}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/packaged_data}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/packaged_data_valid}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/speed_code}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer_clock}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer_reset_n}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer_ddr_input}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_ddr_input_buffer_ddr_output}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_control_ddr_input_buffer_clock}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_control_ddr_input_buffer_reset_n}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_control_ddr_input_buffer_ddr_input}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_control_ddr_input_buffer_ddr_output}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/state}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_state}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/counter}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_counter}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/sample_counter}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_sample_counter}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_packaged_data}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_packaged_data_valid}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_delayed}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_enable_delayed}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_data_delayed}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_data_enable_delayed}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/data_error_delayed}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_data_error_delayed}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_is_first_byte}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/is_first_byte}
add wave -noupdate -group rgmii_0_byte_packager {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_packager/_speed_code}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/clock}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/reset_n}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/read_enable}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/write_enable}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/write_data}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/read_data}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/read_data_valid}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/full}
add wave -noupdate -group rgmii_0_frame_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/frame_fifo/empty}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/clock}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/reset_n}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/data}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/data_enable}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/checksum_result}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/checksum_result_enable}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/receive_slot_enable}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/speed_code}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/data_ready}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/checksum_data}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/checksum_data_valid}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/checksum_data_last}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/packet_data}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/packet_data_valid}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/good_packet}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/bad_packet}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/i}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/index}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_state}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/state}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/process_counter}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_process_counter}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/timeout_counter}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_timeout_counter}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/timeout_counter_limit}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_timeout_counter_limit}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/delayed_data}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_delayed_data}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_checksum_data}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_packet_data_valid}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_packet_data}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_checksum_data_valid}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_checksum_data_last}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/que_slot_select}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_que_slot_select}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_frame_check_sequence}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/frame_check_sequence}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_good_packet}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/_bad_packet}
add wave -noupdate -group rgmii_port_0_ethernet_packet_parser {/testbench/switch_core/genblk3[0]/rgmii_port/ethernet_packet_parser/timeout_flag}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/read_clock}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/read_reset_n}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/write_clock}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/write_reset_n}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/read_enable}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/write_enable}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/write_data}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/read_data}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/read_data_valid}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/full}
add wave -noupdate -group rgmii_port_inbound_fifo {/testbench/switch_core/genblk3[0]/rgmii_port/inbound_fifo/empty}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/clock}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/reset_n}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_enable}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_ready}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/shipped_data}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/shipped_data_valid}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_clock}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_reset_n}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_read_enable}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_write_enable}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_write_data}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_read_data}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_read_data_valid}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_full}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_empty}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_ddr_output_buffer_clock}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_ddr_output_buffer_reset_n}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_ddr_output_buffer_ddr_input}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_ddr_output_buffer_ddr_output}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_valid_ddr_output_buffer_clock}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_valid_ddr_output_buffer_reset_n}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_valid_ddr_output_buffer_ddr_input}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/data_valid__ddr_output_buffer_ddr_output}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/timeout_cycle_timer_clock}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/timeout_cycle_timer_reset_n}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/timeout_cycle_timer_enable}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/timeout_cycle_timer_load_count}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/timeout_cycle_timer_count}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/timeout_cycle_timer_expired}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/state}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/_state}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_data}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/_stage_data}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_data_valid}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/_stage_data_valid}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/counter}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/_counter}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/frame_data}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/_frame_data}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/frame_data_valid}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/_frame_data_valid}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/stage_fifo_flush}
add wave -noupdate -group rgmii_byte_shipper {/testbench/switch_core/genblk3[0]/rgmii_port/rgmii_byte_shipper/_stage_fifo_flush}
add wave -noupdate -expand -group switch_core /testbench/switch_core/clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/reset_n
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_phy_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_phy_receive_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_phy_receive_data_error
add wave -noupdate -expand -group switch_core /testbench/switch_core/module_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/module_transmit_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/module_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_phy_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_phy_receive_data_control
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_phy_receive_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_phy_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_phy_transmit_data_vaid
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_phy_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_phy_transmit_data_control
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_phy_transmit_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/module_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/module_receive_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/module_transmit_data_ready
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_core_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_reset_n
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_rmii_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_rmii_receive_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_rmii_receive_data_error
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_transmit_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_receive_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_receive_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_rmii_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rmii_port_rmii_transmit_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_reset_n
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_mac_source
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_ipv4_source
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_receive_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/virtual_port_udp_transmit_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_module_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_module_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_module_transmit_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_receive_data_ready
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_transmit_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_module_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_module_receive_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/virutal_port_udp_module_transmit_data_ready
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_core_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_reset_n
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_phy_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_phy_receive_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_phy_receive_data_control
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_transmit_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_receive_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_receive_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_phy_transmit_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_phy_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/rgmii_port_phy_transmit_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestraotr_reset_n
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_port_receive_data_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_port_receive_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_match_index
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_no_match
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_match_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_port_receive_data_ready
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_port_transmit_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_port_transmit_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_match_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_write_data
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_write_data_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_index
add wave -noupdate -expand -group switch_core /testbench/switch_core/core_data_orchestrator_cam_table_delete_key
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_clock
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_reset_n
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_write_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_key
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_index
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_match_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_delete_enable
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_match_index
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_match_valid
add wave -noupdate -expand -group switch_core /testbench/switch_core/cam_table_no_match
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9398740 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 320
configure wave -valuecolwidth 327
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
WaveRestoreZoom {0 ps} {59541504 ps}
