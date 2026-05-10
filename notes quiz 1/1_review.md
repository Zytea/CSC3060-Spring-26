# Lec 1: Introduction

## Exam Facts (one-glance must-know)

- ==**Computer system**== = **hardware + system software** that work together to run application programs.
- ==**Computer architecture / ISA**== = **interface between software and hardware**.
- ==**ABI**== = **ISA + OS system calls + calling convention** → decides binary compatibility (whether a binary runs on a system).
- ==**Information = bits + context**==. Same bit pattern can be int / FP / instr / address / chars.
- **Memory is byte-addressable** (1 address = 1 byte); some machines use word/dword addressing.
- ASCII = **7 bits**; extended ASCII = 8 bits. `'0' = 0x30`.
- **No memory is fast + large + cheap** (CMU trap); hierarchy exists *because* of this tradeoff.
- Compilation: **`.c → .i → .s → .o → exe`** (`gcc -E / -S / -c / link`). **Loading is NOT compilation.**
- System tools: preprocessor, compiler, assembler, linker. **Not** a system program: ChatGPT.
- Architectural state saved on interrupt: **PC + registers + status/control state** (NOT cache, NOT files).
- Three OS abstractions: **process, virtual memory, file**.
- Program = passive file; **process = active execution**.
- Threads share **code/text + global data + heap + open files + address space**; each thread owns **stack + PC + registers**.
- Caches work because of **temporal + spatial locality**.
- Amdahl: max speedup limited by **serial fraction** $\beta$, $\le 1/\beta$.
- **Parallelism ⇒ concurrency**, but concurrency does NOT ⇒ parallelism.

## 1.1 Information is Bits + Context

- Memory unit: **byte (8b)**, sometimes word (32b) / double word (64b).
- Same bits, different meanings depending on **format/ISA/context**:

| Bit pattern (32b) | Possible meaning |
|---|---|
| `0x00000000` | int 0, FP +0.0, address 0, NOP-style instr, padding |
| `0x30 0x30 0x30 0x30` | string `"0000"` (NOT all-zero bytes) |
| 128 all-0 bits | 4 × SP `+0.0`, **or** 2 × `long 0` (DP), but **not necessarily** one quad-FP unless format specified |

> [!IMPORTANT] CMU trap: do not claim a bit string has any specific type without context.

- ASCII: **7-bit**; extended ASCII: 8-bit. Char `'0' = 0x30`, so `"0000"` ≠ all-zero bytes.

## 1.2 Program Compilation: 4 Phases

| Phase | I/O | Tool | Work |
|---|---|---|---|
| **Preprocess** | `.c → .i` | `cpp` / `gcc -E` | expand `#include`, macros, `#ifdef`; strip comments |
| **Compile** | `.i → .s` | `cc1` / `gcc -S` | parse, type-check, optimize, emit asm |
| **Assemble** | `.s → .o` | `as` / `gcc -c` | asm → relocatable machine code |
| **Link** | `.o + libs → exe` | `ld` / `gcc` | resolve symbols, relocate addresses |

> [!IMPORTANT]
> **Loading** (OS maps exe into memory) is **NOT** one of the 4 phases. Quiz answer: D = "Loading" is not part of `gcc`.

> Example assembled `add a0,a0,a1` → `0x00B50533` (R-type, opcode `0110011`).
> `jal add` in `.o` has placeholder offset + relocation entry; **real offset filled at link time**.

> A `.o` is **NOT** runnable: jal target unfilled, no entry point assigned.

### Linker errors

- ==**Undefined reference**==: declared but no definition / forgot `-lm` etc. → add impl/lib.
- ==**Multiple definition**==: same global defined in >1 `.o` → 1 def, others `extern`.
- ==**Library order**==: linker scans **left → right**; put libs **after** objects that need them.

### Static vs Dynamic libs

