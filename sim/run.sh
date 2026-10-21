#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
run_tb() {
  local name="$1"; shift
  echo "== $name =="
  iverilog -g2012 -Wall -s "$name" -o "build/$name.vvp" "$@"
  vvp "build/$name.vvp"
}
run_tb clock_divider_tb rtl/clock_divider.sv tb/clock_divider_tb.sv
run_tb uart_tx_tb rtl/uart_tx.sv tb/uart_tx_tb.sv
run_tb spi_master_tb rtl/spi_master.sv tb/spi_master_tb.sv
echo "== register_bank (compile only, no testbench yet) =="
iverilog -g2012 -Wall -o build/register_bank.vvp rtl/register_bank.sv
