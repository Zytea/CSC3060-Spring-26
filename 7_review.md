# Chapter 7: Linking

## Exam Facts

- Standard Unix/Linux linker: **`ld`**; compiler driver `gcc` invokes it.
- Detailed ELF info: **`readelf`**; symbols: `nm` / `readelf -s`; disasm/reloc: `objdump`; shared deps: `ldd`.
- Linker jobs: **symbol resolution, relocation, section merging, libraries, LTO/perf layout/page alignment**.
- **Loading into memory is not a linker job**.
- Object files: **relocatable `.o`, executable, shared object `.so`**.
- `.a` = archive/static library = collection of `.o` files with index.
- Dynamic linking data structures: **GOT + PLT**.
- PLT in **`.text/.plt`**; GOT and GOT.plt in **`.data`-like writable sections**.
- Dynamic linking advantages: **RAM savings, centralized security/bug fixes, faster build-time linking**.

## 7.1-7.3 Linking and Linker Jobs

==**Linking**==: combine code/data modules into one object executable/loadable by resolving symbols and relocating references.
- Benefits: modularity, separate compilation, code reuse, easier maintenance, faster rebuild.
- Symbol resolution: bind every symbol reference to exactly one definition.
- Relocation: assign final addresses and patch code/data references.

## 7.4-7.5 Object Files and ELF

Object file kinds:
- relocatable `.o`: input to linker;
- executable: loadable/runnable;
- shared `.so`: dynamically linked at load/run time.

ELF sections:
- `.text`: code; `.rodata`: constants;
- `.data`: initialized globals/static;
- `.bss`: uninitialized globals/static, occupies no file bytes;
- `.symtab`: symbol table;
- `.rel.text/.rela.text`: relocation info for code refs;
- `.rel.data/.rela.data`: relocation info for data refs;
- `.debug`, `.line`, `.strtab`.

## 7.6 Linker Symbols

Symbol kinds:
- global: defined in module and visible to others, e.g. non-static functions/globals;
- external: referenced here but defined elsewhere;
- local linker symbol: static function/global, visible only to module.

Not linker symbols: automatic local variables on stack.

`.symtab` contains globals, external functions, static local symbols; not ordinary stack locals.

## 7.7 Duplicate Definitions

- ==**Strong**==: functions and initialized globals.
- ==**Weak**==: uninitialized globals, tentative definitions.

Rules:
1. multiple strong symbols -> link error;
2. one strong + weak(s) -> choose strong;
3. multiple weak -> arbitrary choice; dangerous, no type checking.

> [!IMPORTANT]
> Linker does not type-check. Weak symbols with different types can silently corrupt nearby data.

Recommendations: use `static` for private globals/functions; use `extern` declarations in headers; define globals in exactly one `.c`.

## 7.8 Relocation

- Assembler emits relocation entries telling linker which code/data locations need patching.
- `.rel.text`: instruction references needing relocation.
- `.rel.data`: pointer/global data needing relocation.
- RISC-V calls often use relocation types like `R_RISCV_CALL_PLT` and patch `auipc/jalr`.

Relocation steps:
1. merge sections of same type;
2. assign runtime addresses to sections/symbols;
3. patch references using relocation entries.

## 7.9 Loading

Loader maps executable segments into virtual memory:
- read-only code/rodata;
- read/write `.data/.bss`;
- heap/stack;
- memory-mapped shared libraries.

Executable contains program header table for loader; section header table is mainly for link/debug.

## 7.10 Static Libraries

- Static library `.a` archives many `.o` members.
- Linker scans command line left-to-right, maintains unresolved-reference set.
- When archive member resolves current unresolved symbol, linker pulls that member.
- Library order matters: put `main.o ... -lfoo`, not `-lfoo main.o`.
- Your own `malloc` can override libc if symbol resolution finds it first/stronger.

## 7.11 Shared Libraries

- Shared `.so` linked dynamically at load time or run time.
- Load-time: dynamic linker `ld-linux.so` maps needed `.so` and relocates.
- Run-time: `dlopen`, `dlsym`, `dlclose`.
- `LD_PRELOAD` can interpose symbols such as `malloc`; cannot easily interpose statically linked startup `_start`.

## 7.12 PIC, GOT, PLT

==**PIC**==: position-independent code; shared libraries can load at any address.
- GOT: table of absolute addresses for globals/functions, updated by dynamic linker.
- PLT: code stubs/trampolines for external function calls; in text/plt.
- GOT/GOT.plt: in data-like section because dynamic linker writes addresses.
- RISC-V PIC uses PC-relative `auipc` + load/jalr patterns.

## Quiz Traps

- Linker can enable **LTO** and tune layout/page alignment; loader does actual memory loading.
- `.symtab` includes global variables, external functions, static locals.
- Incorrect symbol rule: "two weak symbols are not allowed" is false.
- Dynamic linking is not faster execution; main benefits are sharing, updates, build/link flexibility.
