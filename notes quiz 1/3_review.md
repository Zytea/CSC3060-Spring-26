# Lec 3: RISC-V ISA

## Exam Facts

- ==**ISA**==: programmer/compiler visible contract between software and hardware: instrs, regs, memory model, exceptions, ABI-visible behavior.
- RISC-V is open, modular, load/store, mostly fixed 32b instrs; the ISA does **not** require a cache hierarchy.
- ISA name: `RV{32/64/128}{I/E}{M,A,F,D,C,V}`. Base must be `I` or `E`: `RV32EM` valid, `RV32MI` invalid.
- ==**RV32E**==: 16 GPRs. ==**RV32I**==: 32 GPRs, each 32b, 32b address space.
- C extension absent -> only 32b instrs. With C extension -> also 16b instrs; this explains B/J low-bit encoding.
- RV32I arch state: **32 GPRs + PC + CSRs**. RV64IFD adds FP regs; RV64IFV adds vector regs.
- Microarch state: pipeline regs, BHT, BTB, caches; **not saved on interrupt** because it can be regenerated.
- ABI = ISA + OS syscall interface + calling convention.
- Branch target = `PC + B-imm`; B-imm is split and has implicit low 0. Do **not** read it as a plain 12b value times 2.
- `JAL`: PC-relative, split J-imm, about `+-1 MiB`. `JALR`: I-type, `rs1+imm`, clears target bit 0.
- No `LW rd,(rs1+rs2)`: address computation stays in ALU instrs; loads use base+signed-12b-byte-offset.
- No post-increment load: would need two register writes and makes `rs1` both source and destination.

## 1. Assembly Language Instructions

### 1.1 CISC vs RISC

| | CISC | RISC / RISC-V |
|---|---|---|
| Instr length | variable | mostly fixed 32b, optional 16b C |
| Addressing modes | many | few |
| Memory operands | many instrs can access memory | only loads/stores access memory |
| Decode/pipeline | harder | easier |

==**CPU time = instruction count x CPI x clock cycle time**==. RISC may increase instruction count, but simpler decode/control can lower CPI and clock cycle time.

### 1.2 RISC Design Principles

1. Simplicity favors regularity.
2. Smaller is faster.
3. Make common case fast.
4. Good design demands compromise.

Instruction sets are judged by how well **compilers** use them, not by how convenient they look to humans.

### 1.3 RISC-V Bases and Extensions

| Part | Meaning |
|---|---|
| `I` | base integer ISA, 32 GPRs |
| `E` | embedded base, 16 GPRs |
| `M` | multiply/divide |
| `A` | atomic memory instrs |
| `C` | compressed 16b instrs |
| `F/D` | single/double FP |
| `V` | vector |

## 2. RV32I Instructions and Architecture State

### 2.1 RV32I Instruction Set

| Category | Instrs |
|---|---|
| R ALU | `ADD SUB AND OR XOR SLT SLTU SLL SRL SRA` |
| I ALU | `ADDI SLTI SLTIU ANDI ORI XORI SLLI SRLI SRAI` |
| Loads | `LB LH LW LBU LHU`; RV64 adds `LD LWU` |
| Stores | `SB SH SW` |
| Branches | `BEQ BNE BLT BGE BLTU BGEU` |
| Jumps | `JAL JALR` |
| Upper imm | `LUI AUIPC` |
| System/CSR | `ECALL EBREAK CSRRW CSRRS CSRRC` |

> No `BLE/BGT`: swap operands with `BLT/BGE`. Bounds check `0 <= x < y` can use unsigned compare: `bgeu x,y,out`.

### 2.2 Architectural State

==**Architecture state**==: architecturally visible info needed to resume a program exactly.

| ISA | Visible state |
|---|---|
| RV32I | 32 GPRs + PC + CSRs |
| RV64IFD | GPRs + PC + CSRs + 32 FP regs |
| RV64IFV | GPRs + PC + CSRs + FP regs + vector regs |

`x0` is hardwired 0:

- clear: `add x2,x0,x0`, `xor x2,x2,x2`
- copy: `add x1,x0,x2`
- compare to 0: `beq x5,x0,L`
- discard load result / memory hint: `lw x0,0(x1)`

