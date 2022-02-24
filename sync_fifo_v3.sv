module sync_fifo_v3 #(
    parameter      DEPTH = 2,
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
logic [ADDR_SIZE  :0] waddr_nxt;
assign waddr_nxt = waddr + 1'b1;

logic [ADDR_SIZE-1:0] raddr;
logic [ADDR_SIZE  :0] raddr_nxt;
assign raddr_nxt = raddr + 1'b1;


T mem [DEPTH-1:0];
always_ff @(posedge clk) begin
    if (wen) begin
        mem [waddr] <= data_in;
    end
end

assign data_out = mem [raddr];

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        waddr <= '0;
    end else if (wen) begin
        waddr <= (waddr_nxt == DEPTH) ? '0 : waddr_nxt[ADDR_SIZE-1:0];
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        raddr <= '0;
    end else if (ren) begin
        raddr <= (raddr_nxt == DEPTH) ? '0 : raddr_nxt[ADDR_SIZE-1:0];
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        empty <= 1'b1;
    end else if (ren) begin
        empty <= (raddr_nxt == waddr);
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        full <= 1'b0;
    end else if (wen) begin
        full <= (waddr_nxt == raddr);
    end
end


endmodule
