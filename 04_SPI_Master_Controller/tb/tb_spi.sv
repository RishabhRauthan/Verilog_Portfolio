`timescale 1ns / 1ps

module tb_spi;

  reg        clk;
  reg        rst_n;
  reg        start;
  reg  [7:0] data_in;
  wire [7:0] data_out;
  wire       done;
  
  // Config
  reg        cpol;
  reg        cpha;
  
  // SPI Interface
  wire       sclk;
  wire       mosi;
  wire       miso;
  wire       cs_n;

  // LOOPBACK: Connect MOSI directly to MISO
  assign miso = mosi;

  // Instantiate SPI Master
  spi_master #(.CLK_DIV(4)) dut (
    .clk(clk), .rst_n(rst_n), .start(start),
    .data_in(data_in), .data_out(data_out), .done(done),
    .cpol(cpol), .cpha(cpha),
    .sclk(sclk), .mosi(mosi), .miso(miso), .cs_n(cs_n)
  );

  // Clock Generation (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk; 
  end

  initial begin
    // Initialize
    rst_n = 0; start = 0; data_in = 0;
    cpol = 0; cpha = 0;
    #20 rst_n = 1; #20;

    // --- TEST 1: MODE 0 (CPOL=0, CPHA=0) ---
    cpol = 0; cpha = 0;
    data_in = 8'hA5; // Binary 10100101
    
    start = 1; #10 start = 0;
    wait(done); #20;
    
    if (data_out == 8'hA5) 
        $display("SUCCESS: Mode 0 (0xA5) Matched");
    else 
        $display("FAILURE: Mode 0 Expected 0xA5, Got %h", data_out);
        
    // --- TEST 2: MODE 3 (CPOL=1, CPHA=1) ---
    #100;
    cpol = 1; cpha = 1;
    data_in = 8'h3C; // Binary 00111100
    
    start = 1; #10 start = 0;
    wait(done); #20;
    
    if (data_out == 8'h3C) 
        $display("SUCCESS: Mode 3 (0x3C) Matched");
    else 
        $display("FAILURE: Mode 3 Expected 0x3C, Got %h", data_out);

    #100 $finish;
  end
endmodule
