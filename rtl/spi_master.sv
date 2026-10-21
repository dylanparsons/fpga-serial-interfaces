// SPI mode 0 (CPOL=0, CPHA=0), MSB first, one 8-bit transaction per start.
module spi_master #(
    parameter int unsigned CLKS_PER_HALF_BIT = 2
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [7:0] tx_data,
    output logic [7:0] rx_data,
    output logic       busy,
    output logic       done,
    output logic       sclk,
    output logic       mosi,
    input  logic       miso,
    output logic       cs_n
);
    typedef enum logic [1:0] {IDLE, LEADING, TRAILING} state_t;
    state_t state;
    int unsigned divider;
    logic [2:0] bit_index;
    logic [7:0] tx_shift, rx_shift;

    initial if (CLKS_PER_HALF_BIT < 1) $fatal(1, "CLKS_PER_HALF_BIT must be >= 1");

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; divider <= 0; bit_index <= 0; tx_shift <= 0; rx_shift <= 0;
            rx_data <= 0; busy <= 0; done <= 0; sclk <= 0; mosi <= 0; cs_n <= 1;
        end else begin
            done <= 0;
            case (state)
                IDLE: begin
                    sclk <= 0; cs_n <= 1; busy <= 0; divider <= 0;
                    if (start) begin
                        tx_shift <= tx_data; rx_shift <= 0; bit_index <= 0;
                        mosi <= tx_data[7]; cs_n <= 0; busy <= 1; state <= LEADING;
                    end
                end
                LEADING: begin
                    if (divider == CLKS_PER_HALF_BIT-1) begin
                        divider <= 0; sclk <= 1; rx_shift <= {rx_shift[6:0], miso}; state <= TRAILING;
                    end else divider <= divider + 1;
                end
                TRAILING: begin
                    if (divider == CLKS_PER_HALF_BIT-1) begin
                        divider <= 0; sclk <= 0;
                        if (bit_index == 3'd7) begin
                            rx_data <= rx_shift; cs_n <= 1; busy <= 0; done <= 1; state <= IDLE;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                            tx_shift <= {tx_shift[6:0], 1'b0}; mosi <= tx_shift[6]; state <= LEADING;
                        end
                    end else divider <= divider + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
