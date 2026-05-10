# Lec 4.4: Pipeline Hazards

## Exam Facts

- **Three hazards**: ==**Structural, Data, Control**==. ("Forward hazard" is **NOT** a real type — quiz trap.)
- $\text{CPI}_{actual} = \text{CPI}_{ideal} + \text{Stall cycles per instr}$.
- Branch-penalty CPI ≈ $f_{br} \times f_{mispredict/taken} \times \text{penalty}$.
- ==**Branch prediction at IF**== (earliest stage with PC).
- HW data-hazard reduction: ==**forwarding/bypassing + OoO**==. SW: ==**compiler scheduling**==.
- Control-hazard reduction: ==**BTB + BHT + static/dynamic prediction**==. (NOT data forwarding.)
- BHT often **untagged** because **simple, fast, low energy, cost-effective**.
- Correlated/2-level predictor index: ==**current PC ⊕ Global History Register**==.
- 1-bit predictor mispredicts **twice per inner loop**.
- 2-bit saturating counter: changes prediction only after **2 consecutive mispredicts**.
- ==**BTB predicts where; BHT predicts whether**==.
- Hardest to predict: ==**indirect branch (JALR for switch / vtable)**==. (Returns use **RAS** so easier.)
- Static prediction: ==**backward branches taken; forward not-taken**== (e.g., `beq rs1,x0,+X` predict not-taken).
- Modern high-perf cores (Apple M4) use **dynamic + BTB + tournament/TAGE**, NOT static-only.
- WB-stage signals propagated through pipeline regs: ==**`rd`, `RegWr` (WRen), `WBsel`**==.
- Split L1I/L1D ⇒ avoid IF↔MEM struct hazard + double bandwidth.
- Branch-bubble discrepancy: textbook resolves at EXE, **resteers fetch at MEM ⇒ 3 bubbles**; modern designs **resteer at EXE ⇒ 2 bubbles**.

## 1. Structural Hazards

==**Structural hazard**==: two stages need the **same HW resource** in same cycle.

### 1.1 Causes

- ==**Von-Neumann bottleneck**==: shared instr/data memory → IF vs MEM conflict (= structural hazard).
- **Non-pipelined functional unit**: e.g., divide (~32 cyc) → back-to-back divides stall.
- **Bad design (early WB)**: R-type WB at cyc 4 conflicts with Load WB at cyc 5 → regfile write-port fight.

### 1.2 Solutions

- **Pipeline stall** (bubble at ID).
- More HW: ==**split I/D cache (Harvard)**==, more regfile ports, pipelined functional units.
- **Instruction reordering** (compiler / HW dynamic).
- ISA design: avoid auto-increment / mem operands needing many ports.

> [!IMPORTANT] Why split L1I+L1D: **(1) avoid IF↔MEM struct hazard**, **(2) double cache bandwidth**. NOT for higher hit rate or reliability.

## 2. Data Hazards

==**Data hazard**==: needed value not yet produced/written.

| Type | Meaning | Real in 5-stage in-order? |
|---|---|---|
| **RAW** | true (read-after-write) | **YES** |
| **WAR** | anti (write-after-read) | usually NO; matters in OoO/scheduling |
| **WAW** | output (write-after-write) | matters with OoO/multi-writer |
| RAR | read-after-read | NOT a hazard |

### 2.1 Without Forwarding (worst case)

```
ADD x9, x0, x1    # produces x9 at end of EX (cyc 3), WB at cyc 5
SUB x10, x9, x3   # wants x9 at ID (cyc 4)
```

Reader waits until producer's WB ⇒ adjacent ALU-ALU ⇒ **2 bubbles**.

### 2.2 Solution: Forwarding / Bypassing (HARDWARE)

| Source | Condition |
|---|---|
| EX hazard (forward EX/MEM) | `EX/MEM.RegWr && EX/MEM.Rd != 0 && EX/MEM.Rd == ID/EX.Rs1 (or Rs2)` |
| MEM hazard (forward MEM/WB) | `MEM/WB.RegWr && MEM/WB.Rd != 0 && MEM/WB.Rd == ID/EX.Rs1 (or Rs2)` |

> [!IMPORTANT] Corner: don't forward from instrs that don't write (stores/branches → check `RegWr`). Don't forward to/from `x0`.

#### 2.2.1 Load-Use Hazard

```
LW   x1, 0(x2)
ADD  x3, x1, x4
```

Even with forwarding, **1 bubble remains**: LW result available only at end of MEM; ADD needs it at start of EX.

### 2.3 Solution: Compiler Scheduling (SOFTWARE)

> Reorder independent instrs to fill bubble.

