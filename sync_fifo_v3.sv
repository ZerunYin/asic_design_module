module sync_fifo_v3 #(
    parameter  int  DEPTH         = 2,
    parameter  type T             = logic,
    localparam int  ADDR_SIZE     = $clog2(DEPTH),
    localparam int  DEPTH_IS_POW2 = !(DEPTH&(DEPTH-1)),
    localparam int  CNT_SIZE      = DEPTH_IS_POW2 ? ADDR_SIZE+1 : ADDR_SIZE;
)(
    input        clk,
    input        rst_n,

    input        wen,
    input  T     data_in,

    input        ren,
    output T     data_out,

    output logic full,
    output logic empty
);

logic [ADDR_SIZE-1:0] waddr;
logic [ADDR_SIZE-1:0] raddr;
logic [ADDR_SIZE-1:0] waddr_nxt;
logic [ADDR_SIZE-1:0] raddr_nxt;

wire  [ADDR_SIZE-1:0] waddr_incr = waddr + 1'b1;
wire  [ADDR_SIZE-1:0] raddr_incr = raddr + 1'b1;

if (DEPTH_IS_POW2) begin : rw_addr_nxt
    assign waddr_nxt = waddr_incr;
    assign raddr_nxt = raddr_incr;
end else begin
    assign waddr_nxt  = waddr_incr == DEPTH ? '0 : waddr_incr;
    assign raddr_nxt  = raddr_incr == DEPTH ? '0 : raddr_incr;
end

// input and output data of FIFO
T mem [DEPTH-1:0];
always_ff @(posedge clk) begin
    if (wen) begin
        mem [waddr] <= data_in;
    end
end

assign data_out = mem [raddr];

// waddr and raddr
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        waddr <= '0;
    end else if (wen) begin
        waddr <= waddr_nxt;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        raddr <= '0;
    end else if (ren) begin
        raddr <= raddr_nxt;
    end
end

// empty and full
logic [CNT_SIZE-1:0] cnt;
logic [CNT_SIZE-1:0] cnt_nxt;
always_comb begin
    unique case ({wen, ren})
        2'b10:   cnt_nxt = cnt + 1'b1;
        2'b01:   cnt_nxt = cnt - 1'b1;
        default: cnt_nxt = cnt;
    endcase
end
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        cnt <= '0;
    end else if (wen|ren) begin
        cnt <= cnt_nxt;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        empty <= 1'b1;
    end else if (wen|ren) begin
        empty <= (cnt_nxt == '0);
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        full <= 1'b0;
    end else if (wen|ren) begin
        full <= (cnt_nxt >= DEPTH);
    end
end


endmodule
