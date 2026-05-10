# Lec 7: Linking

## Exam Facts

- Standard Unix linker: **`ld`**; `gcc` is the driver that invokes it.
- Detailed ELF info: **`readelf`**. Useful commands: `readelf -h/-S/-s/-r`, `nm`, `objdump -d/-r`, `ldd`.
- Linker jobs: **symbol resolution, relocation, section merging, library handling, LTO, page/layout tuning**.
- Loading into memory is **not** a linker job; loader/OS/dynamic linker does it.
- Object file kinds: **relocatable `.o`**, **executable**, **shared object `.so`**.
- `.a` is a static archive: collection of `.o` files plus index.
- Dynamic linking data structures: **GOT + PLT**.
- PLT is code in `.text/.plt`; GOT/GOT.plt are writable data in `.data`-like area.
- Dynamic linking advantages: memory/disk savings, centralized bug/security fixes, fast build-time linking. Not faster execution.
- `.symtab` contains global vars, external functions, static local symbols. Not local stack variables.
- Symbol rules: multiple strong -> error; one strong + weak(s) -> strong wins; multiple weak -> arbitrary.
- Linker does **not** type-check across modules.
- Compiler/assembler leave relocation entries in `.rel.text` / `.rel.data`.
- Static libraries scanned left to right; library must appear **after** users.
- `LD_PRELOAD` can interpose shared-library functions such as `malloc`; cannot interpose `_start`, can interpose `__libc_start_main`.
- PIC uses PC-relative addressing + GOT/PLT so shared libraries can load anywhere.

## 1. Linking

==**Linking**== combines separately compiled code/data into one executable or shared object.

Why link:

- modularity.
- fast recompilation.
- library reuse.
- easier maintenance.

> Quiz: "simpler to build executable" is not a core benefit.

## 2. Compiler Drivers and Linking

Pipeline:

```text
.c -> cpp -> .i -> cc1 -> .s -> as -> .o -> ld -> executable
```

| Tool | Use |
|---|---|
| `cpp` / `gcc -E` | preprocess |
| `cc1` / `gcc -S` | compile |
| `as` / `gcc -c` | assemble |
| `ld` | link |
| `gcc` | driver |
| `readelf` | inspect ELF details |
| `nm` | list symbols |
| `objdump` | disasm/relocs |
| `ldd` | shared library dependencies |
| `ar` | create static archive |

## 3. What Do Linkers Do?

### 3.1 Symbol Resolution

Bind every symbol reference to exactly one symbol definition.

Examples:

- function call to `sum`.
- global variable reference to `array`.
- external function `printf`.

### 3.2 Relocation

Assign final addresses to sections/symbols and patch machine code/data references.

### 3.3 Other Jobs

- merge sections (`.text`, `.data`, `.bss`, `.rodata`).
- handle static/shared libraries.
- perform LTO with `-flto`.
- choose page/layout alignment for performance.

## 4. Three Kinds of Object Files

| Kind | Suffix | Meaning |
|---|---|---|
| relocatable | `.o` | link input |
| executable | usually none | loadable/runnable |
| shared object | `.so` | dynamic library |

Quiz trap: "static object file" and "dynamic object file" are not the three ELF object kinds.

## 5. ELF Object File Format

| ELF part | Content |
|---|---|
| ELF header | word size, endian, machine, file type |
| program header table | segments for loader; executable/`.so` |
| `.text` | code |
| `.rodata` | constants, string literals, jump tables |
| `.data` | initialized globals/statics |
| `.bss` | uninitialized globals/statics; no file bytes |
| `.symtab` | symbol table |
| `.rel.text` | relocation records for code |
| `.rel.data` | relocation records for data |
| `.debug` | debug info |
| section header table | section metadata, important for `.o` |

## 6. Linker Symbols

| Symbol kind | Examples |
|---|---|
| global definitions | non-static functions/globals defined here |
| external references | used here, defined elsewhere |
| local linker symbols | `static` functions/globals, local static vars |

Not linker symbols:

- local automatic variables.
- function parameters.
- register temporaries.

### 6.1 `.symtab` Quiz Pattern

```c
int g = 1;
static int helper(int a) { int b = a + g; return b; }
int main(int argc, char **argv) { return helper(5); }
```

