```mermaid
flowchart LR
 subgraph Block_A["Block A: Line Buffer Unit (Memory)"]
    direction TB
        WP["Write Pointer (Counter)"]
        RAM0["Line RAM 0 (Row N-1)"]
        RAM1["Line RAM 1 (Row N-2)"]
  end
 subgraph Row2["Row 2 (Current)"]
    direction RL
        p8["Reg p8"]
        p7["Reg p7"]
        p6["Reg p6"]
  end
 subgraph Row1["Row 1 (Previous)"]
    direction RL
        p5["Reg p5"]
        p4["Reg p4"]
        p3["Reg p3"]
  end
 subgraph Row0["Row 0 (Oldest)"]
    direction RL
        p2["Reg p2"]
        p1["Reg p1"]
        p0["Reg p0"]
  end
 subgraph Block_B["Block B: Sliding Window Logic (Registers)"]
    direction TB
        Row2
        Row1
        Row0
  end
 subgraph Block_C["Block C: Sobel Core (Math)"]
    direction LR
        Gx["Gx Adder Tree"]
        Gy["Gy Adder Tree"]
        AbsX["Abs(Gx)"]
        AbsY["Abs(Gy)"]
        Sum["Adder (Sum)"]
        Thresh["Threshold Comparator"]
  end
    WP -.-> RAM0 & RAM1
    p8 --> p7 & Gx & Gy
    p7 --> p6 & Gx & Gy
    p5 --> p4 & Gx & Gy
    p4 --> p3 & Gx & Gy
    p2 --> p1 & Gx & Gy
    p1 --> p0 & Gx & Gy
    PI["Pixel In (8-bit)"] --> RAM0 & p8
    RAM0 --> RAM1 & p5
    RAM1 --> p2
    p0 --> Gx & Gy
    p3 --> Gx & Gy
    p6 --> Gx & Gy
    Gx --> AbsX
    Gy --> AbsY
    AbsX --> Sum
    AbsY --> Sum
    Sum --> Thresh
    Thresh --> PO["Pixel Out (1-bit Edge)"]
    EN["Enable Signal"] -.-> WP & p8 & p5 & p2

     PI:::input
     EN:::control
     WP:::control
     RAM0:::memory
     RAM1:::memory
     p8:::reg
     p7:::reg
     p6:::reg
     p5:::reg
     p4:::reg
     p3:::reg
     p2:::reg
     p1:::reg
     p0:::reg
     Gx:::math
     Gy:::math
     AbsX:::math
     AbsY:::math
     Sum:::math
     Thresh:::math
     PO:::input
    classDef input fill:#fff9c4,stroke:#fbc02d,stroke-width:2px
    classDef memory fill:#d1e7dd,stroke:#0f5132,stroke-width:2px
    classDef reg fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef math fill:#e2e3e5,stroke:#495057,stroke-width:2px
    classDef control fill:#f8d7da,stroke:#842029,stroke-width:2px

## Technical Specifications

| Feature | Specification |

| **HDL Standard** | Verilog-2001 (IEEE 1364-2001) |
| **Clock Domain** | Single Synchronous Clock |
| **Throughput** | 1 Pixel / Clock Cycle |
| **Latency** | ~130 Cycles (Line Buffer Fill + Pipeline Depth) |
| **Memory Architecture** | Inferred Dual-Port Block RAM (Circular Buffer) |
| **Arithmetic** | 11-bit Signed Fixed-Point (Internal) |
| **Resolution** | Parameterizable (Default: 128x128) |

## Directory Structure

* **rtl/**: Synthesizable source code.
* `sobel_top.v`: Top-level integration module.
* `sobel_core.v`: 3-stage pipeline for gradient calculation.
* `line_buffer.v`: Memory controller with BRAM inference.


* **tb/**: Simulation testbench files.
* `tb_sobel.v`: Stimulus driver and output monitor.


* **scripts/**: Python utility scripts.
* `img_to_hex.py`: Converts bitmap images to memory initialization files.
* `hex_to_img.py`: Reconstructs output images from simulation dumps.


* **sim/**: Simulation artifacts and waveform dumps.

## Verification Flow

The verification strategy employs a file-based constraint-random approach.

1. **Stimulus Generation**: The `img_to_hex.py` script resizes the input image and serializes pixel data into a hex format readable by Verilog `$readmemh`.
2. **RTL Simulation**: The testbench drives the hex data into the DUT (Device Under Test) on every clock cycle, mimicking a standard video interface (e.g., AXI-Stream or VGA).
3. **Output Reconstruction**: The simulation captures the output stream into a log file, which is reconstructed by `hex_to_img.py` for visual inspection of edge detection quality.

## Usage Instructions

### prerequisites

* Python 3.8+ (NumPy, OpenCV)
* Icarus Verilog or equivalent simulator (ModelSim/Vivado/Questa)

### Execution Steps

1. **Generate Test Vector**
```bash
python scripts/img_to_hex.py --input raw_data/lena.jpg

```


2. **Run Simulation**
```bash
iverilog -o sim/sobel_sim rtl/*.v tb/tb_sobel.v
vvp sim/sobel_sim

```


3. **Verify Output**
```bash
python scripts/hex_to_img.py --input sim/output_image.hex

```



## License

MIT License

```

```
