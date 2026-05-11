# Chapter 5: Optimizing Program Performance

---

## 1. Program Optimization

The focus is now shifting from simply writing correct programs to writing programs that perform efficiently.

- Optimization matters because the right change in software can deliver orders-of-magnitude gains in speed, cost, power, and usability — often far more cheaply than changing hardware.
- In performance-critical systems, optimization is especially valuable because even small gains can lead to significant practical benefits.
- This chapter explores how programmers can evaluate performance, identify bottlenecks, and apply optimization techniques to reduce execution time.
- By connecting programming decisions to the behavior of the underlying hardware, this chapter shows that performance improvement is a deliberate and measurable process rather than a matter of trial and error.

### The DeepSeek Example

DeepSeek has put strong pressure on the LLM market by showing that highly capable models can be trained and served at much lower cost (2K GPU vs. 16K). DeepSeek's impact is roughly a 5×–20× improvement in cost efficiency in some comparisons.

While many AI experts believe that the major cost-performance improvements come from LLM models (such as MoE and GQA), the actual significant gains in efficiency stemmed from system performance enhancements.

| Optimization Type | Estimated Performance Contribution | Key Technologies |
|---|---|---|
| PTX & System-Level | ~60–70% | Direct PTX programming, thread optimization, cache management |
| Model Architecture | ~20–30% | MoE design, GQA attention |
| Training Techniques | ~10% | Multi-step scheduling, reinforcement learning |

---

## 2. Is Code Optimization Hard?

Code optimization is fun:
- If you like solving puzzles and mysteries
- Measurable wins could sometimes lead to high rewards
- Creative constraints (work with limits: time, resource, memory, …)
- And you like using all of your computer science knowledge

Performance / Efficiency is critical in every part of the system:
- Compilers (4180), Parallel Programming (4005), HPC (4107), and Computer Architecture (6031) are all related to these objectives.
- Data Structures (3200) and Algorithms (4120) make huge differences.

### Real-world examples

- **Google**: An extra 0.5 seconds in search page generation reduced traffic by about 20%.
- **Amazon**: Every 100 ms of latency can cost about 1% in sales.
- **High-frequency trading**: Microseconds to milliseconds of execution system improvement matter a lot.
- **Netflix**: Even small percentage improvements in video encoding can save millions of dollars in CDN annually.

---

## 3. Using the Compiler in Program Optimizations

An optimizing compiler is one of your most important partners in performance optimization work. It can automatically apply many low-level improvements. The first step is to enable compiler optimizations.

### Optimization Levels (`-On`)

| Flag | Meaning |
|---|---|
| `-O0` | No optimizations, very fast compilation. Generated code is for debugging. |
| `-O1` (= `-O`) | Basic optimizations. |
| `-O2` | **Recommended default.** Highly optimized code that is safe, stable, and does not increase code size by much. |
| `-O3` | Aggressive optimizations, including loop unrolling and SIMDilization. |
| `-O4` | Previously enabled Link-Time Optimization (LTO); now `-O4` also implies `-O3` along with LTO (`-O3 -flto`). |

> `-O3` trades more aggressive transformations for larger code, higher compile time, harder debugging, and sometimes worse runtime performance.

### Other Useful Flags

- `-O3 -flto` — Link-Time Optimization, enable whole program optimization.
- `-march=native` — Tells the compiler to generate code optimized specifically for the CPU architecture it is currently compiling on.
- `-mtune=native` — Optimizes the scheduling of instructions for the current CPU without breaking compatibility with older CPUs.
- Profile-Guided Optimization (PGO):
  - `-fprofile-generate`: compile an instrumented code to generate profiles.
  - `-fprofile-use`: use profile data to guide the code optimizations.
- `-Ofast` is simply `-O3 -ffast-math`. This allows the compiler to reorder FP ops.

### Why Not Let the Compiler Do All Optimizations?

While compilers are very powerful and sophisticated, they have their limits.

- **Compilers cannot change your algorithm** (this may change in the future).
- **Compilers must obey the rules and semantics of the programming language.** The compiler can only apply optimizations if the resulting program behaves exactly as if it were executing the unoptimized code.
  - Memory aliasing, FP associativity, function side effects, volatile variables, memory consistency.
- **Lack of runtime and domain knowledge** (this may demand dynamic translators).
  - Many specific optimization problems are NP-hard: optimal register allocation, optimal code scheduling, memory layout and packing, phase ordering.
