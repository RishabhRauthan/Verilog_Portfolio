`timescale 1ns / 1ps

module uart_top 
  #(parameter CLK_FREQ = 50000000, 
    parameter BAUD_RATE = 19200)
   (
    input wire clk,
    input wire reset,
    
    // UART Interface
    input wire rx,
    output wire tx,
    
    // Control / Status
    input wire tx_start,
    input wire [7:0] tx_data_in,
    output wire tx_done_tick,
    output wire rx_done_tick,
    output wire [7:0] rx_data_out
   );

  wire tick; // Baud rate tick

  // 1. Baud Rate Generator
  baud_rate_gen #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) 
    baud_gen_inst (.clk(clk), .reset(reset), .tick(tick));

  // 2. Transmitter
  uart_tx tx_inst (
    .clk(clk), .reset(reset), .tx_start(tx_start),
    .s_tick(tick), .tx_data_in(tx_data_in),
    .tx_done_tick(tx_done_tick), .tx(tx) 
  );

  // 3. Receiver
  uart_rx rx_inst (
    .clk(clk), .reset(reset), .rx(rx), 
    .s_tick(tick), .rx_done_tick(rx_done_tick), .rx_data(rx_data_out)
  );

endmodule

// --- SUBMODULES (Hidden here for single-file copy) ---
module baud_rate_gen #(parameter CLK_FREQ, BAUD_RATE)(input clk, reset, output reg tick);
  localparam ACC_MAX = CLK_FREQ / (BAUD_RATE * 16); 
  reg [$clog2(ACC_MAX)-1:0] counter;
  always @(posedge clk or posedge reset) begin
    if (reset) begin counter<=0; tick<=0; end
    else if (counter==ACC_MAX-1) begin counter<=0; tick<=1; end
    else begin counter<=counter+1; tick<=0; end
  end
endmodule

module uart_rx (input clk, reset, rx, s_tick, output reg rx_done_tick, output reg [7:0] rx_data);
  localparam [1:0] IDLE=0, START=1, DATA=2, STOP=3;
  reg [1:0] state;
  reg [3:0] s_cnt;
  reg [2:0] n_bit;
  reg [7:0] b_reg;
  always @(posedge clk or posedge reset) begin
    if (reset) begin state<=IDLE; s_cnt<=0; n_bit<=0; b_reg<=0; rx_done_tick<=0; rx_data<=0; end
    else begin
      rx_done_tick<=0;
      case (state)
        IDLE: if (~rx) begin state<=START; s_cnt<=0; end
        START: if (s_tick) if (s_cnt==7) begin state<=DATA; s_cnt<=0; n_bit<=0; end else s_cnt<=s_cnt+1;
        DATA: if (s_tick) if (s_cnt==15) begin s_cnt<=0; b_reg<={rx, b_reg[7:1]}; if (n_bit==7) state<=STOP; else n_bit<=n_bit+1; end else s_cnt<=s_cnt+1;
        STOP: if (s_tick) if (s_cnt==15) begin state<=IDLE; rx_done_tick<=1; rx_data<=b_reg; end else s_cnt<=s_cnt+1;
      endcase
    end
  end
endmodule

module uart_tx (input clk, reset, tx_start, s_tick, input [7:0] tx_data_in, output reg tx_done_tick, output reg tx);
  localparam [1:0] IDLE=0, START=1, DATA=2, STOP=3;
  reg [1:0] state;
  reg [3:0] s_cnt;
  reg [2:0] n_bit;
  reg [7:0] tx_reg;
  always @(posedge clk or posedge reset) begin
    if (reset) begin state<=IDLE; s_cnt<=0; n_bit<=0; tx_reg<=0; tx<=1; tx_done_tick<=0; end
    else begin
      tx_done_tick<=0;
      case (state)
        IDLE: if (tx_start) begin state<=START; s_cnt<=0; tx_reg<=tx_data_in; tx<=1; end else tx<=1; 
        START: begin tx<=0; if (s_tick) if (s_cnt==15) begin state<=DATA; s_cnt<=0; n_bit<=0; end else s_cnt<=s_cnt+1; end
        DATA: begin tx<=tx_reg[0]; if (s_tick) if (s_cnt==15) begin s_cnt<=0; tx_reg<=tx_reg>>1; if (n_bit==7) state<=STOP; else n_bit<=n_bit+1; end else s_cnt<=s_cnt+1; end
        STOP: begin tx<=1; if (s_tick) if (s_cnt==15) begin state<=IDLE; tx_done_tick<=1; end else s_cnt<=s_cnt+1; end
      endcase
    end
  end
endmodule
