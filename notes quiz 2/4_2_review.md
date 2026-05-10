# Lec 4.2: Control

## Exam Facts

- Control = combinational logic generating datapath signals from instr bits.
- ==**Most difficult signal: ALU control**== (depends on opcode/ALUOp + funct3 + funct7).
- RV regularity makes control simple: rs1/rs2/rd in fixed positions.
- Single-cycle drawback: clock period must cover slowest full-instr path (usually `LW`).
- ==**LW has greatest impact on single-cycle clock rate**==.
- HDLs (Verilog/VHDL) describe control → synthesized to **netlist**.

## 1. High-Level Control Signals

| Signal | Logic |
|---|---|
| `PCSrc` | `(BranchTaken \| JAL \| JALR) ? 1 : 0` |
| `RegWr` | `(Branch \| Store) ? 0 : 1` |
| `MemRd` | `Load ? 1 : 0` |
| `MemWr` | `Store ? 1 : 0` |
| `ALUSrc` | `R-type ? 0 : 1` (1 = use imm) |
| `WBsel` | `Load → MemData; R-type → ALU; JAL → PC+4` |

> ==`RegWr=0` for **branches and stores**==.

### 1.1 Next-PC Sources

| Source | When |
|---|---|
| `PC+4` | sequential / not-taken branch |
| `PC+imm` | branch taken, JAL |
| `rs1+imm` | JALR |
| memory indirection | ==NOT in RV== (no `LW pc, ...`) |

> Quiz: legitimate next-PC = PC+4 / PC+imm / rs1+imm. NOT memory-indirect.

## 2. ALU Control

ALU control derives from:
- **ALUOp** (per class: load/store=ADD, branch=SUB, R/I-type=decode)
- **`funct3`** (3 bits)
- **`funct7[5]`** (distinguishes pairs)

### 2.1 funct7[5] Pairs

| Same `funct3` | `funct7=0000000` | `funct7=0100000` |
|---|---|---|
| `000` (ADD/SUB) | ADD | **SUB** |
| `101` (SRL/SRA) | SRL | **SRA** |

> Why ALU control is hardest: most other signals are 1-bit class booleans; ALU control is a multi-bit lookup over opcode + funct3 + funct7 + imm-vs-reg variant.

## 3. Single-Cycle Datapath Examples

| Instr | Active signals |
|---|---|
| `ADD rd,rs1,rs2` | `RegWr=1, ALUSrc=0, ALU=ADD, WBsel=ALU` |
| `SW x2, off(x1)` | `RegWr=0, MemWr=1, ALUSrc=1, ALU=ADD` |
| `BEQ x1,x2, imm` | `RegWr=0, MemWr=0, ALU=SUB, PCSrc = (Zero? 1:0)` |

## 4. Single-Cycle Drawback

Clock cycle must include the entire `LW` chain:

> PC clk-to-Q + IMem + RegFile read + ALU + DMem + WB-mux + RegFile setup + skew

⇒ all instrs pay worst-case time.

> [!IMPORTANT] Quiz: instr with **greatest impact on single-cycle clock rate** = ==**`LW`**==.

## 5. Summary of Single-Cycle RV

- CPI=1 ⇒ simple control + lower CPI than multi.
- Clock long ⇒ low throughput.
- RV simplifies control: fixed 32b instr (16b w/ C), regular format, fixed-width imm (12b/20b), regs/imm-only ops.
- ⇒ lower design + verification cost.
