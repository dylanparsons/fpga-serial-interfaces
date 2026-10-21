# Architecture

## Current RTL blocks

- `clock_divider`: parameterized counter/toggle output. This is suitable for slow logic in demonstrations; for production FPGA clocking, prefer a clock-enable pulse or a vendor PLL/MMCM rather than creating unconstrained fabric clocks.
- `uart_tx`: 8-N-1 asynchronous serial transmitter, LSB first.
- `spi_master`: SPI mode 0, 8-bit full-duplex transaction, MSB first.
- `register_bank`: synchronous write, combinational read register array.

## Verification plan

Each block should have a self-checking testbench. The current simulation runner covers the clock divider, UART transmitter, and SPI master. `register_bank` has no testbench yet; the runner only compile-checks it. I2C is intentionally not implemented yet; an open-drain, ACK-aware I2C master should be added with its own slave model and tests rather than presenting an unverified implementation as complete.

## Conventions

- Reset: every block uses an active-low asynchronous reset (`rst_n`).
- Handshake (`uart_tx`, `spi_master`): `start` begins a transfer, `busy` stays high for its whole duration, and `done` pulses for one clock cycle when it finishes. `start` is ignored while `busy` is high.