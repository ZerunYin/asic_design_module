module idx_to_oh #(
    parameter  NUM_SIGNALS = 4,
    parameter  DIRECTION   = "LSB0",
    localparam INDEX_WIDTH = $clog2(NUM_SIGNALS)
) (
    output logic [NUM_SIGNALS - 1:0] one_hot,
    input        [INDEX_WIDTH - 1:0] index
);

always_comb begin
    one_hot = '0;
    if (DIRECTION == "LSB0")
        one_hot[index] = 1'b1;
    else
        one_hot[NUM_SIGNALS - 1 - 32'(index)] = 1'b1;
end

endmodule
