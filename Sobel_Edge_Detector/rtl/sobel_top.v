`timescale 1ns / 1ps
`default_nettype none

module sobel_top #(
    parameter DATA_WIDTH = 8,
    parameter IMG_WIDTH  = 128
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  en,
    input  wire [DATA_WIDTH-1:0] pixel_in,
    
    output wire [DATA_WIDTH-1:0] pixel_out,
    output wire                  valid_out
);

    wire [DATA_WIDTH-1:0] t0, t1, t2;
    
    reg [DATA_WIDTH-1:0] p0, p1, p2; 
    reg [DATA_WIDTH-1:0] p3, p4, p5; 
    reg [DATA_WIDTH-1:0] p6, p7, p8; 
    
    wire valid_buffer;

    line_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH)
    ) u_line_buffer (
        .clk_i    (clk),
        .rst_n_i  (rst_n),
        .valid_i  (en),
        .pixel_i  (pixel_in),
        .tap0_o   (t0),
        .tap1_o   (t1),
        .tap2_o   (t2)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {p0, p1, p2} <= 0;
            {p3, p4, p5} <= 0;
            {p6, p7, p8} <= 0;
        end else if (en) begin

            p8 <= t0; p7 <= p8; p6 <= p7;
            
            p5 <= t1; p4 <= p5; p3 <= p4;
            
            p2 <= t2; p1 <= p2; p0 <= p1;
        end
    end

    sobel_core #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_sobel_core (
        .clk_i   (clk),
        .rst_n_i (rst_n),
        .valid_i (en),
        
        .p0_i(p0), .p1_i(p1), .p2_i(p2),
        .p3_i(p3), .p4_i(p4), .p5_i(p5),
        .p6_i(p6), .p7_i(p7), .p8_i(p8),
        
        .pixel_o (pixel_out),
        .valid_o (valid_out)
    );

endmodule
`default_nettype wire
