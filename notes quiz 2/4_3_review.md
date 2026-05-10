# 4.3 Pipelined Implementation

## Exam Facts

- ==**Pipelining**==: overlap different instructions in different stages to increase **throughput**, not single-instruction latency.
- 5 stages: **IF, ID, EX, MEM, WB**.
- Ideal N-stage time for n instructions: $(n+N-1)T_{stage}$; fill/drain cost = `N-1`.
- Pipeline speedup limited by **slowest stage**, imbalance, pipeline-reg overhead, hazards.
- CPI of simple scalar pipeline approaches 1; superscalar can be <1.
- Pipeline-oriented ISA: fixed/regular length, simple formats, load/store, few addressing modes.

## Five Stages

- **IF**: fetch instruction using PC; often compute `PC+4`.
- **ID**: decode, read regs, generate control, immediate.
- **EX**: ALU op, address calc, branch compare/target.
- **MEM**: data cache access for loads/stores.
- **WB**: write result to register file.

Pipeline registers: **IF/ID, ID/EX, EX/MEM, MEM/WB** store data, control signals, PC/addresses, register designators.

## Latency vs Throughput

- Latency: time for one instruction to finish; may increase with pipeline regs.
- Throughput: instructions completed per unit time; improves after pipeline fills.
- Example: single 800ps vs 5-stage 200ps: latency 1000ps but throughput 1 inst/200ps.

## Long-Latency Ops and Retirement

- Integer divide is hard to pipeline; often long latency.
- FP/multiply pipelines can allow later independent instructions to proceed.
- In-order retirement gives precise architectural state for traps.
- OoO/precise state requires reorder/commit logic.

## Pipeline Register Contents

- control signals for later stages;
- data values: reg operands, ALU results, memory data;
- addresses: PC, PC+4, target/memory address;
- register numbers: `rd`, sometimes `rs1/rs2` for hazard/forwarding.

## Quiz Traps

- Pipelining improves throughput, not latency.
- Single-cycle has CPI=1 but can be slower because clock is long.
- Split I/D cache avoids structural hazard and increases bandwidth.
- Deep pipelines increase branch misprediction and data-hazard penalties; more pipeline regs needed.
