# Asynchronous FIFO (Clock Domain Crossing)

## Overview
This project implements a parameterizable **Asynchronous FIFO** to safely transfer data between two different clock domains (100MHz Write / 40MHz Read). It utilizes **Gray Code synchronization** to prevent metastability and ensure reliable Empty/Full flag generation.

## Key Features
- **Dual-Clock Support:** Handles completely asynchronous Read/Write clocks.
- **Gray Code Pointers:** Implements Binary-to-Gray and Gray-to-Binary conversion for safe CDC (Clock Domain Crossing).
- **2-Stage Synchronizers:** Mitigates metastability when passing pointers between domains.
- **Robust Logic:** Pessimistic Full/Empty generation prevents overflow/underflow.

## File Structure
- `rtl/async_fifo.sv`: Top-level wrapper containing the Memory, Synchronizers, and Pointer Logic modules.
- `tb/tb_async_fifo.sv`: Testbench generating 100MHz and 40MHz clocks to verify data integrity.

## Simulation
The testbench validates:
1. **Burst Write:** Filling the FIFO depth (16 slots) at 100MHz.
2. **Safe Full Flag:** Ensuring `wfull` asserts correctly.
3. **Slow Read:** Reading data out at 40MHz.
4. **Data Integrity:** Ensuring Data In matches Data Out exactly.
