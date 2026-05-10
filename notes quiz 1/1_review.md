# Chapter 1: Introduction

## Exam Facts

- ==**Computer system**==: **hardware + system software** that work together to run application programs.
- ==**Computer architecture / ISA**==: **interface between software and hardware**.
- ==**ABI**==: **ISA + OS system calls + calling convention**; decides binary compatibility.
- ==**Bits + context**==: bits have meaning only under an interpretation.
- **Memory is byte-addressable**: each address names 1 byte.
- **No memory is fast + large + cheap**; hierarchy exists because of this tradeoff.
- Compilation pipeline: **`.c -> .i -> .s -> .o -> executable`**; **loading is not compilation**.
- Interrupt/exception resume requires **architectural state**: PC, registers, status/control state.
- OS abstractions: **process, virtual memory, file**.
- **Program = passive executable file; process = active execution**.
- Threads share **code/global data/heap/open files**; each thread owns **stack + PC + registers**.
- Cache works because of **temporal locality + spatial locality**.
- Amdahl: speedup is limited by the **serial/unimproved fraction**.

## 1.1 Information is Bits + Context

==**Information**==: **bits + context**; the same bits may be `int`, FP, instruction, address, chars, array/struct field, media data, etc.
- `0x00000000`: may be `int 0`, IEEE FP `+0.0`, address `0`, instruction bits, or padding.
- Character `'0'` is `0x30`, so string `"0000"` is `0x30 0x30 0x30 0x30`, not all-0 bytes.
- 128 all-0 bits can be **four single-precision `+0.0`** values.
- Quiz trap: do not claim 128 all-0 bits is one quad FP value unless the format is specified.
> [!IMPORTANT]
> A bit string has no fixed type; always ask **which format / ISA / context** interprets it.

## 1.2 Program Compilation: 4 Phases

==**Compilation system**==: translates source code into an **executable object file**.

| Phase | I/O | Work |
|---|---|---|
| **Preprocess** | `.c -> .i` | expand `#include`, macros, `#ifdef`; remove comments |
| **Compile** | `.i -> .s` | parse, type-check, optimize, generate assembly |
| **Assemble** | `.s -> .o` | assembly -> relocatable machine code |
| **Link** | `.o + libs -> exe` | resolve symbols; relocate addresses |

Commands: `gcc -E`, `gcc -S`, `gcc -c`, `gcc hello.o -o hello`; compilation tools are preprocessor/compiler/assembler/linker, not OS/ChatGPT.

> [!IMPORTANT]
> **Loading** happens when OS starts an executable; it is not one of the 4 compilation phases.

### Linker Knowledge

- `undefined reference`: symbol used but no definition linked -> add implementation/library.
- `multiple definition`: same global symbol defined >1 time -> 1 definition, `extern` elsewhere.
- library order: linker scans left to right -> put libraries **after** objects that need them.
- static library: code copied into executable, larger exe, less shared-library runtime dependence.
- dynamic library: mapped/loaded at runtime, smaller exe, needs ABI-compatible shared library; update can work if ABI-compatible.

## 1.3 It Pays to Understand Compilation Systems

**Generated machine code matters more than C syntax.**
- `switch`: not always faster; dense cases may use jump table, sparse cases use branch chain/tree.
- function call overhead: argument passing, save/restore registers, stack frame, jump/return.
- `(a+b)+(c+d)` may be faster than `(((a+b)+c)+d)`: shorter dependency chain, more parallel adds.
- FP trap: FP addition is not associative; reassociation can change result.
- ==**`restrict`**==: pointers **do not alias**, enabling vectorization, reordering, fewer reloads.
- `-O`: enables inlining, constant folding, dead-code removal, loop optimization; performance loss without it may be **2x-20x**.
- stack/security: stack stores **locals, saved registers, return address**; unsafe writes can overwrite control info.

## 1.4 Processors Read and Interpret Instructions in Memory

### 1.4.1 Hardware Organization

Main components: **CPU, main memory, I/O devices, buses/interconnect, I/O bridge**.
- CPU: **PC** = next-instruction address; **register file** = small fast word storage; **ALU** = arithmetic/logic.
- Instruction cycle: **fetch -> decode -> execute -> update architectural state**.
- Execution ops: load, store, operate, branch, jump.
> [!IMPORTANT]
> To resume after interrupt/exception, save **architectural state**, not cache contents or open files.

### 1.4.2 Running `hello`

Path: user types `./hello` -> shell makes **system call** -> OS creates process and loads executable -> CPU executes `main` -> bytes of `"hello, world\n"` move memory -> registers -> output device.

==**Shell**==: **user-level command-line interpreter**, not kernel.

==**DMA**==: bulk I/O transfer directly between device and memory, **without sending every byte through CPU**.

## 1.5 Caches Matter

