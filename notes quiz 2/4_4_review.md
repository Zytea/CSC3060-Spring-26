# Lec 4.4: Pipeline Hazards

## Exam Facts

- Three pipeline hazards: ==**structural, data, control**==. **Forward hazard** is not one of them.
- Actual CPI:

$$
CPI_{actual}=CPI_{ideal}+Stall\ Cycles\ per\ Instruction
$$

- Branch stall contribution:

$$
Stall\ Cycles = Branch\ Frequency \times Mispredict\ Rate \times Penalty
$$

- Structural hazards come from insufficient hardware resources: unified I/D memory, non-pipelined divider, not enough regfile ports/write ports.
- Data-hazard fixes: hardware forwarding/bypassing, stalls/interlocks, OoO, compiler scheduling.
- Load-use hazard usually still needs **1 bubble** even with forwarding.
- Control-hazard fixes: predict/not-taken, static prediction, BHT, BTB, RAS, early branch resolution.
- `BHT` predicts **whether** branch is taken. `BTB` predicts **where** the target is. `RAS` predicts returns.
- Untagged BHT: simple, fast, low energy, cheap, but aliases.
- Hard target prediction: indirect `JALR` from switch/vtable/function pointer. Returns are helped by RAS.
- Modern high-performance cores use dynamic predictors + BTB; static-only is not plausible.

## 1. Hazard Overview

Pipelines lose efficiency due to:

- fill and drain.
- unbalanced stage delays.
- structural hazards.
- data hazards.
- control hazards.

Hazards often stall at ID or flush younger wrong-path instrs, inserting bubbles.

## 2. Structural Hazards

==**Structural hazard**==: two pipeline stages need the same hardware resource in the same cycle.

### 2.1 Causes

| Cause | Example |
|---|---|
| unified instr/data memory | IF wants instr while MEM wants data |
| non-pipelined long FU | back-to-back divides contend for divider |
| too few regfile ports | early R-type WB conflicts with normal load WB |
| too few adders | PC+4 and branch target need adders at same time |
| complex ISA side effects | post-increment load needs two writes |

Von Neumann bottleneck in a pipeline is a structural hazard.

### 2.2 Fixes

| Fix | Example |
|---|---|
| duplicate/split resources | separate I-cache and D-cache |
| add ports | 2R/1W scalar regfile, more ports for superscalar |
| pipeline long FU | pipelined multiplier/divider |
| stall | hold younger instr until resource free |
| scheduling | separate resource-conflicting instrs |
| ISA simplicity | no post-increment load, no memory operands for ALU |

> R-type early writeback can create a structural hazard by competing with a normal WB-stage write. Do not assume "earlier WB" is always free.

## 3. Data Hazards

==**Data hazard**==: an instr needs a value that an older instr has not produced or made available yet.

| Dependence | Name | Meaning |
|---|---|---|
| RAW | read after write | true dependence, common pipeline hazard |
| WAR | write after read | anti-dependence, important for scheduling/OoO |
| WAW | write after write | output dependence, important for scheduling/OoO |

Example:

```asm
add x9,x0,x1
sub x10,x9,x3
```

`sub` reads `x9` before `add` has written it unless the pipeline stalls or forwards.

### 3.1 Without Forwarding

If consumer reads in ID and producer writes in WB:

```text
producer: IF ID EX MEM WB
consumer:    IF ID(stall) ID(stall) ID(stall) EX ...
```

Worst simple answer: consumer may need **3 bubbles** until producer writes back, depending on register-file write/read timing.

### 3.2 Register File Half-Cycle Trick

If regfile writes in first half of cycle and reads in second half, an instr in WB can satisfy an instr in ID in the same cycle. This reduces one apparent bubble compared with a strict full-cycle model.

### 3.3 Forwarding / Bypassing

==**Forwarding**== sends a produced value directly from a later pipeline register to an EX input without waiting for regfile WB.

Forward from EX/MEM when older instr result is just produced by ALU:

```text
if EX/MEM.RegWr
and EX/MEM.rd != 0
and EX/MEM.rd == ID/EX.rs1 -> ForwardA = EX/MEM

if EX/MEM.RegWr
and EX/MEM.rd != 0
and EX/MEM.rd == ID/EX.rs2 -> ForwardB = EX/MEM
```

Forward from MEM/WB:

```text
if MEM/WB.RegWr
and MEM/WB.rd != 0
and MEM/WB.rd == ID/EX.rs1 -> ForwardA = MEM/WB

if MEM/WB.RegWr
and MEM/WB.rd != 0
and MEM/WB.rd == ID/EX.rs2 -> ForwardB = MEM/WB
```

Corner cases:

- do not forward from instrs that do not write a register.
- do not forward to/from `x0`.
- if both EX/MEM and MEM/WB match, newer EX/MEM value wins.

### 3.4 Load-Use Hazard

For:

```asm
lw  x5,0(x1)
add x6,x5,x2
```

Load data becomes available after MEM, too late for immediately following EX. Even with forwarding, insert **1 bubble**:

```asm
lw  x5,0(x1)
nop
add x6,x5,x2
```

Compiler can schedule an independent instr into that bubble if one exists.

### 3.5 Compiler Scheduling

MIPS originally meant "Microprocessor without Interlocked Pipeline Stages": compiler inserted reordering/NOPs.

Modern cores have interlocks, but compiler scheduling still reduces stalls.

Limits:

- unknown memory aliasing.
- unknown memory/cache latency.
- branches, indirect jumps, calls/returns limit scheduling scope.
- traps/speculation constraints.

