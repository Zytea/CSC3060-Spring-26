# Lec 3: RISC-V ISA

## Exam Facts

- ==**ISA**==: software-visible contract: instructions, regs, memory model, exceptions, ABI-visible behavior. Computer architecture = SW/HW interface.
- ==**RISC-V**==: open, modular, **load/store**, mostly **fixed 32b** instructions; ISA does **not** require caches.
  - **Modular naming**: `RV{32/64/128}{I/E}{M,A,F,D,C,V,...}`; **base must be `I` or `E`**; 
  - **`RV32E`**: embedded base, **16 GPRs**. 
  - ==**"32" in RV32I**== = **GPR/address width** (4 GiB addressable). NOT "32-bit instruction length"
  - **Low-cost / mobile RV core**: add `C` first if code size / I-cache / memory footprint matters.
  - ==**RVV (`V`)**==: vector extension; **vector-length agnostic (VLA)** so one binary runs efficiently on **different vector lengths**; compiler allocates vector regs and vector loads/stores expose memory patterns.

- ==**RV32I architectural state**==: **32 GPRs `x0-x31` + PC + CSRs**. **RV64IFD**: + FP regs. **RV64IFV**: + FP + vector regs.
- **Microarchitectural state** (regenerable, NOT saved on interrupt): pipeline regs, BHT, BTB, L1I/L1D caches.
  - **RV64I-only**: `LD`, `SD`, `LWU`, `ADDW`, `SLLW`, `SLLIW`, `SRAIW`, `SRLIW`, `SUBW`. **`LDU` is NOT an RV64I instr**. 
  - **Scalar RV32I regfile**: ==**2R / 1W**==. **2-issue scalar**: ~4R/2W. **2-issue FMA FP**: 6R/2W.
  - **No `rd` field**: ==**branches and stores**== (B/S types).
  - ==**Reach**==: branch B-type $12b|0\approx \pm 4\,\text{KiB}$; `JAL` $20b|0\approx \pm 1\,\text{MB}$; `AUIPC+JALR` $32b\approx \pm 2\,\text{GB}$ PC-rel; reg+`JALR` = full $4 GB$ (thus offset in **2-byte units** for  `C`)
  - **Return idiom**: `jalr x0, ra, 0` (= `ret`); procedure return.
  - **Rejected memory forms**: no `LW rd, (rs1+rs2)` (no scaled index); no post-increment load. Reasons: regularity break, extra reg ports, harder hazards/precise exceptions.
  - **`SLLI/SRLI/SRAI` in RV32**: `shamt = imm[4:0]` (5b, 31). `SLLI X5,X6,35` ❌ .
  - **Imm widths in RV32I**: **12b** (I/S/B) and **20b** (U/J). To load 32b const: pseudo-`li` or `lui+addi`; need adjustment ← low 12b has high bit set (signed extension❌ ).

- ==**ABI**==:==ISA + OS + calling convention==. Defines arg/return regs, caller/callee-save split, stack/frame conventions; **NOT** variable names or "legal C data types".
- ==**Hart**==: hardware thread with own architectural state (PC, GPRs, CSRs); a multicore chip can host multiple harts.
  - **`x0` always 0**: clear, copy (`add rd,x0,rs`), compare (`beq rs,x0,L`), discard result, mem hint (`lw x0,0(rs)`).
  - **No `BLE`/`BGT`**: regularity — swap operands of `BLT`/`BGE`.
  - **Bounds-check trick**: `bgeu idx, len, out` catches both `idx<0` (huge unsigned) and `idx≥len`.

- **Natural alignment**: object size N at addr multiple of N. Avoids cache-line / page crossing → no double-miss / double-fault / extra HW.
  - **RISC-V Linux ABI stack alignment**: ==**$16B$**==. RV32E: $4B$
  - **Struct rules**: $$\text{field offset} = N \times \text{field align}$$
  ; $\text{total size} = N \times \text {max field align}$; **fields cannot be reordered** (locals can).

- **R4-type FMA**: `rd = rs1*rs2 + rs3` — only R4 instr in RV ISA. Could be redesigned with 3 ops as `rd = rs1*rs2 + rd` (rd as src+dst), but **breaks regularity**.

## 1. Assembly Language Instructions

### 1.1 CISC vs RISC

