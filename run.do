quit -sim
.main clear

file delete -force presynth
vlib presynth
vmap presynth presynth
vmap rtg4 "C:/Microchip/Libero_SoC_v2022.3/Designer/lib/modelsimpro/precompiled/vlog/rtg4"

vlog -sv -work presynth \
    "rtl/fifo/frame_fifo/coreparameters.v" \
    "rtl/fifo/frame_fifo/corefifo_sync_scntr.v" \
    "rtl/fifo/frame_fifo/corefifo_sync.v" \
    "rtl/fifo/frame_fifo/corefifo_NstagesSync.v" \
    "rtl/fifo/frame_fifo/corefifo_grayToBinConv.v" \
    "rtl/fifo/frame_fifo/corefifo_fwft.v" \
    "rtl/fifo/frame_fifo/COREFIFO_C0_COREFIFO_C0_0_LSRAM_top.v" \
    "rtl/fifo/frame_fifo/COREFIFO_C0_COREFIFO_C0_0_ram_wrapper.v" \
    "rtl/fifo/frame_fifo/COREFIFO.v" \
    "rtl/fifo/frame_fifo/corefifo_async.v" \
    "rtl/fifo/frame_fifo/COREFIFO_C0.v" \
    "rtl/fifo/payload_fifo/corefifo_sync_scntr.v" \
    "rtl/fifo/payload_fifo/corefifo_sync.v" \
    "rtl/fifo/payload_fifo/corefifo_NstagesSync.v" \
    "rtl/fifo/payload_fifo/corefifo_grayToBinConv.v" \
    "rtl/fifo/payload_fifo/corefifo_fwft.v" \
    "rtl/fifo/payload_fifo/COREFIFO_C1_COREFIFO_C1_0_LSRAM_top.v" \
    "rtl/fifo/payload_fifo/COREFIFO_C1_COREFIFO_C1_0_ram_wrapper.v" \
    "rtl/fifo/payload_fifo/COREFIFO.v" \
    "rtl/fifo/payload_fifo/corefifo_async.v" \
    "rtl/fifo/payload_fifo/COREFIFO_C1.v" \
    "rtl/fifo/outbound_fifo/corefifo_sync_scntr.v" \
    "rtl/fifo/outbound_fifo/corefifo_sync.v" \
    "rtl/fifo/outbound_fifo/corefifo_NstagesSync.v" \
    "rtl/fifo/outbound_fifo/corefifo_grayToBinConv.v" \
    "rtl/fifo/outbound_fifo/corefifo_fwft.v" \
    "rtl/fifo/outbound_fifo/COREFIFO_C2_COREFIFO_C2_0_LSRAM_top.v" \
    "rtl/fifo/outbound_fifo/COREFIFO_C2_COREFIFO_C2_0_ram_wrapper.v" \
    "rtl/fifo/outbound_fifo/COREFIFO.v" \
    "rtl/fifo/outbound_fifo/corefifo_async.v" \
    "rtl/fifo/outbound_fifo/COREFIFO_C2.v" \
    "rtl/block_ram/cam_table/RTG4TPSRAM_C0_RTG4TPSRAM_C0_0_RTG4TPSRAM.v" \
    "rtl/block_ram/cam_table/RTG4TPSRAM_C0.v" \
    "rtl/que_slot_receieve_handler.sv" \
    "rtl/receive_slot_arbiter.sv" \
    "rtl/ethernet_packet_parser.sv" \
    "rtl/frame_check_sequence_generator.sv" \
    "rtl/rmii/rmii_byte_packager.sv" \
    "rtl/rmii/rmii_byte_shipper.sv" \
    "rtl/rmii/rmii_port.sv" \
    "rtl/rgmii/rgmii_byte_packager.sv" \
    "rtl/rgmii/rgmii_port.sv" \
    "rtl/core_data_orchestrator.sv" \
    "rtl/switch_core.sv" \
    "test/testbench.sv"

vsim -L rtg4 -L presynth -work presynth -t 1ps presynth.testbench
add log -r /*

if {[file exists "wave.do"]} {
    do  "wave.do"
}

run -all