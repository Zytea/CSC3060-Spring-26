# Lec 3: RISC-V ISA

## Exam Facts

- ==**ISA**==: software-visible contract: instructions, regs, memory model, exceptions, ABI-visible behavior. Computer architecture = SW/HW interface.
- ==**RISC-V**==: open, modular, **load/store**, mostly **fixed 32b** instructions; ISA does **not** require caches.
- **Modular naming**: `RV{32/64/128}{I/E}{M,A,F,D,C,V,...}`; **base must be `I` or `E`**; `RV32EM` ✓, `RV32IM` ✓; `RV32MI`/`RV32ME` ✗.
- **`RV32E`**: embedded base, **16 GPRs**. **`RV32I`**: **32 GPRs `x0-x31`**, each 32b, 32b address space (4 GiB).
- ==**"32" in RV32I**== = **GPR/address width** (4 GiB addressable). NOT "32 registers"; NOT "32-bit instruction length"; NOT "32 instructions".
- **Fixed length**: without `C`, all RV base instrs are **32b**; **`C` extension** adds 16b compressed instrs and is the *only* extension that breaks fixed length.
- ==**RV32I architectural state**==: **32 GPRs `x0-x31` + PC + CSRs**. **RV64IFD**: + FP regs. **RV64IFV**: + FP + vector regs.
- **Microarchitectural state** (regenerable, NOT saved on interrupt): pipeline regs, BHT, BTB, L1I/L1D caches.
- **All-zero 32b word** as RV instr → opcode `0000000` is **not allocated** → **illegal instruction** (traps).
- **`0x00000033`** = RV32I `add x0,x0,x0` (no architectural effect); also int `51`, ASCII `'3'`+NULs.
- **Scalar RV32I regfile**: ==**2R / 1W**==. **2-issue scalar**: ~4R/2W. **2-issue FMA FP**: 6R/2W.
- **Set `x2 = 0`**: `add x2,x0,x0` ✓ ; `xor x2,x2,x2` ✓; `addi x2,x2,0` keeps old value ✗; `or x2,x2,x2` keeps old ✗.
- **No `rd` field**: ==**branches and stores**== (B/S types).
- ==**Reach**==: branch B-type ≈ ±4 KiB; `JAL` ≈ ±1 MiB; `AUIPC+JALR` ≈ ±2 GiB PC-rel; reg+`JALR` = full 4 GiB address space.
- **Return idiom**: `jalr x0, ra, 0` (= `ret`); class quizzes infer this as procedure return.
- **B/J immediates** have implicit `bit0=0`; offset in **2-byte units** (compatible with `C` ext 16b instrs).
- **Rejected memory forms**: no `LW rd, (rs1+rs2)` (no scaled index); no post-increment load. Reasons: regularity break, extra reg ports, harder hazards/precise exceptions.
- **No `LWU` in RV32I**: `LW` already fills all 32b of a GPR; zero/sign-ext only matters when `XLEN > 32` (RV64).
- **RV64I-only**: `LD`, `SD`, `LWU`, `ADDW`, `SLLW`, `SLLIW`, `SRAIW`, `SRLIW`, `SUBW`. **Not** valid RV32I base instrs.
- **`SLLI/SRLI/SRAI` in RV32**: `shamt = imm[4:0]` (5 bits). `SLLI X5,X6,35` ✗ in RV32 (>31).
- **Imm widths supported in RV32I**: **12-bit** (I/S/B; B's bit0 implicit) and **20-bit** (U/J; J's bit0 implicit). To load 32b const: pseudo-`li` or `lui+addi`; need adjustment if low 12b has high bit set.
- ==**ABI**==: ISA + OS + calling convention. Defines arg/return regs, caller/callee-save split, stack/frame conventions; **NOT** variable names or "legal C data types".
- ==**Hart**==: hardware thread with own architectural state (PC, GPRs, CSRs); a multicore chip can host multiple harts.
- **`x0` always 0**: clear, copy (`add rd,x0,rs`), compare (`beq rs,x0,L`), discard result, mem hint (`lw x0,0(rs)`).
- **No `BLE`/`BGT`**: regularity — swap operands of `BLT`/`BGE`.
- **Bounds-check trick**: `bgeu idx, len, out` catches both `idx<0` (huge unsigned) and `idx≥len` in one instr.
- **Natural alignment**: object size N at addr multiple of N. Avoids cache-line / page crossing → no double-miss / double-fault / extra HW.
- **RISC-V Linux ABI stack alignment**: ==**16 bytes**==.
- **Struct rules**: field offset = mult of field align; total size padded to mult of max field align; **fields cannot be reordered** (locals can).
- **R4-type FMA**: `rd = rs1*rs2 + rs3` — only R4 instr in RV ISA. Could be redesigned with 3 ops as `rd = rs1*rs2 + rd` (rd as src+dst), but **breaks regularity**.

