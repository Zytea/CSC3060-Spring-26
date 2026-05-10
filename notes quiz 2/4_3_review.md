# Lec 4.3: Pipelined Implementation

## Exam Facts

- ==**Pipelining**==: partition datapath into stages and overlap different instrs; improves **throughput**, not single-instr latency.
- 5 classic stages: ==**IF, ID, EX, MEM, WB**==.
- Ideal N-stage time for n instrs: $T=(n+N-1)T_{stage}$; fill/drain cost = `N-1`.
- Pipeline speedup is limited by slowest stage, pipeline-register overhead, hazards, and fill/drain.
- Scalar pipeline CPI about 1; superscalar can have CPI <1.
- Pipeline-friendly ISA: fixed/regular instrs, load/store design, few addressing modes.
- MIPS without interlocks failed mainly from **compatibility/scalability**, not raw performance.
- EX stage needs **two adders** in common RV datapath: ALU/address/compare path + branch target `PC+imm`.
- Pipeline regs store **control + data + addresses + register designators**.
- `ID/EX` usually has most info; `MEM/WB` least.
- In-order retirement at WB gives precise architectural state; OoO precise state needs reorder buffer/commit.
- Hardest common FU to pipeline: **integer divide**.
- Deep pipeline 5->20: clock not 4x faster; branch/data penalties, CPI, pipeline-register count increase.
- Deep pipeline less desirable for **frequent branch mispredictions, heavy data dependencies, frequent I-cache misses**. Ordinary memory ops/procedure calls alone are not enough.

## 1. Pipelining

Pipeline partitioning:

| Stage | Work |
|---|---|
| **IF** | fetch instr using PC; compute/choose next PC; branch prediction happens here |
| **ID** | decode; read `rs1/rs2`; generate imm/control |
| **EX** | ALU op, effective address, branch compare/target |
| **MEM** | data cache read/write for load/store |
| **WB** | write result to GPR |

> [!IMPORTANT]
> Pipelining can increase single-instr latency because the instr passes through all stages plus pipeline-register overhead. It improves completed instrs per time.

## 2. Five Stages by Instruction Type

| Instr type | Useful stages | Architectural result |
|---|---|---|
| B-type branch | IF, ID, EX | update PC if taken; no WB |
| S-type store | IF, ID, EX, MEM | write data memory; no WB |
| R/I ALU | IF, ID, EX, WB | write ALU result |
| U/J | IF, ID, EX, WB | write upper/PC+4 result |
| Load | IF, ID, EX, MEM, WB | write loaded data |

Even if a stage has no useful work, the pipeline slot still advances.

## 3. Latency vs Throughput

Example stage delays: regfile read/write 100 ps, other stages 200 ps.

| Impl | Clock | Single instr latency | Throughput |
|---|---:|---:|---:|
| Single-cycle | 800 ps | 800 ps | 1 instr / 800 ps |
| Multi-cycle | 200 ps | depends on stages | not overlapped |
| 5-stage pipe | 200 ps | about 1000 ps | 1 instr / 200 ps ideal |

## 4. Pipeline Speedup

$$
\text{Speedup}=\frac{nT_{single}}{(n+N-1)T_{stage}}\to\frac{T_{single}}{T_{stage}}\quad(n\to\infty)
$$

Ideal speedup near N only when stages are balanced and hazards absent.

## 5. Pipeline-Oriented ISA Design

RISC-V helps pipelining:

- Fixed 32b instrs, except optional C extension.
- Regular `rs1/rs2/rd` positions -> decode/read in ID.
- Load/store only -> address in EX, data memory in MEM.
- Simple operations -> no long microcoded paths for normal integer ops.

## 6. Pipeline Lessons

- More stages improve potential clock but increase branch/data penalty and register overhead.
- More pipeline registers are required as depth increases.
- Pipeline throughput can be hurt by structural, data, and control hazards.
- Split L1I/L1D avoids IF vs MEM structural conflict and doubles access bandwidth.

## 7. Long-Latency Ops and Retirement

Options for long ops:

1. Stall instruction in EX until FU completes.
2. Use separate pipelined/iterative FU so independent younger instrs can proceed.

Precise traps require architectural state to update in program order. In simple in-order pipelines, retirement/writeback order is in order. In OoO, use ROB/commit.

## 8. Pipeline Registers

| Register | Carries |
|---|---|
| `IF/ID` | fetched instr, PC/PC+4 |
| `ID/EX` | reg values, imm, PC/PC+4, decoded control, `rs1/rs2/rd` |
| `EX/MEM` | ALU result, store data, branch target/outcome, MEM/WB control, `rd` |
| `MEM/WB` | memory data, ALU result/PC+4, WB control, `rd` |

> Quiz: pipeline registers store **control, data, addresses, register designators**.

Same-cycle register-file convention: WB writes in first half, ID reads in second half, reducing apparent WB->ID hazard.

## 9. Hazards Preview

| Hazard | Meaning | Main fixes |
|---|---|---|
| Structural | same HW resource needed by two stages | duplicate/pipeline resource, split I/D cache |
| Data | consumer needs value before producer provides it | forwarding, stall, scheduling, OoO |
| Control | next PC unknown/wrong | prediction, BTB/BHT, flush on miss |
