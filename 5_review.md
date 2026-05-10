# Lec 5: Optimizing Program Performance

## Exam Facts

- ==**First step in performance optimization: turn on `-On`**==.
- `-O0` debug; `-O1`/`-O` basic; `-O2` **safe default**; `-O3` aggressive (loop/SIMD/unroll); ==**`-Os` size (embedded)**==; ==**`-O3 -flto` cross-module / LTO**==; `-Ofast = -O3 -ffast-math`.
- ==**Cross-module procedure inlining requires `-O3 -flto`**==.
- ==**No primary locality goal: loop unrolling**==. Locality-oriented: interchange / fusion / tiling.
- ==**Cascading DCE → 1000× speedups**== if earlier opts expose dead code.
- **Class focus**: ==**loop transformations for data locality**==, NOT CUDA/SIMT/multi-threading.
- Compiler limits: ==**aliasing, FP semantics, volatile, side effects, separate compilation, unknown runtime data**==. Cannot change algorithms.
- ==**Use `restrict` or local scalar copies**== when frequent pointer loads block register allocation/vectorization.
- ==**CSE for `(a+b+c+d)` = `(a+d+b+c)` legal for `long long, char` (integer)**==, NOT `float/double` (non-associative).
- Inlining good candidates: ==**small procedures, constant args, called once in loop**==. Bad: recursive, very large, many call sites.
- Pointer-chasing (linked list, tree) → **latency-bound**.
- Streaming arrays / matrix-multiply → **bandwidth/throughput-bound**.
- ==**CPE = Cycles Per Element**==; `cycles = CPE × n + overhead`.

## 1. Why Optimize

A small SW change can deliver order-of-magnitude perf gains — far cheaper than HW upgrades.

> Real impact: Google +0.5s search → −20% traffic; Amazon 100ms = ~1% sales; HFT µs matter.
> DeepSeek: ~60-70% perf came from **PTX/system-level + cache mgmt**, not the model itself.

## 2. Compiler Optimization Levels

| Flag | Meaning |
|---|---|
| `-O0` | no opt, **fast compile, debug-friendly** |
| `-O1` (= `-O`) | basic |
| `-O2` | **recommended default**, safe + stable |
| `-O3` | aggressive: loop unroll + SIMD; bigger code, slower compile |
| ==**`-Os`**== | optimize for **size** (embedded) |
| ==**`-O3 -flto`**== | **LTO → whole-program / cross-module inlining** |
| `-Ofast` | `-O3 -ffast-math` (allows FP reassoc, breaks IEEE) |
| `-march=native` / `-mtune=native` | optimize for current CPU |
| `-fprofile-generate / -fprofile-use` | **PGO** |

### 2.1 Why Not Compiler-Only

- Cannot change **algorithm**.
- Must obey language semantics (aliasing, FP non-assoc, volatile, side effects).
- **No runtime knowledge** (PGO/dynamic-compile help).
- NP-hard problems: optimal regalloc, scheduling, mem packing, **phase ordering**.
- **Separate compilation** hides cross-module facts → LTO needed.

## 3. General Goals

| Goal | Techniques |
|---|---|
| Minimize instr count | **CSE, DCE, SR (strength reduction)** |
| Minimize execution cycles | **regalloc, scheduling, locality, redundant-load elim** |
| Avoid branches | **conditional move, unrolling, inlining, unswitching** |

> Compilers can't beat **algorithmic complexity** improvements. Use better data structures + algos first.

## 4. Basic Optimizations

### 4.1 Constant Folding

```c
long mask = 0xFF << 8;          // → 0xFF00
size_t n = strlen("Harry");     // → 5
```

### 4.2 Dead Code Elimination (DCE)

```c
if (0) { ... }      // removed
x = 23; x = 42;     // first store dead
```

> ==**Cascading DCE**==: removing one dead stmt may expose others ⇒ huge cumulative effect (occasional **1000× speedup**).

### 4.3 Common Subexpression Elimination (CSE)

```c
norm[i] = v[i].x*v[i].x + v[i].y*v[i].y;     // load &v[i] once
A = (A+B+C)*(A+B+D) - (A+D+B);                // (A+B) reused
```

> [!IMPORTANT] CSE for `(a+b+c+d)` and `(a+d+b+c)`: legal only for ==**integer types `long long, char, int, unsigned`**==. For `float/double`: NOT legal (non-associative).

### 4.4 LICM (Loop-Invariant Code Motion)

```c
for(j=0; j<n; j++) a[n*i + j] = b[j];   // n*i invariant
// →
int ni = n*i;
for(j=0; j<n; j++) a[ni + j] = b[j];
```

### 4.5 Strength Reduction (SR)

Replace `*` with shifts/adds; `/2^k` with `>>k` (with bias for signed).

### 4.6 Inlining

Copy callee body into caller. Pros: removes call overhead, enables further opts. Cons: code bloat, I-cache pressure.

> [!IMPORTANT] Inlining good candidates:
> - ==**Small procedures**== ✓
> - ==**Procedures with multiple constant arguments**== ✓ (enables const-prop, DCE)
> - ==**Called only once in a loop**== ✓
> - Recursive procedures ✗
> - Many call sites ✗ (bloat)

## 5. Memory Aliasing

==**Aliasing**==: two pointers may refer to same memory ⇒ compiler must conservatively reload/restore each iter.

### 5.1 Example

```c
void sum_rows1(double *a, double *b, long n) {
  for (i=0; i<n; i++) {
    b[i] = 0;
    for (j=0; j<n; j++)
      b[i] += a[i*n + j];   // can't keep b[i] in reg if a aliases b
  }
}
```

