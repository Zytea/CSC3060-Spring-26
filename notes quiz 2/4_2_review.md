# Lec 4.2: Control

## Exam Facts

<table>
  <thead>
    <tr>
      <th>Signal</th>
      <th>Options</th>
      <th>Signal</th>
      <th>Options</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>PCSrc</td>
      <td><code>0</code>: PC+4, <code>1</code>: branch/target</td>
      <td>ImmSel</td>
      <td><code>0</code>: I, <code>1</code>: S, <code>2</code>: B, <code>3</code>: U, <code>4</code>: J</td>
    </tr>
    <tr>
      <td>RegWr</td>
      <td>Write</td>
      <td>BrUn</td>
      <td>unsigned, 0=signed</td>
    </tr>
    <tr>
      <td>BrEq</td>
      <td>rs1==rs2</td>
      <td>BrLT</td>
      <td>rs1&lt;rs2</td>
    </tr>
    <tr>
      <td>Asel</td>
      <td>0=rs1, 1=PC</td>
      <td>Bsel</td>
      <td>0=rs2, 1=imm</td>
    </tr>
    <tr>
      <td>ALUOp</td>
      <td><code>0</code>: SL, <code>1</code>: branch, <code>2</code>: R/I-type</td>
      <td>ALUSrc</td>
      <td><code>0</code>: ADD, <code>1</code>: SUB, <code>2</code>: AND, <code>3</code>: OR, <code>4</code>: SLT</td>
    </tr>
    <tr>
      <td>MemWr</td>
      <td>Write</td>
      <td>WBSel</td>
      <td>0=mem, 1=alu, 2=pc+4</td>
    </tr>
  </tbody>
</table>

- ==**Control**==: maps `opcode + funct3 + funct7 + branch-result` to **mux selects + write enables**.
  - **7 Core signals**: ==**`PCSrc`, `RegWr`, `MemRd`, `MemWr`, `ALUSrc`, `WBSel`, `ALUCtrl`**==.
  - ==**`RegWr=0`**==: **stores + branches** (also default for trap).
  - ==**`MemRd=1`**== only for **loads**; ==**`MemWr=1`**== only for **stores**.
  - **`ALUSrc`** (B-mux): `0` for R/branches (`rs2`); `1` for I-ALU/load/store/JALR/LUI/AUIPC (imm).
  - **`WBSel`**: load → mem; ALU/I/U → ALU; JAL/JALR → `PC+4`; LUI/AUIPC → imm/ALU.
- ==**`ALUCtrl`**== = `ALUOp + funct3 + funct7[5]`. **Hardest control signal to generate**.
  - **`funct7[5]`**: distinguishes `ADD 0/SUB 1` (R) and `SRL 0/SRA 1` (R or I shift).
- ==**Next-PC sources (RV32I)**==: `PC+4`, `PC+imm` (branch/JAL), `(rs1+imm)&~1` (JALR), trap vector (`mtvec`). **NOT** memory indirection.
- **WB-stage signals propagated**: `rd`, `RegWr/WRen`, `WBSel`. **NOT** `ALUCtrl` (used in EX, dies after).

## 1. Per-Instruction Control Table

==**Fast expressions**==:

```text
PCSrc   = BranchTaken || JAL || JALR
RegWr   = !(Branch || Store)
MemRd   = Load
MemWr   = Store
ALUSrcB = I_ALU || Load || Store || JALR || LUI || AUIPC
```

| Instr                   | `RegWr` | `MemRd` | `MemWr` | `ALUSrc` | `WBSel`    | Next PC                     |
| ----------------------- | ------- | ------- | ------- | -------- | ---------- | --------------------------- |
| **R-ALU** (`add,sub,…`) | 1       | 0       | 0       | 0        | ALU        | `PC+4`                      |
| **I-ALU** (`addi,…`)    | 1       | 0       | 0       | 1        | ALU        | `PC+4`                      |
| **Load** (`lw,lb,…`)    | 1       | **1**   | 0       | 1        | Memory     | `PC+4`                      |
| **Store** (`sw,sb,…`)   | **0**   | 0       | **1**   | 1        | —          | `PC+4`                      |
| **Branch** (`beq,…`)    | **0**   | 0       | 0       | 0        | —          | target if taken else `PC+4` |
| **JAL**                 | 1       | 0       | 0       | x        | `PC+4`     | `PC + J-imm`                |
| **JALR**                | 1       | 0       | 0       | 1        | `PC+4`     | `(rs1+I-imm) & ~1`          |
| **LUI / AUIPC**         | 1       | 0       | 0       | 1        | imm / ALU  | `PC+4`                      |

> Quiz: `add x1,x2,x3` (`0000000_rs2_rs1_000_rd_0110011`) → `RegWr=1, ALUSrc=0, WBSel=ALU, PCSrc=PC+4`.

> [!IMPORTANT]
> Next-fetch in RV32I = `PC+4`, `PC+imm`, `rs1+imm`. **Memory indirection ❌** (no jump target loaded from memory).

## 2. ALU Control

==**`ALUOp`**==:

