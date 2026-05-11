# Lec 4.5: Code (Instruction) Scheduling

## Exam Facts

- ==**Code scheduling**==: reorder independent instrs to fill pipeline bubbles **without changing program meaning**.
- ==**Legal schedule**== = any **topological sort** of the dependence DAG (every node before its successors).
- ==**Dependence DAG**==: node = instr; edge = required order; weight = latency / order delay.
- **Three reg dependences**: ==**RAW, WAR, WAW**==. **RAW = TRUE dependence** (real); WAR/WAW = name/order, removable by **register renaming**.
- **RAR is NOT a hazard**.
- ==**Memory scheduling limits**==: **aliasing unknown** + **memory latency unknown**.
- **Cannot reorder** load/store unless addresses **proven non-aliasing**.
- **Worst-case schedule count**: chain of N dependent instrs → 1 schedule; N independent instrs → N! schedules → exhaustive search infeasible → use heuristics.
- ==**MIPS** ("Microprocessor without Interlocked Pipeline Stages")== relied on compiler-only scheduling. **Failed due to compatibility & scalability**.
- ==**Critical path**==: longest weighted path in DAG. Schedule critical-path nodes **early**.
- **Maximum Delay**: $MD(n) = \max_{n \to c}(weight(n,c) + MD(c))$; leaf = own latency or 0.
- **List scheduling heuristics** (in order):
  1. avoid stall **now**.
  2. larger MD (protect critical path).
  3. original order.
  4. more children.
  5. final use of a reg.
- ==**Compiler limits**==: **memory aliasing**, unknown mem latency, scope shrunk by branches/calls/traps/volatile.
- ==**HW vs SW hazard mitigation split**==:
  - **HW**: forwarding/interlock/OoO/branch-prediction/split-cache/more-ports.
  - **SW**: instruction scheduling, branch layout, `restrict`, local copies, code repositioning.
- ==**Bubble counts**==:
  - ALU→ALU with forwarding: **0**
  - load→use with forwarding: **1**
  - producer→close consumer no forwarding: **2-3**
  - branch resolved in EX: **2**
  - branch resolved in MEM: **3**
- **Reordering across unknown stores**: **NOT allowed** unless aliasing proven safe (e.g., distinct stack offsets, `restrict`, non-overlapping arrays).
- **Deeper pipeline**: NOT a hazard mitigation; **worsens** data + control penalties.
- **WAR/WAW release timing**: weight 0 (order-only); RAW: weight = producer latency (must wait).

## 1. Why Rearrange Code Sequence?

==**Goal**==: reduce pipeline bubbles + expose **ILP**, without changing observable behavior.

==**Load-use stall, no fix**==:

```asm
lw  t0, 0(a0)
add t1, t0, t2     # 1-cycle bubble (load-use)
```

==**With independent work moved between**==:

```asm
lw  t0, 0(a0)
addi s0, s0, 1     # fills the bubble
add  t1, t0, t2
```

## 2. Dependence DAG

==**Node**== = instruction.
==**Edge**== `A → B` = `B` requires `A`'s result or order.
==**Weight**== = latency (RAW) or 0 (WAR/WAW order-only).

==**Any legal schedule**== = topological sort of the DAG: every predecessor scheduled before successor.

==**Schedule count**==:

| Pattern | # legal schedules |
|---|---:|
| chain of 50 dependent | **1** |
| 50 independent | **50!** (huge) |
| typical mix | use heuristics |

> Quiz 3 #27: a basic block with 50 instrs → best case 1 schedule (full chain), worst case 50! → use heuristics, not exhaustive search.

