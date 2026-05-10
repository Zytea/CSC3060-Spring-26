# Lec 1: Introduction

## Exam Facts

- ==**Computer system**==: hardware + system software that run application programs.
- ==**Computer architecture**==: quiz-simple answer = **interface between software and hardware**; broader = ISA + microarchitecture + system design.
- System programs: OS, compiler, assembler, linker, loader. Application example: ChatGPT/browser/game.
- ==**Bits + context**==: same bits can be int, FP, instr, address, char bytes, struct fields.
- 128 all-0 bits can be integer zeros or fp32/fp128 `+0.0`; **not** ASCII `"0000"` (`0x30` bytes).
- `gcc` phases: **preprocess -> compile -> assemble -> link**. Loading is **not** part of `gcc` compilation phases.
- `.o` is relocatable, not executable: some symbol addresses/calls need linker relocation.
- Linker jobs: **symbol resolution + relocation + section merging + library handling**.
- OS abstractions: **process, virtual memory, file**.
- Memory hierarchy illusion: **fast + large + cheap** memory.
- Amdahl: speedup is limited by the unimproved fraction.

## 1. Information is Bits + Context

- Memory is byte-addressed; 1 byte = 8 bits.
- Pointer value = virtual address of first byte; pointer type tells how many bytes/how to interpret.
- A bit pattern has no single meaning without context:

| Bits | Possible meaning |
|---|---|
| `0x00000000` | int `0`, fp32 `+0.0`, NULs, RISC-V `illegal?` depends on ISA |
| `0x00000013` | RISC-V `addi x0,x0,0` (`nop`) |
| `0x30` | ASCII `'0'`, not numeric 0 |

> [!IMPORTANT]
> All-zero bits do **not** mean ASCII zeros. `"0000"` bytes are `30 30 30 30 00`.

## 2. Program Compilation: 4 Phases

| Phase | Tool | Input -> output | Main job |
|---|---|---|---|
| Preprocess | `cpp`, `gcc -E` | `.c -> .i` | expand `#include`, macros, `#if`, remove comments |
| Compile | `cc1`, `gcc -S` | `.i -> .s` | parse/typecheck/optimize, generate assembly |
| Assemble | `as`, `gcc -c` | `.s -> .o` | encode instrs, emit symbols + relocation entries |
| Link | `ld` via `gcc` | `.o + libs -> exe` | resolve symbols, relocate, merge sections |

```bash
gcc -E a.c -o a.i
gcc -S a.i -o a.s
gcc -c a.s -o a.o
gcc a.o b.o -o prog
```

### 2.1 Object / Link Quick Facts

Relocatable `.o` usually contains:

| Section | Use |
|---|---|
| `.text` | machine code |
| `.data` / `.bss` | initialized / zero globals/statics |
| `.symtab` | symbol definitions/references |
| `.rel.text`, `.rel.data` | places linker must patch |

Common linker errors:

| Symptom | Cause | Fix |
|---|---|---|
| `undefined reference` | definition not linked | add object/lib |
| `multiple definition` | duplicate strong global | one definition + `extern` declarations |
| `-lfoo` unresolved | static lib before user object | `gcc main.o -lfoo` |

## 3. Hardware Organization

### 3.1 Processor Interprets Instructions in Memory

Basic execution cycle:

```text
PC -> fetch instr -> decode -> execute/load/store/branch -> writeback -> next PC
```

| Component | Role |
|---|---|
| PC | address of next instr |
| Register file | small fast CPU storage |
| ALU | arithmetic/logic/address calc |
| Main memory | stores instrs + data |
| Bus/I-O bridge | moves data between CPU, memory, devices |

### 3.2 Running `hello`

```text
shell reads command
-> OS loads executable from disk to memory
-> CPU starts at entry
-> program/OS writes bytes to terminal
```

## 4. Caches and Storage Hierarchy

| Level | Example | Property |
|---|---|---|
| L0 | registers | fastest, smallest |
| L1/L2/L3 | SRAM caches | cache lines from lower level |
| L4 | DRAM | main memory |
| L5/L6 | disk/remote | persistent, slow |

Locality:

| Type | Meaning | Example |
|---|---|---|
| temporal | reused soon | loop instrs, hot variable |
| spatial | nearby used soon | array scan, sequential fetch |

> [!IMPORTANT]
> Memory hierarchy gives the illusion of a memory that is **fast, large, and inexpensive**.

## 5. OS Manages Hardware

| Abstraction | Virtualizes | Illusion |
|---|---|---|
| process | CPU + address space | program owns CPU/memory |
| virtual memory | DRAM/disk/pages | private contiguous address space |
| file | I/O devices/data | byte stream |

- ==**Process**==: running program + context (`PC`, regs, address-space state, OS metadata).
- ==**Thread**==: execution stream in a process; shares address space, has own PC/regs/stack.
- System calls enter kernel mode for protected OS services.

## 6. Important Themes

### 6.1 Amdahl's Law

If fraction $\alpha$ of old time is improved by factor $k$:

$$
T_{new}=(1-\alpha)T_{old}+\frac{\alpha T_{old}}{k};\quad
Speedup=\frac{1}{(1-\alpha)+\alpha/k}\le\frac{1}{1-\alpha}
$$

> Example: 90% improvable, target `4x`: $4=1/(0.1+0.9/k)\Rightarrow k=6$.

### 6.2 Concurrency / Parallelism / ILP / DLP

| Term | Meaning |
|---|---|
| concurrency | multiple activities in progress; may be time-sliced |
| parallelism | actually execute at same time |
| ILP | multiple instrs from one thread overlap/issue |
| DLP | same op over many data elements |
| SIMD/vector | one instr, multiple data lanes |

Parallelism implies concurrency; concurrency does not imply parallelism.
