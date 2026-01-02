`timescale 1ns / 1ps
`default_nettype none

module line_buffer #(
    parameter DATA_WIDTH = 8,
    parameter IMG_WIDTH  = 128
)(
    input  wire                  clk_i,
    input  wire                  rst_n_i,
    input  wire                  valid_i,
    input  wire [DATA_WIDTH-1:0] pixel_i,

    output wire [DATA_WIDTH-1:0] tap0_o, // Current pixel
    output wire [DATA_WIDTH-1:0] tap1_o, // 1 Row delayed
    output wire [DATA_WIDTH-1:0] tap2_o  // 2 Rows delayed
);

    // Pointer width calculation based on image width
    localparam PTR_WIDTH = $clog2(IMG_WIDTH);

    // Inferred Block RAMs for line buffering
    reg [DATA_WIDTH-1:0] line_ram0_r [0:IMG_WIDTH-1];
    reg [DATA_WIDTH-1:0] line_ram1_r [0:IMG_WIDTH-1];

    reg [PTR_WIDTH-1:0]  wr_ptr_r;
    reg [DATA_WIDTH-1:0] lb0_out_r;
    reg [DATA_WIDTH-1:0] lb1_out_r;

    // RAM Read/Write & Pointer Logic
    always @(posedge clk_i) begin
        if (valid_i) begin
            // Read-First behavior (Standard for Line Buffers)
            lb0_out_r <= line_ram0_r[wr_ptr_r];
            lb1_out_r <= line_ram1_r[wr_ptr_r];

            // Write new data into RAMs
            // Stream: pixel_i -> RAM0 -> RAM1
            line_ram0_r[wr_ptr_r] <= pixel_i;
            line_ram1_r[wr_ptr_r] <= lb0_out_r;
        end
    end

    // Pointer Management
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            wr_ptr_r <= {PTR_WIDTH{1'b0}};
        end else if (valid_i) begin
            if (wr_ptr_r == IMG_WIDTH - 1)
                wr_ptr_r <= {PTR_WIDTH{1'b0}};
            else
                wr_ptr_r <= wr_ptr_r + 1'b1;
        end
    end

    // Output Assignments
    assign tap0_o = pixel_i;
    assign tap1_o = lb0_out_r;
    assign tap2_o = lb1_out_r;

endmodule

`default_nettype wire
