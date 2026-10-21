# FPGA Serial Interfaces

UART and SPI blocks written in SystemVerilog, with self-checking testbenches that run in CI. I'm building this to learn RTL design and verification. The end goal is an FPGA board that can talk to real UART, SPI, and I2C devices.

## Status

| Block | Status |
|---|---|
| Clock divider | Done, with testbench |
| UART TX (8-N-1) | Done, with testbench |
| SPI master (mode 0, 8-bit) | Done, with testbench |
| Register bank | Written, no testbench yet (CI only checks that it compiles) |
| UART RX | Not started |
| I2C master | Not started |
| Board top-level and constraints | Waiting until I pick a board |
| Synthesis / hardware testing | Not done yet |

## Running the tests

You need [Icarus Verilog](https://steveicarus.github.io/iverilog/). From the repo root:

    ./sim/run.sh

On Windows, use `bash sim/run.sh` in Git Bash or WSL.

Each testbench prints PASS or stops with an error. Waveforms are written to `build/`, and you can open them in GTKWave:

    gtkwave build/uart_tx.vcd

GitHub Actions runs the same script on every push and pull request.

## Design notes

- `clock_divider` toggles its output every `DIVISOR` input clocks, so `f_out = f_in / (2 * DIVISOR)`.
- `uart_tx` sends a start bit, eight data bits LSB first, and a stop bit.
- `spi_master` is SPI mode 0 (CPOL=0, CPHA=0), MSB first. `CLKS_PER_HALF_BIT` sets how many input clocks make up half an SCLK period.
- `register_bank` isn't connected to anything yet. It's there for when the blocks get a shared control interface.

More detail is in [`docs/architecture.md`](docs/architecture.md).

## What's next

- UART RX
- I2C master with open-drain SDA and ACK/NACK handling, tested against a simulated slave
- Connect the blocks through the register bank
- Pick a board and write the top level: reset synchronizer, input synchronizers and debouncing, pin and clock constraints
- Synthesis, with real resource and timing numbers

## Validation

So far everything has only been tested in simulation. None of it has been synthesized or run on an FPGA yet. I'll update this when it has.

## License

MIT, see `LICENSE`.