# Lec 4.3: Pipelined Implementation

## Exam Facts

- Pipeline improves **throughput**, not single-instruction latency. A pipelined instruction may have larger latency due to pipeline-register overhead.
- 5 stages: **IF, ID, EX, MEM, WB**.
- Ideal N-stage pipeline for n instrs: total cycles = `n + N - 1`; fill/drain cost = `N-1`.
- Pipeline speedup limited by slowest stage, stage imbalance, pipeline-register overhead, hazards, and fill/drain.
- Scalar pipeline has ideal CPI about 1. Superscalar pipeline can have CPI < 1.
- RISC-V is pipeline-friendly: fixed 32b instrs (except C), regular fields, load/store ISA, simple formats.
- Deep pipeline 5 -> 20 does not give 4x clock: more pipeline regs, branch/data penalties, and imbalance.
- Deeper pipeline is worse with frequent branch mispredictions, heavy data dependences, and frequent I-cache misses. Frequent memory ops/procedure calls alone are not the key answer.
- Long-latency ops can stall EX or use separate pipelined/iterative FUs.
- Simple in-order pipeline retires in order at WB; precise traps require architectural state update in program order.
- Pipeline regs must carry **data, PC/addresses, immediates, register designators, and control signals**.

## 1. Pipeline Timing Formulas

Let `n` = number of instrs, `N` = pipeline stages.

| Design | Time idea |
|---|---|
| single-cycle | `n * T_long`, where `T_long` is slowest instr delay |
| multi-cycle | `sum CPI(i) * T_stage_long` |
| ideal N-stage pipeline | `(n + N - 1) * T_stage_long` |

Pipeline speedup:

$$
Speedup=\frac{nT_{long}}{(n+N-1)T_{stage}}
$$

For large `n` and balanced stages, speedup approaches `T_long/T_stage`, ideally about `N`.

> If comparing pipeline to multi-cycle, ideal speedup is roughly average multi-cycle CPI, not necessarily number of stages.

## 2. Pipelining

==**Latency**==: time for one instruction/task to finish.

==**Throughput**==: completed instructions/tasks per unit time.

Pipeline overlaps different stages of different instrs:

| Cycle | Instr 1 | Instr 2 | Instr 3 | Instr 4 |
|---:|---|---|---|---|
| 1 | IF | | | |
| 2 | ID | IF | | |
| 3 | EX | ID | IF | |
| 4 | MEM | EX | ID | IF |
| 5 | WB | MEM | EX | ID |
| 6 | | WB | MEM | EX |
| 7 | | | WB | MEM |
| 8 | | | | WB |

## 3. Five Stages of Simple Datapath

| Stage | Name | Work |
|---|---|---|
| IF | instruction fetch | fetch instr using PC; predict/select next PC |
| ID | decode/register read | decode fields, read `rs1/rs2`, generate control/imm |
| EX | execute | ALU op, address calc, branch compare/target |
| MEM | memory | data cache read/write |
| WB | writeback | write `rd` from ALU/memory/`PC+4` |

### 3.1 Stages by Instruction Type

| Instr type | Effective useful stages |
|---|---|
| B-type branch | IF, ID, EX |
| S-type store | IF, ID, EX, MEM |
| R-type ALU | IF, ID, EX, WB; MEM stage has no useful work but slot advances |
| I-type ALU | IF, ID, EX, WB |
| load | IF, ID, EX, MEM, WB |
| JAL | IF, ID, EX, WB for `PC+4` link |
| U-type | IF, ID, EX, WB |

In a pipeline, even if an instr has no useful work in a stage, it still occupies/flows through stage timing.

## 4. Divide Single-Cycle Datapath into 5 Stages

Example stage times:

| Stage work | Delay |
|---|---:|
| regfile read/write | 100 ps |
| memory or ALU stage | 200 ps |

Single-cycle `lw` might need about 800 ps -> max 1.25 GHz.

