# Lec 5: Optimizing Program Performance

## Exam Facts

- ==**Optimization levers**==: algorithm, data layout, compiler flags, locality, ILP, SIMD, alias info.

- ==**Compiler flags**==:
  - `-O0` debug; `-O1` basic safe.
  - **`-O2`** ★ default — safe + stable + small bloat.
  - `-O3` aggressive (unrolling, vectorization, inlining); may bloat.
  - **`-O4`** = **`-O3 -flto`** (LTO). `-Ofast` = `-O3 -ffast-math` (may break strict FP).
  - **`-Os`** ★ for **embedded** / size-constrained.
  - **`-flto`** = link-time / whole-program. `-march=native` / `-mtune=native` = local CPU ISA/scheduling.
  - `-fprofile-generate` / `-fprofile-use` = PGO.
  - ==**Cross-module inlining**==: **`-O3 -flto`** ✅; ==**embedded**== → **`-Os`** ✅.

- ==**Semantic limits**==: pointer **aliasing**, FP non-assoc, `volatile`/atomics, fn side effects, exceptions, separate compilation.

- ==**Basic optimizations**==: **constant folding, DCE, CSE, LICM, strength reduction, inlining, register allocation, scheduling**.
  - **CFG** = control flow; **DFG** = value flow; **DDG** = scheduling deps.
  - ==**Cascading DCE**==: one constant kills branch → calls → loop → **1000× speedup** possible.

- ==**Loop unrolling**==: reduces branch+index overhead, exposes ILP/SIMD. **NOT a locality opt** ❌.
  - ==**Locality opts**==: loop **interchange / fusion / tiling**.
  - Without **cleanup loop**, unroll-by-k is **incorrect** when `n` not mult of `k`.

- ==**`switch` vs `if-else`**==: **dense** → jump table (indirect `JALR`, hard target prediction); **sparse** → branch chain (≈ if/else).

- ==**Procedure layout / I-cache**==: `A() → B()` far apart → thrash. Fix: **inline** OR **linker layout adjacent**.

- ==**Inline candidates**==: small fns, constant args, called once, inside loop. **NOT** recursive, deep call graph, many call sites.

- ==**CPE**== = cycles/element; $\text{total} = CPE \times n + \text{overhead}$. ==**CPE = slope**==, NOT total.
  - **1-acc reduction**: $\text{CPE} \ge \text{latency}(OP)$.
  - **k indep accs**: $\text{CPE} \ge \max(L/k, \text{issue\_limit}, \text{bw\_limit})$.

- ==**Non-aliasing `*a, *b`** but compiler won't reg-allocate==: use **`restrict`** OR **manual local copies**. NOT switching compilers, NOT `-O3` alone.

- ==**FP CSE `(a+b+c+d) ≡ (a+d+b+c)`**==: legal for `long long`/`char` ✅; **`float`/`double` ❌** (FP non-assoc).

- ==**Compiler diagnostics**==: "data dependence" / "cannot vectorize" / "cannot reorder mem ops" → **alias blocks**. Use `restrict` or copy.

- **Latency-bound**: account query, linked-list/tree search. **Bandwidth-bound**: large matmul, streaming.

- **Modern CPU**: front-end (fetch/decode/branch-pred) + execution (parallel FUs, OoO) + regfile + D-cache. OoO issues μops on ready inputs + free FUs.

## 1. Program Optimization

| Lever            | Example                            | Goal                     | Optimizations                        |
| ---------------- | ---------------------------------- | ------------------------ | ------------------------------------ |
| algorithm        | $O(n^2) \to O(n \log n)$           | **min instructions**     | CSE, DCE, strength reduction         |
| data layout      | linked list → array; AoS → SoA     | **min cycles**           | reg alloc, scheduling, locality      |
| compiler         | `-O2`, `-O3`, `-flto`, PGO         | **avoid branches**       | unrolling, inlining, `cmov`, slt+mask |
| μarch awareness  | cache, branch pred, ILP            |                          |                                      |
| ISA              | SIMD/vector/FMA                    |                          |                                      |
| annotations      | `restrict`, alignment, `const`     |                          |                                      |

> Optimize from **measurement / profiling**, not guesswork.

==**Branchless transforms for unpredictable branches**== (e.g., balanced BST traversal ≈ 50/50): compiler emits `slt`+mask (RV) or `cmov` (x86). Trade: 1 extra unconditional instr; no pipeline flush. RV32I has no `cmov`, uses `slt`+`and`.

> Real-world: Google +0.5s → -20% traffic. Amazon +100ms → -1% sales. HFT cares µs. Netflix encoding → CDN $M/yr.

