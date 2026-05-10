# Lec 5: Optimizing Program Performance

## Exam Facts

- ==**First step in performance optimization: turn on compiler `-On`**==.
- `-O0`: debug, **no opt**; `-O1`/`-O`: basic; `-O2`: **safe default**; `-O3`: aggressive (loop/SIMD/unroll); `-Os`: **size** (good for **embedded**); `-O3 -flto`: **whole-program / cross-module inlining (LTO)**; `-Ofast` = `-O3 -ffast-math` (allows FP reassoc).
- ==**Cross-module procedure inlining requires `-O3 -flto` (LTO)**==.
- ==**Optimization with NO primary locality goal: loop unrolling**==. Locality-oriented: interchange / fusion / tiling.
- ==**Cascading DCE can give 1000× speedups**== if earlier opts expose dead code (the only optimization realistically credited with 4-digit gains).
- **Class focus**: ==**loop transformations for data locality**==, NOT CUDA/SIMT/multi-threading.
- Compiler limits: ==**aliasing, FP semantics, volatile, function side effects, separate compilation, unknown runtime data**==. Compilers cannot change algorithms.
- ==**Use `restrict` or local scalar copies**== when frequent pointer loads block register allocation/vectorization.
- ==**CSE for `(a+b+c+d)` = `(a+d+b+c)` legal for `long long` and `char` (integer)**==, NOT for `float`/`double` (non-associative).
- Inlining good candidates: ==**small procedures, constant args, called once in a loop**==. Bad: recursive, very large, many call sites.
- Pointer-chasing (linked list, tree) → **latency-bound**.
- Streaming arrays / matrix-multiply (large independent ops) → **bandwidth/throughput-bound**.
- ==**CPE = Cycles Per Element**==; `cycles = CPE × n + overhead`.

## 1. Why Optimize

- A small SW change can deliver orders-of-magnitude perf gain — far cheaper than HW upgrades.
- Real impact: Google search +0.5s → −20% traffic; Amazon 100ms latency = ~1% sales; HFT us matter.
- DeepSeek example: ~60–70% perf came from **PTX/system-level + cache mgmt**, not the model itself.

## 2. Compiler Optimization Levels

| Flag | Meaning |
|---|---|
| `-O0` | no opt, **fast compile, debug-friendly** |
| `-O1` (= `-O`) | basic |
| **`-O2`** | **recommended default**, safe + stable, modest size growth |
| `-O3` | aggressive: loop unroll + SIMD; bigger code, slower compile |
| **`-Os`** | optimize for **size** (embedded) |
| **`-O3 -flto`** | **Link-Time Optimization → whole-program / cross-module inlining** |
| `-Ofast` | `-O3 -ffast-math` (allows FP reassoc, breaks IEEE strictness) |
| `-march=native` / `-mtune=native` | optimize for current CPU |
| `-fprofile-generate / -fprofile-use` | **PGO** (profile-guided) |

> [!IMPORTANT] Quiz answers:
> - Cross-module inlining → **`-O3 -flto`**.
> - Embedded with limited memory → **`-Os`**.
> - Aggressive vectorization/unrolling → `-O3`.

### Why not let the compiler do *everything*?

- Cannot change your **algorithm**.
- Must obey language semantics (aliasing, FP non-assoc, volatile, side effects, memory consistency).
- **No runtime knowledge** (PGO + dynamic compilers help).
- NP-hard problems: optimal register allocation, scheduling, memory packing, **phase ordering**.
- **Separate compilation** hides cross-module facts → LTO needed.

## 3. General Goals

| Goal | Techniques |
|---|---|
| Minimize instruction count | **CSE, DCE, SR (strength reduction)** |
| Minimize execution cycles | **register allocation, code scheduling, locality, redundant-load elimination** |
| Avoid branches | **conditional move, unrolling, inlining, loop unswitching** |

> Compilers usually can't beat **algorithmic complexity** improvements. Use better data structures + algorithms first.

