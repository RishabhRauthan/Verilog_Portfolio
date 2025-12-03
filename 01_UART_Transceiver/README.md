# UART Transceiver (Verilog)

## Overview
This project implements a fully functional **Universal Asynchronous Receiver-Transmitter (UART)** module. It is designed to handle serial communication between digital systems without a shared clock, commonly used in embedded systems.

## Key Features
- **Full Duplex:** Can transmit (TX) and receive (RX) simultaneously.
- **Configurable Baud Rate:** Parameterized design allows easy modification of speed (default: 19200 baud).
- **16x Oversampling:** The Receiver uses a 16x tick generator to sample the middle of the data bit, ensuring robustness against noise and timing drift.
- **Loopback Verification:** Validated using a self-checking testbench that connects TX directly to RX.

## File Structure
- `rtl/uart_top.sv`: The top-level module containing the Baud Generator, TX, and RX modules.
- `tb/tb_uart.sv`: SystemVerilog testbench performing the Loopback test.

## Simulation
To run the simulation:
1. Compile the design and testbench.
2. The testbench performs two checks:
   - Sends `0x55` -> Expects `0x55`.
   - Sends `0xA3` -> Expects `0xA3`.
3. Success is indicated by the message: `SUCCESS: Received ...`
