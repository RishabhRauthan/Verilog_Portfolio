`timescale 1ns / 1ps

module spi_master
  #(parameter CLK_DIV = 2) 
   (
    input  wire        clk,      
    input  wire        rst_n,    
    input  wire        start,    
    input  wire [7:0]  data_in,  
    output reg  [7:0]  data_out, 
    output reg         done,     
    
    input  wire        cpol,     
    input  wire        cpha,     
    
    output reg         sclk,     
    output reg         mosi,     
    input  wire        miso,     
    output reg         cs_n      
   );

  localparam IDLE = 0, RUNNING = 1;
  reg state;
  reg [$clog2(CLK_DIV)-1:0] clk_cnt; 
  reg [3:0] edge_cnt;                
  reg [7:0] shift_reg;
  reg sclk_edge_t; 
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        clk_cnt <= 0;
        edge_cnt <= 0;
        shift_reg <= 0;
        data_out <= 0;
        done <= 0;
        sclk <= cpol;
        mosi <= 0;
        cs_n <= 1;    
        sclk_edge_t <= 0;
    end else begin
        case (state)
            IDLE: begin
                done <= 0;
                cs_n <= 1;
                sclk <= cpol; 
                mosi <= 0;
                
                if (start) begin
                    state <= RUNNING;
                    cs_n <= 0;            
                    edge_cnt <= 0;
                    clk_cnt <= 0;
                    
                    if (cpha == 0) begin
                        // Mode 0/2: Set First bit immediately
                        mosi <= data_in[7]; 
                        // Pre-shift the register so next edge sends Bit 6
                        shift_reg <= {data_in[6:0], 1'b0}; 
                    end else begin
                        // Mode 1/3: Wait for first edge to set bit
                        mosi <= 0;
                        shift_reg <= data_in;
                    end
                end
            end

            RUNNING: begin
                if (clk_cnt == CLK_DIV-1) begin
                    clk_cnt <= 0;
                    sclk_edge_t <= 1; 
                end else begin
                    clk_cnt <= clk_cnt + 1;
                    sclk_edge_t <= 0;
                end
                
                if (sclk_edge_t) begin
                    sclk <= ~sclk;
                    
                    // --- SAMPLE LOGIC (Read MISO) ---
                    if (cpha == 0 && (edge_cnt[0] == 0)) begin // Leading Edge
                         shift_reg[0] <= miso;
                    end
                    else if (cpha == 1 && (edge_cnt[0] == 1)) begin // Trailing Edge
                         shift_reg[0] <= miso;
                    end
                    
                    // --- SHIFT LOGIC (Update MOSI) ---
                    if (cpha == 0 && (edge_cnt[0] == 1)) begin // Trailing Edge
                         mosi <= shift_reg[7]; 
                         shift_reg <= {shift_reg[6:0], 1'b0};
                    end
                    else if (cpha == 1 && (edge_cnt[0] == 0)) begin // Leading Edge
                         mosi <= shift_reg[7]; 
                         shift_reg <= {shift_reg[6:0], 1'b0};
                    end

                    if (edge_cnt == 15) begin
                        state <= IDLE;
                        done <= 1;
                        data_out <= shift_reg; 
                    end else begin
                        edge_cnt <= edge_cnt + 1;
                    end
                end
            end
        endcase
    end
  end
endmodule
