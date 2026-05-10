# Lec 4.4: Pipeline Hazards

## Exam Facts

- **Three hazards**: ==**Structural, Data, Control**==. ("Forward hazard" is **NOT** a real hazard type — quiz trap.)
- $\text{CPI}_{actual} = \text{CPI}_{ideal} + \text{Stall cycles per instruction}$.
- Branch-penalty CPI ≈ $f_{\text{branch}} \times f_{\text{mispredict/taken}} \times \text{penalty}$.
- ==**Branch prediction performed at IF**== (earliest possible). If IF is unavailable, choose earliest stage with PC.
- ==Hardware data-hazard reduction: **forwarding/bypassing**==.
- ==Software data-hazard reduction: **compiler scheduling/reordering**==.
- ==Control-hazard reduction: **BTB + BHT + static/dynamic prediction**==.
- BHT often **untagged** because it is **simple, fast, low power, cost-effective**. (High-performance cores may use tagged BHT.)
- Correlated/2-level predictor index uses ==**current PC ⊕ Global History Register**==.
- 1-bit predictor: mispredicts **twice per inner loop** (last iteration + first iteration of next outer iter).
- 2-bit saturating counter: changes prediction only after **2 consecutive mispredicts**.
- BTB predicts ==**where**==; BHT predicts ==**whether**==.
- Hard-to-predict: ==**indirect branches (JALR for switch / virtual / function pointer) and returns**==.
- Static prediction examples: ==**backward branches taken; forward branches fall-through**==. (e.g., `beq rs1, x0, +X` predict not-taken; loop back-edge predict taken).
- Modern high-perf cores (Apple M4) use **dynamic + BTB + tournament/TAGE**, NOT static-only.
- WB-stage control signals propagated through pipeline regs: ==**`rd`, `RegWr` (WRen), `WBsel`**==.
- Split L1I/L1D ⇒ removes IF↔MEM structural hazard + increases bandwidth.
- Branch-bubble discrepancy: textbook resolves at EXE but resteers fetch at MEM ⇒ **3 bubbles**; modern designs **resteer at EXE ⇒ 2 bubbles**.

## 1.1 Pipeline Hazards Overview

==**Hazards**== prevent the next instruction from overlapping with previous ones — typically stalled at **ID** stage.

Three types: structural, data, control. (No "forward" hazard.)

## 2 Structural Hazards

==**Structural hazard**== = two pipeline stages need the **same hardware resource** in the same cycle.

### Causes

- **Von-Neumann architecture (shared instr/data memory)**: IF (fetch) of new instr conflicts with MEM (load/store) of older. **Quiz: Von-Neumann bottleneck = a structural hazard**.
- **Non-pipelined functional unit**: e.g., divide takes ~32 cycles; back-to-back divides stall.
- **Bad pipeline design (early WB)**: if R-type writes back at cycle 4, conflicts with Load writing at cycle 5 → both fight for regfile write port.

### Solutions

- **Pipeline stall** (insert bubble at ID).
- **More HW resources**: split I/D cache (Harvard); add regfile ports; pipeline / duplicate functional units.
- **Instruction reordering** (compiler-static or HW-dynamic).
- **ISA design**: avoid auto-increment instructions / mem operands that need too many ports.

> [!IMPORTANT] **Why split L1I + L1D**:
> 1. Avoid IF↔MEM structural hazard.
> 2. **Double the cache bandwidth** (parallel I-fetch + D-access).
> *(Not for higher hit rate or reliability.)*

## 3 Data Hazards

==**Data hazard**== = a needed value hasn't been produced/written yet.

| Type | Meaning | Always real in 5-stage in-order? |
|---|---|---|
| **RAW** | Read-After-Write (true) | **YES**, must preserve |
| **WAR** | Write-After-Read (anti) | usually NO in 5-stage in-order; matters in OoO/scheduling |
| **WAW** | Write-After-Write (output) | matters with OoO / multiple writers |
| RAR | Read-After-Read | **not** a hazard |

### Without forwarding (worst case)

```
ADD x9, x0, x1     // produces x9 at end of EX (cyc 3), writes back in WB (cyc 5)
SUB x10, x9, x3    // wants x9 at ID (cyc 4)
```

Reader needs to wait until producer **writes back** ⇒ adjacent ALU-ALU dependency ⇒ **2 bubbles** (between cycles where reg is read vs written).

### Solution 1: Pipeline stall at ID

> Insert bubbles until producer reaches WB.

### Solution 2: Forwarding / Bypassing (HARDWARE)

Pass result directly from later pipeline stage to earlier without going through regfile.

#### Forwarding conditions

| Source | Condition |
|---|---|
| **EX hazard** (forward from EX/MEM) | `EX/MEM.RegWr && EX/MEM.Rd != 0 && EX/MEM.Rd == ID/EX.Rs1 (or Rs2)` |
| **MEM hazard** (forward from MEM/WB) | `MEM/WB.RegWr && MEM/WB.Rd != 0 && MEM/WB.Rd == ID/EX.Rs1 (or Rs2)` |

> [!IMPORTANT] Corner cases:
> - **Don't forward from instructions that don't write a register** (Stores, Branches → check `RegWr`).
> - **Don't forward to/from `x0`** (always 0; check `Rd != 0`).

#### Load-use hazard

```
LW   x1, 0(x2)
ADD  x3, x1, x4    // wants x1 immediately after LW
```

Even with forwarding, **1 bubble remains** because LW result available only at end of MEM; ADD needs it at start of EX. The MEM/WB → EX/MEM forwarding can cover only after 1 stall.