| Static `.a` | Dynamic `.so` |
|---|---|
| copied into exe at link time | mapped at load/run time |
| larger exe, no runtime dep | smaller exe, needs ABI-compatible `.so` |
| update lib → must recompile | update lib (ABI-compatible) → exe still works |

## 1.3 It Pays to Understand Compilation

**Generated machine code matters more than C syntax.**

- `switch` is **not always** faster than `if-else`:
  - dense cases → jump table (~O(1))
  - sparse cases → branch chain/tree (≈ if-else)
- Function-call overhead: arg passing, save/restore regs, stack frame, jump/return → optimize via **inlining**.
- `(a+b)+(c+d)` faster than `(((a+b)+c)+d)`: **shorter dep chain, more parallel adds (ILP)**.
  - FP trap: FP `+` is **not associative**, reassociation may change result.
- ==**`restrict`**==: declares pointers do **not** alias → enables vectorization, reordering, fewer reloads.
  > Why `memcpy(restrict dst, restrict src, ...)` is much faster: no aliasing → SIMD allowed.
- `-O` flag: enables inlining, constant folding, DCE, loop opts. Without it, **2x–20x slowdown**.
  - `-O0` debug; `-O1`/`-O` basic; `-O2` more safe; `-O3` aggressive (loop/SIMD/unroll); `-Os` size; `-O3 -flto` cross-module / LTO.

### Stack security

- Stack stores **locals + saved regs + return address**.
- Buffer overflow / unsafe writes → can overwrite return addr → control-flow hijack.

## 1.4 Processors Read and Interpret Instructions

### 1.4.1 Hardware Organization

Components: **CPU, main memory, I/O devices, buses, I/O bridge**.

- ==**Bus**== = shared communication protocol + interconnect.
  - Address bus (where), Data bus (what), Control bus (read/write/control).
- **CPU**: PC + register file + ALU.
  - ==**PC**== = one-word reg holding address of *next* instruction.
  - ==**Register file**== = small set of named, fast, word-size registers.
  - ==**ALU**== = arithmetic/logic unit.
- **Bus interface**: protocol conversion, request arbitration, data buffering.
- **I/O bridge**: translates one bus protocol to another.

### Instruction cycle

**Fetch → Decode → Execute → Update PC** (architectural state).

Execute ops: **load, store, operate (ALU), branch, jump**.

> [!IMPORTANT] To resume after interrupt/exception, save **architectural state** only — NOT cache contents, NOT files, NOT BHT/BTB (those are micro-arch and can refill).

### 1.4.2 Running `hello`

`./hello` → **shell** issues syscall → OS creates process & loads exe → CPU runs `main` → bytes flow memory → register file → display.

- ==**Shell**== = user-level command-line interpreter (NOT kernel).
- ==**DMA**== = direct memory access; bulk I/O between device ↔ memory **bypassing CPU per-byte**.

## 1.5 Caches Matter

==**Cache**== = small fast storage for data/instructions likely to be reused.

- ==**Temporal locality**==: recently used → likely reused soon (e.g., loop body, repeated var).
- ==**Spatial locality**==: nearby data → likely used soon (e.g., sequential array).

> [!IMPORTANT] Caches work because real programs have **both** temporal + spatial locality.

- Large stride hurts spatial locality + wastes block bytes.

## 1.6 Storage Devices Form a Hierarchy

| Level | Storage | Trend |
|---|---|---|
| L0 | **Registers** | small / fast / expensive |
| L1 | L1 cache (SRAM) | ↓ |
| L2 | L2 cache (SRAM) | ↓ |
| L3 | L3 cache (SRAM) | ↓ |
| L4 | Main memory (DRAM) | ↓ |
| L5 | Local disk / SSD | ↓ |
| L6 | Remote storage | large / slow / cheap |

Each level **caches** the next-lower level.

> [!IMPORTANT] CMU trap: a memory that is **fast, large, AND inexpensive** does NOT exist; hierarchy only gives the *illusion*.

## 1.7 OS Manages Hardware

==**OS**== = software layer between apps and hardware.