CSR examples: `cycle`, `instret`, `mepc`, `mcause`, `mtvec`, `mstatus`, `mhartid`.

==**Hart**==: hardware thread with its own PC/GPR/CSR context. A core may have multiple harts.

### 2.3 Register File Ports

| Design | Typical regfile ports |
|---|---|
| scalar RV32I | **2R/1W** |
| 2-issue integer | about **4R/2W** |
| 2-issue RV64IFD with FMA | **6R/2W** FP regfile: two FMAs need 6 FP sources and 2 dests |

## 3. Instruction Encoding Formats

### 3.0 Overview

| Function class | Format | Instrs |
|---|---|---|
| reg-reg ALU | R-type | `ADD SUB AND OR XOR SLT SLTU SLL SRL SRA` |
| imm ALU | I-type | `ADDI ANDI ORI XORI SLTI SLTIU SLLI SRLI SRAI` |
| load | I-type | `LB LH LW LBU LHU` |
| store | S-type | `SB SH SW` |
| conditional branch | B-type | `BEQ BNE BLT BGE BLTU BGEU` |
| jump | J/I-type | `JAL`, `JALR` |
| upper immediate | U-type | `LUI AUIPC` |

| Format | Operands | Size | Key feature |
|---|---|---:|---|
| R-type | 3 regs | 32b | no immediate |
| I-type | 2 regs + 12b imm | 32b | signed 12b immediate |
| S-type | 2 regs + 12b imm | 32b | no `rd`; store data comes from `rs2` |
| B-type | 2 regs + split branch imm | 32b | no `rd`; PC-relative |
| U-type | 1 reg + 20b imm | 32b | imm occupies bits 31:12 |
| J-type | 1 reg + split jump imm | 32b | PC-relative link jump |

![](assets/3.3.1.png)

==Regular field positions==: `opcode[6:0]`, `rd[11:7]`, `funct3[14:12]`, `rs1[19:15]`, `rs2[24:20]` stay fixed whenever the field exists.

### 3.1 R-Type: Register-to-Register ALU

![](assets/3.3.1.1.png)

| Bits | Width | Field | Meaning |
|---|---:|---|---|
| `[31:25]` | 7 | `funct7` | secondary opcode |
| `[24:20]` | 5 | `rs2` | source 2 |
| `[19:15]` | 5 | `rs1` | source 1 |
| `[14:12]` | 3 | `funct3` | ALU operation class |
| `[11:7]` | 5 | `rd` | destination |
| `[6:0]` | 7 | `opcode` | major opcode `0110011` |

Instruction meaning: `rd = rs1 op rs2`.

| Instr | `funct7` | `rs2` | `rs1` | `funct3` | `rd` | `opcode` | Example |
|---|---|---|---|---|---|---|---|
| `ADD` | `0000000` | `00011` | `00010` | `000` | `00001` | `0110011` | `add x1,x2,x3` |
| `SUB` | `0100000` | `00011` | `00010` | `000` | `00001` | `0110011` | `sub x1,x2,x3` |

Key decode:

- `funct3=000`, `funct7=0000000` -> `ADD`
- `funct3=000`, `funct7=0100000` -> `SUB`
- `funct3=101`, `funct7=0000000` -> `SRL`
- `funct3=101`, `funct7=0100000` -> `SRA`

### 3.2 I-Type: Immediate ALU, Loads, JALR

![](assets/3.3.2.png)

| Bits | Width | Field | Meaning |
|---|---:|---|---|
| `[31:20]` | 12 | `imm[11:0]` | signed immediate |
| `[19:15]` | 5 | `rs1` | source/base register |
| `[14:12]` | 3 | `funct3` | operation/width |
| `[11:7]` | 5 | `rd` | destination |
| `[6:0]` | 7 | `opcode` | `0010011` ALU, `0000011` load, `1100111` JALR |

Immediate: `I-imm = signext(inst[31:20])`.

| Instr | `imm[11:0]` | `rs1` | `funct3` | `rd` | `opcode` | Example |
|---|---|---|---|---|---|---|
| `ADDI` | `010000000000` | `00010` | `000` | `00001` | `0010011` | `addi x1,x2,1024` |
| `LW` | `001111101000` | `00010` | `010` | `00001` | `0000011` | `lw x1,1000(x2)` |

