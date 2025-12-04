`timescale 1ns / 1ps

module tb_async_fifo;
    parameter DSIZE = 8;
    parameter ASIZE = 4;
    
    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;
    reg [DSIZE-1:0] wdata;
    reg winc, wclk, wrst_n;
    reg rinc, rclk, rrst_n;

    // DUT Instantiation
    async_fifo #(DSIZE, ASIZE) dut (
        .wclk(wclk), .wrst_n(wrst_n),
        .winc(winc), .wdata(wdata),
        .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n),
        .rinc(rinc), .rdata(rdata),
        .rempty(rempty)
    );

    // 100MHz Write Clock
    initial begin
        wclk = 0; forever #5 wclk = ~wclk;
    end
    
    // 40MHz Read Clock
    initial begin
        rclk = 0; forever #12.5 rclk = ~rclk;
    end

    initial begin
        winc = 0; wdata = 0; wrst_n = 0;
        rinc = 0; rrst_n = 0;
        #50; wrst_n = 1; rrst_n = 1; #20;
        
        // TEST 1: Fill the FIFO
        repeat(17) begin 
            @(negedge wclk);
            if (!wfull) begin
                winc = 1; wdata = wdata + 1;
            end else begin
                winc = 0;
            end
        end
        winc = 0;

        // TEST 2: Empty the FIFO
        repeat(17) begin
            @(negedge rclk);
            if (!rempty) begin
                rinc = 1;
            end else begin
                 rinc = 0;
            end
        end
        rinc = 0;
        
        #500 $finish;
    end
endmodule
