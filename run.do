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
    "rtl/rmii_byte_packager.sv" \
    "rtl/que_slot_receieve_handler.sv" \
    "rtl/receive_slot_arbiter.sv" \
    "rtl/ethernet_packet_generator.sv" \
    "rtl/ethernet_packet_parser.sv" \
    "rtl/frame_check_sequence_generator.sv" \
    "rtl/rgmii_port.sv" \
    "test/testbench.sv"

vlog -sv -work presynth testbench.sv

vsim -L rtg4 -L presynth -work presynth -t 1ps presynth.testbench
add log -r /*

if {[file exists "wave.do"]} {
    do  "wave.do"
}

run -all