## 2. Compiler Flag Reference

| Flag | Meaning |
|---|---|
| `-O0` | no opt; fast compile; debug-friendly |
| `-O` / `-O1` | basic safe opts |
| **`-O2`** | ★ default: high opt, stable, small bloat |
| `-O3` | aggressive: unrolling, vectorization, inlining |
| **`-O4`** | class note: `-O3 -flto` |
| `-Ofast` | `-O3 -ffast-math`; may break strict FP |
| **`-Os`** | optimize for **size** (embedded) |
| **`-flto`** | link-time / whole-program; cross-module inlining |
| `-march=native` / `-mtune=native` | local CPU ISA / scheduling |
| `-fprofile-generate` / `-fprofile-use` | PGO |

## 3. Why Compiler Optimization Is Hard

Must preserve **observable behavior**:

- ==**pointer aliasing**== (most common blocker);
- ==**FP non-associativity**==;
- ==**fn calls may have side effects**==;
- `volatile`, atomics, I/O; possible traps; separate compilation (without `-flto`);
- no algorithm/domain knowledge; optimal scheduling/reg alloc is **NP-hard**.

> Compilers can't change algorithm. AI-assisted compilers: heuristic tuning, phase ordering, autotuning.

## 4. Basic Compiler Optimizations

### 4.1 Scope

| Scope                  | Examples                              |
| ---------------------- | ------------------------------------- |
| local block            | constant folding, local CSE, DCE      |
| function/global CFG    | LICM, global CSE, register allocation |
| whole-program          | LTO, interprocedural inlining         |

==**CFG**== = control-flow paths. ==**DFG**== = value flow. ==**DDG**== = scheduling order ([4_5](notes%20quiz%202/4_5_review.md)).

### 4.2 Constant Fold / DCE / CSE / LICM / Strength

```c
// Constant folding
long mask = 0xFF << 8;             // → 0xFF00
size_t n = strlen("Harry Bovik");  // → 11

// DCE
if (0) puts("never");      // dead
x = 23; x = 42;            // → x = 42

// CSE
norm[i] = v[i].x*v[i].x + v[i].y*v[i].y;
// ↓
elt = &v[i]; x = elt->x; y = elt->y;
norm[i] = x*x + y*y;

// LICM
for (j=0; j<n; j++)  a[n*i + j] = b[j];
// ↓
int ni = n*i;
for (j=0; j<n; j++)  a[ni + j] = b[j];
```

==**Cascading DCE**==: one constant → branch dead → calls dead → loop dead → **1000× speedup** possible.

==**FP CSE caveat**==: `(a+b+c+d) ≡ (a+d+b+c)` only when reassoc legal:

| Data type     | `long long`            | `char`        | `float`           | `double`          |
| ------------- | ---------------------- | ------------- | ----------------- | ----------------- |
| **CSE legal** | ✅ (mod $2^w$ exact)   | ✅ (promoted) | ❌ (FP non-assoc) | ❌ (FP non-assoc) |

==**Strength reduction**==:

| Expensive             | Cheaper                                              |
| --------------------- | ---------------------------------------------------- |
| `i * 4`               | `i << 2`                                             |
| loop `i * n`          | maintain pointer / running index                     |
| **unsigned `/2^k`**   | logical right shift                                  |
| **signed `/2^k`**     | bias for negative: `(x<0 ? x+(1<<k)-1 : x) >> k`     |

> LICM valid only if no aliasing change / side effect / trap difference.

### 4.3 Inlining

| Good candidate         | Why                                       | Bad candidate    |
| ---------------------- | ----------------------------------------- | ---------------- |
| **small procedures**   | low size cost, big call-overhead win      | recursive        |
| **constant arguments** | enables further DCE/CSE                   | deep call graph  |
| **inside loop**        | save call overhead × N iters              | many call sites  |
| **called once**        | no code duplication                       | large cold fns   |

==**Call overhead**==: arg setup, `jal/ret`, save/restore live regs, frame setup. Inlining removes all + unlocks more opts. Also improves **I-cache locality** (hot caller/callee no longer ping-pong).

==**Procedure layout / I-cache**==: repeated `A()→B()` in loop, A and B far apart → I-cache thrash. Fix: (1) inline B into A via `__attribute__((always_inline))`; (2) **linker layout** A and B adjacent (PGO can guide).

### 4.4 `switch` Codegen

> [!IMPORTANT]
> ==**`switch` is NOT always faster than `if-else`**==. Depends on generated code.

