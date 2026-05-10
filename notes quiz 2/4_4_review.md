# Lec 4.4: Pipeline Hazards

## Exam Facts

- Three pipeline hazards: ==**structural, data, control**==. **Forward hazard is not a hazard type**.
- $$CPI_{actual}=CPI_{ideal}+\text{stall cycles per instr}$$
- Branch penalty: $\text{Penalty CPI}=f_{br}\times f_{mispredict/taken}\times\text{flush penalty}$.
- Branch prediction should be done in **IF**: earliest stage with PC.
- Data-hazard fixes: HW **forwarding/bypassing**, HW OoO, SW compiler scheduling. Not deeper pipeline.
- Control-hazard fixes: **BTB, BHT, static/dynamic prediction**. Not data forwarding/bypassing.
- Split L1I/L1D: avoid IF-vs-MEM structural hazard + increase cache bandwidth. Not higher hit rate/reliability.
- BHT usually untagged because **simple, fast, low energy, cost-effective**. Not "good for high-performance" as a blanket answer.
- Correlated/2-level predictor index uses **current PC + global history**, often `PC xor GHR`.
- `BTB` predicts **where**; `BHT` predicts **whether**.
- Hardest branch/jump target: **indirect JALR** (`switch`, vtable, function pointer). Returns are helped by RAS.
- Static rules: backward branch taken; forward branch not taken.
- Textbook branch bubble discrepancy: branch resolved at EX but fetch resteered in MEM -> 3 bubbles; modern resteer at EX -> 2 bubbles.

## 1. Structural Hazards

==**Structural hazard**==: two pipeline stages need the same hardware resource in the same cycle.

### 1.1 Causes

| Cause | Example |
|---|---|
| shared instr/data memory | IF wants instruction while MEM wants data |
| non-pipelined long FU | back-to-back divides contend for divider |
| too few regfile ports | two WB writes same cycle |
| complex ISA side effects | post-increment load needs two writes |

Von Neumann bottleneck in a pipeline is a **structural hazard**.

### 1.2 Solutions

- Stall one instruction.
- Add/pipeline resources: split I/D cache, more ports, pipelined FUs.
- Schedule/reorder independent instructions.
- Keep ISA simple so instructions do not demand many ports/resources.

> [!IMPORTANT]
> R-type early WB can create a write-port conflict with a load WB. Do not "optimize" stage timing without checking resource conflicts.

## 2. Data Hazards

==**Data hazard**==: an instruction needs a value that an earlier instruction has not made available yet.

| Dependence | Meaning | In 5-stage in-order |
|---|---|---|
| RAW | read after write, true dependence | real stall/forwarding issue |
| WAR | write after read, anti dependence | mostly scheduling/OoO issue |
| WAW | write after write, output dependence | mostly scheduling/OoO issue |
| RAR | read after read | not a hazard |

### 2.1 Without Forwarding

Adjacent ALU producer/consumer:

```asm
add x9,x0,x1      # x9 written in WB
sub x10,x9,x3     # wants x9 in ID
```

If register-file WB can be read by ID in same cycle, adjacent ALU-use needs **2 bubbles** without forwarding.

Quiz2 sequence bubble count without forwarding:

```text
2->3: 2 bubbles
3->4: 2
5->6: 2
6->7: 2
9->11: 1
total = 9 bubbles
```

### 2.2 Forwarding / Bypassing

==**Forwarding**== sends a produced value from a pipeline register directly to EX input, without waiting for regfile WB.

| Source | Condition for `rs1` or `rs2` |
|---|---|
| EX/MEM -> ID/EX | `EX/MEM.RegWr && EX/MEM.Rd != x0 && EX/MEM.Rd == ID/EX.Rs1/Rs2` |
| MEM/WB -> ID/EX | `MEM/WB.RegWr && MEM/WB.Rd != x0 && MEM/WB.Rd == ID/EX.Rs1/Rs2` |

> [!IMPORTANT]
> Check `RegWr` and `Rd != x0`; stores/branches do not write GPRs and `x0` must never be forwarded as a real result.

### 2.3 Load-Use Hazard

```asm
lw  x1,0(x2)
add x3,x1,x4
```

Load data is ready only after MEM, while consumer needs it at start of EX. Even with forwarding, adjacent load-use leaves **1 bubble**.

