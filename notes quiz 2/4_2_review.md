# Lec 4.2: Control

## Exam Facts

- ==**Control**==: maps `opcode + funct3 + funct7 + branch-result` to **mux selects** and **write enables**.
- **7 main signals**: ==**`PCSrc`, `RegWr`, `MemRd`, `MemWr`, `ALUSrc`, `WBSel`, `ALUCtrl`**==.
- ==**`RegWr=0`**== (no reg write): **stores + branches** (also default for trap).
- ==**`MemRd=1`**== only for **loads**; ==**`MemWr=1`**== only for **stores**.
- **`ALUSrc`** (B-mux): `0` for R-type / branches (`rs2`); `1` for I-ALU / load / store / JALR / LUI/AUIPC (imm).
- **`WBSel`**: load → memory data; ALU/I/U → ALU result; JAL/JALR → `PC+4`; LUI/AUIPC → imm/ALU.
- ==**`ALUCtrl`**== depends on `ALUOp + funct3 + funct7[5]`. **The hardest control signal to generate** (Quiz 2 #8).
- **`funct7[5]`**: distinguishes `ADD/SUB` (R-type) and `SRL/SRA` (R or I shift).
- **HDL control**: synthesizable Verilog/VHDL maps `opcode/funct` → control netlist.
- **WB-stage controls** (signals that travel to WB): `rd`, `RegWr`/`WRen`, `WBSel`. **NOT** `ALUCtrl` (used in EX, dies after).
- **Next-fetch sources** (RV32I): `PC+4`, `PC+imm` (branch/JAL), `(rs1+imm)&~1` (JALR), trap vector. **NOT** memory indirection.
- **Single-cycle drawback**: clock = `lw` time = sum of every stage's worst-case latency. Wastes time on shorter instrs.

## 1. High-Level Control Signal Expressions

> Control = "brain"; datapath = "brawn". Control picks mux inputs + asserts write enables.

==**Fast expressions**==:

```text
PCSrc   = (BranchTaken) || (JAL || JALR)
RegWr   = !(Branch || Store)
MemRd   = Load
MemWr   = Store
ALUSrcB = (I_ALU || Load || Store || JALR || LUI || AUIPC)
```

==**Per-instruction control table**==:

| Instr | `RegWr` | `MemRd` | `MemWr` | `ALUSrc` | `WBSel` | Next PC |
|---|---:|---:|---:|---:|---|---|
| **R-ALU** (`add,sub,…`) | 1 | 0 | 0 | 0 | ALU | `PC+4` |
| **I-ALU** (`addi,…`) | 1 | 0 | 0 | 1 | ALU | `PC+4` |
| **Load** (`lw,lb,…`) | 1 | 1 | 0 | 1 | Memory | `PC+4` |
| **Store** (`sw,sb,…`) | **0** | 0 | 1 | 1 | — | `PC+4` |
| **Branch** (`beq,…`) | **0** | 0 | 0 | 0 | — | target if taken else `PC+4` |
| **JAL** | 1 | 0 | 0 | x | `PC+4` | `PC + J-imm` |
| **JALR** | 1 | 0 | 0 | 1 | `PC+4` | `(rs1+I-imm) & ~1` |
| **LUI / AUIPC** | 1 | 0 | 0 | 1 | imm / ALU | `PC+4` |

> Quiz: example `add x1,x2,x3` (encoded `0000000_rs2_rs1_000_rd_0110011`): `RegWr=1, ALUSrc=0, WBSel=ALU, PCSrc=PC+4`.

## 2. Next-PC Sources

| Source | Used by |
|---|---|
| `PC+4` | normal sequential |
| `PC + B-imm` | taken branch |
| `PC + J-imm` | `JAL` |
| `(rs1 + I-imm) & ~1` | `JALR` |
| trap vector (`mtvec`) | exceptions / interrupts |

> [!IMPORTANT]
> Next-fetch choices in RV32I are `PC+4`, `PC+imm`, `rs1+imm`. **Memory indirection (jump target loaded from memory) is NOT a choice.**

## 3. ALU Control

`ALUCtrl` derived from `ALUOp + funct3 + funct7[5]`. Quiz 2 #8: **most difficult control to generate**.

==**`ALUOp` examples**==:

| `ALUOp` | Use | ALU op |
|---|---|---|
| `00` | load / store / JALR addr | ADD |
| `01` | branch compare | SUB / compare |
| `10` | R / I-ALU | decode by funct |

### 3.1 `funct3` / `funct7` Decoding

| `funct3` | `funct7[5]=0` | `funct7[5]=1` |
|---|---|---|
| `000` | `ADD / ADDI` | **`SUB`** (R only) |
| `001` | `SLL / SLLI` | invalid |
| `010` | `SLT / SLTI` | invalid |
| `011` | `SLTU / SLTIU` | invalid |
| `100` | `XOR / XORI` | invalid |
| `101` | `SRL / SRLI` | **`SRA / SRAI`** |
| `110` | `OR / ORI` | invalid |
| `111` | `AND / ANDI` | invalid |

> R-type `ADD`: `funct7=0000000`. R-type `SUB`: `funct7=0100000`. Same idea for SRL/SRA.

```verilog
// Synthesizable Verilog excerpt
always_comb begin
  case (alu_op)
    2'b00 : alu_control = ALU_ADD;       // load/store/JALR
    2'b01 : alu_control = ALU_SUB;       // branch
    2'b10 : begin                        // R / I ALU
      case (funct3)
        3'b000: alu_control = funct7_5 ? ALU_SUB : ALU_ADD;
        3'b001: alu_control = ALU_SLL;
        3'b010: alu_control = ALU_SLT;
        3'b011: alu_control = ALU_SLTU;
        3'b100: alu_control = ALU_XOR;
        3'b101: alu_control = funct7_5 ? ALU_SRA : ALU_SRL;
        3'b110: alu_control = ALU_OR;
        3'b111: alu_control = ALU_AND;
      endcase
    end
  endcase
end
```

## 4. Complete Single-Cycle Datapath (Order)

```text
PC → IMem → decode/regfile/imm-gen → ALU → DMem → WBmux → rd
                  \_______________ branch/jump PC mux ____________/
```

==**Three muxes again**==:

| Mux | Choices |
|---|---|
| `PCSrc` | `PC+4`, `PC+imm`, `(rs1+imm)&~1` |
| `ALUSrcB` | `R[rs2]` or imm |
| `WBSel` | ALU / mem / `PC+4` / imm |

## 5. Worked Example: `sw x2, offset(x1)`

```text
addr      = R[x1] + signext(S-imm)
mem[addr] = R[x2]
```

| Signal | Value |
|---|---|
| `RegWr` | 0 (no `rd`) |
| `MemWr` | 1 |
| `MemRd` | 0 |
| `ALUSrc` | 1 (imm) |
| `ALUCtrl` | ADD |
| `WBSel` | — (no WB) |
| `PCSrc` | `PC+4` |

## 6. Worked Example: `beq x1, x2, imm`

```text
taken    = (R[x1] == R[x2])
next PC  = taken ? PC + B-imm : PC + 4
```

| Signal | Value |
|---|---|
| `RegWr` | 0 (no `rd`) |
| `MemWr` | 0 |
| `MemRd` | 0 |
| `ALUSrc` | 0 (compare regs) |
| `ALUCtrl` | SUB / equality compare |
| `WBSel` | — |
| `PCSrc` | branch result mux |

## 7. Drawback of Single-Cycle Design

Clock period must cover the **`lw` critical path**:

```text
PC → IMem → Regfile → ALU(addr) → DMem → WBmux → Regfile setup
+ Clock-to-Q + clock skew
```

All shorter instrs (R-type, branch) **waste** the long clock.

> Solution preview: split into pipeline stages (next chapter) — short clock + overlapped exec → much higher throughput.

## 8. Summary of Single-Cycle RV

- **CPI = 1**, but cycle time = `lw` worst-case → poor throughput vs pipelined.
- ==**RISC-V regularity simplifies control**==: fixed instr size, regular field positions (`opcode/rd/funct3/rs1/rs2`), 12b/20b imm only, register/imm operands only.
- Branches/stores: `RegWr = 0`. Load uniquely has `MemRd = 1`. Store uniquely has `MemWr = 1`.
- Good **teaching** design, not high-perf design.
