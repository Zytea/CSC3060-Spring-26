# Lec 4.5: Code (Instruction) Scheduling

## Exam Facts

- ==**Code scheduling**==: reorder independent instrs to fill pipeline bubbles **without changing program meaning**.
  - ==**Legal schedule**== = any **topological sort** of dependence DAG (every node before successors).
  - ==**DAG**==: node = instr; edge = required order; weight = latency (RAW) / 0 (WAR, WAW order-only).
  - ==**Schedule count**==: 50 dependent chain → **1**; 50 independent → **50!** → use heuristics.

- ==**Three reg dependences**==:
  - **RAW** = TRUE dep (real); weight = producer latency; **cannot remove**.
  - **WAR/WAW** = name/order; weight = 0; **removable by renaming**.
  - **RAR** ❌ not a hazard.

- ==**Memory scheduling**==:
  - **Cannot reorder** load/store unless **non-aliasing proven** (distinct stack offsets, `restrict`, non-overlap arrays, no `volatile`/IO/call/trap).
  - Limits: **memory aliasing**, **unknown mem latency**, scope (branches/calls/traps/volatile).

- ==**Critical path**==: longest weighted path; schedule its nodes **early**.
  - $MD(n) = \max_{n \to c}(\text{weight}(n,c) + MD(c))$; leaf = own latency or 0.

- ==**List scheduling heuristics**== (in order):
  1. avoid **stall now**;
  2. larger MD (protect critical path);
  3. original order;
  4. more children;
  5. final use of a reg (reduce live range).

- ==**Bubble counts**==: ALU→ALU fwd: **0**; load→use fwd: **1**; no-fwd: **2-3**; branch in EX: **2**; branch in MEM: **3**.

- ==**HW vs SW split**==:
  - **HW**: forwarding/interlock/OoO/branch-pred/split-cache/more-ports.
  - **SW**: scheduling, branch layout, `restrict`, local copies, code repositioning.
  - **Deeper pipeline ❌** is NOT a mitigation; worsens data + control penalties.

- ==**MIPS history**==: "no Interlocked Pipeline Stages" → compiler-only NOPs. Failed: **compatibility & scalability**.

## 1. Why Rearrange?

==**Goal**==: reduce bubbles + expose **ILP**, without changing observable behavior.

```asm
# Before — 1 load-use bubble:
lw  t0, 0(a0)
add t1, t0, t2

# After — bubble filled with independent op:
lw  t0, 0(a0)
addi s0, s0, 1
add  t1, t0, t2
```

## 2. Dependence Detection

| Edge        | Add when                       | Latency / weight       |
| ----------- | ------------------------------ | ---------------------- |
| **RAW**     | prev writer → current reader   | producer latency       |
| WAR         | prev reader → current writer   | 0 (order-only)         |
| WAW         | prev writer → current writer   | 0 (order-only)         |

> Skip `x0` as destination (no real dep).

```asm
# RAW (TRUE): cannot remove
lw   p1, a;    add p3, p1, p2    # add needs lw's value

# WAR / WAW: removable by renaming
sw  p6, 0(p5);  lw p6, c          # WAR: rename p6
lw p1, a;      lw p1, c            # WAW: rename p1
```

## 3. Memory Aliasing

```asm
sw x5, 0(x1)
lw x6, 0(x2)    # ❌ cannot move before store if x1 may == x2
sw x6, 0(x2)    # ❌ cannot swap stores if x1 may == x2
```

==**Safe evidence**==: distinct stack offsets, `restrict`, proven non-overlapping arrays, no `volatile`/IO/call/trap.

> Unknown aliasing → DAG must include conservative **memory-order edges** (load–store, store–store).

## 4. Operation Latency (Arc Weights)

| Op          | int ALU | **load (hit)** | int mul | FADD | FMUL | FMA   | **int div** |
| ----------- | ------- | -------------- | ------- | ---- | ---- | ----- | ----------- |
| **Latency** | 1       | **2-3**        | 3-5     | 3-4  | 4-5  | 5-6   | **~32**     |

> Hardest to pipeline: **integer divide**.

## 5. Critical Path & MD

$$
MD(n) = \begin{cases}
0 \text{ or } latency(n), & \text{no successors} \\
\max_{n \to c}(\text{weight}(n, c) + MD(c)), & \text{otherwise}
\end{cases}
$$

> Convention: if node latency in edge weight, leaf MD = 0; if MD includes own latency, leaf MD = latency.

