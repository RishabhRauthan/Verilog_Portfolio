`timescale 1ns / 1ps

module tb_sobel;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter IMG_WIDTH  = 128;
    parameter IMG_HEIGHT = 128;
    
    // Inputs to DUT
    reg                   clk;
    reg                   rst_n;
    reg                   enable;
    reg [DATA_WIDTH-1:0]  pixel_in;
    reg [7:0]             threshold;

    // Outputs from DUT
    wire [DATA_WIDTH-1:0] pixel_out;
    wire                  valid_out;

    // File Handlers
    integer file_in, file_out;
    integer scan_res;
    integer i;

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

    // Clock Generation (10ns period = 100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize Signals
        clk       = 0;
        rst_n     = 0;
        enable    = 0;
        pixel_in  = 0;
        threshold = 100;


        file_in  = $fopen("sim/image.hex", "r");
        file_out = $fopen("sim/output.hex", "w");

        if (file_in == 0) begin
            $display("ERROR: Could not open sim/image.hex");
            $finish;
        end

        // Reset Sequence
        $display("Applying Reset...");
        #20 rst_n = 1;
        #20;

        // Process Image
        $display("Starting Processing...");
        
        // Loop through every pixel in the file
        while (!$feof(file_in)) begin
            @(posedge clk);
            scan_res = $fscanf(file_in, "%h\n", pixel_in);
            
            // Only assert enable if we actually read data
            if (scan_res == 1) begin
                enable = 1;
            end else begin
                enable = 0;
            end
        end

        // End of Stream
        @(posedge clk);
        enable = 0;
        
        // Wait for pipeline to flush
        #500;
        
        // Cleanup
        $fclose(file_in);
        $fclose(file_out);
        $display("Simulation Complete. Output written to sim/output.hex");
        $finish;
    end

    always @(posedge clk) begin
        if (valid_out) begin
            $fwrite(file_out, "%h\n", pixel_out);
        end
    end

endmodule
