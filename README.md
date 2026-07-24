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

The regression testbench (`test/testbench.sv`, cases 000-013) runs in Questa
with `do run.do`, or headless:

```
vlib presynth && vmap presynth presynth
<vlog command from run.do>
vsim -c -voptargs=+acc -L presynth -work presynth -t 1ps presynth.testbench \
     -do "run -all; quit -f"
```

Add `-GFABRIC_DATA_BYTES=4` to the vsim command to run the same regression
with four byte fabric beats, and `-GCORE_CLOCK_FREQUENCY=<hz>` to run it at a
reduced core clock. Add `+CASE=<n>` to run a single case instead of the full
regression (some cases depend on earlier ones, for example unicast
forwarding needs the previously learned station). Unit testbenches live in
`test/unit/`, covering the
fabric modules and the egress drain path (including a clock skew test that
proves the gap shrink mechanism drains a saturating stream through a
deliberately slowed transmit clock without dropping a frame).

## Tests

The simulated switch is two RMII ports, one UDP virtual port, and two RGMII
ports. Every case is self checking and fails the simulation on any missed,
corrupted, or misrouted frame. All results below were measured in the same
regression at both flagship configurations — one byte fabric beats with a
250 MHz core clock, and four byte beats with a 62.5 MHz core clock — with
identical outcomes (cases 000 through 009 additionally pass with four byte
beats at 100 MHz and 250 MHz).

### case 000 — bad frame rejection

A frame with a corrupted CRC32 is sent into RMII port 0, followed by a valid
frame. The corrupted frame must be consumed and silently dropped by the
ingress checker while the valid frame is accepted and forwarded.

**Result: pass.** The bad frame never reaches any egress; the good frame is
delivered.

### case 001 — source learning

A valid frame enters RMII port 0. Its source MAC must be validated and
learned into the CAM table so later traffic can be unicast back to it.

**Result: pass.** The station is learned and used by the following cases.

### case 002 — unicast forwarding

RMII port 1 sends a frame addressed to the station learned behind RMII
port 0. The switch must unicast it to RMII port 0 only.

**Result: pass.** The frame appears at RMII port 0 intact.

### case 003 — virtual port transmission

An on-chip module hands a UDP payload to the virtual port, which builds the
full Ethernet/IPv4/UDP frame (checksums and CRC in hardware) addressed to
the RMII port 0 station.

**Result: pass.** The generated frame is routed to RMII port 0.

### case 004 — IP fragmentation

The virtual port transmits a 4096 byte UDP payload, which exceeds one frame.
The hardware must fragment it into three valid IPv4 fragments, each with
correct headers, checksums, and CRC, all routed to RMII port 0.

**Result: pass.** All three fragments arrive correctly.

### case 005 — virtual port reception

RMII port 0 sends a UDP frame addressed to the virtual port's MAC. The
virtual port must validate, parse, and deliver the UDP payload to the
module side interface.

**Result: pass.** The payload is delivered to the module interface.

### case 006 — IP reassembly

A 2000 byte UDP payload arrives from RMII port 0 as multiple IPv4 fragments.
The virtual port must reassemble them in its fragment slots and deliver one
contiguous payload.

**Result: pass.** The fragments are combined and received by the module.

### case 007 — gigabit ingress

RGMII port 0 receives a frame (DDR nibbles at 125 MHz) addressed to the RMII
port 0 station. The gigabit ingress chain must recover, validate, and route
it across the speed boundary.

**Result: pass.** The frame is forwarded to RMII port 0.

### case 008 — concurrent streams

Two frames enter the switch simultaneously on different ingress ports bound
for different egress ports: RGMII port 0 to RMII port 0, and RMII port 1 to
the virtual port. Both CAM lookups land in the same window and both frames
must be delivered — the fabric switches them in parallel rather than
serializing.

**Result: pass.** Both streams deliver; at the reduced core clock the two
deliveries land on the same cycle.

### case 009 — gigabit line rate saturation

RGMII port 1 blasts frames back to back at exact gigabit line rate (12 byte
inter packet gap) unicast to a station behind RGMII port 0, in two parts:
50 minimum size frames (64 bytes, worst case per frame overhead) and 50
maximum MTU frames (1518 bytes, worst case storage occupancy). Frames are
counted at three points — ingress CRC validation, egress FIFO delivery, and
the transmit wire — so a rate shortfall anywhere in the chain appears as a
missed frame.

