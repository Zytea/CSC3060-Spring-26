# Lec 3: RISC-V ISA

## Exam Facts

- ==**ISA**== = software/hardware interface. RISC-V is **open, modular, license-free, load/store**.
- ==**RV32I**== = 32b address space + **32 GPRs** (x0–x31), each 32b; instructions **fixed 32b** unless **C extension** (then 16b allowed → variable length).
- ==**RV32E**==: embedded base, **only 16 GPRs**.
- Naming: `RV{32/64/128}{I/E}{M,A,F,D,C,V,…}`. Base must be I or E. `RV32EM` ✓; `RV32MI` ✗ (M is extension, not base).
- "32" in RV32I = **32b address space + 32b GPR width**, NOT "32 instructions" and NOT "32 GPRs" (RV32E also has 32b).
- **Architectural state**:
  - RV32I: **32 GPRs + PC (+ CSRs)**
  - RV32IFD: + 32 FP regs
  - RV32IFV: + vector regs
- **Microarch state** (NOT saved on interrupt — refillable): pipeline regs, BHT, BTB, L1I/L1D, write buffer.
- ==**ABI**== = **ISA + OS syscalls + calling convention**; decides binary compatibility.
- RV uses **register-register ALU**, **load/store memory access**, **few regular formats**.
- Branch immediate = **PC-relative**, **scaled by 2B** (because of C ext); branch range ≈ ±4 KB.
- JAL range ≈ ±1 MiB; **JALR can reach the full 4 GB** via `rs1 + imm`; AUIPC+JALR for far calls.
- Natural alignment avoids data crossing **cache-line / page boundaries** and simplifies hardware.
- RV-Linux ABI: **16-byte stack alignment** at function boundaries.
- `LUI` (U-type, 20b) + `ADDI` builds 32b constants; if low 12b sign-bit is 1, **bump upper imm by 1** (the assembler `li` handles this).
- `JAL`: J-type; `JALR`: I-type (indirect call/return/switch dispatch).
- **No `LWU`** in RV32I (would need 33-bit zero extension; word load already loads 32b).
- **No `LW rd,(rs1+rs2)`**: needs scaling, breaks regularity, extra ALU work, no actual instr-count savings.
- **No post-increment load**: needs **2 reg write ports**; rs1 becomes both source AND dest → breaks regularity.
- Why **NOT 1024 GPRs**: smaller-is-faster; longer instr fields; more save/restore on calls/context-switch; arrays/structs are in **memory** so most loads remain.
- ==**Hart**== = HW thread ≈ a "core" in multicore (each has own PC/GPRs/CSRs).

## 3.1 ISA Design

### CISC vs RISC

| | CISC (x86, VAX, IBM 360) | RISC (RV, MIPS, ARM, SPARC, PPC) |
|---|---|---|
| Instructions | many, **variable length**, complex | few, **fixed length**, simple |
| Registers | few | many |
| Memory access | many addressing modes | **only load/store** access memory |
| Pipeline | hard | easy / regular |
| Code size | small | larger (helped by I-cache) |

**CPU time = Instruction count × CPI × Cycle time** — RISC may have more instrs but lower CPI / shorter cycle.

> ISA quality is measured by how well **compilers** can use it — not by handwritten asm.

### RISC design philosophy

1. **Simplicity favors regularity** — fixed size, few formats, opcode in fixed bits.
2. **Smaller is faster** — limited instr/reg/addressing modes.
3. **Make the common case fast** — operands in regs (load/store machine), immediate ops.
4. **Good compromises** — balance format vs operand count.

### Modern landscape

GPU dominates compute; AI uses tensor/matrix accelerators; AI changes faster than compilers ⇒ **library-based** acceleration; even modern RISC chips include some complex instructions.

## 3.2 RV32I Instructions and Formats

### 3.2.1 Categories

| Category | Examples |
|---|---|
| ALU R-type | `add sub and or xor sll srl sra slt sltu` |
| ALU I-type imm | `addi andi ori xori slti sltiu slli srli srai` |
| Loads (I-type) | `lb lh lw lbu lhu` (no `lwu` in RV32I) |
| Stores (S-type) | `sb sh sw` |
| Branches (B-type) | `beq bne blt bge bltu bgeu` |
| Jumps | `jal` (J-type), `jalr` (I-type) |
| Upper imm (U-type) | `lui auipc` |
| System / CSR | `ecall ebreak csrrw csrrs csrrc …` |

> No `BLE`/`BGT`: swap operands of `BLT`/`BGE`. No `LWU` in RV32I (`LW` already loads 32b).