==**MIPS history**==: "Microprocessor without Interlocked Pipeline Stages" — relied on **compiler-only** hazard avoidance (NOPs inserted if needed). Failed due to **compatibility & scalability** (Quiz 3 #11). Modern CPUs all have HW interlocks.

## 3. Three Register Data Dependences

### 3.1 RAW: Read After Write (TRUE dependence)

```asm
lw   p1, a            # write p1
add  p3, p1, p2       # read p1 ← TRUE dep
```

`add` needs `lw`'s value. **Cannot remove**; weight = producer latency.

### 3.2 WAR: Write After Read (anti-dep)

```asm
sw  p6, 0(p5)         # read p6
lw  p6, c             # write p6 ← must wait for read
```

==**Order/name dependence**==: later write must not occur before earlier read. **Removable by renaming** (rename one of the `p6`s).

### 3.3 WAW: Write After Write (output-dep)

```asm
lw p1, a              # write p1
...                   # (something using p1 at end? no)
lw p1, c              # final write to p1
```

Later write defines final reg state. **Removable by renaming**.

### 3.4 Detection Summary

| Edge | Add when | Latency / weight |
|---|---|---|
| **RAW** | prev writer → current reader | producer latency |
| WAR | prev reader → current writer | 0 (order-only) |
| WAW | prev writer → current writer | 0 (order-only) |

> Skip `x0` as destination (always 0; no real dep).

> ==Renaming removes WAR + WAW; **RAW can NOT be removed** without changing the computation==.

## 4. Memory Dependence / Aliasing

==**Cannot reorder**== unless safety proven:

```asm
sw x5, 0(x1)
lw x6, 0(x2)    # cannot move BEFORE store if x1 may equal x2
```

```asm
sw x5, 0(x1)
sw x6, 0(x2)    # cannot swap if x1 may equal x2
```

==**Safe evidence**==:

- distinct stack offsets (`-4(fp)` vs `-8(fp)`).
- ==**`restrict`**== keyword.
- proven non-overlapping arrays.
- no `volatile` / I/O / call / trap concerns.

> When aliasing is unknown, the DAG must include **conservative memory-order edges** (load–store, store–store).

==**Compiler scheduling difficulty**==:

| Limit | Why |
|---|---|
| memory aliasing | pointer/index values often unknown at compile time |
| memory latency | depends on cache hit/miss |
| speculative load/store may trap | page fault, alignment |
| shared resources | DRAM bus, interconnect |
| `volatile` (kernel) | order must be preserved |

## 5. Operation Latency = Arc Weights

| Operation | Latency |
|---|---:|
| int ALU | 1 |
| **load (hit)** | **2-3** |
| int multiply | 3-5 |
| FADD | 3-4 |
| FMUL | 4-5 |
| FMA / FMAC | 5-6 |
| **int divide** | **~32** |

> Hardest to pipeline: **integer divide** (Quiz 3 #7).

## 6. Critical Path & Maximum Delay

==**Critical path**== = longest weighted path; schedule its nodes early.

==**Compute MD via reverse topological sort**==:

$$
MD(n) = \begin{cases}
0 \text{ or } latency(n), & n\ has\ no\ successors \\
\max_{n \to c}(weight(n, c) + MD(c)), & otherwise
\end{cases}
$$

> Be consistent: if node latency is in the edge, leaf MD = 0; if MD includes own latency, leaf MD = latency.

```cpp
// Reverse topological computation, O(N + E)
int CP(int n) {
    if (visited[n]) return MD[n];
    visited[n] = true;
    int latency = inst[n].latency;
    if (succ[n].empty()) return MD[n] = latency;
    int maxRAW = 0, maxOrder = 0;
    for (auto& e : succ[n]) {
        int s = CP(e.target);
        if (e.type == RAW) maxRAW = max(maxRAW, s);
        else                maxOrder = max(maxOrder, s);
    }
    return MD[n] = max(latency + maxRAW, maxOrder);
}
```

## 7. List Scheduling Algorithm

```text
1. Build dependence DAG.
2. Compute MD (priority) per node.
3. Ready list = nodes whose preds are scheduled AND latency satisfied.
4. Each cycle, pick best ready node by heuristics.
5. Issue it; update ready list (release succs whose order/latency satisfied).
```

==**Tie-break heuristics**== (apply in order):

1. ==**no stall now**== → avoid bubble.
2. ==**larger MD**== → protect critical path.
3. **original order** → simple, predictable.
4. **more children** → unlock work.
5. **final use of a reg** → reduce live range.

> Trap: if a ready arithmetic op would stall (waiting for load/mul to finish), pick another **independent ready** op instead — fill the bubble.

## 8. Worked Scheduling Pattern

==**Class 11-instr DAG example**== (loads have 2-cycle latency; mul = 3 cycles; add = 1 cycle):

| Step | Ready list | Pick | Reason |
|---|---|---|---|
| 1 | {1, 2, 9} | **1** (`lw $pr1, a`) | tied MD=7, original order first |
| 2 | {2, 9} | **2** (`lw $pr2, b`) | MD=7, no stall |
| 3 | {3, 5, 9} | **9** (`lw $pr7, d`) | 3 & 5 depend on 1 & 2 (2-cycle load latency); pick 9 to fill |
| 4 | {3, 5} | **3** (`add $pr3,...`) | now 1's result ready; MD(3)=5 > MD(5)=3 |
| 5 | {4, 5} | **4** (`mul $pr4,...`) | MD(4)=4 > MD(5)=3 |
| 6 | {6, 10, 5} | **5** | 4 just issued, 6 waits 3 cycles for mul; pick 5 |
| 7 | {6, 10, 8} | **8** | 6, 10 wait; fill with 8 |

> Rule: **don't let critical path stall** — if its node would stall, fill with side work first.

## 9. Schedule Counts and Quiz Patterns

| Pattern | Bubbles |
|---|---:|
| ALU → ALU with forwarding | 0 |
| **load → use with forwarding** | **1** |
| no forwarding, producer → close consumer | 2-3 |
| branch resolved EX | 2 |
| branch resolved MEM | 3 |

## 10. Hardware vs Software Hazard Mitigation

| Technique | Who | Hazard |
|---|---|---|
| forwarding / bypassing | **HW** | data RAW |
| interlock / stall | HW | data / structural |
| split I/D cache, more ports | HW | structural |
| BHT / BTB / RAS | HW | control |
| **OoO (out-of-order)** | HW | data / resource |
| **register renaming** | HW | WAR / WAW |
| **instruction scheduling** | **compiler** | data / structural |
| branch layout / static predict | compiler | control |
| **`restrict`, local copies** | programmer/compiler | aliasing |

> **Deeper pipeline is NOT a mitigation** — it makes data + control penalties worse.

## 11. Memory-Scheduling Restrictions

> Search trigger words: **alias, unknown latency, store-load, volatile, call**.

==**Exam rule of thumb**==:

```text
register RAW/WAR/WAW → build DAG, can be reordered subject to edges
memory ops → KEEP original order unless non-aliasing PROVEN
```

## 12. RAW vs WAR/WAW Release Timing

| Edge | Successor ready when |
|---|---|
| **RAW** | producer's latency satisfied (i.e., result available) |
| WAR / WAW | order-only — successor ready as soon as predecessor is **issued** |

> ==WAR / WAW edges do NOT necessarily create bubbles== (they're just order constraints). Only RAW with latency creates real wait.

## 13. Quiz 2 Reordering Example

Original (load-use heavy):

```text
1. LW S1, 8(S0)
2. LW S2, 16(S0)
3. SUB T4, S2, S1     ← stall on S2
4. AND T5, T4, T3     ← stall on T4
5. SUB S4, T4, T3
6. ADD T6, S4, T4     ← stall on S4
7. SW T6, 4(S7)
8. LW S3, 24(S7)
9. LW S1, 8(S7)
10. LW S5, 32(S0)
11. ADD T7, S3, S1    ← stall on S1
12. LW S6, 64(S0)
```

==**Reorder reducing bubbles**== (fill load-use gaps with independent loads):

```text
1. LW S1, 8(S0)
2. LW S2, 16(S0)
8. LW S3, 24(S7)         # ← moved up; fills load-use gap before instr 3
9. LW S8, 8(S7)          # ← renamed to avoid clobber of S1 needed at instr 11
3. SUB T4, S2, S1
10. LW S5, 32(S0)        # ← independent load
11. ADD T7, S3, S8       # ← uses renamed S8
4. AND T5, T4, T3
5. SUB S4, T4, T3
12. LW S6, 64(S0)
6. ADD T6, S4, T4
7. SW T6, 4(S7)
```

> [!IMPORTANT]
> **Cannot move loads 10/12 before instr 7's store** unless `S0+32`, `S0+64`, `S7+4` proven non-aliasing.
> Renaming `S1 → S8` for instr 9/11 is allowed because the new `S1` would clobber the original used at instr 3.