## 1. Assembly Language Instructions

### 1.1 CISC vs RISC

| | CISC | RISC / RISC-V |
|---|---|---|
| instr length | variable | fixed 32b base, optional 16b `C` |
| addressing modes | many | few (load/store only) |
| memory ops | many instrs touch memory | only `LW/SW`-class |
| pipeline / decode | harder | easier |
| examples | x86 (1978), VAX, IBM 360 | **RISC-V (2010)**, MIPS, SPARC, ARM (1985), PowerPC |

==**Iron Law**==:

$$
CPU\ Time = Instruction\ Count \times CPI \times Clock\ Cycle\ Time
$$

| Lever | Mainly improves |
|---|---|
| RISC simplicity | CPI / cycle time (often raises IC) |
| CISC compactness | IC (often raises CPI / cycle time) |
| SIMD/vector/RVV | **IC** (many elements per instr) |
| pipeline | **cycle time** (overlapped stages) |
| superscalar / OoO / pred / cache | **CPI** |

Modern x86: variable-length CISC at ISA level, but decoders translate into RISC-style μops internally.

### 1.2 RISC Design Principles

1. ==**Simplicity favors regularity**== — fixed-size instrs, regular field positions, opcode in fixed bits.
2. ==**Smaller is faster**== — limited instr set, regs, addressing modes.
3. ==**Make the common case fast**== — operands from regs (load/store), allow imm.
4. ==**Good design demands compromise**== — balance instr formats vs operand count.

> Judge an ISA by **compiler/codegen quality + HW cost**, not by whether one human-written instr looks convenient.

### 1.3 Bases and Extensions

| Part | Meaning |
|---|---|
| **`I`** | base integer, 32 GPRs |
| **`E`** | embedded base, 16 GPRs |
| `M` | integer multiply/divide |
| `A` | atomic memory ops |
| `F` / `D` | single / double FP |
| **`C`** | **compressed 16b instrs** (the *only* ext that breaks fixed-length 32b) |
| `V` | vector |

## 2. RV32I Instructions and Architecture State

### 2.1 RV32I Instruction Set (Base, no `M`)

| Category | Instrs |
|---|---|
| R ALU | `ADD SUB AND OR XOR SLT SLTU SLL SRL SRA` |
| I ALU | `ADDI SLTI SLTIU ANDI ORI XORI SLLI SRLI SRAI` |
| Loads | `LB LH LW LBU LHU` |
| Stores | `SB SH SW` |
| Branches | `BEQ BNE BLT BGE BLTU BGEU` |
| Jumps | `JAL JALR` |
| Upper imm | `LUI AUIPC` |
| System / CSR | `ECALL EBREAK CSRRW CSRRS CSRRC` |

> RV32IM = RV32I + `M`. Running `mul` on plain RV32I → **illegal-instr exception**; handler may abort or **emulate** in SW.

### 2.2 Architectural State

| ISA | State |
|---|---|
| **RV32I** | `x0-x31`, **PC**, CSRs |
| **RV64IFD** | + 32 FP regs |
| **RV64IFV** | + 32 vector regs |

