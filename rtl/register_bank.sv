// Small synchronous control/status register bank for integration examples.
module register_bank #(
    parameter int unsigned ADDR_WIDTH = 4,
    parameter int unsigned DATA_WIDTH = 8
) (
    input logic clk, rst_n,
    input logic write_en,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] write_data,
    output logic [DATA_WIDTH-1:0] read_data
);
    localparam int unsigned REG_COUNT = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] regs [0:REG_COUNT-1];
    integer i;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < REG_COUNT; i = i + 1) regs[i] <= '0;
        end else if (write_en) begin
            regs[addr] <= write_data;
        end
    end
    always_comb read_data = regs[addr];
endmodule
