import argparse
import cv2
import numpy as np
import os
import sys

def parse_arguments():
    parser = argparse.ArgumentParser(description="Reconstruct image from Verilog hex simulation output.")
    parser.add_argument('--input', type=str, default='sim/output_image.hex', help='Path to input hex file')
    parser.add_argument('--output', type=str, default='sim/result_edge.jpg', help='Path to output image file')
    parser.add_argument('--width', type=int, default=128, help='Target image width')
    parser.add_argument('--height', type=int, default=128, help='Target image height')
    return parser.parse_args()

def hex_to_image(args):
    if not os.path.exists(args.input):
        sys.stderr.write(f"Error: Input file '{args.input}' not found.\n")
        sys.exit(1)

    print(f"Processing: {args.input}")

    try:
        with open(args.input, 'r') as f:
            # Read lines, strip whitespace, and filter empty lines
            hex_data = [line.strip() for line in f if line.strip()]

        expected_pixels = args.width * args.height
        data_len = len(hex_data)

        if data_len < expected_pixels:
            print(f"Warning: Insufficient data. Found {data_len}, expected {expected_pixels}. Padding with zeros.")
            hex_data += ['00'] * (expected_pixels - data_len)

        # Convert hex strings to integers
        pixel_vals = [int(p, 16) for p in hex_data[:expected_pixels]]
        
        # Convert to Numpy array and reshape
        img_array = np.array(pixel_vals, dtype=np.uint8).reshape((args.height, args.width))
        
        # Ensure output directory exists
        os.makedirs(os.path.dirname(args.output), exist_ok=True)
        
        cv2.imwrite(args.output, img_array)
        print(f"Success: Output saved to {args.output}")

    except ValueError as e:
        sys.stderr.write(f"Error: Malformed hex data. {e}\n")
        sys.exit(1)
    except Exception as e:
        sys.stderr.write(f"Error: {e}\n")
        sys.exit(1)

if __name__ == "__main__":
    args = parse_arguments()
    hex_to_image(args)
