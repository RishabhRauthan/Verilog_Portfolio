`timescale 1ns / 1ps
`default_nettype none

module sobel_top #(
    parameter DATA_WIDTH = 8,
    parameter IMG_WIDTH  = 128
)(
    input  wire                  clk_i,
    input  wire                  rst_n_i,
    input  wire                  enable_i, 
    input  wire [DATA_WIDTH-1:0] pixel_in,
    input  wire [7:0]            threshold_i, 
    
    output wire [DATA_WIDTH-1:0] pixel_out,
    output wire                  valid_out
);

    // Internal Wires
    wire [DATA_WIDTH-1:0] tap0_data, tap1_data, tap2_data;

    reg [DATA_WIDTH-1:0] p0, p1, p2;
    reg [DATA_WIDTH-1:0] p3, p4, p5;
    reg [DATA_WIDTH-1:0] p6, p7, p8;

    line_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH)
    ) u_line_buffer (
        .clk_i    (clk_i),
        .rst_n_i  (rst_n_i),
        .wen_i    (enable_i),
        .data_i   (pixel_in),
        .tap0_o   (tap0_data), 
        .tap1_o   (tap1_data), 
        .tap2_o   (tap2_data) 
    );

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            {p0,p1,p2,p3,p4,p5,p6,p7,p8} <= 0;
        end else if (enable_i) begin
            // Shift Row 2 (Newest Data)
            p8 <= tap0_data; // Incoming pixel
            p7 <= p8;
            p6 <= p7;

            // Shift Row 1 (Middle Data)
            p5 <= tap1_data; // From Line Buffer 0
            p4 <= p5;
            p3 <= p4;

            // Shift Row 0 (Oldest Data)
            p2 <= tap2_data; // From Line Buffer 1
            p1 <= p2;
            p0 <= p1;
        end
    end

    sobel_core #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_sobel_core (
        .clk_i       (clk_i),
        .rst_n_i     (rst_n_i),
        .valid_i     (enable_i),
        .threshold_i (threshold_i),
        
        // Connect Window to Core
        .p0_i(p0), .p1_i(p1), .p2_i(p2),
        .p3_i(p3), .p4_i(p4), .p5_i(p5),
        .p6_i(p6), .p7_i(p7), .p8_i(p8),
        
        .pixel_o     (pixel_out),
        .valid_o     (valid_out)
    );

endmodule
`default_nettype wire