- **Boundary crossing issues** (separate compilation) → Link-time optimizations.

### AI-Assisted Compiler Optimizations

- An optimizing compiler can automatically apply many low-level improvements, but it cannot replace good algorithms, good data layout, or measurement-driven engineering.
- Today's autotuning systems may search for a more efficient data layout.
- AI-assisted optimization has made real progress, especially in compiler heuristics tuning, optimization pass selection / phase ordering, inlining and register-allocation heuristics, code generation cost models, autotuning kernels for CPUs/GPUs/TPUs, and ML-guided scheduling.
- AI may understand the algorithm you implemented and substitute it with a more suitable or better-performing one in the future.
- Today, there is no end-to-end AI compiler yet, but such compilers may come out in the future.

---

## 4. General Goals of Compiler Optimizations

**Minimize the number of instructions:**
- Don't do calculations more than once → CSE (Common Subexpression Elimination).
- Don't do unnecessary calculations at all → DCE (Dead Code Elimination).
- Avoid slow instructions (multiplication, division) → SR (Strength Reduction).

**Minimize the execution cycles:**
- Keep everything in registers whenever possible → RA (Register Allocation).
- Exploit ILP to hide latencies → CS (Code Scheduling).
- Access memory in cache-friendly patterns → Locality Improvement.
- Load data from memory early, and only once → Preload & Redundant Load Elimination.

**Avoid branching:**
- Avoid branching (conditional move in x86, conditional execution in ARM).
- Loop unrolling, procedure inlining, and unswitching can reduce branches.

### Limits to Compiler Optimization

- Generally cannot improve algorithmic complexity.
- Must not cause any change in program behavior.
  - A programmer may not care about "edge case" behavior, but the compiler does not know that — e.g., exceptions, aliasing.
- Often only analyzes one function at a time.
  - Whole-program analysis ("LTO") is expensive, but gaining popularity (e.g., GCC and LLVM).
  - Exception: inlining merges many functions into one.
- Tricky to anticipate run-time inputs.
  - Profile-guided optimization can help with common cases, but…
  - "Worst case" performance can be just as important as "normal."
  - Especially for code exposed to malicious input (e.g., network servers).
- Memory dependencies are often unknown (e.g., memory aliasing).

---

## 5. Basic Compiler Optimizations

### Local vs Global Optimizations

- **Local optimizations** work inside a single basic block: constant folding, strength reduction, dead code elimination, (local) CSE, …
- **Global optimizations** process the entire control flow graph of a function: loop transformations, code motion, (global) CSE, …

### Data Dependence Graph and Control Flow Graph

- The **Control Flow Graph (CFG)** and the **Data Flow Graph (DFG)** are the two most critical data structures used to understand and optimize your code. While the CFG models the paths of execution, the DFG models the movement of information.
- By looking at both graphs simultaneously, the compiler knows exactly where the program is going (CFG) and what it is carrying along the way (DFG), which forms the mathematical foundation for almost all `-O1`, `-O2`, and `-O3` optimizations.
- The **Data Dependency Graph (DDG)** we used in code scheduling is a graph to track instruction execution order constraints. DFG is used to determine the values of the variable flow. It enables various optimizations such as CSE, DCE, reaching definitions, and register allocations.

### Constant Folding

Do arithmetic in the compiler. Any expression with constant inputs can be folded. Might even be able to remove library calls.

```c
long mask = 0xFF << 8;                  // → long mask = 0xFF00;
size_t namelen = strlen("Harry Bovik"); // → size_t namelen = 11;
```

### Dead Code Elimination (DCE)

Don't emit code that will never be executed:
```c
if (0) { puts("Kilroy was here"); }
if (1) { puts("Only bozos on this bus"); }
```

Don't emit code whose result is overwritten:
```c
x = 23;
x = 42;
```

These may look silly, but they:
- Can be produced by other optimizations.
- Can be produced by conditional compilations.
- Assignments to `x` might be far apart.

### Common Subexpression Elimination (CSE)

Factor out repeated calculations, only do them once.

```c
norm[i] = v[i].x * v[i].x + v[i].y * v[i].y;

// →
elt = &v[i];
x = elt->x;
y = elt->y;
norm[i] = x*x + y*y;
```

