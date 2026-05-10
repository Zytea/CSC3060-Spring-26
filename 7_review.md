# Lec 7: Linking

## Exam Facts

- ==**Linking**== combines code/data from object files and libraries into an executable or shared object.
- Linker benefits: modularity, separate compilation, library reuse, time/space efficiency.
- Linker jobs: **symbol resolution + relocation + section merging + library handling**.
- Object file kinds: relocatable `.o`, executable, shared object `.so`.
- ELF sections: `.text`, `.rodata`, `.data`, `.bss`, `.symtab`, `.rel.text`, `.rel.data`, `.debug`, section header table.
- Linker symbols: global, external, local. Local C automatic variables are **not** linker symbols.
- Strong symbols: functions and initialized globals. Weak symbols: uninitialized globals and some extern/common symbols.
- Duplicate rules: multiple strong -> error; strong beats weak; multiple weak -> arbitrary/common.
- Linker does **not** type-check duplicate symbols.
- Static library order matters: put libraries **after** object files that need them.
- Dynamic linker `ld-linux.so` maps dependencies and performs relocations before program startup.
- `LD_PRELOAD` can interpose shared-library functions like `malloc`; cannot interpose statically linked `_start`, can interpose `__libc_start_main`.
- PIC uses PC-relative addressing + GOT/PLT so shared libraries can load anywhere.
- PLT is executable stubs in `.plt/.text`; GOT/GOT.plt are writable data filled by dynamic linker.

## 1. Linking

==**Linking**==: collect and combine code/data from multiple object files into one file that can be loaded into memory and executed.

Example:

```c
// main.c
int sum(int *a, int n);
int array[2] = {1,2};
int main() { return sum(array,2); }
```

```c
// sum.c
int sum(int *a, int n) {
    int i, s=0;
    for (i=0; i<n; i++) s += a[i];
    return s;
}
```

Build:

```bash
gcc -Og -o prog main.c sum.c
```

Pipeline:

```text
main.c -> cpp/cc1/as -> main.o
sum.c  -> cpp/cc1/as -> sum.o
main.o + sum.o + libraries -> ld -> prog
```

## 2. Why Linkers?

| Benefit | Meaning |
|---|---|
| modularity | split large program into files/modules |
| separate compilation | recompile changed file only, then relink |
| libraries | reuse common code: libc, libm, libvector |
| time efficiency | compile modules in parallel |
| space efficiency | static links only used archive members; dynamic libs share code across processes |

## 3. What Linkers Do

### 3.1 Symbol Resolution

Programs define and reference symbols:

```c
void swap() { }       // define symbol swap
swap();               // reference symbol swap
int *xp = &x;         // define xp, reference x
```

Assembler stores symbol definitions/references in `.symtab`. Linker binds each reference to exactly one definition.

### 3.2 Relocation

After resolution, linker:

- merges same-name sections from input `.o` files.
- assigns final addresses to sections and symbols.
- patches code/data references using relocation entries.

Relocation entry says: at this offset, patch bits using this symbol and relocation type.

### 3.3 Other Jobs

- library archive scanning.
- dead section removal if enabled.
- LTO coordination.
- layout/page alignment.
- dynamic relocation metadata for shared libraries.

## 4. Object File Kinds

| Kind | Extension | Description |
|---|---|---|
| relocatable | `.o` | code/data ready to combine with other objects |
| executable | `a.out`, no required extension | loadable and runnable |
| shared object | `.so` / DLL | loaded and linked dynamically at load time or run time |

## 5. ELF Object File Format

| Section/table | Meaning |
|---|---|
| ELF header | word size, endian, file type, machine type |
| program/segment header | loadable segments for OS loader; required for executables |
| `.text` | executable code |
| `.rodata` | string constants, jump tables, const data |
| `.data` | initialized globals/statics |
| `.bss` | uninitialized globals/statics; occupies no file bytes |
| `.symtab` | symbol table: names, sizes, sections, bindings |
| `.rel.text` / `.rela.text` | relocation records for code |
| `.rel.data` / `.rela.data` | relocation records for data pointers |
| `.debug` | debug info from `-g` |
| section header table | section offsets/sizes; important for relocatables/debugging |

> `.bss` saves disk space: loader allocates zero-filled memory for it.

## 6. Linker Symbols

| Symbol type | Meaning | Examples |
|---|---|---|
| global | defined in this module, referenceable by others | non-static function/global |
| external | referenced here, defined elsewhere | `printf`, `sum` in `main.o` |
| local linker symbol | defined and referenced only in this module | `static` function/global |

