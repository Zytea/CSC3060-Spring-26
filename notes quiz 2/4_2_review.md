# Lec 4.2: Control

## Exam Facts

==**12 control signals**== (RV32I single-cycle datapath, `BrEq/BrLT` are BranchComp **outputs**; rest are Control-logic outputs):

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
      <td><code>0</code>: PC+4, <code>1</code>: branch/jump target</td>
      <td>ImmSel</td>
      <td><code>0</code>: I, <code>1</code>: S, <code>2</code>: B, <code>3</code>: U, <code>4</code>: J</td>
    </tr>
    <tr>
      <td>RegWr</td>
      <td><code>1</code>: write rd; <code>0</code>: store/branch</td>
      <td>MemRW</td>
      <td><code>0</code> (default) / <code>1</code> (stores)</td>
    </tr>
    <tr>
      <td>BrUn</td>
      <td><code>0</code>: signed, <code>1</code>: unsigned cmp</td>
      <td>BrEq</td>
      <td>output: rs1==rs2</td>
    </tr>
    <tr>
      <td>BrLT</td>
      <td>output: rs1&lt;rs2</td>
      <td>Asel</td>
      <td><code>0</code>: rs1, <code>1</code>: PC</td>
    </tr>
    <tr>
      <td>Bsel</td>
      <td><code>0</code>: rs2, <code>1</code>: imm</td>
      <td>ALUOp</td>
      <td><code>00</code>: ADD (L/S/JALR addr), <code>01</code>: SUB (branch), <code>10</code>: decode by funct</td>
    </tr>
    <tr>
      <td>ALUSel</td>
      <td><code>ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU</code></td>
      <td>WBSel</td>
      <td><code>0</code>: mem (ld), <code>1</code>: ALU (R/I/U), <code>2</code>: PC+4 (JAL/JALR)</td>
    </tr>
  </tbody>
</table>

> [!NOTE]
>
> - ==**PCSrc (RV32I)**==: `PC+4`, `PC+imm` (branch/JAL), `(rs1+imm)&~1` (JALR), trap vector (`mtvec`). **NOT** memory indirection.
> - **`Asel`**: `0=rs1` for R/I-ALU/load/store/JALR; `1=PC` for branch/JAL/AUIPC (ALU computes `PC+imm` target).
>
> - **`Bsel`**: `0=rs2` only for **R-type/branch-compare-input-side N/A**; `1=imm` for I-ALU/load/store/branch-target/JALR/LUI/AUIPC.
> - ==**`ALUSel`**== = `f(ALUOp, funct3, funct7[5])`. **Hardest signal to generate**.
>   - **`funct7[5]`**: distinguishes `ADD 0 / SUB 1` (R) and `SRL 0 / SRA 1` (R or I shift).


- ==**Control**==: maps `opcode + funct3 + funct7 + BrEq/BrLT` to **mux selects + write enables**.
- 
- **WB-stage signals propagated**: `rd`, `RegWr`, `WBSel`. **NOT** `ALUSel` (dies after EX).

## 1. Per-Instruction Control Table

| Instr      | `ImmSel` | `RegWr` | `Asel` | `Bsel` | `ALUSel` | `MemRW` | `WBSel`  | `PCSrc`         |
| ---------- | -------- | ------- | ------ | ------ | -------- | ------- | -------- | --------------- |
| **R-ALU**  | —        | 1       | 0      | 0      | funct    | 0       | 1 (ALU)  | 0               |
| **I-ALU**  | I        | 1       | 0      | 1      | funct    | 0       | 1 (ALU)  | 0               |
| **Load**   | I        | 1       | 0      | 1      | ADD      | 0       | 0 (mem)  | 0               |
| **Store**  | S        | **0**   | 0      | 1      | ADD      | **1**   | ×        | 0               |
| **Branch** | B        | **0**   | **1**  | 1      | ADD      | 0       | ×        | `BrEq/BrLT` mux |
| **JAL**    | J        | 1       | 1      | 1      | ADD      | 0       | 2 (PC+4) | 1               |
| **JALR**   | I        | 1       | 0      | 1      | ADD      | 0       | 2 (PC+4) | 1 (ALU&~1)      |
| **LUI**    | U        | 1       | ×      | 1      | B-pass   | 0       | 1        | 0               |
| **AUIPC**  | U        | 1       | 1      | 1      | ADD      | 0       | 1        | 0               |

==**Fast expressions**==:

```text
RegWr  = !(Branch || Store)
MemRW  = Store ? W : R
Bsel   = !R-type        # only R uses rs2 as ALU B-input
Asel   = Branch || JAL || AUIPC      # PC+imm targets
PCSrc  = (Branch && taken) || JAL || JALR
```

