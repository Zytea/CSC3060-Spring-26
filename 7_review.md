# Lec 7: Linking

## Exam Facts

- ==**Standard Unix linker**==: ==**`ld`**==. (`gcc` is the compiler driver that invokes `ld`.) NOT `ln` (creates symlinks), NOT `link` (Windows).
- ==**Read detailed ELF info**==: ==**`readelf`**== (e.g., `readelf -s` for symbols). Other tools: `nm` (symbols), `objdump -d` (disasm), `objdump -r` (relocations), `ldd` (shared deps).
- ==**Linker jobs**==: ==**symbol resolution + relocation + section merging + library handling + LTO + page-alignment/perf tuning**==.
- ==**Loading into memory is NOT a linker job**== (it's the loader/OS).
- **Three kinds of object files**: ==**Relocatable `.o`, Executable, Shared object `.so`**==. ("Static object file" / "Dynamic object file" are NOT real categories — quiz traps.)
- `.a` = static **archive** library = collection of `.o` files **with an index**.
- ==**Dynamic linking data structures**==: ==**GOT + PLT**==.
  - **PLT** lives in **`.text`/`.plt`** (executable code).
  - **GOT** and **GOT.plt** live in **`.data`** (writable, dynamic linker fills in).
- ==**Dynamic linking advantages**==: ==**RAM/disk savings (shared single copy), centralized security updates / bug fixes, faster build-time linking**==. **NOT** "faster execution".
- **`.symtab`** contains: ==**global variables, external functions, static local symbols**==. **NOT** local stack variables.
- **Linker symbol rules** (CMU classic):
  - 2 strong → **error**.
  - 1 strong + N weak → strong wins.
  - N weak → arbitrary pick (potentially dangerous).
  - **"Two weak symbols are not allowed" is INCORRECT** (quiz: incorrect rule = "two weaks not allowed").
- **Linker does NOT type-check** ⇒ a strong `int` and weak `double` of same name silently corrupt memory.
- **Compiler/assembler** writes relocation info to **`.rel.text` / `.rel.data`** (NOT linker, loader, or dynamic linker).
- **Library order matters**: command-line scanned **left to right** ⇒ put libs **after** objects that need them. `gcc main.o -lfoo` ✓; `gcc -lfoo main.o` ✗.
- Your own `malloc` overrides libc because it appears before `libc.a` in the scan and resolves earlier.
- ==**LD_PRELOAD**== forces a custom `.so` to be loaded first → can interpose `malloc` etc. **Cannot** easily interpose statically-linked startup like `_start` (in `crt1.o`); but `__libc_start_main` is interposable.
- ==**PIC** (Position-Independent Code)==: shared libs can load at any address; uses PC-relative + GOT/PLT.
- Modern dynamic linking benefits answer: **2,3,4** (RAM, security, fast build) — NOT 1 (faster exec).

## 1. What is Linking & Why

==**Linking**== = combine code/data modules into a single executable (or shared object) that can be loaded into memory and run. **`ld`** does this.

### Why linking exists (benefits)

> Quiz answer: **modularity, fast (re)compilation, code reuse via libs, easier maintenance**. (NOT "simpler to build an executable" — it actually makes build *more* complex.)

| Benefit | Why |
|---|---|
| **Modularity** | decompose program into small files |
| **Time efficiency (separate compile)** | change one `.c` → recompile that file → relink |
| **Space efficiency (libraries)** | static or dynamic libraries; pay-as-you-go |

## 2. Compiler Pipeline & Tools

```
.c → cpp → .i → cc1 → .s → as → .o → ld → exe
```

| Tool | Role |
|---|---|
| `cpp` (gcc -E) | preprocess macros/#include |
| `cc1` (gcc -S) | compile to asm |
| `as` (gcc -c) | assemble to `.o` |
| **`ld`** | **link** |
| `gcc` | driver wrapping all above |
| `readelf` | detailed ELF info (`-s` symbols, `-r` relocs, `-h` header) |
| `nm` | symbol list |
| `objdump -d` | disassemble |
| `objdump -r` | show relocation entries |
| `ldd` | list shared-lib dependencies |
| `ar rs libfoo.a x.o y.o` | create static archive |
| `gcc -shared -fpic` | create `.so` |
| `dlopen / dlsym / dlclose` | runtime dynamic linking |

## 3. Linker Jobs

> [!IMPORTANT] What linker DOES:
> - **Symbol resolution** — bind every reference to exactly one definition.
> - **Relocation** — assign final addresses; patch references in code/data.
> - **Section merging** — merge `.text/.data/.bss/...` from many `.o`'s.
> - **Library handling** — pull needed `.o` from `.a`, link `.so` symbols.
> - **Link-Time Optimization (LTO)** when `-flto` is on.
> - **Tune layout / page alignment** (improve perf via section placement).
>
> What linker does NOT do:
> - **Loading into memory** (loader / `ld-linux.so`).
> - **Type checking** between modules.
> - Compiling source.

## 4. Three Kinds of Object Files

| Kind | Suffix | Description |
|---|---|---|
| **Relocatable** | `.o` | input to linker |
| **Executable** | (no suffix on Linux, `.exe` on Win) | loadable + runnable |
| **Shared object** | `.so` (`.dll` on Win) | dynamically linked at load/run time |

> Quiz trap: "Static object file" / "Dynamic object file" are NOT object file types. (Static and dynamic refer to *libraries*: `.a` static lib, `.so` shared lib.)

## 5. ELF Object File Format

| Section | Content |
|---|---|
| ELF header | word size, byte order, file type, machine type |
| Program header table | (executables/`.so`): segment info for OS loader |
| **`.text`** | code |
| **`.rodata`** | read-only data (string consts, jump tables) |
| **`.data`** | initialized globals |
| **`.bss`** | uninitialized globals — **occupies no file bytes** |
| **`.symtab`** | symbol table (procedures, static vars, sections) |
| **`.rel.text`** | relocation info for code refs |
| **`.rel.data`** | relocation info for data refs |
| `.debug` | debug info (`gcc -g`) |
| `.line`, `.strtab` | line numbers, string table |
| Section header table | (`.o` only required) section offsets/sizes |

> "BSS" = "Block Started by Symbol" / "Better Save Space".
> Program header table is required for **executables/.so**; section header table is required for **`.o`**.

## 6. Linker Symbols

| Type | Examples |
|---|---|
| **Global** | non-static functions, non-static globals — visible to other modules |
| **External** | referenced here, defined elsewhere |
| **Local linker symbol** | static functions, static globals — visible only in this module |

> [!IMPORTANT] **NOT** linker symbols: local stack variables, function parameters (those live on the stack only).

### `.symtab` quiz

```c
int incr = 1;
static int foo(int a) { int b = a + incr; return b; }
int main(int argc, char *argv[]) { printf("%d\n", foo(5)); }
```

Symbols in `.symtab`: **`incr, foo, main, printf`** (`"%d\n"` may also appear as a `.rodata` symbol). NOT `a, b, argc, argv` (stack-only).

> Quiz answer: `.symtab` contains **global variables, external functions, static local symbols** (1, 3, 4 — NOT local stack vars).

### Local static vs Local non-static

```c
int f() { static int x = 17; return x++; }
int g() { static int x = 19; return x += 14; }
```

- **Local static**: stored in `.bss`/`.data`, given **unique names** (e.g., `x.1721`, `x.1724`) so they don't collide.
- **Local non-static**: lives on stack — NOT a linker symbol.

## 7. Symbol Resolution: Strong vs Weak

| Strong | Weak |
|---|---|
| **functions, initialized globals** | **uninitialized globals, `extern`** |

### Rules

1. **Multiple strong** → **link error** (e.g., two `int x = 5;` in different `.c`).
2. **One strong + N weak** → **strong wins**; weak refs resolve to it.
3. **Multiple weak** → **arbitrary pick** (UB/dangerous; can override with `gcc -fno-common`).

> [!IMPORTANT] Quiz: which rule is **incorrect**?
> - "Two weak symbols are not allowed" → ❌ **THIS is wrong** (rule 3 says they ARE allowed; arbitrary pick).
> - "Two strong not allowed" ✓.
> - "1 strong + multiple weak allowed" ✓.
> - "Two weak with different types allowed" ✓ (linker doesn't type-check).

### Insidious bugs from no type checking

```c
// File A
long int x;             /* weak */
printf("%ld\n", x);

// File B
double x = 3.14;        /* strong */
```

Compiles fine. **Prints garbage** — `printf` reads `double` bytes as `long`.

```c
// A
int x = 7;  int y = 5;
// B
double x;   /* writes can spill into adjacent y */
```

Writes to `x` in B may overwrite `y`. **Linker does not type-check.**

### Recommendations

- **Avoid global vars**.
- Use `static` for module-private.
- Initialize globals you define.
- Use `extern` in `.h` for shared globals; define exactly once in a `.c`.

## 8. Relocation

After symbol resolution, linker:
1. **Merges sections** of same type from all input `.o`s.
2. **Assigns runtime addresses** to merged sections + symbols.
3. **Patches references** using **relocation entries**.

> Quiz: ==**The compiler/assembler** leaves relocation info in **`.rel.text` / `.rel.data`**==. NOT linker / loader / dynamic linker.

```c
typedef struct { int offset; int symbol:24, type:8; } elf32_rel;
```

### RISC-V relocation example

```asm
0:  auipc a0, 0x0          # %got_pcrel_hi(array) — top 20b of array addr
4:  addi  a0, a0, 0        # %pcrel_lo — low 12b
e:  auipc ra, 0x0          # call sum
12: jalr  ra
```

| Offset | Symbol | Type |
|---|---|---|
| 4 | array | `R_RISCV_PCREL_HI20` |
| 8 | array | `R_RISCV_PCREL_LO12_I` |
| e | sum | **`R_RISCV_CALL_PLT`** |

## 9. Loading

Process VA layout (low → high):

```
0..0x400000   unused
[.init .text .rodata]    read-only code (loaded from exe)
[.data .bss]             read/write data
heap (grows up)          malloc
[mmap region]            shared libs / mmap
stack (grows down)       %rsp / sp
kernel VA                invisible to user
```

> Loader uses **program header table** to map segments. Section header table is mainly for link/debug.

## 10. Static Libraries (`.a`)

==**Static library**== = archive of `.o` files + index.

```bash
ar rs libc.a atoi.o printf.o ... random.o
```

Common libs:
- `libc.a` (1496 `.o`, 4.6 MB) — I/O, malloc, signal, str, time.
- `libm.a` (444 `.o`, 2 MB) — `sin, cos, log, exp, sqrt`.

Link with: `gcc main.c -lm` (libm), `-lc` (libc default).

### Linker algorithm (left-to-right scan)

```
1. Scan .o and .a in command-line order.
2. Maintain UNRESOLVED set.
3. For each new .o or .a member:
     - resolve unresolved refs against its symbols.
     - if .a member resolves something, pull it in.
4. End: if UNRESOLVED nonempty → error.
```

### Library order matters

```bash
gcc main.o -lvector       ✓  (main.o adds refs first; -lvector resolves them)
gcc -lvector main.o       ✗  (when -lvector seen, UNRESOLVED is empty → ignored)
```

> **Moral: put libraries AFTER object files that need them.**

### Why your `malloc` overrides libc's

```bash
gcc a.o b.o main.o -lc
```
- `a.o` calls `malloc` → adds to UNRESOLVED.
- `b.o` calls `malloc` → already in set.
- `main.o` defines `malloc` → resolves it (your version wins).
- `libc.a` reached but `malloc` already resolved → libc's `malloc` not pulled.

## 11. Shared Libraries (`.so` / DLL)

> [!IMPORTANT] Why static libs are inadequate:
> - duplication on disk (every exe has libc).
> - duplication in RAM (every running process has libc copy).
> - bug fix in libc → must relink all executables.

==**Shared library**==: code/data loaded + linked **at load/run time**.

| Linking time | How |
|---|---|
| **Load-time** | Linux dynamic linker `ld-linux.so` maps `.so`s + relocates when exe starts. Standard for `libc.so`. |
| **Run-time** | App calls `dlopen("libfoo.so", RTLD_LAZY); dlsym(handle, "func"); dlclose()`. |

### How the dynamic linker is invoked

- ELF program header `PT_INTERP` points to `/lib/ld-linux.so.2` (or similar).
- OS loads `ld-linux.so` first; jumps into it; it maps your exe + dependencies, fixes addresses, then jumps to your `main`.

### `LD_PRELOAD` interposition

- Setting env `LD_PRELOAD=./mylib.so` forces dynamic loader to load `mylib.so` **before** anything else.
- If `mylib.so` defines `malloc`, all calls go to your version.
- **Cannot** interpose `_start` (statically linked in `crt1.o`).
- **CAN** interpose `__libc_start_main`.

### Build commands

```bash
gcc -shared -fpic addvec.c multvec.c -o libvector.so
gcc main2.c ./libvector.so -o prog2l            # load-time link
ldd prog2l                                       # see deps
```

### Quiz: dynamic linking advantages

> ==**RAM/disk savings, centralized security/bug-fix updates, fast build-time linking**== (modern answer: **2, 3, 4**).
> **NOT** "faster execution" — there's lookup overhead (PLT/GOT trampolines), so dynamic is *not* faster than static at runtime.

## 12. PIC, GOT, PLT

==**PIC (Position-Independent Code)**==: code can be loaded at any address. Multiple processes share one in-memory copy.

### How

- Distance between `.text` and `.data` segments is **fixed at link time**.
- Compiler builds a **GOT** at start of data segment with one entry per externally-resolved global.
- For external **functions**, uses a **PLT** of stubs in `.text/.plt`.

### Memory layout

```
[.text  | .plt]          ← code segment (read-only)
[.got   | .got.plt | .data | .bss]   ← data segment (read-write)
            ↑ filled in by dynamic linker
```

### Quiz: where do GOT/PLT live?

> ==**PLT in `.text`/`.plt`** (executable). **GOT and GOT.plt in `.data`** (writable so dynamic linker can fill addresses).==

### External global var (RV PIC)

```asm
auipc a0, %got_pcrel_hi(my_var)   # PC-rel addr of GOT entry
ld    a0, %pcrel_lo(...)(a0)      # load real addr from GOT
lw    a0, 0(a0)                    # finally load value
```

### External function call (RV: `printf`)

Compiler emits pseudo `call printf`. Assembler expands:
```asm
auipc ra, %pcrel_hi(printf@plt)
jalr  ra, %pcrel_lo(...)(ra)
```

Linker creates a 3-instr **PLT stub**:
```asm
auipc t3, %hi(printf@got)
ld    t3, %lo(...)(t3)
jalr  t0, t3
```

GOT.plt entry initialized to "lazy resolver"; first call goes through resolver, fills real address; subsequent calls jump direct.

### PIC pipeline summary

| Step | Phase | Action |
|---|---|---|
| 1 | Compile | compiler emits `call printf` (pseudo) |
| 2 | Assemble | expands to `auipc + jalr`; emits relocation entry |
| 3 | Link | creates `.plt` stub (`auipc/ld/jalr`) |
| 4 | Link | reserves GOT slot in `.got.plt` |
| 5 | Run-time | dynamic linker fills GOT slot with real addr |
