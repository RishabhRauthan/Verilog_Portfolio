# Real-Time Sobel Edge Detection Accelerator

![Languages](https://img.shields.io/badge/Languages-Verilog%20%7C%20Python-blue)
![RTL Standard](https://img.shields.io/badge/Standard-Verilog--2001-blue)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20%7C%20Questa-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 1. Project Overview
This project hosts a synthesizable RTL implementation of a high-throughput **Sobel Edge Detection Accelerator**, designed to serve as a low-latency vision pre-processor for embedded systems.
In modern **Autonomous Driving (ADAS)** and **Industrial Machine Vision** pipelines, software-based edge detection introduces variable latency (jitter) due to OS interrupts and frame-buffering overhead. This hardware accelerator solves that bottleneck by offloading the pixel-intensive gradient calculation to an FPGA.
The core utilizes a **Streaming Systolic Architecture** to process video data in real-time without external memory buffering. By performing edge extraction at the hardware level (immediately after the camera sensor), downstream CPUs are relieved of up to 90% of the computational load, allowing them to focus on high-level decision-making tasks like lane keeping or object classification.

**Key Design:**
* **Zero-Frame Latency:** Uses internal Circular Line Buffers to process pixels the instant they arrive, rather than waiting for a full frame to store in DDR.
* **Deterministic Timing:** Guarantees a fixed processing delay (~5 microseconds), making it suitable for safety-critical control loops.
* **Resource Optimized:** Implements a multiplier-less "Manhattan Distance" approximation to minimize logic footprint on low-cost FPGA fabrics.

## 2. Technical Specifications
| Parameter | Specification |
| :--- | :--- |
| **Throughput** | 1 Pixel / Clock Cycle |
| **Latency** | Line Buffer Fill + 3 Pipeline Stages |
| **Arithmetic** | 11-bit Signed Fixed-Point |
| **Memory** | 2 x Block RAM (Dual Port) |
| **Input Interface** | 8-bit Grayscale (Stream) + Valid |
| **Output Interface** | 8-bit Binary (Stream) + Valid |
| **Dynamic Control** | Real-time Threshold Adjustment Port |

## Verification Workflow
The verification environment utilizes a Make-driven flow for reproducible testing.

### Prerequisites
* Icarus Verilog (`iverilog`, `vvp`)
* Python 3.8+ (`numpy`, `opencv-python`)
* Make

### Execution Steps
The project includes a `Makefile` to automate the stimulus generation, compilation, and analysis pipeline.

**1. Run Full Verification**
Execute the complete flow (Image $\to$ Hex $\to$ RTL Sim $\to$ Output Image):
```bash
make
```



## Manual Execution: ##

**Generate Stimulus:**

```Bash
python scripts/img_to_hex.py --input data/source.jpg
```
**Compile & Simulate:**

```Bash
\iverilog -o sim/sobel_sim rtl/*.v tb/tb_sobel.v
vvp sim/sobel_sim
```

**Analyze Output:**

```Bash

python scripts/hex_to_img.py --input sim/output.hex
```



## Micro-Architecture

```mermaid
flowchart LR
    %% 1. STYLING DEFINITIONS
    classDef input fill:#fff9c4,stroke:#fbc02d,stroke-width:2px
    classDef memory fill:#d1e7dd,stroke:#0f5132,stroke-width:2px
    classDef reg fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef math fill:#e2e3e5,stroke:#495057,stroke-width:2px
    classDef control fill:#f8d7da,stroke:#842029,stroke-width:2px

    %% ==========================================
    %% 2. DIAGRAM LOGIC
    %% ==========================================

    %% BLOCK A: MEMORY
    subgraph Block_A ["Block A: Line Buffer Unit (Memory)"]
        direction TB
        WP["Write Pointer (Counter)"]:::control
        RAM0["Line RAM 0 (Row N-1)"]:::memory
        RAM1["Line RAM 1 (Row N-2)"]:::memory
    end

    %% BLOCK B: REGISTERS (Nested Subgraphs Fixed)
    subgraph Block_B ["Block B: Sliding Window Logic"]
        direction TB
        
        subgraph Row2 ["Row 2 (Current)"]
            direction RL
            p8["Reg p8"]:::reg
            p7["Reg p7"]:::reg
            p6["Reg p6"]:::reg
        end
        
        subgraph Row1 ["Row 1 (Previous)"]
            direction RL
            p5["Reg p5"]:::reg
            p4["Reg p4"]:::reg
            p3["Reg p3"]:::reg
        end
        
        subgraph Row0 ["Row 0 (Oldest)"]
            direction RL
            p2["Reg p2"]:::reg
            p1["Reg p1"]:::reg
            p0["Reg p0"]:::reg
        end
    end

    %% BLOCK C: MATH CORE
    subgraph Block_C ["Block C: Sobel Core (Math)"]
        direction LR
        Gx["Gx Adder Tree"]:::math
        Gy["Gy Adder Tree"]:::math
        AbsX["Abs(Gx)"]:::math
        AbsY["Abs(Gy)"]:::math
        Sum["Adder (Sum)"]:::math
        Thresh["Threshold Comparator"]:::math
    end

    %% EXTERNAL NODES
    PI["Pixel In (8-bit)"]:::input
    PO["Pixel Out (1-bit Edge)"]:::input
    EN["Enable Signal"]:::control

    %% ==========================================
    %% 3. CONNECTIONS
    %% ==========================================

    %% Control Flow
    EN -.-> WP & p8 & p5 & p2
    WP -.-> RAM0 & RAM1

    %% Data Flow - Input & Memory
    PI --> RAM0 & p8
    RAM0 --> RAM1 & p5
    RAM1 --> p2

    %% Data Flow - Register Shifts (Right to Left)
    p8 --> p7
    p7 --> p6
    p5 --> p4
    p4 --> p3
    p2 --> p1
    p1 --> p0

    %% Data Flow - To Math Core (The "Spaghetti" wires)
    %% Grouping them for slightly cleaner rendering
    p0 & p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8 --> Gx
    p0 & p1 & p2 & p3 & p4 & p5 & p6 & p7 & p8 --> Gy

    %% Math Flow
    Gx --> AbsX
    Gy --> AbsY
    AbsX --> Sum
    AbsY --> Sum
    Sum --> Thresh
    Thresh --> PO
