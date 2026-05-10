# Lec 4.5: Code (Instruction) Scheduling

## Exam Facts

- ==**Code scheduling**==: reorder instructions to **reduce stalls** while preserving dependencies (semantic equivalence).
- ==**True dependence = RAW**== (Read-After-Write).
- ==Legal schedule = any **topological order** of dependence DAG==.
- ==Critical path = longest weighted path== through DAG (weights = operation latencies).
- "Schedule critical-path nodes **early**".
- Compiler scheduling is limited by **memory aliasing** + **unknown / non-deterministic memory latency**. (NOT by structural hazards or "error-prone".)
- HW data-hazard reduction: **forwarding/bypassing + OoO**. SW: **compiler scheduling**.
- For N instructions: **best case = 1 schedule** (if all deps form a chain); **worst case = N!** schedules; never quadratic.
- Static analysis cannot move loads past stores if their addresses **may alias** — must use `restrict` or local copies.

## 1. Why Reschedule

A naive instruction order can leave the pipeline stalled at every dependency. Reordering **independent instructions** into the bubble slots reduces total cycle count.

## 2. Three Register Data Dependences

| Type | Meaning | Constraint |
|---|---|---|
| ==**RAW**== | Read After Write (true / flow) | producer must finish before consumer reads |
| ==**WAR**== | Write After Read (anti) | early reader must read before later writer overwrites |
| ==**WAW**== | Write After Write (output) | last writer's result must be the one in the register at end |
| RAR | Read After Read | **NO** dependence — can reorder freely |

> [!IMPORTANT]
> - RAW edge weight = **operation latency** (ALU 1, Load 2, Mul 3, FMA 5–6, …).
> - WAR/WAW are **order-only** (weight ≈ 0–1) — they enforce ordering but don't add latency. Important for OoO/register renaming.
> - In simple in-order 5-stage, WAR/WAW don't cause stalls; they constrain the *compiler's* schedule.

## 3. Memory Dependence (alias problem)

Memory ops are conservative: the compiler must assume two pointers **may alias** unless proven otherwise.

⇒ Cannot freely:
- move a load **before** an earlier store,
- swap two stores,
- vectorize loops with possibly-aliasing pointers.

**Fixes**:
- `restrict` keyword.
- Copy pointer-pointed values into **local scalars** before the loop, work on locals, write back after.
- Better data layout / API design.

> Volatile vars (OS kernels, I/O) **forbid** any reordering.

## 4. Dependence DAG

- **Node** = one instruction.
- **Edge A→B** = B depends on A (must be scheduled later).
- **Edge weight** = operation latency (cycles A's result must wait before B can use it).
- Legal schedule = any topological order respecting all edges.

## 5. Operation Latency / Critical Path

| Op | Latency (typical) |
|---|---|
| ALU `add/sub/and/or` | 1 |
| Load (cache hit) | 2 |
| Multiply | 3 |
| Divide | ~32 |
| FADD | 4 |
| FMUL | 5 |
| FMA | 5–6 |

==**Critical Path = longest weighted path** from any node to a leaf==. Set the schedule to attack the critical path first.

### Computing node priority (Maximum Delay, MD)

Reverse-topological:

$$\text{MD}(n) = \text{latency}(n) + \max_{m \in \text{successors}(n)} \text{MD}(m)$$

(Use 0 for WAR/WAW edges' latency; latency for RAW.)

## 6. List Scheduling Algorithm

```
1. Build dependence DAG.
2. Compute MD (priority) for each node.
3. Maintain ready set = nodes with no unscheduled predecessors.
4. Each cycle:
   a. From ready set, pick best by heuristic (priority/critical-path/tie-break).
   b. Issue it; track in-flight.
   c. Update successors' counters; release when satisfied.
5. Repeat until all scheduled.
```

### Common heuristics for picking from ready

1. Favor nodes that can **issue without stalling** (their RAW preds finished).
2. Tie: largest **MD** (critical path).
3. Tie: original program order.
4. Tie: largest number of children (frees more nodes).
5. Tie: final use of a register.

## 7. Worked Example Pattern

| Step | Ready | Pick | Reason |
|---|---|---|---|
| 1 | {1, 2, 9} | 1 | largest MD |
| 2 | {2, 9} | 2 | largest MD, no stall |
| 3 | {3, 5, 9} | **9** | 3 and 5 would stall waiting on load latency; 9 fills gap |
| 4 | {3, 5} | 3 | larger MD |
| ... | | | ... |

> Pattern: **fill load-latency gaps with independent instructions**.

## 8. Schedule Counts

For N instructions:
- **Best case** (full chain of deps): exactly **1** legal schedule.
- **Worst case** (no deps at all): **N!** legal schedules.

⇒ Exhaustive search infeasible; use heuristics like list scheduling.

## 9. HW vs SW Hazard Mitigation

| Solution | Where |
|---|---|
| Forwarding / Bypassing | HW |
| Out-of-Order execution | HW |
| Compiler instruction scheduling | SW |
| Stalls / interlocks | HW (defaults if scheduling fails) |
| Branch prediction | HW (separate, control hazards) |

> [!IMPORTANT] Quiz answer for "what reduces data hazards": **forwarding (A), bypassing (C), OoO, compiler scheduling**. NOT "deeper pipeline" (worsens), NOT "branch prediction" (control hazard).

## 10. Memory Scheduling Restrictions

> [!IMPORTANT] Compiler **cannot**:
> - move loads/stores past each other if addresses may alias,
> - speculate loads that may trap (page fault, DTLB miss),
> - reorder volatile or atomic ops,
> - move past procedure calls / `setjmp`/exception barriers.

**Quiz answer for "compiler scheduling limitations":**
- **B) Memory aliasing** (addresses unknown).
- **D) Memory latency unknown / non-deterministic** (cache miss).

NOT "code scheduling is error-prone" (it's algorithmic) and NOT "structural hazards are hard" (those are HW issues).

## 11. RAW vs WAR/WAW in Schedule

In list scheduler:
- RAW preds release **after producer's latency elapsed** (consumer can issue then).
- WAR/WAW preds release **on issue** of the predecessor (order-only).

This matches the user code:
```cpp
if (edge.type == DependencyType::RAW)
    release after producer.finish_cycle
else  // WAR/WAW
    release at producer.issue_cycle
```
