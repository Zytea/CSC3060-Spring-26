# Chapter 3: RISC-V ISA

## Exam Facts

- ==**ISA**==: **software/hardware interface**; RISC-V is open, modular, load/store.
- ==**RV32I**==: 32b address space + 32b GPRs; instruction length is 32b except with **C extension**.
- ==**RV32E**==: embedded base with **16 GPRs**.
- Naming: `RV32I`, `RV64IM`, `RV32EM` valid; base is one of `I/E`, extensions follow. `RV32I` means **32b GPR/address**, not "32 instructions".
- RV32I is byte-addressable and has 32 GPRs, but **does not require on-chip cache**.
- RV32I architectural state: **32 GPRs + PC + CSRs**; RV32IFD adds FP regs; RV32IFV adds vector regs.
- Microarchitectural state: pipeline regs, BHT, BTB, caches; not saved on interrupt because it can be regenerated.
- RISC-V uses **register-register ALU**, **load/store memory access**, few regular formats.
- Natural alignment avoids data crossing **cache-line/page boundaries** and simplifies hardware.
- Branch immediate is **PC-relative** and scaled by 2B due to C extension; store immediate is byte offset from base register.
- `JAL` is J-type; `JALR` is I-type indirect jump/call/return.
- `LUI+ADDI` loads 32b constants; if low 12b sign bit is 1, adjust upper immediate.
- RISC-V avoids complex addressing like `LW rd,(rs1+rs2)` and post-increment loads to preserve regularity and port count.

## 3.1 ISA Design

- RISC: simple fixed/regular instructions, many registers, load/store, compiler-oriented.
- CISC: complex variable-length instructions, more work per instruction, harder decode/pipeline.
- CPU time = **instruction count x CPI x cycle time**; RISC may have more instructions but lower CPI/shorter cycle.
- ISA quality is measured by how well **compilers** can use it, not by assembly convenience.

## 3.2 RV32I Instruction Set + State

Categories:
- integer ALU: `add sub sll slt sltu xor srl sra or and`;
- immediate ALU: `addi slti sltiu xori ori andi slli srli srai`;
- load/store: `lb lh lw lbu lhu`, `sb sh sw`;
- branch: `beq bne blt bge bltu bgeu`;
- jump: `jal jalr`; upper: `lui auipc`; system/CSR.

Register file:
- `x0` always 0; writes ignored.
- RV32I needs **2 read ports + 1 write port**.
- 2-issue superscalar needs roughly **4R/2W** for integer GPRs.
- 2-issue RV64IFD with FMA needs FP reg file **6R/2W** because each FMA reads 3 operands.

Architectural vs microarchitectural:
- RV32I arch: GPRs + PC.
- RV64IFV arch: GPRs + PC + FP regs + vector regs.
- Micro: pipeline regs, BHT, BTB, L1I, L1D.
- In-order retirement gives precise architectural state for traps/resume.

## 3.3 Instruction Formats

| Type | Use | Fields / Exam Point |
|---|---|---|
| R | register ALU | `rd rs1 rs2 funct3 funct7 opcode` |
| I | immed/load/JALR | `rd rs1 imm[11:0]`; 12b signed imm |
| S | stores | no `rd`; imm split; offset from `rs1` in bytes |
| B | branches | no `rd`; PC-relative; imm scaled by 2 |
| U | `lui/auipc` | 20b upper immediate |
| J | `jal` | PC-relative jump, saves `PC+4` in `rd` |

Regularity:
- `rd` always bits 7-11 when present.
- `rs1` bits 15-19, `rs2` bits 20-24.
- Immediate bits often placed high; B/S and J/U are rearranged to reduce hardware muxing.

## 3.3.3 Alignment + Memory Operands