Note that the compiler is very good at CSE. Programmers are not supposed to do it.

**More CSE examples:**
```c
float dist2 = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2);
A = (A+B+C) * (A+B+D) - (A+D+B);   // A,B,C,D are integers; A+B is a common subexpression
A = B[i][j][k] + C[i][j][k];        // B,C are float[L][M][N]; i*(M*N)+j*N+k is a common subexpression
A = A->b->c->e + A->b->c->d;        // A->b->c is a common subexpression
```

### LICM (Loop Invariant Code Motion)

Move calculations out of a loop. Only valid if every iteration would produce the same result.

```c
long j;
for (j = 0; j < n; j++)
    a[n*i + j] = b[j];

// →
long j;
int ni = n*i;
for (j = 0; j < n; j++)
    a[ni + j] = b[j];
```

### Inlining

Copy body of a function into its caller(s).
- Can create opportunities for many other optimizations.
- Can make code much bigger and therefore slower (size; i-cache).

```c
int pred(int x) {
    if (x == 0) return 0;
    else        return x - 1;
}

int func(int y) {
    return pred(y) + pred(0) + pred(y+1);
}
```

After inlining:
```c
int func(int y) {
    int tmp;
    if (y == 0)    tmp  = 0;        else tmp  = y - 1;
    if (0 == 0)    tmp += 0;        else tmp += 0 - 1;     // always true
    if (y+1 == 0)  tmp += 0;        else tmp += (y+1) - 1; // does nothing
    return tmp;
}
```

After constant folding:
```c
int func(int y) {
    int tmp = 0;
    if (y != 0)  tmp  = y - 1;
    if (y != -1) tmp += y;
    return tmp;
}
```

### To Inline or Not To Inline

Procedure inlining is one of the most powerful optimizations a compiler can perform, but it is a delicate balancing act. The compiler must weigh the benefits of eliminating the function call overhead (and unlocking further optimizations) against the cost of code bloat.

Decision factors:
- Function size.
- Execution frequency — Is the call inside a loop? Is it an error handling call?
- Number of call sites.
- Constant arguments and secondary optimizations — constant parameters can trigger additional optimizations.
- Recursion and depth limits.
- GPU kernels try to inline all calls.

---

## 6. Memory Aliasing

### The Problem

```c
/* Sum rows of n x n matrix a and store in vector b. */
void sum_rows1(double *a, double *b, long n) {
    long i, j;
    for (i = 0; i < n; i++) {
        b[i] = 0;
        for (j = 0; j < n; j++)
            b[i] += a[i*n + j];
    }
}
```

Generated assembly:
```asm
.L_inner_loop:
    fld     fa5, 0(a3)            # 1. LOAD: Read b[i] from memory into fa5
    fld     fa4, 0(a4)            # 2. LOAD: Read current a[...] into fa4
    fadd.d  fa5, fa5, fa4         # 3. MATH: Add them together (Double precision)
    fsd     fa5, 0(a3)            # 4. STORE: Write the result back to b[i] in memory
    addi    a4, a4, 8             # 5. Move pointer 'a' forward by 8 bytes
    bne     a4, a5, .L_inner_loop # 6. If 'a' pointer hasn't reached the end, loop
```

Code updates `b[i]` on every iteration. Why couldn't the compiler optimize this away? Such as keeping it in a register?

If the compiler could prove `a` and `b` do not alias, the inner loop could be:
```asm
.L_inner_loop: // Allocating b[i] in register fa5
    fld     fa4, 0(a4)
    fadd.d  fa5, fa5, fa4
    addi    a4, a4, 8
    bne     a4, a5, .L_inner_loop
```

### How to Know if Aliasing Gets in the Way

Compilers can output detailed messages saying "cannot reorder memory operations" or "cannot vectorize loop due to potential memory dependencies". These messages are direct indicators that pointer aliasing is forcing the compiler to load/store to memory rather than keep values in registers.

```bash
# GCC
gcc -O3 -fopt-info-missed=missed_opts.txt my_program.c
# Clang (LLVM)
clang -O3 -Rpass-missed=.* -Rpass-analysis=.* my_program.c
```

When you see "data dependence" or "dependent memory operations," that is GCC saying: "I don't know if these pointers alias, so I must read/write to RAM in the exact order you wrote the code."

### Avoiding Aliasing Penalties

