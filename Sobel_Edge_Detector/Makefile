# Project: Sobel Edge Detection Accelerator
# Target:  FPGA / ASIC Verification

# --- Toolchain ---
IVC     := iverilog
VVP     := vvp
PYTHON  := python3
MKDIR   := mkdir -p
RM      := rm -rf

# --- Configuration ---
SRC_DIR := rtl
TB_DIR  := tb
SIM_DIR := sim
SCR_DIR := scripts
DAT_DIR := data

IMG_W   := 128
IMG_H   := 128

# --- Artifacts ---
SRCS    := $(wildcard $(SRC_DIR)/*.v) $(wildcard $(TB_DIR)/*.v)
SIM_BIN := $(SIM_DIR)/sobel_sim.out
HEX_IN  := $(SIM_DIR)/image.hex
HEX_OUT := $(SIM_DIR)/output.hex
IMG_IN  := $(DAT_DIR)/source.jpg
IMG_OUT := $(SIM_DIR)/result.jpg

# --- Targets ---
.PHONY: all clean run verify

all: verify

$(SIM_DIR):
	@$(MKDIR) $(SIM_DIR)

# 1. Pre-Processing
$(HEX_IN): $(IMG_IN) $(SCR_DIR)/img_to_hex.py | $(SIM_DIR)
	@echo "[PY] Generating HEX stimulus..."
	@$(PYTHON) $(SCR_DIR)/img_to_hex.py --input $(IMG_IN) --width $(IMG_W) --height $(IMG_H)

# 2. Compilation
$(SIM_BIN): $(SRCS) | $(SIM_DIR)
	@echo "[IVL] Compiling RTL..."
	@$(IVC) -Wall -g2001 -o $(SIM_BIN) $(SRCS)

# 3. Simulation
$(HEX_OUT): $(SIM_BIN) $(HEX_IN)
	@echo "[VVP] Running simulation..."
	@$(VVP) -n $(SIM_BIN)

# 4. Post-Processing
$(IMG_OUT): $(HEX_OUT) $(SCR_DIR)/hex_to_img.py
	@echo "[PY] Reconstructing output image..."
	@$(PYTHON) $(SCR_DIR)/hex_to_img.py --input $(HEX_OUT) --output $(IMG_OUT) --width $(IMG_W) --height $(IMG_H)

verify: $(IMG_OUT)
	@echo "[DONE] Verification successful. Artifact: $(IMG_OUT)"

clean:
	@echo "[CLEAN] Removing artifacts..."
	@$(RM) $(SIM_DIR)
