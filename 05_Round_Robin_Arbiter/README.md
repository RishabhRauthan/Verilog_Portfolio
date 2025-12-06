# 4-Port Round-Robin Arbiter

## Overview
A fair arbitration module that manages shared resource access among 4 agents. It uses a **Rotating Priority** scheme (Round-Robin) to ensure no agent starves, regardless of request density. This is a critical component in Network-on-Chip (NoC) routers and CPU Bus controllers.

## Key Features
- **Fairness:** Guarantees service to all requestors using a masked priority encoder.
- **Zero-Latency:** Combinational logic determines the next grant immediately.
- **Starvation Free:** Even if Agent 0 holds the request line high forever, the arbiter forces it to wait until Agents 1, 2, and 3 have been served.

## File Structure
- `rtl/round_robin_arbiter.sv`: Implements the Masking Logic and Priority Encoders.
- `tb/tb_arbiter.sv`: Verifies the rotation logic under heavy contention.

## Simulation
The testbench validates the **Saturation Scenario** where `req = 4'b1111` (Everyone wants access).
The Grants rotate cyclically: `0001` -> `0010` -> `0100` -> `1000` -> `0001`.
