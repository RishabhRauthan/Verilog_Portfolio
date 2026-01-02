# Real-Time Sobel Edge Detection Accelerator

![Language](https://img.shields.io/badge/language-Verilog-blue)
![Platform](https://img.shields.io/badge/platform-FPGA%20%2F%20ASIC-orange)
![Verification](https://img.shields.io/badge/verification-Python%20Co--Sim-green)
![Status](https://img.shields.io/badge/status-In%20Development-yellow)

## Project Overview
This project implements a high-throughput, pipelined hardware accelerator for **real-time edge detection** using the Sobel operator. 
Designed in **Verilog HDL**, the architecture is optimized for FPGA implementation, utilizing **inferred Block RAMs (BRAM)** for line buffering and efficient arithmetic logic for convolution.
The system processes video data streams without CPU intervention, demonstrating advanced digital design concepts including **circular memory buffering**, **systolic arrays**, and **Python-hardware co-simulation**.

## Micro-Architecture
The design follows a streaming architecture to ensure **1 pixel/clock throughput**.

```mermaid
graph LR
    %% -- Styles --
    classDef mem fill:#e1f5fe,stroke:#0277bd,stroke-width:2px,color:#000
    classDef logic fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px,color:#000
    classDef io fill:#fff9c4,stroke:#fbc02d,stroke-width:2px,color:#000

    %% -- Nodes --
    Pixel_In(Pixel Stream):::io
    
    subgraph Line_Buffer_Unit [Memory Subsystem]
        LB1[Line Buffer 0\n(BRAM)]:::mem
        LB2[Line Buffer 1\n(BRAM)]:::mem
    end
    
    subgraph Kernel_Unit [Convolution Core]
        Window[3x3 Sliding Window]:::logic
        Sobel_X[Gx Calc]:::logic
        Sobel_Y[Gy Calc]:::logic
        Abs[Magnitude & Threshold]:::logic
    end
    
    Pixel_Out(Edge Detected Pixel):::io

    %% -- Connections --
    Pixel_In --> LB1
    LB1 --> LB2
    
    Pixel_In --> Window
    LB1 --> Window
    LB2 --> Window
    
    Window --> Sobel_X
    Window --> Sobel_Y
    
    Sobel_X --> Abs
    Sobel_Y --> Abs
    Abs --> Pixel_Out
