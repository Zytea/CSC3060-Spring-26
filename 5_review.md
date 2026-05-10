# Lec 5: Optimizing Program Performance

## Exam Facts

- Optimization levers: algorithm, data layout, compiler flags, locality, ILP, SIMD, alias info.
- Flags: `-O2` safe default; `-O3` aggressive; `-Ofast=-O3 -ffast-math`; `-flto` enables cross-module/LTO optimization.
- Embedded tight memory: use `-Os`.
- Cross-module procedure inlining needs `-O3 -flto` style LTO.
- Compiler cannot change semantics: aliasing, FP non-associativity, volatile/atomics, calls/side effects, exceptions, separate compilation.
- Basic optimizations: constant folding, DCE, CSE, LICM, strength reduction, inlining, register allocation, scheduling.
- Cascading DCE can produce huge speedup if it removes almost all work.
- Loop unrolling reduces overhead and exposes ILP/SIMD; it is **not primarily a locality optimization**.
- Class-discussed locality optimization: loop transformations such as interchange/fusion/tiling, not CUDA/SIMT.
- CPE = cycles per element; `cycles = CPE*n + overhead`.
- Reduction with one accumulator is latency-bound; k accumulators reduce critical-path CPE about `latency/k` until throughput/bandwidth limits.
- If non-aliasing `*a,*b` stay in memory, use `restrict` or local scalar copies.
- Pointer-heavy data structures are latency-bound; arrays/B+ trees/open addressing improve locality/MLP.

## 1. Program Optimization

| Lever | Example |
|---|---|
| algorithm | `O(n^2)` -> `O(n log n)` |
| data layout | linked list -> array, AoS -> SoA |
| compiler | `-O2`, `-O3`, `-flto`, PGO |
| microarchitecture | cache, branch prediction, ILP |
| ISA | SIMD/vector/FMA |
| annotations | `restrict`, alignment, `const` |

> Optimize from measurement/profiling, not guesswork.

## 2. Compiler Optimization Flags

| Flag | Meaning |
|---|---|
| `-O0` | no optimization, debugging |
| `-O` / `-O1` | basic safe opts |
| `-O2` | default recommended |
| `-O3` | more unrolling/vectorization/inlining; may bloat |
| `-Ofast` | fast but may break strict FP |
| `-Os` | optimize for size |
| `-flto` | link-time whole-program optimization |
| `-march=native` | use local CPU ISA |
| `-mtune=native` | tune scheduling for local CPU |

## 3. Why Compiler Optimization Is Hard

Compiler must preserve visible behavior:

- pointer aliasing.
- FP non-associativity.
- calls may modify memory or have side effects.
- `volatile`, atomics, I/O.
- possible traps/exceptions.
- separate compilation without LTO.
- optimal scheduling/register allocation is hard.

## 4. Basic Compiler Optimizations

### 4.1 Local / Global / Whole-Program

| Scope | Examples |
|---|---|
| local block | folding, local CSE, DCE |
| function/global CFG | LICM, global CSE, register allocation |
| whole-program | LTO, interprocedural inlining |

### 4.2 Constant Folding / Propagation

```c
long mask = 0xFF << 8;           // 0xFF00
size_t n = strlen("Harry Bovik"); // 11
```

### 4.3 Dead Code Elimination

```c
if (0) puts("never");
x = 23;
x = 42;      // first store dead if x unread
```

Cascading DCE: one constant makes branch dead -> calls dead -> whole loop dead -> huge speedup.

### 4.4 Common Subexpression Elimination

Reuse repeated integer/address/pointer computations.

```c
A->b->c->e + A->b->c->d   // share A->b->c
```

FP caveat: `(a+b+c+d)` and `(a+d+b+c)` are CSE only for types where reassociation is legal. Quiz answer: `long long` and `char` yes; `float/double` no under strict FP.

### 4.5 LICM

Move loop-invariant work out:

```c
for (j=0;j<n;j++) a[n*i+j]=b[j];
```

```c
int ni=n*i;
for (j=0;j<n;j++) a[ni+j]=b[j];
```

Valid only if no changed side effects/alias/traps.

### 4.6 Strength Reduction

