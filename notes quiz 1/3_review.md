# Lec 3: RISC-V ISA

## Exam Facts

- ==**ISA**==: contract/interface between software and hardware.
- RISC-V: open, modular, load/store, regular formats; no required cache hierarchy.
- ISA name: `RV{32/64/128}{I/E}{M,A,F,D,C,V}`. Base is `I` or `E`. `RV32EM` valid; `RV32MI` invalid.
- ==**RV32E**== has only **16 GPRs**; RV32I has 32 GPRs.
- In `RV32I`, `32` means **32b address space** and **32b GPR width**, not 32 regs/instrs.
- C extension absent -> RISC-V would be fixed-length 32b ISA.
- RV32I arch state: **32 GPRs + PC + CSRs**. RV64IFV adds FP regs + vector regs.
- Microarch state: pipeline regs, BHT, BTB, L1I/L1D; **not saved on interrupt**.
- ABI = **ISA + OS syscall interface + calling convention**.
- Natural alignment avoids data crossing **cache-line/page boundaries**.
- Branch offset: PC-relative, 2B-scaled, signed 12b encoded + implicit 0 -> about **+-4 KiB**.
- `JAL`: PC-relative, 2B-scaled, about **+-1 MiB**. `JALR`: `rs1+imm`, can reach full RV32 address space with loaded base.
- `LUI+ADDI` for 32b constants; if low12 has sign bit 1, bump upper by 1.
- No `LW rd,(rs1+rs2)`: needs scaling/complex addressing, breaks load/store regularity, often saves no instr in loops.
- No post-increment load: needs **2 write ports** and makes `rs1` both source+destination.

## 1. ISA Design

### 1.1 CISC vs RISC

| | CISC | RISC / RISC-V |
|---|---|---|
| Instr length | variable | mostly fixed 32b (16b with C) |
| Addressing modes | many | few |
| Memory operands | many instrs | only load/store |
| Decode/pipeline | harder | easier |

==**CPU time = IC x CPI x cycle time**==. RISC may increase IC but lowers CPI/cycle time.

### 1.2 RISC Philosophy

1. Simplicity favors regularity.
2. Smaller is faster.
3. Make common case fast.
4. Good design demands compromise.

## 2. RV32I Instructions and State

### 2.1 Categories

| Category | Examples |
|---|---|
| R ALU | `add sub and or xor sll srl sra slt sltu` |
| I ALU | `addi andi ori xori slti sltiu slli srli srai` |
| Loads | `lb lh lw lbu lhu`; RV64 adds `ld lwu` |
| Stores | `sb sh sw` |
| Branches | `beq bne blt bge bltu bgeu` |
| Jumps | `jal jalr` |
| U | `lui auipc` |
| System/CSR | `ecall ebreak csrrw csrrs csrrc` |

> No `BLE/BGT`: swap operands with `BLT/BGE`. `0 <= x < y` can use unsigned compare `bgeu x,y,out`.

### 2.2 Architectural State

| ISA | Architectural state |
|---|---|
| RV32I | 32 GPRs + PC + CSRs |
| RV64IFD | GPRs + PC + CSRs + 32 FP regs |
| RV64IFV | GPRs + PC + CSRs + FP regs + vector regs |

`x0` is hardwired 0: clear/copy/compare-zero/discard load result.

### 2.3 Register Ports

- RV32I scalar register file: ==**2 read + 1 write**==.
- 2-issue superscalar integer: about **4R/2W**.
- 2-issue RV64IFD with FMA: FMA has 3 FP sources -> **6R/2W** FP regfile.

## 3. Instruction Formats

![](assets/3.3.1.png)

