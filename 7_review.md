# Lec 7: Linking

## Exam Facts

- ==**Linking**==: combines object files and libraries into an executable/shared object.
- **Benefits**: modularity, separate compilation, library reuse, easier maintenance, time/space efficiency.
- **Standard linker**: Unix `ld`; compiler driver `gcc` invokes it.
- **ELF tools**: `readelf` for details; `objdump` for code/relocs; `nm` for symbols.
- **Linker jobs**: **symbol resolution, relocation, section merging, library handling**, and may coordinate LTO/layout.
- **Not linker job**: loading into memory; that is loader/dynamic linker work.
- **Object file kinds**: relocatable `.o`, executable, shared object `.so`.
- **ELF sections**: `.text`, `.rodata`, `.data`, `.bss`, `.symtab`, `.rel.text`, `.rel.data`, `.debug`, section header table.
- **Linker symbols**: global, external, local static; automatic locals are **not** linker symbols.
- **Strong/weak**: strong = functions + initialized globals; weak/common = uninitialized globals in old common model.
- **Duplicate rules**: multiple strong -> error; strong beats weak; multiple weak -> arbitrary/common; linker **does not type-check**.
- **Static library order**: put libraries after objects that need them.
- **Dynamic linking data structures**: **GOT + PLT**.
- **Placement**: PLT in executable code (`.plt/.text`); GOT/GOT.plt writable data.

## 1. Linking

```text
main.c -> main.o
sum.c  -> sum.o
main.o + sum.o + libs -> linker -> executable
```

`gcc -o prog main.c sum.c` performs all phases, then invokes `ld`.

Compiler driver path: `cpp/cc1/as` produce relocatable `.o`; `ld` produces the executable.

## 2. Why Linkers?

| Benefit | Meaning |
|---|---|
| modularity | split code into files |
| separate compilation | recompile changed module only |
| libraries | reuse libc/libm/project libs |
| easier maintenance | independent modules |
| time efficiency | compile in parallel/incrementally |
| space efficiency | static archives pull used members; shared libs share code pages |

## 3. What Linkers Do

### 3.1 Symbol Resolution

Bind every symbol reference to exactly one definition.

```c
void swap(){}   // defines swap
swap();         // references swap
int *xp=&x;     // defines xp, references x
```

### 3.2 Relocation

After deciding final section/symbol addresses, linker patches code/data references using relocation entries.

```text
merge .text/.data
assign final addresses
patch calls/global-address loads/data pointers
```

### 3.3 Other Jobs

- scan static archives.
- section alignment/page layout.
- dynamic relocation metadata.
- LTO if `-flto`.

## 4. Object File Kinds

| Kind | Extension | Use |
|---|---|---|
| relocatable | `.o` | input to linker |
| executable | `a.out`/no ext | load/run |
| shared object | `.so` | dynamically loaded library |

`.a` is an archive of `.o` files plus index, not a fourth ELF object kind.

## 5. ELF Object File Format

| Section/table | Meaning |
|---|---|
| ELF header | word size, endian, type, machine |
| program header | loadable segments for executable/shared object |
| `.text` | code |
| `.rodata` | constants/jump tables/strings |
| `.data` | initialized globals/statics |
| `.bss` | zero globals/statics; no file bytes |
| `.symtab` | symbol table |
| `.rel.text/.rela.text` | code relocation entries |
| `.rel.data/.rela.data` | data relocation entries |
| section header table | section metadata |

ELF sections include `.text/.data/.bss/.symtab`; stack/register file/`.static` are **not** ELF sections.

## 6. Linker Symbols

| Type | Example |
|---|---|
| global defined here | non-static function/global |
| external reference | `printf`, `sum` declared but defined elsewhere |
| local linker symbol | `static` function/global |

Not linker symbols:

- automatic local variables.
- parameters.
- register temporaries.

### 6.1 `.symtab` Pattern

```c
int incr=1;                 // global symbol
static int foo(int a){      // local linker symbol
  int b=a+incr;             // a,b not linker symbols
  return b;
}
int main(){ printf("%d",foo(5)); } // main, printf ref
```

Symbols: `incr`, `foo`, `main`, `printf`; string literals may appear as compiler-generated local objects.

### 6.2 Static Local Variables

```c
int f(){ static int x=17; return x++; }
```

Function-scope `static` has storage in `.data/.bss` and a compiler-generated local linker symbol. Ordinary local variables do not.

## 7. Duplicate Symbol Resolution

| Declaration/definition | Strength |
|---|---|
| function definition | strong |
| initialized global | strong |
| uninitialized global | weak/common in traditional model |
| `extern int x;` | reference only |

Rules:

1. two strong same name -> link error.
2. one strong + weak(s) -> choose strong.
3. multiple weak -> arbitrary/common.

`static` file-scope symbols are local to one object file; same name in another file is not a global duplicate.

### 7.1 Silent Error Pattern

```c
// a.c
double x = 3.14;   // strong

// main.c
long x;            // weak/common
```

May link with garbage behavior because linker does not type-check.

Recommendations:

- use `static` for file-local.
- initialize intended globals.
- put `extern` declarations in headers.
- one definition in one `.c`.
- use `-fno-common`.

Header pattern: declarations use `extern`; exactly one `.c` file owns the definition/initialization.

## 8. Relocation

Relocation entry includes:

| Field | Meaning |
|---|---|
| offset | where to patch |
| symbol | target symbol |
| type | encoding/computation rule |
| addend | constant adjustment |