#### 3.2.1 I-Type ALU

Meaning: `rd = rs1 op signext(imm12)`.

| Instr | `funct3` | Note |
|---|---|---|
| `ADDI` | `000` | add signed imm |
| `SLTI` | `010` | signed less-than |
| `SLTIU` | `011` | unsigned less-than |
| `XORI` | `100` | `xori rd,rs1,-1` = bitwise NOT |
| `ORI` | `110` | bitwise OR |
| `ANDI` | `111` | bitwise AND |

#### 3.2.2 Shift I-Type Variant

Meaning: `rd = rs1 shift shamt`. `shamt` is 5b in RV32, 6b in RV64.

| Instr | `funct3` | top bits | Meaning |
|---|---|---|---|
| `SLLI` | `001` | `0000000` | logical left |
| `SRLI` | `101` | `0000000` | logical right |
| `SRAI` | `101` | `0100000` | arithmetic right |

For RV32 shifts, only `imm[4:0]` is the shift amount; `inst[30]` distinguishes `SRLI` vs `SRAI`.

#### 3.2.3 Load I-Type

![](assets/3.3.2.2.png)

Meaning: `rd = mem[rs1 + signext(imm12)]`; offset is **bytes**, not elements.

| Load | `funct3` | Meaning |
|---|---|---|
| `LB` | `000` | signed byte |
| `LH` | `001` | signed halfword |
| `LW` | `010` | signed word |
| `LBU` | `100` | unsigned byte |
| `LHU` | `101` | unsigned halfword |
| `LWU` | `110` | RV64 only; zero-extend 32b word |
| `LD` | `011` | RV64 only; 64b |

> [!IMPORTANT]
> No `LWU` in RV32I: loading an unsigned 32b word into a 32b GPR is the same bit pattern as `LW`; `LWU` matters in RV64 because it zero-extends to 64b.

![](assets/3.3.2.3.png)

### 3.3 S-Type: Stores

![](assets/3.3.3.png)

| Bits | Width | Field | Meaning |
|---|---:|---|---|
| `[31:25]` | 7 | `imm[11:5]` | high imm bits |
| `[24:20]` | 5 | `rs2` | data to store |
| `[19:15]` | 5 | `rs1` | base address |
| `[14:12]` | 3 | `funct3` | store width |
| `[11:7]` | 5 | `imm[4:0]` | low imm bits |
| `[6:0]` | 7 | `opcode` | `0100011` |

Meaning: `mem[rs1 + signext(S-imm)] = rs2`.

`S-imm = signext({inst[31:25], inst[11:7]})`.

| Store | `funct3` | Example |
|---|---|---|
| `SB` | `000` | `sb x1,1000(x2)` |
| `SH` | `001` | `sh x1,1000(x2)` |
| `SW` | `010` | `sw x1,1000(x2)` |

Example `sw x1,1000(x2)`:

| `imm[11:5]` | `rs2` | `rs1` | `funct3` | `imm[4:0]` | `opcode` |
|---|---|---|---|---|---|
| `0011111` | `00001` | `00010` | `010` | `01000` | `0100011` |

### 3.4 B-Type: Conditional Branches

Branch instrs compare two regs and choose fall-through `PC+4` or target `PC + B-imm`.

| Bits | Width | Field |
|---|---:|---|
| `[31]` | 1 | `imm[12]` |
| `[30:25]` | 6 | `imm[10:5]` |
| `[24:20]` | 5 | `rs2` |
| `[19:15]` | 5 | `rs1` |
| `[14:12]` | 3 | `funct3` |
| `[11:8]` | 4 | `imm[4:1]` |
| `[7]` | 1 | `imm[11]` |
| `[6:0]` | 7 | `opcode=1100011` |

$$
B\text{-imm} = \text{signext}(\{inst[31],inst[7],inst[30:25],inst[11:8],0\})
$$

| Branch | `funct3` | Condition |
|---|---|---|
| `BEQ` | `000` | `rs1 == rs2` |
| `BNE` | `001` | `rs1 != rs2` |
| `BLT` | `100` | signed `<` |
| `BGE` | `101` | signed `>=` |
| `BLTU` | `110` | unsigned `<` |
| `BGEU` | `111` | unsigned `>=` |

