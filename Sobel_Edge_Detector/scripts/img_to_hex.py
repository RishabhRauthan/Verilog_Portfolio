import cv2
import os
import sys

# Configuration
INPUT_IMAGE = 'test_image.png'
OUTPUT_FILE = 'sim/image.hex'
IMG_WIDTH = 128
IMG_HEIGHT = 128

def generate_hex():
  
    if not os.path.exists(INPUT_IMAGE):
        print(f"[Error] Input file '{INPUT_IMAGE}' not found.")
        sys.exit(1)

    # Read image in grayscale mode
    img = cv2.imread(INPUT_IMAGE, 0)
    
    if img is None:
        print(f"[Error] Failed to load '{INPUT_IMAGE}'. Check file format.")
        sys.exit(1)

    # Resize to target dimensions for simulation
    img_resized = cv2.resize(img, (IMG_WIDTH, IMG_HEIGHT))
    
    # Ensure output directory exists
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)

    try:
        with open(OUTPUT_FILE, 'w') as f:
            for row in range(IMG_HEIGHT):
                for col in range(IMG_WIDTH):
                    # Write pixel value as 2-digit hex
                    f.write(f"{img_resized[row, col]:02x}\n")
        
        print(f"[Success] Generated {OUTPUT_FILE} ({IMG_WIDTH}x{IMG_HEIGHT})")
        
    except IOError as e:
        print(f"[Error] File I/O failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    generate_hex()
