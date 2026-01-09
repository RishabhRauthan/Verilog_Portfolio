`timescale 1ns / 1ps

module tb_sobel;

    // 1. Configuration Parameters
    parameter DATA_WIDTH = 8;
    parameter IMG_WIDTH  = 128;
    parameter IMG_HEIGHT = 128;
    
    // File Paths 
    localparam INPUT_FILE  = "sim/image.hex";
    localparam OUTPUT_FILE = "sim/output.hex";

    // 2. Signals
    reg                   clk;
    reg                   rst_n;
    reg                   enable;
    reg [DATA_WIDTH-1:0]  pixel_in;
    reg [7:0]             threshold;

    wire [DATA_WIDTH-1:0] pixel_out;
    wire                  valid_out;

    integer file_in, file_out;
    integer scan_res;

    // 3. DUT Instantiation
    sobel_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH)
    ) u_dut (
        .clk_i       (clk),
        .rst_n_i     (rst_n),
        .enable_i    (enable),
        .pixel_in    (pixel_in),
        .threshold_i (threshold),
        .pixel_out   (pixel_out),
        .valid_out   (valid_out)
    );

    // Clock Generation (100 MHz)
    always #5 clk = ~clk;

    // 4. Main Process
    initial begin
        // Setup Waves
        $dumpfile("sim/waveform.vcd");
        $dumpvars(0, tb_sobel);

        // Init
        clk       = 0;
        rst_n     = 0;
        enable    = 0;
        pixel_in  = 0;
        threshold = 100;

        // Try to open files
        file_in  = $fopen(INPUT_FILE, "r");
        file_out = $fopen(OUTPUT_FILE, "w");

        // SAFETY CHECK: Stop if file missing
        if (file_in == 0) begin
            $display("\n[ERROR] Input file not found: %s", INPUT_FILE);
            $display("Please run: python scripts/img_to_hex.py --output %s\n", INPUT_FILE);
            $stop; 
        end

        // Start Simulation
        $display("[INFO] Simulation Started. Processing %s...", INPUT_FILE);
        
        // Reset
        #20 rst_n = 1;
        #20;

        // Read Loop
        while (!$feof(file_in)) begin
            @(posedge clk);
            scan_res = $fscanf(file_in, "%h\n", pixel_in);
            
            if (scan_res == 1) 
                enable = 1;
            else 
                enable = 0;
        end

        // Flush Pipeline
        @(posedge clk);
        enable = 0;
        #1000; 

        // Close and Exit
        $fclose(file_in);
        $fclose(file_out);
        $display("[INFO] Simulation Complete. Results saved to %s", OUTPUT_FILE);
        $stop;
    end

    // 5. Output Capture
    always @(posedge clk) begin
        if (valid_out) begin
            $fwrite(file_out, "%h\n", pixel_out);
        end
    end

endmodule
