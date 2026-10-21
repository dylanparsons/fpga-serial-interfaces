module uart_tx #(
    parameter int unsigned CLKS_PER_BIT = 434 // 50 MHz / 115200 baud ~= 434
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic [7:0] data_in,
    output logic       tx,
    output logic       busy,
    output logic       done
);
    typedef enum logic [1:0] {IDLE, START_BIT, DATA_BITS, STOP_BIT} state_t;
    state_t state;
    int unsigned tick_count;
    logic [2:0] bit_index;
    logic [7:0] data_latched;

    initial if (CLKS_PER_BIT < 1) $fatal(1, "CLKS_PER_BIT must be >= 1");

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; tick_count <= 0; bit_index <= 0;
            data_latched <= '0; tx <= 1'b1; busy <= 1'b0; done <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    tx <= 1'b1; busy <= 1'b0; tick_count <= 0; bit_index <= 0;
                    if (start) begin
                        data_latched <= data_in; busy <= 1'b1; tx <= 1'b0; state <= START_BIT;
                    end
                end
                START_BIT: begin
                    if (tick_count == CLKS_PER_BIT-1) begin
                        tick_count <= 0; tx <= data_latched[0]; state <= DATA_BITS;
                    end else tick_count <= tick_count + 1;
                end
                DATA_BITS: begin
                    if (tick_count == CLKS_PER_BIT-1) begin
                        tick_count <= 0;
                        if (bit_index == 3'd7) begin tx <= 1'b1; state <= STOP_BIT; end
                        else begin bit_index <= bit_index + 1'b1; tx <= data_latched[bit_index+1'b1]; end
                    end else tick_count <= tick_count + 1;
                end
                STOP_BIT: begin
                    if (tick_count == CLKS_PER_BIT-1) begin
                        tick_count <= 0; state <= IDLE; busy <= 1'b0; done <= 1'b1; tx <= 1'b1;
                    end else tick_count <= tick_count + 1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
