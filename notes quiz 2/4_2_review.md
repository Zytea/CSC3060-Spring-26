# Lec 4.2: Control

## Exam Facts

- Control sets datapath muxes/write-enables from opcode, funct3/funct7, branch result, and instruction class.
- Main signals: `PCSrc`, `RegWr`, `MemRd`, `MemWr`, `ALUSrc`, `WBSel`, `ALUCtrl`.
- `RegWr=0` for **branch and store**.
- `MemRd=1` only for load. `MemWr=1` only for store.
- `ALUSrc=0` for R-type; `ALUSrc=1` for I-type/load/store/address/immediate ops.
- `WBSel`: load -> memory, ALU/R/I/U -> ALU/imm result, JAL/JALR -> `PC+4`.
- ALU control depends on `ALUOp` plus `funct3` and `funct7[5]`.
- `funct7[5]` distinguishes `ADD/SUB` and `SRL/SRA`.
- Single-cycle clock is dominated by load path.

## 1. High-Level Control Signals

![](assets/CA3060-4-2-Control_0.png)

| Signal | Expression idea | Meaning |
|---|---|---|
| `PCSrc` | branch taken or `JAL/JALR` | select non-`PC+4` next PC |
| `RegWr` | not branch/store | write destination register |
| `MemRd` | load | read data memory |
| `MemWr` | store | write data memory |
| `ALUSrc` | not R-type for operand B | choose immediate vs `rs2` |
| `WBSel` | load/R-type/JAL | choose memory/ALU/`PC+4` |

High-level table:

| Instr class | `RegWr` | `MemRd` | `MemWr` | `ALUSrc` | `WBSel` | Next PC |
|---|---:|---:|---:|---:|---|---|
| R ALU | 1 | 0 | 0 | 0 | ALU | `PC+4` |
| I ALU | 1 | 0 | 0 | 1 | ALU | `PC+4` |
| load | 1 | 1 | 0 | 1 | memory | `PC+4` |
| store | 0 | 0 | 1 | 1 | none | `PC+4` |
| branch | 0 | 0 | 0 | 0 | none | `PC+imm` if taken else `PC+4` |
| JAL | 1 | 0 | 0 | x | `PC+4` | `PC+imm` |
| JALR | 1 | 0 | 0 | 1 | `PC+4` | `(rs1+imm)&~1` |
| LUI/AUIPC | 1 | 0 | 0 | 1 | ALU/imm path | `PC+4` |

> HDL such as Verilog/SystemVerilog/VHDL describes these control functions and synthesizes to gates/netlists.

## 2. Next-PC Sources

| Source | Used by |
|---|---|
| `PC+4` | normal fall-through |
| `PC + branch_imm` | taken conditional branch |
| `PC + J_imm` | `JAL` |
| `(rs1 + I_imm) & ~1` | `JALR` |

`PCSrc` sometimes means a simple 2-way branch/JAL mux in a teaching datapath; complete RV32I needs enough choices for JALR and exceptions.

## 3. ALU Control

ALU control input levels:

1. main decoder uses opcode to produce `ALUOp`.
2. ALU decoder combines `ALUOp`, `funct3`, and `funct7[5]`.

Common `ALUOp`:

| `ALUOp` | Use | ALU action |
|---|---|---|
| `00` | load/store address | ADD |
| `01` | branch compare | SUB / compare |
| `10` | R/I ALU | decode funct fields |

### 3.1 funct Table

| `funct3` | `funct7[5]=0` | `funct7[5]=1` |
|---|---|---|
| `000` | `ADD` / `ADDI` | `SUB` for R-type |
| `001` | `SLL` / `SLLI` | invalid/reserved in base |
| `010` | `SLT` / `SLTI` | invalid/reserved |
| `011` | `SLTU` / `SLTIU` | invalid/reserved |
| `100` | `XOR` / `XORI` | invalid/reserved |
| `101` | `SRL` / `SRLI` | `SRA` / `SRAI` |
| `110` | `OR` / `ORI` | invalid/reserved |
| `111` | `AND` / `ANDI` | invalid/reserved |

Pseudo-Verilog shape:

```verilog
case (alu_op)
  2'b00: alu_control = ALU_ADD;  // load/store
  2'b01: alu_control = ALU_SUB;  // branch compare
  2'b10: case (funct3)
    3'b000: alu_control = funct7_bit5 ? ALU_SUB : ALU_ADD;
    3'b001: alu_control = ALU_SLL;
    3'b010: alu_control = ALU_SLT;
    3'b011: alu_control = ALU_SLTU;
    3'b100: alu_control = ALU_XOR;
    3'b101: alu_control = funct7_bit5 ? ALU_SRA : ALU_SRL;
    3'b110: alu_control = ALU_OR;
    3'b111: alu_control = ALU_AND;
  endcase
endcase
```

## 4. Complete Single-Cycle Datapath

![](assets/CA3060-4-2-Control_2.png)

Required flows:

- fetch instr with PC.
- read `rs1/rs2`.
- generate immediate.
- ALU computes result/address/compare.
- data memory for loads/stores.
- writeback to `rd`.
- next PC mux selects `PC+4` or target.

## 5. Example: `sw x2, offset(x1)`

![](assets/CA3060-4-2-Control_5.png)

Data movement:

1. read `rs1=x1` as base.
2. read `rs2=x2` as store data.
3. sign-extend S-imm.
4. ALU computes `x1 + imm`.
5. memory writes `x2` value at computed address.

Control:

| Signal | Value |
|---|---|
| `RegWr` | 0 |
| `MemWr` | 1 |
| `MemRd` | 0 |
| `ALUSrc` | 1 |
| `ALUCtrl` | ADD |
| `WBSel` | don't care |
| `PCSrc` | `PC+4` |

## 6. Example: `beq x1,x2,imm`

![](assets/CA3060-4-2-Control_6.png)

Data movement:

1. read `x1` and `x2`.
2. compare equality.
3. compute `PC + branch_imm`.
4. next PC = target if equal, else `PC+4`.

Control:

| Signal | Value |
|---|---|
| `RegWr` | 0 |
| `MemWr` | 0 |
| `MemRd` | 0 |
| `ALUSrc` | 0 |
| `ALUCtrl` | SUB/compare |
| `WBSel` | don't care |
| `PCSrc` | branch condition result |

## 7. Drawback of Single-Cycle Design

Clock period must cover the slowest instruction. For `lw`:

```text
PC clk-to-Q
-> instruction memory access
-> register file read
-> ALU address calculation
-> data memory access
-> writeback mux
-> register file setup
-> clock skew
```

All other instrs are forced to use this long period even if they do not need data memory.

## 8. Summary of Single-Cycle RV

- CPI = 1, but cycle time is long.
- RISC-V regularity simplifies control: fixed field positions, mostly fixed 32b instrs, limited formats, register/immediate ALU ops.
- Single-cycle is good for teaching but inefficient for real high-performance CPUs.