- ==**Natural alignment**==: object address is multiple of object size.
- Struct rules: each field aligned to its own size; struct size padded to multiple of largest field alignment.
- RISC-V Linux stack alignment: **16B** at function boundaries.
- Loads/stores use base + signed 12b byte offset: `LW rd, imm(rs1)`.
- Arrays/structs often stay in memory; more registers do not remove most memory ops.
- No `LW rd,(rs1+rs2)`: needs scaling by element size, 3 source-like operands, more complex datapath/addressing mode.

## 3.3.4 Branches and Jumps

- Branch target: `PC + imm`; fall-through: `PC + 4`.
- Store offset: relative to `rs1`; branch offset: relative to PC.
- Branch range: about **+/-4KB** in bytes for RV32I B-type.
- JAL range: about **+/-1MiB**; JALR range: effectively larger because it can jump to address in `rs1+imm`.
- `JAL rd,label`: `rd=PC+4`, `PC=PC+imm`; `j label` = `jal x0,label`.
- `JALR rd,rs1,imm`: `rd=PC+4`, `PC=(rs1+imm)&~1`; used for indirect calls, returns, switch/virtual dispatch.
- Return: `jalr x0, ra, 0`.
- Hard-to-predict jumps: indirect branches (`jalr` for switch/virtual calls) and returns; BTB/RAS help.

## 3.3.5 Constants and Addressing

- `ADDI` imm is 12b signed; cannot load arbitrary 32b constant alone.
- `LI rd,0xAABBCCDD` is pseudo-instruction; assembler may emit `LUI+ADDI` or more.
- For `0x12345678`: usually `lui rd,0x12345; addi rd,rd,0x678`.
- If low 12b has sign bit set, round upper up: e.g. low `0x800` is negative as signed imm.
- `AUIPC+JALR` supports far PC-relative calls/jumps.

## 3.5 ABI

==**ABI**==: **ISA + OS system calls + calling convention**; decides whether binary runs on a system.
- ABI register names: `a0-a7` args/returns, `t0-t6` temporaries, `s0-s11` saved, `ra`, `sp`, `gp`, `tp`.
- Function args in `a0-a7`; return value in `a0`.
- External binary compatibility requires following ABI.

## 3.5.3 Common RV32I Codegen

- `a*4`: `slli rd,a0,2`; unsigned `a/8`: `srli rd,a0,3`; `a%128`: `andi rd,a0,127`.
- signed `b>>3`: `srai rd,a1,3`; signed `b/8`: if `b<0`, add 7 then `srai`.
- `pow(2,a)`: `addi rd,x0,1; sll rd,rd,a0`.
- `a=(b>=c)`: `slt a0,a1,a2; xori a0,a0,1` or compare reversed carefully.
- `b*61`: `(b<<6)-(b<<2)+b`.
- RV32I lacks `mul/div` unless M extension; software multiply uses shift-add loop.

## 3.6 Exceptions / Interrupts

- Trap transfers control to handler; handler saves needed architectural state, handles cause, restores, returns.
- Illegal instruction: e.g. RV32IM binary using `mul` on RV32I core.
- Microarchitectural state is not saved; caches/BHT/BTB/pipeline state can refill/relearn.

## 3.7 ISA Design Issues / Quiz Traps

- 128 GPRs? Usually no: slower regfile, more hardware, wider instruction fields, more save/restore/context-switch overhead; arrays/structs still in memory.
- FMA R4 uses 3 sources + 1 dest. 3-operand alternative `rd = rs1*rs2 + rd` preserves dot product but breaks regularity because `rd` is also source.
- Post-increment load is rejected: needs 2 write ports and makes `rs1` both source and destination.
- RISC-V has no separate call/jump; `JAL/JALR` + `rd=x0` handles jump, `rd=ra` handles call.
- GDB/Bomb Lab: `info registers`/`info registers a0` inspect regs; `x/d addr` examines memory; `a0-a7` are caller-saved and may change across calls.
- Bomb Lab goal: infer correct inputs without exploding; a bomb binary is not guaranteed to run on every RISC-V platform/ABI.