- `x0` hardwired to 0: clear, copy, compare, discard, memory hint (`lw x0,0(x1)` to test access).
- CSRs: `cycle`, `instret`, `hartid`, `mepc`, `mcause`, `mtvec`, `mstatus`.
- ==**Hart**==: HW thread with own arch state.

==**Architectural vs Microarchitectural state**==:

| State | Class | Save on interrupt? |
|---|---|---|
| `x0-x31`, PC, CSRs (RV32I) | architectural | yes |
| FP / vector regs (when ISA includes them) | architectural | yes |
| BHT, BTB, pipeline regs, L1I/L1D | **microarchitectural** | **no** (regenerable) |
| Overflow/underflow flags | **not** in RV32I (no condition codes) | n/a |

### 2.3 ABI Snapshot

| x-reg | ABI | Role | Saver |
|---|---|---|---|
| `x0` | `zero` | hardwired 0 | — |
| `x1` | `ra` | return address | **caller** |
| `x2` | `sp` | stack pointer (16B aligned) | **callee** |
| `x3` | `gp` | global pointer | platform |
| `x4` | `tp` | thread pointer | platform |
| `x5-x7` | `t0-t2` | temps | caller |
| `x8` | `s0/fp` | saved / frame ptr | callee |
| `x9` | `s1` | saved | callee |
| `x10-x17` | `a0-a7` | args; `a0/a1` returns | caller |
| `x18-x27` | `s2-s11` | saved | callee |
| `x28-x31` | `t3-t6` | temps | caller |

## 3. Instruction Encoding Formats

### 3.1 Format Overview (32b, opcode in `[6:0]`)

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

==**Regular field positions**== (regularity → start regfile read before full decode):

| Field | Bits |
|---|---|
| `opcode` | `[6:0]` |
| `rd` | `[11:7]` |
| `funct3` | `[14:12]` |
| `rs1` | `[19:15]` |
| `rs2` | `[24:20]` |

### 3.2 R-Type

`rd = rs1 op rs2`, opcode `0110011`.

| Instr | `funct3` | `funct7` |
|---|---|---|
| `ADD` | `000` | `0000000` |
| `SUB` | `000` | **`0100000`** |
| `SLL` | `001` | `0000000` |
| `SLT` | `010` | `0000000` |
| `SLTU` | `011` | `0000000` |
| `XOR` | `100` | `0000000` |
| `SRL` | `101` | `0000000` |
| `SRA` | `101` | **`0100000`** |
| `OR` | `110` | `0000000` |
| `AND` | `111` | `0000000` |

> Quiz: `funct7[5]` distinguishes `ADD/SUB` and `SRL/SRA`; rest of `funct7` is 0 → trap inputs to ALU control.

### 3.3 I-Type

`I-imm = signext(inst[31:20])` (12b signed, range `-2048..+2047`).

| Class | Behavior | Opcode |
|---|---|---|
| I-ALU | `rd = rs1 op imm12` | `0010011` |
| Load | `rd = mem[rs1 + imm12]` (offset in **bytes**) | `0000011` |
| `JALR` | `rd=PC+4; PC=(rs1+imm12) & ~1` | `1100111` |

==**Shift I-type**== (`SLLI/SRLI/SRAI`): `shamt = imm[4:0]` (RV32) / `imm[5:0]` (RV64); `inst[30]` distinguishes `SRLI` (0) vs `SRAI` (1).

> Trap: `SLLI X5,X6,35` is **invalid in RV32I** (shamt > 31).

==**Loads**==:

| Instr | Load | Sign-ext? |
|---|---|---|
| `LB` | byte | sign |
| `LH` | half | sign |
| `LW` | word | n/a (fills 32b GPR) |
| `LBU` | byte | zero |
| `LHU` | half | zero |

> No `LWU` in RV32I — `LW` already fills the GPR. Only matters in RV64I (where `LWU` zero-extends to 64b).

### 3.4 S-Type (Stores)

`S-imm = signext({inst[31:25], inst[11:7]})` — 12b signed split.

```text
mem[rs1 + S-imm] = rs2
```

- `SB / SH / SW`. **No `rd` field** (overwritten by `imm[4:0]`).

