# Five-Stage RISC-V Processor (RV32I)

A work-in-progress implementation of a 5-stage pipelined RV32I processor written in SystemVerilog, targeting the Nexys A7 FPGA board.

## Project Status

🚧 **Work in Progress** — Core pipeline is functional. Data forwarding (hazard mitigation) is partially implemented and under active development.

---

## Pipeline Overview

The processor implements the classic 5-stage RISC pipeline:

IF → ID → EX → MEM → WB

Each stage is separated by pipeline registers that latch data on every clock edge, allowing multiple instructions to be in-flight simultaneously.

### Stage Descriptions

**IF — Instruction Fetch (`rv32_if_top.sv`)**
Maintains the program counter and fetches the next instruction from memory each cycle. PC increments by 4 each cycle and supports halt on EBREAK detection.

**ID — Instruction Decode (`rv32_id_top.sv`)**
Decodes the instruction word, reads rs1/rs2 from the register file, and determines the destination register and writeback enable. Contains forwarding input ports for future hazard resolution.

**EX — Execute (`rv32_ex_top.sv`)**
Extracts immediates and control signals, then drives the ALU. Supports all RV32I arithmetic, logical, shift, compare, and jump instructions.

**ALU (`alu.sv`)**
Combinational computation unit inside the EX stage. Output is registered on the clock edge.

**MEM — Memory Access (`rv32_mem_top.sv`)**
Pipeline register stage bridging EX and WB. Load/store memory operations are still being integrated.

**WB — Writeback (`rv32_wb_top.sv`)**
Passes the ALU result and writeback control signals back to the register file.

**Register File (`rv32i_regs_top.sv`)**
32 general-purpose 32-bit registers. x0 is hardwired to zero. Supports two simultaneous reads and one write.

**Memory (`dual_port_ram.sv`)**
Synchronous dual-port RAM. One port for instruction fetch, one for data. Initialized from `memory.mem` using `$readmemh`.

---

## Data Hazards

Because instructions take multiple cycles, a later instruction may read a register before an earlier one has finished writing to it (RAW hazard). Currently handled by manually inserting 3 NOP instructions (`0x00000013`) between dependent instructions. Data forwarding is planned — the `df_*` ports on the ID stage are already wired for this.

---

## How to Run

1. Add all `.sv` files to a Vivado project
2. Set `lab5_top.sv` as the top-level module
3. Provide a `memory.mem` file with your RV32I program in hex
4. Run behavioural simulation or program the Nexys A7 board

---

## File Structure

├── lab5_top.sv          # Top-level, connects all stages
├── rv32_if_top.sv       # Instruction Fetch
├── rv32_id_top.sv       # Instruction Decode
├── rv32_ex_top.sv       # Execute
├── alu.sv               # ALU
├── rv32_mem_top.sv      # Memory Access
├── rv32_wb_top.sv       # Writeback
├── rv32i_regs_top.sv    # Register file
├── dual_port_ram.sv     # Dual-port RAM
└── memory.mem           # Program memory (not tracked)

---

## Known Limitations

- Data forwarding not yet implemented — NOPs required between dependent instructions
- Branch instructions (BEQ, BNE, etc.) not yet implemented
- Load/store data path not fully connected
- No exception or interrupt handling
