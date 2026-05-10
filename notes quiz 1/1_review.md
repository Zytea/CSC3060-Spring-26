# Lec 1: Introduction

## Exam Facts

- ==**Computer system**==: **hardware + system software** that work together to run application programs.
- ==**Computer architecture**==: how ISA/microarchitecture/system design use transistors to deliver performance: multiplier/divider, pipeline, superscalar, OoO, multicore, caches, SIMD/vector.
- ==**Bits + context**==: the same bits may be an integer, FP value, instruction, address, character bytes, or media data.
- 128 all-zero bits may be two 64b integer zeros, four fp32 `+0.0`, one fp128 `+0.0`, or something else by context; it is **not** ASCII `"0000"`.
- ASCII character `'0'` = `0x30`; C string `"0000"` bytes = `30 30 30 30 00`.
- Compilation pipeline: **preprocess -> compile -> assemble -> link**.
- A relocatable `.o` is **not executable**: external symbols/addresses may need relocation.
- Linker jobs: **symbol resolution + relocation + library handling**.
- Common link errors: undefined reference, multiple definition, wrong static-library order.
- OS abstractions: **processes, virtual memory, files**.
- ==**Amdahl's Law**== limits speedup by the unimproved fraction.

## 1. Information is Bits + Context

Memory is usually byte-addressed: 1 byte = 8 bits. A pointer value is the virtual address of the first byte of an object; its type tells the compiler how to interpret the bytes.

| Bit pattern | Possible interpretation |
|---|---|
| all 0 bits | integer 0, FP `+0.0`, NUL byte, invalid/legal instr depending on ISA |
| `0x30` | ASCII `'0'`, not numeric zero |
| `0x00000013` in RISC-V | `addi x0,x0,0` (`nop`) |
| same 4 bytes | `int`, `float`, instr, pointer fragment, struct field |

> [!IMPORTANT]
> Never identify a bit pattern without interpretation context. Quiz traps often ask whether all-zero bits are a string of ASCII zeros or a valid value in every FP format.

## 2. Program Compilation: 4 Phases

![](assets/1.2.png)

| Phase | Tool | Input -> output | Main job |
|---|---|---|---|
| Preprocess | `cpp`, `gcc -E` | `.c -> .i` | expand `#include`, macros, conditional compilation, remove comments |
| Compile | `cc1`, `gcc -S` | `.i -> .s` | parse, type/semantic check, optimize, generate assembly |
| Assemble | `as`, `gcc -c` | `.s -> .o` | encode instrs, build `.symtab`, emit relocation records |
| Link | `ld`, `gcc` driver | `.o + libs -> executable` | resolve symbols, relocate addresses, merge sections, add runtime startup/libs |

Common commands:

```bash
gcc -E hello.c -o hello.i
gcc -S hello.i -o hello.s
gcc -c hello.s -o hello.o
gcc hello.o -o hello
gcc hello.c -o hello
```

### 2.1 Assembly and Relocation Example

Source:

```c
int add(int a, int b) { return a + b; }
int main() { return add(3,4); }
```

Possible RISC-V assembly:

```asm
add:
    add a0,a0,a1
    ret

main:
    li  a0,3
    li  a1,4
    jal ra,add
    ret
```

Assembler encodes known instrs directly:

```asm
add a0,a0,a1
0000000 01011 01010 000 01010 0110011
0x00b50533
```

But `jal ra,add` may not know final address yet. The `.o` contains:

| Section / record | Purpose |
|---|---|
| `.text` | machine code with placeholders if needed |
| `.symtab` | symbols such as `add`, `main` |
| `.rel.text` / `.rela.text` | relocation records saying where linker must patch code |
| ELF header | object-file metadata |

> A `.o` file is not a runnable program: start address, final symbol addresses, library code, and some relocation patches are unresolved.

### 2.2 Linker Errors

| Symptom | Typical cause | Fix |
|---|---|---|
| `undefined reference to f` | declared/called `f`, no definition found | compile/link file that defines `f`; add correct library |
| `multiple definition of x` | global `x` defined in more than one `.o` | one definition; use `extern` declarations in headers |
| math function unresolved | forgot math library | `gcc main.o -lm` |
| static library unresolved | library appears before object needing it | put library after objects: `gcc main.o -lfoo` |

### 2.3 Static vs Dynamic Libraries

| | Static library `.a` | Shared library `.so` / `.dll` |
|---|---|---|
| When linked | copied into executable at link time | loaded at load time or run time |
| Executable size | larger | smaller |
| Runtime dependency | less | needs compatible shared lib |
| Update library | relink executable | can update library separately if ABI compatible |
| Linker issue | left-to-right archive scan order matters | dynamic loader resolves/imports symbols |

## 3. Why Compilation Knowledge Matters

Understanding compilation lets you answer performance and correctness questions from generated code, not source syntax.

| Source-level question | Real deciding factor |
|---|---|
| Is `switch` always faster than `if`? | no; dense cases may become jump table, sparse cases become compare/branch chain |
| What is call overhead? | args, `jal/jalr`, saving `ra`, saving live regs, stack frame, return |
| Why `(a+b)+(c+d)` may be faster than `(((a+b)+c)+d)`? | exposes parallel independent adds / shorter dependence chain |
| Why `restrict` helps `memcpy`-like code? | compiler can assume no aliasing, enabling vectorization/reordering/register allocation |
| Why `-O0` is slow? | disables many optimizations: inlining, constant folding, DCE, CSE, LICM, scheduling |

