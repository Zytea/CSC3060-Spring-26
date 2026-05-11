# Lec 4.2: Control

## Exam Facts

==**12 control signals**==. `BrEq/BrLT` are **BranchComp outputs** fed back to Control; the rest are Control-logic outputs.

<table>
  <thead>
    <tr>
      <th>Signal</th><th>Options</th><th>Signal</th><th>Options</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>PCSrc</b><br/><sub>IF</sub></td>
      <td><code>0</code>: PC+4, <code>1</code>: branch/jump target</td>
      <td><b>ImmSel</b><br/><sub>ID</sub></td>
      <td><code>0</code>: I, <code>1</code>: S, <code>2</code>: B, <code>3</code>: U, <code>4</code>: J</td>
    </tr>
    <tr>
      <td><b>RegWr</b><br/><sub>ID/WB</sub></td>
      <td><code>0</code>: store/branch; <code>1</code>: write rd</td>
      <td><b>BrUn</b><br/><sub>EX</sub></td>
      <td><code>0</code>: signed, <code>1</code>: unsigned cmp</td>
    </tr>
    <tr>
      <td><b>BrLT</b><br/><sub>EX·out</sub></td>
      <td>rs1 &lt; rs2</td>
      <td><b>BrEq</b><br/><sub>EX·out</sub></td>
      <td>rs1 == rs2</td>
    </tr>
    <tr>
      <td><b>Bsel</b><br/><sub>EX</sub></td>
      <td><code>0</code>: rs2, <code>1</code>: imm</td>
      <td><b>Asel</b><br/><sub>EX</sub></td>
      <td><code>0</code>: rs1, <code>1</code>: PC</td>
    </tr>
    <tr>
      <td><b>ALUOp</b><br/><sub>EX</sub></td>
      <td><code>00</code>: ADD (L/S/JALR/branch target), <code>10</code>: decode by funct (R/I-ALU)</td>
      <td><b>ALUSel</b><br/><sub>EX</sub></td>
      <td><code>ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU</code></td>
    </tr>
    <tr>
      <td><b>MemRW</b><br/><sub>MEM</sub></td>
      <td><code>0</code>: read (default), <code>1</code>: write (stores)</td>
      <td><b>WBSel</b><br/><sub>WB</sub></td>
      <td><code>0</code>: mem (ld), <code>1</code>: ALU (R/I/U), <code>2</code>: PC+4 (JAL/JALR)</td>
    </tr>
  </tbody>
</table>
> [!NOTE]
>
> - ==**PCSrc sources (RV32I)**==: `PC+4`, `PC+imm` (branch/JAL), `(rs1+imm)&~1` (JALR), trap vector (`mtvec`). **NOT** memory indirection.
> - **`Asel`**: `0=rs1` for R/I-ALU/load/store/JALR; `1=PC` for branch/JAL/AUIPC (ALU = `PC+imm` target).
> - **`Bsel`**: `0=rs2` **only for R-type**; `1=imm` everywhere else.
> - ==**`ALUSel`**== = `f(ALUOp, funct3, funct7[5])`. **Hardest signal to generate**.
>   - `funct7[5]`: distinguishes `ADD 0 / SUB 1` and `SRL 0 / SRA 1`.

- ==**Control**==: maps `opcode + funct3 + funct7 + BrEq/BrLT` → **mux selects + write enables**.
  - **WB-stage signals propagated**: `rd`, `RegWr`, `WBSel`. **NOT** `ALUSel` (dies after EX).


## 1. Per-Instruction Control Table

IF → ID → EX → MEM → WB:

| Instr       | `PCSrc`           | `ImmSel` | `RegWr` | `BrUn` | `Bsel`  | `Asel`     | `ALUSel` | `MemRW` | `WBSel`  |
| ----------- | ----------------- | -------- | ------- | ------ | ------- | ---------- | -------- | ------- | -------- |
| **R-ALU**   | 0                 | —        | 1       | ×      | 0 (rs2) | 0 (rs1)    | funct    | 0       | 1 (ALU)  |
| **I-ALU**   | 0                 | I        | 1       | ×      | 1 (imm) | 0 (rs1)    | funct    | 0       | 1 (ALU)  |
| **I-Load**  | 0                 | I        | 1       | ×      | 1       | 0 (rs1)    | ADD      | 0       | 0 (mem)  |
| **Store**   | 0                 | S        | **0**   | ×      | 1       | 0          | ADD      | **1**   | ×        |
| **B**       | `BrEq/BrLT` → 0/1 | B        | **0**   | 0/1    | 1       | **1** (PC) | ADD      | 0       | ×        |
| **JAL**     | 1                 | J        | 1       | ×      | 1       | 1          | ADD      | 0       | 2 (PC+4) |
| **I-JALR**  | 1 (ALU & ~1)      | I        | 1       | ×      | 1       | 0          | ADD      | 0       | 2 (PC+4) |
| **U-LUI**   | 0                 | U        | 1       | ×      | 1       | ×          | ADD      | 0       | 1        |
| **U-AUIPC** | 0                 | U        | 1       | ×      | 1       | 1          | ADD      | 0       | 1        |

