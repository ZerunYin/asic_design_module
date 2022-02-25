module sync_fifo_v4 #(
    parameter int  DEPTH = 2,
    parameter type T     = logic
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

localparam ADDR_SIZE = $clog2(DEPTH);

logic [ADDR_SIZE-1:0] waddr;
wire  [ADDR_SIZE  :0] waddr_incr = waddr + 1'b1;
wire  [ADDR_SIZE-1:0] waddr_nxt  = waddr_incr == DEPTH ? '0 : waddr_incr;

logic [ADDR_SIZE-1:0] raddr;
wire  [ADDR_SIZE  :0] raddr_incr = raddr + 1'b1;
wire  [ADDR_SIZE-1:0] raddr_nxt  = raddr_incr == DEPTH ? '0 : raddr_incr;


// input and output data of FIFO
T mem [DEPTH-1:0];
always_ff @(posedge clk) begin
    if (wen) begin
        mem [waddr] <= data_in;
    end
end

always_ff @(posedge clk) begin
    if (ren) begin
        data_out <= mem [raddr];
    end
end

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
logic [ADDR_SIZE:0] cnt;
logic [ADDR_SIZE:0] cnt_nxt;
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