Pipeline/multi-cycle stage clock may be about 200 ps -> 5 GHz before overhead.

## 5. Single-Cycle vs Multi-Cycle vs Pipeline

| Design | Latency | Throughput |
|---|---:|---:|
| single-cycle | 1 long cycle, e.g. 800 ps | 1 instr / 800 ps |
| pipelined | 5 short cycles, e.g. 1000 ps | 1 instr / 200 ps after fill |

> Pipeline can make each instruction take longer in latency while improving completed instructions per second.

## 6. Pipeline-Oriented ISA Design

RISC-V helps pipelining:

- fixed 32b instrs in base ISA: easy fetch/decode.
- few regular formats: register fields in fixed positions.
- load/store ISA: only loads/stores access data memory.
- ALU ops use regs/immediates, not arbitrary memory operands.
- simple instrs reduce variable execution lengths.

Contrast x86: variable 1-17 byte instr length and many addressing modes make front-end decode harder.

## 7. Pipeline Lessons

- throughput gain, not latency gain.
- slowest stage limits clock.
- unbalanced stage lengths reduce speedup.
- pipeline register overhead reduces speedup.
- fill/drain hurts short instruction sequences.
- hazards create bubbles.
- I-cache misses and branch mispredictions increase fill/drain-like lost work.

Pipeline appears outside CPU core too: DRAM, caches, FP units, GPUs, network routers.

## 8. Pipelined RV32I Datapath

Within the same cycle, many teaching pipelines assume register file write in first half and read in second half, which can remove a WB/ID read-after-write bubble.

## 9. Long-Latency Operations and Retirement

Options for divide/FP/cache-miss-like long ops:

1. Stall following instrs at EX or earlier.
2. Use a separate pipelined/iterative FU so independent younger instrs can proceed.

In simple in-order pipelines, instructions retire/write architectural state in order, usually at WB. Out-of-order cores use reorder buffers to preserve precise traps.

> RISC-V avoids many arithmetic traps, but loads/page faults/illegal instrs still require precise architectural recovery.

## 10. Multiple Instructions On the Fly

Pipeline must carry the right instruction-specific metadata forward:

| Question | Correct source |
|---|---|
| Which `rd` to write? | instruction in WB, stored in MEM/WB |
| Which immediate to use in EX? | instruction in EX, stored in ID/EX |
| Which `rs1/rs2` values enter ALU? | values latched in ID/EX |
| Which control signals apply in MEM/WB? | control bits carried through pipeline regs |

## 11. Pipeline Registers

==**Pipeline register**==: sequential element inserted between stages to hold data/control for the next cycle.

| Register | Must carry |
|---|---|
| IF/ID | fetched instr, PC, maybe predicted PC |
| ID/EX | `rs1/rs2` values, imm, PC, `rd/rs` fields, EX/MEM/WB control |
| EX/MEM | ALU result, store data, branch info, `rd`, MEM/WB control |
| MEM/WB | memory data, ALU result, `PC+4`, `rd`, WB control |

Quiz: pipeline registers store **control, data, addresses, and register designators**.

## 12. Control Signals in Pipelined Datapath

Control is decoded in ID, but used later. Therefore control bits must travel with the instruction.

| Stage where used | Control examples |
|---|---|
| EX | `ALUSel`, `ASel`, `BSel`, `BrUn`, ALU control |
| MEM | `MemRW`, branch/jump PC select |
| WB | `RegWEn`, `WBSel`, `rd` designator |

Single-cycle mistake: using the `rd` in ID for WB. Correct pipeline uses `rd` carried to MEM/WB.

## 13. Hazards Preview

| Hazard | Cause | Typical fix |
|---|---|---|
| structural | same resource needed by multiple stages | duplicate/pipeline resource, split I/D cache |
| data | consumer needs producer result too soon | forwarding, stall, scheduling, OoO |
| control | next PC unknown/wrong | prediction, BTB/BHT, flush on miss |