| Case pattern               | Codegen                       | Consequence                                |
| -------------------------- | ----------------------------- | ------------------------------------------ |
| **dense / continuous**     | `jump table` + indirect branch | ≈ O(1), but **target-prediction is hard**  |
| **sparse / few**           | compare-branch chain          | similar to `if-else`, sometimes slower     |

## 5. Memory Aliasing

==**Problem**==: `*a` and `*b` may alias → compiler reloads/stores every iter conservatively:

```c
void sum_rows1(double *a, double *b, long n) {
    for (long i = 0; i < n; i++) {
        b[i] = 0;
        for (long j = 0; j < n; j++) b[i] += a[i*n + j];  // reloads b[i] every iter
    }
}
```

==**Fixes**==:

```c
// (1) Local accumulator
double val = 0;
for (long j = 0; j < n; j++) val += a[i*n + j];
b[i] = val;                                            // single store

// (2) restrict keyword
void sum_rows1(double *restrict a, double *restrict b, long n);
```

> Quiz: `*a, *b` not aliased but compiler doesn't reg-allocate → **(3) `restrict` + (4) manual local copies**. NOT switching compilers, NOT just `-O3`.

==**Compiler diagnostics**==: "data dependence" / "cannot vectorize" / "cannot reorder mem ops" → **alias blocks**.

```bash
gcc   -O3 -fopt-info-missed=missed.txt   my_program.c
clang -O3 -Rpass-missed='.*' -Rpass-analysis='.*'  my_program.c
```

==**Function calls in loops**==:

```c
for (i = 0; i < strlen(s); i++) ...    // QUADRATIC: strlen each iter
// ↓ LINEAR (only if loop doesn't modify s)
size_t n = strlen(s);
for (i = 0; i < n; i++) ...
```

> If loop modifies `s`, hoisting `strlen` is **wrong**. GCC knows `strlen` is "pure" but if loop modifies, must recall.

## 6. Loop Optimizations

### 6.1 Loop Unrolling

| **Benefit**                                  | **Cost**                                  |
| -------------------------------------------- | ----------------------------------------- |
| fewer branch / index updates                 | cleanup loop for non-multiples            |
| more **ILP exposed** (parallel chains)       | code size ↑ → I-cache pressure            |
| prepares for **SIMD**                        | register pressure ↑                       |
| more scheduling freedom                      | aliasing / dep constraints                |
|                                              | small `n` → cleanup dominates             |

```c
// unroll-by-4
for (i = 0; i + 4 < nelts; i += 4) {
    A[i  ] = B[i  ]*k + C[i  ];
    A[i+1] = B[i+1]*k + C[i+1];
    A[i+2] = B[i+2]*k + C[i+2];
    A[i+3] = B[i+3]*k + C[i+3];
}
for (; i < nelts; i++) A[i] = B[i]*k + C[i];        // cleanup
```

> [!IMPORTANT]
> ==**Loop unrolling ≠ locality opt**== — wins are branch overhead ↓ + ILP/SIMD ↑. Loop **interchange / fusion / tiling** are locality opts.

### 6.2 Instruction Scheduling

```c
// Hoist loads above ops; cannot move across possible aliases
for (i = 0; i+4 < n; i += 4) {
    B0=B[i]; B1=B[i+1]; B2=B[i+2]; B3=B[i+3];   // batch loads
    C0=C[i]; C1=C[i+1]; C2=C[i+2]; C3=C[i+3];
    A[i] = B0*k+C0; A[i+1] = B1*k+C1;            // independent ops
    A[i+2] = B2*k+C2; A[i+3] = B3*k+C3;
}
```

> Trap: **incorrect** if `A` overlaps `B`/`C` (writes to A change values being read).

## 7. CPE / Critical Path

==**CPE**== (Cycles Per Element): $\text{total cycles} = CPE \times n + \text{overhead}$. ==**CPE = slope**==, NOT absolute.

One accumulator critical path:

| OP          | `+` (int) | `*` (int) | `+` (FP) | `*` (FP) |
| ----------- | --------- | --------- | -------- | -------- |
| **Min CPE** | 1         | 3-5       | 3-4      | 4-5      |

==**With `k` independent accumulators**==: $CPE \ge \max(L/k, \text{issue\_limit}, \text{bw\_limit})$.

==**Reassoc trap**==: `(a+b)+(c+d)` exposes 2 indep adds → CP = $2L$ vs `(((a+b)+c)+d)` fully serial = $3L$. **Strict FP can't reassoc** without `-Ofast` / `-ffast-math` / `-ffp-contract=fast`.

==**combine4 wins**==: hoist `vec_length`; get data ptr once; accumulate in **local scalar** (no alias block); store `*dest` once at end.

