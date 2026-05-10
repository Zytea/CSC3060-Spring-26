# Lec 3: RISC-V ISA

## Exam Facts

- ==**ISA**==: software-visible contract: instrs, regs, memory model, exceptions, ABI-visible behavior.
- **RISC-V**: open, modular, load/store, mostly fixed 32b instrs; ISA **does not require caches**.
- **ISA name**: `RV{32/64/128}{I/E}{M,A,F,D,C,V}`; base must be `I` or `E`; `RV32EM` valid, `RV32MI` invalid.
- **`RV32E`**: 16 GPRs. **`RV32I`**: 32 GPRs, each 32b, 32b byte-address space.
- **`32` in `RV32I`**: GPR/address width, **not** "32 registers" or "32-bit instructions".
- **Fixed length**: without `C`, RISC-V base instrs are 32b; `C` adds 16b compressed instrs.
- **RV32I architectural state**: **32 GPRs + PC + CSRs**. **RV64IFV** adds FP + vector regs.
- **Microarchitectural state**: pipeline regs, BHT, BTB, caches; regenerated, not saved on interrupt.
- **All-zero 32b word as RV instr**: opcode `0000000` is not valid -> illegal instruction in class quizzes.
- **Scalar RV32I regfile**: **2R/1W**.
- **`JAL` vs `JALR`**: `JAL` PC-relative ~$\pm1$ MiB; `JALR` uses `rs1+imm12`, can reach full RV32 address space via register, clears bit 0.
- **Rejected memory forms**: no `LW rd,(rs1+rs2)` and no post-increment load; they break regularity / add ports / complicate pipeline.
- **No `LWU` in RV32I**: `LW` already fills the 32b GPR; zero/sign extension difference matters only when `XLEN>32` (e.g., RV64).
- **Offsets**: B/J immediates have implicit bit0=0; range is in **2-byte units** because compressed `C` may use 16b instrs.

## 1. Assembly Language Instructions

### 1.1 CISC vs RISC

| | CISC | RISC / RISC-V |
|---|---|---|
| instr length | variable | fixed 32b base, optional 16b C |
| addressing modes | many | few |
| memory ops | many instrs touch memory | only loads/stores |
| pipeline/decode | harder | easier |

$$
CPU\ Time = Instruction\ Count \times CPI \times Clock\ Cycle\ Time
$$

RISC may increase instr count, but often lowers CPI/cycle time.

### 1.2 RISC Design Principles

1. Simplicity favors regularity.
2. Smaller is faster.
3. Make common case fast.
4. Good design demands compromise.

> Judge ISA by compiler/codegen and hardware cost, not by whether one human-written instr looks convenient.

### 1.3 Bases and Extensions

| Part | Meaning |
|---|---|
| `I` | base integer, 32 GPRs |
| `E` | embedded base, 16 GPRs |
| `M` | multiply/divide |
| `A` | atomics |
| `F/D` | single/double FP |
| `C` | compressed 16b instrs |
| `V` | vector |

## 2. RV32I Instructions and Architecture State

### 2.1 RV32I Instruction Set

| Category | Instrs |
|---|---|
| R ALU | `ADD SUB AND OR XOR SLT SLTU SLL SRL SRA` |
| I ALU | `ADDI SLTI SLTIU ANDI ORI XORI SLLI SRLI SRAI` |
| loads | `LB LH LW LBU LHU` |
| stores | `SB SH SW` |
| branches | `BEQ BNE BLT BGE BLTU BGEU` |
| jumps | `JAL JALR` |
| upper imm | `LUI AUIPC` |
| system/CSR | `ECALL EBREAK CSRRW CSRRS CSRRC` |

RV64 adds `LD`, `SD`, `LWU`, `ADDW`, `SLLIW`, etc.

### 2.2 Architectural State

| ISA | State |
|---|---|
| RV32I | `x0-x31`, PC, CSRs |
| RV64IFD | GPRs, PC, CSRs, FP regs |
| RV64IFV | GPRs, PC, CSRs, FP regs, vector regs |

`x0` is hardwired 0: clear, copy, compare, discard result, or memory hint/probe (`lw x0,0(x1)`).

CSR examples: `cycle`, `instret`, `hartid`, `mepc`, `mcause`, `mtvec`, `mstatus`.

==**Hart**==: hardware thread with its own architectural state.

Quiz state-classification anchor:

| State | Class |
|---|---|
| RV32I `x0-x31`, PC | architectural |
| RV64IFV GPRs, PC, FP regs, vector regs | architectural |
| pipeline regs, BHT, BTB, L1I/L1D caches | microarchitectural; regenerated after interrupt |
| overflow/underflow condition-code flags | not part of RV32I class answer |

### 2.3 ABI Snapshot

