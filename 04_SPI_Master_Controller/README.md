# Configurable SPI Master Controller

## Overview
This project implements a generic **Serial Peripheral Interface (SPI) Master** controller. It is designed to interface with various slave devices (Sensors, Flash, SD Cards) by supporting configurable Clock Polarity (CPOL) and Clock Phase (CPHA).

## Key Features
- **All 4 SPI Modes:** Supports Modes 0, 1, 2, and 3 via `cpol` and `cpha` input ports.
- **Configurable Speed:** Internal clock divider (`CLK_DIV`) to adjust SCLK frequency relative to the system clock.
- **FSM Based:** Robust Finite State Machine handles Chip Select (CS_N) assertion, serialization, and sampling.
- **Loopback Verified:** Validated using a MOSI-to-MISO loopback testbench.

## File Structure
- `rtl/spi_master.sv`: The SPI Master core logic with configurable timing.
- `tb/tb_spi.sv`: Testbench verifying Mode 0 and Mode 3 transmission.

## Simulation
The testbench performs a **Loopback Test** (connecting MOSI to MISO):
1. Configures the Master for **Mode 0** (Idle Low, Sample 1st Edge) and sends `0xA5`.
2. Configures the Master for **Mode 3** (Idle High, Sample 2nd Edge) and sends `0x3C`.
3. Verifies that the received data matches the transmitted data.
