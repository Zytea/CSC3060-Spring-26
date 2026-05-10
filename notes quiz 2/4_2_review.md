# Lec 4.2: Control

## Exam Facts

- Control = combinational logic that **generates datapath signals from instruction bits**.
- ==Most difficult signal: **ALU control**==, because it depends on **opcode/ALUOp + funct3 + funct7**.
- RISC-V's regularity (fixed source/dest positions) makes control simpler than CISC.
- Single-cycle drawback: clock period must accommodate the **slowest full-instruction path**.
- HDLs (Verilog, VHDL) describe control logic → synthesized to a **netlist**.

## High-Level Control Signals

| Signal | Logic |
|---|---|
| `PCSrc` | `(BranchTaken \| JAL \| JALR) ? 1 : 0` |
| `RegWr` | `(Branch \| Store) ? 0 : 1` |
| `MemRd` | `Load ? 1 : 0` |
| `MemWr` | `Store ? 1 : 0` |
| `ALUSrc` | `R-type ? 0 : 1` (1 = use immediate) |
| `WBsel` | `Load → MemData; R-type → ALU; JAL → PC+4` |

> Quiz: `RegWr = 0` for **branches and stores**. Loads, ALU ops, jumps (write `PC+4` to `rd`) all set `RegWr = 1`.

### Next-PC sources

| Source | When |
|---|---|
| `PC + 4` | sequential / not-taken branch |
| `PC + imm` | branch taken, JAL |
| `rs1 + imm` | JALR |
| memory indirection | **NOT** in RV (no `LW pc, ...`) |

> Quiz: legitimate next-PC sources are `PC+4`, `PC+imm`, `rs1+imm`. NOT `(rs1+imm)→memory→PC` (no memory-indirect jumps in RV32I).

## ALU Control

ALU control derives from:
- **ALUOp** (per instruction class: load/store=ADD, branch=SUB, R/I-type=decode further),
- **`funct3`** (3 bits in I/R encoding),
- **`funct7[5]`** distinguishes pairs.

### Common mappings

| Class | ALU op |
|---|---|
| Load / Store | `ADD` (compute address) |
| Branch (sub-style) | `SUB` (or use compare unit) |
| R-type / I-type | decode `funct3` + `funct7[5]` |

### funct7[5] distinguishes pairs

| Same `funct3` | `funct7=0000000` | `funct7=0100000` |
|---|---|---|
| `000` (ADD/SUB) | ADD | **SUB** |
| `101` (SRL/SRA) | SRL | **SRA** |

> [!IMPORTANT] Why ALU control is hardest:
> - Most other signals are 1-bit class booleans.
> - ALU control is a **multi-bit lookup** depending on opcode + funct3 + funct7 + immediate vs register variant.

## Single-Cycle Datapath Examples

### `SW x2, offset(x1)`

- `RegWr=0` (no rd written), `MemWr=1`, `ALUSrc=1` (use imm), ALU = `ADD` (compute addr), `PCSrc=0`.

### `BEQ x1, x2, imm`

- `RegWr=0`, `MemWr=0`, ALU = `SUB` (or compare), `PCSrc = 1 if Zero==1 else 0`.

### `ADD rd, rs1, rs2`

- `RegWr=1`, `ALUSrc=0` (use reg), ALU = `ADD`, `WBsel=ALU`.

## Single-Cycle Drawbacks

Clock cycle must include the entire `LW` chain:

> PC clk-to-Q + IMem access + RegFile read + ALU (addr calc) + DMem access + WB-mux + RegFile setup + clock skew

⇒ all instructions pay the worst-case time even if they don't need DMem (e.g., `ADD`).

> [!IMPORTANT] Quiz: the RV32I instruction with **greatest impact on single-cycle clock rate** is **`LW`** (longest path).

## Summary of Single-Cycle RV

- CPI = 1 ⇒ simple control + lower CPI than multi-cycle.
- Clock long ⇒ low throughput.
- RV simplifies control:
  - Fixed 32b instr length (or 16b w/ C-ext).
  - **Regular format**: rs1/rs2/rd in fixed positions.
  - Immediates same width (12b imm, 20b upper imm).
  - Operations only on regs/imms (load-store).
- ⇒ lower design + verification cost.

## Quiz Cheat Sheet

| Q | A |
|---|---|
| Which control signal hardest? | **ALU control** |
| `RegWr=0` for what? | Branches, Stores |
| Next-PC sources | PC+4 / PC+imm / rs1+imm |
| Single-cycle clock determined by | slowest instr (usually `LW`) |
| Inst with biggest impact on clock | `LW` |
| ADD vs SUB distinguished by | `funct7[5]` |