Responsibilities: **resource alloc, scheduling, device control, protection/security, syscall interface**.

==**System call**== = controlled user→kernel mode switch to request OS service.

### 1.7.0 Three OS Abstractions (Virtualization)

| Abstraction | What it virtualizes |
|---|---|
| ==**Process**== | one CPU → many running programs (time virtualization) |
| ==**Virtual Memory**== | one phys mem → many private address spaces (space) |
| ==**File**== | many devices → uniform byte-stream interface (device) |

VM (Virtual Machine): one machine → many OSes simultaneously.

### 1.7.1 Processes

==**Process**== = OS abstraction for a running program.

- **Program** (passive `.exe` file) ≠ **process** (active execution + state).
- Single core: concurrent processes interleaved by **context switching**; multi-core: real parallelism.
- Each process has **own virtual address space**.
- ==**Context**== = state needed to stop/resume: **PC + GPRs + status/control + memory-mgmt state**.

### 1.7.2 Threads

==**Thread**== = lightweight execution unit *within* a process.

| Shared in same process | Private per thread |
|---|---|
| code/text, global data, heap, open files, address space | **stack, PC, registers**, execution path |

| Process | Thread |
|---|---|
| high isolation, secure, scalable | low overhead, fast comm, race-prone |

> [!IMPORTANT] CMU trap: **every thread has its OWN stack**.

### 1.7.3 Virtual Memory

==**Virtual memory**== = each process appears to have **exclusive use of main memory**.

- Same VA in different processes → no conflict (different page tables).
- High VA = kernel; **VA 0's page (4KB) unmapped** → catches NULL deref.
- Heap grows ↑, stack grows ↓.
- **RAM = cache for VM**: pages on disk, brought in on demand.
- Benefits: **private spaces, protection, sharing (shared libs/COW), VA > phys RAM, multiprogramming**.
- ==**TLB**== caches **VA→PA translations** (perf optimization, NOT a main VM benefit).

### 1.7.4 Files

==**File**== = sequence of bytes.

Unix models I/O as files: disk, keyboard, display, sockets, pipes. **Unix I/O syscalls**: `open / close / read / write / lseek`.

## 1.8 Systems Communicate with Networks

==**Network**== = "another I/O device" abstraction.

- Remote login: local client ↔ remote process via network I/O.
- Telnet sends plaintext; **SSH encrypts the session**.

## 1.9 Important Themes

### 1.9.1 Amdahl's Law

If fraction $\alpha$ of $T_{old}$ improved by factor $k$:

$$
T_{new}=(1-\alpha)T_{old}+\frac{\alpha T_{old}}{k};\quad
S=\frac{1}{(1-\alpha)+\alpha/k}\le \frac{1}{1-\alpha}
$$

Serial fraction $\beta$ → max speedup $= 1/\beta$.

> Example: 90% improvable, want 4×: $4=\frac{1}{0.1+0.9/k}\Rightarrow k=6$.
> 80% parallel, ∞ procs: max $=1/0.2=5$×.

**Lesson:** focus on the most time-consuming part; don't waste effort on rare paths.

### 1.9.2 Concurrency vs Parallelism

| Term | Meaning | Example |
|---|---|---|
| ==**Concurrency**== | multiple activities **in progress** | 1-core time-share |
| ==**Parallelism**== | concurrency for **speed** | 4 cores running 4 tasks |

> **Parallelism ⇒ concurrency**; concurrency does NOT ⇒ parallelism.

### 1.9.3 ILP, DLP, SIMD

| Term | Meaning | HW |
|---|---|---|
| ==**ILP**== | independent instrs from 1 thread overlap | pipeline, superscalar, OoO |
| ==**DLP**== | same op on many data items | vector units, GPUs |
| ==**SIMD**== | Single Instr Multiple Data | vector/SIMD instrs |

## 1.10 Summary

System correctness/perf depends on **bits+context, compilation/linking, execution, locality/hierarchy, OS abstractions, Amdahl limits**.