Local automatic variables are **not** linker symbols:

```c
int main(int argc, char **argv) {
    int val = sum(array,2);  // val is stack/local, linker does not know it
}
```

### 6.1 `.symtab` Quiz Pattern

```c
int incr = 1;
static int foo(int a) {
    int b = a + incr;
    return b;
}
int main(int argc, char *argv[]) {
    printf("%d\n", foo(5));
}
```

Symbols in `symbols.o`: `incr`, `foo`, `main`, `printf`. Local variables `a`, `b`, `argc`, `argv` are not linker symbols. String literal may appear as a local read-only object with compiler-generated name.

Use:

```bash
readelf -s symbols.o
```

### 6.2 Static Local vs Non-Static Local

```c
static int x = 15;
int f() { static int x = 17; return x++; }
int g() { static int x = 19; return x += 14; }
int h() { return x += 27; }
```

- file-scope `static x`: local linker symbol in `.data`.
- function-scope `static x`: storage in `.data`/`.bss`, local linker symbol with unique compiler name.
- ordinary local variables: stack/registers, no linker symbol.

## 7. Duplicate Symbol Resolution

| Symbol | Strong/weak |
|---|---|
| function definition | strong |
| initialized global | strong |
| uninitialized global/common | weak in traditional common model |
| `extern` declaration | reference, not definition |

Rules:

1. Multiple strong symbols with same name -> link error.
2. Strong + weak -> choose strong.
3. Multiple weak -> choose arbitrary one/common allocation; `-fno-common` turns many cases into errors.

### 7.1 Insidious Weak/Strong Example

```c
// file1.c
int x = 15213;    // strong
int main() { f(); printf("%d\n", x); }
```

```c
// file2.c
int x;            // weak/common
void f() { x = 15212; }
```

No error; both references resolve to strong `x`; output is `15212`.

### 7.2 Linker Does Not Type Check

```c
// main.c
long x;           // weak
int main() { printf("%ld\n", x); }
```

```c
// var.c
double x = 3.14;  // strong
```

References may resolve to the same address with incompatible type. Output is garbage or memory corruption.

Recommendations:

- avoid globals if possible.
- use `static` for file-local globals/functions.
- initialize actual definitions.
- put `extern` declarations in headers, one definition in a `.c`.
- compile with warnings and `-fno-common`.

## 8. Relocation

After symbol resolution, linker merges sections:

```text
main.o .text + sum.o .text + CRT/lib code -> executable .text
main.o .data + sum.o .data -> executable .data
```

Then it patches references.

### 8.1 Relocation Entry

ELF relocation record includes:

| Field | Meaning |
|---|---|
| offset | where to patch |
| symbol | index/name in symbol table |
| type | how to compute/encode patch |
| addend | constant adjustment, explicit in RELA |

Example idea:

```asm
call sum
    relocation: offset f, type PC-relative, symbol sum
```

After link, call displacement is filled from final `sum` address.

### 8.2 RISC-V Relocation Shape

RISC-V often uses paired PC-relative relocations:

```asm
auipc a0,%pcrel_hi(array)
addi  a0,a0,%pcrel_lo(array)

auipc ra,%pcrel_hi(sum)
jalr  ra,%pcrel_lo(sum)(ra)
```

| Type | Use |
|---|---|
| `R_RISCV_PCREL_HI20` | high 20 bits for PC-relative address |
| `R_RISCV_PCREL_LO12_I` | low 12 bits for I-type add/load |
| `R_RISCV_PCREL_LO12_S` | low 12 bits for S-type store |
| `R_RISCV_CALL_PLT` | external call via PLT-capable sequence |

## 9. Loading Executables

OS loader uses ELF program headers to map segments.

Typical process virtual memory:

| Region low -> high | Contents |
|---|---|
| unmapped low page | catches NULL dereference |
| read-only segment | `.init`, `.text`, `.rodata` |
| read/write segment | `.data`, `.bss` |
| heap | `malloc`, grows upward |
| memory-mapped region | shared libraries, mapped files |
| user stack | grows downward |
| kernel virtual memory | protected from user code |

For dynamically linked executable, OS loads dynamic linker first, then dynamic linker maps dependencies and relocates before program startup.

## 10. Static Libraries

==**Static library**==: `.a` archive of relocatable `.o` members plus index.

Create:

```bash
ar rs libvector.a addvec.o multvec.o
```

Link:

```bash
gcc -L. main2.o -lvector -o prog
```

Library naming convention: `-lvector` searches for `libvector.a` or `libvector.so`.

### 10.1 Static Linker Algorithm

