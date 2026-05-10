# Lec 4.2: Control

## Exam Facts

- ==**Control**==: combinational logic that maps instruction bits + datapath status to control signals.
- ==**Most difficult control signal: ALU control / `ALUSel`**== because it depends on opcode class + `funct3` + `funct7[5]`.
- Regular RV fields (`rd`, `rs1`, `rs2`) simplify decode/control.
- `RegWEn=0` for **stores and branches**.
- `LW` usually sets the single-cycle clock period because it uses IF, reg read, ALU, data memory, WB.
- Single-cycle control is simpler than pipeline/OoO, but slow.

## 1. High-Level Control Signals

| Signal | Function | Typical values |
|---|---|---|
| `PCSel/PCSrc` | next PC source | 0=`PC+4`, 1=branch/JAL target; JALR uses `rs1+imm` path |
| `ImmSel` | immediate format | I/S/B/U/J |
| `RegWEn` | write GPR? | 0 for store/branch; 1 for ALU/load/U/J |
| `BrUn` | unsigned branch compare? | 1 for `bltu/bgeu`, 0 for signed |
| `BrEq` | comparator output | `rs1 == rs2` |
| `BrLT` | comparator output | `rs1 < rs2` |
| `ASel` | ALU A input | 0=`rs1`, 1=`PC` |
| `BSel` | ALU B input | 0=`rs2`, 1=`imm` |
| `MemRW` | data memory | read/write |
| `WBSel` | writeback source | ALU / memory / `PC+4` |

### 1.1 Next-PC Sources

| Source | Used by |
|---|---|
| `PC+4` | normal sequential path, not-taken branch |
| `PC + branch/jump imm` | taken branch, `jal` |
| `rs1 + imm` | `jalr` |

> [!IMPORTANT]
> RV32I has no memory-indirect next PC option like "load PC from memory". Quiz answer excludes `(rs1+imm)` as memory indirection.

## 2. ALU Control

Two-level idea:

1. Main control classifies instruction: load/store -> ADD, branch -> compare/sub, R/I -> decode function.
2. ALU control uses `ALUOp + funct3 + funct7[5]`.

### 2.1 `funct7[5]` Pairs

| `funct3` | `funct7[5]=0` | `funct7[5]=1` |
|---|---|---|
| `000` | `ADD` | `SUB` |
| `101` | `SRL` | `SRA` |

> Other signals are often simple booleans; `ALUSel` is a multi-way decode, so it is the hardest control signal in Quiz.

## 3. Single-Cycle Datapath Examples

| Instr | Important control |
|---|---|
| `add rd,rs1,rs2` | `RegWEn=1`, `ASel=rs1`, `BSel=rs2`, `ALUSel=ADD`, `WBSel=ALU` |
| `lw rd,off(rs1)` | `RegWEn=1`, `BSel=imm`, `ALUSel=ADD`, `MemRW=Read`, `WBSel=Mem` |
| `sw rs2,off(rs1)` | `RegWEn=0`, `BSel=imm`, `ALUSel=ADD`, `MemRW=Write` |
| `beq rs1,rs2,L` | `RegWEn=0`, compare `BrEq`; if true `PCSel=target` |
| `jal rd,L` | `RegWEn=1`, `WBSel=PC+4`, `PCSel=PC+imm` |
| `jalr rd,rs1,imm` | `RegWEn=1`, `WBSel=PC+4`, `PCSel=rs1+imm` |

## 4. Single-Cycle Drawback

Clock period must cover the worst full instruction path.

`LW` critical path:

```text
PC -> instr memory -> register read -> ALU addr calc -> data memory -> WB mux -> register setup
```

> [!IMPORTANT]
> Quiz: among `JALR`, `LW`, `SLL`, `LUI`, the single-cycle clock is dominated by ==**LW**==.

## 5. Summary of Single-Cycle RV

- Advantage: simple control; CPI=1.
- Disadvantage: long clock, low throughput, duplicated resources.
- RV helps control: fixed fields, few formats, load/store discipline, simple operations.