| Type | Use | Key fields |
|---|---|---|
| **R** | reg-reg ALU | `funct7 rs2 rs1 funct3 rd opcode` |
| **I** | imm ALU, loads, `jalr` | `imm[11:0] rs1 funct3 rd opcode` |
| **S** | stores | `imm[11:5] rs2 rs1 funct3 imm[4:0] opcode`; no `rd` |
| **B** | branches | split imm, no `rd`; PC-relative target |
| **U** | `lui auipc` | 20b upper immediate in bits 31:12 |
| **J** | `jal` | split 20b immediate + implicit low 0 |

==Regularity==: `opcode[6:0]`, `rd[11:7]`, `rs1[19:15]`, `rs2[24:20]` stay in fixed positions when present.

### 3.1 Immediate Encoding Precisely

| Type | Immediate value |
|---|---|
| I | `signext(inst[31:20])` |
| S | `signext({inst[31:25], inst[11:7]})` |
| B | `signext({inst[31],inst[7],inst[30:25],inst[11:8],0})` |
| U | `inst[31:12] << 12` |
| J | `signext({inst[31],inst[19:12],inst[20],inst[30:21],0})` |

![](assets/3.8.png)

> [!IMPORTANT]
> B/J immediates are not "multiply by 2" after an arbitrary field. The encoded bits are rearranged and have an **implicit low 0 bit** because targets are 2B-aligned for the C extension.

### 3.2 Alignment + Memory Operands

==**Natural alignment**==: address is a multiple of object size.

| Type | Size/alignment under LP64 |
|---|---:|
| `char` | 1 |
| `short` | 2 |
| `int` / `float` | 4 |
| `long` / `double` / pointer | 8 |

Avoids data crossing cache-line/page boundaries, which could need two cache accesses/TLB checks/page faults.

#### 3.2.1 Struct Rules

1. Each field starts at offset multiple of its own alignment.
2. Struct total size is padded to multiple of largest field alignment.
3. C struct field order is fixed; compiler may reorder independent locals, **not struct fields**.

#### 3.2.2 Worked Example (Quiz1 #14)

```c
struct S1 { int white; long count; char c; long red; int green; char d; int blue } A[1000];
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
| total | 48 | pad to 8B multiple |

`A[10].blue = 0`: offset `10*48 + 40 = 520` -> ==**`sw x0, 520(x1)`**==.

### 3.3 Branches and Jumps

| Instr | Target/effect | Range idea |
|---|---|---|
| branch | `PC + signext(B-imm)` | `[-4096,+4094]` bytes |
| `jal rd,label` | `rd=PC+4; PC=PC+J-imm` | about `+-1 MiB` |
| `jalr rd,rs1,imm` | `rd=PC+4; PC=(rs1+signext(imm)) & ~1` | via base reg, full address space possible |

Common forms:

```asm
jal  x0, label      # unconditional jump, no link
jal  ra, func       # call
jalr x0, ra, 0      # ret
jalr x0, t0, 0      # indirect jump: switch/vtable/function pointer
```

> Store offset is `rs1 + byte_offset`; branch offset is **PC-relative**. Do not mix them.

### 3.4 Constants and Addressing

```asm
; target: x1 = 0x12345678
lui  x1, 0x12345      # x1 = 0x12345000
addi x1, x1, 0x678
```

If low12 sign bit is 1:

```asm
; target: x1 = 0x12345800; addi imm is signed -0x800
lui  x1, 0x12346
addi x1, x1, -0x800
```

`li` pseudo-instruction handles this. `auipc rd,imm` computes `PC + (imm<<12)`; `auipc+jalr` supports far PC-relative calls.

## 4. Assembly vs Binary

Assembler conveniences:

- labels instead of numeric PC offsets.
- pseudo-instrs: `li`, `mv`, `nop`, `j`, `ret`, `beqz`, `bnez`.
- relocation records for unresolved labels/symbols.

## 5. ABI / Register Convention

| ABI | x-reg | Role | Preserved by |
|---|---|---|---|
| `zero` | x0 | constant 0 | fixed |
| `ra` | x1 | return address | caller |
| `sp` | x2 | stack pointer | callee |
| `gp/tp` | x3/x4 | global/thread ptr | fixed platform |
| `t0-t2` | x5-x7 | temps | caller |
| `s0/fp` | x8 | saved/frame ptr | callee |
| `s1` | x9 | saved | callee |
| `a0-a7` | x10-x17 | args; `a0/a1` returns | caller |
| `s2-s11` | x18-x27 | saved | callee |
| `t3-t6` | x28-x31 | temps | caller |

- First 8 integer args: `a0-a7`; return value: `a0` (and `a1` for wider RV32 returns).
- Stack alignment at calls in RISC-V Unix ABI: **16B**.
- `a0-a7`, `t0-t6`, `ra` may be clobbered across calls.

## 6. Common RV32I Codegen

Assume function args: unsigned `a` in `a0`, signed `b` in `a1`, signed `c` in `a2`.

| C expression | Good RV32I code |
|---|---|
| `a*4` | `slli t0,a0,2` |
| `b*61` | `slli t0,a1,6; slli t1,a1,2; sub t0,t0,t1; add t0,t0,a1` |
| `a/8` unsigned | `srli t0,a0,3` |
| `b>>3` | `srai t0,a1,3` |
| `b/8` signed | `bge a1,x0,L; addi a1,a1,7; L: srai t0,a1,3` |
| `a%128` | `andi t0,a0,0x7f` |
| `pow(2,a)` | `addi t0,x0,1; sll t0,t0,a0` |
| `a=(b>=c)` | `slt a0,a1,a2; xori a0,a0,1` |

> Signed divide by power of 2 rounds toward 0, while arithmetic shift rounds toward `-inf`; add bias for negative values.

### 6.1 Software Multiply Without `M`

```asm
xor  a0,a0,a0        # result=0
loop:
    andi t0,a2,1
    beqz t0,skip
    add  a0,a0,a1