Compiler must load/add/store `b[i]` every iter — `a[k]` could alias `&b[i]`.

### 5.2 Diagnose

```bash
gcc -O3 -fopt-info-missed=missed.txt foo.c
clang -O3 -Rpass-missed=.* -Rpass-analysis=.* foo.c
```

Look for: "**cannot vectorize loop due to dependent memory operations**" / "data dependence".

### 5.3 Fixes

> [!IMPORTANT] When `*a, *b` are heavy but compiler won't allocate to registers:
> 1. ==**Use `restrict` pointers**==.
> 2. ==**Manually copy `*a, *b` to local scalars**==, work, write back.
> NOT: turn on `-O3` (alone won't fix), changing compiler.

```c
// Option A: local scalar
void sum_rows2(double *a, double *b, long n) {
  for(i=0; i<n; i++) {
    double val = 0;
    for(j=0; j<n; j++) val += a[i*n+j];
    b[i] = val;
  }
}

// Option B: restrict
void sum_rows1(double *restrict a, double *restrict b, long n);
```

==`restrict`==: "this is the only pointer to that object in its scope".

### 5.4 Function Calls in Loops

```c
for(i=0; i<strlen(s); i++) ...      // quadratic — strlen each iter
n = strlen(s); for(i=0; i<n; i++)... // linear
```

> Compiler can't hoist `strlen` if loop modifies the string — call may have side effects on its inputs.

## 6. Loop Optimizations

| Optimization | Primary goal |
|---|---|
| ==**Loop unrolling**== | **fewer branches/index ops, more ILP** (NOT primarily locality) |
| ==**Loop interchange**== | locality (change loop order to walk contiguously) |
| ==**Loop fusion**== | locality (combine 2 loops over same data) |
| ==**Loop tiling/blocking**== | locality (operate on cache-sized blocks) |
| Loop unswitching | move invariant `if` out of loop |

> [!IMPORTANT] Quiz "no primary locality goal" → ==**loop unrolling**==.

### 6.1 Loop Unrolling Example

```c
for(i=0; i<n-4; i+=4) {
  A[i  ] = B[i  ]*k + C[i  ];
  A[i+1] = B[i+1]*k + C[i+1];
  A[i+2] = B[i+2]*k + C[i+2];
  A[i+3] = B[i+3]*k + C[i+3];
}
// + cleanup loop for remainder
```

> Incorrect when: A overlaps B/C; n not multiple of 4 (need cleanup).

## 7. CPE / Vector Combine Benchmark

==**CPE = Cycles Per Element**==; `cycles = CPE × n + overhead`.

### 7.1 combine1 (calls `vec_length`+bounds check each iter)

| Method | int+ | int* | f+ | f* |
|---|---|---|---|---|
| unopt | 22.7 | 20.0 | 20.0 | 20.2 |
| `-O1` | 10.1 | 10.1 | 10.2 | 11.1 |
| `-O3` | 4.5 | 4.5 | 6.0 | 7.8 |

### 7.2 combine4 (hoist length, skip bounds, accumulate in temp)

```c
long length = vec_length(v);
data_t *d = get_vec_start(v);
data_t t = IDENT;
for (i=0; i<length; i++) t = t OP d[i];
*dest = t;
```

| | int+ | int* | f+ | f* |
|---|---|---|---|---|
| combine4 | **1.27** | **3.01** | **3.01** | **5.01** |

### 7.3 Unroll + Multiple Accumulators

```c
data_t x0=IDENT, x1=IDENT;
for (i=0; i<limit; i+=2) {
  x0 = x0 OP d[i];
  x1 = x1 OP d[i+1];
}
*dest = x0 OP x1;
```

| | int+ | int* | f+ | f* |
|---|---|---|---|---|
| Unroll-2 | **0.81** | **1.51** | **1.51** | **2.51** |

> Why multiple accumulators help: ==**break dependency chain**==. With 1 accumulator, latency-bound = op latency. With k accumulators, CPE ≈ latency/k until throughput/load-bandwidth saturates.

### 7.4 Optimal CPE Bound

$$\text{CPE} \ge \max(\text{critical-path}, \text{functional-unit}, \text{load/store BW})$$

## 8. Reduction & SIMD

```c
for (i=0; i<n; i++) sum += a[i];
```

- **Scalar reduction**: 1 accumulator → latency chain.
- **Vector reduction (SIMD)**: lanes accumulate in parallel, combined at end. Enabled by `-O2/-O3`.

Other reductions: max/min, AND, OR, XOR, parity, product.

## 9. Latency-Bound vs Bandwidth-Bound

| Code pattern | Bound by |
|---|---|
| Single account-balance query | latency |
| ==**Linked list traversal**== | **latency** (pointer chasing) |
| ==**Binary tree traversal**== | **latency** (pointer chasing) |
| Large matrix multiply | bandwidth/throughput |
| Streaming array op | bandwidth |

> Quiz: "limited by **latency** rather than bandwidth": single query, linked list, binary tree (NOT large matmul).

### 9.1 Pointer-Chasing Fixes

- Use **arrays / contiguous data**.
- B/B+ trees instead of binary tree.
- Open addressing instead of chained hash.
- Batch independent streams.
- Allow multiple memory requests in flight.

## 10. Safety Traps

| Trap | Why |
|---|---|
| FP reassociation | not associative — needs `-ffast-math` |
| Function calls in loop | side effects, may modify inputs |
| `volatile` | restricts reordering |
| Memory consistency | constrains stores/loads |
| Separate compilation | hides cross-module facts unless `-flto` |
