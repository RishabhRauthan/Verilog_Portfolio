
# AMBA APB 3.0 Slave Peripheral

## Project Overview
This project is a synthesizable RTL implementation of a Memory-Mapped Slave peripheral compliant with the **AMBA APB v3.0 Protocol**. It functions as a 32-deep internal register file that allows an APB Master (such as a CPU) to perform read and write operations with zero wait-states.

## Key Features
- **Protocol Compliance:** Implements the official AMBA APB 3.0 State Machine (IDLE $\to$ SETUP $\to$ ACCESS).
- **Handshaking:** Correctly drives `PSEL`, `PENABLE`, and `PREADY` signals for robust communication.
- **Performance:** Optimized for zero wait-states (`PREADY` tied High) for immediate data availability.
- **Verification:** Verified using a SystemVerilog testbench featuring modular **Tasks** to emulate Bus Master driver behavior.

## File Structure
- **`rtl/apb_slave.sv`**: The APB Slave module wrapping a 32x32 bit memory array.
- **`tb/tb_apb_slave.sv`**: Self-checking testbench using `apb_write` and `apb_read` tasks.

## Simulation & Verification
The testbench validates the design by simulating a Bus Master performing the following sequence:
1.  **Write Operation:** Writes `0xDEAD_BEEF` to Address `0x10`.
2.  **Write Operation:** Writes `0xCAFE_F00D` to Address `0x20`.
3.  **Read Operation:** Reads back data from both addresses and compares it against expected values.

### Simulation Waveforms
The waveforms below demonstrate the successful execution of the protocol.

**1. Write Transaction (SETUP & ACCESS Phases)**
The screenshot below highlights the Write cycle. Note the transition from **SETUP** (`PSEL=1`, `PENABLE=0`) to **ACCESS** (`PSEL=1`, `PENABLE=1`), latching the data `0xDEAD_BEEF`.

![APB Write Transaction](YOUR_IMAGE_NAME_1.jpg)

**2. Read Transaction & Data Integrity**
This waveform shows the Read cycle. The Slave correctly drives `PRDATA` with the stored value, and the transcript confirms the data match with `[PASS]`.

![APB Read Transaction](YOUR_IMAGE_NAME_2.jpg)
