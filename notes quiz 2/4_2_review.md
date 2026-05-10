# Lec 4.2: Control

## Exam Facts

- Control maps opcode/funct/branch result to mux selects and write enables.
- Main signals: `PCSrc`, `RegWr`, `MemRd`, `MemWr`, `ALUSrc`, `WBSel`, `ALUCtrl`.
- `RegWr=0` for stores and branches.
- `MemRd=1` only load. `MemWr=1` only store.
- `ALUSrc=0` for R-type and branches; `ALUSrc=1` for I/load/store/JALR address.
- `WBSel`: load -> memory; ALU/I/U -> ALU/imm; JAL/JALR -> `PC+4`.
- `ALUCtrl` is hardest: depends on `ALUOp + funct3 + funct7[5]`.
- `funct7[5]`: `ADD/SUB`, `SRL/SRA`.

## 1. High-Level Control Signals

| Instr | `RegWr` | `MemRd` | `MemWr` | `ALUSrc` | `WBSel` | Next PC |
|---|---:|---:|---:|---:|---|---|
| R ALU | 1 | 0 | 0 | 0 | ALU | `PC+4` |
| I ALU | 1 | 0 | 0 | 1 | ALU | `PC+4` |
| load | 1 | 1 | 0 | 1 | memory | `PC+4` |
| store | 0 | 0 | 1 | 1 | none | `PC+4` |
| branch | 0 | 0 | 0 | 0 | none | target if taken |
| JAL | 1 | 0 | 0 | x | `PC+4` | `PC+imm` |
| JALR | 1 | 0 | 0 | 1 | `PC+4` | `(rs1+imm)&~1` |
| LUI/AUIPC | 1 | 0 | 0 | 1 | imm/ALU | `PC+4` |

## 2. Next-PC Sources

| Source | Used by |
|---|---|
| `PC+4` | normal |
| `PC+B-imm` | taken branch |
| `PC+J-imm` | `JAL` |
| `(rs1+I-imm)&~1` | `JALR` |
| trap vector | exceptions/interrupts |

> Quiz answer for RV32I next fetch address choices: `PC+4`, `PC+imm`, `rs1+imm`. Not memory indirection.

## 3. ALU Control

Common `ALUOp`:

| `ALUOp` | Use | ALU |
|---|---|---|
| `00` | load/store/JALR address | ADD |
| `01` | branch compare | SUB/compare |
| `10` | R/I ALU | decode funct |

### 3.1 `funct3/funct7` Table

| `funct3` | `funct7[5]=0` | `funct7[5]=1` |
|---|---|---|
| `000` | `ADD/ADDI` | `SUB` for R |
| `001` | `SLL/SLLI` | invalid |
| `010` | `SLT/SLTI` | invalid |
| `011` | `SLTU/SLTIU` | invalid |
| `100` | `XOR/XORI` | invalid |
| `101` | `SRL/SRLI` | `SRA/SRAI` |
| `110` | `OR/ORI` | invalid |
| `111` | `AND/ANDI` | invalid |

## 4. Complete Single-Cycle Datapath

Data path order:

```text
PC -> IMem -> decode/regfile/imm -> ALU -> DMem -> WB mux -> rd
                     \                         /
                      -> branch/jump PC mux <-
```

## 5. Example: `sw x2, offset(x1)`

```text
addr = x1 + signext(S-imm)
mem[addr] = x2
```

| Signal | Value |
|---|---|
| `RegWr` | 0 |
| `MemWr` | 1 |
| `MemRd` | 0 |
| `ALUSrc` | 1 |
| `ALUCtrl` | ADD |
| `PCSrc` | `PC+4` |

## 6. Example: `beq x1,x2,imm`

```text
taken = (x1 == x2)
next PC = taken ? PC+B-imm : PC+4
```

| Signal | Value |
|---|---|
| `RegWr` | 0 |
| `MemWr` | 0 |
| `MemRd` | 0 |
| `ALUSrc` | 0 |
| `ALUCtrl` | SUB/compare |
| `PCSrc` | branch condition |

## 7. Drawback of Single-Cycle Design

Clock period must cover `lw`:

```text
PC -> IMem -> RegFile -> ALU -> DMem -> WB mux -> RegFile setup
```

All shorter instrs waste the same long clock.

## 8. Summary of Single-Cycle RV

- CPI = 1, cycle time long.
- Regular field positions make control easier.
- Good teaching design, not high-performance design.
