module tb_top;

bit clk;
bit rst_n;

initial fork
    forever #5 clk = ~clk;
    begin
        @(posedge clk);
        #1 rst_n = 1'b1;
    end
join

typedef logic[7:0] T;

// fifo output
T data_out;
logic full;
logic empty;


logic wen;
T data_in;
logic ren;

initial begin
    wait(rst_n);
    while (1) begin
        @(posedge clk);
        #1;
        wen = (!full | full & ren) & $urandom_range(1, 0);
        ren = !empty & $urandom_range(1, 0);
        data_in = $random;
    end
end

initial begin
    #1000;
    $finish;
end

sync_fifo_v1 #(
    .DEPTH (2),
    .T     (T)
) i_sync_fifo_v1 (
    .*
);

endmodule
