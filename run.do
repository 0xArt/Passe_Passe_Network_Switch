quit -sim
.main clear

file delete -force presynth
vlib presynth
vmap presynth presynth
vmap intel "/home/artin/intelFPGA_lite/22.1std/questa_fse/modelsim_lib"


vlog -sv -work presynth \
    "rtl/cycle_timer.sv" \
    "rtl/block_ram/generic_dual_port_ram.sv" \
    "rtl/block_ram/generic_block_ram.sv" \
    "rtl/fifo/synchronous_fifo.sv" \
    "rtl/fifo/asynchronous_fifo/asynchronous_fifo_read_controller.sv" \
    "rtl/fifo/asynchronous_fifo/asynchronous_fifo_write_controller.sv" \
    "rtl/fifo/asynchronous_fifo/asynchronous_fifo.sv" \
    "rtl/que_slot.sv" \
    "rtl/que_slot_receieve_handler.sv" \
    "rtl/receive_slot_arbiter.sv" \
    "rtl/ethernet_packet_parser.sv" \
    "rtl/frame_check_sequence_generator.sv" \
    "rtl/rmii/rmii_byte_packager.sv" \
    "rtl/rmii/rmii_byte_shipper.sv" \
    "rtl/rmii/rmii_port.sv" \
    "rtl/rgmii/rgmii_byte_packager.sv" \
    "rtl/rgmii/rgmii_port.sv" \
    "rtl/virtual_port/udp/internet_checksum_calculator.sv" \
    "rtl/virtual_port/udp/ethernet_frame_generator.sv" \
    "rtl/virtual_port/udp/ethernet_frame_parser.sv" \
    "rtl/virtual_port/udp/receive_slot.sv" \
    "rtl/virtual_port/udp/udp_fragment_slot.sv" \
    "rtl/virtual_port/udp/udp_receieve_handler.sv" \
    "rtl/virtual_port/udp/udp_transmit_handler.sv" \
    "rtl/virtual_port/udp/virtual_port_udp.sv" \
    "rtl/core_data_orchestrator.sv" \
    "rtl/switch_core.sv" \
    "test/testbench.sv"

vsim -voptargs=+acc -L intel -L presynth -work presynth -t 1ps presynth.testbench
add log -r /*

if {[file exists "wave.do"]} {
    do  "wave.do"
}

run -all