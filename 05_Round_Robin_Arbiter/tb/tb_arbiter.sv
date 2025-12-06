`timescale 1ns / 1ps

module tb_arbiter;

  reg        clk;
  reg        rst_n;
  reg  [3:0] req;
  wire [3:0] gnt;

  // Instantiate Arbiter
  round_robin_arbiter dut (
    .clk(clk), .rst_n(rst_n), .req(req), .gnt(gnt)
  );

  // Clock Gen
  initial begin
    clk = 0;
    forever #5 clk = ~clk; 
  end

  initial begin
    // Initialize
    rst_n = 0; req = 0;
    #15 rst_n = 1;
    
    // --- TEST 1: Single Request ---
    req = 4'b0001; #10; // Agent 0 asks
    if(gnt == 4'b0001) $display("PASS: Agent 0 Granted");
    
    req = 4'b0100; #10; // Agent 2 asks
    if(gnt == 4'b0100) $display("PASS: Agent 2 Granted");

    // --- TEST 2: Round Robin Rotation (Saturation) ---
    req = 4'b1111; // Everyone asks at once!
    
    // It should rotate 0 -> 1 -> 2 -> 3 -> 0 ...
    #10; $display("Time: %0t | Gnt: %b (Agent 3 finished, Expect 0)", $time, gnt);
    #10; $display("Time: %0t | Gnt: %b (Expect 1)", $time, gnt);
    #10; $display("Time: %0t | Gnt: %b (Expect 2)", $time, gnt);
    #10; $display("Time: %0t | Gnt: %b (Expect 3)", $time, gnt);
    #10; $display("Time: %0t | Gnt: %b (Expect 0)", $time, gnt);
    
    #50 $finish;
  end
endmodule