==**MIPS**== (Microprocessor without Interlocked Pipe Stages): no HW interlocks; compiler must insert NOPs if no useful instr. **Failed mainly due to compatibility/scalability**, not perf.

> Compiler limits: memory aliasing; unknown/non-deterministic memory latency; branches/calls limit basic-block scope.

## 3. Control Hazards

==**Control hazard**==: next-PC unknown until branch resolved.

- Branches occur **15-30%** of instrs (~1 per 4-5).
- Late resolution → must flush wrong-path instrs.

### 3.1 Branch Resolution Stage → Flush Count

| Resolved at | Flushed (penalty) |
|---|---|
| ID | 1 |
| **EXE (modern)** | **2** |
| **MEM (textbook)** | **3** |
| WB | 4 |

> Textbook: 3 bubbles (resteer at MEM); modern: 2 bubbles (resteer at EXE). Quiz answer for the discrepancy.

### 3.2 Branch Penalty CPI

$$\text{Penalty CPI} = f_{br} \times f_{taken/mispredict} \times \text{flushed}$$

| Setting | Calc | Penalty |
|---|---|---|
| 20%br, 50%taken, 3-flush, no pred | $0.2\times 0.5\times 3=0.3$ | 30% |
| ==**A57: 16-stage, 20%br, no pred, ~15-cyc penalty**== | $0.2\times 1\times 15=3.0$ | **75%** |
| ==**Pentium 4: 31-stage, 20%br, 2%mispred, penalty=30**== | $0.2\times 0.02\times 30=0.12$ | **12%** |

### 3.3 Branch Prediction Schemes

| Scheme | Accuracy |
|---|---|
| Always not-taken | 30-40% |
| Static (compiler) | 65-90% |
| 1-bit dynamic BHT | 70-80% |
| **2-bit FSM (saturating)** | 85-95% |
| 2-level correlated (global) | 94-96% |
| Tournament | 96-97% |
| ==**TAGE** (modern Intel/AMD/ARM/Apple)== | **97-99%** |

#### 3.3.1 Static Rules

- ==**Backward → predict TAKEN**== (loop back-edges).
- ==**Forward → predict NOT TAKEN**== (then-clause of `if`).
- E.g., `beq rs1, x0, +X` (forward) → predict not-taken.

#### 3.3.2 Dynamic Prediction (BHT)

==**Branch History Table**==: indexed by **lower bits of PC**; entry is recent outcome (1 or 2 bits).

> Why **untagged**: tag would be 30-46b vs 1-2b history → too expensive. Aliasing causes some mispredicts, but speed/cost win. **Simple, fast, low power, cost-effective**. (High-perf cores may add tags / TAGE.)

#### 3.3.3 1-bit Pitfall

Inner loop: 2 mispredicts per outer iteration:
- Last iter of inner (predict taken, actual fall-through).
- First iter next time (predict not-taken, actually taken).

#### 3.3.4 2-bit Saturating Counter

States: `00 strong-NT, 01 weak-NT, 10 weak-T, 11 strong-T`. Flip prediction only after **2 consecutive mispredicts**.

#### 3.3.5 Correlated / 2-Level

==**Global History Register (GHR)**==: shift register of recent outcomes.
==**Pattern History Table (PHT)**==: 2-bit counters.
==**Index = current PC ⊕ GHR**==.

### 3.4 "Whether" vs "Where"

- ==**BHT predicts WHETHER**== (taken/not-taken).
- ==**BTB predicts WHERE**== (cache of `(PC → target)`).
- BHT + BTB ⇒ fetch from target the **next cycle** after a predicted-taken branch.

#### 3.4.1 Hard Cases for BTB

- ==**Indirect branch (JALR)**== for `switch`, virtual calls, function pointers — target varies.
- **Returns** — handled by ==**Return Address Stack (RAS)**==.

> Modern improvement focus: indirect branches + returns; conditional already 99%.

### 3.5 Branch Target at ID Stage?

- IF compute `PC+imm` at ID, fetch from target one cyc earlier on predicted-taken branches.
- BUT modern BTB+BHT already supplies target at IF ⇒ ==extra ID adder doesn't pay off==.

## 4. Control Signals in Pipeline

Generated in ID, propagated through pipeline regs:

| Stage signals | Cycles delayed |
|---|---|
| EX (`ALUctl, ALUSrc`) | +1 |
| MEM (`MemRW, Branch`) | +2 |
| ==**WB (`rd, RegWr, WBsel`)**== | **+3** |

> [!IMPORTANT] WB-stage signals through pipeline regs: ==**`rd, RegWr (WRen), WBsel`**==. NOT `ALUctl` (used at EX).
