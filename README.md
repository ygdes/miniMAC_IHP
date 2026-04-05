This project is the 3rd version of miniMAC, this time using [a crude PDK abstraction layer](https://github.com/YannGuidon/IHP_SG13_cells).

![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout : the miniMAC unit

MAC as in "Media Access Controller", one layer of a network protocol stack. Though inspired by Ethernet/IEEE802.3, it is incompatible and ultimately it only shares the twisted pairs cables and 8P8C connector.

- [Read this project's documentation](docs/info.md)

- [Read about its design on Hackaday](https://hackaday.io/project/198914)

- [Check the original template](https://github.com/TinyTapeout/ttihp-verilog-template)

## What is this miniMAC

This unit (de)scrambles 16-bit data (+ a 17th bit for data/control framing). The 18-bit result is suitable for feeding an upcoming PHY for serialisation and line coding. Due to pin constraints, the data are transmitted in two cycles.

This unit combines two bleeding-edge circuits:

- the gPEAC18 unit is an additive-based scrambler that combines the 17 bits and creates an extra check bit. It uses 2 cycles too (to reuse the adders) so it matches the interface's throughput.

- the Hammer18 unit is a bijective XOR-based scrambler that boosts the Hamming distance on the 18 bits at low Bit Error Rates. It was first published in March of 2026 as [https://connect.ed-diamond.com/gnu-linux-magazine/glmf-277/erreurs-en-rafales-multiparites-et-codes-gray-entrelaces](https://connect.ed-diamond.com/gnu-linux-magazine/glmf-277/erreurs-en-rafales-multiparites-et-codes-gray-entrelaces)

Together they provide a very strong and early error detection, tailored for early retransmition, saving costs, latency and bandwidth. Higher levels of the protocol will detect anomalous conditions and reset the link's state.

## Performance

Two tiles are required to fit both the encoder and decoder. They can be used alone (as either Encoder or Decoder) or in loopback mode (Encoder chained with Decoder) to verify the integrity of the circuits. Synthesis claims it can fly at 200MHz at 25°C but the interface and the pins are unlikely to be that fast. Anyway, even at 50MHz, the throughput is 450Mbps. Is that fast enough? The target of one tile for the scrambler or descrambler is reached. It will be even lighter without the 9-bit interfaces and the loopback gates.

## What next?

This version should finally work as intended, still using an experimental PDK under development. Later versions would add a FSM, some buffer SRAM and a proper PHY interface ((YGMII)[https://hackaday.io/project/205414-ygmii] is being designed).

## TODO

enable/disable Hammer with a separate RESET pin