| Expensive | Cheaper |
|---|---|
| `i*4` | `i<<2` |
| loop `i*n` | pointer/index increment |
| unsigned `/2^k` | logical shift |

Signed `/2^k` needs bias for negative values.

### 4.7 Inlining

Good candidates:

- small hot functions.
- functions with constant arguments.
- called inside loop.
- called once where body enables DCE/CSE.

Bad candidates:

- recursive/deep call graph.
- many call sites causing code bloat.
- large cold functions.

## 5. Memory Aliasing

### 5.1 Problem

```c
for (j=0;j<n;j++)
    b[i] += a[i*n+j];
```

If `a[...]` may alias `b[i]`, compiler must reload/store `b[i]` repeatedly.

### 5.2 Fixes

Local accumulator:

```c
double val=0;
for (j=0;j<n;j++) val += a[i*n+j];
b[i]=val;
```

Restricted pointers:

```c
void f(double *restrict a, double *restrict b, long n);
```

Quiz: if `*a,*b` frequently used and do not alias, use **`restrict`** or **manual local copies**.

### 5.3 Function Calls in Loops

```c
for (i=0;i<strlen(s);i++) ...
```

Can become quadratic if `s` may change. Hoist only if length invariant:

```c
size_t n=strlen(s);
for (i=0;i<n;i++) ...
```

## 6. Loop Optimizations

### 6.1 Loop Unrolling

Benefits:

- fewer branch/index updates.
- more ILP.
- exposes scheduling/SIMD.

Costs:

- cleanup loop.
- code size/I-cache pressure.
- register pressure.
- aliasing constraints.

Quiz: too much unrolling can be slower due to I-cache/code size, register pressure, limited FUs.

### 6.2 Instruction Scheduling

Move independent loads/ops earlier to hide latency, but do not move stores/loads across possible aliases.

## 7. CPE / Critical Path

==**CPE**==: cycles per processed element.

```text
cycles = CPE*n + overhead
```

For a reduction:

```c
sum = sum OP a[i];
```

one accumulator critical path:

```text
sum0 -> sum1 -> sum2 -> ...
```

If `OP` latency = `L`, ideal CPE is at least `L` with one accumulator.

With `k` independent accumulators:

$$
CPE \ge \max(L/k,\ issue\_limit,\ bandwidth\_limit)
$$

CMU-style examples:

| Case | Ideal CPE idea |
|---|---|
| multiply latency 4, one product chain | `4` |
| unroll 3 independent chains | `4/3` |
| dot product add latency 5, unroll 2 accumulators | `5/2=2.5` |
| target CPE 0.5 with add latency 5 | need `k=10` accumulators if throughput unlimited |

## 8. Reduction and SIMD

Multiple accumulators:

```c
s0=s1=s2=s3=0;
for (i=0;i+3<n;i+=4) {
  s0 += a[i]; s1 += a[i+1];
  s2 += a[i+2]; s3 += a[i+3];
}
sum = s0+s1+s2+s3;
```

SIMD/vector reduction processes multiple elements per instr, then horizontally reduces lanes.

## 9. Latency-Bound vs Bandwidth-Bound

| Bottleneck | Symptom | Fix |
|---|---|---|
| latency | dependency chain/pointer chasing | break chain, prefetch, better structure |
| bandwidth | streaming bytes saturated | reduce bytes, block, vectorize |
| branch | unpredictable branch | branchless/layout |
| cache | high miss rate | blocking, contiguous layout |

Latency-bound quiz examples: single account query, linked-list end search, binary-tree search. Large matrix multiply is bandwidth/throughput/locality dominated.

## 10. Data-Structure Fixes

Pointer-heavy structures:

- linked lists.
- binary trees.
- queues/stacks as nodes.
- hash tables with chained collisions.

Fix:

- arrays/contiguous storage.
- B/B+ trees.
- open addressing.
- batch independent traversals.
- pool allocation.

## 11. Safety Traps

| Trap | Correct idea |
|---|---|
| compiler optimizes everything | semantic limits |
| unroll always helps | code size/reg pressure/I-cache |
| FP reassociation is safe | only fast-math or proven |
| loads before stores | only if no alias/trap |
| inline always helps | may bloat |
| CPE is total cycles | CPE is slope |