==**Caches**==: small fast storage for data/instructions likely to be used soon.
- ==**Temporal locality**==: recently used item likely reused soon, e.g. loop instruction/repeated variable.
- ==**Spatial locality**==: nearby item likely used soon, e.g. sequential array traversal.
- Large stride usually hurts spatial locality and wastes cache-block bytes.
> [!IMPORTANT]
> Caches work because real programs have **temporal + spatial locality**.

## 1.6 Storage Devices Form a Hierarchy

==**Memory hierarchy**==: **each level acts as a cache for the next lower level**.
- Order: **registers -> L1/L2/L3 SRAM cache -> DRAM -> SSD/disk -> remote storage**.
- Trend downward: **larger, slower, cheaper per byte**; trend upward: **smaller, faster, more expensive**.
> [!IMPORTANT]
> A memory that is **fast, large, and inexpensive** is an exam trap.

## 1.7 OS Manages the Hardware

==**OS**==: **software layer between applications and hardware**.

Responsibilities: **resource allocation, scheduling, device control, protection/security, system-call interface**.

==**System call**==: **controlled transfer from user mode to kernel mode** to request OS service.

### 1.7.0 Three OS Abstractions

| Abstraction | Meaning | Exam Point |
|---|---|---|
| ==**Process**== | running program | illusion of exclusive machine use |
| ==**Virtual memory**== | memory + disk-backed address space | private address space per process |
| ==**File**== | I/O device/data | byte-stream interface |

Virtualization: 1 CPU -> many processes; 1 memory -> many virtual address spaces; devices -> files.

### 1.7.1 Processes

==**Process**==: OS abstraction for **a running program**.
- program = passive executable file; process = active execution with runtime state.
- single-core: concurrent processes are **interleaved** by context switching; multicore: may run **in parallel**.
- each process has its own **virtual address space**.
- ==**Context**==: state needed to stop/resume execution: **PC, registers, status/control state, memory-management state**.

### 1.7.2 Threads

==**Thread**==: **execution unit within a process**.
- shared in same process: **code/text, global data, heap, open files, address space**.
- private per thread: **stack, PC, registers, execution path**.
- process: stronger isolation, separate address space, higher communication cost.
- thread: lower overhead, faster communication, race-prone without synchronization.
> [!IMPORTANT]
> CMU-style trap: every thread has its own **stack**.

### 1.7.3 Virtual Memory

==**Virtual memory**==: each process appears to have **exclusive use of main memory**.
- each process has its own **virtual address space**; same virtual address can exist in different processes without conflict.
- kernel memory is protected; page containing address `0` is normally unmapped for null dereference.
- heap usually grows up; stack usually grows down.
- physical memory acts as a cache for disk-backed virtual pages.
- benefits: **private address spaces, protection, sharing, address space > physical RAM, multiprogramming**.
- ==**TLB**==: caches **virtual-to-physical address translations**; it is a performance optimization, not the main VM benefit.

### 1.7.4 Files

==**File**==: **a sequence of bytes**.

Unix models many I/O devices as files: **disk files, keyboard, display, sockets, pipes**. Core calls: `open`, `close`, `read`, `write`, `lseek`.

## 1.8 Systems Communicate with Networks

==**Network**==: **another I/O device**.
- Remote execution adds network I/O between local client and remote process.
- Telnet is insecure; **SSH encrypts the session**.

## 1.9 Important Themes

### 1.9.1 Amdahl's Law

If fraction $\alpha$ of old time is improved by factor $k$:

$$
T_{new}=(1-\alpha)T_{old}+\frac{\alpha T_{old}}{k}; \quad \text{Speedup}=\frac{1}{(1-\alpha)+\frac{\alpha}{k}}\leq\frac{1}{1-\alpha}
$$

If serial/unimproved fraction is $\beta$, max speedup $=1/\beta$.
> Example: 90% improvable, target `4x`: $4=\frac{1}{0.1+0.9/k}\Rightarrow k=6$.

### 1.9.2 Concurrency and Parallelism

| Term | Meaning | Example |
|---|---|---|
| ==**Concurrency**== | **multiple activities in progress** | time-sharing on 1 core |
| ==**Parallelism**== | **simultaneous execution** for speed | 4 cores run 4 tasks |

**Parallelism implies concurrency; concurrency does not imply parallelism.**

### 1.9.3 ILP, DLP, SIMD

| Term | Meaning | Hardware/Technique |
|---|---|---|
| ==**ILP**== | independent instructions from 1 thread overlap | pipeline, superscalar, OoO |
| ==**DLP**== | same op on many data items | vector units, GPUs |
| ==**SIMD**== | Single Instruction, Multiple Data | vector/SIMD instructions |

## 1.10 Summary

System performance/correctness depends on **bits+context, compilation/linking, CPU execution, locality/memory hierarchy, OS abstractions, and limited speedup (Amdahl)**.