> [!IMPORTANT]
> Next-fetch in RV32I = `PC+4`, `PC+imm`, `rs1+imm`. **Memory indirection ❌**.

## 2. ALU Control

==**`ALUOp` → `ALUSel`**==:

| `ALUOp`     | `00`                     | `01`              | `10`            |
| ----------- | ------------------------ | ----------------- | --------------- |
| **Use**     | load / store / JALR addr | branch (ALU off)  | R / I-ALU       |
| **ALUSel**  | ADD                      | (don't care)      | decode by funct |

> Branch comparison runs in **BranchComp** (not ALU); ALU is free for `PC+imm` target.

==**`funct3` / `funct7[5]` decoding**==:

| `funct3`            | `000`           | `001`        | `010`        | `011`         | `100`        | `101`            | `110`       | `111`        |
| ------------------- | --------------- | ------------ | ------------ | ------------- | ------------ | ---------------- | ----------- | ------------ |
| **`funct7[5]=0`**   | `ADD / ADDI`    | `SLL / SLLI` | `SLT / SLTI` | `SLTU / SLTIU`| `XOR / XORI` | `SRL / SRLI`     | `OR / ORI`  | `AND / ANDI` |
| **`funct7[5]=1`**   | **`SUB`** (R)   | invalid      | invalid      | invalid       | invalid      | **`SRA / SRAI`** | invalid     | invalid      |

```verilog
always_comb begin
  case (alu_op)
    2'b00 : alu_sel = ALU_ADD;            // load/store/JALR addr
    2'b01 : alu_sel = ALU_ADD;            // branch target = PC+imm
    2'b10 : case (funct3)
        3'b000: alu_sel = funct7_5 ? ALU_SUB : ALU_ADD;
        3'b001: alu_sel = ALU_SLL;
        3'b010: alu_sel = ALU_SLT;
        3'b011: alu_sel = ALU_SLTU;
        3'b100: alu_sel = ALU_XOR;
        3'b101: alu_sel = funct7_5 ? ALU_SRA : ALU_SRL;
        3'b110: alu_sel = ALU_OR;
        3'b111: alu_sel = ALU_AND;
      endcase
  endcase
end
```

## 3. Single-Cycle Datapath

<img src="assets/CA3060-4-2-Control_2.png" alt="RV32I single-cycle datapath" style="zoom:50%;" />

==**Components**==: PC + next-PC mux, IMem, ==**2R/1W regfile**==, ImmGen, **BranchComp** (outputs `BrEq, BrLT`), ALU, DMem, `PC+4` adder, A-mux (`Asel`), B-mux (`Bsel`), WB mux.

==**4 key muxes**==:

| Mux              | Sel       | Choices                                   |
| ---------------- | --------- | ----------------------------------------- |
| ==**PC-mux**==   | `PCSrc`   | `PC+4` (0) or branch/jump target (1)      |
| ==**A-input**==  | `Asel`    | `R[rs1]` (0) or `PC` (1)                  |
| ==**B-input**==  | `Bsel`    | `R[rs2]` (0) or imm (1)                   |
| ==**WB-input**== | `WBSel`   | mem (0), ALU (1), `PC+4` (2)              |

## 4. Worked Examples

```text
sw  x2, off(x1):   addr = R[x1]+S-imm;     mem[addr] = R[x2]
beq x1, x2, imm:   target = PC + B-imm;    if R[x1]==R[x2] take, else PC+4
```

| Instr     | `ImmSel` | `RegWr` | `Asel`  | `Bsel`  | `ALUSel` | `MemRW` | `WBSel` | `BrUn` | `PCSrc`        |
| --------- | -------- | ------- | ------- | ------- | -------- | ------- | ------- | ------ | -------------- |
| **`sw`**  | S        | 0       | 0 (rs1) | 1 (imm) | ADD      | **W**   | ×       | ×      | 0              |
| **`beq`** | B        | 0       | 1 (PC)  | 1 (imm) | ADD      | R       | ×       | ×      | `BrEq ? 1 : 0` |

> ALU computes **address** for `sw` and **branch target** for `beq`; BranchComp does the actual `rs1==rs2` test.

## 5. Single-Cycle Drawback

Clock = `lw` critical path: `PC → IMem → Regfile → ALU(addr) → DMem → WBmux → Regfile setup` + clk-to-Q + skew. Shorter instrs (R, branch) **waste** the long clock. → Solution: pipeline stages.

> ==**RISC-V regularity simplifies control**==: fixed instr size, regular field positions, 12b/20b imm only, reg/imm operands only.

> Branch datapath details (comparator vs ALU subtract, why 2 adders) → [4_1_review.md §6](4_1_review.md).
