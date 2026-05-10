# Lec 3: RISC-V ISA

## Exam Facts

- ==**ISA**==: SW/HW interface; RV is **open, modular, license-free, load/store**.
- ==**RV32I**==: 32b addr space + **32 GPRs**; 32b instr (16b w/ **C ext**).
- ==**RV32E**==: embedded, **only 16 GPRs**.
- Naming `RV{32/64/128}{I/E}{M,A,F,D,C,V}`. Base must be I or E. `RV32EM` ✓; `RV32MI` ✗.
- "32" in RV32I = ==**32b addr + 32b GPR width**==, NOT "32 instr" / "32 GPRs".
- **Architectural state**: RV32I = 32 GPRs + PC + CSRs; RV32IFD adds FP regs; RV32IFV adds vector regs.
- ==**Microarch state**== (NOT saved on interrupt): pipeline regs, BHT, BTB, L1I/L1D, write buffer.
- ==**ABI**== = ISA + OS syscalls + calling convention.
- RV uses **register-register ALU**, **load/store memory access**, few regular formats.
- Branch imm = **PC-relative, scaled by 2B** (C ext) → range ≈ ==**±4 KB**==.
- JAL ≈ ±1 MiB; ==**JALR reaches full 4 GB**== via `rs1+imm`; AUIPC+JALR for far calls.
- Natural alignment avoids data crossing **cache-line / page boundaries**.
- RV-Linux ABI stack alignment = ==**16B**== at calls.
- `LUI` (U, 20b) + `ADDI` for 32b consts; ==if low12 sign-bit is 1, **bump upper +1**== (`li` does this).
- **No `LWU` in RV32I** (`LW` already 32b).
- **No `LW rd,(rs1+rs2)`**: needs scaling, breaks regularity, no instr-count savings.
- **No post-increment load**: needs **2 reg write ports**; rs1 = both src+dst → breaks regularity.
- **No 128/1024 GPRs**: smaller=faster, longer instr fields, more save/restore overhead, arrays/structs in mem anyway.
- ==**Hart**==: HW thread (PC/GPRs/CSRs).

## 1. ISA Design

### 1.1 CISC vs RISC

| | CISC (x86, VAX) | RISC (RV, ARM, MIPS) |
|---|---|---|
| Instr | many, **var-length**, complex | few, **fixed**, simple |
| Mem access | many addr modes | **load/store only** |
| Pipeline | hard | regular |
| Code size | small | larger (I-cache helps) |

==**CPU time = IC × CPI × cycle**==. RISC: more IC, lower CPI, shorter cycle.
> Modern x86 decodes complex instr into RISC-like µ-ops internally. ISA quality measured by **compiler usability**.

### 1.2 RISC Philosophy

1. **Simplicity favors regularity** — fixed size, few formats, opcode in fixed bits.
2. **Smaller = faster** — limit instr/regs/addr modes.
3. **Make common case fast** — ops in regs, immediate ops.
4. **Good compromises** — balance format vs operand count.

## 2. RV32I Instructions and State

### 2.1 Categories

- ALU R-type: `add sub and or xor sll srl sra slt sltu`
- ALU I-type: `addi andi ori xori slti sltiu slli srli srai`
- Loads (I): `lb lh lw lbu lhu` (no `lwu`); Stores (S): `sb sh sw`
- Branches (B): `beq bne blt bge bltu bgeu`; Jumps: `jal` (J), `jalr` (I)
- U-type: `lui auipc`; system/CSR: `ecall ebreak csrrw csrrs csrrc`

> No `BLE/BGT`: swap operands of `BLT/BGE`. Range check `0≤x<y` via unsigned `BGEU` (1 instr).

### 2.2 Architectural State

- RV32I: **32 GPRs + PC + CSRs**; RV32IFD: + 32 FP regs; RV32IFV: + vector regs.
- ==`x0` hard-wired 0==: clear (`sub x9,x0,x8`), copy (`add x1,x0,x2`), cmp-zero (`beq x5,x0,L`), mem test (`lw x0,0(x1)`).
- CSRs: `cycle, instret, hartid, mepc, mcause, mstatus, mtvec, mscratch`.