## 4. Basic Optimizations

### Constant folding

```c
long mask = 0xFF << 8;          // → 0xFF00
size_t n = strlen("Harry");     // → 5
```

### Dead code elimination (DCE)

```c
if (0) { ... }      // removed
x = 23; x = 42;     // first store dead
```

> **Cascading DCE**: removing one dead statement may expose others ⇒ huge cumulative effect (occasional **1000× speedup**).

### Common subexpression elimination (CSE)

```c
norm[i] = v[i].x*v[i].x + v[i].y*v[i].y;
// → load &v[i] once, then x*x + y*y
A = (A+B+C)*(A+B+D) - (A+D+B);   // (A+B) is reused
```

> [!IMPORTANT] CSE for **`(a+b+c+d)` and `(a+d+b+c)`**: legal only for **integer types `long long, char, int, unsigned, …`**. For `float/double`: **NOT** legal (non-associative; reassoc changes result).

### LICM (Loop-Invariant Code Motion)

```c
for(j=0; j<n; j++) a[n*i + j] = b[j];   // n*i invariant
// →
int ni = n*i;
for(j=0; j<n; j++) a[ni + j] = b[j];
```

### Strength reduction (SR)

Replace `*` with shifts/adds; `/2^k` with `>>k` (with bias for signed).

### Inlining

Copy callee body into caller. Pros: removes call overhead, enables further opts. Cons: code bloat, I-cache pressure.

> Quiz: Good candidates for inlining:
> - **Small procedures** ✓
> - **Procedures with multiple constant arguments** ✓ (enables const-prop, DCE)
> - **Called only once in a loop** ✓
> - Recursive procedures ✗
> - Procedures with many call sites ✗ (bloat)

After inlining + const-fold + DCE:
```c
int func(int y) {
    int tmp = 0;
    if (y != 0)  tmp = y - 1;
    if (y != -1) tmp += y;
    return tmp;
}
```

## 5. Memory Aliasing

==**Aliasing**==: two pointers may refer to same memory ⇒ compiler must conservatively reload/restore each iteration.

### Example

```c
void sum_rows1(double *a, double *b, long n) {
  for (i=0; i<n; i++) {
    b[i] = 0;
    for (j=0; j<n; j++)
      b[i] += a[i*n + j];   // can't keep b[i] in register if a aliases b
  }
}
```

Compiler must: load `b[i]`, add, store `b[i]` every iteration. Cannot keep `b[i]` in a register because `a[k]` could alias `&b[i]`.

### Compiler diagnostic

```bash
gcc -O3 -fopt-info-missed=missed.txt foo.c
clang -O3 -Rpass-missed=.* -Rpass-analysis=.* foo.c
```

Look for: **"cannot vectorize loop due to dependent memory operations"** / "data dependence".

### Fixes

> [!IMPORTANT] Quiz: when `*a` and `*b` are used heavily but compiler won't allocate them to registers:
> 1. ==**Use `restrict` pointers**==.
> 2. ==**Manually copy `*a, *b` to local scalar variables**==, work, write back.
>
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

==`restrict`== = "this is the only pointer to that object in its scope".

### Function calls in loops

```c
// Quadratic — strlen called every iteration:
for(i=0; i<strlen(s); i++) ...

// Linear:
n = strlen(s); for(i=0; i<n; i++) ...
```

> Compiler **can't hoist `strlen` if the loop modifies the string** — call may have side effects on its inputs (the loop body writes `s[i]`).

## 6. Modern CPU & Scheduling

CPU has **Instruction Control** (fetch/decode/branch-pred/retire) + **Execution** (parallel functional units, OoO dispatch).

> Compiler scheduling cooperates with HW OoO. Programmers usually can't beat the compiler at scheduling — use `-march=native -mtune=native`.

## 7. Loop Optimizations

