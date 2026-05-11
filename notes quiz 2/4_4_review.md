# Lec 4.4: Pipeline Hazards

## Exam Facts

- ==**Three hazards**==: ==**Structural, Data, Control**==. "Forward hazard" is NOT one ❌ (it's the *fix*).
  - $CPI_{actual} = CPI_{ideal} + \text{StallCycles/Instr}$
  - $\text{AddedCPI}_{ctrl} = \text{BranchFreq} \times \text{MispredRate} \times \text{Penalty}$ (no-pred: replace `MispredRate` with `TakenRate`)
- ==**Structural**==: insufficient HW (unified I/D mem, non-pipelined divider, too few ports, early-WB conflict).
  - ==**Von Neumann bottleneck = structural hazard**== in pipelined data path.
  - ==**Why split I/D cache**==: avoid IF/MEM structural hazard + **higher bandwidth**. NOT for hit rate / reliability.
  - Moving R-type WB to stage 4 ❌ creates structural conflict with loads at stage 5; keep all WB at stage 5.
- ==**Data hazards**==:
  - **RAW** = TRUE dependence (2 bubbles without forwarding; 1 with (Load-use)); 
  - **WAR/WAW** = name/order, removable by **renaming**; **RAR** ❌ 
  - **Fixes**: forwarding/bypass (HW), stall (HW), OoO (HW), compiler scheduling (SW). **Deeper pipeline ❌**.
  - ==**Load-use hazard**==: even with forwarding, needs **1 bubble** (load data after MEM, too late for next EX).
  - **Forwarding requires** `RegWr=1` AND `rd != x0`; if both EX/MEM and MEM/WB match, **EX/MEM wins**.
- ==**Control hazards**==: BHT (whether), BTB (where), RAS (returns), static, early resolution. **NOT** data forwarding.
  - **Prediction stage**: ==**IF**== (must predict next PC at fetch).
  - ==**Correlated index**== = **PC ⊕ GHR**.
  - **Hardest branch**: ==**indirect `JALR`**== (jump tables / vtables / fn ptrs). Returns easy via RAS.
  - ==**Resolution → flush**==: MEM→**3**; **EX→2** (class); ID→1; IF (BTB+BHT correct)→0.
- ==**Static rules**==: **backward branch taken** (loop); forward `beq rs1,x0` NT; if-then NT; BHT-no-history NT.
- **Untagged BHT**: simple, fast, cheap, low energy. **NOT** "good for high-perf" (uses tagged/correlated).
- **2-bit FSM**: 85–95%; 1-bit BHT: 70–80%; correlated: 94–96%; tournament: 96–97%; **TAGE**: 97–99%.
  - **1-bit BHT mispredicts twice per inner loop** (last iter wrong + first iter next time wrong).
- **Tree/list traversal**: ==**data hazards** (pointer load-use) **+ control hazards** (branch on data)==.
- **Compiler scheduling limits**: memory aliasing, unknown mem latency, scope (branches/calls/traps/volatile/IO).

## 1. Structural Hazards

| Cause                            | Example                       | Fix                              |
| -------------------------------- | ----------------------------- | -------------------------------- |
| **unified I/D mem** (Von Neumann)| IF + MEM conflict             | **split I/D cache** (Harvard)    |
| non-pipelined divider            | back-to-back `div`            | pipeline divider; or stall       |
| too few regfile ports            | 2 writes same cycle           | more ports; schedule             |
| too few adders                   | `PC+4` + branch target        | add 2nd adder in EX              |
| early R-WB design                | R @ stage 4 vs load @ stage 5 | keep common WB; or extra ports   |

> [!IMPORTANT]
> Split I/D cache: **structural-hazard avoidance + bandwidth** ✅; NOT for hit rate / reliability ❌. Also: I-cache has no CPU stores → different policy than D-cache.

## 2. Data Hazards

==**Dependence types**==:

| Type     | **RAW** (R-after-W)   | **WAR** (W-after-R)        | **WAW** (W-after-W)         | **RAR** |
| -------- | --------------------- | -------------------------- | --------------------------- | ------- |
| **Meaning** | reader needs producer | later W must wait for earlier R | later W is final value | both read |
| **Hazard?** | ✅ TRUE dep (real)    | ❌ name/order (rename)     | ❌ name/order (rename)      | ❌      |

### 2.1 No Forwarding → 2 Bubble Stall

Producer writes in WB; consumer reads in ID. With WB-first-half + ID-second-half trick → 2 bubbles.

==**Quiz 2 sequence (no forwarding) → 9 bubbles**==:

```asm
1. LW S1, 8(S0)
2. LW S2, 16(S0)
3. SUB T4, S2, S1     ← 2 bubbles (RAW on S2/S1)
4. AND T5, T4, T3     ← 2 bubbles (RAW on T4)
5. SUB S4, T4, T3     ← 0 (T4 already bubbled by 4)
6. ADD T6, S4, T4     ← 2 bubbles (RAW on S4)
7. SW T6, 4(S7)       ← 2 bubbles (RAW on T6)
8. LW S3, 24(S7)
9. LW S1, 8(S7)
10. LW S5, 32(S0)
11. ADD T7, S3, S1    ← 1 bubble (RAW on S1, 1 cy apart)
12. LW S6, 64(S0)
```

**With forwarding: 0**

### 2.2 Forwarding Equations

```verilog
EX/MEM → EX (most recent producer):
  if EX/MEM.RegWr && EX/MEM.rd != 0:
    if EX/MEM.rd == ID/EX.rs1 → ForwardA = EX/MEM.ALUresult
    if EX/MEM.rd == ID/EX.rs2 → ForwardB = EX/MEM.ALUresult

MEM/WB → EX (older producer):  same pattern, MEM/WB.value
```

> [!IMPORTANT]
>
> Hazard conditions:==**EX/MEM.RegRd | MEM/WB.RegRd= ID/EX.RegRs1 | ID/EX.RegRs2**==
>
> ==**Must check `RegWr=1` AND `rd != x0`**==; if both match, **EX/MEM wins** (more recent).

### 2.3 Load-Use Hazard (1 Bubble)

```asm
lw  x5  IF ID EX MEM WB
add x6     IF ID -- EX MEM WB    ← 1 bubble
```

==**Compiler fix**==: insert independent instr between `lw` and consumer.

> Quiz 2 with forwarding → only **1 bubble** (load-use between instr 2 LW S2 and instr 3 SUB).

### 2.4 Compiler Scheduling Limits

- ==**memory aliasing**==: load/store reorder only if non-aliasing proven.
- ==**unknown mem latency**==: cache hit/miss.
- scope shrunk by branches/calls/traps; volatile/I/O/atomics block.

==**MIPS history**==: "no Interlocked Pipeline Stages" — compiler-only. Failed due to **compatibility & scalability**.

## 3. Control Hazards

| Mechanism                        | Role                                          |
| -------------------------------- | --------------------------------------------- |
| stall / flush                    | handles wrong control flow, pays full penalty |
| **BHT, BTB, RAS, static layout** | reduce penalty via early prediction           |

==**Resolution stage → flush**==:

| Resolved at      | **MEM** (textbook) | **EX** (class) | **ID** (early compare) | **IF** (BTB+BHT correct) |
| ---------------- | ------------------ | -------------- | ---------------------- | ------------------------ |
| **Bubbles**      | 3                  | **2**          | 1                      | 0                        |

==**Worked penalty anchors**==:

| Case | Calc | Slowdown |
|---|---|---|
| **A57** (16 stages, 20% br, 15-cy pen, **no pred**) | $\text{addCPI}=0.2\times15=3$; total $1+3=4$; share $3/4$ | **75%** |
| **Pentium 4** (31 stages, 20% br, **2% mispred**, 30-cy pen) | $\text{addCPI}=0.2\times0.02\times30=0.12$ | **12%** |

## 4. Branch Prediction

### 4.1 Accuracy

<table>
  <thead>
    <tr>
      <th>Method</th>
      <th>Accuracy</th>
      <th>Method</th>
      <th>Accuracy</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>always not-taken</td>
      <td>30–40%</td>
      <td>backward-taken / forward-NT</td>
      <td>60–70%</td>
    </tr>
    <tr>
      <td>compiler-static / profile-guided</td>
      <td>65–90%</td>
      <td>1-bit BHT</td>
      <td>70–80%</td>
    </tr>
    <tr>
      <td><strong>2-bit FSM</strong></td>
      <td><strong>85–95%</strong></td>
      <td>correlated / 2-level (global)</td>
      <td>94–96%</td>
    </tr>
    <tr>
      <td>local 2-level</td>
      <td>93–97%</td>
      <td>tournament</td>
      <td>96–97%</td>
    </tr>
    <tr>
      <td><strong>TAGE</strong> (Intel/AMD/ARM/Apple)</td>
      <td><strong>97–99%</strong></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>

> **Static rules quiz**: predict **backward taken** ✅, forward `beq rs1,x0` NT ✅. ❌: `beq rs1,rs2` NT (no info), `blt` taken (no info), `JALR` NT.

> [!IMPORTANT]
>
> **Dynamic (Runtime): Untagged BHT**
>
> ==**Why untagged**==: simple, fast IF access, low energy, cost-effective. **NOT** "good for high-perf" ❌ (high-perf uses tagged/correlated). Indexed by lower PC bits.

### 4.2 1-bit Problem & 2-bit FSM

==**1-bit BHT inner-loop problem**==: **mispredicts twice per outer iteration**:

```text
beq ..., inner   # last inner iter: T → predict T → actually NT (miss)
                 # re-enter: state=NT → predict NT → actually T (miss)
```

==**2-bit saturating counter**== changes prediction only on **two successive mispredictions**. States `SNT (00) → WNT (01) → WT (10) → ST (11)`:

<img src="assets%5CCA3060-4-4-Hazards_17.png" style="zoom:50%;" />

*states: 00=strongly NT, 01=weakly NT, 10=weakly T, 11=strongly T*

### 4.3 Correlated / 2-Level

```text
GHR = shift reg of last k outcomes
index = PC XOR GHR     
PHT[index] = 2-bit saturating counter
```

==**When useful**==: branches whose outcome depends on previous:

```c
if (a==2) a=0;       // B1
if (b==2) b=0;       // B2
if (a!=b) {...}      // B3 — predictable from B1, B2
```

### 4.5 BHT vs BTB vs RAS

| Structure                       | Predicts        | Implementation                                       |
| ------------------------------- | --------------- | ---------------------------------------------------- |
| ==**BHT** (direction)==         | T/NT        | 2-bit counter array indexed by PC (or PC⊕GHR)        |
| ==**BTB**==                     | **target PC**   | small **tagged cache**; tag = branch PC              |
| ==**RAS** (Return Addr Stack)== | **return target** | HW stack: push @ `JAL`, pop @ `jalr x0,ra,0`        |

==**Hard-to-predict**==:

- ==**Indirect `JALR` for switch jump tables**== (target depends on data).
- virtual calls / fn pointers.
- returns when RAS mismatches (deep recursion / RAS overflow).
- binary-tree / linked-list: data + control hazards.

> ==**Switch codegen**==: **dense** → jump table (`JALR`, hard to predict target); **sparse** → branch chain (≈ if/else).

## 5. Branch Target Adder at ID

==**`PC + B-imm` in ID**== could help **direct predicted-taken** branches (fetch target 1 cycle earlier).

==**Not useful in modern HW**==: BTB already gives target in IF; only helps direct branches (not `JALR`/returns); adds ID-stage adder cost.

> Future focus: better prediction for **indirect branches + returns** (the hardest).

## 6. Quick Quiz Anchors

| Q | Answer |
|---|---|
| binary-tree search → hazards? | **data + control** |
| linked-list pointer chase | **data** |
| split I/D cache reasons | structural avoidance + bandwidth (NOT hit rate) |
| MIPS failed because | compatibility & scalability |
| HW reducing data hazard | forwarding |
| HW+SW data hazard fixes | forwarding + OoO + scheduling |
| 5→20 stages effects | branch pen ↑, data pen ↑, CPI ↑, more pipeline regs |
| Microarch state | **BHT, BTB, pipeline regs** (NOT FP regs, NOT PC) |
| WB-propagated signals | `Rd, WRen, WBSel` (NOT `ALUCtrl`) |
| comparator unit reason | avoid subtract-overflow compare bug |
| return prediction | RAS |
| post-incr load rejected | 2 write ports + breaks regularity |