### 2.3 Register Ports

- RV32I scalar: ==**2R / 1W**==.
- 2-issue superscalar (int): ~**4R / 2W**.
- 2-issue RV64IFD with FMA: FP ==**6R / 2W**== (FMA = 3 src/issue).

## 3. Instruction Formats

| Type | Use | Fields |
|---|---|---|
| **R** | reg-reg ALU | `funct7\|rs2\|rs1\|funct3\|rd\|opcode` |
| **I** | imm ALU, loads, JALR | `imm[11:0]\|rs1\|funct3\|rd\|opcode` (12b signed) |
| **S** | stores | imm split, no rd |
| **B** | branches | imm split, **PC-rel × 2B**, no rd |
| **U** | `lui auipc` | 20b upper imm |
| **J** | `jal` | 20b imm × 2 |

==Regularity==: opcode bits 0-6, rd 7-11, rs1 15-19, rs2 20-24. B/J imm rearranged to share sign-extension HW.

> R-type: `rd = rs1 (funct3,funct7) rs2`. ADD/SUB: `funct7=0000000/0100000`. SRL/SRA same.
> I-type: 12b signed sign-extended. Shifts: `inst[30]` distinguishes SRLI/SRAI.

### 3.1 Alignment + Memory Operands

- ==**Natural alignment**==: addr is multiple of object size.
- Compiler maintains: `char` 1B, `short` 2B, `int` 4B, `long` 8B (LP64), `double` 8B.
- Avoids cache-line/page crossing → no double TLB miss / page fault.

#### 3.1.1 Struct Rules

1. Each member at multiple of **its own alignment**.
2. **Total size** padded to multiple of **largest member's alignment**.
3. ==Field order **fixed** in C== (binary compat, pointer arithmetic).

> [!IMPORTANT] Independent locals **may** be reordered; struct fields **may NOT**.

#### 3.1.2 Worked Example (Quiz1 #14, RV64IFD)

```
struct S1 { int white; long count; char c; long red; int green; char d; int blue } A[1000];
```

| Field | Offset | Bytes |
|---|---|---|
| `int white` | 0 | 4 (+pad 4) |
| `long count` | 8 | 8 |
| `char c` | 16 | 1 (+pad 7) |
| `long red` | 24 | 8 |
| `int green` | 32 | 4 |
| `char d` | 36 | 1 (+pad 3) |
| `int blue` | 40 | 4 (+pad 4) |
| total | | **48** |

`A[10].blue=0` → offset = `10*48 + 40 = 520` → ==**`SW x0, 520(x1)`**==.

> Stack/frame alignment per ABI: ==**RV-Linux 16B**== (older 8B). CRT enforces before main.

### 3.2 Branches and Jumps

- ==Branch==: `PC + imm × 2`, signed 12b → ==**±4 KB**==.
- ==Store==: `rs1 + imm`, byte offset.
> Trap: branch ≠ store offset semantics — branch is PC-relative (2B-scaled), store is base-register-relative (byte).
- Branch imm scaled by **2** (not 4) so 16b compressed instructions can be targets.
- JAL: 20b imm × 2 → ±1 MiB. AUIPC+JALR: full 4 GB.
- ==**JALR rd,rs1,imm**==: `rd=PC+4; PC=(rs1+imm)&~1`.

#### 3.2.1 JAL / JALR Uses

```
jal  x0, label    ; j label (no link)
jal  x1, func     ; call (link to ra)
jalr x0, x1, 0    ; ret
jalr x0, rs1, 0   ; indirect jump (switch / vtable)
```

> No separate JUMP/CALL: `JAL/JALR + rd=x0/ra` covers both. Return prediction: HW uses ==**RAS**== + recognizes `JALR x0,ra,0` as return; wrong if ra repurposed.

### 3.3 Constants and Addressing (LUI, AUIPC)

```
# 0x12345678
lui  x1, 0x12345     # x1 = 0x12345000
addi x1, x1, 0x678   # x1 = 0x12345678
```

