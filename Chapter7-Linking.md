# Chapter 7: Linking

> CSC3060 – Computer Architecture

---

## 1. Linking

**Linking** is the process of collecting and combining various pieces of code and data into a single object file that can be loaded into memory and executed.

- **Linker** is the system program that performs linking.
- Linkers are important because they enable **separate compilation**.
- Separate compilation allows us to decompose a large application into smaller, more manageable modules that can be modified and compiled separately. When we change one of these modules, we simply recompile it and relink the application, without recompiling other files.

### Example C Program

```c
// main.c
int sum(int *a, int n);

int array[2] = {1, 2};

int main(int argc, char** argv)
{
    int val = sum(array, 2);
    return val;
}
```

```c
// sum.c
int sum(int *a, int n)
{
    int i, s = 0;
    for (i = 0; i < n; i++) {
        s += a[i];
    }
    return s;
}
```

---

## 2. Compiler Drivers and Linking

Programs are translated and linked using a **compiler driver**:
```bash
linux> gcc -Og -o prog main.c sum.c
linux> ./prog
```

Pipeline:
1. **Source files:** `main.c`, `sum.c`.
2. **Translators (cpp, cc1, as):** produce separately compiled relocatable object files `main.o`, `sum.o`.
3. **Linker (ld):** produces a fully linked executable object file `prog` (contains code and data for all functions defined in `main.c` and `sum.c`).

### Why Linkers? — Modularity

- Programs can be written as a collection of smaller source files, rather than one monolithic mass.
- Can build libraries of common functions — e.g., math library (`/lib/libm`), standard C library (`/lib/libc`).
- Header files in C declare types that are defined in libraries.

### Why Linkers? — Efficiency

**Time: separate compilation**
- Change one source file, compile, and then relink. No need to recompile others.
- Can compile multiple files concurrently (parallel processing).

**Space: libraries** — common functions can be aggregated into a single file:
- **Option 1: Static Linking.** Executable files and running memory images contain only the library code they actually use.
- **Option 2: Dynamic Linking.** Executable files contain no library code. During execution, a single copy of library code can be shared across all executing processes.

---

## 3. What Do Linkers Do?

### Symbol Resolution

Programs define and reference symbols (global variables and functions):
```c
void swap() {…}     /* define symbol swap */
swap();             /* reference symbol swap */
int *xp = &x;       /* define symbol xp, reference x */
```

- Symbol definitions are stored in an object file (by the assembler) in the **symbol table**.
- Symbol table is an array of entries — each entry includes name, size, and location of symbol.
- During the symbol resolution step, the linker associates each symbol reference with exactly one symbol definition.

### Relocation

- Merges separate code and data sections into single sections.
- Relocates symbols from their relative locations in the `.o` files to their final absolute memory locations in the executable.
- Updates all references to these symbols to reflect their new positions.

---

## 4. Three Kinds of Object Files (Modules)

| Kind | Description |
|---|---|
| **Relocatable object file (`.o`)** | Contains code and data in a form that can be combined with other relocatable object files to form an executable object file. Each `.o` file is produced from exactly one source (`.c`) file. |
| **Executable object file (`a.out`)** | Contains code and data in a form that can be copied directly into memory and then executed. |
| **Shared object file (`.so`)** | Special type of relocatable object file that can be loaded into memory and linked dynamically, at either load time or run time. Called Dynamic Link Libraries (DLLs) by Windows. |

---

## 5. Executable and Linkable Format (ELF)

Standard binary format for object files. One unified format for:
- Relocatable object files (`.o`).
- Executable object files (`a.out`).
- Shared object files (`.so`).

Generic name: **ELF binaries**.

### ELF Object File Format

