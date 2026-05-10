# Lec 4.5: Code / Instruction Scheduling

## Exam Facts

- Code scheduling rearranges independent instrs to fill pipeline bubbles while preserving program meaning.
- Legal schedule = any topological order of dependence DAG.
- Three register dependences: **RAW, WAR, WAW**.
- RAW is true dependence and carries producer latency. WAR/WAW are order/name dependences.
- Memory scheduling is conservative because aliasing and latency are often unknown.
- Cannot move a load before an earlier store or swap stores unless addresses are proven independent.
- Arc weight = operation latency. Critical path = longest weighted path through DAG.
- Maximum delay:

$$
MD(node)=\max_{child}(MD(child)+arc\_weight)
$$

- List scheduling: maintain ready list; issue best ready instr by no-stall, max MD, original order/children/final-use tie-breaks.
- Quiz limitations answer: **memory aliasing** and **unknown memory latency**.
- HW mitigates hazards with forwarding/interlocks/OoO/prediction; compiler mitigates with scheduling/reordering.

## 1. Why Rearrange Code Sequence?

Pipeline stalls occur when a consumer is issued before producer result is ready. If there is independent work, the compiler can move it into the waiting slots.

Goal: reduce bubbles without changing observable behavior.

## 2. Dependence DAG

==**Dependence DAG**==: node = instruction/operation; edge = scheduling constraint; edge weight = latency/order delay.

Any schedule must place every predecessor before its successor. A legal schedule is a topological sort. Best schedule minimizes stalls/total cycles.

Exhaustive search is infeasible: possible orders grow like `N!`, so compilers use heuristics.

## 3. Three Register Data Dependences

### 3.1 RAW: Read After Write / Flow Dependence

`B` reads a register written by older `A`.

```asm
lw  p1,a
add p3,p1,p2
```

`lw` must produce `p1` before `add` consumes it. RAW is a true dependence and usually carries operation latency.

### 3.2 WAR: Write After Read / Anti-Dependence

`B` writes a register that older `A` reads.

```asm
sw p6,0(p5)    # reads p6 and p5
lw p6,c        # writes p6
```

`sw` must read old `p6` before later `lw` overwrites it. WAR is a name/order dependence, not value production.

### 3.3 WAW: Write After Write / Output Dependence

Two instrs write the same register; final value must come from later program-order writer.

```asm
lw p1,a
...
lw p1,c
```

WAW preserves final register value.

### 3.4 Dependence Detection Summary

| Dependence | Add edge when | Typical latency |
|---|---|---|
| RAW | last writer of source reg -> current reader | producer operation latency |
| WAR | previous reader of dest reg -> current writer | 0/order-only in simple list scheduling |
| WAW | last writer of dest reg -> current writer | 0 or 1/order-only |

Implementation idea:

- track last writer per register for RAW/WAW.
- track readers since last write for WAR.
- ignore `x0` as a real destination.

## 4. Memory Dependence / Aliasing

Scheduling memory instrs is harder than registers because addresses may be unknown at compile time.

Conservative rules:

- do not move a load before an earlier store if addresses may alias.
- do not swap two stores if addresses may alias.
- be careful moving memory ops around calls, volatile, I/O, or possible traps.

Reasons:

- pointer aliasing.
- array index unknown.
- cache hit/miss latency unknown.
- memory system resources shared: cache, DRAM, bus, interconnect.
- speculative load/store may trap.

> A `restrict` pointer or proven non-overlap can remove alias edges and expose scheduling freedom.

## 5. Operation Latency and Arc Weights

| Operation | Latency idea |
|---|---:|
| integer add / ALU | 1 |
| load | 2 |
| multiply | 3 |
| FADD | 3-4 |
| FMUL | 4-5 |
| FMA | 5-6 |
| integer divide | about 32 |

Arc weight is the delay from producer issue/result to consumer readiness.

## 6. Critical Path and Maximum Delay

Nodes on critical paths should be scheduled as early as possible.

