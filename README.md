# Passe_Passe

A FPGA Layer 2 network switch that supports virtual ports for efficient UDP data transmission and reception. The use of virtual ports facilitates seamless integration with various applications requiring UDP communication, optimizing performance and reducing latency in real-time data transfer scenarios. It currently supports RMII and RGMII interfaces, offering flexibility across Ethernet standards. This design enables dynamic resource management without hardware changes, ideal for high-performance networking environments requiring low latency and real-time communication.

More info at:

https://www.circuitden.com/blog/24

## Architecture

The switching core is an output queued fabric. Each port has its own header
engine on ingress (destination/source MAC capture, lookup, learning) and its
own scheduler on egress (frame granular round robin arbitration into the
port's transmit FIFO), so frames between different port pairs flow in
parallel. One shared CAM table sits behind an access arbiter that serializes
lookups and keeps learn operations atomic. A destination whose transmit
buffer is congested at the start of a frame drops that frame only, so one
slow port never stalls the others.

Frames move through the fabric as beats of `FABRIC_DATA_BYTES` bytes
(a `switch_core` parameter, default 1) with explicit first/last delimiting
and a tail byte count. Width adapters bridge the byte serial ports onto the
fabric and elaborate to plain wires at one byte per beat, so widening the
fabric for higher aggregate bandwidth is a parameter change rather than a
redesign.

## Simulation

The regression testbench (`test/testbench.sv`, cases 000-008) runs in Questa
with `do run.do`, or headless:

```
vlib presynth && vmap presynth presynth
<vlog command from run.do>
vsim -c -voptargs=+acc -L presynth -work presynth -t 1ps presynth.testbench \
     -do "run -all; quit -f"
```

Add `-GFABRIC_DATA_BYTES=4` to the vsim command to run the same regression
with four byte fabric beats. Unit testbenches for the fabric modules live in
`test/unit/`.
