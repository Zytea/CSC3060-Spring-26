# 4.4 Pipeline Hazards

## Exam Facts

- Three hazards: **structural, data, control**. "Forward hazard" is not a hazard type.
- Actual CPI = ideal CPI + stall cycles per instruction.
- Branch prediction should be as early as possible: **IF** in modern pipelines; if IF is absent, choose earliest available stage.
- Hardware data-hazard reduction: **forwarding/bypassing**; software: **instruction scheduling**.
- Control-hazard reduction: **BHT, BTB, static/dynamic prediction**.
- BHT often untagged because it is **simple, fast, low energy, cost-effective**.
- Correlated predictor index uses **PC xor global history**.
- 1-bit loop predictor often mispredicts twice per inner loop; 2-bit changes only after 2 misses.

## Structural Hazards

==**Structural hazard**==: two pipeline stages need same hardware resource in same cycle.
- Von Neumann shared instruction/data memory bottleneck behaves like structural hazard.
- Split L1I/L1D avoids IF vs MEM conflict and increases cache bandwidth.
- Early WB can create structural hazards if regfile ports/timing cannot support it.

## Data Hazards

==**Data hazard**==: needed value not produced/written yet.
- RAW = true dependence; must preserve.
- WAR = anti-dependence; in simple in-order 5-stage usually not a real hazard, but matters in scheduling/OoO.
- WAW = output dependence; matters with OoO/multiple writers.
- Load-use hazard may still need 1 bubble even with forwarding.

Forwarding conditions:
- EX hazard: `EX/MEM.RegWr && EX/MEM.Rd!=0 && EX/MEM.Rd == ID/EX.Rs1/Rs2`.
- MEM hazard: `MEM/WB.RegWr && MEM/WB.Rd!=0 && MEM/WB.Rd == ID/EX.Rs1/Rs2`.
- Do not forward from instructions that do not write, or to/from `x0`.

Quiz pattern:
- Without forwarding, consumer may wait until producer WB -> often 2 bubbles between adjacent ALU deps.
- With forwarding, ALU-ALU deps can be 0 bubbles; load-use often 1 bubble.

## Compiler Scheduling

- Reorder independent instructions to fill bubbles.
- Limitations: unknown memory aliasing, unpredictable memory latency, branch/call boundaries.
- For linked lists/trees/hash chains: use arrays/contiguous data, B/B+ trees, open addressing, batch independent streams.

## Control Hazards

- Branches are frequent (~15-30%); late resolution is expensive.
- If branch resolved in MEM, penalty can be 3 flushed inst; if EX, often 2.
- Penalty estimate: loss CPI $\approx f_{branch}\cdot f_{mispredict/taken}\cdot penalty$; slowdown = loss/base CPI.
- A57-like no prediction with 20% branches and late 15-cycle penalty gives large penalty (~75% in quiz).
- Computing `PC+imm` in ID helps predicted-taken branches only if target is not already predicted; modern BTB+BHT predicts both **where** and **whether**, so extra ID adder may not pay off.

Prediction:
- static: backward branches taken; forward fall-through/not taken.
- dynamic: BHT/PHT counters, BTB target prediction, return address stack for returns.
- BTB predicts **where**; BHT predicts **whether**.
- Hard cases: indirect branch for switch/virtual calls, returns.

## Branch Predictors

- 1-bit: predict last outcome.
- 2-bit saturating counter: strongly/weakly taken/not taken; changes direction after 2 wrong outcomes.
- Correlated/2-level: global history + PC indexes PHT; quiz answer: **current PC xor global history**.
- Untagged BHT can alias but is fast/simple.

## Control Signals in Pipeline

- WB-stage propagated signals: **`rd`, `RegWr`, `WBsel`**.
- Pipeline registers carry both control and data; control usually generated in ID and flows down pipeline.