### 3.5 B-Type (Branches)

$$
B\text{-imm} = signext(\{inst[31], inst[7], inst[30:25], inst[11:8], 0\})
$$

- 13-bit signed byte offset with **implicit bit0=0** → reach ≈ **±4 KiB**.
- No `rd`. Compare `rs1` and `rs2`; PC = taken ? PC+B-imm : PC+4.

| Branch | Compare |
|---|---|
| `BEQ / BNE` | equal / not equal |
| `BLT / BGE` | **signed** < / ≥ |
| `BLTU / BGEU` | **unsigned** < / ≥ |

> [!IMPORTANT]
> S-type imm is **base-relative byte offset** (rs1+imm). B-type imm is **PC-relative** with implicit low `0`, has **no `rd`**, and offset is in **2-byte units** (so `C` ext compressed 16b instrs are reachable).

==**No `BGT/BLE`**==: regularity. Swap operands:

```asm
# if x > y → y < x
blt y, x, L
# if x ≤ y → y ≥ x
bge y, x, L
```

==**Bounds check trick**== (single instr catches both negative and over):

```asm
# int A[len], idx in x5, len in x6
bgeu x5, x6, out_of_bounds   # signed-neg becomes huge unsigned, also catches idx ≥ len
```

### 3.6 U-Type (`LUI`, `AUIPC`)

| Instr | Behavior |
|---|---|
| `LUI rd, imm20` | `rd = imm20 << 12` (load upper imm) |
| `AUIPC rd, imm20` | `rd = PC + (imm20 << 12)` (PC-rel base) |

### 3.7 J-Type and JALR

$$
J\text{-imm} = signext(\{inst[31], inst[19:12], inst[20], inst[30:21], 0\})
$$

- `JAL rd, imm`: `rd = PC+4; PC = PC + J-imm`. Reach ≈ **±1 MiB** (21b signed, bit0=0).
- `JALR rd, rs1, imm`: I-type, `rd = PC+4; PC = (rs1+imm12) & ~1`. Reach: full 32b address space via reg.

==**Common forms**==:

```asm
jal  ra, func        # call (saves return PC in ra)
jal  x0, label       # plain jump (rd=0 discards link)
jalr x0, ra, 0       # ret (return)
jalr ra, rs1, 0      # indirect call (function pointer)
```

> "Jump and Link" naming: a *call* must both jump AND save return PC; rd=`x0` repurposes for plain jump (no separate JUMP needed → simpler ISA).

==**Reach quick facts**==:

| Mechanism | Reach |
|---|---|
| Branch B-type | ≈ ±4 KiB |
| `JAL` | ≈ ±1 MiB |
| `AUIPC + JALR` | ≈ ±2 GiB PC-rel |
| reg-based `JALR` | full 4 GiB address space |

> Quiz Q5 (Sec II): "Jump instrs can be used for function calls" ✓ (rd=ra). "JALR has larger jump range than JAL" ✓ (full 32b vs ±1 MiB). "Jump instrs are UJ type" — only `JAL` is J-type; `JALR` is **I-type**.

### 3.8 S-type vs B-type Imm Encoding (Why Different?)

S-type imm = `{inst[31:25] | inst[11:7]}` (low 12b, contig).
B-type imm = `{inst[31] | inst[7] | inst[30:25] | inst[11:8] | 0}` (rearranged, bit0=0 implicit).

The **rearrangement keeps `funct3, rs1, rs2` in fixed positions** so decode + regfile read are the same. Trade: imm bits scattered, but HW just reroutes wires (no extra cost).

Same idea: U-type vs J-type both 20b, but J reorders bits to keep regularity.

## 4. Data Alignment and Layout

### 4.1 Natural Alignment

==**Natural alignment**==: object of size N starts at addr multiple of N.

| Type LP64 | Size = Align |
|---|---:|
| `char` | 1 |
| `short` | 2 |
| `int` / `float` | 4 |
| `long` / `double` / pointer | 8 |