Compute MD by reverse topological traversal:

$$
MD(n)=
\begin{cases}
latency(n), & n\ has\ no\ successors \\
\max_{e:n\to c}(MD(c)+weight(e)), & otherwise
\end{cases}
$$

Some schedulers treat WAR/WAW edges as order-only with no result latency, and RAW edges as latency-carrying.

## 7. List Scheduling Algorithm

Basic block list scheduling:

1. Build dependence DAG.
2. Compute MD/priority for each node.
3. Initialize ready list with nodes whose predecessors are scheduled/satisfied.
4. At each cycle, pick one ready instr.
5. Mark issued instr; release WAR/WAW successors immediately if order is satisfied.
6. Release RAW successors only when producer latency is satisfied.
7. Continue until all nodes scheduled.

Tie-break heuristics:

| Priority | Reason |
|---|---|
| can issue without stalling | avoid bubble |
| larger MD | protect critical path |
| original order | preserve locality/simple code |
| more children | unlock more future ready nodes |
| final use of register | shorten live ranges |
| longer processing time | LPT heuristic for some machines |

## 8. Worked Scheduling Pattern

Example ready sets from lecture:

| Step | Candidate list | Choose | Reason |
|---|---|---|---|
| 1 | `{1,2,9}` | `1` | highest MD and original order |
| 2 | `{2,9}` | `2` | high MD, no stall |
| 3 | `{3,5,9}` | `9` | `3/5` wait for load results; `9` fills slot |
| 4 | `{3,5}` | `3` | result ready, larger MD |
| 5 | `{4,5}` | `4` | larger MD |
| 6 | `{6,10,5}` | `5` | `6` waits for multiply; choose independent work |
| 7 | `{6,10,8}` | `8` | fill multiply latency |

Key idea: do not blindly choose first ready child if it would stall waiting for a latency edge.

## 9. Schedule Counts and Quiz Patterns

For a 5-stage pipeline:

| Situation | Typical bubble count |
|---|---:|
| RAW ALU producer -> immediate consumer, no forwarding | up to 2-3 depending regfile timing |
| load -> immediate use, with forwarding | 1 |
| ALU producer -> consumer, with forwarding | 0 |
| branch resolved in EX after wrong fetch | about 2 |
| branch resolved in MEM after wrong fetch | about 3 |

Quiz 2 scheduling/hazard pattern:

- Without forwarding, a chain may generate many bubbles, e.g., total 9 in the given schedule.
- With forwarding, ALU-ALU RAWs use EX/MEM or MEM/WB forwarding.
- Load-use still needs one bubble unless independent instr is scheduled between.

## 10. Hardware vs Software Hazard Mitigation

| Technique | Hazard | Who |
|---|---|---|
| forwarding/bypassing | data RAW | hardware |
| interlock/stall | data/structural | hardware |
| split I/D cache, more ports | structural | hardware |
| BHT/BTB/RAS | control | hardware |
| OoO execution | data/resource | hardware |
| compiler scheduling | data/structural | software |
| branch layout/static prediction | control | compiler/software |
| `restrict`, local scalar copies | memory aliasing | programmer/compiler |
| deeper pipeline | not a fix | often worsens data/control penalties |

## 11. Memory-Scheduling Restrictions

Do not reorder these unless proven safe:

```asm
sw x5,0(x1)
lw x6,0(x2)    # cannot move before store if x1 may equal x2
```

```asm
sw x5,0(x1)
sw x6,0(x2)    # cannot swap if x1 may equal x2
```

Safe reorder examples:

- different proven stack offsets.
- independent scalar regs.
- `restrict` pointers.
- compiler can prove arrays do not overlap.

## 12. RAW vs WAR/WAW Release Timing

In simple list scheduling:

- RAW successor becomes ready only after producer latency completes.
- WAR/WAW successor can become ready when predecessor is issued/read/order preserved, because no produced value must be waited for.

> This distinction explains why the scheduler may release order-only edges earlier than true value edges.
