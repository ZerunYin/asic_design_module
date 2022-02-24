//
// Convert a one-hot signal to a binary index corresponding to the active bit.
// (Binary encoder)
// If DIRECTION is "LSB0", index 0 corresponds to the least significant bit
// If "MSB0", index 0 corresponds to the most significant bit
//

module oh_to_idx #(
    parameter  NUM_SIGNALS = 4,
    parameter  DIRECTION   = "LSB0",

    localparam INDEX_WIDTH = $clog2(NUM_SIGNALS)
) (
    input        [NUM_SIGNALS -1:0] one_hot,
    output logic [INDEX_WIDTH -1:0] index
);

always_comb begin
    index = '0;
    for (int i = 0; i< NUM_SIGNALS; i++) begin
        if (one_hot[i]) begin
            if (DIRECTION == "LSB0")
                index |= i[INDEX_WIDTH -1:0]; // Use 'or' to avoid synthesizing priority encoder
            else
                index |= INDEX_WIDTH'(NUM_SIGNALS-1 - i);
        end
    end
end

endmodule