| Feature           | instr length                     | addressing modes      | memory ops               | pipeline / decode |
| ----------------- | -------------------------------- | --------------------- | ------------------------ | ----------------- |
| **CISC**          | variable                         | many                  | many instrs touch memory | harder            |
| **RISC / RISC-V** | fixed 32b base, optional 16b `C` | few (load/store only) | only `LW/SW`-class       | easier            |

==**Iron Law**==:
$$
\text{CPU\ Time} = \text{Instruction Count} \times CPI \times \text{Clock Cycle Time}
$$
| Metric              | RISC simplicity          | CISC compactness         | SIMD/vector/RVV                   | Pipeline        | Superscalar / OoO / Pred / Cache |
| ------------------- | ------------------------ | ------------------------ | --------------------------------- | --------------- | -------------------------------- |
| **Mainly improves** | CPI↓ / cycle time↓ (IC↑) | IC↓ (CPI↑ / cycle time↑) | **IC↓** (many elements per instr) | **cycle time↓** | **CPI↓**                         |

> Modern x86: variable-length CISC at ISA level, but decoders translate into RISC-style μops internally.

### 1.2 RISC Design Principles

1. ==**Simplicity favors regularity**== — fixed-size instrs, regular field positions, opcode in fixed bits.
2. ==**Smaller is faster**== — limited instr set, regs, addressing modes.
3. ==**Make the common case fast**== — operands from regs (load/store), allow imm.
4. ==**Good design demands compromise**== — balance instr formats vs operand count.

> Judge an ISA by **compiler/codegen quality + HW cost**, not by human-written.

### 1.3 Bases and Extensions

| **`I`**           | **`E`**                | `M`                | `A`                            | `F` / `D` | **`C`**        | `V`                                                   |
| ----------------- | ---------------------- | ------------------ | ------------------------------ | --------- | -------------- | ----------------------------------------------------- |
| base int, 32 GPRs | embedded base, 16 GPRs | integer $\times /$ | atomic memory ops (Multi-core) | FP16/32   | **16b instrs** | **VLA** for portability across vector-register widths |

## 2. RV32I Instructions and Architecture State

### 2.1 RV32I Instruction Set (Base, no `M`)

| Category | Instrs | Opcode |
|---|---|---|
| R | `ADD SUB AND OR XOR SLT SLTU SLL SRL SRA` | `0110011` |
| I | `ADDI SLTI SLTIU ANDI ORI XORI SLLI SRLI SRAI` | `0010011` |
| I Load | `LB LH LW LBU LHU` | `0000011` |
| S | `SB SH SW` | `0100011` |
| B | `BEQ BNE BLT BGE BLTU BGEU` | `1100011` |
| J | `JAL (1101111) JALR (I, 1100111)` | ← |
| U imm | `LUI (0110111) AUIPC (0010111)` | ← |
| I CSR | `ECALL EBREAK CSRRW CSRRS CSRRC` | `1110011` |

### 2.2 Architectural State

**RV32I**: `x0-x31`, **PC**, CSRs; **RV64IFD**: + 32 FP regs; **RV64IFV**: + 32 vector regs.

- `x0` hardwired to 0: clear, copy, compare, discard, memory hint (`lw x0,0(x1)` to test access).
- CSRs: `cycle`, `instret`, `hartid`, `mepc`, `mcause`, `mtvec`, `mstatus`.
- ==**Hart**==: HW thread with own arch state.

==**Architectural vs Microarchitectural state**==:

| State | Class | Save on interrupt? |
|---|---|---|
| `x0-x31`, PC, CSRs (RV32I) | architectural | yes |
| FP / vector regs (when ISA includes them) | architectural | yes |
| BHT, BTB, pipeline regs, L1I/L1D | **microarchitectural** | **no** (regenerable) |
| Overflow/underflow flags | **not** in RV32I | n/a |

## 3. Instruction Encoding Formats

### 3.1 Format Overview

