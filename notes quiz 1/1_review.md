# Lec 1: Introduction

## Exam Facts

- ==**Computer system**==: **HW + system software** running application programs.
- ==**Computer architecture / ISA**==: SW/HW interface.
- ==**ABI**== = **ISA + OS syscalls + calling convention** → binary compatibility.
- Compilation 4 phases: **`.c → .i → .s → .o → exe`** (`gcc -E/-S/-c/link`); ==**loading is NOT a phase**==.
- System programs: preprocessor, compiler, assembler, linker. NOT a system program: **ChatGPT**.
- Memory **byte-addressable**.
- Architectural state on interrupt: **PC + regs + status/control** (NOT cache, files, BHT/BTB).
- 3 OS abstractions: **process, virtual memory, file**.
- Program = passive file; ==**process = active execution**==.
- Threads share **code+globals+heap+open files+address space**; private = **stack+PC+regs**.
- Caches work because of ==**temporal + spatial locality**==.
- Amdahl: max speedup $\le 1/(1-\alpha) = 1/\beta$ ($\beta$ = serial fraction).
- ==**Parallelism ⇒ concurrency**==; concurrency ⇏ parallelism.

## 1. Information is Bits + Context

- A bit pattern may represent (e.g., 32b `0x0...0`):
    - variables: `int 0`, `float +0.0`, addr 0, NOP-ish instr, padding
    - 128 all-0 bits = **4 SP +0.0** or 2 DP zeros; **NOT necessarily one quad-FP** without format
- ASCII = **7b**, ext-ASCII 8b. `'0' = 0x30`, so `"0000"` = `30 30 30 30` ≠ all-zero bytes.
> [!NOTE] $\forall$ format, never claim a bit pattern's type without context.

## 2. Program Compilation: 4 Phases

| Phase | I/O | Tool | Work |
|---|---|---|---|
| Preprocess | `.c→.i` | `cpp` / `gcc -E` | `#include`, macros, `#ifdef` |
| Compile | `.i→.s` | `cc1` / `gcc -S` | parse, type-check, opt, emit asm |
| Assemble | `.s→.o` | `as` / `gcc -c` | asm → relocatable machine code |
| Link | `.o + libs → exe` | `ld` / `gcc` | resolve symbols, relocate |

> [!IMPORTANT] **Loading** = OS maps exe into mem; NOT one of the 4 phases.

> `.o` not runnable: `jal` target unfilled, no entry point.

### 2.1 Linker errors

- ==**Undefined reference**==: declared, not defined → add impl/lib.
- ==**Multiple definition**==: same global in >1 `.o` → 1 def, others `extern`.
- ==**Library order**==: scan **left→right**, libs **after** their users.

### 2.2 Static `.a` vs Dynamic `.so`

- Static: copied into exe at link time → larger exe, no runtime dep, lib update needs recompile.
- Dynamic: mapped at load/run time → smaller exe, ABI-compatible update works without recompile.

## 3. It Pays to Understand Compilation

- `switch` not always faster: dense → jump table; sparse → branch chain.
- Function call overhead: arg pass, save/restore, frame, jump/return → mitigate via **inlining**.
- `(a+b)+(c+d)` faster than `(((a+b)+c)+d)`: shorter dep chain, more **ILP**.
> FP `+` not associative; reassoc may change result.
- ==**`restrict`**==: pointers don't alias → enables vectorization, reordering, fewer reloads (e.g., `memcpy`).
- `-O` flag enables inlining/CSE/DCE/loop opts; without it loss may be **2-20×**. `-O0/-O1/-O2/-O3/-Os/-O3 -flto`.
- Stack: **locals + saved regs + return addr**; buffer overflow → return-addr hijack.

## 4. Processors Read and Interpret Instructions

### 4.1 Hardware Organization

Components: **CPU, main memory, I/O devices, buses, I/O bridge**.

- ==**Bus**==: shared protocol+wires (Address / Data / Control).
- **CPU**: ==**PC**== (next-instr addr), **regfile**, **ALU**.
- **Bus interface**: protocol conversion, arbitration, buffering. **I/O bridge**: translates protocols.