> [!IMPORTANT]
> Store offset is `rs1 + byte_offset`; branch offset is **PC-relative**. B-type has no `rd`, and its immediate bits are arranged differently from S-type.

### 3.5 U-Type: LUI and AUIPC

| Bits | Width | Field | Meaning |
|---|---:|---|---|
| `[31:12]` | 20 | `imm[31:12]` | upper immediate |
| `[11:7]` | 5 | `rd` | destination |
| `[6:0]` | 7 | `opcode` | `0110111` LUI, `0010111` AUIPC |

| Instr | Meaning |
|---|---|
| `LUI rd,imm20` | `rd = imm20 << 12` |
| `AUIPC rd,imm20` | `rd = PC + (imm20 << 12)` |

`AUIPC+JALR` supports far PC-relative calls/jumps beyond `JAL` range.

### 3.6 J-Type: JAL

| Bits | Width | Field |
|---|---:|---|
| `[31]` | 1 | `imm[20]` |
| `[30:21]` | 10 | `imm[10:1]` |
| `[20]` | 1 | `imm[11]` |
| `[19:12]` | 8 | `imm[19:12]` |
| `[11:7]` | 5 | `rd` |
| `[6:0]` | 7 | `opcode=1101111` |

$$
J\text{-imm} = \text{signext}(\{inst[31],inst[19:12],inst[20],inst[30:21],0\})
$$

Meaning: `rd = PC+4; PC = PC + J-imm`.

Common forms:

```asm
jal x1, func      # call, ra=x1
jal x0, label     # unconditional jump, pseudo: j label
```

> `JAL` still has `rd`; ignoring the link uses `rd=x0`. A separate non-link jump could have more range, but would add another format.

### 3.7 JALR: I-Type Indirect Jump

![](assets/3.3.6.png)

Meaning:

```asm
rd = PC + 4
PC = (rs1 + signext(imm12)) & ~1
```

Common forms:

```asm
jalr x0, rs1, imm     # indirect jump
jalr x1, rs1, imm     # indirect call
jalr x0, x1, 0        # return, pseudo: ret
```

`JALR` uses I-type format. Hardware often uses a return address stack (RAS): calls push return address; returns pop. Return prediction can fail if `x1/ra` is used for non-return indirect jumps.

### 3.8 Immediate Encoding Differences

![](assets/3.8.png)

#### 3.8.1 S-Type vs B-Type

![](assets/3.8.1.png)

| Type | Inst bits | Immediate value |
|---|---|---|
| S | `[31:25] [11:7]` | `signext({inst[31:25],inst[11:7]})` |
| B | `[31] [7] [30:25] [11:8]` | `signext({inst[31],inst[7],inst[30:25],inst[11:8],0})` |

B-type reuses S-type bit positions so `rs1/rs2/funct3/opcode` remain fixed, but rearranges immediate bits to encode halfword-aligned PC-relative targets.

#### 3.8.2 U-Type vs J-Type

![](assets/3.8.2.png)

| Type | Inst bits | Immediate value |
|---|---|---|
| U | `[31:12]` | `inst[31:12] << 12` |
| J | `[31] [19:12] [20] [30:21]` | `signext({inst[31],inst[19:12],inst[20],inst[30:21],0})` |

> [!IMPORTANT]
> Do not write "20b imm x2" without the actual bit order. J-type has 20 encoded imm bits, an implicit low 0, and scrambled bit positions.

## 4. Data Alignment and Memory Operands

### 4.1 Natural Alignment

==**Natural alignment**==: an object of size N is stored at an address divisible by N.

| Type | Size/alignment under LP64 |
|---|---:|
| `char` | 1 |
| `short` | 2 |
| `int` / `float` | 4 |
| `long` / `long long` / `double` / pointer | 8 |

Benefits:

- no cache-line crossing for a single aligned access.
- no double TLB lookup/page fault for one access.
- simpler hardware and faster common case.

### 4.2 Struct Padding Rules

1. Each field starts at an offset that is a multiple of its own alignment.
2. Struct size is padded to a multiple of the largest field alignment.
3. C compiler may reorder independent locals, but **cannot reorder struct fields**.