Compiler/assembler emits `.rel.text/.rel.data` or `.rela.*`; linker consumes them because it does not know final addresses before layout.

### 8.1 RISC-V Relocation Shape

```asm
auipc a0,%pcrel_hi(array)
addi  a0,a0,%pcrel_lo(array)

auipc ra,%pcrel_hi(sum)
jalr  ra,%pcrel_lo(sum)(ra)
```

| Reloc | Use |
|---|---|
| `R_RISCV_PCREL_HI20` | high 20 PC-relative |
| `R_RISCV_PCREL_LO12_I` | low 12 I-type |
| `R_RISCV_PCREL_LO12_S` | low 12 S-type |
| `R_RISCV_CALL_PLT` | call via PLT-capable sequence |

## 9. Loading Executables

Loader maps ELF segments:

```text
low unmapped page
.text/.rodata  r-x/r--
.data/.bss     rw-
heap           grows up
mmap/shared libs
stack          grows down
kernel space   protected
```

Dynamically linked executable:

```text
kernel maps program + ld-linux.so -> dynamic linker maps .so deps -> relocates -> startup -> main
```

## 10. Static Libraries

Create:

```bash
ar rs libvector.a addvec.o multvec.o
```

Link:

```bash
gcc main.o -L. -lvector -o prog
```

`-lvector` searches `libvector.a` / `libvector.so`.

Static vs shared library:

| Static `.a` | Shared `.so` |
|---|---|
| archive members copied into executable at link time | mapped/relocated by loader/dynamic linker |
| larger executable, no runtime `.so` dependency | smaller executable, runtime dependency |
| library update needs relink/rebuild | ABI-compatible update can benefit programs without relink |

Static archives are **pay-as-you-go**: only needed members are copied.

### 10.1 Static Linker Algorithm

Left-to-right scan:

| Input | Action |
|---|---|
| object `.o` | include unconditionally |
| archive `.a` | include only members resolving current unresolved refs |

If unresolved after scan -> link error.

If `main.o` defines `malloc`, references to `malloc` can resolve before libc's archive member is pulled; this is why your own `malloc` can override libc's during static linking.

### 10.2 Library Order Matters

```bash
gcc main.o -lfoo     # OK if main.o needs foo
gcc -lfoo main.o     # often fails
```

Circular libs:

```bash
gcc main.o -lA -lB -lA
```

### 10.3 Link Error Triage

| Symptom | Likely cause | Fix |
|---|---|---|
| `undefined reference` | missing object/lib or wrong library order | add object/lib; put `-lfoo` after users |
| `multiple definition` | duplicate strong global/function | one definition; use `extern` declarations |
| type garbage but link succeeds | strong/weak mismatch; linker no type check | fix declarations; use headers + `-fno-common` |

## 11. Shared Libraries / Dynamic Linking

Advantages:

- significant RAM/disk savings.
- centralized security/bug-fix updates if ABI compatible.
- fast link/build time.

Not advantage: faster execution in general.

### 11.1 Load-Time Dynamic Linking

```bash
gcc -shared -fpic -o libv.so addvec.c multvec.c
gcc main.o ./libv.so -o prog
```

At load: `ld-linux.so` maps deps, resolves needed relocations/lazy bindings.

`PT_INTERP` in the executable names the dynamic linker path; the kernel maps the program and `ld-linux.so`, then the dynamic linker maps needed `.so` files.

Load-time dynamic linking produces a **partially linked executable**; final shared-library addresses are fixed by the dynamic linker at load time.

### 11.2 Run-Time Dynamic Linking

```c
void *h = dlopen("./libv.so", RTLD_LAZY);
void (*f)(int*,int*,int*,int)=dlsym(h,"addvec");
f(x,y,z,2);
dlclose(h);
```

Used for plugins/modules.

### 11.3 Runtime Interposition

`LD_PRELOAD=./wrap.so prog` loads `wrap.so` first, so same-name functions can intercept later library calls.

Limit: cannot replace code already executed before interposition, such as `_start`; wrappers often intercept `__libc_start_main` or libc functions instead.

## 12. PIC, GOT, PLT

==**PIC**==: position-independent code; shared library code works at any load address.

Dynamic linking uses **GOT + PLT**; not jump table or section header table.

PIC data trick: code and data keep a fixed relative distance inside the loaded object, so code can use PC-relative addressing to reach the GOT.

### 12.1 GOT

==**GOT**==: Global Offset Table, writable table of runtime addresses for global data/external symbols.

```asm
auipc a0,%got_pcrel_hi(my_var)
ld    a0,%pcrel_lo(...)(a0)   # address from GOT
lw    a0,0(a0)                # value
```

### 12.2 PLT

==**PLT**==: Procedure Linkage Table, executable stubs for external calls.

Lazy binding:

```text
call -> PLT stub -> GOT.plt entry
first call -> resolver patches GOT.plt
later calls -> real function directly via GOT.plt
```

### 12.3 Memory Placement

| Structure | Place | Writable | Executable |
|---|---|---|---|
| `.text` | code | no | yes |
| `.plt` | code stubs | no | yes |
| `.got` | data table | yes | no |
| `.got.plt` | lazy function addr table | yes | no |
| `.data/.bss` | writable data | yes | no |

PLT is in `.text/.plt`; GOT and GOT.plt are in `.data`-like writable region.