### Solution 3: Compiler Scheduling (SOFTWARE)

> Reorder independent instructions to fill the bubble gap.

#### MIPS = "Microprocessor without Interlocked Pipeline Stages"

> Compiler must insert NOPs for hazards if no useful instruction is available; HW does NOT interlock. **Failed mainly due to compatibility/scalability**, not perf.

#### Compiler limitations

- **Memory aliasing**: can't safely move loads/stores past each other if addresses might alias.
- **Unknown / non-deterministic memory latency**: hard to schedule loads precisely.
- **Branches/calls** limit scheduling scope (basic blocks).

> [!IMPORTANT] HW reduce data hazard: **forwarding + bypassing + OoO**. SW: **compiler scheduling**.

## 4 Control Hazards

==**Control hazard**== = next-PC unknown until branch is resolved.

- Branches occur **15–30%** of instructions (~ 1 per 4–5).
- Late resolution → must flush wrong-path instructions.

### Branch resolution stage → flush count

| Branch resolved at | Flushed (penalty) |
|---|---|
| ID | 1 |
| **EXE (modern)** | **2** |
| **MEM (textbook fig)** | **3** |
| WB | 4 |

> Textbook says 3 bubbles (resteer at MEM); modern designs resteer at EXE → 2 bubbles. **Quiz answer for the discrepancy: where the resteer happens.**

### Branch penalty CPI calculation

$$\text{Penalty CPI} = f_{branch} \times f_{taken/mispredict} \times \text{flushed inst count}$$

#### Worked examples

| Setting | Calc | Penalty |
|---|---|---|
| 20% br, 50% taken, 3-flush, no pred | $0.2 \times 0.5 \times 3 = 0.3$ | **30%** (or 60% if all-taken) |
| 20% br, 50% taken, 2-flush, no pred | $0.2 \times 0.5 \times 2 = 0.2$ | **20%** (or 40% all-taken) |
| **A57: 16-stage, 20% br, no pred, ~15-cyc penalty** | $0.2 \times 1 \times 15 = 3.0$ | **75%** |
| **Pentium 4: 31-stage, 20% br, 2% mispred, penalty=30** | $0.2 \times 0.02 \times 30 = 0.12$ | **12%** |

### Branch Prediction Schemes

| Scheme | Accuracy |
|---|---|
| Always predict not-taken | 30–40% |
| Static (compiler) | 65–90% |
| 1-bit dynamic BHT | 70–80% |
| **2-bit FSM (saturating counter)** | **85–95%** |
| 2-level correlated (global) | 94–96% |
| Tournament | 96–97% |
| **TAGE** (modern Intel/AMD/ARM/Apple) | **97–99%** |

#### Static prediction rules

- ==**Backward branches → predict TAKEN**== (loop back-edges).
- ==**Forward branches → predict NOT TAKEN**== (then-clause of `if`).
- E.g., `beq rs1, x0, +X` (forward) → predict not-taken.

#### Dynamic prediction (BHT)

==**Branch History Table**==: indexed by **lower bits of PC**; entry is recent outcome (1 or 2 bits).

> Why **untagged BHT**: tag would cost 30–46 bits per entry vs 1–2 bits of history → too expensive. Aliasing causes some mispredicts, but speed/cost win. **Simple, fast, low power, cost-effective**. (High-perf cores may use tagged BHT or TAGE.)

#### 1-bit predictor pitfall

Inner loop: 2 mispredicts per outer iteration:
- Last iteration of inner loop (predict taken, actual fall-through).
- First iteration next time (predict not-taken, actually taken).

#### 2-bit saturating counter (FSM)

States: `00 strong-NT, 01 weak-NT, 10 weak-T, 11 strong-T`. Only flip prediction after **2 consecutive mispredictions** ⇒ tolerates one-off anomalies.

#### Correlated / 2-level prediction

==**Global History Register (GHR)**==: shift register of recent branch outcomes.

==**Pattern History Table (PHT)**==: 2-bit counters.

==**Index = current PC ⊕ GHR**==. (Quiz answer.)

### "Whether" vs "Where"

- ==**BHT predicts WHETHER**== (taken/not-taken).
- ==**BTB predicts WHERE**== (cache of `(PC → target)`).
- Combined BHT + BTB enables fetch from target in the **next cycle after** a predicted-taken branch.

#### Hard cases for BTB

- ==**Indirect branch (JALR)**== for `switch`, virtual calls, function pointers — target varies.
- **Returns** — target depends on caller; use a **Return Address Stack (RAS)** instead.

> [!IMPORTANT]
> Modern improvement focuses on **indirect branches** + **returns** (call/return-address stack), since predictable conditional branches already at 99%.

### Computing branch target at ID stage?

- IF compute `PC+imm` at ID, fetch from target one cycle earlier on **predicted-taken** branches.
- BUT modern BTB+BHT already supplies target at IF ⇒ extra ID adder doesn't pay off.
- **Quiz: usually a bad design choice in modern processors.**

## Control Signals in Pipeline

Generated in ID, propagated through pipeline registers:

| Stage signals used | Cycles delayed |
|---|---|
| EX (`ALUctl, ALUSrc`) | +1 |
| MEM (`MemRW, Branch`) | +2 |
| **WB (`rd, RegWr, WBsel`)** | **+3** |

> [!IMPORTANT] **WB-stage signals (must reach WB through pipeline regs)**:
> - **`rd`** (which register to write)
> - **`RegWr` / WRen** (write enable)
> - **`WBsel`** (ALU vs Mem vs PC+4)
> NOT `ALUctl` (used in EX, not propagated to WB).
