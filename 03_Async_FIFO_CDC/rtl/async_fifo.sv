`timescale 1ns / 1ps

module async_fifo #(
    parameter DSIZE = 8,
    parameter ASIZE = 4
)(
    input  wire wclk, wrst_n,
    input  wire winc,
    input  wire [DSIZE-1:0] wdata,
    output wire wfull,
    
    input  wire rclk, rrst_n,
    input  wire rinc,
    output wire [DSIZE-1:0] rdata,
    output wire rempty
);

    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;

    sync_r2w sync_r2w_inst (
        .wclk(wclk), .wrst_n(wrst_n), .rptr(rptr), .wq2_rptr(wq2_rptr)
    );
    
    sync_w2r sync_w2r_inst (
        .rclk(rclk), .rrst_n(rrst_n), .wptr(wptr), .rq2_wptr(rq2_wptr)
    );
    
    fifomem #(DSIZE, ASIZE) fifomem_inst (
        .wclk(wclk), .wclken(winc), .waddr(waddr), .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .raddr(raddr), .rdata(rdata)
    );
    
    rptr_empty #(ASIZE) rptr_empty_inst (
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc),
        .rq2_wptr(rq2_wptr),
        .rempty(rempty), .raddr(raddr), .rptr(rptr)
    );

    wptr_full #(ASIZE) wptr_full_inst (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc),
        .wq2_rptr(wq2_rptr),
        .wfull(wfull), .waddr(waddr), .wptr(wptr)
    );

endmodule

module fifomem #(parameter DATASIZE = 8, parameter ADDRSIZE = 4) (
    input  wire wclk, wclken, wfull,
    input  wire [ADDRSIZE-1:0] waddr,
    input  wire [DATASIZE-1:0] wdata,
    input  wire rclk,
    input  wire [ADDRSIZE-1:0] raddr,
    output wire [DATASIZE-1:0] rdata
);
    localparam DEPTH = 1<<ADDRSIZE;
    reg [DATASIZE-1:0] mem [0:DEPTH-1];
    assign rdata = mem[raddr];
    always @(posedge wclk)
        if (wclken && !wfull) mem[waddr] <= wdata;
endmodule

module sync_r2w #(parameter ADDRSIZE = 4) (
    input  wire wclk, wrst_n,
    input  wire [ADDRSIZE:0] rptr,
    output reg  [ADDRSIZE:0] wq2_rptr
);
    reg [ADDRSIZE:0] wq1_rptr;
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) {wq2_rptr, wq1_rptr} <= 0;
        else         {wq2_rptr, wq1_rptr} <= {wq1_rptr, rptr};
    end
endmodule

module sync_w2r #(parameter ADDRSIZE = 4) (
    input  wire rclk, rrst_n,
    input  wire [ADDRSIZE:0] wptr,
    output reg  [ADDRSIZE:0] rq2_wptr
);
    reg [ADDRSIZE:0] rq1_wptr;
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) {rq2_wptr, rq1_wptr} <= 0;
        else         {rq2_wptr, rq1_wptr} <= {rq1_wptr, wptr};
    end
endmodule

module rptr_empty #(parameter ADDRSIZE = 4) (
    input  wire rclk, rrst_n, rinc,
    input  wire [ADDRSIZE:0] rq2_wptr,
    output reg  rempty,
    output wire [ADDRSIZE-1:0] raddr,
    output reg  [ADDRSIZE:0] rptr
);
    reg [ADDRSIZE:0] rbin;
    wire [ADDRSIZE:0] rgraynext, rbinnext;
    assign rbinnext = rbin + (rinc & ~rempty);
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;
    assign raddr = rbin[ADDRSIZE-1:0]; 
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) {rbin, rptr} <= 0;
        else         {rbin, rptr} <= {rbinnext, rgraynext};
    end
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) rempty <= 1'b1;
        else         rempty <= (rgraynext == rq2_wptr);
    end
endmodule

module wptr_full #(parameter ADDRSIZE = 4) (
    input  wire wclk, wrst_n, winc,
    input  wire [ADDRSIZE:0] wq2_rptr,
    output reg  wfull,
    output wire [ADDRSIZE-1:0] waddr,
    output reg  [ADDRSIZE:0] wptr
);
    reg [ADDRSIZE:0] wbin;
    wire [ADDRSIZE:0] wgraynext, wbinnext;
    wire wfull_val;
    assign wbinnext = wbin + (winc & ~wfull);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;
    assign waddr = wbin[ADDRSIZE-1:0];
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) {wbin, wptr} <= 0;
        else         {wbin, wptr} <= {wbinnext, wgraynext};
    end
    assign wfull_val = (wgraynext == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1], wq2_rptr[ADDRSIZE-2:0]});
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) wfull <= 1'b0;
        else         wfull <= wfull_val;
    end
endmodule