Example:

```c
struct S { int a; long long b; char c; double d; };
```

| Field | Offset | Reason |
|---|---:|---|
| `a` | 0 | 4B |
| pad | 4 | align `b` to 8 |
| `b` | 8 | 8B |
| `c` | 16 | 1B |
| pad | 17-23 | align `d` to 8 |
| `d` | 24 | 8B |
| total | 32 | multiple of 8 |

### 4.3 Quiz Struct Example

```c
struct S1 { int white; long count; char c; long red; int green; char d; int blue; } A[1000];
```

RV64IFD / LP64:

| Field | Offset | Note |
|---|---:|---|
| `white` | 0 | 4B, then pad to 8 |
| `count` | 8 | 8B |
| `c` | 16 | 1B, then pad to 24 |
| `red` | 24 | 8B |
| `green` | 32 | 4B |
| `d` | 36 | 1B, then pad to 40 |
| `blue` | 40 | 4B |
| total | 48 | multiple of 8 |

`A[10].blue = 0`: offset `10*48 + 40 = 520` -> ==**`sw x0,520(x1)`**==.

### 4.4 Memory Operand Exercises

| Access | Calculation | Instr |
|---|---|---|
| `int A[8]`, base `x1`, load `A[8]` | `8*4=32` | `lw x2,32(x1)` |
| `long A[100]`, base `x1`, load `A[100]` | `100*8=800` | `ld x2,800(x1)` |
| `struct {int green; int red; int blue;} A[100].red` | `100*12+4=1204` | `lw x2,1204(x1)` |
| `{int white; long count; char c; int red; int blue;} A[100].red` | size 32, `red` offset 20 -> `3220` | `lw x2,3220(x1)` |

## 5. Logical, Shift, and Codegen Patterns

### 5.1 Logical and Shift Operations

| Operation | C | RISC-V |
|---|---|---|
| shift left | `<<` | `SLL`, `SLLI` |
| logical right shift | unsigned `>>` | `SRL`, `SRLI` |
| arithmetic right shift | signed `>>` | `SRA`, `SRAI` |
| bitwise AND | `&` | `AND`, `ANDI` |
| bitwise OR | `|` | `OR`, `ORI` |
| bitwise XOR | `^` | `XOR`, `XORI` |
| bitwise NOT | `~x` | `xori rd,rs,-1` |

Masks:

- extract low 10 bits: `andi rd,rs,1023`
- clear low 10 bits: `andi rd,rs,-1024`
- set bit mask: `ori rd,rs,mask`

### 5.2 Common RV32I Codegen

Assume unsigned `a` in `a0`, signed `b` in `a1`, signed `c` in `a2`.

| C expression | Good RV32I code |
|---|---|
| `a*4` | `slli t0,a0,2` |
| `b*61` | `slli t0,a1,6; slli t1,a1,2; sub t0,t0,t1; add t0,t0,a1` |
| `a/8` unsigned | `srli t0,a0,3` |
| `b>>3` signed shift | `srai t0,a1,3` |
| `b/8` signed division | `bge a1,x0,L; addi a1,a1,7; L: srai t0,a1,3` |
| `a%128` | `andi t0,a0,0x7f` |
| `pow(2,a)` | `addi t0,x0,1; sll t0,t0,a0` |
| `a=(b>=c)` | `slt a0,a1,a2; xori a0,a0,1` |

> Signed division by power of 2 rounds toward 0; arithmetic shift rounds toward `-inf`. Add bias before `srai` for negative values.

### 5.3 Software Multiply Without `M`

```asm
xor  a0,a0,a0        # result = 0
loop:
    andi t0,a2,1
    beqz t0,skip
    add  a0,a0,a1
skip:
    slli a1,a1,1
    srli a2,a2,1
    bnez a2,loop
```

## 6. LUI/AUIPC Constants and Addresses

### 6.1 Loading a 32b Constant

For `0x12345678`:

```asm
lui  x1,0x12345       # x1 = 0x12345000
addi x1,x1,0x678      # x1 = 0x12345678
```

Corner case when low 12b sign bit is 1:

