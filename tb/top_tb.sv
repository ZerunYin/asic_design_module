module tb_top;

bit clk;
bit rst_n;

initial fork
    forever clk = #5 ~clk;
    begin
        @(posedge clk);
        rst_n = #1 1'b1;
    end
join

typedef logic[7:0] T;

// fifo output
T     data_out;
logic full;
logic empty;

// fifo input
logic ren;
logic wen;
T     data_in;

initial begin
    wait(rst_n);
    while (1) begin
        wen = (!full | full & ren) & $urandom_range(1, 0);
        ren = !empty & $urandom_range(1, 0);
        data_in = $random;
        @(posedge clk);
        #1;
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

// model
T mem[$];
initial begin
    wait(rst_n);
    while (1) begin
        @(posedge clk) begin
            if (wen)
                mem.push_back(data_in);
            
            if (ren)
                assert (data_out == mem.pop_front);
        end

    end
end

endmodule