Quiz2 forwarding result: only **1 bubble remains**.

### 2.4 Compiler Scheduling

Compiler tries to fill bubbles with independent instructions.

Limits:

- unknown memory aliasing.
- unknown/non-deterministic cache miss latency.
- branches/calls limit scheduling scope.
- volatile/atomic/trapping loads cannot be freely moved.

MIPS without interlocks required compiler-inserted NOPs; it failed mainly because of **compatibility/scalability**, not because performance was uncompetitive.

## 3. Control Hazards

==**Control hazard**==: next PC is unknown or predicted wrong.

Branches are common (about 15-30% instrs), so late resolution costs many cycles.

### 3.1 Resolution Stage and Flush Penalty

| Branch resolved / resteer used at | Wrong-path instrs flushed |
|---|---:|
| ID | 1 |
| EX, modern resteer immediately | 2 |
| EX outcome but MEM-stage resteer (textbook) | 3 |
| WB | 4 |

### 3.2 Branch Penalty CPI

$$
\text{Penalty CPI}=f_{br}\times f_{mispredict/taken}\times\text{penalty cycles}
$$

Examples:

| Case | Calculation | Result |
|---|---|---|
| 20% branches, 50% taken, 3-cycle no-pred taken penalty | `0.2*0.5*3` | 0.3 CPI = 30% if base CPI=1 |
| ARM A57 16 stages, no prediction, 20% branches, about 15-cycle penalty | `0.2*1*15=3`; slowdown part `3/(1+3)` | **75% performance penalty** |
| Pentium 4 31 stages, 20% branches, 2% mispred, 30-cycle penalty | `0.2*0.02*30` | 0.12 CPI = 12% |

> Be clear whether the question asks added CPI or performance loss fraction. Quiz A57's 75% comes from branch stalls being 3 cycles out of total 4 cycles.

## 4. Branch Prediction

### 4.1 Schemes

| Scheme | Accuracy idea |
|---|---|
| Always not-taken | 30-40% |
| Static compiler/rule | 65-90% |
| 1-bit BHT | 70-80% |
| 2-bit saturating counter | 85-95% |
| Correlated / 2-level | 94-96% |
| Tournament | 96-97% |
| TAGE-like modern | 97-99% |

Modern high-perf cores use dynamic prediction + BTB; static-only is not plausible for Apple M4-like cores.

### 4.2 Static Prediction

- Backward branches -> predict taken.
- Forward branches -> predict not taken.
- Example `beq rs1,x0,+offset`: forward -> predict not taken.

### 4.3 BHT

==**BHT**== stores recent taken/not-taken history, often indexed by low PC bits.

- Untagged BHT is small/fast/low-energy.
- Aliasing can hurt accuracy.
- 1-bit predictor mispredicts twice per inner loop per outer iteration: loop exit and next first iteration.

2-bit saturating counter:

```text
00 strong NT, 01 weak NT, 10 weak T, 11 strong T
prediction changes only after two consecutive misses
```

### 4.4 Correlated / 2-Level Prediction

==**GHR**== records recent global branch outcomes; ==**PHT**== holds 2-bit counters.

Index commonly: `current PC xor GHR`.

Quiz wording: uses **current PC** and **global branch history**.

### 4.5 BTB and Hard Targets

| Structure | Predicts |
|---|---|
| BHT | whether branch is taken |
| BTB | where target address is |
| RAS | return targets |

Hard cases:

- indirect `jalr` for `switch`.
- virtual calls/function pointers.
- returns are less hard because RAS predicts them.

## 5. Branch Target at ID Stage

If `PC+imm` is computed in ID, predicted-taken branch can fetch target one cycle earlier.

Why not always good:

- Modern BTB already supplies target in IF.
- Extra ID adder increases area/critical path.
- Conditional prediction is already very accurate; remaining gains are mainly indirect branches/returns.

## 6. Control Signals in Pipeline

Control generated in ID must travel with its instruction.

| Used at | Signals |
|---|---|
| EX | `ASel`, `BSel`, `ALUSel`, branch compare controls |
| MEM | `MemRW`, branch/jump control/outcome |
| WB | ==**`rd`, `RegWEn/WRen`, `WBSel`**== |

Quiz: WB-stage propagated signals are `rd`, `WRen`, `WBSel`; **not** `ALUctl`.
