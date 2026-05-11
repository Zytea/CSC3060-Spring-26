# Lec 7: Linking

## Exam Facts

- ==**Linking**==: combine object files + libraries → executable / shared object. Performed by the **linker**.
- ==**Standard Unix linker**==: **`ld`**; `gcc` is a compiler **driver** that invokes it (Quiz 5 #1).
- ==**ELF inspection tools**==: ==**`readelf`**== for full ELF details ★ (Quiz 5 #2); `objdump` for disasm + relocs; `nm` for symbol list.
- ==**Linker jobs**==: **symbol resolution + relocation + section merging + library handling** + may coordinate **LTO** + **layout / page alignment**.
- ==**NOT a linker job**==: ==**loading into memory**== (loader / dynamic linker does it; Quiz 5 #3).
- **Performance via linker**: page sizes, alignments, **function/code layout** for I-cache locality (place hot caller/callee adjacent).
- ==**Three object file kinds**==: ==**relocatable `.o`**==, ==**executable `a.out`**==, ==**shared object `.so`**==. (Static archive `.a` is NOT a 4th kind — it's a **collection of `.o`s + index**, Quiz 5 #11.)
- ==**Benefits of linking**==: **modularity, separate compilation, library reuse, easier maintenance, time efficiency** (parallel/incremental compile), space efficiency. NOT "simpler to build an executable" (Quiz 5 #9).
- ==**ELF sections**==: `.text` (code), `.rodata` (read-only), `.data` (initialized globals), `.bss` (zero globals), `.symtab` (symbols), `.rel.text/.rel.data` (relocations), `.debug` (debug info), section header table.
- ==**ELF executable contains**== machine code + global data + symbol/reloc/debug metadata as sections; **NOT** the user stack or register file (runtime state).
- **Symbols in `.symtab`** (Quiz 5 #15): **global vars, external funcs, static local symbols** (file-local + function-scope `static`). **NOT** ordinary local variables (those are stack temporaries).
- ==**Strong vs Weak**==: **strong** = function definitions + initialized globals; **weak** = uninitialized globals (or `extern` declarations).
- ==**Duplicate rules**==:
  1. **Multiple strong → ERROR**.
  2. **Strong + weak → strong wins**, weak refs resolved to strong.
  3. **Multiple weak → arbitrary** (linker picks one); use `-fno-common` to force error.
  4. ==**Linker does NOT type-check**== — silent garbage on type mismatch.
- **Two weak symbols are allowed (legacy "common" model)**; Quiz 5 #16: incorrect rule = "two weak symbols are NOT allowed".
- ==**Static library order matters**==: put `-lfoo` **after** the `.o`s that need it (`gcc main.o -lfoo`).
- ==**Dynamic linking data structures**==: ==**GOT (Global Offset Table) + PLT (Procedure Linkage Table)**==. NOT JT, NOT SHT (Quiz 5 #12).
- ==**GOT/PLT placement**==:
  - **PLT in `.text`** (executable code) ✅
  - **GOT in `.data`** (writable, non-exec) ✅
  - **`.got.plt` in `.data`** ✅
  - GOT in `.text` ❌ (would be non-writable)
- ==**Dynamic-link advantages**== (Quiz 5 #13): **memory savings + centralized security/bug-fix updates + fast build-time linking**. **NOT** "faster execution" (PLT/GOT add indirection).
- ==**Where reloc info comes from**== (Quiz 5 #18): **compiler/assembler emits `.rel.text` + `.rel.data`**, linker consumes them. NOT linker, NOT loader, NOT dynamic linker.
- **`.so` and `.a`**: `.so` for shared object; `.a` for archived static lib; `.o` for relocatable. `.a` = collection of `.o`s + index.
- ==**Static linker scan algorithm**==: left-to-right; `.o` always included; archive members **only if they resolve current unresolved refs**.
- ==**`malloc` override pattern**==: if user `.o` defines `malloc` and is scanned **before** `libc.a`, libc's `malloc` is **never pulled** (already resolved).
- ==**Inline candidates good for I-cache locality**==: hot caller/callee that ping-pong far cache lines → inline OR linker-layout adjacent.
- **Loader maps ELF segments**: low-page unmapped, `.text/.rodata` r-x/r--, `.data/.bss` rw-, heap → upward, mmap/.so middle, stack → downward, kernel space protected.
- **Dynamic exe**: kernel maps program + `ld-linux.so` (named in `PT_INTERP`); dynamic linker maps `.so` deps, relocates, jumps to start.
- **Runtime interposition**: `LD_PRELOAD=./wrap.so prog` loads first → same-name funcs intercept later library calls.

## 1. What Is Linking?

==**Linking**== combines code + data from multiple `.o`s and libraries into a single object that can be loaded + executed.

```text
main.c → cpp → cc1 → as → main.o   ┐
sum.c  → cpp → cc1 → as → sum.o    ├→  ld  →  prog (executable)
libc.a / libfoo.so                  ┘
```

==**`gcc` is a compiler driver**==: orchestrates `cpp/cc1/as` then invokes `ld`.

```bash
gcc -Og -o prog main.c sum.c
```

> ==**Why linkers are essential**==: separate compilation. Edit one file → recompile only it → relink. Without linker, every change requires recompiling everything.

## 2. Why Linkers? (Quiz 5 #9)

| Benefit | Meaning |
|---|---|
| **modularity** | split code into smaller files |
| **separate compilation** | recompile only what changed |
| **libraries** (code reuse) | libc, libm, libfoo,... |
| **easier maintenance** | independent modules |
| **time efficiency** | parallel compile, incremental |
| **space efficiency** | static `.a` pulls only needed members; `.so` shares pages across processes |

> Quiz 5 #9 distractor: "simpler to build an executable" is NOT a benefit (linking adds complexity).

==**Two library models**==:

|                  | **Static (`.a`)**             | **Shared (`.so`)**                       |
| ---------------- | ----------------------------- | ---------------------------------------- |
| **When linked**  | at link time, copied into exe | at load/run time, by dynamic linker      |
| **Exe size**     | larger, no runtime dep        | smaller, runtime `.so` dep               |
| **Lib update**   | must relink                   | ABI-compat → no relink                   |
| **Memory**       | pay-as-you-go (only used)     | one copy shared by all processes         |

## 3. What Linkers Do

### 3.1 Symbol Resolution

Bind every **symbol reference** to exactly one **symbol definition**.

```c
void swap() { ... }   // defines swap
swap();               // references swap
int *xp = &x;         // defines xp, references x
```

==**Symbol classification (linker view)**==:

| Type | Examples |
|---|---|
| **global defined here** | non-static funcs, non-static globals |
| **external reference** | `printf`, `sum` declared but not defined here |
| **local linker symbol** | `static` funcs, `static` file-scope globals, `static` function-scope vars |

==**NOT linker symbols**==:

- ordinary local (auto) variables — they're stack temporaries.
- function parameters.
- register temporaries.

### 3.2 Relocation

After deciding final section/symbol addresses, linker patches code/data references using **relocation entries**:

```text
1. merge .text from all .o → one big .text
   merge .data → one big .data, etc.
2. assign final addresses to each symbol.
3. patch every reloc entry: fix calls, global-data loads, jump targets.
```

### 3.3 Other Jobs (linker can do)

- scan static archives.
- section alignment / page layout.
- function/code layout for I-cache (with PGO/profile).
- **page sizes / alignments** for performance.
- emit dynamic relocation metadata.
- LTO if `-flto`.

## 4. Object File Kinds (Quiz 5 #11)

| Kind | Extension | Use |
|---|---|---|
| ==**relocatable**== | **`.o`** | input to linker |
| ==**executable**== | `a.out` (or no ext) | load + run |
| ==**shared object**== | **`.so`** (Linux) / `.dll` (Windows) | dynamically loaded library |

> ==**`.a` archive is NOT a 4th kind**== — it's a collection of `.o`s + index. Quiz 5 #17: "all of these descriptions are correct" → **NONE incorrect**.

## 5. ELF Object File Format

==**Generic ELF binary**==: one format for `.o`, exe, and `.so`.

| Section / Table | Contents |
|---|---|
| **ELF header** | word size, endian, file type, machine type |
| Program header (segments, exec only) | loadable mem segments + sizes |
| **`.text`** | machine code |
| **`.rodata`** | read-only constants, jump tables, string literals |
| **`.data`** | initialized globals/statics |
| **`.bss`** | uninit globals/statics ("Block Started by Symbol" / "Better Save Space") — **header only, no file bytes** |
| **`.symtab`** | symbol table — name, size, location, scope |
| **`.rel.text` / `.rela.text`** | relocations for code |
| **`.rel.data` / `.rela.data`** | relocations for data pointers |
| `.debug` | debug info (`gcc -g`) |
| Section header table | metadata for sections |

> ELF sections include `.text/.rodata/.data/.bss/.symtab` etc. **NOT** ELF sections: **user stack**, register file, ".static" (no such section).

## 6. Linker Symbols

| Type | Example |
|---|---|
| **global defined here** | non-static func, non-static global |
| **external reference** | `printf`, `sum` declared but defined elsewhere |
| **local linker symbol** | `static` func, `static` file-scope global, **function-scope `static` vars** |

==**NOT linker symbols**==: ordinary `auto` local vars, params, register temps.

### 6.1 `.symtab` Quiz Pattern

```c
int incr = 1;                // global symbol ★
static int foo(int a) {      // local linker symbol ★
    int b = a + incr;         // a, b NOT linker symbols (auto locals)
    return b;
}
int main(int argc, char *argv[]) {
    printf("%d\n", foo(5));   // main = global ★; printf = external ref ★
    return 0;
}
```

==**Symbols in `.symtab` of `symbols.o`**==: `incr, foo, main, printf` (and possibly `"%d\n"` as a `.rodata` constant string).

==**Verify with**==: `readelf -s symbols.o`.

### 6.2 Static Local Variables

```c
int f() { static int x = 17; return x++; }
```

Function-scope `static` has storage in `.data`/`.bss` and a **compiler-generated local linker symbol** (e.g., `x.1721`). Ordinary local vars do NOT.

## 7. Duplicate Symbol Resolution

| Declaration / Definition | Strength |
|---|---|
| **function definition** | **strong** |
| **initialized global** (`int x = 5;`) | **strong** |
| uninitialized global (`int x;`) | **weak** (legacy "common" model) |
| `extern int x;` | reference only (no def) |

==**Linker rules**==:

1. **Two strong same name → ERROR** (multiple definition).
2. **One strong + N weak → choose strong**; weak refs all resolve to strong.
3. **Multiple weak → arbitrary** (linker picks one); use `gcc -fno-common` to force error.

> Quiz 5 #16: incorrect rule = ==**"two weak symbols are not allowed"**== (actually they ARE allowed in legacy common model).

> Quiz 5 #17: `static` file-scope symbols are local to one `.o`; same name in another file is **not** a global duplicate.

### 7.1 Insidious Silent Errors

```c
// File 1
int x = 15213;                     // strong
int main() { f(); printf("%d\n", x); return 0; }

// File 2
int x;                             // weak / common
void f() { x = 15212; }
```

Compiles + links cleanly; **prints `15212`** because both refer to same `x`.

==**Type mismatch** (linker doesn't type-check)==:

```c
// main.c
long int x;                  // weak symbol, 8 bytes (LP64)

// vars.c
double x = 3.14;             // strong, 8 bytes
```

Linker uses `double` storage; `printf("%ld", x)` reinterprets bytes → **garbage**.

==**Linker puzzle table**==:

| Files | Outcome |
|---|---|
| `int x; p1() {}` and `p1() {}` | ❌ **link error** (two strong `p1`) |
| `int x; p1() {}` and `int x; p2() {}` | both refer to **same uninitialized int** |
| `int x; p1() {}` and `double x; p2() {}` | writes to `x` in `p2` may **overwrite neighbors** (silent!) |
| `int x = 7; p1() {}` and `int x; p2() {}` | both refer to **same initialized int** ✅ |

### 7.2 Recommendations

- **Avoid global vars** if you can.
- Otherwise: use `static` for file-local; **initialize** intended globals; use `extern` for external refs.
- Put `extern` declarations in `.h` headers; one `.c` owns the definition + initialization.
- Use **`-fno-common`** to force errors on common symbols.

```c
// global.h
extern int g;
int f(void);

// c1.c
#include "global.h"
int f(void) { return g + 1; }

// c2.c
#include "global.h"
int g = 0;                  // exactly one definition
int main(void) { ... }
```

## 8. Relocation

==**Relocation entry**==:

| Field | Meaning |
|---|---|
| **offset** | where to patch (byte index in section) |
| **symbol** | target symbol |
| **type** | encoding/computation rule |
| **addend** | constant adjustment |

==**Compiler/assembler emits `.rel.text` + `.rel.data`**== because final addrs unknown. Linker consumes after layout.

> Quiz: "the **compiler or assembler** leaves reloc info in `.rel.text` and `.rel.data`" ✅.

### 8.1 RISC-V Relocation Patterns

==**Global data load** (PC-relative)==:

```asm
auipc a0, %pcrel_hi(array)         # R_RISCV_PCREL_HI20
addi  a0, a0, %pcrel_lo(array)     # R_RISCV_PCREL_LO12_I
```

==**Far call / function pointer**==:

```asm
auipc ra, %pcrel_hi(sum)
jalr  ra, %pcrel_lo(sum)(ra)        # R_RISCV_CALL_PLT
```

| Reloc | Use |
|---|---|
| `R_RISCV_PCREL_HI20` | upper 20b of PC-rel address |
| `R_RISCV_PCREL_LO12_I` | lower 12b for I-type (load/JALR) |
| `R_RISCV_PCREL_LO12_S` | lower 12b for S-type (store) |
| `R_RISCV_CALL_PLT` | call via PLT-capable sequence |

## 9. Loading Executables

```text
high addr
┌────────────────────────┐
│ kernel space (protected)│
├────────────────────────┤
│ stack (rw-) ← grows down│
├────────────────────────┤
│ mmap / shared libs      │
├────────────────────────┤
│ heap (rw-) → grows up   │
├────────────────────────┤
│ .data / .bss (rw-)      │
├────────────────────────┤
│ .text / .rodata (r-x/r--)│
├────────────────────────┤
│ low unmapped page       │
└────────────────────────┘
low addr
```

==**Dynamic exe boot**==:

```text
1. kernel maps program + interpreter (named in PT_INTERP, e.g., /lib/ld-linux.so)
2. dynamic linker maps needed .so deps
3. dynamic linker performs relocations, lazy or now
4. jumps to _start, which calls main
```

## 10. Static Libraries

==**Create**==:

```bash
ar rs libvector.a addvec.o multvec.o
```

==**Link**==:

```bash
gcc main.o -L. -lvector -o prog
```

`-lvector` searches `libvector.a` (or `.so`) along `-L` paths.

==**`.a` is "pay-as-you-go"**==: only members that resolve unresolved references are included. See §2 table for full static/shared comparison.

### 10.1 Static Linker Scan Algorithm

==**Left-to-right scan**==:

| Input | Action |
|---|---|
| object `.o` | **always include** |
| archive `.a` | include **only members resolving current unresolved refs** |

If unresolved refs remain after scan → **link error**.

### 10.2 `malloc` Override Pattern

```bash
gcc main.o my_alloc.o -lc -o prog
# my_alloc.o defines its own malloc()
```

| Step | Effect |
|---|---|
| `main.o` calls `malloc` | adds `malloc` to **unresolved** set |
| `my_alloc.o` defines `malloc` | resolves; `malloc` no longer unresolved |
| `libc.a` scanned | libc `malloc` member **NOT pulled** (already resolved) |

Result: program uses your `malloc`, not libc's.

### 10.3 Library Order Matters

```bash
gcc main.o -lfoo          # OK if main.o needs foo
gcc -lfoo main.o          # may fail: at -lfoo time, no unresolved refs to pull
```

==**Circular dependencies**==:

```bash
gcc main.o -lA -lB -lA    # repeat -lA to resolve back-references
# or use --start-group / --end-group
```

### 10.4 Link Error Triage

| Symptom | Likely cause | Fix |
|---|---|---|
| `undefined reference to 'X'` | missing `.o`/lib OR wrong library order | add `.o`/lib; put `-lfoo` **after** users |
| `multiple definition of 'X'` | duplicate strong global/func | one definition; use `extern` in headers |
| **garbage at runtime, link succeeded** | strong/weak mismatch (different types) | fix declarations; use headers + `-fno-common` |

## 11. Shared Libraries / Dynamic Linking

==**Advantages**==: **memory savings** ✅ (one `.so` shared across processes); **centralized security/bug-fix updates** ✅ (replace `.so`, all programs benefit); **fast build-time linking** ✅. **NOT** faster execution ❌ (PLT/GOT add indirection).

### 11.1 Load-Time Dynamic Linking

```bash
gcc -shared -fpic -o libv.so addvec.c multvec.c
gcc main.o ./libv.so -o prog
```

==**At load**==: `ld-linux.so` (named in `PT_INTERP`) maps deps, performs needed relocations + lazy bindings.

> Result: **partially linked executable** — final `.so` addrs fixed at load.

### 11.2 Run-Time Dynamic Linking

```c
#include <dlfcn.h>
void *h = dlopen("./libv.so", RTLD_LAZY);
void (*f)(int *, int *, int *, int) = dlsym(h, "addvec");
f(x, y, z, 2);
dlclose(h);
```

Used for plugins / hot-swappable modules.

### 11.3 Runtime Interposition

```bash
LD_PRELOAD=./wrap.so prog
```

`wrap.so` loaded **first** → its same-name functions intercept later library calls. Useful for instrumentation, leak detection, etc.

> Limit: cannot replace code already executed before interposition (e.g., `_start`); wrappers usually intercept libc calls or `__libc_start_main`.

## 12. PIC, GOT, PLT (Dynamic-Linking Internals)

==**PIC**== (Position-Independent Code): shared library code works at **any load address**.

==**Dynamic linking uses GOT + PLT**== (Quiz 5 #12). NOT JT (jump table), NOT SHT.

==**PIC trick**==: code and data keep a **fixed relative distance** within the loaded `.so`, so PC-relative addressing reaches GOT entries reliably.

### 12.1 GOT (Global Offset Table)

==**GOT**==: writable table of runtime addresses for globals + external symbols.

```asm
auipc a0, %got_pcrel_hi(my_var)
ld    a0, %pcrel_lo(...)(a0)   # a0 = address from GOT
lw    a0, 0(a0)                # actual value
```

### 12.2 PLT (Procedure Linkage Table)

==**PLT**==: executable stubs for external function calls.

==**Lazy binding**==:

```text
call func@plt → PLT stub → indirect-jump via GOT.plt[func]
First call:  GOT.plt[func] = resolver → resolve real address → patch GOT.plt
Later calls: GOT.plt[func] = real address → direct jump
```

### 12.3 Memory Placement (Quiz 5 #14)

| Structure        | `.text` | **`.plt`**        | **`.got`** | **`.got.plt`**       | `.data` / `.bss` |
| ---------------- | ------- | ----------------- | ---------- | -------------------- | ---------------- |
| **Purpose**      | code    | code stubs        | data table | lazy func addr table | writable data    |
| **Writable**     | ❌      | ❌                | ✅         | ✅                   | ✅               |
| **Executable**   | ✅      | ✅                | ❌         | ❌                   | ❌               |

> ==**PLT in `.text` (or `.plt`)**==; ==**GOT and `.got.plt` in `.data`-like writable region**==.

## 13. Quick Quiz Anchors

| Question | Answer |
|---|---|
| Unix standard linker | **`ld`** (NOT `gcc` / `ln` / `link`) |
| read ELF detail | **`readelf`** |
| disasm + reloc | `objdump` |
| symbol list | `nm` |
| NOT a linker job | **loading into memory** |
| object file kinds (3) | `.o`, exe, `.so` |
| `-O3 -flto` enables | cross-module inlining |
| bug: link succeeds, type mismatch | **linker doesn't type-check** |
| `-fno-common` | force error on multiple weak |
| good inline candidates | small + constant args + once-in-loop |
| dynamic-link advantage NOT | "faster execution" |
| dynamic-link data structures | **GOT + PLT** |
| PLT in section | `.text`/`.plt` |
| GOT in section | `.data`/`.got` |
| who emits reloc info | **compiler / assembler** in `.rel.text` + `.rel.data` |
| static lib order | put libs **after** consumers |
| `-l` searches | `lib<name>.{so,a}` |
| `.symtab` contains | globals + external refs + static linker symbols (NOT auto locals) |
| weak/strong rule (incorrect) | "two weak NOT allowed" — actually allowed |
| benefits of linking (NOT) | "simpler to build executable" |
| description NOT applicable to `.so/.a/.o` | **NONE** (all 4 descriptions correct) |