```text
31           25 24       20 19       15 14   12 11        7 6           0
┌─────────────┬───────────┬───────────┬───────┬───────────┬─────────────┐
│   funct7    │    rs2    │    rs1    │funct3 │    rd     │   opcode    │ R
├─────────────┴───────────┼───────────┼───────┼───────────┼─────────────┤
│        imm[11:0]        │    rs1    │funct3 │    rd     │   opcode    │ I
├─────────────┬───────────┼───────────┼───────┼───────────┼─────────────┤
│  imm[11:5]  │    rs2    │    rs1    │funct3 │ imm[4:0]  │   opcode    │ S
├─────────────┼───────────┼───────────┼───────┼───────────┼─────────────┤
│imm[12|10:5] │    rs2    │    rs1    │funct3 │imm[4:1|11]│   opcode    │ B
├─────────────┴───────────┴───────────┴───────┼───────────┼─────────────┤
│                 imm[31:12]                  │    rd     │   opcode    │ U
├─────────────────────────┬───────────────────┼───────────┼─────────────┤
│     imm[20|10:1|11]     │    imm[19:12]     │    rd     │   opcode    │ J
└─────────────────────────┴───────────────────┴───────────┴─────────────┘
```

==**Regular field positions**== (regularity → start rs1/rs2 read before full decode):

> Opcode all-`0000000` is **NOT allocated** → all-zero 32b instr is **illegal** in RV32I.

> Example:
>
> ```text
> 0x00000013 = 0000 0000 0000 | 00000 | 000 | 00000 | 0010011
>               imm[11:0]=0   | rs1=x0| f3=0| rd=x0 | opcode=I-ALU
> → ADDI x0, x0, 0     (writes to x0 = no effect = NOP)
> ```
>
> ```text
> 0x00208093 = 0000 0000 0010 | 00001 | 000 | 00001 | 0010011
>               imm=2          | rs1=x1| f3=0| rd=x1 | opcode=I-ALU
> → ADDI x1, x1, 2
> ```
>

### 3.2 R-Type `rd = rs1 op rs2`

```
31           25 24       20 19       15 14   12 11        7 6           0
│   funct7    │    rs2    │    rs1    │funct3 │    rd     │   opcode    │ 
```

| Field        | `ADD`   | `SUB`         | `SLL`   | `SLT`   | `SLTU`  | `XOR`   | `SRL`   | `SRA`         | `OR`    | `AND`   |
| ------------ | ------- | ------------- | ------- | ------- | ------- | ------- | ------- | ------------- | ------- | ------- |
| **`funct3`** | `000`   | `000`         | `001`   | `010`   | `011`   | `100`   | `101`   | `101`         | `110`   | `111`   |
| **`funct7`** | `0...0` | **`0100000`** | `0...0` | `0...0` | `0...0` | `0...0` | `0...0` | **`0100000`** | `0...0` | `0...0` |

> Quiz: `funct7[5]` distinguishes `ADD 0/SUB 1` and `SRL 0/SRA 1`; rest of `funct7` is 0 → trap inputs to ALU control.

### 3.3 I-Type 

```
31                      20 19       15 14   12 11        7 6            0
│        imm[11:0]        │    rs1    │funct3 │    rd     │   opcode    │ 
```

`I-imm = signext(inst[31:20])`  (12b signed, range `-2048..+2047`).

| Class | Behavior | Opcode |
|---|---|---|
| I-ALU | `rd = rs1 op imm12` | `0010011` |
| Load | `rd = mem[rs1 + imm12]` (offset in **bytes**) | `0000011` |
| `JALR` | `rd=PC+4; PC=(rs1+imm12) & ~1` | `1100111` |

==**Shift I-type**== (`SLLI/SRLI/SRAI`): `shamt = imm[4:0]` (RV32) / `imm[5:0]` (RV64); `inst[30]` distinguishes `SRLI` (0) vs `SRAI` (1).

> Trap: `SLLI X5,X6,35` is **invalid in RV32I** (shamt > 31).

==**Loads**==:

| Instr      | `LB`     | `LH`     | `LW`       | `LBU` | `LHU` |
| ---------- | -------- | -------- | ---------- | ----- | ----- |
| **Extend** | **sign** | **sign** | (fill 32b) | zero  | zero  |

> No `LWU` in RV32I — `LW` already fills the GPR. Only matters in RV64I (`LWU` zero-extends to 64b).

### 3.4 S-Type (Stores)

```
31                      20 19       15 14   12 11        7 6            0
│  imm[11:5]  │    rs2    │    rs1    │funct3 │ imm[4:0]  │   opcode    │
```

`S-imm = signext({inst[31:25], inst[11:7]})` — 12b signed split. Opcode `0100011`.

```text
mem[rs1 + S-imm] = rs2
```

