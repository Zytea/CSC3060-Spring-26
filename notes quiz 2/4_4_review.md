# Lec 4.4: Pipeline Hazards

## Exam Facts

- **Three hazards**: ==**structural, data, control**==; "forward hazard" is **not** one.
- **Actual CPI**: `ideal CPI + stall cycles per instruction`.
- ==**Structural hazard**==: not enough hardware resources.
- **Data-hazard fixes**: `forwarding/bypassing`, stalls/interlocks, compiler scheduling, OoO.
- **Load-use hazard**: usually needs **1 bubble** even with forwarding.
- **Control-hazard fixes**: dynamic prediction, BHT, BTB, RAS, static layout, early resolution.
- **BHT / BTB / RAS**: BHT predicts **whether**; BTB predicts **where**; RAS predicts returns.
- **Prediction stage**: branch prediction should happen in **IF**.
- **Correlated predictor index**: current PC combined with global history, often `PC xor GHR`.
- **Hard target prediction**: indirect `JALR` from `switch`/vtable/function pointer; returns use RAS.
- **High-performance cores**: static-only prediction is not plausible.

## 1. Hazard Overview

$$
CPI_{actual}=CPI_{ideal}+StallCycles/Instruction
$$

Hazards insert bubbles or flush wrong-path instrs.

## 2. Structural Hazards

==**Structural hazard**==: two stages need same resource in same cycle.

| Cause | Example | Fix |
|---|---|---|
| unified I/D memory | IF and MEM conflict | split I/D cache |
| non-pipelined divider | back-to-back divide | pipeline or stall |
| too few regfile ports | two writes same cycle | more ports or schedule |
| too few adders | `PC+4` and branch target | add adder |

Von Neumann bottleneck in pipeline = structural hazard.

Split I/D caches help because they avoid IF/MEM conflict and increase access bandwidth; not primarily for hit rate.

## 3. Data Hazards

### 3.1 Dependence Types

| Type | Meaning | Importance |
|---|---|---|
| RAW | read after write | true dependence |
| WAR | write after read | name/order dependence |
| WAW | write after write | output/order dependence |
| RAR | read after read | not a hazard |

### 3.2 Without Forwarding

Producer writes in WB, consumer reads in ID.

```text
add x5,...
sub x6,x5,...
```

May need up to 2-3 bubbles depending on regfile write/read timing.

Quiz 2 sequence without forwarding: **9 bubbles**:

```text
2->3:2, 3->4:2, 5->6:2, 6->7:2, 9->11:1
```

### 3.3 Forwarding Equations

EX/MEM to EX:

```text
EX/MEM.RegWr && EX/MEM.rd!=0 && EX/MEM.rd==ID/EX.rs1 -> ForwardA=EX/MEM
EX/MEM.RegWr && EX/MEM.rd!=0 && EX/MEM.rd==ID/EX.rs2 -> ForwardB=EX/MEM
```

MEM/WB to EX:

```text
MEM/WB.RegWr && MEM/WB.rd!=0 && MEM/WB.rd==ID/EX.rs1 -> ForwardA=MEM/WB
MEM/WB.RegWr && MEM/WB.rd!=0 && MEM/WB.rd==ID/EX.rs2 -> ForwardB=MEM/WB
```

If both match, newer EX/MEM wins. Never forward from `x0` or non-writing instr.

### 3.4 Load-Use Hazard

```asm
lw  x5,0(x1)
add x6,x5,x2
```

Load data ready after MEM, too late for next EX -> **1 bubble** with forwarding.

Compiler may place independent instr between them.

### 3.5 Compiler Scheduling Limits

Scheduling helps but is limited by:

- possible memory aliasing.
- unknown cache/memory latency.
- calls, branches, traps, volatile/I/O.

## 4. Control Hazards

==**Control hazard**==: correct next PC unknown or predicted wrong.

Branch penalty contribution:

$$
AddedCPI = BranchFreq \times MispredictRate \times Penalty
$$

No-prediction taken-branch case uses taken fraction instead of mispredict rate.

### 4.1 Resolution Stage -> Flush Count

| Branch resolved at | Penalty idea |
|---|---:|
| MEM | 3 bubbles |
| EX | 2 bubbles |
| ID | 1 bubble |
| IF via BTB+BHT | 0 if correct |

Textbook 3 vs class 2: textbook redirects fetch one stage later; class assumes EX can resteer sooner.

### 4.2 Penalty Examples

| Case | Calculation | Result |
|---|---|---|
| A57 no prediction, 20% branches, 15-cycle penalty | added CPI `0.2*15=3`; total `4` | branch stalls `3/4=75%` |
| Pentium 4, 20% branches, 2% mispred, 30-cycle penalty | `0.2*0.02*30` | 0.12 added CPI = 12% if base CPI=1 |

## 5. Branch Prediction

### 5.1 Static and Dynamic

| Method | Accuracy idea |
|---|---:|
| always not taken | 30-40% |
| backward taken, forward not taken | 60-70% |
| compiler/profile static | 65-90% |
| 1-bit BHT | 70-80% |
| 2-bit counter | 85-95% |
| correlated/2-level | 94-96% |
| tournament/TAGE-like | 96-99% |

Static useful rules:

- backward branch taken.
- forward `beq rs1,x0` often not taken in class quiz.

### 5.2 1-bit vs 2-bit BHT

1-bit loop issue: inner-loop branch often mispredicts on loop exit and first iteration next time.

2-bit counter:

| State | Predict | T -> | NT -> |
|---|---|---|---|
| SNT | NT | WNT | SNT |
| WNT | NT | WT | SNT |
| WT | T | ST | WNT |
| ST | T | ST | WT |

### 5.3 Untagged BHT

Why untagged:

- simple.
- fast IF access.
- low energy.
- cheap/cost-effective.

Cost: aliasing between branches.

### 5.4 Correlated / 2-Level

Uses recent branch history:

```text
GHR = shift register of recent outcomes
index = PC xor GHR   # common quiz answer
PHT[index] = 2-bit counter
```

Useful when branches are correlated, e.g., third branch depends on previous two outcomes.

### 5.5 BHT vs BTB vs RAS

| Structure | Predicts |
|---|---|
| BHT / direction predictor | taken/not-taken |
| BTB | target PC |
| RAS | return target |

Hard branch/jump targets:

- indirect `JALR` for switch jump table.
- virtual calls/function pointers.
- returns if RAS mismatch.

Switch vs if-chain:

- dense/continuous cases -> compiler may use jump table -> indirect `JALR`, fast but harder target prediction.
- sparse/few cases -> compiler may emit conditional branch chain; not necessarily faster than `if/else`.

## 6. Branch Target at ID Stage

Computing `PC+imm` in ID can help predicted-taken direct branches.

Not usually a strong modern design reason:

- BTB already gives target in IF.
- only helps direct branches, not indirect `JALR`.
- adds ID-stage adder/delay.

Future improvement focus: indirect branches and returns.

## 7. Control Signals in Pipeline

Control decoded in ID must move with its instruction.

| Stage | Data/control needed |
|---|---|
| EX | operands, imm, `ALUCtrl`, compare mode |
| MEM | ALU address/result, store data, `MemRW` |
| WB | ALU/mem/PC+4, `rd`, `RegWr`, `WBSel` |