### 3.2.2 RV32I Architectural state

- **32 GPRs** (x0–x31, 32b). `x0` hard-wired to 0.
- **PC** (32b).
- **CSRs**: `cycle, instret, hartid, mepc, mcause, mstatus, mtvec, mscratch, …`

> Why `x0=0` is useful: **clear** (`sub x9, x0, x8`), **copy** (`add x1, x0, x2`), **compare-with-zero** (`beq x5, x0, L`), **memory test** (`lw x0, 0(x1)`).

> Architectural state must be saved on context switch / interrupt; cache/BHT/pipeline regs need NOT be saved (regenerable).

### 3.2.3 Variant states

| ISA | Architectural state |
|---|---|
| RV32I | 32 GPRs + PC + CSRs |
| RV32IFD | + 32 FP regs |
| RV32IFV | + 32 vector regs |

### Register ports

- RV32I scalar regfile: **2 read + 1 write** ports (most R-type instructions read 2, write 1).
- 2-issue superscalar integer: ~**4R/2W**.
- 2-issue RV64IFD with FMA: FP regfile **6R/2W** (FMA reads 3 src per issue).

## 3.3 Instruction Formats

| Type | Use | Fields |
|---|---|---|
| **R** | reg-reg ALU | `funct7 \| rs2 \| rs1 \| funct3 \| rd \| opcode` |
| **I** | imm ALU, loads, JALR | `imm[11:0] \| rs1 \| funct3 \| rd \| opcode` (12b signed imm) |
| **S** | stores | `imm[11:5] \| rs2 \| rs1 \| funct3 \| imm[4:0] \| opcode` (no rd) |
| **B** | branches | imm split + rearranged; **PC-relative, scaled by 2B**; no rd |
| **U** | `lui auipc` | `imm[31:12] \| rd \| opcode` (20b upper immediate) |
| **J** | `jal` | imm rearranged; `rd = pc+4`, `pc += imm` |

**Regularity**: `rd` always bits 7–11; `rs1` bits 15–19; `rs2` bits 20–24.

> Why B-imm and J-imm bits are rearranged: shared HW for sign-extension + reduces muxing in the immediate generator.

### R-Type detail

- `rd = rs1 (funct3, funct7) rs2`
- `funct7` distinguishes ADD vs SUB (`0000000` vs `0100000`), SRL vs SRA (`0000000` vs `0100000`).

### I-Type detail

- 12b signed immediate, sign-extended to 32b (range −2048 to +2047).
- For shift imm (SLLI/SRLI/SRAI): only low 5b used (RV32) / 6b (RV64); `inst[30]` distinguishes SRLI/SRAI.

### Loads/Stores

- Load: `lw rd, imm(rs1)` → `rd ← mem[rs1 + signext(imm)]`.
- Store: `sw rs2, imm(rs1)` → `mem[rs1 + signext(imm)] ← rs2`.
- Offset is **bytes**.

### 3.3.3 Alignment + Memory Operands

- ==**Natural alignment**==: address is multiple of object size (`sw/lw` on 4B-aligned, `sd/ld` on 8B-aligned).
- Compiler maintains alignment: `char` 1B, `short` 2B, `int` 4B, `long` 8B (LP64), `double` 8B.

#### Why alignment matters

- No cache-line / page boundary crossing → no double TLB miss / page fault from one instr.
- Better cache-line utilization, simpler hardware.

#### Struct layout rules

1. Each member starts at address that's a multiple of **its own alignment**.
2. **Total struct size** padded to multiple of **largest member's alignment**.
3. **Order is fixed** in C standard (cannot reorder fields).

> [!IMPORTANT] Independent locals **may be reordered** by compiler; struct fields **may NOT** (binary compatibility, pointer arithmetic, ABI).

#### Worked example (RV64IFD)

```
struct S1 { int white; long count; char c; long red; int green; char d; int blue } A[1000];
```

| Field | Offset | Bytes |
|---|---|---|
| `int white` | 0 | 4 |
| (pad) | 4–7 | 4 |
| `long count` | 8 | 8 |
| `char c` | 16 | 1 |
| (pad) | 17–23 | 7 |
| `long red` | 24 | 8 |
| `int green` | 32 | 4 |
| `char d` | 36 | 1 |
| (pad) | 37–39 | 3 |
| `int blue` | 40 | 4 |
| (pad to 8B) | 44–47 | 4 |
| **total** | | **48** |