- `SB / SH / SW` (`funct3 = 000 / 001 / 010`). **No `rd` field** (overwritten by `imm[4:0]`).

### 3.5 B-Type (Branches)

```
31                      20 19       15 14   12 11        7 6            0
│imm[12|10:5] │    rs2    │    rs1    │funct3 │imm[4:1|11]│   opcode    │
```

`B-imm = signext({inst[31], inst[7], inst[30:25], inst[11:8], 0})`

- 13-bit signed byte offset with **implicit bit0=0** → reach ≈ **±4 KiB**. Opcode `1100011`.
- No `rd`. Compare `rs1` and `rs2`; PC = taken ? PC+B-imm : PC+4.

| Branch | `funct3` | Compare |
|---|---|---|
| `BEQ` / `BNE` | `000` / `001` | equal / not equal |
| `BLT` / `BGE` | `100` / `101` | **signed** < / ≥ |
| `BLTU` / `BGEU` | `110` / `111` | **unsigned** < / ≥ |

> [!IMPORTANT]
> S-type imm is **base-relative byte offset** (rs1+imm). B-type imm is **PC-relative** with implicit low `0`, has **no `rd`**, and offset is in **2-byte units** (so `C` ext compressed 16b instrs are reachable).
>
> ==**No `BGT/BLE`**==: regularity. 

> [!NOTE]
>
> **S vs B Imm**: **rearrangement keeps `funct3, rs1, rs2` in fixed positions** so decode + regfile read are the same. Tradeoff: imm bits scattered, but HW just reroutes wires (no cost).
>
> Same idea: **U vs J Imm**both 20b, but J reorders bits to keep regularity.

==**Bounds check trick**== (single instr catches both negative and over):

```asm
# int A[len], idx in x5, len in x6
bgeu x5, x6, out_of_bounds   # signed-neg becomes huge unsigned, also catches idx ≥ len
```

### 3.6 U-Type (`LUI`, `AUIPC`)

```
31                                          12 11        7 6            0
│                 imm[31:12]                  │    rd     │   opcode    │
```

| Instr | Opcode | Behavior |
|---|---|---|
| `LUI rd, imm20` | `0110111` | `rd = imm20 << 12` (load upper imm) |
| `AUIPC rd, imm20` | `0010111` | `rd = PC + (imm20 << 12)` (PC-rel base) |

### 3.7 J-Type and JALR

```
31                      20 19               12 11        7 6            0
│     imm[20|10:1|11]     │    imm[19:12]     │    rd     │   opcode    │
```

`J-imm = signext({inst[31], inst[19:12], inst[20], inst[30:21], 0})`

- `JAL rd, imm`: J-type, opcode `1101111`. `rd = PC+4; PC = PC + J-imm`. Reach ≈ **±1 MiB** (21b signed, bit0=0).
- `JALR rd, rs1, imm`: I-type, opcode `1100111` (`funct3=000`). `rd = PC+4; PC = (rs1+imm12) & ~1`. Reach: full 32b address space via reg.

==**Common forms**==:

```asm
jal  ra, func        # call (saves return PC in ra)
jal  x0, label       # plain jump (rd=0 discards link)
jalr x0, ra, 0       # ret (return)
jalr ra, rs1, 0      # indirect call (function pointer)
```

> "Jump and Link" naming: a *call* must both jump AND save return PC; rd=`x0` repurposes for plain jump (no separate JUMP needed → simpler ISA).

==**Reach quick facts**==:

| Mechanism    | Branch B-type        | `JAL`                | `AUIPC + JALR`              | reg-based `JALR` |
| ------------ | -------------------- | -------------------- | --------------------------- | ---------------- |
| **Reach**    | $\approx \pm 4$ KiB  | $\approx \pm 1$ MiB  | $\approx \pm 2$ GiB PC-rel  | full 4 GiB       |

> Quiz: "Jump can be used for function calls" ✅ (rd=ra). "JALR has larger jump range than JAL" ✅ (full 32b vs ±1 MiB). "Jump instrs are UJ type" ❌ — only `JAL` is J-type; `JALR` is **I-type**.

## 4. Data Alignment and Layout

### 4.1 Natural Alignment

==**Natural alignment**==: object of size N starts at addr multiple of N.