```asm
# target x1 = 0x12345800
lui  x1,0x12346       # bump upper 20b
addi x1,x1,-0x800     # add signed low 12b
```

Reason: `addi` immediate is signed 12b. `0x800` means `-2048`, not `+2048`. Pseudo `li` handles this.

### 6.2 Far PC-Relative Address

```asm
auipc x1,imm20        # x1 = PC + (imm20 << 12)
jalr  x0,x1,imm12     # PC = (x1 + imm12) & ~1
```

`AUIPC+JALR` reaches much farther than `JAL`; useful for far calls and PIC sequences.

## 7. ABI and Assembly vs Binary

### 7.1 Assembly vs Binary

Assembler conveniences:

- labels instead of numeric PC offsets.
- pseudo-instrs: `li`, `mv`, `nop`, `j`, `ret`, `beqz`, `bnez`.
- relocation records for unresolved symbols.

### 7.2 ABI Register Convention

| ABI | x-reg | Role | Preserved by |
|---|---|---|---|
| `zero` | x0 | constant 0 | fixed |
| `ra` | x1 | return address | caller |
| `sp` | x2 | stack pointer | callee |
| `gp` | x3 | global pointer | platform |
| `tp` | x4 | thread pointer | platform |
| `t0-t2` | x5-x7 | temporaries | caller |
| `s0/fp` | x8 | saved/frame pointer | callee |
| `s1` | x9 | saved | callee |
| `a0-a7` | x10-x17 | args; `a0/a1` returns | caller |
| `s2-s11` | x18-x27 | saved | callee |
| `t3-t6` | x28-x31 | temporaries | caller |

- First 8 integer args: `a0-a7`.
- Return value: `a0` or `a0/a1`.
- RISC-V Unix ABI stack alignment at call boundary: **16B**.

## 8. Exception Handling and CSRs

On trap/interrupt:

1. HW writes `mepc`, `mcause`, updates status bits, jumps to `mtvec`.
2. Handler saves GPRs it will clobber.
3. Handler handles event; may adjust `mepc`.
4. Restore regs; `mret`.

Illegal instr example: `mul` on RV32I without `M`; handler may emulate it.

> [!IMPORTANT]
> Context switch/trap must preserve architectural state. Microarchitectural state like pipeline regs/cache predictor state is not part of the architectural contract.

## 9. ISA Design Issues / Quiz Traps

### 9.1 More Registers: Why Not 128 GPRs?

Pros: fewer spills, more compiler allocation freedom.

Cons:

- register specifier grows from 5b to 7b -> larger instrs or fewer imm/opcode bits.
- larger/slower regfile, more expensive ports.
- more save/restore overhead at calls/context switches.
- arrays/strings/structs/stacks still live in memory, so memory ops do not disappear.

### 9.2 FMA and R4

RISC-V F/D includes FMA because matrix/vector kernels use `A = B*C + D` constantly.

Benefits:

- one instr instead of `FMUL+FADD`.
- one final rounding, better precision.
- often 5-6 cycles, not `FMUL latency + FADD latency`.

Alternative 3-operand design: `rd = rs1*rs2 + rd`. It avoids a fourth source field, but makes ==**rd both source and destination**== and breaks regularity.

### 9.3 No `LW rd,(rs1+rs2)`

For `A[i]`, address is `base + i*sizeof(element)`, not just `base+i`.

- If load scales `rs2`, addressing mode becomes complex.
- If compiler precomputes scaled index, no instr-count saving.
- In loops, compiler often increments a pointer by element size using `addi`.
- A 3-reg load would need R-type-like source fields plus load semantics, hurting regularity.

### 9.4 No Post-Increment Load

Rejected form:

```asm
rd = mem[rs1+imm]
rs1 = rs1 + imm
```

Why rejected:

- needs two register writes (`rd` and updated `rs1`).
- makes `rs1` both source and destination.
- complicates forwarding, hazard detection, and precise exceptions.

## 10. GDB / Bomb Lab

- `p $a0`: print `a0` decimal.
- `p/x $a0`: print `a0` hex.
- `info registers`: show all regs.
- `x/d addr`: examine memory at `addr` in decimal.
- Bomb lab goal: infer inputs from code; do not brute force; binary may depend on the provided RISC-V environment.
