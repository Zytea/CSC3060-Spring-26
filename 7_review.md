# Lec 7: Linking

## Exam Facts

- ==**Standard Unix linker**==: ==**`ld`**==. (`gcc` driver invokes it.) NOT `ln` (symlink), NOT `link` (Windows).
- ==**Read detailed ELF info**==: ==**`readelf`**== (`-s` symbols, `-r` relocs, `-h` header). Other: `nm`, `objdump -d/-r`, `ldd`.
- ==**Linker jobs**==: ==**symbol resolution + relocation + section merging + library handling + LTO + page-alignment/perf tuning**==.
- ==**Loading into memory is NOT a linker job**== (it's the loader/OS).
- **Three kinds of object files**: ==**Relocatable `.o`, Executable, Shared object `.so`**==. ("Static object file" / "Dynamic object file" are NOT real.)
- `.a` = static **archive** = ==**collection of `.o` + index**==.
- ==**Dynamic linking data structures**==: ==**GOT + PLT**==.
- ==**PLT in `.text`/`.plt`**== (executable code).
- ==**GOT and GOT.plt in `.data`**== (writable, dynamic linker fills).
- ==**Dynamic linking advantages**==: ==**RAM/disk savings, centralized security/bug fixes, faster build-time linking**==. NOT "faster execution".
- `.symtab` contains: ==**global vars, external functions, static local symbols**==. NOT local stack vars.
- **Linker symbol rules**:
  - 2 strong → **error**.
  - 1 strong + N weak → strong wins.
  - N weak → arbitrary pick (dangerous).
  - ==**"Two weak symbols are not allowed" is INCORRECT**== (quiz: incorrect rule).
- **Linker does NOT type-check**.
- ==**Compiler/assembler** writes relocation info to `.rel.text` / `.rel.data`==.
- **Library order matters**: scan **left→right**; libs **after** their users (`gcc main.o -lfoo` ✓; `-lfoo main.o` ✗).
- Your own `malloc` overrides libc because it appears before `libc.a` in scan.
- ==**`LD_PRELOAD`**== forces a custom `.so` first → can interpose `malloc` etc. **Cannot** interpose `_start` (in `crt1.o`); CAN interpose `__libc_start_main`.
- ==**PIC**== (Position-Independent Code): shared libs load at any address; uses PC-relative + GOT/PLT.

## 1. What is Linking & Why

==**Linking**==: combine code/data modules into a single executable / shared object that can be loaded and run. **`ld`** does this.

> Quiz benefits: **modularity, fast (re)compile, code reuse, easier maintenance**. NOT "simpler to build an executable".

| Benefit | Why |
|---|---|
| Modularity | decompose into small files |
| Time efficiency | change 1 `.c` → recompile + relink only |
| Space efficiency | static / dynamic libs; pay-as-you-go |

## 2. Compiler Pipeline & Tools

```
.c → cpp → .i → cc1 → .s → as → .o → ld → exe
```

| Tool | Role |
|---|---|
| `cpp` (gcc -E) | preprocess macros/#include |
| `cc1` (gcc -S) | compile to asm |
| `as` (gcc -c) | assemble to `.o` |
| ==**`ld`**== | **link** |
| `gcc` | driver wrapping all above |
| ==**`readelf`**== | detailed ELF info |
| `nm` | symbol list |
| `objdump -d` / `-r` | disasm / relocations |
| `ldd` | shared-lib deps |
| `ar rs libfoo.a x.o y.o` | create static archive |
| `gcc -shared -fpic` | create `.so` |
| `dlopen / dlsym / dlclose` | runtime dynamic linking |

## 3. Linker Jobs

> [!IMPORTANT] Linker DOES:
> - **Symbol resolution** — bind every reference to exactly one definition.
> - **Relocation** — assign final addresses; patch refs.
> - **Section merging** — merge `.text/.data/.bss/...`.
> - **Library handling** — pull `.o` from `.a`, link `.so` symbols.
> - **LTO** when `-flto` on.
> - **Tune layout / page alignment**.
>
> Linker does NOT:
> - **Loading into memory** (loader / `ld-linux.so`).
> - Type-check between modules.
> - Compile source.

## 4. Three Kinds of Object Files

| Kind | Suffix | Description |
|---|---|---|
| **Relocatable** | `.o` | input to linker |
| **Executable** | (no suffix on Linux) | loadable + runnable |
| **Shared object** | `.so` (Win `.dll`) | dynamically linked at load/run time |

> Quiz trap: "Static object file" / "Dynamic object file" are NOT object kinds. Static/dynamic refer to **libraries**: `.a` static lib, `.so` shared lib.

## 5. ELF Object File Format

| Section | Content |
|---|---|
| ELF header | word size, byte order, type, machine |
| Program header table | (executables/`.so`): segments for OS loader |
| **`.text`** | code |
| **`.rodata`** | read-only data (string consts, jump tables) |
| **`.data`** | initialized globals |
| **`.bss`** | uninitialized globals — **occupies no file bytes** |
| **`.symtab`** | symbol table |
| **`.rel.text`** | relocation info for code refs |
| **`.rel.data`** | relocation info for data refs |
| `.debug` | debug info (`gcc -g`) |
| `.line`, `.strtab` | line numbers, string table |
| Section header table | (`.o`) section offsets/sizes |

> "BSS" = "Block Started by Symbol" / "Better Save Space".
> Program header table required for executables/`.so`; section header table required for `.o`.

## 6. Linker Symbols

| Type | Examples |
|---|---|
| **Global** | non-static functions, non-static globals — visible to other modules |
| **External** | referenced here, defined elsewhere |
| **Local linker symbol** | static functions/globals — visible only in this module |

> [!IMPORTANT] **NOT** linker symbols: ==**local stack variables, function parameters**==.

### 6.1 `.symtab` Quiz

```c
int incr = 1;
static int foo(int a) { int b = a + incr; return b; }
int main(int argc, char *argv[]) { printf("%d\n", foo(5)); }
```

Symbols: ==**`incr, foo, main, printf`**== (and `"%d\n"` may appear as `.rodata`). NOT `a, b, argc, argv` (stack-only).

### 6.2 Local Static vs Non-Static

```c
int f() { static int x = 17; return x++; }
int g() { static int x = 19; return x += 14; }
```

- **Local static**: stored in `.bss`/`.data`, given **unique names** (e.g., `x.1721`, `x.1724`).
- **Local non-static**: stack-only — NOT a linker symbol.

## 7. Symbol Resolution: Strong vs Weak

| Strong | Weak |
|---|---|
| **functions, initialized globals** | **uninitialized globals, `extern`** |

### 7.1 Rules

1. **Multiple strong** → ==**link error**== (e.g., two `int x = 5;`).
2. **One strong + N weak** → ==**strong wins**==.
3. **Multiple weak** → ==**arbitrary pick**== (UB/dangerous; `gcc -fno-common` overrides).

> [!IMPORTANT] Quiz: which rule is **incorrect**? ==**"Two weak symbols are not allowed"** is wrong== (rule 3 says they ARE allowed).
> "Two strong not allowed" ✓; "1 strong + multiple weak allowed" ✓; "Two weak with different types allowed" ✓ (linker doesn't type-check).

### 7.2 Insidious Bugs (no type checking)

```c
// File A
long int x;             /* weak */
printf("%ld\n", x);

// File B
double x = 3.14;        /* strong wins */
```

Compiles fine. **Prints garbage** — `printf` reads `double` bytes as `long`.

```c
// A
int x = 7;  int y = 5;
// B
double x;   /* writes can spill into adjacent y */
```

Writes to `x` in B may overwrite `y`. **Linker does not type-check.**

### 7.3 Recommendations

- Avoid global vars.
- Use `static` for module-private.
- Initialize globals you define.
- Use `extern` in `.h` for shared globals; define exactly once in a `.c`.

## 8. Relocation

After symbol resolution, linker:
1. **Merges sections** of same type.
2. **Assigns runtime addresses**.
3. **Patches references** using **relocation entries**.

> [!IMPORTANT] ==**Compiler/assembler** leaves relocation info in `.rel.text` / `.rel.data`==. NOT linker / loader / dynamic linker.

```c
typedef struct { int offset; int symbol:24, type:8; } elf32_rel;
```

### 8.1 RISC-V Relocation Example

```asm
0:  auipc a0, 0x0          # %got_pcrel_hi(array)
4:  addi  a0, a0, 0        # %pcrel_lo
e:  auipc ra, 0x0          # call sum
12: jalr  ra
```

| Offset | Symbol | Type |
|---|---|---|
| 4 | array | `R_RISCV_PCREL_HI20` |
| 8 | array | `R_RISCV_PCREL_LO12_I` |
| e | sum | ==**`R_RISCV_CALL_PLT`**== |

## 9. Loading

Process VA layout (low → high):

```
0..0x400000   unused
[.init .text .rodata]    read-only code (loaded from exe)
[.data .bss]             read/write data
heap (grows up)          malloc
[mmap region]            shared libs / mmap
stack (grows down)       sp
kernel VA                invisible to user
```

> Loader uses **program header table** to map segments. Section header table mainly for link/debug.

## 10. Static Libraries (`.a`)

==**Static library**== = archive of `.o` + index.

```bash
ar rs libc.a atoi.o printf.o ... random.o
```

Common libs: `libc.a` (1496 `.o`, 4.6MB) — I/O, malloc, signal, str, time. `libm.a` (444 `.o`, 2MB) — `sin/cos/log/exp/sqrt`. Link via `gcc main.c -lm`.

### 10.1 Linker Algorithm (left-to-right scan)

```
1. Scan .o and .a in command-line order.
2. Maintain UNRESOLVED set.
3. For each new .o or .a member:
     - resolve unresolved refs against its symbols.
     - if .a member resolves something, pull it in.
4. End: if UNRESOLVED nonempty → error.
```

### 10.2 Library Order Matters

```bash
gcc main.o -lvector       # ✓ main.o adds refs first; -lvector resolves them
gcc -lvector main.o       # ✗ when -lvector seen, UNRESOLVED is empty → ignored
```

> ==**Moral: put libraries AFTER object files that need them.**==

### 10.3 Why Your `malloc` Overrides libc's

```bash
gcc a.o b.o main.o -lc
```
- `a.o` calls `malloc` → adds to UNRESOLVED.
- `b.o` calls `malloc` → already in set.
- `main.o` defines `malloc` → resolves both refs (your version wins).
- `libc.a` reached but `malloc` already resolved → libc's `malloc` not pulled.

## 11. Shared Libraries (`.so` / DLL)

> Static libs inadequate: duplication on disk + RAM; bug fix in libc → must relink all exes.

==**Shared library**==: code/data loaded + linked **at load/run time**.

| When | How |
|---|---|
| **Load-time** | Linux dynamic linker `ld-linux.so` maps `.so`s + relocates when exe starts. Standard for `libc.so`. |
| **Run-time** | App calls `dlopen / dlsym / dlclose`. |

### 11.1 How Dynamic Linker Is Invoked

- ELF program header `PT_INTERP` points to `/lib/ld-linux.so.2`.
- OS loads `ld-linux.so` first; jumps into it; it maps exe + deps, fixes addresses, then jumps to your `main`.

### 11.2 `LD_PRELOAD` Interposition

- `LD_PRELOAD=./mylib.so` forces dynamic loader to load `mylib.so` **before** anything else.
- If `mylib.so` defines `malloc`, all calls go to your version.
- ==**Cannot** interpose `_start`== (in `crt1.o`, statically linked).
- ==**CAN** interpose `__libc_start_main`==.

### 11.3 Build Commands

```bash
gcc -shared -fpic addvec.c multvec.c -o libvector.so
gcc main2.c ./libvector.so -o prog2l        # load-time link
ldd prog2l                                   # see deps
```

### 11.4 Quiz: Dynamic Linking Advantages

==**RAM/disk savings, centralized security/bug-fix updates, fast build-time linking**== (answer: 2,3,4).
**NOT** "faster execution" — there's PLT/GOT lookup overhead.

## 12. PIC, GOT, PLT

==**PIC (Position-Independent Code)**==: code can be loaded at any address. Multiple processes share one in-memory copy.

### 12.1 How

- Distance between `.text` and `.data` segments **fixed at link time**.
- Compiler builds **GOT** at start of data segment with one entry per externally-resolved global.
- For external **functions**, uses **PLT** stubs in `.text/.plt`.

### 12.2 Memory Layout

```
[.text  | .plt]                       ← code segment (read-only)
[.got   | .got.plt | .data | .bss]    ← data segment (read-write)
            ↑ filled in by dynamic linker
```

> ==**PLT in `.text`/`.plt`**==. ==**GOT and GOT.plt in `.data`**== (writable so dynamic linker can fill addresses).

### 12.3 External Global Var (RV PIC)

```asm
auipc a0, %got_pcrel_hi(my_var)   # PC-rel addr of GOT entry
ld    a0, %pcrel_lo(...)(a0)       # load real addr from GOT
lw    a0, 0(a0)                     # load value
```

### 12.4 External Function Call (RV: `printf`)

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

### 12.5 PIC Pipeline

| Step | Phase | Action |
|---|---|---|
| 1 | Compile | emits `call printf` (pseudo) |
| 2 | Assemble | expands to `auipc + jalr`; emits relocation entry |
| 3 | Link | creates `.plt` stub (`auipc/ld/jalr`) |
| 4 | Link | reserves GOT slot in `.got.plt` |
| 5 | Run-time | dynamic linker fills GOT slot with real addr |
