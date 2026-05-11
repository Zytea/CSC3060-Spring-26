# Lec 7: Linking

## Exam Facts

- ==**Linking**==: combine `.o`s + libs → exe / `.so`. By the **linker**.
  - ==**Standard Unix linker**==: **`ld`**; `gcc` is a compiler **driver** that invokes it.
  - ==**ELF tools**==: ==**`readelf`**== full details ★; `objdump` disasm + relocs; `nm` symbol list.
  - ==**Linker jobs**==: **symbol resolution + relocation + section merging + library handling** (+ LTO, layout, page alignment).
  - ==**NOT a linker job**==: ==**loading into memory**== (loader / dynamic linker).
  - **Performance via linker**: page alignment, **fn/code layout** for I-cache locality (hot caller/callee adjacent).

- ==**3 object file kinds**==: ==**relocatable `.o`**==, ==**executable `a.out`**==, ==**shared `.so`**==. (`.a` is **NOT** a 4th — it's `.o`s + index.)

- ==**Benefits of linking**==: **modularity, separate compilation, library reuse, easier maintenance, time efficiency, space efficiency**. NOT "simpler to build" ❌.

- ==**ELF sections**==: `.text` code, `.rodata` read-only, `.data` init globals, `.bss` zero globals, `.symtab`, `.rel.text/.rel.data`, `.debug`, section header table.
  - **`.bss`** ("Block Started by Symbol") = header only, no file bytes.
  - **ELF exe contains**: machine code + global data + symbol/reloc/debug **as sections**; NOT user stack or register file ❌.

- ==**`.symtab` contains**==: **global vars, external fns, static local symbols** (file-local `static` + function-scope `static`). **NOT** ordinary auto locals/params/temps ❌.

- ==**Strong vs Weak**==: **strong** = fn def + initialized global; **weak** = uninitialized global / `extern` decl.
  - **Two strong same name** → ❌ ERROR (multiple def).
  - **Strong + weak** → strong wins; weak refs resolve to strong.
  - **Multiple weak** → arbitrary (linker picks one); use `-fno-common` to force error.
  - **Two weak allowed** in legacy "common" model — Quiz incorrect rule = "two weak NOT allowed" ❌.
  - ==**Linker does NOT type-check**== — silent garbage on type mismatch.

- ==**Static library order matters**==: `-lfoo` **after** consumers (`gcc main.o -lfoo`).
  - **Scan algorithm**: left-to-right; `.o` always included; archive members **only if resolving current unresolved refs**.
  - ==**`malloc` override**==: user `.o` defines `malloc` scanned **before** `libc.a` → libc's `malloc` never pulled.

- ==**Dynamic linking**==: ==**GOT + PLT**==. NOT JT, NOT SHT ❌.
  - ==**Placement**==: **PLT in `.text`** ✅; **GOT in `.data`** (writable) ✅; **`.got.plt` in `.data`** ✅; GOT in `.text` ❌.
  - ==**Advantages**==: **memory savings** ✅; **centralized security/bug-fix updates** ✅; **fast build-time linking** ✅. **NOT** faster execution ❌ (PLT/GOT indirection).

- ==**Reloc info emitted by**==: ==**compiler/assembler**== in `.rel.text` + `.rel.data`. NOT linker/loader/dynamic linker ❌.

- **Loader maps**: low-page unmapped; `.text/.rodata` r-x/r--; `.data/.bss` rw-; heap → up; mmap/`.so` middle; stack → down; kernel protected.
  - **Dynamic exe boot**: kernel maps program + `ld-linux.so` (in `PT_INTERP`); dyld maps `.so` deps, relocates, jumps to `_start`.
  - ==**`LD_PRELOAD=./wrap.so prog`**==: wrap loaded first → same-name fns intercept later calls (instrumentation, leak detection).

## 1. What Is Linking?

```text
main.c → cpp → cc1 → as → main.o   ┐
sum.c  → cpp → cc1 → as → sum.o    ├→  ld  →  prog
libc.a / libfoo.so                 ┘
```

==**`gcc` is a compiler driver**==: orchestrates `cpp/cc1/as` + invokes `ld`.

> ==**Why essential**==: separate compilation. Edit 1 file → recompile only it → relink. Without linker, every change = recompile everything.

==**Two library models**==:

|                  | **Static (`.a`)**             | **Shared (`.so`)**                       |
| ---------------- | ----------------------------- | ---------------------------------------- |
| **When linked**  | at link time, copied into exe | at load/run time, by dynamic linker      |
| **Exe size**     | larger, no runtime dep        | smaller, runtime `.so` dep               |
| **Lib update**   | must relink                   | ABI-compat → no relink                   |
| **Memory**       | pay-as-you-go (only used)     | one copy shared by all processes         |

## 2. Linker Symbols

| Type                    | Examples                                                         |
| ----------------------- | ---------------------------------------------------------------- |
| **global defined here** | non-static fns, non-static globals                               |
| **external reference**  | `printf`, `sum` declared but not defined here                    |
| **local linker symbol** | `static` fns, `static` file-scope globals, fn-scope `static` vars |
| **NOT linker symbols**  | auto locals, params, register temps (stack temporaries)          |

==**`.symtab` quiz pattern**==:

```c
int incr = 1;                // global ★
static int foo(int a) {      // local linker ★
    int b = a + incr;        // a, b NOT linker symbols
    return b;
}
int main(int argc, char *argv[]) {
    printf("%d\n", foo(5));  // main = global ★; printf = external ref ★
}
```

==**Symbols in `.symtab`**==: `incr, foo, main, printf` (+ `"%d\n"` as `.rodata`). Verify: `readelf -s symbols.o`.

==**Static local trap**==: `int f() { static int x = 17; return x++; }` — `x` has storage in `.data`/`.bss` + compiler-generated local symbol (e.g., `x.1721`).

## 3. ELF Object Format

| Section / Table                          | Contents                                                          |
| ---------------------------------------- | ----------------------------------------------------------------- |
| **ELF header**                           | word size, endian, file type, machine type                        |
| Program header (exe only)                | loadable mem segments + sizes                                     |
| **`.text`**                              | machine code                                                      |
| **`.rodata`**                            | read-only constants, jump tables, string literals                 |
| **`.data`**                              | initialized globals/statics                                       |
| **`.bss`**                               | uninit globals/statics — **header only, no file bytes**           |
| **`.symtab`**                            | symbol table — name, size, location, scope                        |
| **`.rel.text` / `.rel.data`** (`.rela.*`) | relocations for code / data pointers                              |
| `.debug`                                 | debug info (`gcc -g`)                                             |
| Section header table                     | metadata for sections                                             |

> ❌ NOT ELF sections: user stack, register file, `.static` (no such section).

==**3 object file kinds**==:

| Kind                    | Extension                | Use                                  |
| ----------------------- | ------------------------ | ------------------------------------ |
| ==**relocatable**==     | **`.o`**                 | input to linker                      |
| ==**executable**==      | `a.out` (or no ext)      | load + run                           |
| ==**shared object**==   | **`.so`** (`.dll` Win)   | dynamically loaded library           |

> ==`.a` is NOT a 4th kind== — collection of `.o`s + index.

## 4. Duplicate Symbol Resolution

| Form                              | Strength |
| --------------------------------- | -------- |
| **function definition**           | **strong** |
| **initialized global** (`int x = 5;`) | **strong** |
| uninitialized global (`int x;`)   | **weak** (legacy "common") |
| `extern int x;`                   | reference only (no def) |

==**Rules**==:
1. **Two strong** → ❌ ERROR.
2. **Strong + N weak** → strong wins; weak refs → strong.
3. **Multiple weak** → arbitrary; `-fno-common` to force error.

> Quiz: incorrect rule = ==**"two weak symbols are not allowed"**== — actually allowed in legacy common.

> Quiz: `static` file-scope symbols local to one `.o`; same name in another file is **not** a global duplicate.

==**Linker puzzle**==:

| Files | Outcome |
|---|---|
| `int x; p1() {}` + `p1() {}` | ❌ **link error** (two strong `p1`) |
| `int x; p1() {}` + `int x; p2() {}` | both refer to **same uninit int** |
| `int x; p1() {}` + `double x; p2() {}` | writes to `x` in `p2` **overwrite neighbors** (silent!) |
| `int x = 7; p1() {}` + `int x; p2() {}` | both refer to **same initialized int** ✅ |

==**Type-mismatch trap**==: linker uses wider type's storage; `printf("%ld", x)` reinterprets bytes → **garbage**.

==**Recommendations**==:
- **Avoid global vars** if possible.
- Otherwise: `static` for file-local; **initialize** intended globals; `extern` for external refs.
- `extern` decls in `.h`; one `.c` owns the def.
- Use **`-fno-common`** to force errors.

## 5. Relocation

==**Reloc entry**==:

| Field        | Meaning                                |
| ------------ | -------------------------------------- |
| **offset**   | where to patch (byte index in section) |
| **symbol**   | target symbol                          |
| **type**     | encoding/computation rule              |
| **addend**   | constant adjustment                    |

==**Compiler/assembler emits `.rel.text` + `.rel.data`**== — final addrs unknown. Linker consumes after layout.

==**RISC-V reloc patterns**==:

```asm
# Global data load (PC-relative)
auipc a0, %pcrel_hi(array)         # R_RISCV_PCREL_HI20
addi  a0, a0, %pcrel_lo(array)     # R_RISCV_PCREL_LO12_I

# Far call / function pointer
auipc ra, %pcrel_hi(sum)
jalr  ra, %pcrel_lo(sum)(ra)       # R_RISCV_CALL_PLT
```

| Reloc                       | Use                                  |
| --------------------------- | ------------------------------------ |
| `R_RISCV_PCREL_HI20`        | upper 20b of PC-rel address          |
| `R_RISCV_PCREL_LO12_I`      | lower 12b for I-type (load/JALR)     |
| `R_RISCV_PCREL_LO12_S`      | lower 12b for S-type (store)         |
| `R_RISCV_CALL_PLT`          | call via PLT-capable sequence        |

## 6. Loading Executables

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

==**Dynamic exe boot**==: kernel maps program + interpreter (in `PT_INTERP`, e.g., `/lib/ld-linux.so`) → dyld maps `.so` deps → relocates (lazy or now) → jumps to `_start` → calls `main`.

## 7. Static Libraries

```bash
ar rs libvector.a addvec.o multvec.o     # create
gcc main.o -L. -lvector -o prog          # link
```

`-lvector` searches `libvector.a` (or `.so`) on `-L` paths.

==**Static linker scan**== (left-to-right):

| Input         | Action                                                    |
| ------------- | --------------------------------------------------------- |
| object `.o`   | **always include**                                        |
| archive `.a`  | include **only members resolving current unresolved refs** |

Unresolved after scan → **link error**.

==**`malloc` override pattern**==:

```bash
gcc main.o my_alloc.o -lc -o prog
# my_alloc.o defines its own malloc()
```

| Step                                  | Effect                                                       |
| ------------------------------------- | ------------------------------------------------------------ |
| `main.o` calls `malloc`               | adds `malloc` to **unresolved** set                          |
| `my_alloc.o` defines `malloc`         | resolves; `malloc` no longer unresolved                      |
| `libc.a` scanned                      | libc `malloc` **NOT pulled** (already resolved)              |

==**Order matters**==:

```bash
gcc main.o -lfoo          # ✅ OK if main.o needs foo
gcc -lfoo main.o          # ❌ may fail: at -lfoo time, no unresolved refs
```

==**Circular deps**==: `gcc main.o -lA -lB -lA` (repeat) or `--start-group / --end-group`.

==**Link error triage**==:

| Symptom                              | Likely cause                            | Fix                                          |
| ------------------------------------ | --------------------------------------- | -------------------------------------------- |
| `undefined reference to 'X'`         | missing `.o`/lib OR wrong order         | add `.o`/lib; put `-lfoo` **after** users    |
| `multiple definition of 'X'`         | duplicate strong global/fn              | one def; `extern` in headers                 |
| **garbage at runtime, link OK**      | strong/weak type mismatch               | fix decls; headers + `-fno-common`           |

## 8. Shared Libraries / Dynamic Linking

==**Advantages**==: **memory savings** ✅; **centralized security/bug-fix updates** ✅; **fast build-time linking** ✅. **NOT** faster execution ❌ (PLT/GOT indirection).

==**Load-time**==:

```bash
gcc -shared -fpic -o libv.so addvec.c multvec.c
gcc main.o ./libv.so -o prog
```

At load: `ld-linux.so` (in `PT_INTERP`) maps deps, performs relocs + lazy bindings.

==**Run-time**==:

```c
#include <dlfcn.h>
void *h = dlopen("./libv.so", RTLD_LAZY);
void (*f)(int *, int *, int *, int) = dlsym(h, "addvec");
f(x, y, z, 2);
dlclose(h);
```

> Used for plugins / hot-swappable modules.

==**Interposition**==: `LD_PRELOAD=./wrap.so prog` loads wrap **first** → same-name fns intercept later library calls (instrumentation, leak detection). Limit: cannot replace code already executed before interposition (e.g., `_start`).

## 9. PIC, GOT, PLT

==**PIC**== (Position-Independent Code): code works at **any load address**. Trick: code and data keep **fixed relative distance** within `.so` → PC-relative reaches GOT.

==**GOT**==: writable table of runtime addrs for globals + external symbols.

```asm
auipc a0, %got_pcrel_hi(my_var)
ld    a0, %pcrel_lo(...)(a0)   # a0 = address from GOT
lw    a0, 0(a0)                # actual value
```

==**PLT**==: executable stubs for external fn calls. ==**Lazy binding**==:

```text
call func@plt → PLT stub → indirect via GOT.plt[func]
First call:  GOT.plt[func] = resolver → resolve real addr → patch GOT.plt
Later calls: GOT.plt[func] = real addr → direct jump
```

==**Memory placement**==:

| Structure        | `.text` | **`.plt`** | **`.got`** | **`.got.plt`**       | `.data` / `.bss` |
| ---------------- | ------- | ---------- | ---------- | -------------------- | ---------------- |
| **Purpose**      | code    | code stubs | data table | lazy func addr table | writable data    |
| **Writable**     | ❌      | ❌         | ✅         | ✅                   | ✅               |
| **Executable**   | ✅      | ✅         | ❌         | ❌                   | ❌               |

> ==**PLT in `.text` (or `.plt`)**==; ==**GOT and `.got.plt` in `.data`-like writable region**==.

## 10. Quick Quiz Anchors

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
| PLT in section | `.text` / `.plt` |
| GOT in section | `.data` / `.got` |
| who emits reloc info | **compiler / assembler** in `.rel.text` + `.rel.data` |
| static lib order | put libs **after** consumers |
| `-l` searches | `lib<name>.{so,a}` |
| `.symtab` contains | globals + external refs + static linker symbols (NOT auto locals) |
| weak/strong rule (incorrect) | "two weak NOT allowed" — actually allowed |
| benefits of linking (NOT) | "simpler to build executable" |
| description NOT applicable to `.so/.a/.o` | **NONE** (all correct) |
