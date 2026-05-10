# Lec 5: Optimizing Program Performance

## Exam Facts

- First optimization step: **enable compiler optimization**.
- Flags: `-O0` debug, `-O1/-O` basic, `-O2` safe default, `-O3` aggressive, **`-Os` size**, **`-O3 -flto` cross-module/LTO**.
- Cross-module procedure inlining requires **`-O3 -flto`**.
- `-Ofast = -O3 -ffast-math`; may break IEEE FP assumptions.
- Quiz: optimization with **no primary locality goal** = **loop unrolling**. Locality transforms: interchange, fusion, tiling/blocking.
- Quiz: possible **1000x speedup** = **cascading DCE**.
- Class-discussed compiler optimization: **loop transformations for data locality**. Not CUDA/SIMT/multithreading.
- Compiler limits: aliasing, FP non-associativity, volatile, side effects/calls, separate compilation, unknown runtime data.
- If `*a` and `*b` are frequent and non-aliasing but compiler keeps them in memory: use **`restrict`** or manual local scalar copies.
- CSE/reassociation for `(a+b+c+d)` and `(a+d+b+c)` is safe for integer types (`long long`, `char`), not `float/double`.
- Good inlining candidates: **small procedures**, multiple constant args, called once in a loop. Bad: recursive, very large, many call sites.
- Pointer chasing (linked list/tree) is latency-bound; matrix multiply/streaming arrays are bandwidth/throughput-bound.

## 1. Program Optimization

Optimization goals:

- reduce instruction count.
- reduce cycles per instruction / stalls.
- improve locality and memory behavior.
- expose ILP/SIMD.
- keep correctness under language rules.

> Algorithm/data-structure improvement beats compiler tricks. Compiler cannot turn O(n^2) into O(n log n) unless you change the algorithm.

## 2. Compiler Optimization Levels

| Flag | Meaning |
|---|---|
| `-O0` | no optimization; debugging |
| `-O1` / `-O` | basic local/global opts |
| `-O2` | safe default: most non-size-exploding opts |
| `-O3` | aggressive loop opts, unrolling, vectorization; possible code bloat |
| `-Os` | optimize for code size, embedded memory-limited builds |
| `-O3 -flto` | link-time whole-program analysis; cross-module inlining |
| `-Ofast` | `-O3` plus fast-math semantics |
| `-march=native` | use local CPU ISA/features |
| PGO | `-fprofile-generate` then `-fprofile-use` |

## 3. Why Compiler Optimization Is Hard

Compiler must preserve observable behavior:

- pointer aliasing may make memory ops dependent.
- FP operations are not associative.
- calls may have side effects.
- `volatile`/atomic accesses are ordered.
- runtime values are unknown.
- separate compilation hides other modules unless LTO is enabled.
- optimal register allocation/scheduling/phase ordering is hard.

## 4. Basic Compiler Optimizations

### 4.1 Constant Folding / Propagation

```c
int x = 3 * 8;        // x=24
if (DEBUG == 0) ...   // branch may disappear
```

### 4.2 Dead Code Elimination (DCE)

```c
x = 1;
x = 2;       // first store dead if x not read
if (0) f();  // removed
```

==**Cascading DCE**==: one removal exposes another removal; can create very large speedups when templates/debug/checking layers collapse.

### 4.3 Common Subexpression Elimination (CSE)

```c
t = a*b;
x = t + c;
y = t + d;
```

For integer expressions, compiler may reuse/reassociate when overflow/semantics allow. For FP, do not assume:

```c
(x+y)+z != x+(y+z)   // possible because rounding
```

Quiz: `(a+b+c+d)` and `(a+d+b+c)` CSE -> **long long, char**; not `float/double`.

### 4.4 Loop-Invariant Code Motion (LICM)

```c
for (j=0; j<n; j++) a[n*i+j] = b[j];
```

Move `n*i` outside inner loop.

### 4.5 Strength Reduction

- replace multiply by constant with shifts/adds.
- replace division by power of 2 with shifts when semantics allow.
- for signed division by `2^k`, add bias for negative values to round toward 0.

### 4.6 Inlining

Inlining removes call/return overhead and exposes constants, CSE, DCE, register allocation, and scheduling.

| Good | Bad |
|---|---|
| small function | recursive |
| constant args | large body |
| called once inside loop | many call sites causing code bloat |

## 5. Memory Aliasing

==**Aliasing**==: two references may name the same memory location.

Example:

```c
void f(double *a, double *b) {
    *a += *b;
    *b += 1;
}
```

If `a==b`, transformations that keep `*a`/`*b` in separate registers can be wrong.

### 5.1 Fixes for Alias-Limited Code

```c
void f(double *restrict a, double *restrict b, long n)
```

`restrict`: within this scope, object is accessed only through that pointer-derived path.

Manual scalar copy:

```c
double aa = *a, bb = *b;
/* compute in registers */
*a = aa; *b = bb;
```

Quiz answer for frequent non-aliasing `*a`, `*b`: **restricted pointers** and **local variables manually**.

### 5.2 Function Calls in Loops

```c
for (i=0; i<strlen(s); i++) ...
```

May be O(n^2). Hoist `strlen` only if loop cannot modify `s`.

## 6. Loop Optimizations

| Transform | Main purpose |
|---|---|
| loop unrolling | reduce branch/index overhead; expose ILP |
| loop interchange | make inner loop access contiguous data |
| loop fusion | combine loops over same data; improve reuse |
| loop tiling/blocking | operate on cache-sized blocks |
| loop unswitching | move invariant branch outside loop |

> Quiz: unrolling is not primarily for locality.

## 7. CPE / Combine Benchmark

==**CPE**==: cycles per element.

```text
cycles = CPE*n + overhead
```

Optimization steps in vector combine:

1. avoid repeated `vec_length` calls.
2. avoid bounds checks via raw data pointer.
3. accumulate in local variable.
4. unroll loop.
5. use multiple accumulators to break dependency chains.

Multiple accumulators:

```c
x0 = IDENT; x1 = IDENT;
for (i=0; i<limit; i+=2) {
  x0 = x0 OP d[i];
  x1 = x1 OP d[i+1];
}
*dest = x0 OP x1;
```

Why it works: one accumulator creates a latency chain; k accumulators reduce CPE until FU/load bandwidth becomes the bottleneck.

## 8. Reduction and SIMD

Reduction:

```c
sum += a[i];
```

One scalar accumulator is latency-bound. SIMD/multiple accumulators create independent partial reductions, then combine at the end.

## 9. Latency-Bound vs Bandwidth-Bound

| Pattern | Bound |
|---|---|
| one account-balance query | latency |
| linked-list traversal | latency |
| binary-tree search | latency + branch/data hazards |
| large matrix multiply | bandwidth/throughput |
| streaming array traversal | bandwidth |

### 9.1 Data-Structure Fixes for Pointer Chasing

- prefer contiguous arrays.
- B/B+ tree over binary tree.
- open addressing over collision chains.
- batch multiple independent lookups.
- allow multiple memory requests in flight.

## 10. Safety Traps

- FP reassociation needs fast-math permission.
- `restrict` is a promise; wrong use gives wrong code.
- unrolling needs cleanup for remainder.
- overlapping arrays can break vectorization/unrolling assumptions.
- code bloat can hurt I-cache.
