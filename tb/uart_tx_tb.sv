`timescale 1ns/1ps
module uart_tx_tb;
    localparam int CPB = 4;
    logic clk=0, rst_n=0, start=0;
    logic [7:0] data_in=8'hA5;
    logic tx, busy, done;
    logic [9:0] captured;
    uart_tx #(.CLKS_PER_BIT(CPB)) dut(.*);
    always #5 clk=~clk;
    initial begin
        $dumpfile("build/uart_tx.vcd"); $dumpvars(0, uart_tx_tb);
        repeat (2) @(negedge clk); rst_n=1; @(negedge clk); start=1;
        @(negedge clk); start=0;
        // Sample the start bit, 8 data bits (LSB first), and stop bit at bit centers.
        repeat (CPB/2) @(negedge clk);
        captured[0]=tx;
        for (int i=0;i<9;i++) begin
            repeat (CPB) @(negedge clk);
            captured[i+1]=tx;
        end
        wait(done);
        if (captured[0] !== 1'b0) $fatal(1,"UART start bit wrong");
        for (int b=0;b<8;b++) if (captured[b+1] !== data_in[b]) $fatal(1,"UART data bit %0d wrong",b);
        if (captured[9] !== 1'b1) $fatal(1,"UART stop bit wrong");
        $display("PASS uart_tx: transmitted 0x%02h", data_in); $finish;
    end
    initial begin repeat (200) @(posedge clk); $fatal(1,"UART test timed out"); end
endmodule
