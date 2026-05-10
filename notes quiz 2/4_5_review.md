# Lec 4.5: Code (Instruction) Scheduling

## Exam Facts

- ==**Code scheduling**==: reorder instructions to reduce stalls while preserving dependencies.
- ==**True dependence = RAW**==.
- A legal schedule is a **topological order** of the dependence DAG.
- For N instrs: best case **1** legal schedule (chain); worst case **N!** (no deps). Not quadratic.
- Critical path = longest weighted path; schedule critical-path nodes early.
- Compiler scheduling limits: **unknown memory aliasing** and **unknown/non-deterministic memory latency**.
- Hardware data-hazard fixes: forwarding/bypassing, OoO. Software fix: compiler scheduling.
- Cannot move memory ops across each other if addresses may alias.

## 1. Why Reschedule

Pipeline stalls appear when a consumer is issued before producer result is ready. If independent instrs exist, move them into the waiting slots.

Goal: **same program result, fewer bubbles**.

## 2. Three Register Data Dependences

| Dep | Full name | Meaning | Scheduling constraint |
|---|---|---|---|
| ==**RAW**== | Read After Write | B reads A's result | A before B; latency matters |
| **WAR** | Write After Read | B overwrites a reg A reads | A before B; order-only in simple schedule |
| **WAW** | Write After Write | A and B write same reg | preserve final writer order |
| RAR | Read After Read | both read | no dependence |

> In simple in-order 5-stage, RAW causes stalls. WAR/WAW still matter to a compiler that reorders code or to OoO implementations.

## 3. Memory Dependence (Aliasing)

Memory scheduling is conservative because addresses may be unknown at compile time.

Compiler usually cannot:

- move a load before an earlier store if addresses may alias.
- swap two stores if addresses may alias.
- move volatile/atomic accesses.
- speculate a load that may trap.
- freely cross calls/exception barriers.

Fixes:

- `restrict` pointers.
- copy `*p`/`*q` into local scalars when safe.
- better layout so addresses are provably independent.

## 4. Dependence DAG

- Node = instruction.
- Edge `A -> B` = B cannot be scheduled before A.
- Edge weight = result latency / required gap.
- Legal schedule = any topological order respecting every edge.

> Quiz "valid schedules": check each candidate sequence by ensuring every predecessor appears before its child.

## 5. Operation Latency and Critical Path

| Operation | Typical latency |
|---|---:|
| ALU add/sub/logic | 1 |
| Load hit | 2 |
| Multiply | 3 |
| Divide | ~32 |
| FADD | 4 |
| FMUL | 5 |
| FMA | 5-6 |

### 5.1 Maximum Delay (MD)

For node priority, compute backward from leaves:

$$
MD(n)=\max_{s\in succ(n)}(w(n,s)+MD(s))
$$

If including node latency instead of edge weight, use one convention consistently. High MD = on/near critical path.

## 6. List Scheduling Algorithm

1. Build dependence DAG.
2. Compute MD/priority.
3. Ready set = unscheduled nodes with all predecessors satisfied.
4. Each cycle choose one ready node.
5. Prefer a node that does not stall; then larger MD; then original order / more children / final register use.
6. Update ready set and continue.

### 6.1 Worked Pattern

If ready set is `{1,2,9}` and 1/2 are loads feeding 3/5, issue independent `9` while waiting for load results.

This is the key exam pattern:

```text
load A
load B
independent work       # fills load-use gap
use A/B
```

## 7. Schedule Counts

| Dependence graph | Number of legal schedules |
|---|---:|
| single chain of N nodes | 1 |
| no edges among N nodes | N! |

Exhaustive search is impossible for large blocks; heuristics are normal.

## 8. HW vs SW Hazard Mitigation

| Technique | Hazard | HW/SW |
|---|---|---|
| forwarding / bypassing | data | HW |
| OoO execution | data/control tolerance | HW |
| compiler scheduling | data | SW |
| BTB/BHT/static prediction | control | HW/rule |
| deeper pipeline | not a fix | often worsens data/control penalties |

## 9. Memory-Scheduling Restrictions

If original code has:

```c
*a = ...
x = *b
```

and compiler cannot prove `a != b`, it cannot move `x=*b` before `*a=...`.

If original code has independent arrays/pointers marked `restrict`, compiler can schedule/vectorize more aggressively.

## 10. RAW vs WAR/WAW Release Timing

- RAW: successor becomes ready only after producer latency is satisfied.
- WAR/WAW: successor may become ready after predecessor is issued/read/write order preserved; no result latency gap needed in simple scheduling.

> [!IMPORTANT]
> Quiz limitations answer: **memory aliasing** and **unknown memory latency**. Do not choose "structural hazards are hard" or "scheduling is error-prone" unless a different question explicitly asks that.
