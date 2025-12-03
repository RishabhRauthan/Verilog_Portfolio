# AMBA APB 3.0 Slave Peripheral

## Overview
This project implements a Memory-Mapped Slave peripheral compliant with the **AMBA APB v3.0 Protocol**. It acts as a 32-deep internal memory that can be read from or written to by an APB Master (e.g., a CPU).

## Key Features
- **Protocol Compliance:** Implements the complete IDLE -> SETUP -> ACCESS state machine.
- **Handshaking:** correctly manages `PSEL`, `PENABLE`, and `PREADY` signals.
- **Zero Wait-States:** Optimized for immediate data availability (`PREADY` tied High).
- **Verification:** Testbench uses SystemVerilog **Tasks** to model a Bus Master driver.

## File Structure
- `rtl/apb_ram.sv`: The APB Slave module wrapping a 32x32 bit memory array.
- `tb/tb_apb.sv`: Testbench with `apb_write` and `apb_read` tasks.

## Simulation
The testbench performs the following transactions:
1. Writes `0xDEAD_BEEF` to Address 5.
2. Writes `0xCAFE_BABE` to Address 10.
3. Reads both addresses back to verify data integrity.
