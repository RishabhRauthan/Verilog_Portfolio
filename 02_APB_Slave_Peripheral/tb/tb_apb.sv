`timescale 1ns / 1ps

module tb_apb;

  reg         pclk;
  reg         presetn;
  reg         psel;
  reg         penable;
  reg         pwrite;
  reg  [31:0] paddr;
  reg  [31:0] pwdata;
  wire [31:0] prdata;
  wire        pready;

  apb_ram dut (
    .pclk(pclk), .presetn(presetn), .psel(psel), .penable(penable),
    .pwrite(pwrite), .paddr(paddr), .pwdata(pwdata),
    .prdata(prdata), .pready(pready)
  );

  // Clock Generation
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  // --- TASKS ---
  task apb_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge pclk);
      psel   <= 1; pwrite <= 1; paddr  <= addr; pwdata <= data; penable <= 0;
      @(posedge pclk);
      penable <= 1;
      wait(pready);
      @(posedge pclk);
      psel    <= 0; penable <= 0;
      $display("[WRITE] Addr: %0d, Data: %h", addr, data);
    end
  endtask

  task apb_read(input [31:0] addr);
    begin
      @(posedge pclk);
      psel   <= 1; pwrite <= 0; paddr  <= addr; penable <= 0;
      @(posedge pclk);
      penable <= 1;
      wait(pready);
      #1; 
      $display("[READ ] Addr: %0d, Data: %h", addr, prdata);
      @(posedge pclk);
      psel    <= 0; penable <= 0;
    end
  endtask

  // --- MAIN TEST ---
  initial begin
    presetn = 0; psel = 0; penable = 0; pwrite = 0; paddr = 0; pwdata = 0;
    #20 presetn = 1; #10;
    
    // 1. Write
    apb_write(5,  32'hDEAD_BEEF);
    apb_write(10, 32'hCAFE_BABE);
    
    // 2. Read
    apb_read(5);
    apb_read(10);
    
    #50 $finish;
  end
endmodule