`A[10].blue = 0` → offset = `10*48 + 40 = 520`.
**Answer**: `SW x0, 520(x1)`. (Quiz1 #14 = E)

#### Stack/frame alignment

- Pointer (sp/fp) always aligned per ABI: **RV-Linux = 16B**; older/embedded = 8B.
- C-runtime (CRT) ensures alignment **before main**; maintained at function entry/exit.

### 3.3.4 Branches and Jumps

- ==**Branch**: `PC + imm × 2`==, immediate is **PC-relative**, signed 12b → range **±2¹⁰ × 4B = ±4 KB** (12b signed scaled by 2).
- ==**Store**: `rs1 + imm`==, offset relative to base register, in bytes.
  > Trap: branch ≠ store offset semantics — branch is PC-relative, store is base-register-relative.
- **Branch range scaled by 2B** (not 4B) so 16b compressed (C-ext) instructions can also be targets.
- Jump (J-type, JAL): 20b imm scaled by 2 → range **±2¹⁹ × 2 = ±1 MiB**.
- **AUIPC + JALR**: PC-relative far call, reaches full 4 GB.
- **JALR rd, rs1, imm**: `rd = PC+4; PC = (rs1+imm) & ~1` (clear LSB so PC stays 2B-aligned).

#### JAL / JALR uses

```asm
jal x0, label    # = j label    (unconditional jump, no link)
jal x1, func     # = call (link to ra)
jalr x0, x1, 0   # = ret (return via ra)
jalr x0, rs1, 0  # indirect jump (switch / vtable)
```

> Why no separate JUMP/CALL: `JAL/JALR` + `rd = x0` → jump; `rd = ra` → call. Saves a format. Trade-off: rd field could've gone to bigger immediate → 32× more range. Not worth complexity.

> Return prediction: hardware uses a **Return Address Stack (RAS)** + recognizes `JALR x0, ra, 0` as a return. Wrong if ra is repurposed.

#### Conditional branches

- `BEQ BNE BLT BGE BLTU BGEU`. No `BLE/BGT` (swap operands).
- Range check `0 ≤ x < y`: use unsigned `BGEU x, y` (1 instr instead of 2 signed compares).

### 3.3.5 Constants and Addressing (LUI, AUIPC)

- `ADDI` immediate is 12b signed → cannot encode arbitrary 32b constants.
- Standard pattern for 32b: `LUI rd, upper20; ADDI rd, rd, low12`.

```asm
# load 0x12345678
lui  x1, 0x12345     # x1 = 0x12345000
addi x1, x1, 0x678   # x1 = 0x12345678
```

> **Corner case**: if low 12b has sign bit set (e.g., `0x800`), `addi` sign-extends to negative → result wrong. **Bump upper +1** to compensate. Pseudo `li` does this automatically.

```asm
# load 0x12345800
lui  x1, 0x12346     # bumped!
addi x1, x1, -0x800  # 0x12345800 = 0x12346000 - 0x800
```

- `AUIPC rd, imm`: `rd = PC + (imm << 12)`. Used with `JALR` for **far PC-relative calls**, but not great for binary patching (PC-dependent).

## 3.4 Assembly vs Binary

Assemblers provide:
- **Mnemonics**: `add x1, x2, x3`.
- **Pseudo-instructions**: `mv` (=`addi rd,rs,0`), `j` (=`jal x0,L`), `li`, `nop` (=`addi x0,x0,0`), `ret` (=`jalr x0, ra, 0`), `bnez`, `beqz`, …
- **Symbols** for labels.

## 3.5 ABI / Register Convention

| ABI name | x-reg | Role | Save |
|---|---|---|---|
| `zero` | x0 | constant 0 | — |
| `ra` | x1 | return address | **caller-saved** |
| `sp` | x2 | stack pointer | preserved |
| `gp` | x3 | global pointer | preserved |
| `tp` | x4 | thread pointer | preserved |
| `t0–t6` | x5–7,28–31 | temporaries | **caller-saved** |
| `s0–s11` | x8–9,18–27 | saved/local | **callee-saved** |
| `a0–a7` | x10–17 | args / returns | **caller-saved** |

- **Args**: a0–a7 (first 8); extras spill to stack.
- **Return value**: a0 (and a1 for 64b on RV32).
- ==Result must be returned in `a0`==.
- Calls go through `jal ra, target`; returns via `ret`.

### 3.5.3 Common RV32I codegen

| C op | RV32I |
|---|---|
| `a*4` | `slli rd, a0, 2` |
| `a/8` (unsigned) | `srli rd, a0, 3` |
| `a%128` | `andi rd, a0, 0x7F` |
| `b>>3` (signed shift) | `srai rd, a1, 3` |
| `b/8` (signed div, biased) | `bge a1, x0, +8; addi a1,a1,7; srai rd, a1, 3` |
| `pow(2,a)` | `addi rd,x0,1; sll rd,rd,a0` |
| `b*61` | `slli t0,a1,6; slli t1,a1,2; sub t0,t0,t1; add t0,t0,a1` (= 64b − 4b + b = 61b) |
| `a = (b >= c)` | `slt a0,a2,a1; xori a0,a0,1` (or use slt with swapped operands) |

> [!IMPORTANT] Signed `b/8` needs **biasing** when negative: `if(b<0) b += 7;` then `srai 3`. Otherwise `-9>>3 = -2` instead of `-1`.

### Software multiply (no `M` ext)

Loop 32 times: if LSB of multiplier set, add multiplicand to result; shift multiplicand left, multiplier right. (Quiz 1 problem 3.)

```asm
xor a0, a0, a0           # result = 0
mult_loop:
    andi t0, a2, 1       # LSB of c
    beqz t0, skip
    add  a0, a0, a1      # result += b
skip:
    slli a1, a1, 1       # b <<= 1
    srli a2, a2, 1       # c >>= 1
    bnez a2, mult_loop
```

### Pop quiz facts

| Q | A |
|---|---|
| Set X2=0 | `add X2,X0,X0` ✓; `xor X2,X2,X2` ✓ |
| No `rd` field | **Branches** + **Stores** |
| RV32I is | Load/store ✓; 3-operand ✓; RISC ✓ |
| Branch range | **±4KB** |
| Jump range | **±1MB** |
| AUIPC+JALR | **±2GB** (full 4GB reachable) |
| Why "32" in RV32I | **32b address + 32b GPR width** |

## 3.6 Exceptions / Interrupts

When an exception occurs:

**HW**:
1. Save `mepc` (faulting PC), `mcause`, `mstatus.MPP`.
2. Jump to handler at `mtvec`.
3. Increase privilege level.

**SW handler**:
1. Save GPRs into memory pointed by `mscratch`.
2. Decode cause, dispatch.
3. Adjust `mepc` if needed (+4 / +2).
4. Restore GPRs.
5. `MRET` → restores PC + privilege.

> Illegal-instruction example: code compiled for RV32IM but core is RV32I → `mul` traps. Handler can **emulate** the multiply in software.

### Why precise exceptions are easier in-order

Architectural state updates **in program order** ⇒ cleanly stoppable + restartable. OoO needs a reorder buffer + commit logic for precise state.

## 3.7 ISA Design Issues / Quiz Traps

- **128 / 1024 GPRs?** No — slower regfile, wider instr encoding, more save/restore on calls/context-switch, longer ports. Arrays/structs/strings are in memory ⇒ most loads remain.
- **3-operand instr** (`A = B op C`) is the RISC standard; **R4-type FMA** is the only 4-operand instr (3 src + 1 dst).
- **3-operand FMA alternative** `rd = rs1 * rs2 + rd` saves one operand but **breaks regularity** (rd is BOTH src and dst → needs extra read port for rd).
- **Post-increment load** (Itanium) `rd ← mem[rs1+imm]; rs1 ← rs1+imm`: rejected because **2 write ports** + rs1 is both src AND dst.
- **Compare-and-branch** vs flag/condition-code style: RV uses compare-and-branch — flexible, no global flag register, simple pipeline.
- **Should branch target (`PC + imm`) compute in ID instead of EX?** Saves 1 cycle on predicted-taken — but modern BTB+BHT already predicts where + whether, so the extra ID adder may not pay off. (See lec 4.4.)
- **Why no `LW rd,(rs1+rs2)`**:
  1. Index needs scaling (`rs2 * sizeof(elem)`); extra instr cancels savings.
  2. 3 source-like operands break R/I encoding.
  3. In a loop, compiler simply uses `addi` to advance base — no need for two-reg addressing.

### GDB / Bomb Lab tips

- `print $a0` (or `p $a0`) → register value in **decimal**.
- `print/x $a0` → hex.
- `info registers` → all GPRs at once.
- `x/d addr` / `x/x addr` → memory examination.
- `a0–a7, t0–t6, ra` are **caller-saved** → may be clobbered across calls.
- Bomb is **NOT guaranteed to run on every RISC-V platform** (different ABI/HW). Goal: enter correct inputs without exploding; **NOT** brute force.