Instr cycle: ==**Fetch → Decode → Execute → Update PC**==. Execute ops: **load/store/op/branch/jump**.

> [!IMPORTANT] On interrupt save **architectural state** (PC, regs, CSRs) only — micro-arch (cache/BHT/pipeline) refills.

### 4.2 Running `hello`

`./hello` → **shell** syscall → OS creates process & loads exe → CPU runs `main` → mem→regs→display.

- ==**Shell**==: user-level CLI interpreter (NOT kernel).
- ==**DMA**==: bulk I/O between device↔mem, **bypassing CPU per-byte**.

## 5. Caches Matter

==**Cache**==: small fast store for likely-reused data/instr.

- ==**Temporal locality**==: recently used → reused soon (loop body).
- ==**Spatial locality**==: nearby data → used soon (sequential array). Large stride hurts both.

## 6. Storage Devices Form a Hierarchy

==Registers → L1/L2/L3 SRAM → DRAM → SSD/HDD → remote==. Down: larger/slower/cheaper. Each level caches the next.
> [!IMPORTANT] No memory is **fast + large + cheap** — hierarchy gives only the *illusion*.

## 7. OS Manages Hardware

==**OS**==: SW layer between apps & HW. Jobs: resource alloc, scheduling, device control, protection, syscall iface.
==**System call**==: controlled user→kernel switch.

### 7.1 Three OS Abstractions (Virtualization)

- ==**Process**==: 1 CPU → many running programs (time virt.).
- ==**Virtual memory**==: 1 phys mem → many private spaces (space virt.).
- ==**File**==: byte-stream interface for all I/O (device virt.).

### 7.2 Processes

==**Process**==: OS abstraction for a running program; private VAS; ==**context**===PC+GPRs+status+mem-mgmt state.
- 1 core: concurrent via **context switching**; multi-core: real parallelism.

### 7.3 Threads

==**Thread**==: lightweight execution unit *within* process.
- Shared: **code, globals, heap, open files, address space**.
- Private: ==**stack, PC, registers**==.
- Process: high isolation/secure; Thread: low overhead/fast comm/race-prone.
> [!IMPORTANT] Every thread has its **own stack** (CMU trap).

### 7.4 Virtual Memory

==**VM**==: each process appears to have exclusive main memory.
- Same VA in different processes don't conflict (separate page tables).
- Kernel high; **VA 0's page (4KB) unmapped** → catches NULL deref.
- Heap ↑, stack ↓. **RAM = cache for VM** (pages from disk).
- Benefits: **private space, protection, sharing (libs/COW), VA > phys RAM, multiprogramming**.
- ==**TLB**== caches VA→PA (perf, NOT a main VM benefit).

### 7.5 Files

==**File**==: sequence of bytes; unifies disk/keyboard/display/sockets/pipes. Unix I/O: `open/close/read/write/lseek`.

## 8. Systems Communicate with Networks

Network = another I/O device. Telnet plaintext; **SSH encrypted**.

## 9. Important Themes

### 9.1 Amdahl's Law

If $\alpha$ of $T_{old}$ improved by $k$:

$$T_{new}=(1-\alpha)T_{old}+\frac{\alpha T_{old}}{k};\quad \text{Speedup}=\frac{1}{(1-\alpha)+\alpha/k}\le \frac{1}{1-\alpha}$$

> Serial fraction $\beta$ ⇒ max speedup $=1/\beta$. Quizzes don't go beyond this formula.

### 9.2 Concurrency vs Parallelism

- ==**Concurrency**==: multiple activities in progress (1-core time-share).
- ==**Parallelism**==: concurrency *for speed* (4 cores, 4 tasks).
- **Parallelism ⇒ concurrency**; reverse not true.

### 9.3 ILP, DLP, SIMD

- ==**ILP**==: indep instrs in 1 thread overlap → pipeline, superscalar, OoO.
- ==**DLP**==: same op on many data → vector, GPU.
- ==**SIMD**==: Single Instr Multiple Data → vector instrs.
