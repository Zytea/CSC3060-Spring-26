# Lec 5: Optimizing Program Performance

## Exam Facts

- Optimization must be measurement-driven: improve algorithm, data layout, compiler flags, locality, ILP, SIMD, and alias information.
- Compiler flags: `-O2` is safe default; `-O3` adds aggressive loop/unroll/vector transforms; `-Ofast = -O3 -ffast-math`; `-flto` enables link-time optimization.
- Compiler cannot change semantics: aliasing, FP non-associativity, volatile, calls/side effects, exceptions, separate compilation, unknown inputs.
- Basic optimizations: constant folding, DCE, CSE, LICM, strength reduction, inlining, register allocation, scheduling.
- If frequent non-aliasing `*a`, `*b` still stay in memory, use `restrict` or local scalar copies.
- `strlen` inside a loop can accidentally make code quadratic if the string may be modified.
- Loop unrolling reduces branch overhead and exposes ILP/SIMD but can increase code size and hurt I-cache.
- CPE = cycles per element. `cycles = CPE*n + overhead`.
- Reduction with one accumulator is latency-bound; multiple accumulators/SIMD lanes reduce dependency-chain CPE.
- Pointer-heavy structures are latency-bound; contiguous arrays, B/B+ trees, open addressing improve locality/MLP.

## 1. Program Optimization

Program optimization shifts from correct code to efficient code.

Main levers:

| Lever | Example |
|---|---|
| algorithm | `O(n^2)` -> `O(n log n)` or `O(n)` |
| data structure/layout | linked list -> array; AoS -> SoA |
| compiler | `-O2`, `-O3`, `-flto`, PGO |
| microarchitecture | cache locality, branch predictability, ILP |
| ISA | SIMD/vector/FMA |
| programmer annotations | `restrict`, alignment, constness |

> Optimization is not guessing. Use profiling, inspect generated code, and understand bottlenecks.

## 2. Compiler Optimization Flags

| Flag | Meaning |
|---|---|
| `-O0` | no optimization, best debugging, slow code |
| `-O1` / `-O` | basic safe optimizations |
| `-O2` | recommended default; broad safe optimizations without huge code growth |
| `-O3` | aggressive loop unrolling/vectorization/inlining; may increase code size |
| `-Ofast` | `-O3 -ffast-math`; may break strict FP semantics |
| `-flto` | link-time optimization across translation units |
| `-march=native` | generate instructions for current CPU |
| `-mtune=native` | schedule/tune for current CPU while preserving ISA target |
| PGO | `-fprofile-generate`, run workload, `-fprofile-use` |

`-O3` can be slower than `-O2` if code bloat hurts I-cache or branch prediction.

## 3. Why Compiler Optimization Is Hard

The compiler must preserve language-visible behavior.

Hard limits:

- cannot generally change algorithmic complexity.
- memory aliasing may force loads/stores in program order.
- FP arithmetic is not associative.
- function calls may have side effects.
- `volatile` and atomics constrain reordering.
- separate compilation hides whole-program facts unless LTO.
- optimal register allocation/scheduling/phase ordering are hard combinatorial problems.
- worst-case and malicious inputs may matter more than profiled common cases.

## 4. Basic Compiler Optimizations

### 4.1 Local vs Global

| Scope | Meaning | Examples |
|---|---|---|
| local | inside one basic block | constant folding, local CSE, DCE |
| global | across CFG of a function | LICM, global CSE, register allocation |
| whole-program | across modules | LTO, interprocedural inlining |

CFG models control paths; DFG/DDG models value/dependence flow.

### 4.2 Constant Folding / Propagation

Compute constant expressions at compile time:

```c
long mask = 0xFF << 8;                  // 0xFF00
size_t n = strlen("Harry Bovik");       // 11
```

### 4.3 Dead Code Elimination (DCE)

Remove unreachable code or useless overwritten assignments:

```c
if (0) puts("never");
x = 23;
x = 42;     // first store dead if x not read between
```

DCE often cleans up code created by other optimizations and conditional compilation.

### 4.4 Common Subexpression Elimination (CSE)

Reuse repeated calculations:

