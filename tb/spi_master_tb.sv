`timescale 1ns/1ps
module spi_master_tb;
    localparam int HALF=2;
    logic clk=0, rst_n=0, start=0;
    logic [7:0] tx_data=8'hA6, rx_data;
    logic busy, done, sclk, mosi, miso, cs_n;
    logic [7:0] expected_rx=8'h3C;
    int sample_index=7;
    spi_master #(.CLKS_PER_HALF_BIT(HALF)) dut(.*);
    always #5 clk=~clk;
    // Slave presents each bit before the rising edge, MSB first.
    assign miso = expected_rx[sample_index];
    always @(posedge sclk) begin
        // Let the DUT sample the current MISO bit before advancing the slave data.
        #1;
        if (!cs_n && sample_index>0) sample_index--;
    end
    initial begin
        $dumpfile("build/spi_master.vcd"); $dumpvars(0, spi_master_tb);
        repeat(2) @(negedge clk); rst_n=1; @(negedge clk); start=1;
        @(negedge clk); start=0;
        wait(done);
        if (rx_data !== expected_rx) $fatal(1,"SPI RX expected %02h got %02h",expected_rx,rx_data);
        if (cs_n !== 1'b1 || sclk !== 1'b0) $fatal(1,"SPI bus not idle after transaction");
        $display("PASS spi_master: TX %02h RX %02h",tx_data,rx_data); $finish;
    end
    initial begin repeat(500) @(posedge clk); $fatal(1,"SPI test timed out"); end
endmodule
