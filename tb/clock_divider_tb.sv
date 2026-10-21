`timescale 1ns/1ps
module clock_divider_tb;
    localparam int DIVISOR = 4;
    logic clk = 0, rst_n = 0, clk_out;
    int transitions = 0;
    clock_divider #(.DIVISOR(DIVISOR)) dut(.*);
    always #5 clk = ~clk;
    always @(posedge clk_out or negedge clk_out) if (rst_n) transitions++;
    initial begin
        $dumpfile("build/clock_divider.vcd"); $dumpvars(0, clock_divider_tb);
        repeat (2) @(negedge clk); rst_n = 1;
        repeat (40) @(negedge clk);
        if (transitions < 4) $fatal(1, "Expected at least 4 output transitions, got %0d", transitions);
        $display("PASS clock_divider: %0d output transitions", transitions);
        $finish;
    end
endmodule