| Section | Description |
|---|---|
| ELF header | Word size, byte ordering, file type (`.o`, exec, `.so`), machine type, etc. |
| Segment header table (for OS) | Page size, virtual address memory segments (sections), segment sizes. (Required for executables.) |
| `.text` | Code. |
| `.rodata` | Read-only data: jump tables, string constants, … |
| `.data` | Initialized global variables. |
| `.bss` | Uninitialized global variables. "Block Started by Symbol" / "Better Save Space". Has section header but occupies no space. |
| `.symtab` | Symbol table — procedure and static variable names; section names and locations. |
| `.rel.text` | Relocation info for `.text` section — addresses of instructions that will need to be modified in the executable; instructions for modifying. |
| `.rel.data` | Relocation info for `.data` section — addresses of pointer data that will need to be modified in the merged executable. |
| `.debug` | Info for symbolic debugging (`gcc -g`). |
| Section header table | Offsets and sizes of each section (for execution and debugging). |

---

## 6. Linker Symbols

- **Global symbols:** symbols defined by module m that can be referenced by other modules. E.g., non-static C functions and non-static global variables.
- **External symbols:** global symbols that are referenced by module m but defined by some other module.
- **Local symbols:** symbols that are defined and referenced exclusively by module m. E.g., C functions and global variables defined with the `static` attribute.
  - Local linker symbols are NOT local program variables.

### Step 1: Symbol Resolution (in our example)

```c
int sum(int *a, int n);              // referencing a global... that's defined elsewhere
int array[2] = {1, 2};               // defining a global
int main(int argc, char **argv)      // defining a global
{
    int val = sum(array, 2);         // referencing a global... that's defined elsewhere
    return val;                      // linker knows nothing of val
}

int sum(int *a, int n)               // defining a global
{
    int i, s = 0;                    // linker knows nothing of i or s
    ...
}
```

### Symbol Identification Quiz

```c
// symbols.c
int incr = 1;
static int foo(int a) {
    int b = a + incr;
    return b;
}

int main(int argc, char* argv[]) {
    printf("%d\n", foo(5));
    return 0;
}
```