| Type (LP64)        | `char` | `short` | `int` / `float` | `long` / `double` / pointer |
| ------------------ | ------ | ------- | --------------- | --------------------------- |
| **Size = Align**   | 1      | 2       | 4               | 8                           |

==**Why required**==:
- avoid **cache-line crossing** (would need 2 accesses).
- avoid **double TLB miss / double page fault** from 1 mem instr.
- HW simpler (no misaligned-fixup logic).
- better cache-line utilization.

> Cache lines: typically 64 B (also 32, 128). Pages: 4 KiB+.

### 4.2 Struct Padding Rules
$$
\text{field offset} = N \times \text{field align}; \quad \text{total size} = N \times \text {max field align}
$$

1. **Compiler cannot reorder struct fields** (C standard guarantees order); **independent locals can** be reordered.
2. **Reordering large→small** often shrinks padding.

```c
T   A[R][C][D];   &A[i][j][k] = base + (D*(C*i + j) + k) * sizeof(T)
```

### 4.3 Worked Struct Quiz Pattern

```c
struct S1 { int white; long count; char c; long red; int green; char d; int blue; }
// field offset = (4+4) + 8 + (1+7) + 8 + 4 + (1+3) + 4 + trail 4 = 48
struct S1 A[1000]; // offset = base + 48 * i
A[10].blue = 0;    // offset = base + 48 * 10 + 40
```

## 5. Codegen Patterns

Assume RV32I: unsigned `a` in `a0`, signed `b` in `a1`, signed `c` in `a2`.

| C | RV32I | Notes |
|---|---|---|
| `a*4` | `slli t0, a0, 2` | shift cheaper than mul |
| `b*61` | `slli t0,a1,6; slli t1,a1,2; sub t0,t0,t1; add t0,t0,a1` | `64-4+1 = 61` |
| `a/8` | `srli t0, a0, 3` | logical (unsigned) |
| `b>>3` | `srai t0, a1, 3` | arithmetic |
| `b/8` | `bge a1,x0,L; addi a1,a1,7; L: srai t0,a1,3` | bias for negative |
| `a%128` | `andi t0, a0, 0x7f` | low 7 bits |
| `pow(2,a)` | `addi t0,x0,1; sll t0,t0,a0` | `1 << a` |
| `a = (b >= c)` | `slt a0,a1,a2; xori a0,a0,1` | invert "<" |
| `b * c` (no `M`) | shift-and-add loop | software emulation |

```asm
# a0 = b * c, b in a1, c in a2
xor  a0, a0, a0          # result = 0
loop:
    andi t0, a2, 1       # LSB of c
    beqz t0, skip
    add  a0, a0, a1      # result += b
skip:
    slli a1, a1, 1       # b <<= 1
    srli a2, a2, 1       # c >>= 1
    bnez a2, loop
```

```asm
# unsigned division
# a1 = dividend, a2 = divisor, a0 = quotient, a3 = remainder
    beq  a2, x0, div_zero
    addi a0, x0, 0      # q = 0
    addi a3, x0, 0      # r = 0
    addi t1, x0, 32
loop:
    srli t0, a1, 31     # next dividend bit
    slli a1, a1, 1      # consume bit
    slli a3, a3, 1      # r <<= 1
    or   a3, a3, t0     # r |= next bit
    slli a0, a0, 1      # q <<= 1
    bltu a3, a2, skip   # if r < divisor, q bit = 0
    sub  a3, a3, a2     # r -= divisor
    addi a0, a0, 1      # q bit = 1
skip:
    addi t1, t1, -1
    bne  t1, x0, loop
    jal  x0, done
div_zero:
    addi a0, x0, -1     # DIVU quotient on /0
    add  a3, a1, x0     # remainder = dividend
done:
```

### 5.1 Loading 32-bit Constants

==**Pseudo `li`**== (preferred when assembler available):

```asm
li x2, 0xAABBCCDD        # assembler picks correct lui+addi or lui-only
```

==**Manual `lui + addi`**==:

```asm
# 0x12345678  (low 12b 0x678 < 0x800: simple case)
lui  x1, 0x12345
addi x1, x1, 0x678

# 0x12345800  (low 12b sign bit set: must adjust upper)
lui  x1, 0x12346         # NOT 0x12345!
addi x1, x1, -0x800      # sign-extends to 0xFFFFF800
```