| ABI | x-reg | Role | Preserved by |
|---|---|---|---|
| `zero` | x0 | constant 0 | fixed |
| `ra` | x1 | return address | caller |
| `sp` | x2 | stack pointer | callee |
| `t0-t6` | x5-x7,x28-x31 | temporaries | caller |
| `s0/fp,s1-s11` | x8-x9,x18-x27 | saved locals | callee |
| `a0-a7` | x10-x17 | args; returns in `a0/a1` | caller |

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

==**Regular field positions**==: `opcode[6:0]`, `rd[11:7]`, `funct3[14:12]`, `rs1[19:15]`, `rs2[24:20]`.

### 3.2 R-Type

`rd = rs1 op rs2`, opcode `0110011`.

| Instr | Key decode |
|---|---|
| `ADD` | `funct3=000`, `funct7=0000000` |
| `SUB` | `funct3=000`, `funct7=0100000` |
| `SRL` | `funct3=101`, `funct7=0000000` |
| `SRA` | `funct3=101`, `funct7=0100000` |

### 3.3 I-Type

`I-imm = signext(inst[31:20])`.

| Class | Meaning |
|---|---|
| I-ALU | `rd = rs1 op imm12` |
| load | `rd = mem[rs1 + imm12]`, offset in bytes |
| `JALR` | `rd=PC+4; PC=(rs1+imm12)&~1` |

Shift I-type: `shamt = imm[4:0]` in RV32; `inst[30]` distinguishes `SRLI/SRAI`.

### 3.4 S-Type

`S-imm = signext({inst[31:25], inst[11:7]})`.

```text
mem[rs1 + S-imm] = rs2
```

Stores: `SB`, `SH`, `SW`.

### 3.5 B-Type

$$
B\text{-imm}=signext(\{inst[31],inst[7],inst[30:25],inst[11:8],0\})
$$

Branch target = `PC + B-imm`; compare `rs1`/`rs2`.

Range: 13-bit signed byte offset with bit0=0 -> about $\pm4$ KiB.

| Branch | Compare |
|---|---|
| `BEQ/BNE` | equal/not |
| `BLT/BGE` | signed |
| `BLTU/BGEU` | unsigned |

> [!IMPORTANT]
> S-type offset is base-relative byte offset. B-type offset is PC-relative with implicit low `0` and **no `rd`**.

Branch offset uses 2B granularity, not 4B, so it remains compatible with 16b compressed instructions.

No `BGT/BLE` needed: swap operands.

```asm
# if x > y  -> y < x
blt  y,x,L
# if x <= y -> y >= x
bge  y,x,L
```

Unsigned bounds check trick: signed negative index becomes huge as unsigned, so `bgeu idx,len,out` catches `idx < 0 || idx >= len`.

### 3.6 U-Type

| Instr | Meaning |
|---|---|
| `LUI rd,imm20` | `rd = imm20 << 12` |
| `AUIPC rd,imm20` | `rd = PC + (imm20 << 12)` |

### 3.7 J-Type and JALR

$$
J\text{-imm}=signext(\{inst[31],inst[19:12],inst[20],inst[30:21],0\})
$$

`JAL`: `rd=PC+4; PC=PC+J-imm`.

Range: 21-bit signed byte offset with bit0=0 -> about $\pm1$ MiB.

`JALR`: I-type, `rd=PC+4; PC=(rs1+imm12)&~1`.

Common forms:

```asm
jal  ra, func       # call
jal  x0, label      # jump
jalr x0, ra, 0      # ret
```

`JAL` is "jump and link" because a call must both jump and save return PC (`PC+4`) in `ra`.

Reach quick facts:

| Mechanism | Reach |
|---|---|
| branch B-type | about `+-4 KiB` |
| `JAL` | about `+-1 MiB` |
| `AUIPC + JALR` | about `+-2 GiB` PC-relative |
| register + `JALR` | full RV32 address space if register holds target |

## 4. Data Alignment and Layout

### 4.1 Natural Alignment

==**Natural alignment**==: object of size N starts at address multiple of N.

| Type LP64 | Size/alignment |
|---|---:|
| `char` | 1 |
| `short` | 2 |
| `int/float` | 4 |
| `long/double/pointer` | 8 |

Why: avoid cache-line/page crossing, double TLB misses/page faults, and complex hardware handling.

### 4.2 Struct Padding Rules

1. Field offset must be multiple of field alignment.
2. Struct size padded to multiple of max alignment.
3. Compiler cannot reorder struct fields, but can reorder independent locals.
4. Reordering fields from large to small often reduces padding.

C row-major array address:

```text
int A[R][C];  &A[i][j] = base + (i*C + j)*4
T A[R][C][D]; &A[i][j][k] = base + ((i*C + j)*D + k)*sizeof(T)
```

### 4.3 Quiz Struct Pattern

```c
struct S1 { int white; long count; char c; long red; int green; char d; int blue; } A[1000];
```

LP64 offsets:

| Field | Offset |
|---|---:|
| `white` | 0 |
| `count` | 8 |
| `c` | 16 |
| `red` | 24 |
| `green` | 32 |
| `d` | 36 |
| `blue` | 40 |
| total | 48 |