Symbols include `g`, `helper`, `main`. If `printf` called, `printf` is external. `a`, `b`, `argc`, `argv` are not linker symbols.

### 6.2 Local Static vs Non-Static

```c
int f() { static int x = 1; return x++; }
```

Local static `x` has storage in `.data/.bss` and a unique internal symbol. A normal local variable lives on stack and is not in `.symtab`.

## 7. Duplicate Symbol Resolution

| Definition | Strength |
|---|---|
| function | strong |
| initialized global | strong |
| uninitialized global/common | weak in traditional GCC common model |

Rules:

1. Two strong definitions -> link error.
2. One strong + weak(s) -> choose strong.
3. Multiple weak -> choose one arbitrarily.

> Quiz asks incorrect rule: **"Two weak symbols are not allowed"** is incorrect.

### 7.1 No Type Checking

```c
/* a.c */ long x;
/* b.c */ double x = 3.14;
```

Linker may bind them; program reads bytes with wrong type and prints garbage.

Global mismatch can overwrite adjacent objects. Avoid globals; use `static`; use `extern` declarations in headers and exactly one definition.

## 8. Relocation

Relocation entry says: at this offset, patch bits using this symbol and relocation type.

Compiler/assembler produce relocation records; linker consumes them.

Common sections:

- `.rel.text`: instruction/call/address references in code.
- `.rel.data`: pointers or initialized data needing addresses.

### 8.1 RISC-V Relocation Shape

External/global address in PIC may use:

```asm
auipc a0, %got_pcrel_hi(sym)
ld    a0, %pcrel_lo(...)(a0)
```

Function call pseudo:

```asm
call printf
```

expands to `auipc + jalr` with relocation such as `R_RISCV_CALL_PLT`.

## 9. Loading

Loader maps executable segments into process virtual memory using program headers.

Typical user VA layout:

```text
low addresses
text / rodata
data / bss
heap grows up
mmap/shared libraries
stack grows down
kernel region
high addresses
```

Linking creates a loadable file; loading maps it into memory and starts execution.

## 10. Static Libraries

Static library `.a` = archive of `.o` files:

```bash
ar rs libvec.a addvec.o multvec.o
```

### 10.1 Left-to-Right Scan

Linker scans command line left to right:

1. object files always included.
2. archive members included only if they resolve an unresolved symbol at that moment.
3. unresolved set must be empty at end.

Correct:

```bash
gcc main.o -lvec
```

Wrong:

```bash
gcc -lvec main.o
```

### 10.2 Your `malloc` Overrides libc

If your object defining `malloc` appears before libc is scanned, references are resolved to yours; libc member is not pulled.

## 11. Shared Libraries

Shared library `.so` is linked at load time or runtime.

Build/load:

```bash
gcc -shared -fpic addvec.c multvec.c -o libvector.so
gcc main.c ./libvector.so -o prog
ldd prog
```

Runtime API: `dlopen`, `dlsym`, `dlclose`.

### 11.1 Dynamic Linker

ELF `PT_INTERP` names dynamic linker, e.g., `ld-linux.so`.

OS loads dynamic linker first; it maps dependencies, performs relocations/lazy binding, then transfers control to program startup.

### 11.2 Library Interposition

`LD_PRELOAD=./mylib.so ./prog` loads `mylib.so` first.

- can interpose `malloc`, `free`, etc.
- cannot interpose `_start` because it comes from startup object.
- can interpose `__libc_start_main`.

## 12. PIC, GOT, PLT

==**PIC**==: position-independent code; shared object can be mapped at any address and shared by processes.

### 12.1 GOT

==**GOT**== stores runtime addresses of global data/external symbols. It is writable because dynamic linker fills entries.

Typical RV external data access:

```asm
auipc a0, %got_pcrel_hi(my_var)
ld    a0, %pcrel_lo(...)(a0)   # real address
lw    a0, 0(a0)                # value
```

### 12.2 PLT

==**PLT**== is executable code stubs for external function calls.

Call path:

```text
caller -> PLT stub -> GOT.plt entry -> dynamic resolver first time -> real function later
```

### 12.3 Memory Placement

```text
.text / .plt          code, read-only/executable
.got / .got.plt       writable data, filled by dynamic linker
.data / .bss          normal writable data
```

Quiz: PLT in `.text`; GOT and GOT.plt in `.data`-like writable section.
