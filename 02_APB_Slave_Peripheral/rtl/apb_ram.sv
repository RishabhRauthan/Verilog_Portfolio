`timescale 1ns / 1ps

module apb_ram (
    input              pclk,
    input              presetn,
    input              psel,
    input              penable,
    input              pwrite,
    input      [31:0]  paddr,
    input      [31:0]  pwdata,
    output reg [31:0]  prdata,
    output wire        pready   
);

  // 32-bit Memory Array (Depth 32)
  reg [31:0] mem [0:31]; 

  // APB Slave Logic: Always ready (0 wait states)
  assign pready = 1'b1; 

  // Read Logic
  always @(*) begin
    if (psel && !pwrite) 
      prdata = mem[paddr];
    else 
      prdata = 32'h0;
  end

  // Write Logic
  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      integer i;
      for (i=0; i<32; i=i+1) mem[i] <= 0;
    end 
    else begin
      // Write happens only in ACCESS state
      if (psel && penable && pwrite) begin
        mem[paddr] <= pwdata;
      end
    end
  end

endmodule