`A[10].blue=0`: `10*48+40=520` -> **`sw x0,520(x1)`**.

## 5. Codegen Patterns

Assume unsigned `a` in `a0`, signed `b` in `a1`, signed `c` in `a2`.

| C | RV32I |
|---|---|
| `a*4` | `slli t0,a0,2` |
| `b*61` | `slli t0,a1,6; slli t1,a1,2; sub t0,t0,t1; add t0,t0,a1` |
| `a/8` | `srli t0,a0,3` |
| `b>>3` | `srai t0,a1,3` |
| `b/8` | `bge a1,x0,L; addi a1,a1,7; L: srai t0,a1,3` |
| `a%128` | `andi t0,a0,0x7f` |
| `pow(2,a)` | `addi t0,x0,1; sll t0,t0,a0` |
| `a=(b>=c)` | `slt a0,a1,a2; xori a0,a0,1` |

### 5.1 Software Multiply Without `M`

```asm
xor  a0,a0,a0
loop:
  andi t0,a2,1
  beqz t0,skip
  add  a0,a0,a1
skip:
  slli a1,a1,1
  srli a2,a2,1
  bnez a2,loop
```

### 5.2 Loading Constants

Use pseudo-instruction when allowed:

```asm
li x2,0xAABBCCDD      # assembler expands correctly
```

```asm
# 0x12345678
lui  x1,0x12345
addi x1,x1,0x678

# 0x12345800: low 12b has sign bit
lui  x1,0x12346
addi x1,x1,-0x800
```

`addi` immediate is signed 12b; pseudo `li` handles rounding upper bits.

Common pseudo-instr:

| Pseudo | Typical expansion |
|---|---|
| `mv rd,rs` | `addi rd,rs,0` |
| `j label` | `jal x0,label` |
| `ret` | `jalr x0,ra,0` |
| `jr rs` | `jalr x0,rs,0` |
| `li rd,imm` | `addi` if 12b; otherwise `lui` + adjusted `addi` |

Pop-quiz anchors:

| Question | Answer |
|---|---|
| supported immediate widths | 12b and 20b |
| set `x2=0` | `add x2,x0,x0` or `xor x2,x2,x2` |
| no destination `rd` | branches and stores |
| `RV32I` means | load/store, 3-operand, RISC, 32b GPR/address |

## 6. ISA Design Traps

### 6.1 128 Registers?

No, usually not for base RV64I:

- 5b register fields become 7b -> larger instrs or fewer bits for immediates/opcodes.
- bigger/slower regfile and many more ports.
- more save/restore at calls/context switches.
- arrays/structs/strings still need memory.

### 6.2 FMA and R4

FMA computes `A=B*C+D`. Alternative 3-operand form `rd = rs1*rs2 + rd` supports dot products but makes **`rd` both source and destination**, breaking regularity.

### 6.3 No `LW rd,(rs1+rs2)`

For `A[i]`, address is `base + i*sizeof(element)`, not just `base+i`.

- scaling in load makes addressing complex.
- precomputing scaled index removes instruction-count benefit.
- loops often increment pointer by element size.
- load would need R-type-like 3 regs + memory semantics.

### 6.4 No Post-Increment Load

Rejected behavior:

```text
rd  = mem[rs1+imm]
rs1 = rs1+imm
```

Why: two register writes, `rs1` both source/destination, harder forwarding/hazards/precise exceptions.

### 6.5 Compare-and-Branch vs Condition Codes

RISC-V uses explicit compare-and-branch (`beq/blt/...`), not hidden condition-code flags.

| Compare-and-branch | Condition codes |
|---|---|
| no implicit flag dependence; less architectural state; easier OoO/precise state | can reuse one compare for several branches, but flags create hidden dependencies |

### 6.6 ISA Design Checklist

| Proposal | Class answer |
|---|---|
| 1024 GPRs | no: huge encodings/regfile/context-switch cost |
| fast procedure call single instr | usually no: complex stack/register side effects |
| register pairs for wider data | hurts regularity; use extensions/ABI rules |
| static branch-prediction bit | not worth encoding cost for modern dynamic predictors |

## 7. Exceptions, CSRs, GDB

Trap/interrupt must preserve architectural state; microarchitectural state is regenerated.

Missing extension / illegal instr can trap; a handler may emulate it or terminate the program, depending on OS/runtime.

Trap sketch:

```text
save mepc/mcause/status -> mtvec -> handler saves clobbered GPRs -> mret
```

GDB:

| Command | Meaning |
|---|---|
| `print a0` / `p $a0` | print `a0` decimal |
| `p/x $a0` | print `a0` hex |
| `info registers` | all regs |
| `x/d addr` | memory at address in decimal |

Bomb Lab goal: infer correct phase inputs from executable/assembly without exploding; not brute force and not portable to arbitrary RISC-V platforms.