> Why adjust: `addi` imm is **signed 12b**. If low 12b ≥ 0x800, it sign-extends negative; `lui` upper must be incremented to compensate.

==**Common pseudo-instr expansions**==:

<table border="1" style="border-collapse: collapse; width: 100%;">
  <thead>
    <tr style="background-color: #f2f2f2;">
      <th style="padding: 10px; text-align: left;">Pseudo</th>
      <th style="padding: 10px; text-align: left;">Expansion</th>
      <th style="padding: 10px; text-align: left;">Pseudo</th>
      <th style="padding: 10px; text-align: left;">Expansion</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 10px;"><code>mv rd, rs</code></td>
      <td style="padding: 10px;"><code>addi rd, rs, 0</code></td>
      <td style="padding: 10px;"><code>j label</code></td>
      <td style="padding: 10px;"><code>jal x0, label</code></td>
    </tr>
    <tr>
      <td style="padding: 10px;"><code>ret</code></td>
      <td style="padding: 10px;"><code>jalr x0, ra, 0</code></td>
      <td style="padding: 10px;"><code>jr rs</code></td>
      <td style="padding: 10px;"><code>jalr x0, rs, 0</code></td>
    </tr>
    <!-- 这里的两行不并排，独占一行 -->
    <tr>
      <td style="padding: 10px;"><code>call label</code></td>
      <td colspan="3" style="padding: 10px;"><code>auipc ra, hi20; jalr ra, lo12(ra)</code> (far call)</td>
    </tr>
    <tr>
      <td style="padding: 10px;"><code>li rd, imm</code></td>
      <td colspan="3" style="padding: 10px;"><code>addi</code> if 12b; else <code>lui+addi</code> (adjust if low12 sign bit)</td>
    </tr>
    <tr>
      <td style="padding: 10px;"><code>bgt rs,rt,L</code></td>
      <td style="padding: 10px;"><code>blt rt,rs,L</code></td>
      <td style="padding: 10px;"><code>ble rs,rt,L</code></td>
      <td style="padding: 10px;"><code>bge rt,rs,L</code></td>
    </tr>
    <tr>
      <td style="padding: 10px;"><code>nop</code></td>
      <td style="padding: 10px;"><code>addi x0,x0,0</code></td>
      <td style="padding: 10px;"><code>not rd,rs</code></td>
      <td style="padding: 10px;"><code>xori rd,rs,-1</code></td>
    </tr>
    <tr>
      <td style="padding: 10px;"><code>neg rd,rs</code></td>
      <td style="padding: 10px;"><code>sub rd,x0,rs</code></td>
      <td style="padding: 10px;"></td>
      <td style="padding: 10px;"></td>
    </tr>
  </tbody>
</table>
==**Pop-quiz anchors**==:

| Question | Answer |
|---|---|
| imm widths in RV32I | **12b** (I/S/B, B's bit0=0) and **20b** (U/J, J's bit0=0) |
| set `x2 = 0` | `add x2,x0,x0` ✅; `xor x2,x2,x2` ✅; `addi x2,x2,0`/`or x2,x2,x2` ❌ |
| no `rd` | branches, stores |
| RV32I means | load/store, 3-operand, RISC, 32b GPR/address |
| return | `jalr x0, ra, 0` |
| direct call | `jal ra, offset` |

### 5.2 C-to-RV Translation Examples

==**Bounds check pattern**==:

```asm
# int A[100], idx in x5, len=100 in x6
bgeu x5, x6, out_of_bounds    # also catches idx<0 (becomes huge unsigned)
slli t0, x5, 2
add  t0, t0, A
lw   x, 0(t0)
```

==**Masked operations**==:

```asm
# extract low 10 bits (= A % 1024)
andi rd, A, 0x3FF      # 0x3FF = 0b 0...0 1111111111
# clear low 10 bits
li   t0, 0xFFFFFC00
and  rd, A, t0
# set bit 2 and 3
ori  rd, A, 0xC        # 0xC = 0b 1100
```

## 6. ISA Design Traps

### 6.1 Should We Have 1024 Registers?

**No**, for RV64I:

- 5b → 11b reg field → larger instr or fewer bits for imm/opcode.
- bigger/slower regfile, many more ports.
- much more save/restore at calls + context switches.
- **arrays/structs/strings/stacks still need memory** — most loads/stores come from these, not scalar variables.
- Itanium had 128, but most compilers couldn't use them efficiently.

