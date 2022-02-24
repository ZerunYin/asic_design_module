module sync_fifo_v2 #(
    parameter      DEPTH = 2,
    parameter type T     = logic
)(
    input    clk,
    input    rst_n,

    input    wen,
    input  T data_in,

    input    ren,
    output T data_out,

    output   full,
    output   empty
);

localparam ADDR_SIZE = $clog2(DEPTH);

logic [ADDR_SIZE-1:0] waddr;
logic                 wwrap;
logic [ADDR_SIZE-1:0] raddr;
logic                 rwrap;

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

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        {wwrap, waddr} <= '0;
    end else if (wen) begin
        {wwrap, waddr} <= {wwrap, waddr} + 1'b1;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        {rwrap, raddr} <= '0;
    end else if (ren) begin
        {rwrap, raddr} <= {rwrap, raddr} + 1'b1;
    end
end

assign full  = (wwrap!=rwrap) & (waddr == raddr);
assign empty = (wwrap==rwrap) & (waddr == raddr);

endmodule