## 4. Control Hazards

==**Control hazard**==: pipeline does not know correct next PC because of branch/jump.

Frequent: about 15-30% of instrs may be branches, often one branch per 4-5 instrs.

### 4.1 Resolution Stage and Flush Penalty

If branch outcome/target available at MEM, wrong-path instrs in earlier stages may be flushed. If available at EX, fewer flushes.

| Branch resolved at | Typical taken/mispredict penalty idea |
|---|---:|
| MEM | about 3 flushed younger instrs |
| EX | about 2 flushed younger instrs |
| ID | about 1 flushed younger instr |
| IF via BTB + predictor | 0 if predicted correctly |

Textbook discrepancy: some diagrams count 3 bubbles because branch result is available at end of EX and redirect affects next fetch later; class may count 2 if redirect/resteer can occur sooner.

### 4.2 Branch Penalty CPI

If no prediction, all taken branches flush:

```text
Added CPI = branch_fraction * taken_fraction * penalty
```

Examples:

| Case | Calculation | Result |
|---|---|---|
| branch 20%, 50% taken, MEM penalty 3 | `0.2*0.5*3` | `0.3` added CPI |
| branch 20%, 50% taken, EX penalty 2 | `0.2*0.5*2` | `0.2` added CPI |
| ARM A57 16 stages, no prediction, 20% branches, 15-cycle penalty | added CPI `0.2*15=3`; total CPI `4` | branch stalls are `3/4=75%` of time |
| Pentium 4 31 stages, 20% branches, 2% mispred, 30-cycle penalty | `0.2*0.02*30` | `0.12` added CPI |

> Be clear whether the question asks added CPI or performance-loss fraction. A57's 75% comes from branch stalls `3` cycles out of total `1+3`.

## 5. Branch Prediction

| Method | Accuracy idea |
|---|---:|
| always fall-through / not taken | 30-40% |
| backward taken, forward not taken | 60-70% |
| compiler static | 65-90% |
| profile-guided static | 80-90% |
| 1-bit BHT | 70-80% |
| 2-bit saturating counter | 85-95% |
| global correlated / 2-level | 94-96% |
| local 2-level | 93-97% |
| tournament | 96-97% |
| TAGE-like | 97-99% |

### 5.1 Predict Not Taken

Fetch `PC+4`. If branch is taken, flush wrong fall-through instrs and fetch target. Correct not-taken branches have no penalty.

### 5.2 Static Prediction

Rules:

- backward branch taken: loop back edges likely taken.
- forward branch not taken: compiler often arranges fall-through as common path.
- ISA or encoding may include prediction hints in some architectures.

### 5.3 BHT

==**BHT**==: Branch History Table, indexed by PC bits, stores recent taken/not-taken behavior.

1-bit BHT issue for nested loops: inner loop branch mispredicts twice per outer iteration:

- last inner iteration: predicted taken but should fall through.
- first inner iteration next time: predicted not taken but should take.

2-bit saturating counter changes prediction only after two consecutive misses:

| State | Prediction | On taken | On not taken |
|---|---|---|---|
| strongly NT | NT | weakly NT | strongly NT |
| weakly NT | NT | weakly T | strongly NT |
| weakly T | T | strongly T | weakly NT |
| strongly T | T | strongly T | weakly T |

Untagged BHT uses low PC bits only. Pros: simple, fast, low power/cost. Cons: aliasing between different branches.

### 5.4 Correlated / 2-Level Prediction

==**Correlated prediction**== uses recent global/local branch history to predict current branch.

Components:

- GHR/GHB: shift register of recent branch outcomes.
- PHT: table of 2-bit counters indexed by GHR, PC, or hash of both.

Example:

```c
if (a==2) a=0;
if (b==2) b=0;
if (a!=b) ...
```

If first two branches both taken, third likely not taken. History pattern predicts it better than per-branch 1-bit history.

### 5.5 Whether vs Where: BHT, BTB, RAS

| Structure | Predicts |
|---|---|
| BHT / direction predictor | whether taken |
| BTB | where target address is |
| RAS | return target for call/return nesting |

==**BTB**==: Branch Target Buffer, a cache from branch PC to target address. In IF, if BTB hit and direction predicts taken, fetch target immediately.

Hard cases:

- indirect `JALR` target from function pointer.
- virtual function dispatch/vtable.
- switch jump table.
- returns if RAS underflow/mismatch, but RAS usually helps.

## 6. Branch Target at ID Stage

If `PC+imm` can be computed in ID, predicted-taken branches can redirect earlier.

Why not always a great modern choice:

- modern BTB already supplies target in IF.
- ID-stage target only helps direct branches, not indirect `JALR`.
- adds ID-stage delay/complexity.
- branch direction may still be unavailable.

## 7. Control Signals in Pipeline

Control decoded in ID must be carried to later stages.

| Stage | Data | Control |
|---|---|---|
| ID | `rs1/rs2`, imm, `rd` | immediate select, decoded EX/MEM/WB controls |
| EX | operand values, PC, imm | `ASel`, `BSel`, `ALUSel`, compare signed/unsigned |
| MEM | ALU addr/result, store data | `MemRW`, branch/jump decision |
| WB | ALU result, memory data, `PC+4`, `rd` | `WBSel`, `RegWr` |

Timing:

- EX controls used 1 cycle after decode.
- MEM controls used 2 cycles after decode.
- WB controls used 3 cycles after decode.
- `rd` must be passed to WB; it is not the current ID-stage `rd`.