==**CPE progression**==:

| Version    | `combine1` no opt | `-O1` | `-O3` | **`combine4`** | **+ unroll + k accs** |
| ---------- | ----------------- | ----- | ----- | -------------- | --------------------- |
| **Int +**  | 22.7              | 10.1  | 4.5   | **1.27**       | **0.81**              |
| **FP +**   | 20.0              | 10.2  | 6.0   | **3.01**       | **1.51**              |
| **FP ×**   | 20.2              | 11.1  | 7.8   | **5.01**       | **2.51**              |

## 8. Reduction & SIMD

```c
// k=4 indep accumulators → ILP × 4 → CPE ≈ latency/4
double s0=0, s1=0, s2=0, s3=0;
for (long i = 0; i+3 < n; i += 4) {
    s0 += a[i]; s1 += a[i+1]; s2 += a[i+2]; s3 += a[i+3];
}
double sum = (s0+s1) + (s2+s3);
```

==**SIMD reduction**==: multi-elem per instr (e.g., 4× double per AVX op), then horizontal reduce. Modern compilers auto-vectorize at `-O2`/`-O3`.

## 9. Latency vs Bandwidth Bound

| Bottleneck     | Symptom                         | Fix                                          |
| -------------- | ------------------------------- | -------------------------------------------- |
| **latency**    | dep chain, pointer chasing      | break chain, prefetch, better data structure |
| **bandwidth**  | streaming bytes saturate bus    | reduce bytes, blocking, vectorize            |
| **branch**     | unpredictable                   | branchless / better layout                   |
| **cache**      | high miss rate                  | blocking, contiguous, alignment              |

==**Latency-bound**==: single account query, **linked-list end search**, **binary-tree search**. NOT large matmul (bandwidth/locality dominated).

## 10. Data Structure & Layout Fixes

| Technique                       | Use when                                  | Main win / trap                              |
| ------------------------------- | ----------------------------------------- | -------------------------------------------- |
| **loop interchange**            | row-major scans columns                   | make innermost stride-1                      |
| **loop fusion**                 | two loops touch same arrays               | reuse hot data; avoid if deps/pressure bad   |
| **loop fission**                | one loop has long dep chain               | split work; may hurt locality                |
| **tiling / blocking**           | matrix transpose / multiply               | keep working set in cache                    |
| **array padding / alignment**   | power-of-2 conflict misses                | change set mapping; pad must be **used**     |
| **software prefetch**           | predictable miss far ahead                | hide latency; can hurt bw / pollute cache    |
| **AoS → SoA**                   | vectorize / scan one field of many objs   | contiguous fields                            |

==**Pointer-heavy → fixes**==:

| Bad                          | Good                                |
| ---------------------------- | ----------------------------------- |
| linked list                  | **array** / vector                  |
| binary tree                  | **B / B+ tree**                     |
| chained hash                 | **open addressing**                 |
| traverse 1 at a time         | **batch independent traversals**    |
| many tiny allocs             | **pool allocator** / arena          |

> Multiple in-flight mem requests + non-blocking cache + MSHRs → **MLP**.

## 11. Modern CPU Design

| Part                       | Components                                                                          |
| -------------------------- | ----------------------------------------------------------------------------------- |
| **Instruction Control**    | Fetch → I-Cache → Decode → μops; Retirement Unit; Register File; Branch Prediction  |
| **Execution**              | parallel FUs (Branch, Arith×N, Load, Store); results bus → RF; D-Cache → Loads/Stores |

==**OoO dispatch**==: instr issues as soon as inputs ready + FU free — even if later than waiting older instrs.

==**Programmer hints**==:

| Compiler can't               | You should                       |
| ---------------------------- | -------------------------------- |
| change algorithm             | pick better algorithm            |
| infer non-alias              | use `restrict` / local copy      |
| reassoc FP                   | use `-ffast-math` if safe        |
| inline across modules        | use `-flto`                      |
| pick machine-tuned codegen   | use `-march=native -mtune=native`|

## 12. Safety Traps

| Trap claim                       | Correct view                                              |
| -------------------------------- | --------------------------------------------------------- |
| compiler optimizes everything    | **semantic limits** — aliasing, FP, calls, volatile       |
| unroll always helps              | code-size + reg pressure + I-cache cost                   |
| FP reassoc is safe               | only with `-Ofast` / `-ffast-math` / proven               |
| moving loads before stores       | only if no alias / no trap                                |
| inline always helps              | bloat / I-cache / register pressure                       |
| **CPE = total cycles**           | **CPE = slope** (cycles/elem), NOT total                  |