### 6.2 FMA / R4-Type

`FMA: rd = rs1 * rs2 + rs3` — only **R4-type** in RV ISA (4 reg fields).

==**Could you redesign with 3 operands?**== Yes: `rd = rs1*rs2 + rd` (rd as both src + dst). Supports dot product / matmul. **But breaks regularity**: in RV, `rd` is always write-only, never a source. Adopting this would force every consumer of the instr format to handle the irregularity.

==**Why FMA is 5–6 cycles, not 9 (FMUL 5 + FADD 4)?**==

- FMUL needs partial-product reduction (multi-cycle); FADD's exp alignment runs **in parallel** with reduction.
- After mul reduction, the add happens directly — **skip intermediate normalize/round**.
- One **final rounding** (saves 2 cycles); parallel exp align (saves 1 cycle).

==**FMA Benefits**==: 2 FLOPs/cycle; lower latency; **higher precision** (one round, not two); smaller code; less power.

### 6.3 No `LW rd, (rs1+rs2)`

For `A[i]`, address = `base + i*sizeof(elem)`, **not** `base + i`.

- Scaling in load complicates addressing.
- Pre-computing scaled index removes the supposed instr-count benefit.
- Loops often increment ptr by elem size.
- Would need 3 reg fields **plus** memory semantics → format break.

### 6.4 No Post-Increment Load (`rd=mem[rs1+imm]; rs1=rs1+imm`)

- Two register writes per instr → **need 2 write ports**.
- `rs1` is both source and destination → breaks regularity.
- Harder forwarding/hazards/precise exceptions.

### 6.5 Compare-and-Branch vs Condition Codes

RV uses **explicit compare-and-branch** (`beq, blt`), not hidden condition-code flags.

| Compare-and-branch | Condition codes (x86) |
|---|---|
| no implicit flag dep, simpler arch state, easier OoO/precise state | one cmp can drive several branches; flags create hidden deps that complicate reordering |

### 6.6 ISA Design Checklist

| Proposal | Class answer |
|---|---|
| 1024 GPRs | **No** — slower access, more save/restore, longer instr; arrays/strings/stack still need mem |
| fast-call single-instr (CALLS-style) | usually **no** — complex stack/reg side effects |
| reg pairs for wider data | hurts regularity; use ext / ABI rules |
| condition codes as ALU side effect | **No** — hidden flag deps, extra arch state; compare-and-branch is regular |
| static branch-prediction bit | not worth encoding cost vs modern dynamic predictors |
| HP-style: reg order = pred (`beq r3,r4` predict NT; `beq r4,r3` predict T) | rejected — encoding + asymmetry costs |
| arrays/structs/strings in regs | **no** — need memory layout, addresses, var indexing |

## 7. Exceptions, CSRs, GDB

### 7.1 Trap Flow

```text
exception → save mepc/mcause/mstatus.mpp → jump to mtvec handler
         → handler saves clobbered GPRs (uses mscratch swap)
         → handler logic (emulate / abort / resume)
         → mret: PC←mepc, restore privilege/enables
```

| CSR | Use |
|---|---|
| `mepc` | exception PC (return target) |
| `mcause` | interrupt bit + cause code |
| `mtvec` | trap vector base = base address + mode |
| `mstatus` | mode + interrupt enables |
| `mscratch` | scratch swap (often holds kernel sp) |
| `cycle`, `instret` | perf counters (read-only at user mode) |
| `hartid` | hart ID |

==**Save / Restore on trap**==: only **architectural state** (GPRs, PC, CSRs the handler uses); **microarch state regenerates**.

==**Emulating `mul` on RV32I**== (no `M`): trap handler reads instr at `mepc`, decodes opcode/funct3/funct7, extracts `rd/rs1/rs2`, runs SW shift-and-add, returns `mepc+4`.

### 7.2 GDB Quick Ref (Project 2)

| Command | Meaning |
|---|---|
| `print $a0` / `p $a0` | print `a0` decimal |
| `p/x $a0` | print `a0` hex |
| `info registers` | all regs (decimal default) |
| `x/d addr` | memory at addr in decimal |
| `x/x addr` | memory at addr in hex |

==**Bomb Lab pattern**==: infer correct phase inputs from executable/asm; not brute force; not portable across arbitrary RV platforms.
