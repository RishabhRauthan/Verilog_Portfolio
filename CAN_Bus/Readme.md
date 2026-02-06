# CAN 2.0A Bus Controller IP
**Language:** Verilog HDL (IEEE 1364-2001)  
**Target:** FPGA (Intel/Altera, Xilinx) / ASIC  
**Status:** Active Development (Phase 1: PHY & Basic TX)

---

## 1. Project Overview
This repository contains the synthesizable RTL implementation of a **Controller Area Network (CAN) 2.0A** bus controller. 

CAN is the backbone of modern automotive and industrial avionics networks, favored for its fault tolerance and differential signaling robustness. This IP core is designed to bridge a host CPU (or FPGA logic) to a physical CAN bus, handling the low-level protocol details like framing, arbitration, and error checking in hardware.

**Why Build This?**
To demonstrate a deep understanding of **asynchronous serial communication**, **collision avoidance protocols**, and **safety-critical hardware design** relevant to the Automotive Silicon industry (ISO 11898 standards).

---

## 2. Technical Specifications
The design targets the **CAN 2.0A (Standard Frame)** specification:

* **Protocol:** CAN 2.0A (11-bit Identifier).
* **Bus Interface:** 2-wire interface (TX/RX) mapping to Dominant (0) and Recessive (1) states.
* **Baud Rate:** Configurable via clock dividers (Target: 500 kbps - 1 Mbps).
* **Architecture:** Finite State Machine (FSM) based packet generation.

---

## 3. Current Architecture (Phase 1)
The project is currently in the **Physical Layer (PHY) & Framing** phase. The `can_tx_core` module implements the fundamental packet structure without bit-stuffing.

### **Transmitter State Machine**
The core utilizes a specialized Mealy/Moore hybrid FSM to sequence the frame:

1.  **IDLE:** Monitors bus state, waits for Host `START` signal.
2.  **SOF (Start of Frame):** Drives the bus to **Dominant (0)** to synchronize nodes.
3.  **Arbitration Field:** Shifts out the 11-bit Identifier (Priority). *Note: Logic assumes single-master for Phase 1.*
4.  **Control Field:** Transmits Data Length Code (DLC).
5.  **Data Field:** Serializes payload (0-8 bytes).
6.  **CRC Field:** (Placeholder for Polynomial calculation).
7.  **EOF (End of Frame):** Drives **Recessive (1)** to signal completion.

---

## 4. Directory Structure
```text
/
├── rtl/
│   ├── can_top.v       # Top-level wrapper
│   └── can_tx.v        # Transmitter Logic & FSM
├── tb/
│   └── tb_can.v        # Simulation Testbench
├── sim/                # Questa/ModelSim artifacts
└── docs/               # Waveforms and Specification notes
