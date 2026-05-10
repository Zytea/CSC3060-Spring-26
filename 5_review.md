# Chapter 5: Optimizing Program Performance

## Exam Facts

- First optimization step: **turn on compiler optimization**.
- `-O0`: debug/no opt; `-O1/-O`: basic; `-O2`: more safe opts; `-O3`: aggressive loop/SIMD/unroll; `-Os`: size; `-O3 -flto`: link-time/whole-program.
- Cross-module inlining requires **LTO**: quiz answer `-O3 -flto`.
- Optimizations with no primary locality goal: **loop unrolling**.
- Cascading DCE can produce huge speedups if earlier opts expose dead code.
- Compiler limits: **aliasing, FP semantics, volatile, function side effects, separate compilation, unknown runtime data**.
- Use `restrict` or local scalar copies when frequent pointer loads block register allocation/vectorization.

## Compiler Optimization Goals

- Reduce instruction count: constant folding, DCE, CSE, strength reduction.
- Reduce expensive operations: replace mul/div with shifts/adds when legal.
- Improve locality: loop interchange, fusion, tiling/blocking.
- Expose ILP: unrolling and scheduling.
- Reduce branches/calls: inlining, unswitching, unrolling.
- Pointer chasing in linked lists/trees is usually **latency-bound**; streaming arrays can be bandwidth/locality-bound.
- Large independent array/matrix work tends throughput/bandwidth-bound; dependent lists/trees tend latency-bound.

## Basic Optimizations

- ==**Constant folding**==: compute constants at compile time.
- ==**DCE**==: remove computations whose results are never used; cascading DCE may unlock 1000x-style cases.
- ==**CSE**==: compute repeated expression once if no intervening side effects/alias.
- CSE/reassociation safe for exact integer ops if no overflow UB; unsafe for `float/double` unless fast-math permits.
- ==**LICM**==: move loop-invariant computation outside loop.
- ==**Inlining**==: remove call overhead and enable constant propagation/DCE; risk = code bloat/I-cache pressure.

Inlining good candidates: **small procedures, constant args, called once in loop**. Bad: recursive, huge, too many call sites.

## Aliasing

==**Aliasing**==: two pointers may refer to same memory, forcing conservative loads/stores.
- Compiler may say cannot vectorize/reorder due to dependent memory operations.
- Fix: `restrict`, local temp variables, better API/data layout.
- `restrict` says this pointer is the only way to access that object in its scope.

Quiz pattern: if `*a` and `*b` do not alias but compiler cannot know, use **restricted pointers** or manually copy to locals.

## Loop Optimizations

- ==**Loop unrolling**==: fewer branch/index overheads, more ILP, more registers; not primarily locality.
- ==**Scheduling**==: reorder loads/ops to hide latency and use functional units.
- ==**Loop interchange**==: change loop order to improve spatial locality.
- ==**Loop fusion**==: combine loops over same data to improve temporal locality and reduce overhead.
- ==**Loop tiling/blocking**==: operate on cache-sized blocks to improve locality.

## CPE / Vector Combine

- ==**CPE**==: cycles per element; `cycles = CPE*n + overhead`.
- Reduce CPE by eliminating repeated length calls, reducing memory refs, using accumulators, unrolling, reassociation if legal.
- Reduction dependency chain can limit latency; multiple accumulators reduce critical path.
- Latency-bound reduction: unroll by k with k independent accumulators gives approximate CPE `latency/k` until throughput/resource bound dominates.
- Optimal CPE is at least max of critical-path bound and functional-unit/load-store bandwidth bound.

## Safety Traps

- FP reassociation not generally legal unless fast-math/contract flags permit.
- Function calls may have side effects; compiler cannot move them freely.
- Volatile and memory consistency restrict reordering.
- Separate compilation hides cross-module facts unless LTO is enabled.
