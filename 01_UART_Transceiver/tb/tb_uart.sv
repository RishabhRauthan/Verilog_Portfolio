`timescale 1ns / 1ps

module tb_uart;
  // Parameters
  parameter CLK_FREQ = 50000000; 
  parameter BAUD_RATE = 460800; // Fast baud rate for simulation
  
  // Signals
  reg clk = 0;
  reg reset;
  reg tx_start;
  reg [7:0] tx_data_in;
  wire tx_done_tick, rx_done_tick;
  wire [7:0] rx_data_out;
  wire tx_line; 

  // Instantiate the Top Module (DUT)
  uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) 
    dut (
      .clk(clk), 
      .reset(reset), 
      .rx(tx_line), // Loopback: Connect TX wire to RX wire
      .tx(tx_line),
      .tx_start(tx_start), 
      .tx_data_in(tx_data_in),
      .tx_done_tick(tx_done_tick), 
      .rx_done_tick(rx_done_tick),
      .rx_data_out(rx_data_out)
    );

  // Clock Generation (50 MHz)
  always #10 clk = ~clk; 

  // Test Sequence
  initial begin
    // Initialize
    reset = 1; tx_start = 0; tx_data_in = 0;
    #100 reset = 0; #100;
    
    // TEST 1: Send 0x55
    tx_data_in = 8'h55; tx_start = 1; #20 tx_start = 0;
    
    // Wait for Receiver
    @(posedge rx_done_tick); 
    
    if (rx_data_out == 8'h55) 
        $display("SUCCESS: Received 0x55");
    else 
        $display("FAIL: Expected 0x55, Got %h", rx_data_out);

    // TEST 2: Send 0xA3
    #500; 
    tx_data_in = 8'hA3; tx_start = 1; #20 tx_start = 0;
    
    @(posedge rx_done_tick);
    
    if (rx_data_out == 8'hA3) 
        $display("SUCCESS: Received 0xA3");
    else 
        $display("FAIL: Expected 0xA3, Got %h", rx_data_out);
    
    #100 $finish;
  end
endmodule