| Optimization | Primary goal |
|---|---|
| ==**Loop unrolling**== | **fewer branches/index ops, more ILP** (NOT primarily locality!) |
| ==**Loop interchange**== | locality (change loop order to walk contiguously) |
| ==**Loop fusion**== | locality (combine 2 loops over same data) |
| ==**Loop tiling / blocking**== | locality (operate on cache-sized blocks) |
| Loop unswitching | move invariant `if` out of loop |

> [!IMPORTANT] Quiz "no primary locality goal" → **loop unrolling**.

### Loop unrolling

```c
// Original
for(i=0; i<n; i++) A[i] = B[i]*k + C[i];

// Unrolled by 4
for(i=0; i<n-4; i+=4) {
  A[i  ] = B[i  ]*k + C[i  ];
  A[i+1] = B[i+1]*k + C[i+1];
  A[i+2] = B[i+2]*k + C[i+2];
  A[i+3] = B[i+3]*k + C[i+3];
}
// + cleanup loop for remainder
```

Pros: amortize branch overhead, enable CSE, scheduling, SIMD.
Cons: code size growth, I-cache pressure.

> Incorrect when: A overlaps B/C (writes change reads); n not multiple of 4 (need cleanup).

## 8. CPE / Vector Combine Benchmark

==**CPE = Cycles Per Element**==; `cycles = CPE × n + overhead`.

### Original `combine1` (calls `vec_length` and bounds check every iter)

| Method | int+ | int* | f+ | f* |
|---|---|---|---|---|
| unopt | 22.7 | 20.0 | 20.0 | 20.2 |
| `-O1` | 10.1 | 10.1 | 10.2 | 11.1 |
| `-O3` | 4.5 | 4.5 | 6.0 | 7.8 |

### `combine4` (hoist length, skip bounds, accumulate in temp)

```c
long length = vec_length(v);
data_t *d = get_vec_start(v);
data_t t = IDENT;
for (i=0; i<length; i++) t = t OP d[i];
*dest = t;
```

| Method | int+ | int* | f+ | f* |
|---|---|---|---|---|
| combine4 | **1.27** | **3.01** | **3.01** | **5.01** |

### Unroll + multiple accumulators

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
| **Unroll-2** | **0.81** | **1.51** | **1.51** | **2.51** |

> Why multiple accumulators help: **break dependency chain**. With 1 accumulator, latency-bound = op latency. With k accumulators, CPE ≈ latency/k until throughput/load bandwidth saturates.

### Optimal CPE bound

$$\text{CPE} \ge \max(\text{critical-path-bound}, \text{functional-unit-bound}, \text{load/store-bandwidth-bound})$$

## 9. Reduction & SIMD

```c
for (i=0; i<n; i++) sum += a[i];
```

- **Scalar reduction**: 1 accumulator → latency chain.
- **Vector reduction (SIMD)**: lanes accumulate in parallel, combined at end. Enabled by `-O2/-O3`.

Other reductions: max/min, AND, OR, XOR, parity, product.

## 10. Locality Bound vs Bandwidth Bound

| Code pattern | Bound by |
|---|---|
| Single account-balance query | latency (1 query, ~zero parallelism) |
| **Linked list traversal** | **latency** (pointer chasing) |
| **Binary tree traversal** | **latency** (pointer chasing) |
| **Large matrix multiply** | bandwidth/throughput |
| Streaming array op | bandwidth |

> Quiz: "limited by **latency** rather than bandwidth": single query, linked list, binary tree (NOT large matmul).

### Pointer chasing fixes

- Use **arrays / contiguous data**.
- B/B+ trees instead of binary tree.
- Open addressing instead of chained hash.
- Batch independent streams.
- Allow multiple memory requests in flight.

## 11. Safety Traps

| Trap | Why |
|---|---|
| FP reassociation | not associative — compiler can't reorder without `-ffast-math` |
| Function calls inside loop | compiler can't move them (side effects, may modify inputs) |
| `volatile` variables | restrict reordering |
| Memory consistency | constrains stores/loads |
| Separate compilation | hides cross-module facts unless `-flto` |
