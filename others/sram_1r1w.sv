// An 1R1W sram for simulation
//
// The READ_DURING_WRITE parameter determines what happens
// if a read and a write are performed to the same address in the same cycle:
//  - "NEW_DATA" this will return the newly written data ("read-after-write").
//  - "DONT_CARE" The results are undefined. This can be used to improve clock
//    speed.
// This does not clear memory contents on reset.
//

module sram_1r1w #(
    parameter  DATA_WIDTH        = 32,
    parameter  SIZE              = 1024,
    parameter  READ_DURING_WRITE = "NEW_DATA",
    localparam ADDR_WIDTH        = $clog2(SIZE)
) (
    input                          clk,

    input                          read_en,
    input        [ADDR_WIDTH -1:0] read_addr,
    output logic [DATA_WIDTH -1:0] read_data,

    input                          write_en,
    input        [ADDR_WIDTH -1:0] write_addr,
    input        [DATA_WIDTH -1:0] write_data
);

logic [DATA_WIDTH -1:0] data[SIZE];

always @(posedge clk) begin
    if (write_en)
        data[write_addr] <= write_data;

    if (write_addr == read_addr && write_en && read_en) begin
        if (READ_DURING_WRITE == "NEW_DATA")
            read_data <= write_data; // Bypass
        else
            read_data <= DATA_WIDTH'($random()); // ensure it is really "don't care"
    end else if (read_en)
        read_data <= data[read_addr];
end

endmodule
