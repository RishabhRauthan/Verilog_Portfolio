`timescale 1ns / 1ps
`default_nettype none

module sobel_core #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk_i,
    input  wire                  rst_n_i,
    input  wire                  valid_i,
    
    input  wire [DATA_WIDTH-1:0] p0_i, p1_i, p2_i,
    input  wire [DATA_WIDTH-1:0] p3_i, p4_i, p5_i,
    input  wire [DATA_WIDTH-1:0] p6_i, p7_i, p8_i,

    output reg  [DATA_WIDTH-1:0] pixel_o,
    output reg                   valid_o
);

    reg signed [10:0] gx, gy;
    reg signed [10:0] abs_gx, abs_gy;
    reg        [10:0] sum;

    localparam THRESHOLD = 100;

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            gx      <= 0;
            gy      <= 0;
            abs_gx  <= 0;
            abs_gy  <= 0;
            sum     <= 0;
            pixel_o <= 0;
            valid_o <= 0;
        end else if (valid_i) begin
         
            gx <= ($signed({1'b0, p2_i}) + $signed({p5_i, 1'b0}) + $signed({1'b0, p8_i})) - 
                  ($signed({1'b0, p0_i}) + $signed({p3_i, 1'b0}) + $signed({1'b0, p6_i}));
                  
            gy <= ($signed({1'b0, p0_i}) + $signed({p1_i, 1'b0}) + $signed({1'b0, p2_i})) - 
                  ($signed({1'b0, p6_i}) + $signed({p7_i, 1'b0}) + $signed({1'b0, p8_i}));
            abs_gx <= (gx < 0) ? -gx : gx;
            abs_gy <= (gy < 0) ? -gy : gy;

            sum = abs_gx + abs_gy;
            
            if (sum > THRESHOLD)
                pixel_o <= 8'hFF;
            else
                pixel_o <= 8'h00;
                
            valid_o <= 1'b1;
        end else begin
            valid_o <= 1'b0;
        end
    end

endmodule
`default_nettype wire