> [!IMPORTANT] If low12 sign-bit set (e.g., `0x800`), `addi` sign-extends negative. **Bump upper +1** to compensate; pseudo `li` does this automatically.
> ```
> # 0x12345800
> lui  x1, 0x12346
> addi x1, x1, -0x800
> ```

`AUIPC rd,imm`: `rd = PC + (imm<<12)`. With JALR → far PC-rel calls.

## 4. Assembly vs Binary

Assembler provides: mnemonics, **pseudo-instructions** (`mv, j, li, nop, ret, bnez, beqz`), labels.

## 5. ABI / Register Convention

| ABI | x-reg | Role | Save |
|---|---|---|---|
| `zero` | x0 | const 0 | — |
| `ra` | x1 | return addr | **caller** |
| `sp` | x2 | stack ptr | preserved |
| `gp/tp` | x3/x4 | global/thread ptr | preserved |
| `t0-t2` | x5-7 | temps | **caller** |
| `s0/fp` | x8 | saved/frame ptr | **callee** |
| `s1` | x9 | saved | **callee** |
| `a0-a1` | x10-11 | args / **return val** | **caller** |
| `a2-a7` | x12-17 | args | **caller** |
| `s2-s11` | x18-27 | saved | **callee** |
| `t3-t6` | x28-31 | temps | **caller** |

- Args: a0-a7 (extras spill to stack); return: ==**a0**== (a1 too on RV32 for 64b).
- Calls: `jal ra, target`; returns: `ret = jalr x0, ra, 0`.

### 5.1 Common RV32I Codegen

| C op | RV32I |
|---|---|
| `a*4` | `slli rd, a0, 2` |
| `a/8` (unsigned) | `srli rd, a0, 3` |
| `a%128` | `andi rd, a0, 0x7F` |
| `b>>3` (signed) | `srai rd, a1, 3` |
| `b/8` (signed div) | `bge a1,x0,+8; addi a1,a1,7; srai rd,a1,3` |
| `pow(2,a)` | `addi rd,x0,1; sll rd,rd,a0` |
| `b*61` | `slli t0,a1,6; slli t1,a1,2; sub t0,t0,t1; add t0,t0,a1` (=64b−4b+b) |
| `a=(b>=c)` | `slt a0,a2,a1; xori a0,a0,1` |

> [!IMPORTANT] Signed `b/8` needs **biasing** when negative: `if(b<0) b+=7;` then `srai 3` (else `-9>>3=-2` instead of `-1`).

### 5.2 Software Multiply (no `M` ext)

```
xor a0,a0,a0
mult_loop:
    andi t0,a2,1
    beqz t0,skip
    add  a0,a0,a1
skip:
    slli a1,a1,1
    srli a2,a2,1
    bnez a2,mult_loop
```

## 6. Exceptions / Interrupts

HW: save `mepc, mcause, mstatus.MPP`; jump to `mtvec`; raise privilege.
SW: save GPRs to mem at `mscratch`; decode; adjust `mepc` (+4/+2); restore; `MRET`.

> Illegal instr (e.g., `mul` on RV32I): handler can **emulate** in SW.
> Precise exceptions easier in-order; OoO needs reorder buffer + commit.

## 7. ISA Design Issues / Quiz Traps

- **128 GPRs?** No: slower regfile, wider instr, more save/restore, arrays still in mem.
- **3-operand FMA alt** `rd=rs1*rs2+rd` saves operand but rd is both src+dst → ==breaks regularity== (extra read port for rd).
- **Post-increment load** rejected: 2 write ports; rs1 src+dst.
- **Compare-and-branch** vs flag: RV picks compare-and-branch (no global flag, simple pipeline).
- **No `LW rd,(rs1+rs2)`**: needs scaling; in loops, `addi` advances base — no savings.

### 7.1 GDB / Bomb Lab

- ==`print $a0`== / `p $a0`: reg in **decimal**.
- `print/x $a0`: hex; `info registers`: all GPRs; `x/d addr`: memory.
- ==`a0-a7,t0-t6,ra` are caller-saved== → may be clobbered across calls.
- Bomb is **NOT guaranteed cross-platform**; goal: correct inputs, NOT brute force.