**1. Use a local variable for intermediate results:**
```c
void sum_rows2(double *a, double *b, long n) {
    long i, j;
    for (i = 0; i < n; i++) {
        double val = 0;
        for (j = 0; j < n; j++)
            val += a[i*n + j];
        b[i] = val;
    }
}
```

**2. Use the `restrict` keyword:**
```c
void sum_rows1(double *restrict a, double *restrict b, long n);
```
Tells the compiler that this is the "only" pointer to that memory location — no possible aliasing.

### Can't Move Function Calls Out of Loops

```c
// Quadratic — strlen called in every iteration
void lower_quadratic(char *s) {
    size_t i;
    for (i = 0; i < strlen(s); i++)
        if (s[i] >= 'A' && s[i] <= 'Z')
            s[i] += 'a' - 'A';
}

// Still quadratic — strlen recomputed after each modification
void lower_still_quadratic(char *s) {
    size_t i, n = strlen(s);
    for (i = 0; i < n; i++)
        if (s[i] >= 'A' && s[i] <= 'Z') {
            s[i] += 'a' - 'A';
            n = strlen(s);
        }
}

// Linear — strlen hoisted out
void lower_linear(char *s) {
    size_t i, n = strlen(s);
    for (i = 0; i < n; i++)
        if (s[i] >= 'A' && s[i] <= 'Z')
            s[i] += 'a' - 'A';
}
```

GCC knows `strlen` is a "pure function," but if the loop modifies the string, it must call `strlen` again. This is "accidentally quadratic" complexity — the programmer probably didn't intend it to be this slow, but it is anyway.

> Quadratic is already too slow. Even n log n can be too slow — database wranglers spend a lot of time avoiding sorting.

---

## 7. Modern CPU Design

A modern CPU has two main parts:

**Instruction Control:**
- Fetch → Instruction Cache → Instruction Decode → Operations.
- Retirement Unit, Register File, Register Updates.
- Branch prediction.

**Execution:**
- Functional Units (Branch, Arith × multiple, Load, Store) operate in parallel.
- Operation Results returned via buses to the Register File.
- Data Cache services Load/Store units.

The control unit dispatches instructions to appropriate functional units to keep all of them busy, even if that means executing instructions "out of order" — as soon as all the inputs to an instruction are available, and there's a free functional unit that can process it, it goes, even if it was later in the machine code than other instructions that are still waiting.

---

## 8. Loop Unrolling

Amortize cost of loop condition by duplicating body.
- Creates opportunities for CSE, code motion, scheduling.
- Prepares code for SIMDilization.
- Can hurt performance by increasing code size.
- Can increase compile time significantly.

```c
// Original
for (size_t i = 0; i < nelts; i++) {
    A[i] = B[i]*k + C[i];
}

// Unrolled by 4
for (size_t i = 0; i < nelts - 4; i += 4) {
    A[i  ] = B[i  ]*k + C[i  ];
    A[i+1] = B[i+1]*k + C[i+1];
    A[i+2] = B[i+2]*k + C[i+2];
    A[i+3] = B[i+3]*k + C[i+3];
}
```

> When would this change be incorrect? When the number of elements is not a multiple of 4. Sometimes the compiler can emit code to do the last few array elements separately from the loop, but that takes up even more space.

---

## 9. Scheduling

Rearrange instructions to make it easier for the CPU to keep all functional units busy. For instance, move all the loads to the top of an unrolled loop. Now maybe it's more obvious why we need lots of registers.

```c
for (size_t i = 0; i < nelts - 4; i += 4) {
    B0 = B[i]; B1 = B[i+1]; B2 = B[i+2]; B3 = B[i+3];
    C0 = C[i]; C1 = C[i+1]; C2 = C[i+2]; C3 = C[i+3];
    A[i  ] = B0*k + C0;
    A[i+1] = B1*k + C1;
    A[i+2] = B2*k + C2;
    A[i+3] = B3*k + C3;
}
```

> When would this change be incorrect? When A overlaps B or C, so the writes to A change the values being read from B or C.

### Unrolling/Scheduling Are Compiler Optimizations

Modern compilers (like GCC, Clang, and MSVC) are incredibly advanced and handle these optimizations much better than a human can in almost all scenarios.

Compilers also know the underlying microarchitectures better than programmers. All you need to do is use the option:
```
-march=native
-mtune=native
```