**Result: pass, at the theoretical maxima.** 50/50 delivered in both parts:
0.762 Gbps of frame data at minimum size and 0.987 Gbps at maximum MTU,
which are the ceilings imposed by preamble and inter packet gap overhead.
The minimum inter frame gap measured on the transmit wire is exactly 12
byte times, the 802.3 minimum — the egress repeats a backlogged stream at
precisely the fastest legal arrival rate, so a saturating stream of any
length cannot accumulate backlog inside the switch.

### case 010 — iperf3 style TCP transfer

Emulates an iperf3 TCP run between a client behind RGMII port 1 and a server
behind RGMII port 0: a real three way handshake on port 5201, a windowed
bulk transfer of 40 segments of 1460 bytes with at most 8 unacknowledged
segments in flight, delayed acknowledgements clocked by actual frame
delivery at the server wire, and a FIN exchange. Data and acknowledgements
cross the switch simultaneously in opposite directions between the same two
ports. Raising the segment count to 720 turns the case into a one megabyte
soak.

**Result: pass.** 58,400 bytes at 0.924 Gbps goodput, zero retransmissions
(the test asserts losslessness), 20/20 acknowledgements, and the egress
admission logic never deferred a frame (measured at its 3 cycle per frame
minimum in both directions). The one megabyte soak variant measured
1,051,200 bytes in 8.87 ms — goodput 0.948 Gbps, 99.9% of the 0.949 Gbps
ceiling for MSS sized segments, with 360/360 acknowledgements.

### case 011 — iperf3 style UDP test

Emulates an iperf3 UDP run over the same client/server pair: 200 datagrams
of 1470 bytes streamed at line rate, each carrying a sequence number and a
send timestamp in its payload. The server side monitor decodes every
datagram at the wire and computes the real iperf3 receiver statistics: loss
from sequence gaps, reordering, and RFC 1889 smoothed jitter from the
embedded timestamps.

**Result: pass.** 294,000 bytes at 0.957 Gbps (the exact ceiling for this
datagram size), 0/200 datagrams lost, none reordered, 0.0 ns jitter (the
simulation is deterministic, so every datagram sees an identical transit
time — on hardware this measures clock domain crossing variation).

### case 012 — multicast flood integrity

RGMII port 1 floods 20 broadcast MTU frames at gigabit line rate, so every
copy fans out through the fabric to all four other ports at once — including
the byte serial virtual port, the slowest consumer in the switch. A monitor
on the RGMII port 0 wire validates every flooded copy byte for byte: full
1518 byte length and a correct frame check sequence. The case exists because
a flood is only as fast as its slowest granted egress; if a slow port paces
the fabric handshake directly, the gigabit copy underruns the transmitter
mid frame and leaves the wire truncated. The beat wide staging FIFO in front
of the virtual port keeps the flood streaming at full beat rate no matter
how slowly the virtual port drains.

**Result: pass.** 20/20 flooded copies arrive complete and CRC clean on the
gigabit wire with the virtual port in the flood set. Before the staging FIFO
this case failed at the reduced core clock exactly as predicted — the first
copy truncated mid frame and the rest collapsed to short fragments.

### case 013 — RGMII tri speed

RGMII port 1 renegotiates to 100 megabit: the phy receive clock drops to
25 MHz and the idle data lines carry the RGMII in band status, which the
byte packager decodes for the link speed. Forwarding is then checked in
both directions. A 100 megabit frame (one duplicated nibble per clock, low
nibble first) forwards to the gigabit port 0 wire, and a gigabit frame
forwards back out of port 1 at 100 megabit, decoded nibble by nibble
against the generated 25 MHz transmit clock. The transmit side never
changes clock domains: the shipper stretches every nibble and generates
the slower transmit clock as a ddr pattern, so no clock muxing is needed.

**Result: pass.** Both frames arrive complete and CRC clean, and the
generated transmit clock measures exactly 25 MHz with fifty percent duty.
The same machinery covers 10 megabit (one nibble per 2.5 MHz clock),
which does not yet have a dedicated case.