==**Why required**==:
- avoid **cache-line crossing** (would need 2 accesses).
- avoid **double TLB miss / double page fault** from 1 mem instr.
- HW simpler (no misaligned-fixup logic).
- better cache-line utilization.

> Cache lines: typically 64 B (also 32, 128). Pages: 4 KiB+.

### 4.2 Struct Padding Rules

1. **Field offset** = multiple of field's align.
2. **Total struct size** = multiple of **max field align** (trailing pad).
3. **Compiler cannot reorder struct fields** (C standard guarantees order); **independent locals can** be reordered.
4. **Reordering large→small** often shrinks padding.

C row-major array address:

```text
int A[R][C];      &A[i][j]    = base + (i*C + j) * 4
T   A[R][C][D];   &A[i][j][k] = base + ((i*C + j)*D + k) * sizeof(T)
```

### 4.3 Worked Struct Quiz Pattern

```c
struct S1 { int white; long count; char c; long red; int green; char d; int blue; }
A[1000];
```

LP64 layout (`char=1, int=4, long=8`):

| Field | Offset | Size | Pad after |
|---|---:|---:|---:|
| `white` | 0 | 4 | 4 |
| `count` | 8 | 8 | 0 |
| `c` | 16 | 1 | 7 |
| `red` | 24 | 8 | 0 |
| `green` | 32 | 4 | 0 |
| `d` | 36 | 1 | 3 |
| `blue` | 40 | 4 | **4 trailing** |

**Total size = 48 B** (multiple of 8 = max align).

==**`A[10].blue = 0` on RV64IFD**==:
- offset = `10 * 48 + 40 = 520`
- assume `&A[0]` in `x1` → ==**`sw x0, 520(x1)`**==.

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
| `b * c` (no `M`) | shift-and-add loop (see 5.1) | software emulation |

### 5.1 Software Multiply Without `M`

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

### 5.2 Loading 32-bit Constants

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
# result: 0x12346 << 12 + 0xFFFFF800 = 0x12345800 ✓
```

> Why adjust: `addi` imm is **signed 12b**. If low 12b ≥ 0x800, it sign-extends negative; `lui` upper must be incremented to compensate.

==**Common pseudo-instr expansions**==:

| Pseudo | Expansion |
|---|---|
| `mv rd, rs` | `addi rd, rs, 0` |
| `j label` | `jal x0, label` |
| `ret` | `jalr x0, ra, 0` |
| `jr rs` | `jalr x0, rs, 0` |
| `call label` | `auipc ra, hi20; jalr ra, lo12(ra)` (far call) |
| `li rd, imm` | `addi` if 12b; else `lui+addi` (adjust if low12 sign bit) |
| `bgt rs,rt,L` | `blt rt,rs,L` |
| `ble rs,rt,L` | `bge rt,rs,L` |
| `nop` | `addi x0,x0,0` |
| `not rd,rs` | `xori rd,rs,-1` |
| `neg rd,rs` | `sub rd,x0,rs` |

==**Pop-quiz anchors**==:

| Question | Answer |
|---|---|
| imm widths in RV32I | **12b** (I/S/B with implicit bit0=0) and **20b** (U/J with implicit bit0=0 for J) |
| set `x2 = 0` | `add x2,x0,x0` ✓; `xor x2,x2,x2` ✓; `addi x2,x2,0`/`or x2,x2,x2` ✗ (keeps old) |
| no `rd` | branches, stores |
| RV32I means | load/store, 3-operand, RISC, 32b GPR/address |
| return | `jalr x0, ra, 0` |
| direct call | `jal ra, offset` |

### 5.3 C-to-RV Translation Examples

```c
int x = A[i];     // A is int[]
```
```asm
slli t0, i, 2       # t0 = i * 4
add  t0, t0, base   # t0 = &A[0] + i*4
lw   x, 0(t0)
```

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

CSRs:

| CSR | Use |
|---|---|
| `mepc` | exception PC (return target) |
| `mcause` | cause code |
| `mtvec` | trap vector base |
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

==**Bomb Lab pattern**==: infer correct phase inputs from executable/assembly; not brute force; not portable across arbitrary RV platforms.
