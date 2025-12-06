`timescale 1ns / 1ps

module round_robin_arbiter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] req,   // Request Vector
    output reg  [3:0] gnt    // Grant Vector (One-Hot)
);

  reg [3:0] mask; // Pointer to who has priority
  wire [3:0] req_masked;
  wire [3:0] masked_gnt;
  wire [3:0] unmasked_gnt;
  
  // 1. Mask Logic: Filter out requests that have already been served
  assign req_masked = req & mask;

  // 2. Fixed Priority Encoder (Find First Set Bit)
  
  // High Priority Group (Based on Mask)
  assign masked_gnt[0] = req_masked[0];
  assign masked_gnt[1] = req_masked[1] & ~req_masked[0];
  assign masked_gnt[2] = req_masked[2] & ~req_masked[1] & ~req_masked[0];
  assign masked_gnt[3] = req_masked[3] & ~req_masked[2] & ~req_masked[1] & ~req_masked[0];

  // Low Priority Group (Wrap Around - when mask has no matches)
  assign unmasked_gnt[0] = req[0];
  assign unmasked_gnt[1] = req[1] & ~req[0];
  assign unmasked_gnt[2] = req[2] & ~req[1] & ~req[0];
  assign unmasked_gnt[3] = req[3] & ~req[2] & ~req[1] & ~req[0];

  // 3. Final Grant Logic
  always @(*) begin
      if (|req_masked) gnt = masked_gnt;
      else             gnt = unmasked_gnt;
  end

  // 4. Update the Mask (Rotate Priority)
  always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          mask <= 4'b1111; // Reset: Everyone eligible
      end else begin
          case (1'b1) 
              gnt[0]: mask <= 4'b1110; // 0 won, check 1,2,3 next
              gnt[1]: mask <= 4'b1100; // 1 won, check 2,3 next
              gnt[2]: mask <= 4'b1000; // 2 won, check 3 next
              gnt[3]: mask <= 4'b1111; // 3 won, RESET mask to all 1s immediately
              default: begin
              end 
          endcase
      end
  end

endmodule