Security reason: stack stores local data, saved regs, old frame pointer, and return address. Buffer overflow or bad pointer writes can corrupt control flow.

## 4. Processors Interpret Instructions Stored in Memory

The shell is a command-line interpreter:

```bash
./hello
hello, world
```

The processor executes machine instructions in `hello`: bytes are loaded from disk to memory, instructions update registers/memory/I/O, and output bytes reach the display/terminal.

### 4.1 Hardware Organization

| Component | Role |
|---|---|
| CPU | executes instructions; contains PC, register file, ALU, control, bus interface |
| PC | register holding address of next instruction |
| Register file | small named storage in CPU |
| ALU | arithmetic/logic operations |
| Main memory | stores data and instructions |
| Bus | moves address/data/control signals |
| I/O bridge | translates between CPU/memory bus and I/O bus |
| I/O devices | keyboard, display, disk, network |

Basic instruction cycle:

1. Fetch instr from memory at `PC`.
2. Decode opcode/fields.
3. Execute: load, store, ALU op, branch/jump.
4. Write back result if needed.
5. Update `PC`.

### 4.2 Running `hello`

![](assets/1.4.2.png)

High-level flow:

1. Shell reads command from keyboard.
2. OS loads executable from disk to memory.
3. CPU starts executing at program entry.
4. Program copies string bytes through memory/registers.
5. OS/device driver sends output to display/terminal.

## 5. Caches Matter

Computers spend much time moving bytes. Caches exploit locality:

| Locality | Meaning | Example |
|---|---|---|
| Temporal | recently used item likely reused soon | loop instrs, repeated variable access |
| Spatial | nearby addresses likely used soon | array scan, sequential instr fetch |

Cache hierarchy is critical because CPU is much faster than DRAM/disk.

## 6. Storage Devices Form a Hierarchy

| Level | Storage | Key property |
|---|---|---|
| L0 | registers | smallest, fastest, most expensive |
| L1 | L1 cache SRAM | cache lines from L2 |
| L2 | L2 cache SRAM | cache lines from L3 |
| L3 | L3 cache SRAM | cache lines from memory |
| L4 | main memory DRAM | disk blocks cached in RAM |
| L5 | local disk/SSD | persistent local files |
| L6 | remote storage | largest, slowest, cheapest |

Trend downward: larger capacity, slower access, lower cost per byte.

## 7. OS Manages Hardware

OS roles:

- resource manager: CPU time, memory, I/O devices, network.
- controller/protection: privilege, isolation, scheduling, security.
- abstraction provider: processes, virtual memory, files.

Applications request OS service through **system calls**, which perform controlled privilege transitions.

### 7.1 Three OS Abstractions

| Abstraction | What it virtualizes | Illusion |
|---|---|---|
| Process | CPU + address space | program seems to have its own CPU/memory |
| Virtual memory | physical memory/disk | each process has private contiguous address space |
| File | I/O devices | every I/O object is a byte stream |

### 7.2 Processes

==**Process**==: OS abstraction for a running program.

- Context: state needed to stop/resume process, e.g., PC, regs, flags, address-space info.
- Context switch: OS saves one process context and restores another.
- On single core, context switches create concurrency, not true parallel execution.

### 7.3 Threads

==**Thread**==: execution unit inside a process. Threads in the same process share code/global data/address space but have separate execution state such as PC/registers/stack.

| Processes | Threads |
|---|---|
| stronger isolation | lower overhead |
| slower communication | fast shared-memory communication |
| separate address spaces | share address space |

### 7.4 Virtual Memory

==**Virtual memory**==: abstraction giving each process the illusion of exclusive main memory.

Key facts:

- each process has its own virtual address space.
- kernel occupies protected high address region.
- page 0 is usually unmapped to catch NULL dereference.
- RAM is a cache for pages whose backing store may be disk.
- different virtual pages can map to the same physical page, e.g., shared libraries.
- VM supports protection, sharing, relocation, and multiprogramming.

### 7.5 Files

==**File**==: sequence of bytes modeling I/O devices and persistent data.

Unix I/O uses a small interface: `open`, `close`, `read`, `write`, `lseek`.

## 8. Networks

Networks let computer systems communicate. From a program view, remote data can often be treated like I/O through files/sockets, with much larger latency and failure modes.

## 9. Important Themes

### 9.1 Amdahl's Law

If fraction $\alpha$ of old time is improved by factor $k$:

$$
T_{new} = (1-\alpha)T_{old} + \frac{\alpha T_{old}}{k}; \quad
\text{Speedup}=\frac{1}{(1-\alpha)+\frac{\alpha}{k}} \le \frac{1}{1-\alpha}
$$

> Example: 90% improvable, target speedup `4x`: `4 = 1/(0.1+0.9/k)` -> `k=6`.

### 9.2 Concurrency and Parallelism

| Term | Meaning |
|---|---|
| Concurrency | multiple activities in progress; may be time-sliced |
| Parallelism | multiple activities physically execute at same time to improve speed |

Parallelism implies concurrency; concurrency does not imply parallelism.

### 9.3 ILP, DLP, SIMD

| Term | Meaning |
|---|---|
| ILP | instruction-level parallelism: overlap/multiple instrs from one thread, e.g., pipeline, superscalar, OoO |
| DLP | data-level parallelism: same operation across many data items |
| SIMD | single instruction, multiple data; vector/SIMD units exploit DLP |
| GPU | many-lane throughput machine exploiting massive DLP |
