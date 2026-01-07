`timescale 1ns / 1ps
`default_nettype none

module sobel_core #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk_i,
    input  wire                  rst_n_i,
    input  wire                  valid_i,
    input  wire [7:0]            threshold_i,
    
    // Window Inputs (3x3)
    input  wire [DATA_WIDTH-1:0] p0_i, p1_i, p2_i,
    input  wire [DATA_WIDTH-1:0] p3_i, p4_i, p5_i,
    input  wire [DATA_WIDTH-1:0] p6_i, p7_i, p8_i,

    output reg  [DATA_WIDTH-1:0] pixel_o,
    output reg                   valid_o
);

    //Pipeline Stages

    reg signed [10:0] gx_reg, gy_reg;
    
    reg signed [10:0] abs_gx_reg, abs_gy_reg;
    
    reg [1:0] valid_pipe_r; 

    // Internal wire for Stage 3 calculation
    reg [10:0] sum;

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            gx_reg       <= 0;
            gy_reg       <= 0;
            abs_gx_reg   <= 0;
            abs_gy_reg   <= 0;
            pixel_o      <= 0;
            valid_o      <= 0;
            valid_pipe_r <= 0;
        end else begin
         
            if (valid_i) begin
                // Gx = (p2 + 2*p5 + p8) - (p0 + 2*p3 + p6)
                gx_reg <= ($signed({1'b0, p2_i}) + $signed({p5_i, 1'b0}) + $signed({1'b0, p8_i})) - 
                          ($signed({1'b0, p0_i}) + $signed({p3_i, 1'b0}) + $signed({1'b0, p6_i}));
                
                // Gy = (p0 + 2*p1 + p2) - (p6 + 2*p7 + p8)
                gy_reg <= ($signed({1'b0, p0_i}) + $signed({p1_i, 1'b0}) + $signed({1'b0, p2_i})) - 
                          ($signed({1'b0, p6_i}) + $signed({p7_i, 1'b0}) + $signed({1'b0, p8_i}));
            end
            
            // Shift the Valid Signal into the pipeline
            valid_pipe_r[0] <= valid_i;

            if (gx_reg < 0) abs_gx_reg <= -gx_reg;
            else            abs_gx_reg <= gx_reg;

            if (gy_reg < 0) abs_gy_reg <= -gy_reg;
            else            abs_gy_reg <= gy_reg;

            // Shift Valid Signal to next stage
            valid_pipe_r[1] <= valid_pipe_r[0];

            sum = abs_gx_reg + abs_gy_reg;

            // Check against the Dynamic Input Threshold
            if (sum > threshold_i)
                pixel_o <= 8'hFF; // White
            else
                pixel_o <= 8'h00; // Black

            // Output Valid matches the data valid
            valid_o <= valid_pipe_r[1]; 
        end
    end

endmodule
`default_nettype wire