Command line scanned left to right.

State:

- exported/defined symbols seen so far.
- unresolved references wanted so far.

For each input:

| Input | Action |
|---|---|
| object `.o` | include it unconditionally; add definitions; add unresolved refs |
| archive `.a` | include only members that resolve currently unresolved refs; repeat within archive if needed |

If unresolved refs remain at end -> link error.

### 10.2 Library Order Matters

```bash
gcc libtest.o -L. -lmine      # OK if libtest.o references libfun in libmine
gcc -L. -lmine libtest.o      # error: library scanned before wanted symbol exists
```

Moral: put libraries after objects that need them.

If circular libraries:

```bash
gcc main.o -lA -lB -lA
```

### 10.3 Your `malloc` Overrides libc `malloc`

If `main.o` defines `malloc`, and earlier objects reference `malloc`, linker resolves those references before scanning libc. It will not pull libc's `malloc` because the symbol is already resolved.

## 11. Shared Libraries / Dynamic Linking

Static library problems:

- duplicate library code in executables.
- duplicate code in running processes.
- security bug fix requires relinking/redeploying apps.

Shared library:

- loaded dynamically at load time or run time.
- code pages can be shared by processes.
- updates possible if ABI compatible.

### 11.1 Load-Time Dynamic Linking

```bash
gcc -shared -fpic -o libvector.so addvec.c multvec.c
gcc main.o ./libvector.so -o prog
```

At load:

1. OS sees `PT_INTERP` in executable.
2. OS maps dynamic linker `ld-linux.so`.
3. dynamic linker maps needed `.so` files.
4. dynamic linker performs relocations / lazy binding setup.
5. jumps to program startup, then `main`.

Use:

```bash
ldd prog
objdump -t libvector.so
objdump -rd libvector.so
```

### 11.2 Run-Time Dynamic Linking

```c
void *h = dlopen("./libvector.so", RTLD_LAZY);
void (*addvec)(int*,int*,int*,int) = dlsym(h, "addvec");
addvec(x,y,z,2);
dlclose(h);
```

Used for plugins, web servers, optional modules, runtime interposition.

`RTLD_LAZY`: resolve function references when first used.

### 11.3 `LD_PRELOAD` Interposition

```bash
LD_PRELOAD=./mymalloc.so ./prog
```

Dynamic loader loads preloaded library first. If it defines `malloc`, calls resolve to that symbol before libc's `malloc`.

Can interpose:

- `malloc`, `free`, `printf`, many dynamically linked functions.

Cannot interpose:

- statically linked code.
- `_start` from startup object already linked into executable.

Can interpose:

- `__libc_start_main` because it is normally resolved dynamically through libc.

## 12. PIC, GOT, PLT

==**PIC**==: Position-Independent Code, executable correctly no matter where loaded.

Why needed:

- shared libraries should map at different virtual addresses.
- multiple processes share same read-only code pages.
- code should not need many text relocations.

PIC uses PC-relative addressing and indirection tables.

### 12.1 GOT

==**GOT**==: Global Offset Table. Writable data table containing runtime addresses of global data/external symbols.

For external global `my_var`:

```asm
auipc a0,%got_pcrel_hi(my_var)
ld    a0,%pcrel_lo(...)(a0)   # load address of my_var from GOT
lw    a0,0(a0)                # load value
```

Dynamic linker fills GOT entries with actual addresses.

### 12.2 PLT

==**PLT**==: Procedure Linkage Table. Executable stubs used for calls to external functions.

Compiler emits call-like pseudo-instr:

```asm
call printf
```

Assembler/linker shape:

```asm
auipc ra,%pcrel_hi(printf@plt)
jalr  ra,%pcrel_lo(...)(ra)
```

PLT stub shape:

```asm
auipc t3,%hi(printf@got)
ld    t3,%lo(...)(t3)
jalr  t0,t3
```

Lazy binding idea:

```text
caller -> PLT stub -> GOT.plt entry
first call -> dynamic resolver -> patch GOT.plt
later calls -> PLT stub -> real function address
```

### 12.3 Memory Placement

| Structure | Segment/section idea | Writable? | Executable? |
|---|---|---|---|
| `.text` | code | no | yes |
| `.plt` | code stubs | no | yes |
| `.got` | addresses for globals | yes | no |
| `.got.plt` | function addresses/lazy binding | yes | no |
| `.data` | initialized writable data | yes | no |
| `.bss` | zero-initialized data | yes | no |

Quiz: PLT is code in `.text/.plt`; GOT and GOT.plt are writable data in `.data`-like region.
