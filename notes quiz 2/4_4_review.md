# Lec 4.4: Pipeline Hazards

## Exam Facts

- ==**Three hazards**==: ==**Structural, Data, Control**==. **"Forward hazard" is NOT one** (Quiz 3 #1).
- $$CPI_{actual} = CPI_{ideal} + StallCycles/Instr$$
- $$AddedCPI_{control} = BranchFreq \times MispredictRate \times Penalty$$
- ==**Structural hazard**==: insufficient HW (e.g., unified mem for IF+MEM, non-pipelined divider, too few regfile ports, early WB conflict).
- **Von Neumann bottleneck in pipeline = structural hazard** (Quiz 3 #8).
- ==**Why split I/D cache**==: avoid IF/MEM **structural hazard** + **higher access bandwidth**. NOT primarily for hit rate / reliability.
- **Data hazard fixes** (HW or SW): **forwarding/bypassing** (HW), **stall/interlock** (HW), **OoO** (HW), **compiler scheduling** (SW).
- **Deeper pipeline does NOT fix data hazards** (it makes them worse).
- ==**Load-use hazard**==: even with forwarding, needs **1 bubble** (load data ready after MEM, too late for next EX).
- ==**Control hazard fixes**==: **BHT** (predicts whether), **BTB** (predicts where), **RAS** (predicts returns), static predict, early resolution. NOT data forwarding.
- ==**BHT vs BTB vs RAS**==: BHT = direction (taken/NT); BTB = target PC; RAS = return target stack.
- **Branch prediction stage**: ==**IF**== (must predict next PC at fetch).
- ==**Correlated (2-level) predictor index**== = **PC ⊕ Global History Register** (most common). Or **PC + GHR**.
- **Hardest branch to predict**: ==**indirect `JALR`**== for switch jump-tables / vtables / function pointers. Returns are easy (RAS).
- **Modern high-perf CPUs use dynamic prediction**, not static-only. Apple M4 → not "static branch prediction".
- **Static rules**: ==**predict backward branch taken**== (loop), forward branch fall-through (then-path), default-NT for `beq rs1,x0` forward, default-taken for backward `blt`.
- **Untagged BHT**: simple, fast, cheap, low energy. **NOT** "good for high-performance" (high-perf CPUs use tagged or correlated).
- ==**Branch resolution stage → flush**==: MEM→**3 bubbles** (textbook); EX→**2 bubbles** (class); ID→**1 bubble**; IF (BTB+BHT correct)→**0**.
- **A57 example** (16 stages, 20% branch, 15-cycle penalty, no pred): added CPI = 0.2×15 = 3; penalty = 3/(1+3) = **75%**.
- **Pentium 4 example** (31 stages, 20% branch, 2% mispred, 30-cycle penalty, base CPI=1): added CPI = 0.2×0.02×30 = 0.12 → **12% slowdown**.
- **Without prediction, only-taken branches flush**: use `BranchFreq × TakenRate × Penalty`.
- **2-bit FSM accuracy**: 85–95%; 1-bit BHT: 70–80%; correlated 2-level: 94–96%; tournament: 96–97%; TAGE: 97–99%.
- **1-bit BHT mispredicts twice per inner loop** (last iter wrong + first iter next time wrong).
- **Tree/list traversal hazard**: ==**data hazards** (pointer load-use chain) **+ control hazards** (branch on data)==.
- **Compiler scheduling limits**: memory aliasing unknown, mem latency unknown, scope limited by branches/calls/traps/volatile/IO.
- **Branch target adder in ID**: would help only **direct predicted-taken branches**; not used much in modern HW (BTB already gives target in IF).

## 1. Hazard Overview

==**Pipeline equation**==:

$$
CPI_{actual} = CPI_{ideal} + \frac{Stall\ Cycles}{Instr}
$$

==**Pipeline loss sources**==:

- unbalanced stages.
- pipeline-reg overhead.
- fill/drain.
- ==**structural / data / control hazards**==.

> Quiz: **"forward hazard" is NOT a real hazard** (it's the *fix*, not the problem).

## 2. Structural Hazards

==**Structural hazard**==: two stages need the **same HW resource** in the same cycle.

| Cause | Example | Fix |
|---|---|---|
| **unified I/D mem** (Von Neumann) | IF + MEM conflict | **split I/D cache** (Harvard) |
| non-pipelined divider | back-to-back `div` | pipeline divider; or stall |
| too few regfile ports | 2 writes same cycle | more ports; schedule |
| too few adders | `PC+4` + branch target | add 2nd adder in EX |
| early R-WB design | R-type WB at stage 4 vs load WB at stage 5 | keep common WB; or extra ports |

> ==**Von Neumann bottleneck in pipelined data path = structural hazard**== (Quiz 3 #8 → answer A).

==**Why split I/D cache**==: (Quiz 3 #14) → **avoid structural hazards** + **higher access bandwidth**. NOT for hit rate / reliability. Also: I-cache and D-cache can be managed differently (e.g., I has no writes from CPU).

> [!IMPORTANT]
> ==Moving R-type WB earlier (to stage 4) **creates a structural hazard** with loads writing the regfile at stage 5==. Class answer: keep all WB at stage 5.

## 3. Data Hazards

### 3.1 Dependence Types

| Type | Meaning | Hazard? |
|---|---|---|
| ==**RAW**== (Read After Write) | reader needs producer's value | **TRUE dependence** (real) |
| **WAR** (Write After Read) | later write must wait for earlier read | name/order — removable by **renaming** |
| **WAW** (Write After Write) | later write defines final value | name/order — removable by **renaming** |
| RAR | both read | **NOT a hazard** |

> Quiz 2 #12: "True Dependence" = ==**RAW**==.

### 3.2 Without Forwarding

Producer writes in WB; consumer reads in ID. Without forwarding:

```text
add x5, ...   IF ID EX MEM WB
sub x6, x5, ...  IF ID ID ID EX MEM WB    ← stall 2-3 cycles
```

Up to **2-3 bubbles** depending on regfile write/read timing (with WB-first-half + ID-second-half trick → 2 bubbles).

==**Quiz 2 sequence (no forwarding) → 9 bubbles**==:

```text
1. LW S1, 8(S0)
2. LW S2, 16(S0)
3. SUB T4, S2, S1     ← 2 bubbles (RAW on S2 from instr 2; on S1 from instr 1)
4. AND T5, T4, T3     ← 2 bubbles (RAW on T4 from instr 3)
5. SUB S4, T4, T3     ← 0 bubbles (T4 already produced; covered by half-cycle write)
6. ADD T6, S4, T4     ← 2 bubbles (RAW on S4 from instr 5)
7. SW T6, 4(S7)       ← 2 bubbles (RAW on T6 from instr 6)
8. LW S3, 24(S7)
9. LW S1, 8(S7)
10. LW S5, 32(S0)
11. ADD T7, S3, S1    ← 1 bubble (RAW on S1 from instr 9, 1 cycle apart)
12. LW S6, 64(S0)
```

Total: 2 + 2 + 2 + 2 + 1 = **9 bubbles**.

### 3.3 Forwarding Equations (Bypass)

==**EX/MEM → EX**== (most recent producer):

```text
IF (EX/MEM.RegWr) AND (EX/MEM.rd != 0):
  IF (EX/MEM.rd == ID/EX.rs1) → ForwardA = EX/MEM.ALUresult
  IF (EX/MEM.rd == ID/EX.rs2) → ForwardB = EX/MEM.ALUresult
```

==**MEM/WB → EX**== (older producer):

```text
IF (MEM/WB.RegWr) AND (MEM/WB.rd != 0):
  IF (MEM/WB.rd == ID/EX.rs1) → ForwardA = MEM/WB.value
  IF (MEM/WB.rd == ID/EX.rs2) → ForwardB = MEM/WB.value
```

> [!IMPORTANT]
> ==**Both must check `RegWr=1` AND `rd != x0`**==. Otherwise: stores/branches/`x0` create false forwards.

> If both EX/MEM and MEM/WB match, **EX/MEM wins** (more recent value).

### 3.4 Load-Use Hazard

```asm
lw  x5, 0(x1)
add x6, x5, x2     ← load data ready after MEM, too late for next EX
```

==**Even with forwarding, needs 1 bubble**==:

```text
lw  x5  IF ID EX MEM WB
add x6      IF ID -- EX MEM WB    ← 1 bubble
```

==**Compiler fix**==: place an independent instr between `lw` and consumer.

```asm
lw  x5, 0(x1)
addi t0, t0, 1    # independent, fills the bubble
add  x6, x5, x2
```

### 3.5 With Forwarding: Quiz 2 → 1 Bubble Remains

With both forwarding paths active, the only unavoidable bubble in the Quiz 2 sequence is at the **load-use** between instr 2 (`LW S2`) and instr 3 (`SUB T4, S2, S1`).

### 3.6 Compiler Scheduling Limits

Scheduling helps but is limited by:

- ==**memory aliasing**== (load/store across each other only safe if proven non-aliasing).
- ==**unknown memory latency**== (cache hit/miss).
- calls/branches/traps shrink scheduling scope (basic block).
- volatile / I/O / atomics.

> Quiz 3 #28: compiler limits = **B (alias) + D (latency)**.

==**MIPS history**==: "Microprocessor without Interlocked Pipeline Stages" — compiler-only hazard avoidance. **Failed due to compatibility/scalability** (Quiz 3 #11 → A).

## 4. Control Hazards

==**Control hazard**==: correct next-PC is unknown or predicted wrong.

==**Branch penalty contribution**==:

$$
AddedCPI = BranchFreq \times MispredictRate \times Penalty
$$

> No-prediction case: replace `MispredictRate` with `TakenRate` (only taken branches flush).

| Mechanism | Role |
|---|---|
| stall / flush | handles wrong control flow but pays full penalty |
| **BHT, BTB, RAS, static layout** | reduce penalty via early prediction |
| data forwarding/bypassing | **NOT** a control-hazard fix (Quiz 3 #18 wrong distractor) |

### 4.1 Resolution Stage → Flush Count

| Resolved at      | **MEM** (textbook) | **EX** (class) | **ID** (early compare) | **IF** (BTB+BHT correct) |
| ---------------- | ------------------ | -------------- | ---------------------- | ------------------------ |
| **Bubbles**      | 3                  | **2**          | 1                      | 0                        |

==**Discrepancy textbook 3 vs class 2**==: textbook redirects fetch one stage later (after MEM); class assumes EX can resteer immediately. Quiz 2 #6d explanation.

==**Worked penalty anchors**==:

| Case | Calc | Slowdown |
|---|---|---|
| **A57** (16 stages, 20% br, 15-cycle pen, **no pred**) | added CPI $=0.2 \times 15=3$; total $1+3=4$; share $3/4$ | **75%** ★ |
| **Pentium 4** (31 stages, 20% br, **2% mispred**, 30-cycle pen) | added CPI $=0.2 \times 0.02 \times 30 = 0.12$ | **12%** ★ |

## 5. Branch Prediction

### 5.1 Static and Dynamic

| Method | Accuracy |
|---|---:|
| always not-taken | 30–40% |
| backward-taken / forward-not-taken | 60–70% |
| compiler-static / profile-guided | 65–90% |
| 1-bit BHT | 70–80% |
| ==**2-bit FSM (saturating counter)**== | **85–95%** |
| correlated / 2-level (global) | 94–96% |
| local 2-level | 93–97% |
| tournament | 96–97% |
| **TAGE** (Intel/AMD/ARM/Apple) | **97–99%** |

==**Static rules**==:

| Pattern | Predict |
|---|---|
| backward branch (loop back-edge) | **taken** |
| forward `beq rs1, x0` | **not taken** (often error/exception path) |
| if-then with then in fall-through | not taken |
| BHT entry no history | **NT** (default) |

> Quiz 3 #23 (effective static): **predict backward taken**, predict forward `beq rs1,x0` not-taken. **NOT**: `beq rs1,rs2` NT (no info), `blt` taken (no info), `JALR` NT.

### 5.2 1-bit vs 2-bit BHT

==**1-bit BHT inner-loop problem**==: **mispredicts twice per outer iteration**:

```
outer:
  inner:
    ...
    beq ..., inner   # last inner iter: was T → predict T → actually NT (mispredict)
                     # next time inner: state=NT → predict NT → actually T (mispredict)
```

==**2-bit saturating counter**== (FSM): only changes prediction on **two successive mispredictions**.

States `SNT (00) → WNT (01) → WT (10) → ST (11)`:

| State        | **SNT** | **WNT** | **WT** | **ST** |
| ------------ | ------- | ------- | ------ | ------ |
| **Predict**  | NT      | NT      | T      | T      |
| **on T →**   | WNT     | WT      | ST     | ST     |
| **on NT →**  | SNT     | SNT     | WNT    | WT     |

### 5.3 Untagged BHT

==**Why untagged**== (Quiz 3 #24):

- **simple**.
- **fast IF access**.
- **low energy**.
- **cost-effective**.

==**NOT**== "good for high-performance" — high-perf CPUs prefer **tagged or correlated**. Cost: aliasing between branches.

> Indexed by **lower PC bits** typically.

### 5.4 Correlated / 2-Level

Use recent branch outcomes:

```text
GHR (Global History Register) = shift register of last k outcomes
index = PC XOR GHR     ★ Quiz 2 #11 / Quiz 3 #22 answer
PHT[index] = 2-bit saturating counter
```

==**When useful**==: branches whose outcome depends on previous outcomes:

```c
if (a==2) a=0;       // B1
if (b==2) b=0;       // B2
if (a!=b) {...}      // B3 — depends on B1, B2 outcomes
```

If B1=T && B2=T → B3=NT predictable.

### 5.5 BHT vs BTB vs RAS

| Structure | Predicts | Implementation |
|---|---|---|
| ==**BHT / direction predictor**== | taken/NT | array of 2-bit counters indexed by PC (or PC⊕GHR) |
| ==**BTB**== | **target PC** | small **tagged cache**; one tag = branch PC, payload = target PC |
| ==**RAS** (Return Address Stack)== | **return target** | hardware stack: push at `JAL` call; pop at `JALR x0,ra,0` |

==**Hard-to-predict branches**== (Quiz 3 #34):

- ==**Indirect `JALR` for switch jump tables**== ★ (target depends on data).
- virtual calls / function pointers.
- returns when RAS mismatches (deep recursion or RAS overflow).
- binary-tree / linked-list traversal: **data hazards** (pointer load-use) + **control hazards** (data-dependent branch direction).

==**Switch vs if-chain**==:

- **dense / continuous cases** → compiler emits **jump table** → indirect `JALR`, fast but **harder target prediction**.
- **sparse / few cases** → compare-branch chain, similar to `if/else`.

## 6. Branch Target at ID Stage

==**Computing `PC + B-imm` in ID**== could help **predicted-taken direct branches** (IF can fetch target one cycle earlier).

==**But not really useful in modern HW**== (Quiz 2 #6b):

- BTB already gives target in IF.
- Only helps **direct branches**, not indirect `JALR` or returns.
- Adds an ID-stage adder (delay + cost).

==**Future improvement focus**== (Quiz 2 #6c): better prediction for **indirect branches + returns** (the hardest category).

## 7. Control Signals in Pipeline

Decoded in **ID**, propagated forward via pipeline regs.

| Stage | Data + Control needed |
|---|---|
| **EX** | operands (`R[rs1], R[rs2]`), imm, `ALUCtrl`, `ASel/BSel`, `BrUn` |
| **MEM** | ALU result (addr), store-data, `MemRW`, branch result for `PCSel` |
| **WB** | ALU result / mem-data / `PC+4`, `rd` desig, `RegWr/WRen`, `WBSel` |

==**WB-stage signals (3 cycles after ID)**==: `Rd`, `WRen`, `WBSel`. **NOT `ALUCtrl`** (used in EX, dies after).

## 8. Data Structures and Data Hazards (Quiz 2 #5)

==**Pipeline-hostile data structures**==: linked lists, trees, queues/stacks (as nodes), hash tables with chained collisions. Cause:

- **Pointer chase** (`while (p) p = p->next`): RAW on `p` every iter; load-use 1-bubble + every load may miss cache.
- **Tree search**: data hazards (pointer chase) + control hazards (compare-and-branch on data).

==**Programmer fixes**== (Quiz 2 #5):

| Fix | How |
|---|---|
| **Prefer contiguous structures** | use **arrays**; B/B+ trees instead of binary trees; **open addressing** instead of collision chains |
| **Avoid one-at-a-time** | traverse multiple **independent** streams together; batch lookups; allow multiple in-flight memory requests |

## 9. Quick Quiz Anchors

| Q | Answer |
|---|---|
| three hazards | structural, data, control (NOT "forward") |
| binary-tree search → which hazards? | **data + control** (Quiz 3 #30) |
| linked-list pointer chase → hazard | **data** (Quiz 3 #5) |
| split I/D cache reasons | structural-hazard avoidance + bandwidth (NOT hit rate) |
| MIPS interlock-free design failed because | compatibility & scalability |
| what HW reduces data hazard penalty | forwarding + bypassing |
| HW + SW reducing data hazard | forwarding + OoO + scheduling (NOT deeper pipe) |
| 5→20 stages effects | branch penalty ↑, data penalty ↑, CPI ↑, more pipeline regs |
| Microarch states | **BHT, BTB, pipeline regs** (NOT FP regs, NOT PC) |
| WB-propagated signals | `Rd, WRen, WBSel` (NOT `ALUCtrl`) |
| comparison unit reason | avoid subtract-overflow compare bug |
| return prediction structure | RAS (Return Address Stack) |
| post-incr load rejected reason | needs 2 write ports + breaks regularity |