```cpp
int CP(int n) {                       // reverse topo, O(N+E)
    if (visited[n]) return MD[n];
    visited[n] = true;
    int lat = inst[n].latency;
    if (succ[n].empty()) return MD[n] = lat;
    int maxRAW = 0, maxOrder = 0;
    for (auto& e : succ[n]) {
        int s = CP(e.target);
        if (e.type == RAW) maxRAW = max(maxRAW, s);
        else                maxOrder = max(maxOrder, s);
    }
    return MD[n] = max(lat + maxRAW, maxOrder);
}
```

## 6. List Scheduling

```text
1. Build DAG.
2. Compute MD per node.
3. Ready list = preds scheduled AND latency satisfied.
4. Each cycle, pick best ready by heuristics.
5. Issue; update ready list.
```

==**Tie-break order**==: (1) no stall now, (2) larger MD, (3) original order, (4) more children, (5) final reg use.

> Trap: if a ready arith op would stall (waiting load/mul), pick **another independent ready op** — fill bubble.

==**Worked DAG step**== (loads=2 cy, mul=3 cy, add=1 cy):

| Step | Ready list  | Pick                   | Reason                                                        |
| ---- | ----------- | ---------------------- | ------------------------------------------------------------- |
| 1    | {1, 2, 9}   | **1** (`lw $pr1, a`)   | tied MD=7, original order first                               |
| 2    | {2, 9}      | **2** (`lw $pr2, b`)   | MD=7, no stall                                                |
| 3    | {3, 5, 9}   | **9** (`lw $pr7, d`)   | 3 & 5 await 1 & 2 (2-cy load); pick 9 to fill                 |
| 4    | {3, 5}      | **3** (`add $pr3`)     | 1's result ready; MD(3)=5 > MD(5)=3                           |
| 5    | {4, 5}      | **4** (`mul $pr4`)     | MD(4)=4 > MD(5)=3                                             |
| 6    | {6, 10, 5}  | **5**                  | 6 waits 3 cy for mul; pick 5                                  |
| 7    | {6, 10, 8}  | **8**                  | 6, 10 wait; fill with 8                                       |

## 7. HW vs SW Hazard Mitigation

| Technique                       | Who                  | Hazard            |
| ------------------------------- | -------------------- | ----------------- |
| forwarding / bypassing          | **HW**               | data RAW          |
| interlock / stall               | HW                   | data / structural |
| split I/D cache, more ports     | HW                   | structural        |
| BHT / BTB / RAS                 | HW                   | control           |
| **OoO**                         | HW                   | data / resource   |
| **register renaming**           | HW                   | WAR / WAW         |
| **instruction scheduling**      | **compiler**         | data / structural |
| branch layout / static predict  | compiler             | control           |
| **`restrict`, local copies**    | programmer/compiler  | aliasing          |

> **Deeper pipeline ❌** — worsens data + control penalties.

## 8. RAW vs WAR/WAW Release Timing

| Edge          | Successor ready when                                            |
| ------------- | --------------------------------------------------------------- |
| **RAW**       | producer's latency satisfied (result available)                 |
| WAR / WAW     | order-only — successor ready as soon as pred **issued**         |

> ==WAR/WAW edges don't create bubbles== (order constraints only). Only RAW with latency creates real wait.

## 9. Quiz 2 Reordering Example

Original (load-use heavy) — see [4_4_review.md §2.1](4_4_review.md).

==**Reorder reducing bubbles**== (fill load-use gaps with independent loads):

```text
1.  LW S1, 8(S0)
2.  LW S2, 16(S0)
8.  LW S3, 24(S7)         # moved up; fills load-use before instr 3
9.  LW S8, 8(S7)          # renamed S1→S8 (S1 needed at instr 11)
3.  SUB T4, S2, S1
10. LW S5, 32(S0)
11. ADD T7, S3, S8        # uses renamed S8
4.  AND T5, T4, T3
5.  SUB S4, T4, T3
12. LW S6, 64(S0)
6.  ADD T6, S4, T4
7.  SW T6, 4(S7)
```

> [!IMPORTANT]
> ❌ Cannot move loads 10/12 before instr 7's store unless `S0+32`, `S0+64`, `S7+4` proven non-aliasing.
> ✅ Renaming `S1 → S8` allowed: new `S1` from instr 9 would clobber the original used at instr 3.