Which of the following names will be in the symbol table of `symbols.o`?
- Candidates: `incr`, `foo`, `a`, `argc`, `argv`, `b`, `main`, `printf`, `"%d\n"`.
- **Answer:** `incr`, `foo`, `main`, `printf`. (Can actually make a case for `"%d\n"`: it's a global constant string in read-only section, so it will have a name.)
- Find this with `readelf -s symbols.o`.

### Local Symbols

Local non-static C variables vs local static C variables:
- **Local non-static:** stored on the stack.
- **Local static:** stored in either `.bss` or `.data`.

```c
static int x = 15;

int f() { static int x = 17; return x++; }
int g() { static int x = 19; return x += 14; }
int h() { return x += 27; }
```

The compiler allocates space in `.data` for each definition of `x`. Creates local symbols in the symbol table with unique names, e.g., `x`, `x.1721`, `x.1724`.

---

## 7. How Linker Resolves Duplicate Definitions

Program symbols are either **strong** or **weak**:
- **Strong:** procedures and initialized globals.
- **Weak:** uninitialized globals, or ones declared with specifier `extern`.

```c
// p1.c                  // p2.c
int foo = 5;             int foo;
p1() { }                 p2() { }
// (strong, strong)      // (weak, strong)
```

### Linker's Symbol Rules

- **Rule 1:** Multiple strong symbols are not allowed. Each item can be defined only once. Otherwise → linker error.
- **Rule 2:** Given a strong symbol and multiple weak symbols, choose the strong symbol. References to the weak symbol resolve to the strong symbol.
- **Rule 3:** If there are multiple weak symbols, pick an arbitrary one. Can override this with `gcc -fno-common` to force the compiler to give a "multiple definition error".

### Insidious Errors

```c
// File 1
int x = 15213;            /* strong symbol */
int main(int argc, char *argv[]) {
    f();
    printf("%d\n", x);
    return 0;
}

// File 2
int x;                    /* weak symbol */
void f() { x = 15212; }
```

Compiles without any errors or warnings. **What gets printed? `15212`.**

### Linker Puzzles

| Configuration | Result |
|---|---|
| `int x; p1() {}` and `p1() {}` | Link-time error: two strong symbols (`p1`). |
| `int x; p1() {}` and `int x; p2() {}` | References to `x` will refer to the same uninitialized int. Is this what you really want? |
| `int x; p1() {}` and `double x; p2() {}` | Writes to `x` in `p2` might overwrite `y`! **Evil!** |
| `int x = 7; int y = 5; p1() {}` and `double x; p2() {}` | Writes to `x` in `p2` might overwrite `y`! **Nasty!** |
| `int x = 7; p1() {}` and `int x; p2() {}` | References to `x` will refer to the same initialized variable. |

> **Important: Linker does not do type checking.**

### Type Mismatch Example

```c
// mismatch-main.c
long int x;                                  /* Weak symbol */
int main(int argc, char *argv[]) {
    printf("%ld\n", x);
    return 0;
}

// mismatch-variable.c
double x = 3.14;                             /* Global strong symbol */
```

Compiles without any errors or warnings. What gets printed? Garbage — because `printf` interprets `double` bytes as `long`.

### Global Variables — Recommendations

- **Avoid if you can.**
- Otherwise:
  - Use `static` if you can. (Static globals vs static locals.)
  - Initialize if you define a global variable.
  - Use `extern` if you reference an external global variable. Treated as a weak symbol, but also causes a linker error if not defined in some file.

### Use of `extern` in `.h` Files (#1)

```c
// global.h
extern int g;
int f();

// c1.c
#include "global.h"
int f() { return g + 1; }

// c2.c
#include <stdio.h>
#include "global.h"
int g = 0;
int main(int argc, char argv[]) {
    int t = f();
    printf("Calling f yields %d\n", t);
    return 0;
}
```

### Use of `.h` Files (#2) — controlled initialization with macro

```c
// global.h
#ifdef INITIALIZE
  int g = 23;
  static int init = 1;
#else
  extern int g;
  static int init = 0;
#endif

// c1.c
#include "global.h"
int f() { return g + 1; }

// c2.c
#define INITIALIZE
#include <stdio.h>
#include "global.h"

int main(int argc, char** argv) {
    if (init) /* do something, e.g., g = 31; */ ;
    int t = f();
    printf("Calling f yields %d\n", t);
    return 0;
}
```

---

## 8. Step 2: Relocation

After symbol resolution, relocatable object files are merged into the executable object file:
- System code (`main()` lives among CRT and standard C library code).
- `main.o` contributes `main()` and `int array[2] = {1, 2}`.
- `sum.o` contributes `sum()`.
- `.text`, `.data`, `.symtab`, `.debug` are merged into corresponding executable sections.

### Relocation Entries

```c
typedef struct {
    int offset;
    int symbol:24, type:8;
} elf32_rel;     // ELF relocation entry
```
The `symbol` field is an index into `.symtab`.

**Source: `objdump -r -d main.o`**

```asm
0000000000000000 <main>:
   0:  48 83 ec 08          sub    $0x8, %rsp
   4:  be 02 00 00 00       mov    $0x2, %esi
   9:  bf 00 00 00 00       mov    $0x0, %edi      # %edi = &array
                a: R_X86_64_32 array               # Relocation entry

   e:  e8 00 00 00 00       callq  13 <main+0x13>  # sum()
                f: R_X86_64_PC32 sum-0x4           # Relocation entry
  13:  48 83 c4 08          add    $0x8, %rsp
  17:  c3                   retq
```

### Relocated `.text` Section

**Source: `objdump -d prog`**

```asm
00000000004004d0 <main>:
  4004d0:  48 83 ec 08       sub    $0x8, %rsp
  4004d4:  be 02 00 00 00    mov    $0x2, %esi
  4004d9:  bf 18 10 60 00    mov    $0x601018, %edi  # %edi = &array
  4004de:  e8 05 00 00 00    callq  4004e8 <sum>    # sum()
  4004e3:  48 83 c4 08       add    $0x8, %rsp
  4004e7:  c3                retq

00000000004004e8 <sum>:
  4004e8:  b8 00 00 00 00    mov    $0x0, %eax
  4004ed:  ba 00 00 00 00    mov    $0x0, %edx
  4004f2:  eb 09             jmp    4004fd <sum+0x15>
  4004f4:  48 63 ca          movslq %edx, %rcx
  4004f7:  03 04 8f          add    (%rdi, %rcx, 4), %eax
  4004fa:  83 c2 01          add    $0x1, %edx
  4004fd:  39 f2             cmp    %esi, %edx
  4004ff:  7c f3             jl     4004f4 <sum+0xc>
  400501:  f3 c3             repz retq
```

> `callq` instruction uses PC-relative addressing for `sum()`: `0x4004e8 = 0x4004e3 + 0x5`.

### Relocation for RISC-V

```asm
0000000000000000 <main>:
   ...
   # Load the address of 'array' into register a0
   4:  00000517         auipc  a0, 0x0
   8:  00050513         addi   a0, a0, 0      # holds &array
   # Load the immediate value 2 into register a1
   c:  4589             li     a1, 2          # a1 now holds 2
   # Call 'sum'
   e:  00000097         auipc  ra, 0x0
  12:  000080e7         jalr   ra             # jump and link to sum
```

| Offset | Symbol | Type | Notes |
|---|---|---|---|
| 4 | array | `R_RISCV_PCREL_HI20` | Top 20b |
| 8 | array | `R_RISCV_PCREL_LO12_I` | Low 12b |
| e | sum | `R_RISCV_CALL_PLT` | |

---

## 9. Loading Executable Object Files

Process virtual address space layout (low → high):

| Region | Source |
|---|---|
| Unused (0 – 0x400000) | — |
| Read-only code segment (`.init`, `.text`, `.rodata`) | Loaded from the executable file |
| Read/write data segment (`.data`, `.bss`) | Loaded from the executable file |
| Run-time heap (created by `malloc`, grows toward `brk`) | — |
| Memory-mapped region for shared libraries | Dynamic loader |
| User stack (created at runtime, grows down, `%rsp`) | — |
| Kernel virtual memory (invisible to user code) | OS |

The executable file itself contains: ELF header, Program header table (required for executables), `.init`, `.text`, `.rodata`, `.data`, `.bss`, `.symtab`, `.debug`, `.line`, `.strtab`, Section header table (required for relocatables).

---

## 10. Packaging Commonly Used Functions

How to package functions commonly used by programmers? (Math, I/O, memory management, string manipulation, etc.)

Awkward, given the linker framework so far:

- **Option 1:** Put all functions into a single source file. Programmers link the big object file into their programs (e.g., `ld -o prog main.o lib.o`). Space- and time-inefficient.
- **Option 2:** Put each function in a separate source file. Programmers explicitly link appropriate binaries into their programs (e.g., `ld -o prog main.o exp.o sin.o atoi.o random.o malloc.o strcpy.o strcmp.o …`). More efficient, but burdensome on the programmer.

### Old-Fashioned Solution: Static Libraries

Static libraries (`.a` archive files):
- Concatenate related relocatable object files into a single file with an index (called an **archive**).
- Enhance the linker so that it tries to resolve unresolved external references by looking for the symbols in one or more archives.
- If an archive member file resolves a reference, link it into the executable.
- **Pay-as-you-go.**

### Creating Static Libraries

```bash
unix> ar rs libc.a atoi.o printf.o … random.o
```
Archiver allows incremental updates (option `ru`): recompile the function that changes and replace the `.o` file in the archive.

### Commonly Used Libraries

- **`libc.a` (C standard library):** 4.6 MB archive of 1496 object files. I/O, memory allocation, signal handling, string handling, date and time, random numbers, integer math.
- **`libm.a` (C math library):** 2 MB archive of 444 object files. Floating point math (`sin`, `cos`, `tan`, `log`, `exp`, `sqrt`, …).

```bash
% ar -t libm.a | sort
…
e_acos.o
e_acosf.o
e_acosh.o
e_asin.o
…

% ar -t libc.a | sort
…
fork.o
fprintf.o
fpu_control.o
fputc.o
freopen.o
fscanf.o
fseek.o
fstab.o
…
```

> The convention is that libraries are always prefixed with "lib".
> `$(CC) $(CFLAGS) -o csim csim.c cachelab.c -lm`

### Linking with Static Libraries — Example

```c
// libvector.a contents:
// addvec.c
void addvec(int *x, int *y, int *z, int n) {
    int i;
    for (i = 0; i < n; i++) z[i] = x[i] + y[i];
}

// multvec.c
void multvec(int *x, int *y, int *z, int n) {
    int i;
    for (i = 0; i < n; i++) z[i] = x[i] * y[i];
}

// main2.c
#include <stdio.h>
#include "vector.h"

int x[2] = {1, 2};
int y[2] = {3, 4};
int z[2];

int main(int argc, char** argv) {
    addvec(x, y, z, 2);
    printf("z = [%d %d]\n", z[0], z[1]);
    return 0;
}
```

Build pipeline:
- Translators → `main2.o`.
- Archiver creates `libvector.a` from `addvec.o`, `multvec.o`.
- Linker combines `main2.o` + `addvec.o` (from `libvector.a`) + `printf.o` and any other modules called by `printf.o` (from `libc.a`) → `prog2c`.

### Using Static Libraries — Linker Algorithm

The linker's algorithm for resolving external references:
1. Scan `.o` files and `.a` files in the command line order.
2. During the scan, keep a list of the current unresolved references (a "Wanted list" / TO-DO list).
3. As each new `.o` or `.a` file `obj` is encountered, try to resolve each unresolved reference in the list against the symbols defined in `obj`.
4. If any entries are in the Wanted list at the end of the scan, then there is an error.

> **Problem: command line order matters!**
> **Moral: put libraries at the end of the command line.**

```bash
unix> gcc -L. libtest.o -lmine            # OK
unix> gcc -L. -lmine libtest.o            # ERROR
# libtest.o: In function 'main':
# libtest.o(.text+0x4): undefined reference to 'libfun'
```

### Why Order Matters

```bash
unix> gcc -L. -lmine libtest.o
```

What happens:
1. **Step 1:** The linker sees `-lmine` (the library). At this point, the Wanted list is empty because no object files have been processed yet. The linker looks inside `libmine`, sees it has functions, but since nothing has asked for them yet, it ignores the library.
2. **Step 2:** The linker sees `libtest.o`. It finds calls to functions inside `libtest.o`, say `libfun()`. It adds those functions to the Wanted list.
3. **Step 3:** End of command. The Wanted list still contains the functions from `libtest.o` (i.e., `libfun()`). The linker already passed `libmine` and couldn't grab the code again.

**Result:** undefined reference error.

### Why Your Own Malloc Overrides libc malloc()

```bash
unix> gcc a.o b.o main.o /usr/libc
```
Assume `a.c` and `b.c` call `malloc`, and a `malloc()` is defined in `main.c`:

| Step | File | Action regarding `malloc` |
|---|---|---|
| 1 | `a.o` | Sees call `malloc` → adds `malloc` to Wanted list. |
| 2 | `b.o` | Sees call `malloc` — already in the Wanted list (no change). |
| 3 | `main.o` | Sees `malloc` definition → resolves the undefined references from steps 1 & 2. |
| 4 | `/usr/libc.a` | `malloc` is already resolved → no actions. |

---

## 11. Modern Solution: Shared Libraries

Static libraries have the following disadvantages:
- Duplication in the stored executables (every function needs `libc`).
- Duplication in the running executables.
- Minor bug fixes of system libraries require each application to explicitly relink. Rebuild everything with glibc? (See: CVE-2015-7547 glibc `getaddrinfo` stack-based vulnerability.)

**Modern solution: Shared Libraries.**
- Object files that contain code and data that are loaded and linked into an application dynamically, at either load-time or run-time.
- Also called: dynamic link libraries, DLLs, `.so` files.

### When Dynamic Linking Happens

**Load-time linking** (executable is first loaded and run):
- Common case for Linux, handled automatically by the dynamic linker (`ld-linux.so`).
- Standard C library (`libc.so`) is usually dynamically linked.

**Run-time linking** (after the program has begun):
- In Linux, this is done by calls to the `dlopen()` interface.
- Use cases: distributing software, high-performance web servers, runtime library interpositioning.

> Shared library routines can be shared by multiple processes. (More on this when we learn about virtual memory.)

### What Happens When `ld-linux.so` is Loaded

- **Normal Shared Library (e.g., `libc.so`):** When the OS loader sees this, it maps it into memory and waits for the main program to call functions inside it.
- **The Dynamic Linker (`ld-linux.so`):** When the OS loader sees an executable that has `PT_INTERP` (a special entry in the ELF Program Header, which contains the absolute file path to the dynamic linker) pointing to `ld-linux.so`, it does something special:
  1. It loads `ld-linux.so` into memory.
  2. Instead of running your program's `main()`, it jumps straight to the entry point of `ld-linux.so`.
  3. It passes control to `ld-linux.so`, effectively saying: "Here is the user's program and the list of libraries they need. You fix up the addresses, load the dependencies, and then jump to the user's `main()` when you are ready."

### Runtime Library Interpositioning and `LD_PRELOAD`

- When you launch a program, the Linux dynamic loader (`ld.so`) looks for the dynamic libraries your program needs (like `libc.so`) and resolves the function symbols.
- If you set an environment variable called `LD_PRELOAD`, you force the dynamic loader to load your custom shared library first, before it loads `libc` or anything else.
- If your custom library contains a function with the exact same name as a standard function (e.g., `malloc`), the dynamic loader says, "I found `malloc` in the preloaded library!" and wires all calls to your custom function instead of the real one in `libc`.
- This allows you to intercept the library calls you want.
- You may not intercept `_start` (it is in `crt1.o` and is statically linked), but you can intercept `__libc_start_main`.

### Dynamic Linking at Load-Time

```bash
unix> gcc -shared -o libvector.so addvec.c multvec.c -fpic
```

Build pipeline:
- Translators → `main2.o` + relocation/symbol table info.
- Linker (ld) takes `main2.o` + `libc.so` + `libvector.so` → produces a **partially linked** executable object file `prog2l`.
- At runtime: Loader (`execve`) → Dynamic linker (`ld-linux.so`) loads `libc.so` and `libvector.so` code and data → fully linked executable in memory.

> Try: `ldd prog2l`, `objdump -t libvector.so`, `objdump -rd libvector.so`.

### Dynamic Linking at Run-Time

```c
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

int x[2] = {1, 2};
int y[2] = {3, 4};
int z[2];

int main(int argc, char** argv) {
    void *handle;
    void (*addvec)(int *, int *, int *, int);
    char *error;

    /* Dynamically load the shared library that contains addvec() */
    handle = dlopen("./libvector.so", RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "%s\n", dlerror());
        exit(1);
    }

    /* Get a pointer to the addvec() function we just loaded */
    addvec = dlsym(handle, "addvec");
    if ((error = dlerror()) != NULL) {
        fprintf(stderr, "%s\n", error);
        exit(1);
    }

    /* Now we can call addvec() just like any other function */
    addvec(x, y, z, 2);
    printf("z = [%d %d]\n", z[0], z[1]);

    /* Unload the shared library */
    if (dlclose(handle) < 0) {
        fprintf(stderr, "%s\n", dlerror());
        exit(1);
    }
    return 0;
}
```

> `RTLD_LAZY` — don't resolve references until requested.

Build pipeline:
- Translators → `dll.o`.
- Linker has no information about the vector library at static-link time.
- At runtime: Loader (`execve`) → Dynamic linker (`ld-linux.so`) → call to dynamic linker via `dlopen` brings in `libvector.so`.

---

## 12. Position-Independent Code (PIC)

A key purpose of shared libraries is to allow multiple running processes to share the same library code in memory. So how do we share a single copy of code?

- One approach is to assign a dedicated chunk of the virtual address space to each shared library. This is very inflexible.
- A better approach is to compile library code so that it can be loaded and executed at any address. Such code is known as **Position-Independent Code (PIC)**.

### How PIC Works

Compilers generate PIC references to global variables by exploiting an interesting fact: no matter where we load an object module in memory, **the data segment is always allocated immediately after the code segment**. Therefore, the distance between any instruction in the code segment and any variable in the data segment is a runtime constant.

To exploit this fact, the compiler creates a table, called the **Global Offset Table (GOT)**, at the beginning of the data segment. The GOT contains an entry for each global data object that is referenced by the object module.

### GOT and PLT

In Linux, which uses the ELF (Executable and Linkable Format) file format, the **GOT (Global Offset Table)** and **PLT (Procedure Linkage Table)** are two crucial data structures used to support Dynamic Linking and Position-Independent Code (PIC).

When a program is compiled as a shared library, it doesn't know the absolute memory addresses of external functions (like `printf`) or global variables until the program is actually loaded into memory.

- **GOT:** When the executable is first loaded into memory, the dynamic linker (e.g., `ld-linux.so`) looks at the program's dependencies, finds where the shared libraries are loaded in memory, and updates the GOT with the actual absolute addresses of the variables and functions.
- **PLT:** It is a section of memory containing small executable code stubs (trampolines) for every external function the program calls. It lives in the read-only code section (`.text` or `.plt`).

### Memory Layout

```
code segment:    [.text]  [.plt]
data segment:    [.GOT]  [.GOT.plt]  [.data]  [.bss]
                  ↑ Pointers updated by the dynamic linker
```

Accessing an external global variable `my_var` (RISC-V example):
```asm
# 1. Calculate the PC-relative address of the GOT entry for 'my_var'
auipc a0, %got_pcrel_hi(my_var)
# 2. Load the actual address of 'my_var' from the GOT into a0
ld    a0, %pcrel_lo(...)(a0)
# 3. Load the actual value of 'my_var' (e.g., a 32-bit word)
lw    a0, 0(a0)
```

### Example: Main.c calls printf()

The compiler generates a pseudo instruction `call printf`. The assembler expands it to:
```asm
Label0: auipc ra, %pcrel_hi(printf@plt)   # Load upper 20 bits of PC-relative PLT offset
        jalr  ra, %pcrel_lo(Label0)(ra)   # Jump to the PLT stub and save return address
```

The `.plt` section does not exist initially. At link time, the linker creates a separate `.plt` section next to the `.text` section. For each external reference name, it creates one stub. In this `.plt` section, three instructions are present:
```asm
auipc t3, %hi(printf@got)   # the real address of printf() will be stored in GOT
ld    t3, %lo(...)(t3)       # load the address in GOT[printf] into register t3
jalr  t0, t3                 # jump to the real address of printf()
```

### Full Walkthrough

1. The compiler generates a pseudo instruction `call printf`.
2. The assembler expands the pseudo-instruction into two instructions:
   ```asm
   auipc ra, %pcrel_hi(printf@plt)
   jalr  ra, %pcrel_lo(...)(ra)
   ```
   The assembler leaves a relocation entry telling the linker, "Please update these two instructions to point to the PLT stub for `printf`."
3. The linker realizes `printf` is an external dynamic function. The linker automatically generates a small three-instruction sequence (the stub), creates the `.plt` section, and places these three instructions inside it:
   ```asm
   auipc t3, %hi(printf@got)
   ld    t3, %lo(...)(t3)
   jalr  t0, t3
   ```
4. The static linker knows you have an external call. So it creates a `.got.plt` section, and reserves 4B (or 8B) space for a 32(64)b address.
5. The dynamic linker will eventually fill in the real address of `printf()`.

### Summary

| Step | Phase | Action |
|---|---|---|
| Step 1 | Compile (static time) | The compiler generates a pseudo instruction. |
| Step 2 | Compile (static time) | The assembler expands it to AUIPC/JALR. Insert relocation entries. |
| Step 3 | Link (walk time) | The linker creates `.plt` section as the stub with AUIPC/LD/JALR instructions. |
| Step 4 | Link (walk time) | The linker creates one entry in GOT (4B for 32b, 8B for 64b). |
| Step 5 | Dynamic Linking (run time) | The dynamic linker fills in the real memory address. |