==**Fast expressions**==:

```cpp
PCSrc  = (Branch && taken) || JAL || JALR
RegWr  = !(Branch || Store)
Bsel   = !R-type                     // only R uses rs2 as ALU B-input
Asel   = Branch || JAL || AUIPC      // PC+imm target
MemRW  = Store                       // 1 only for stores
```

> [!IMPORTANT]
> Next-fetch in RV32I = `PC+4`, `PC+imm`, `rs1+imm`. **Memory indirection ❌**.

## 2. ALU Control

==**`ALUOp` → `ALUSel`**==:

| `ALUOp`    | `00`                                         | `10`            |
| ---------- | -------------------------------------------- | --------------- |
| **Use**    | load / store / JALR addr / branch target / U | R / I-ALU       |
| **ALUSel** | ADD                                          | decode by funct |

> If not `BranchComp` → 01

==**`funct3` / `funct7[5]` decoding**==:

| `funct3`          | `000`         | `001`        | `010`        | `011`          | `100`        | `101`            | `110`      | `111`        |
| ----------------- | ------------- | ------------ | ------------ | -------------- | ------------ | ---------------- | ---------- | ------------ |
| **`funct7[5]=0`** | `ADD `        | `SLL / SLLI` | `SLT / SLTI` | `SLTU / SLTIU` | `XOR / XORI` | `SRL / SRLI`     | `OR / ORI` | `AND / ANDI` |
| **`funct7[5]=1`** | **`SUB`** (R) | invalid      | invalid      | invalid        | invalid      | **`SRA / SRAI`** | invalid    | invalid      |

```verilog
always_comb begin
  case (alu_op)
    2'b00 : alu_sel = ALU_ADD;            // L/S/JALR/branch target
    2'b01 : alu_control = ALU_SUB;        // if no branchcmp
    2'b10 : case (funct3)
        3'b000: alu_sel = funct7_5 ? ALU_SUB : ALU_ADD;
        3'b001: alu_sel = ALU_SLL;        // SLL / SLLI
        3'b010: alu_sel = ALU_SLT;        // SLT / SLTI
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

==**Components**== (left→right): PC + PC-mux, IMem, ==**2R/1W regfile**==, ImmGen, **BranchComp** (outputs `BrEq, BrLT`), B-mux (`Bsel`), A-mux (`Asel`), ALU, DMem, WB mux.

==**4 datapath muxes**== (left→right):

| Mux              | Sel       | Choices                                | Stage |
| ---------------- | --------- | -------------------------------------- | ----- |
| ==**PC-mux**==   | `PCSrc`   | `PC+4` (0) or branch/jump target (1)   | IF    |
| ==**B-input**==  | `Bsel`    | `R[rs2]` (0) or imm (1)                | EX    |
| ==**A-input**==  | `Asel`    | `R[rs1]` (0) or `PC` (1)               | EX    |
| ==**WB-input**== | `WBSel`   | mem (0), ALU (1), `PC+4` (2)           | WB    |

## 4. Worked Examples

```text
sw  x2, off(x1):   addr = R[x1]+S-imm;   mem[addr] = R[x2]
beq x1, x2, imm :  target = PC + B-imm;  if R[x1]==R[x2] take, else PC+4
```

Same column order as §1:

| Instr     | `PCSrc`        | `ImmSel` | `RegWr` | `BrUn` | `Bsel`  | `Asel`     | `ALUSel` | `MemRW` | `WBSel` |
| --------- | -------------- | -------- | ------- | ------ | ------- | ---------- | -------- | ------- | ------- |
| **`sw`**  | 0              | S        | 0       | ×      | 1 (imm) | 0 (rs1)    | ADD      | **1**   | ×       |
| **`beq`** | `BrEq ? 1 : 0` | B        | 0       | 0      | 1 (imm) | **1** (PC) | ADD      | 0       | ×       |

> ALU computes **address** for `sw` and **branch target** (`PC+imm`) for `beq`; **BranchComp** does the actual `rs1==rs2` test and emits `BrEq` to Control, which sets `PCSrc`.

## 5. Single-Cycle Drawback

Clock = `lw` critical path: `PC → IMem → Regfile → ALU(addr) → DMem → WBmux → Regfile setup` + clk-to-Q + skew. Shorter instrs (R, branch) **waste** the long clock. → Solution: pipeline stages.

> ==**RISC-V regularity simplifies control**==: fixed instr size, regular field positions, 12b/20b imm only, reg/imm operands only.

> Branch datapath details (comparator vs ALU subtract, why 2 adders) → [4_1_review.md §6](4_1_review.md).