skip:
    slli a1,a1,1
    srli a2,a2,1
    bnez a2,loop
```

## 7. Exceptions / Interrupts

On trap/interrupt, save/restore architectural state; microarchitectural state can be regenerated.

Typical machine-mode flow:

1. HW writes `mepc`, `mcause`, updates `mstatus`, jumps to `mtvec`.
2. Handler saves GPRs if needed.
3. Handle event; may adjust `mepc`.
4. Restore regs; `mret`.

Illegal instruction (e.g., `mul` on RV32I) can be emulated by software handler.

## 8. ISA Design Issues / Quiz Traps

### 8.1 128 GPRs?

Usually no:

- more bits per register specifier -> larger instr or fewer opcode/imm bits.
- larger/slower register file, more ports expensive.
- more save/restore at calls/context switches.
- arrays/structs/strings still live in memory, so memory ops do not disappear.

### 8.2 Three-Operand FMA Alternative

To avoid R4, define `rd = rs1 * rs2 + rd`. It preserves dot-product use, but breaks RV regularity because ==**rd is both source and destination**==; it also pressures read ports.

### 8.3 No `LW rd,(rs1+rs2)`

For `A[i]`, address is `base + i * sizeof(element)`, not just `base+i`.

- If load scales `rs2`, addressing mode becomes complex.
- If compiler first computes scaled index, no instr-count savings.
- In loops, compiler often increments base pointer by 1/2/4/8 with `addi`.
- R-type-like 3-reg load breaks regular load/store format regularity.

### 8.4 No Post-Increment Load

`rd <- mem[rs1+imm]; rs1 <- rs1+imm` is rejected because it needs **two register writes** and makes `rs1` both source and destination.

## 9. GDB / Bomb Lab

- `print $a0` / `p $a0`: print register `a0` in decimal.
- `print/x $a0`: hex.
- `info registers`: all regs.
- `x/d addr`: examine memory at address.
- Bomb goal: infer correct inputs without exploding; not brute force; executable is not universally portable to every RISC-V platform.
