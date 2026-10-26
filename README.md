# Synchronous FIFO in SystemVerilog

A parameterized, single-clock FIFO implemented in SystemVerilog, with a self-checking testbench.

## Features

- Configurable data width and FIFO depth.
- Single clock for read and write operations.
- Active-low asynchronous reset.
- Full and empty status flags.
- Registered read output.
- Simultaneous read and write support when the FIFO is neither full nor empty.
- Writes blocked when full and reads blocked when empty.

- ## Operation

A write is accepted when `wr_en` is high and `full` is low.
A read is accepted when `rd_en` is high and `empty` is low.

Accepted operations take place on the rising edge of `clk`.
Read and write pointers wrap around after the last memory location.

| Accepted write | Accepted read | Occupancy change |
|----------------|---------------|------------------|
| No | No | Unchanged |
| Yes | No | +1 |
| No | Yes | -1 |
| Yes | Yes | Unchanged |

## Running the Simulation

Requirement: Icarus Verilog with SystemVerilog support.

Run these commands from the project directory:

```bash
iverilog -g2012 -s tb_fifo -o fifo_sim fifo.sv tb_fifo.sv
vvp fifo_sim
```

The testbench generates `fifo.vcd`, which can be opened in a waveform viewer.

## Verification

The current testbench:

- Applies an initial reset.
- Fills the FIFO with random data.
- Checks that `full` is asserted after filling.
- Reads back the data and compares each word against its expected value.
- Stops the simulation with `$fatal` if a data mismatch occurs.
- Checks that `empty` is asserted after draining.
- Applies a simultaneous read and write sequence.

The simultaneous read/write sequence currently provides stimulus but still needs automatic result checks.
