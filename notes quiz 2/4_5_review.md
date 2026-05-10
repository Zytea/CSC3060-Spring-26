# Lec 4.5: Code (Instruction) Scheduling

## Exam Facts

- ==**Code scheduling**==: reorder instrs to **reduce stalls** while preserving deps.
- ==**True dependence = RAW**==.
- Legal schedule = any **topological order** of dependence DAG.
- Critical path = longest **weighted** path. Schedule critical-path nodes **early**.
- Compiler scheduling limited by ==**memory aliasing**== + ==**unknown/non-deterministic memory latency**==. (NOT structural hazards or "error-prone".)
- HW data-hazard reduction: ==**forwarding/bypassing + OoO**==. SW: ==**compiler scheduling**==.
- For N instrs: best case = **1** schedule (chain); worst case = **N!** (no deps); never quadratic.
- Cannot move loads past stores if addresses **may alias** — use `restrict` or local copies.

## 1. Why Reschedule

A naive order leaves the pipeline stalled at every dependency. Reordering **independent instrs** into bubble slots reduces total cycles.

## 2. Three Register Data Dependences

| Type | Meaning | Constraint |
|---|---|---|
| ==**RAW**== | Read After Write (true / flow) | producer → consumer |
| ==**WAR**== | Write After Read (anti) | early reader before later writer overwrites |
| ==**WAW**== | Write After Write (output) | last writer's result wins |
| RAR | Read After Read | **no dependence** |

> [!IMPORTANT]
> - RAW edge weight = **op latency** (ALU 1, Load 2, Mul 3, FMA 5-6).
> - WAR/WAW are **order-only** (weight ≈ 0-1).
> - In simple in-order 5-stage, WAR/WAW don't stall but constrain compiler schedule.

## 3. Memory Dependence (Aliasing)

Compiler must conservatively assume two pointers **may alias** unless proven otherwise.

⇒ Cannot freely:
- move a load **before** an earlier store,
- swap two stores,
- vectorize loops with possibly-aliasing pointers.

Fixes:
- ==**`restrict`** keyword==.
- Copy pointer-pointed values into ==**local scalars**== before loop.
- Better data layout / API.

> Volatile vars (OS kernels, I/O) **forbid** any reordering.

## 4. Dependence DAG

- **Node** = instr.
- **Edge A→B** = B depends on A (must be scheduled later).
- **Edge weight** = op latency (cyc A's result must wait before B can use it).
- Legal schedule = any topological order respecting all edges.

## 5. Operation Latency / Critical Path

| Op | Latency (typical) |
|---|---|
| ALU | 1 |
| Load (cache hit) | 2 |
| Multiply | 3 |
| Divide | ~32 |
| FADD | 4 |
| FMUL | 5 |
| FMA | 5-6 |

==**Critical Path = longest weighted path** from any node to a leaf==.

### 5.1 Compute Node Priority (Maximum Delay)

Reverse-topological:

$$\text{MD}(n) = \text{latency}(n) + \max_{m \in \text{successors}(n)} \text{MD}(m)$$

Use 0 for WAR/WAW edges' latency; full latency for RAW.

## 6. List Scheduling Algorithm

```
1. Build dependence DAG.
2. Compute MD (priority) for each node.
3. Maintain ready set = nodes with no unscheduled predecessors.
4. Each cycle:
   a. Pick best ready node by heuristic.
   b. Issue; track in-flight.
   c. Update successors' counters; release when satisfied.
5. Repeat until all scheduled.
```

### 6.1 Heuristics for Ready-Set Selection

1. Favor nodes that **issue without stalling** (RAW preds finished).
2. Tie: largest **MD** (critical path).
3. Tie: original program order.
4. Tie: largest number of children.
5. Tie: final use of a register.

### 6.2 Pattern (worked example)

| Step | Ready | Pick | Reason |
|---|---|---|---|
| 1 | {1, 2, 9} | 1 | largest MD |
| 2 | {2, 9} | 2 | no stall |
| 3 | {3, 5, 9} | **9** | 3/5 stall on load latency; 9 fills gap |
| 4 | {3, 5} | 3 | larger MD |

> Pattern: **fill load-latency gaps with independent instrs**.

## 7. Schedule Counts

For N instrs:
- **Best case** (chain of deps): exactly **1** legal schedule.
- **Worst case** (no deps): **N!** legal schedules.

⇒ Exhaustive search infeasible; use heuristics.

## 8. HW vs SW Hazard Mitigation

| Solution | Where |
|---|---|
| Forwarding / Bypassing | HW |
| Out-of-Order execution | HW |
| Compiler scheduling | SW |
| Stalls / interlocks | HW (default if scheduling fails) |
| Branch prediction | HW (separate, control hazards) |

> [!IMPORTANT] "What reduces data hazards": forwarding, bypassing, OoO, compiler scheduling. NOT "deeper pipeline" (worsens), NOT "branch prediction" (control).

## 9. Memory-Scheduling Restrictions

> Compiler **cannot**:
> - move loads/stores past each other if addresses may alias,
> - speculate loads that may trap (page fault, DTLB miss),
> - reorder volatile/atomic ops,
> - move past procedure calls / `setjmp` / exception barriers.

## 10. RAW vs WAR/WAW in Schedule

- RAW preds release **after producer's latency elapsed** (consumer issues then).
- WAR/WAW preds release **on issue** of predecessor (order-only).