```c
norm[i] = v[i].x*v[i].x + v[i].y*v[i].y;
```

Compiler can transform to:

```c
elt = &v[i];
x = elt->x;
y = elt->y;
norm[i] = x*x + y*y;
```

Other CSE patterns:

- `A=(A+B+C)*(A+B+D)-(A+D+B)` has integer common subexpressions like `A+B`.
- `B[i][j][k] + C[i][j][k]` shares index arithmetic.
- `A->b->c->e + A->b->c->d` shares pointer chain `A->b->c`.

FP caveat: do not reassociate FP sums unless fast-math semantics allow it.

### 4.5 Loop-Invariant Code Motion (LICM)

Move loop-invariant work out of loop:

```c
for (j=0; j<n; j++)
    a[n*i+j] = b[j];
```

becomes:

```c
int ni = n*i;
for (j=0; j<n; j++)
    a[ni+j] = b[j];
```

Valid only if moved expression produces same result and no side effects/exceptions/aliasing changes behavior.

### 4.6 Strength Reduction

Replace expensive operations with cheaper ones:

| Expensive | Cheaper |
|---|---|
| `i * 4` | `i << 2` |
| `i * n` in loop | increment pointer/index by `n` |
| division by power of 2 unsigned | logical shift |

Signed division by power of 2 needs bias for negative values.

### 4.7 Inlining

Inlining copies callee body into caller.

Benefits:

- removes call/return overhead.
- exposes constants and CSE/DCE/LICM.
- improves register allocation and scheduling.

Costs:

- code bloat.
- worse I-cache.
- longer compile time.
- recursion/deep inline limits.

Inlining is high value when small hot functions are called inside loops.

## 5. Memory Aliasing

### 5.1 Problem

```c
void sum_rows1(double *a, double *b, long n) {
    for (long i=0; i<n; i++) {
        b[i] = 0;
        for (long j=0; j<n; j++)
            b[i] += a[i*n+j];
    }
}
```

Compiler may reload/store `b[i]` every iteration because `a[i*n+j]` might alias `b[i]`.

Bad inner loop shape:

```asm
fld    fa5,0(a3)      # load b[i]
fld    fa4,0(a4)      # load a[i*n+j]
fadd.d fa5,fa5,fa4
fsd    fa5,0(a3)      # store b[i]
```

If no alias, it can keep accumulator in a register.

### 5.2 Fixes for Alias-Limited Code

Use local accumulator:

```c
void sum_rows2(double *a, double *b, long n) {
    for (long i=0; i<n; i++) {
        double val = 0;
        for (long j=0; j<n; j++)
            val += a[i*n+j];
        b[i] = val;
    }
}
```

Use `restrict`:

```c
void sum_rows(double *restrict a, double *restrict b, long n);
```

Check compiler diagnostics:

```bash
gcc -O3 -fopt-info-missed=missed_opts.txt file.c
clang -O3 -Rpass-missed=.* -Rpass-analysis=.* file.c
```

Look for messages like "data dependence", "dependent memory operations", or "cannot vectorize due to aliasing".

### 5.3 Function Calls in Loops

```c
for (i=0; i<strlen(s); i++)
    ...
```

If loop body modifies `s`, compiler may need to recompute `strlen(s)` each iteration, making code quadratic.

Fix:

```c
size_t n = strlen(s);
for (i=0; i<n; i++)
    ...
```

Only valid if loop does not change string length.

## 6. Modern CPU Design and Scheduling

Modern CPUs have:

- instruction fetch + I-cache.
- branch prediction.
- decode/rename/dispatch.
- multiple functional units: branch, integer ALU, load/store, FP/SIMD.
- data cache.
- retirement unit to preserve architectural order.

OoO executes ready operations when operands and functional units are available. Compiler scheduling still helps, especially when hardware window is small or code is in-order/embedded.

## 7. Loop Unrolling

Unroll by 4:

```c
for (i=0; i+3<nelts; i+=4) {
    A[i  ] = B[i  ]*k + C[i  ];
    A[i+1] = B[i+1]*k + C[i+1];
    A[i+2] = B[i+2]*k + C[i+2];
    A[i+3] = B[i+3]*k + C[i+3];
}
for (; i<nelts; i++)
    A[i] = B[i]*k + C[i];
```