| `ALUOp`     | `00`                     | `01`              | `10`            |
| ----------- | ------------------------ | ----------------- | --------------- |
| **Use**     | load / store / JALR addr | branch compare    | R / I-ALU       |
| **ALU op**  | ADD                      | SUB / compare     | decode by funct |

==**`funct3` / `funct7[5]` decoding**==:

| `funct3`            | `000`           | `001`        | `010`        | `011`         | `100`        | `101`            | `110`       | `111`        |
| ------------------- | --------------- | ------------ | ------------ | ------------- | ------------ | ---------------- | ----------- | ------------ |
| **`funct7[5]=0`**   | `ADD / ADDI`    | `SLL / SLLI` | `SLT / SLTI` | `SLTU / SLTIU`| `XOR / XORI` | `SRL / SRLI`     | `OR / ORI`  | `AND / ANDI` |
| **`funct7[5]=1`**   | **`SUB`** (R)   | invalid      | invalid      | invalid       | invalid      | **`SRA / SRAI`** | invalid     | invalid      |

```verilog
always_comb begin
  case (alu_op)
    2'b00 : alu_control = ALU_ADD;       // load/store/JALR
    2'b01 : alu_control = ALU_SUB;       // branch
    2'b10 : case (funct3)
        3'b000: alu_control = funct7_5 ? ALU_SUB : ALU_ADD;
        3'b001: alu_control = ALU_SLL;
        3'b010: alu_control = ALU_SLT;
        3'b011: alu_control = ALU_SLTU;
        3'b100: alu_control = ALU_XOR;
        3'b101: alu_control = funct7_5 ? ALU_SRA : ALU_SRL;
        3'b110: alu_control = ALU_OR;
        3'b111: alu_control = ALU_AND;
      endcase
  endcase
end
```

## 3. Single-Cycle Datapath

```text
PC → IMem → decode/regfile/imm-gen → ALU → DMem → WBmux → rd
            \_______________ branch/jump PC mux ____________/
```

Three muxes: `PCSrc` (`PC+4` / `PC+imm` / `(rs1+imm)&~1`); `ALUSrcB` (`R[rs2]` / imm); `WBSel` (ALU / mem / `PC+4` / imm).

## 4. Worked Examples

```text
sw x2, offset(x1):   addr = R[x1]+signext(S-imm); mem[addr] = R[x2]
beq x1, x2, imm  :   taken = (R[x1]==R[x2]); next PC = taken? PC+B-imm : PC+4
```

| Signal     | `RegWr`     | `MemRd` | `MemWr` | `ALUSrc`         | `ALUCtrl`           | `WBSel` | `PCSrc`        |
| ---------- | ----------- | ------- | ------- | ---------------- | ------------------- | ------- | -------------- |
| **`sw`**   | 0 (no `rd`) | 0       | **1**   | 1 (imm)          | ADD                 | —       | `PC+4`         |
| **`beq`**  | 0 (no `rd`) | 0       | 0       | 0 (compare regs) | SUB / equality cmp  | —       | branch-mux     |





| Signal    | Meaning                               |
| --------- | ------------------------------------- |
| `RegWr`   | enable write to `rd`                  |
| `MemRd`   | DMem read (Load)                      |
| `MemWr`   | DMem write (Store)                    |
| `ALUSrc`  | ALU op B: 0=R[rs2], 1=imm             |
| `ALUCtrl` | ALU op (`ALUOp + funct3 + funct7[5]`) |
| `WBSel`   | WB mux: ALU / mem / PC+4 / imm        |
| `PCSrc`   | next-PC: PC+4 / PC+imm / (rs1+imm)&~1 |

==**Components**==: PC + next-PC mux, IMem/I-cache, ==**2R/1W regfile**==, imm-gen, ALU, DMem/D-cache, `PC+4` + `PC+imm` adders, WB mux.

==**Three MUX selects**==:

| Mux               | Choices                                                |
| ----------------- | ------------------------------------------------------ |
| ==**`PCSrc`**==   | `PC+4`, `PC+imm` (branch/JAL), `(rs1+imm)&~1` (JALR)   |
| ==**`ALUSrcB`**== | `R[rs2]` (R/branch) or imm (I/load/store/JALR)         |
| ==**`WBSel`**==   | ALU result, memory, `PC+4` (JAL/JALR), imm (LUI/AUIPC) |

## 6. Branch Datapath

==**`beq rs1, rs2, imm`**==: read regs; compare; taken → `PC + B-imm`, else `PC+4`.

==**Why 2 adders in EX**==: `PC+4` (always) + `PC + B-imm` (branch target); ALU busy comparing.

> [!IMPORTANT]
> ==**Branch comparator vs ALU subtract**==:
>
> 1. **avoid subtract-overflow compare bug**;
> 2. comparator **faster** than full subtractor;
> 3. frees ALU for addr/ALU in same cycle.
>
> NOT "comparison cannot trap" (irrelevant — RV doesn't trap on int overflow).

> Equality (`beq/bne`) via subtract-then-zero is safe (XOR=0 means equal).
