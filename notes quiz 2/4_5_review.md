# Lec 4.5: Code / Instruction Scheduling

## Exam Facts

- ==**Code scheduling**==: reorder independent instrs to fill bubbles while preserving meaning.
- **Legal schedule**: topological order of dependence DAG.
- **Register dependences**: **RAW, WAR, WAW**; RAW is true dependence.
- **Memory scheduling limits**: aliasing and latency are often unknown.
- **Store/load ordering**: cannot move load before earlier store or swap stores unless addresses proven independent.
- **Arc weight**: latency/order delay. **Critical path** = longest weighted path.
- **List scheduling**: ready list + priority such as no-stall, max delay, original order, more children.
- **Compiler limits**: **memory aliasing** and **unknown memory latency**.
- **Mitigation split**: HW = forwarding/interlocks/OoO/prediction; compiler = scheduling/layout.

## 1. Why Rearrange Code Sequence?

Goal: reduce pipeline bubbles without changing observable behavior.

```asm
lw  t0,0(a0)
add t1,t0,t2     # load-use stall
```

If independent work exists:

```asm
lw  t0,0(a0)
addi s0,s0,1     # fills bubble
add t1,t0,t2
```

## 2. Dependence DAG

==**Dependence DAG**==: node = instr/op; edge = required order; weight = latency/order cost.

Any legal schedule must place every predecessor before successor.

Quiz option checklist:

| Check | Meaning |
|---|---|
| every DAG edge respected | predecessor appears before successor |
| memory alias edges preserved | do not move possible aliasing loads/stores across each other |
| stalls ignored for legality | a schedule can be legal but still have bubbles |

Worst-case legal schedules can be huge:

| Case | # schedules |
|---|---:|
| chain of 50 dependent instrs | 1 |
| all 50 independent | `50!` |

MIPS ("Microprocessor without Interlocked Pipeline Stages") relied on software scheduling; main failure reason: compatibility/scalability.

## 3. Three Register Data Dependences

### 3.1 RAW: Read After Write

```asm
lw  p1,a
add p3,p1,p2
```

`add` needs value produced by `lw`; carries producer latency.

### 3.2 WAR: Write After Read

```asm
sw p6,0(p5)   # reads old p6
lw p6,c       # writes p6
```

Order/name dependence: later write must not occur before earlier read.

### 3.3 WAW: Write After Write

```asm
lw p1,a
...
lw p1,c
```

Final value must come from later write.

### 3.4 Detection Summary

| Edge | Add when | Latency |
|---|---|---|
| RAW | previous writer -> current reader | real producer latency |
| WAR | previous reader -> current writer | order-only |
| WAW | previous writer -> current writer | order-only |

Ignore `x0` as destination.

WAR/WAW are name dependences. Register renaming can remove them; RAW cannot be removed without changing the computation.

## 4. Memory Dependence / Aliasing

Do not reorder unless proven safe:

```asm
sw x5,0(x1)
lw x6,0(x2)    # cannot move before store if x1 may equal x2
```

```asm
sw x5,0(x1)
sw x6,0(x2)    # cannot swap if x1 may equal x2
```

Safe evidence:

- distinct stack offsets.
- `restrict`.
- proven non-overlapping arrays.
- no volatile/I-O/call/trap issue.

When aliasing is unknown, the dependence DAG must include conservative memory-order edges.

## 5. Operation Latency and Arc Weights

| Operation | Latency idea |
|---|---:|
| int ALU | 1 |
| load hit | 2-3 |
| int multiply | 3-5 |
| FADD | 3-4 |
| FMUL | 4-5 |
| FMA | 5-6 |
| int divide | ~32 |

## 6. Critical Path and Maximum Delay

Schedule critical path early.

$$
MD(n)=
\begin{cases}
0,&n\ has\ no\ successors\\
\max_{n\to c}(weight(n,c)+MD(c)),&otherwise
\end{cases}
$$

Some notes include node latency inside edge weight; be consistent with the given graph.

## 7. List Scheduling Algorithm

1. Build dependence DAG.
2. Compute max delay / priority.
3. Ready list = nodes whose predecessors are scheduled and latency satisfied.
4. Pick best ready node each cycle.
5. Update ready list.

Ready-list invariant: a node enters only after all predecessors are scheduled; RAW edges may also wait for producer latency.

Tie-breaks:

| Priority | Why |
|---|---|
| no stall now | avoid bubble |
| larger MD | protect critical path |
| original order | simple/predictable |
| more children | unlock work |
| final use of reg | reduce live range |

Candidate-list trap: if a ready arithmetic op would stall waiting for a load/mul, pick an independent ready op instead.

## 8. Worked Scheduling Pattern

Common idea: schedule independent loads/ALU ops between producer and consumer.

Do **not** move memory ops across unknown stores:

```text
instr 10/12 loads cannot move before instr 7 store if alias possible
```

Quiz 2 hazard schedule: any schedule reducing bubbles and respecting memory dependence earns; exact "free of hazards" may be impossible under alias constraints.

## 9. Schedule Counts and Quiz Patterns

| Pattern | Bubble count |
|---|---:|
| ALU -> ALU, forwarding | 0 |
| load -> use, forwarding | 1 |
| no forwarding, producer -> close consumer | up to 2-3 |
| branch resolved EX | about 2 |
| branch resolved MEM | about 3 |

## 10. Hardware vs Software Hazard Mitigation

| Technique | Who | Hazard |
|---|---|---|
| forwarding/bypassing | HW | data RAW |
| interlock/stall | HW | data/structural |
| split I/D cache, more ports | HW | structural |
| BHT/BTB/RAS | HW | control |
| OoO | HW | data/resource |
| instruction scheduling | compiler | data/structural |
| branch layout/static predict | compiler | control |
| `restrict`, local copies | programmer/compiler | aliasing |

Deeper pipeline is not a mitigation; it often worsens data/control penalties.

## 11. Memory-Scheduling Restrictions

Search trigger: **alias**, **unknown memory latency**, **store-load**, **volatile**, **call**.

When in doubt for exam:

```text
register RAW/WAR/WAW -> build DAG
memory ops -> keep original order unless non-alias proven
```

## 12. RAW vs WAR/WAW Release Timing

- RAW successor ready only after producer latency.
- WAR/WAW successor ready once required order/read/write name condition is satisfied.

This is why order-only edges do not necessarily create bubbles.