Benefits:

- less loop branch overhead.
- more ILP.
- exposes CSE and scheduling.
- helps SIMD vectorization.

Risks:

- cleanup loop needed if length not multiple of unroll factor.
- code size increases.
- register pressure increases.
- aliasing can make reordered loads/stores illegal.

## 8. Instruction Scheduling

Move independent loads early:

```c
B0=B[i]; B1=B[i+1]; B2=B[i+2]; B3=B[i+3];
C0=C[i]; C1=C[i+1]; C2=C[i+2]; C3=C[i+3];
A[i  ] = B0*k + C0;
A[i+1] = B1*k + C1;
A[i+2] = B2*k + C2;
A[i+3] = B3*k + C3;
```

Invalid if `A` overlaps `B` or `C` and writes change later reads.

Use `-march=native -mtune=native` so compiler knows available ISA and scheduling costs.

## 9. CPE / Vector Combine Benchmark

==**CPE**==: cycles per element.

```text
cycles = CPE*n + overhead
```

`combine1`:

```c
void combine1(vec_ptr v, data_t *dest) {
    *dest = IDENT;
    for (i=0; i<vec_length(v); i++) {
        data_t val;
        get_vec_element(v,i,&val);
        *dest = *dest OP val;
    }
}
```

Problems:

- calls `vec_length` every iteration.
- calls `get_vec_element` with bounds check.
- loads/stores `*dest` every iteration due to aliasing.

`combine4`:

```c
void combine4(vec_ptr v, data_t *dest) {
    long length = vec_length(v);
    data_t *d = get_vec_start(v);
    data_t t = IDENT;
    for (i=0; i<length; i++)
        t = t OP d[i];
    *dest = t;
}
```

Performance pattern:

| Version | Reason for improvement |
|---|---|
| `-O1/-O3` | compiler removes obvious overhead |
| `combine4` | hoists length/start, uses local accumulator |
| unrolled | reduces loop overhead, exposes ILP |
| multiple accumulators | breaks serial dependency chain |
| SIMD/vector reduction | parallel lanes |

## 10. Reduction and SIMD

Scalar reduction:

```c
sum = 0;
for (i=0; i<n; i++)
    sum += a[i];
```

One accumulator creates a RAW dependency chain:

```text
sum0 -> sum1 -> sum2 -> ...
```

Multiple accumulators:

```c
s0=s1=s2=s3=0;
for (i=0; i+3<n; i+=4) {
    s0 += a[i];
    s1 += a[i+1];
    s2 += a[i+2];
    s3 += a[i+3];
}
sum = s0+s1+s2+s3;
```

Why it works: four independent chains can use multiple ALUs/FMA lanes and hide latency until throughput becomes bottleneck.

SIMD reduction accumulates across vector lanes, then horizontally combines.

## 11. Latency-Bound vs Bandwidth-Bound

| Bottleneck | Symptom | Fix |
|---|---|---|
| latency-bound | dependency chain, pointer chasing | break chain, prefetch, better data structure |
| bandwidth-bound | streaming large arrays, FU/cache bandwidth saturated | improve locality, reduce bytes, vectorize, compress |
| branch-bound | unpredictable branches | branchless code, better layout, prediction-friendly data |
| cache-bound | high miss rate | blocking, layout, contiguous data |

Pointer-heavy data structures:

- linked lists.
- binary trees.
- queues/stacks built from nodes.
- hash tables with linked collision chains.

Fixes:

- arrays/contiguous storage.
- B/B+ trees.
- open addressing.
- structure-of-arrays for vectorization.
- pool allocator to improve locality.

## 12. Safety Traps

| Trap | Correct idea |
|---|---|
| "compiler will optimize everything" | no; semantics and unknowns constrain it |
| "unroll always helps" | no; code size/register pressure/I-cache can hurt |
| "FP can be reassociated" | only under fast-math-like assumptions |
| "loads can move before stores" | only if no alias/trap concern |
| "inline always helps" | no; may bloat code |
| "CPE is total cycles" | no; CPE is slope per element |
