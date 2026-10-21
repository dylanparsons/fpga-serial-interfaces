module clock_divider #(
    parameter int unsigned DIVISOR = 2
) (
    input  logic clk,
    input  logic rst_n,
    output logic clk_out
);
    localparam int unsigned COUNT_WIDTH = (DIVISOR <= 1) ? 1 : $clog2(DIVISOR);
    logic [COUNT_WIDTH-1:0] count;

    initial if (DIVISOR < 2) $fatal(1, "DIVISOR must be >= 2");

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count   <= '0;
            clk_out <= 1'b0;
        end else if (count == DIVISOR-1) begin
            count   <= '0;
            clk_out <= ~clk_out;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
