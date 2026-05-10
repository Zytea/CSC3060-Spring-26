# Lec 4.3: Pipelined Implementation

## Exam Facts

- Pipeline improves **throughput**, not single-instr latency.
- 5 stages: **IF, ID, EX, MEM, WB**.
- Ideal N-stage pipeline for `n` instrs: cycles = `n + N - 1`.
- Ideal scalar pipeline CPI ~= 1; superscalar can have CPI < 1. Quiz phrase: **CPI lower than 1** -> superscalar.
- Speedup limited by slowest stage, imbalance, pipeline-register overhead, hazards, fill/drain.
- RISC-V is pipeline-friendly: fixed 32b base, regular fields, load/store ISA, simple formats.
- Deep 5 -> 20 stages is not 4x faster: more pipeline regs, branch/data penalties, stage imbalance.
- Deeper pipeline is less desirable with **frequent branch mispredictions, heavy data dependences, frequent I-cache misses**.
- Long-latency ops can stall or use separate pipelined/iterative FUs.
- In-order retirement preserves precise architectural state.
- Pipeline regs carry **control, data, addresses/PC, immediates, register designators**.

## 1. Pipeline Timing Formulas

Let `N` = stages, `n` = instrs.

| Design | Cycles/time idea |
|---|---|
| single-cycle | `n*T_long` |
| ideal pipeline | `(n+N-1)*T_stage` |

$$
Speedup=\frac{nT_{long}}{(n+N-1)T_{stage}}
$$

For large `n`, balanced pipeline speedup approaches `T_long/T_stage`, ideally `N`.

## 2. Pipelining

==**Latency**==: time for one instr/task to finish.

==**Throughput**==: completed instrs/tasks per time.

```text
Cycle: 1   2   3   4   5   6   7
I1:    IF  ID  EX  MEM WB
I2:        IF  ID  EX  MEM WB
I3:            IF  ID  EX  MEM WB
```

> [!IMPORTANT]
> Pipeline can increase instruction latency while improving instruction throughput.

## 3. Five Stages

| Stage | Work |
|---|---|
| IF | fetch instr; predict/select next PC |
| ID | decode, read regs, generate imm/control |
| EX | ALU, address calc, branch compare/target |
| MEM | data cache read/write |
| WB | write `rd` |

Even if an instr has no useful work in a stage, it still occupies the stage slot.

## 4. Divide Single-Cycle Datapath into 5 Stages

Pipeline clock is set by slowest stage + pipeline register overhead.

Example: single-cycle `lw` 800ps; pipeline stage 200ps -> higher throughput after fill, but one load latency about `5*200ps`.

## 5. Single-Cycle vs Multi-Cycle vs Pipeline

| Design | Latency | Throughput |
|---|---|---|
| single-cycle | 1 long cycle | 1 instr per long cycle |
| multi-cycle | several short cycles | variable |
| pipeline | 5 short stages | about 1 instr per short cycle after fill |

## 6. Pipeline-Oriented ISA Design

RISC-V helps because:

- fixed 32b base instr fetch.
- `rs1/rs2/rd` in fixed positions.
- load/store only memory data access.
- simple ALU/addressing modes.

Variable-length ISAs or memory-operand ISAs need more complex front-end/uop translation.

## 7. Pipeline Lessons

Pipeline losses:

- slowest stage dominates.
- unbalanced stages.
- pipeline register overhead.
- fill/drain for short sequences.
- structural/data/control hazards.
- I-cache miss empties front end and wastes fill work.

## 8. Pipelined RV32I Datapath

Register file teaching trick: write in first half, read in second half, so WB can feed ID in same cycle.

Do not use current ID instruction's `rd` for WB. The correct `rd` is carried in MEM/WB.

## 9. Long-Latency Ops and Retirement

Options:

1. stall pipeline at EX/ID until long op finishes.
2. use separate iterative/pipelined FU.
3. OoO core lets independent younger ops execute but retires in order using ROB.

Precise trap requirement:

```text
architectural state must look as if all older instrs completed and no younger instr completed
```

## 10. Multiple Instructions On the Fly

| Question | Stored where |
|---|---|
| current instr in EX | ID/EX |
| `rd` to write in WB | MEM/WB |
| ALU result for MEM | EX/MEM |
| WB select and RegWr | control bits carried forward |

## 11. Pipeline Registers

| Reg | Carries |
|---|---|
| IF/ID | instr, PC, predicted PC |
| ID/EX | `rs1/rs2` values, imm, PC, `rd/rs`, EX/MEM/WB control |
| EX/MEM | ALU result, store data, branch info, `rd`, MEM/WB control |
| MEM/WB | memory data, ALU result, `PC+4`, `rd`, WB control |

## 12. Control Signals in Pipeline

Control decoded in ID, used later:

| Stage | Control |
|---|---|
| EX | operand muxes, ALU control, branch compare mode |
| MEM | `MemRW`, branch/jump redirect |
| WB | `RegWr`, `WBSel` |

## 13. Hazards Preview

| Hazard | Cause | Fix |
|---|---|---|
| structural | resource conflict | duplicate/pipeline resource, split I/D cache |
| data | value not ready | forwarding, stall, scheduling, OoO |
| control | next PC unknown/wrong | prediction, BTB/BHT/RAS, flush |
