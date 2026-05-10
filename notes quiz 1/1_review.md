# Lec 1: Introduction

## Exam Facts

- ==**Computer architecture**==: the **software/hardware interface** visible to programmers and compilers.
- ==**Computer system**==: **hardware + system software** cooperating to run application programs.
- ==**System programs**==: OS, compiler, assembler, linker, loader, shell. ChatGPT/browser/user apps are **not** system programs.
- ==**Bits + context**==: the same bit pattern may mean integer, FP, instruction, address, char data, etc.
- 128 all-0 bits may be two 64b integer 0s, four fp32 +0.0, one quad +0.0; **not** a string of ASCII `'0'` chars (`0x30`).
- `gcc` build phases: **preprocess -> compile -> assemble -> link**. **Loading is not part of gcc compilation**.
- Memory hierarchy illusion: **fast + large + cheap** memory.
- OS abstractions: ==**processes, virtual memory, files**==.
- Interrupt/resume must save **architectural state** (PC/registers/CSRs), not caches/files/all memory.
- Amdahl: optimize the common/high-time part; serial fraction limits parallel speedup.

## 1. Information is Bits + Context

==**Context**== decides how a byte sequence is interpreted.

- `0x00000000`: `int 0`, fp32 `+0.0`, address 0, part of an instruction, etc.
- C string `"0000"` bytes: `0x30 0x30 0x30 0x30 0x00`, **not** zero bytes.
- Machine code is just bytes; ABI/ISA tells the processor how to decode them.

> [!IMPORTANT]
> Do not answer from bit pattern alone. Ask: **type? ISA? data size? endian? encoding?**

## 2. Program Compilation: 4 Phases

| Phase | Tool-ish | Input -> output | Main work |
|---|---|---|---|
| **Preprocess** | `cpp`, `gcc -E` | `.c -> .i` | `#include`, `#define`, `#ifdef`, remove comments |
| **Compile** | `cc1`, `gcc -S` | `.i -> .s` | parse, semantic check, optimize, emit asm |
| **Assemble** | `as`, `gcc -c` | `.s -> .o` | encode machine instrs, build symbol/relocation info |
| **Link** | `ld`, `gcc` driver | `.o + libs -> executable` | symbol resolution + relocation + library handling |

> [!IMPORTANT]
> A relocatable `.o` is **not executable**: external labels/calls/data references may still need relocation.

### 2.1 Linking Errors

| Error | Cause | Fix |
|---|---|---|
| `undefined reference` | declared/called but no definition linked | add `.o`/library; implement function |
| `multiple definition` | same strong symbol defined in multiple files | one definition; others `extern` |
| library order error | static lib scanned too early | put library **after** users: `gcc main.o -lm` |

### 2.2 Static vs Dynamic Libraries

| | Static `.a` | Dynamic `.so` |
|---|---|---|
| When | copied at link time | loaded at load/runtime |
| Executable | larger, self-contained | smaller, needs runtime library |
| Update | relink/rebuild executable | replace shared lib |
| Typical benefit | no runtime dependency | memory sharing + security updates |

## 3. Why Compilation Knowledge Matters

- `switch` is not always faster: dense cases -> jump table; sparse/few cases -> branch chain.
- Function call overhead: pass args, save/restore regs, stack frame, jump/return. Small hot functions may be inlined.
- `(a+b)+(c+d)` may expose ILP vs left-chain `(((a+b)+c)+d)`.
- `restrict` tells compiler no alias -> more register allocation/vectorization/reordering.
- `-O0` can be **2x-20x** slower; `-O1/-O2/-O3` add increasingly aggressive optimization.
- Stack layout matters for security: local buffers near saved regs/return address -> overflow can hijack control flow.

## 4. Processors Interpret Instructions in Memory

### 4.1 Hardware Organization

| Component | Role |
|---|---|
| **Bus** | moves address/data/control info |
| **I/O bridge** | connects CPU/mem bus to I/O bus |
| **Main memory** | stores program instructions + data |
| **CPU** | PC + register file + ALU + control |
| **PC** | address of next instruction |

Instruction cycle: ==**fetch -> decode -> execute -> update PC**==.

### 4.2 Running `hello`

1. Shell reads command.
2. OS loads executable bytes from disk to memory.
3. CPU PC points to program entry; fetch/decode/execute instructions.
4. Data moves among memory, registers, I/O device.

> Computers spend much time **copying data**. This is why caches and locality dominate performance.

## 5. Caches Matter

- ==**Temporal locality**==: recently used item likely reused soon (loop instructions).
- ==**Spatial locality**==: nearby addresses likely used soon (array traversal).

## 6. Storage Devices Form a Hierarchy

==Registers -> L1/L2/L3 SRAM -> DRAM -> SSD/HDD -> remote storage==.

| Direction | Trend |
|---|---|
| Up | smaller, faster, more expensive/byte |
| Down | larger, slower, cheaper/byte |

> [!IMPORTANT]
> Memory hierarchy gives the **illusion** of a memory that is **fast, large, and inexpensive**.

## 7. OS Manages Hardware

OS roles: resource allocator, hardware controller, protection/security layer, service provider via **system calls**.

### 7.1 Three OS Abstractions

| Abstraction | What it virtualizes | Exam wording |
|---|---|---|
| **Process** | CPU + running program state | each program seems to own CPU |
| **Virtual memory** | memory address space | each process seems to own memory |
| **File** | I/O devices | all I/O as byte streams |

### 7.2 Processes

==**Process**==: OS abstraction for a running program.

- **Context**: state needed to resume a process (PC, registers, OS bookkeeping).
- **Context switch**: save current process context, restore another process.

### 7.3 Threads

==**Thread**==: execution unit inside a process.

- Threads in same process share code/global data/address space.
- Lower overhead than processes, but weaker isolation.

### 7.4 Virtual Memory

==**Virtual memory**==: each process sees a private virtual address space.

- Address 0 page is usually unmapped -> catches NULL dereference.
- Main memory acts as a **cache** for disk-backed virtual pages.
- Enables protection, sharing (shared libraries), and multiprogramming.

### 7.5 Files

==**File**==: sequence of bytes; Unix models I/O devices as files.

Common Unix I/O: `open`, `close`, `read`, `write`, `lseek`.

## 8. Systems Communicate with Networks

Network I/O is another file-like I/O path; a remote server can act like a storage/device source.

## 9. Important Themes

### 9.1 Amdahl's Law

If fraction $\alpha$ of old time is improved by factor $k$:

$$
T_{new}=(1-\alpha)T_{old}+\frac{\alpha T_{old}}{k};\quad
\text{Speedup}=\frac{1}{(1-\alpha)+\alpha/k}\le \frac{1}{1-\alpha}
$$

> If serial/unimproved fraction is $\beta$, max speedup is $1/\beta$.

### 9.2 Concurrency vs Parallelism

| Term | Meaning |
|---|---|
| ==**Concurrency**== | multiple activities logically in progress |
| ==**Parallelism**== | multiple activities physically run at same time to improve speed |

Parallelism implies concurrency; concurrency does **not** imply parallelism.

### 9.3 ILP, DLP, SIMD

- ==**ILP**==: multiple instructions from one thread overlapped/executed together (pipeline, superscalar, OoO).
- ==**DLP**==: same operation over many data elements.
- ==**SIMD/vector**==: one instruction operates on multiple data lanes.