For machines with superscalar and out-of-order execution, programmers struggle with instruction scheduling. If the reorder buffer is empty, they should prioritize latency hiding; if it is full, they should prioritize retirement.

---

## 10. Benchmark Example: Vector Combine

### Data Type for Vectors

```c
/* data structure for vectors */
typedef struct {
    size_t len;
    data_t *data;
} vec;

/* retrieve vector element and store at val */
int get_vec_element(vec *v, size_t idx, data_t *val) {
    if (idx >= v->len)
        return 0;
    *val = v->data[idx];
    return 1;
}
```

- **Data types:** use different declarations for `data_t` — `int`, `long`, `float`, `double`.
- **Operations:** use different definitions of `OP` and `IDENT` — `+ / 0`, `* / 1`.

### Benchmark Computation: combine1

```c
void combine1(vec_ptr v, data_t *dest) {
    long int i;
    *dest = IDENT;
    for (i = 0; i < vec_length(v); i++) {
        data_t val;
        get_vec_element(v, i, &val);
        *dest = *dest OP val;
    }
}
```

### Cycles Per Element (CPE)

A convenient way to express the performance of a program that operates on vectors or lists:
- `Cycles = CPE * n + Overhead`
- `CPE` is the slope of the line.
- Example: `psum1` slope = 9.0; `psum2` slope = 6.0.

### combine1 Performance (CPE)

| Method | Int Add | Int Mult | FP Add | FP Mult |
|---|---|---|---|---|
| combine1 unoptimized | 22.68 | 20.02 | 19.98 | 20.18 |
| combine1 -O1 | 10.12 | 10.12 | 10.17 | 11.14 |
| combine1 -O3 | 4.5 | 4.5 | 6 | 7.8 |

### Basic Optimizations: combine4

```c
void combine4(vec_ptr v, data_t *dest) {
    long i;
    long length = vec_length(v);    // Move vec_length out of loop
    data_t *d = get_vec_start(v);
    data_t t = IDENT;               // Accumulate in temporary
    for (i = 0; i < length; i++)
        t = t OP d[i];              // Avoid bounds check on each cycle
    *dest = t;
}
```

| Method | Int Add | Int Mult | FP Add | FP Mult |
|---|---|---|---|---|
| combine1 unoptimized | 22.68 | 20.02 | 19.98 | 20.18 |
| combine1 -O1 | 10.12 | 10.12 | 10.17 | 11.14 |
| combine1 -O3 | 4.5 | 4.5 | 6 | 7.8 |
| **combine4** | **1.27** | **3.01** | **3.01** | **5.01** |

### Loop Unrolling

```c
void unroll2a_combine(vec_ptr v, data_t *dest) {
    long length = vec_length(v);
    long limit  = length - 1;
    data_t *d   = get_vec_start(v);
    data_t x0 = IDENT;
    data_t x1 = IDENT;
    long i;
    /* Combine 2 elements at a time */
    for (i = 0; i < limit; i += 2) {
        x0 = x0 OP d[i];
        x1 = x1 OP d[i+1];
    }
    /* Finish any remaining elements */
    for (; i < length; i++) {
        x0 = x0 OP d[i];
    }
    *dest = x0 OP x1;
}
```

Loop unrolling saves on the overhead to check bounds and jump.

### Reduction

```c
int a[1000], sum = 0;
for (i = 0; i < n; i++)
    sum += a[i];
```

- Reduction includes sum reduction, product reduction, parity, AND, OR, XOR, max, min.
- **Scalar Reduction:** one accumulator, serial dependency.
- **Vector Reduction:** SIMD lanes accumulate in parallel, then combine — `sum = sum0 + sum1 + sum2 + sum3`.
- Vector reduction is part of `-O2` or `-O3` optimizations.

### Effect of Loop Unrolling

| Method | Int Add | Int Mult | FP Add | FP Mult |
|---|---|---|---|---|
| combine1 unoptimized | 22.68 | 20.02 | 19.98 | 20.18 |
| combine1 -O1 | 10.12 | 10.12 | 10.17 | 11.14 |
| combine1 -O3 | 4.5 | 4.5 | 6 | 7.8 |
| combine4 | 1.27 | 3.01 | 3.01 | 5.01 |
| **Unroll** | **0.81** | **1.51** | **1.51** | **2.51** |
