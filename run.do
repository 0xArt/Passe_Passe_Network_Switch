quit -sim
.main clear

file delete -force presynth
vlib presynth
vmap presynth presynth
vmap rtg4 "C:/Microchip/Libero_SoC_v2022.3/Designer/lib/modelsimpro/precompiled/vlog/rtg4"

vlog -sv -work presynth \
    "ethernet_packet_generator.sv" \
    "ethernet_packet_parser.sv" \
    "frame_check_sequence_generator.sv" \
    "rgmii_port.sv"

vlog -sv -work presynth testbench.sv

vsim -L rtg4 -L presynth -work presynth -t 1ps presynth.testbench
add log -r /*

if {[file exists "wave.do"]} {
    do  "wave.do"
}

run -all