# Lec 5: Optimizing Program Performance

## Exam Facts

- **Optimization levers**: algorithm, data layout, compiler flags, locality, ILP, SIMD, alias info.
- ==**Compiler optimization flags**==:
  - `-O0` no optimization (debug); `-O1` (`=-O`) basic safe.
  - **`-O2`** ★ **recommended default** — safe + stable + small bloat.
  - `-O3` aggressive (unrolling, vectorization, inlining); may bloat.
  - **`-O4`** = treated as **`-O3 -flto`** (LTO).
  - `-Ofast` = `-O3 -ffast-math` (may break strict FP).
  - **`-Os`** ★ **for embedded** / size-constrained.
  - **`-flto`** link-time / whole-program optimization.
  - `-march=native` / `-mtune=native` use local CPU ISA / scheduling.
  - `-fprofile-generate` / `-fprofile-use` = PGO.
- ==**Cross-module inlining**== (Quiz 5 #4): needs **`-O3 -flto`**.
- ==**Embedded with limited memory**==: **`-Os`** (Quiz 5 #8).
- ==**Compiler semantic limits**==: **memory aliasing**, FP non-associativity, `volatile`/atomics, function calls/side effects, exceptions, separate compilation.
- ==**Basic optimizations**==: **constant folding, DCE, CSE, LICM, strength reduction, inlining, register allocation, scheduling**.
- **CFG** = control flow graph; **DFG** = data flow (value movement); **DDG** = data dependency for scheduling.
- ==**`switch` vs `if-else`**==: not a syntax-speed rule. **Dense cases** → jump table; **sparse/few** → branch chain (≈ if-else).
- ==**Cascading DCE**== (Quiz 5 #6) can give **1000× speedup** when one constant kills a whole loop's worth of work.
- ==**Loop unrolling**==: reduces branch+index overhead, exposes ILP/SIMD. **NOT primarily a locality optimization** (Quiz 5 #5).
- ==**Loop interchange / fusion / tiling**==: locality optimizations.
- **Loop unroll-by-k**: incorrect without cleanup loop when `n` not a multiple of `k`.
- ==**Procedure layout / I-cache**==: repeated `A() → B()` calls miss I-cache if A and B are far apart in memory; **fix by inlining or having linker layout A, B adjacent**.
- ==**Inline candidates**== (Quiz 5 #19): small procedures, those with constant arguments, called once in a loop. **NOT** recursive, NOT deep call graphs, NOT many call sites.
- ==**CPE**==: cycles per element; `total_cycles = CPE × n + overhead`. CPE = slope.
- ==**Reduction CPE**==: 1-accumulator → CPE ≥ `latency(OP)`. With `k` independent accumulators → CPE ≈ `latency/k` until throughput / bandwidth limit.
- ==**Non-aliasing `*a, *b`**==: if compiler doesn't allocate to regs, use **`restrict`** OR **manual local copies** (Quiz 5 #20). NOT "switch to clang" or "turn on `-O3`" alone.
- ==**FP CSE for `(a+b+c+d)` vs `(a+d+b+c)`**==: legal only for types where reassoc is OK → **`long long` and `char` ✓**; **`float` and `double` ✗** (Quiz 5 #21).
- **Pointer-heavy structures**: latency-bound; arrays / B+ trees / open addressing / batched traversals improve locality + MLP.
- **Latency-bound**: single account query, linked-list end search, binary-tree search.
- **Bandwidth-bound**: large matmul, streaming.
- ==**Compiler diagnostics**==: "data dependence", "cannot vectorize", "cannot reorder memory operations" → **possible aliasing blocks vectorization**. Use `restrict` or copy.
- **Modern CPU**: front-end (fetch/decode/branch-pred) + execution (multiple FUs in parallel, OoO) + register file + data cache. Issues μops out-of-order based on ready inputs + free FUs.

## 1. Program Optimization

| Lever | Example |
|---|---|
| algorithm | `O(n²)` → `O(n log n)` |
| data layout | linked list → array; AoS → SoA |
| compiler | `-O2`, `-O3`, `-flto`, PGO |
| μarch awareness | cache, branch pred, ILP |
| ISA | SIMD/vector/FMA |
| annotations | `restrict`, alignment, `const` |

> Optimize from **measurement / profiling**, not guesswork.

| Goal | Optimizations |
|---|---|
| **minimize instructions** | CSE, DCE, strength reduction |
| **minimize cycles** | reg alloc, scheduling, locality, redundant-load elim |
| **avoid branches** | unrolling, inlining, **conditional move (`cmov`)**, branchless transforms, unswitching |

==**Branchless transforms for unpredictable branches**==: for branches that are hard to predict (e.g., **balanced binary tree traversal**, ≈ 50/50 outcome), compiler may emit branchless code (`slt`+mask, or `cmov` on x86) to avoid misprediction penalty. Trade: one extra instr executes unconditionally; no pipeline flush. RV32I has no `cmov` in base, but `slt`+`and` patterns achieve the same.

> Real-world: Google search +0.5s → -20% traffic. Amazon +100ms → -1% sales. HFT cares about microseconds. Netflix encoding %ages → CDN $millions/yr.

## 2. Compiler Optimization Flags

| Flag | Meaning |
|---|---|
| `-O0` | no opt; fast compile; debug-friendly |
| `-O` / `-O1` | basic safe opts |
| **`-O2`** | ★ **recommended default**: highly opt, stable, small bloat |
| `-O3` | aggressive: unrolling, vectorization, inlining; may bloat / hurt |
| **`-O4`** | class note: `-O3 -flto` |
| `-Ofast` | `-O3 -ffast-math`; may break strict FP |
| **`-Os`** | optimize for **size** (embedded) |
| **`-flto`** | **link-time / whole-program** opt; enables cross-module inlining |
| `-march=native` | local CPU's ISA |
| `-mtune=native` | local CPU scheduling tuning |
| `-fprofile-generate` / `-fprofile-use` | PGO: collect runtime profile → use it |

> Quiz: cross-module procedure inlining → **`-O3 -flto`** ✅. Embedded with severe memory limits → **`-Os`** ✅.

## 3. Why Compiler Optimization Is Hard

Compiler must preserve **observable behavior**:

- ==**pointer aliasing**== (most common blocker).
- ==**FP non-associativity**==.
- ==**function calls may have side effects**== or modify memory.
- `volatile`, atomics, I/O.
- possible traps / exceptions.
- separate compilation (without `-flto`).
- no algorithm/domain/runtime knowledge.
- optimal scheduling / register allocation is **NP-hard**.

> Compilers can't change algorithm. AI-assisted compilers may someday substitute algorithms; today, mostly help w/ heuristic tuning, phase ordering, autotuning kernels.

## 4. Basic Compiler Optimizations

### 4.1 Local / Global / Whole-Program Scope

| Scope | Examples |
|---|---|
| local block | constant folding, local CSE, DCE |
| function/global CFG | LICM, global CSE, register allocation |
| whole-program | LTO, interprocedural inlining |

==**CFG**== = control-flow paths. ==**DFG**== = value flow. ==**DDG**== = scheduling order constraints (used in [4_5_review.md](notes%20quiz%202/4_5_review.md)).

### 4.2 Constant Folding / Propagation

```c
long mask = 0xFF << 8;             // → 0xFF00
size_t n = strlen("Harry Bovik");  // → 11
```

### 4.3 Dead Code Elimination (DCE)

```c
if (0) puts("never");      // dead
x = 23;                    // dead if next stmt overwrites
x = 42;                    // → x = 42 only
```

==**Cascading DCE**== (Quiz 5 #6): one constant → branch dead → calls dead → loop dead → **1000× speedup possible**.

### 4.4 Common Subexpression Elimination (CSE)

```c
norm[i] = v[i].x * v[i].x + v[i].y * v[i].y;
```
↓
```c
elt = &v[i];
x = elt->x;  y = elt->y;
norm[i] = x*x + y*y;
```

==**FP CSE caveat**==: `(a+b+c+d)` ≡ `(a+d+b+c)` only when **reassoc is legal**:

| Data type     | `long long`         | `char`        | `float` | `double` |
| ------------- | ------------------- | ------------- | ------- | -------- |
| **CSE legal** | ✅ (mod $2^w$ exact) | ✅ (promoted) | ❌ (FP non-assoc) | ❌ (FP non-assoc) |

> Quiz answer: **`long long` and `char`**.

### 4.5 LICM (Loop Invariant Code Motion)

Move loop-invariant work out:

```c
for (j=0; j<n; j++)  a[n*i + j] = b[j];
```
↓
```c
int ni = n*i;
for (j=0; j<n; j++)  a[ni + j] = b[j];
```

> Valid only if no aliasing change / side effect / trap difference.

### 4.6 Strength Reduction

| Expensive | Cheaper |
|---|---|
| `i * 4` | `i << 2` |
| loop `i * n` | maintain pointer / running index |
| **unsigned `/2^k`** | logical right shift |
| **signed `/2^k`** | bias for negative: `(x<0 ? x+(1<<k)-1 : x) >> k` |

### 4.7 Inlining

==**Good candidates**== (Quiz 5 #19):

| Candidate | Why |
|---|---|
| **small procedures** | low size cost, big call-overhead win |
| **constant arguments** | enables further DCE/CSE |
| **inside loop** | save call overhead × N iters |
| **called once** | no code duplication |

==**Bad candidates**==:

- recursive / deep call graph.
- many call sites → code bloat.
- large cold functions.

==**Call overhead**==: arg setup, `jal/ret`, save/restore live regs, stack frame setup, prologue/epilogue. Inlining removes all this and unlocks more optimizations.

> Inlining can also improve **I-cache locality**: hot caller/callee no longer ping-pong between distant cache lines/pages.

==**Procedure layout / I-cache**== (Quiz 5 final): repeated `A() → B()` calls in a loop, with A and B far apart → I-cache thrash. Fix:

1. **inline B into A** via `__attribute__((always_inline))` / pragma.
2. **linker layout** places A and B adjacent (PGO can guide).

### 4.8 `switch` Codegen

> [!IMPORTANT]
> ==**`switch` is NOT always faster than `if-else`**==. Performance depends on the generated code.

| Case pattern | Codegen | Consequence |
|---|---|---|
| **dense / continuous** | `jump table` + indirect branch | ≈ O(1), but **target-prediction is hard** |
| **sparse / few** | compare-branch chain | similar to `if-else`, sometimes slower |

## 5. Memory Aliasing

### 5.1 The Problem

```c
void sum_rows1(double *a, double *b, long n) {
    for (long i = 0; i < n; i++) {
        b[i] = 0;
        for (long j = 0; j < n; j++)
            b[i] += a[i*n + j];
    }
}
```

Generated inner loop **reloads/stores `b[i]` every iter** because `a` and `b` *may* alias (compiler must be conservative):

```asm
.L:
    fld     fa5, 0(a3)     # load b[i]    ← reload every iter!
    fld     fa4, 0(a4)     # load a[i*n+j]
    fadd.d  fa5, fa5, fa4
    fsd     fa5, 0(a3)     # store b[i]   ← store every iter!
    addi    a4, a4, 8
    bne     a4, a5, .L
```

If compiler could prove **non-aliasing**:

```asm
.L:
    fld     fa4, 0(a4)
    fadd.d  fa5, fa5, fa4    # b[i] kept in fa5, no load/store
    addi    a4, a4, 8
    bne     a4, a5, .L
```

### 5.2 Fixes

==**(1) Local accumulator**==:

```c
void sum_rows2(double *a, double *b, long n) {
    for (long i = 0; i < n; i++) {
        double val = 0;
        for (long j = 0; j < n; j++)
            val += a[i*n + j];
        b[i] = val;             // single store
    }
}
```

==**(2) `restrict` keyword**==:

```c
void sum_rows1(double *restrict a, double *restrict b, long n);
```

`restrict` declares no aliasing → compiler can vectorize / reorder memory aggressively.

> Quiz 5 #20: `*a, *b` not aliased but compiler doesn't allocate to regs → answers are **(3) `restrict` + (4) manual local copies**. NOT switching compilers, NOT just `-O3`.

==**Compiler diagnostics**==: when you see "data dependence" / "cannot vectorize" / "cannot reorder memory ops" → **alias blocking optimization**.

```bash
gcc   -O3 -fopt-info-missed=missed.txt   my_program.c
clang -O3 -Rpass-missed='.*' -Rpass-analysis='.*'  my_program.c
```

### 5.3 Function Calls in Loops

```c
// QUADRATIC: strlen called every iter
for (i = 0; i < strlen(s); i++) ...

// LINEAR (only if loop body doesn't change s):
size_t n = strlen(s);
for (i = 0; i < n; i++) ...
```

> If the loop modifies `s`, hoisting `strlen` is **wrong**. GCC knows `strlen` is "pure," but if loop modifies the string, must call again.

## 6. Loop Optimizations

### 6.1 Loop Unrolling

==**Benefits**==:

- fewer branch / index updates.
- more **ILP exposed** (multiple parallel chains).
- prepares code for **SIMD** vectorization.
- enables more scheduling freedom.

==**Costs**==:

- cleanup loop for non-multiples.
- **code size** ↑ → I-cache pressure.
- register pressure ↑.
- aliasing / dependency constraints.
- small `n` → cleanup dominates before steady-state CPE reached.

```c
// unroll-by-4
for (i = 0; i + 4 < nelts; i += 4) {
    A[i  ] = B[i  ]*k + C[i  ];
    A[i+1] = B[i+1]*k + C[i+1];
    A[i+2] = B[i+2]*k + C[i+2];
    A[i+3] = B[i+3]*k + C[i+3];
}
// cleanup
for (; i < nelts; i++)
    A[i] = B[i]*k + C[i];
```

> Without cleanup, unroll-by-4 is **incorrect** when `nelts` not a multiple of 4.

> [!IMPORTANT]
> ==**Loop unrolling is NOT a locality optimization**== — its main wins are reduced branch overhead + exposed ILP/SIMD. Loop **interchange / fusion / tiling** are the locality opts.

### 6.2 Instruction Scheduling

Move independent loads/ops earlier to hide latency. **Cannot move stores/loads across possible aliases**.

```c
// Schedule: hoist loads above ops
for (i = 0; i+4 < n; i += 4) {
    B0=B[i]; B1=B[i+1]; B2=B[i+2]; B3=B[i+3];   // batch loads
    C0=C[i]; C1=C[i+1]; C2=C[i+2]; C3=C[i+3];
    A[i  ] = B0*k + C0;                         // independent ops
    A[i+1] = B1*k + C1;
    A[i+2] = B2*k + C2;
    A[i+3] = B3*k + C3;
}
```

> Trap: **incorrect** if `A` overlaps `B` or `C` (the writes to A would change values being read).

> Cross-branch scheduling shrinks scope (basic block = small unit). This is a compiler limit even when no alias issue.

## 7. CPE / Critical Path

==**CPE**== (Cycles Per Element): performance metric for loops over vectors/arrays.

$$
total\ cycles = CPE \times n + overhead
$$

==**CPE = slope**== of cycles vs `n` plot (NOT the absolute value).

==**Reduction**== `sum = sum OP a[i]`:

```text
sum0 → sum1 → sum2 → sum3 → ...
```

One accumulator critical path:

| OP          | `+` (int) | `*` (int) | `+` (FP) | `*` (FP) |
| ----------- | --------- | --------- | -------- | -------- |
| **Min CPE** | 1         | 3-5       | 3-4      | 4-5      |

==**With `k` independent accumulators**==:

$$
CPE \ge \max\left(\frac{L}{k},\ issue\_limit,\ bandwidth\_limit\right)
$$

==**Reassoc requirement**==: `(a+b)+(c+d)` exposes 2 indep adds before final → critical path = `2L` instead of `3L`. For `(((a+b)+c)+d)` → fully serial. **Strict FP → compiler can't reassoc unless `-Ofast` / `-ffast-math` / `-ffp-contract=fast`**.

### 7.1 Vector Combine Pattern (combine1 → unroll)

==**combine4 wins**==:

- hoist `vec_length` out of loop.
- get data pointer once.
- accumulate in **local scalar** (no aliasing block).
- store `*dest` once at the end.

==**CPE progression**==:

| Version              | `combine1` no opt | `-O1` | `-O3` | **`combine4`** | **+ unroll + k accs** |
| -------------------- | ----------------- | ----- | ----- | -------------- | --------------------- |
| **Int +**            | 22.7              | 10.1  | 4.5   | **1.27**       | **0.81**              |
| **FP +**             | 20.0              | 10.2  | 6.0   | **3.01**       | **1.51**              |
| **FP ×**             | 20.2              | 11.1  | 7.8   | **5.01**       | **2.51**              |

## 8. Reduction & SIMD

==**Multiple accumulators**==:

```c
double s0=0, s1=0, s2=0, s3=0;
for (long i = 0; i+3 < n; i += 4) {
    s0 += a[i  ];   s1 += a[i+1];
    s2 += a[i+2];   s3 += a[i+3];
}
double sum = (s0+s1) + (s2+s3);
```

==**Independent chains**== → ILP × 4 → CPE ≈ `latency/4`.

==**SIMD/vector reduction**==: process multiple elements per instr (e.g., 4× double per AVX op), then horizontal reduce. Modern compilers auto-vectorize at `-O2`/`-O3`.

## 9. Latency-Bound vs Bandwidth-Bound

| Bottleneck | Symptom | Fix |
|---|---|---|
| **latency** | dependency chain, pointer chasing | break chain, prefetch, better data structure |
| **bandwidth** | streaming bytes saturate bus | reduce bytes, blocking, vectorize |
| **branch** | unpredictable | branchless / better layout |
| **cache** | high miss rate | blocking, contiguous, alignment |

==**Latency-bound examples**== (Quiz 2 #1):

- single account query.
- **linked-list end search**.
- **binary-tree search**.

> NOT large matrix multiply (that's bandwidth/throughput/locality dominated).

## 10. Data Structure Fixes

==**Memory locality transformations**== (CA3060 Review):

| Technique | Use when | Main win / trap |
|---|---|---|
| **loop interchange** | row-major code scans columns | make innermost loop stride-1 |
| **loop fusion** | two loops touch same arrays | reuse data while hot; avoid if deps/pressure bad |
| **loop fission / distribution** | one loop has long dep chain / too much pressure | split independent work; may hurt locality if split arrays reused |
| **tiling / blocking** | matrix transpose / multiply | keep working set in cache |
| **array padding / alignment** | conflict misses from power-of-2 spacing | change set mapping; padding must be used so compiler keeps it |
| **software prefetch** | predictable miss far enough ahead | hide latency; can hurt bandwidth/cache pollution |
| **AoS → SoA** | vectorize / scan one field of many objects | contiguous fields; worse if whole object always used |

==**Pointer-heavy** (slow on pipelined CPUs)==:

- linked lists.
- binary trees.
- queues/stacks of nodes.
- hash tables with **chained collisions**.

==**Fixes**==:

| Bad | Good |
|---|---|
| linked list | **array** / vector |
| binary tree | **B / B+ tree** |
| chained hash | **open addressing** |
| traverse one item at a time | **batch independent traversals** |
| many tiny allocs | **pool allocator** / arena |

> Multiple in-flight memory requests + non-blocking cache + MSHRs → **MLP**.

## 11. Modern CPU Design

==**Two main parts**==:

| Part | Components |
|---|---|
| **Instruction Control** | Fetch → I-Cache → Decode → μops; Retirement Unit; Register File; Branch Prediction |
| **Execution** | multiple FUs (Branch, Arith ×N, Load, Store) operating **in parallel**; results bus to RF; D-Cache services Loads/Stores |

==**Out-of-order**== dispatch: as soon as inputs are ready + FU free, instr issues — even if later in machine code than waiting older instrs.

==**Programmer hints**==:

| Compiler can't | You should |
|---|---|
| change algorithm | pick better algorithm |
| infer non-alias | use `restrict` / local copy |
| reassoc FP | use `-ffast-math` if safe |
| inline across modules | use `-flto` |
| pick machine-tuned codegen | use `-march=native -mtune=native` |

## 12. Safety Traps

| Trap claim | Correct view |
|---|---|
| compiler optimizes everything | **semantic limits** — aliasing, FP, calls, volatile |
| unroll always helps | code-size + reg pressure + I-cache cost |
| FP reassoc is safe | only with `-Ofast` / `-ffast-math` / proven |
| moving loads before stores | only if no alias / no trap |
| inline always helps | bloat / I-cache / register pressure |
| **CPE = total cycles** | **CPE = slope** (cycles/elem), NOT total |
