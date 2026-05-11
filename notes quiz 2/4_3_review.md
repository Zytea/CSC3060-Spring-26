# Lec 4.3: Pipelined Implementation

## Exam Facts

- ==**Pipeline**==: improves **throughput**, NOT single-instr latency (latency may even **increase** due to pipeline reg overhead).
- ==**5 stages**==: **IF → ID → EX → MEM → WB**.
- ==**Ideal N-stage cycles**==: $n + N - 1$ for `n` instrs (drain = `N-1`).
- **Speedup**: $\frac{n \cdot T_{long}}{(n+N-1) \cdot T_{stage}}$; large `n` → ≈ $T_{long}/T_{stage}$ ≤ $N$ (balanced stages).
- ==**Scalar pipeline CPI**== ≈ **1**; ==**CPI < 1** requires superscalar / multi-issue==.
- **Speedup limits**: slowest stage, imbalanced stages, pipeline-reg overhead, hazards, fill/drain.
- ==**Pipeline-friendly RISC-V features**==: fixed 32b base instr, regular field positions (`rs1/rs2/rd`), load/store-only memory, simple ALU/addressing, simple decode.
- **Deep pipeline trap**: 5→20 stages is **NOT** 4× faster. Branch/data penalties grow; pipeline-reg overhead grows; CPI increases.
- **More stages → clock may improve, but**: branch misprediction penalty ↑, data hazard penalty ↑, pipeline-reg overhead ↑, CPI ↑. **Throughput** may improve modestly; **latency** usually does not.
- **Bad for deep pipeline**: frequent branch misprediction, heavy data deps, frequent I-cache miss.
- **Long-latency ops** (mul, div, FP): **stall** the pipeline at EX/ID **OR** use a **separate iterative/pipelined FU**.
- ==**In-order retirement at WB**==: ensures **precise architectural state** for traps. RISC-V avoids int arith exceptions, so **OoO execution but in-order retirement** is viable.
- **Pipeline regs carry**: control bits, data (ALU result/regs/imm), addresses (PC, PC+4, mem addr), register designators.
- ==**WB-stage signals propagated**==: `rd`, `RegWr/WRen`, `WBSel`. Used **3 cycles after** ID. **NOT** `ALUCtrl` (used in EX).
- **EX-stage signals (1 cycle later)**: `ALUOp/ALUCtrl, ASel, BSel, BrUn`.
- **MEM-stage signals (2 cycles later)**: `MemRW`, `PCSel`, `BrEq/BrLt` results.
- ==**Pipeline regs least info**==: among IF/ID, ID/EX, EX/MEM, MEM/WB → class answer is **MEM/WB** (only data + WB control).
- ==**Pipeline design principles**==: multi-stage partitioning, overlapped execution, increased throughput, improved resource utilization. **NOT lowered instr latency**.
- **Regfile trick**: write in 1st half of cycle, read in 2nd half → same-cycle WB→ID forwarding through the regfile.

## 1. Pipeline Timing Formulas

Let $N$ = pipeline stages, $n$ = instrs.

| Design | Cycles / Time |
|---|---|
| single-cycle | $n \cdot T_{long}$ |
| ideal pipeline | $(n + N - 1) \cdot T_{stage}$ |

$$
Speedup = \frac{n \cdot T_{long}}{(n+N-1) \cdot T_{stage}}; \quad \lim_{n \to \infty} = \frac{T_{long}}{T_{stage}} \le N
$$

> [!IMPORTANT]
> Ideal speedup assumes balanced stages and ignores pipeline-reg overhead + hazards. Short instr sequences lose to fill/drain.

==**Latency trap**==: single-cycle `lw` = 800 ps; pipelined `lw` = 5 × 200 ps = **1000 ps** (latency **worse**), but throughput = 1 instr/200 ps after fill (4× better).

## 2. Pipelining: Latency vs Throughput

==**Latency**==: time for **one** instr/task to finish.

==**Throughput**==: completed instrs/tasks **per unit time**.

```text
Cycle:  1   2   3   4   5   6   7
I1:     IF  ID  EX  MEM WB
I2:         IF  ID  EX  MEM WB
I3:             IF  ID  EX  MEM WB
I4:                 IF  ID  EX  MEM WB
```

> [!IMPORTANT]
> ==**Pipeline raises throughput at the cost of (possibly) higher per-instr latency**==.

> Pipeline appears in **many places** beyond CPU: DRAM (RAS/CAS/transfer), Cache (decode/way-select/tag/data), FP unit (align/op/normalize/round), GPU graphics pipeline (vertex/raster/fragment), network packet processing.

## 3. Five Stages

| Stage | Work |
|---|---|
| **IF** | fetch instr from IMem; predict / select next PC |
| **ID** | decode; read regs; gen imm + control; (may also resolve branch in some designs) |
| **EX** | ALU op; address calc; branch compare + target |
| **MEM** | DMem read/write |
| **WB** | write `rd` |

> Even if an instr has **no useful work** in some stage, it still **occupies that stage slot** in pipeline.

==**Useful end-stage by class**==:

| Instr | Last useful stage |
|---|---|
| Branch (`beq`, …) | **EX** (compare + target decision) |
| Store (`sw`, …) | **MEM** (memory write) |
| R-type / I-ALU / U / J | **WB** (write result / `PC+4`) |
| Load (`lw`, …) | **WB** (write loaded data) |

## 4. Divide Single-Cycle Datapath into 5 Stages

==**Pipeline clock**== set by `slowest stage + pipeline-reg overhead`.

==**Example**== (regfile R/W = 100 ps, IMem/ALU/DMem = 200 ps each):

| Design        | single-cycle (`lw` = 800 ps) | multi-cycle (200 ps stage) | 5-stage pipeline (200 ps stage) |
| ------------- | ---------------------------- | -------------------------- | ------------------------------- |
| **Max clock** | 1.25 GHz                     | 5.0 GHz                    | ≈ 5.0 GHz                       |

## 5. Single-Cycle vs Multi-Cycle vs Pipeline

| Design             | **single-cycle** | **multi-cycle**       | **pipeline**                    |
| ------------------ | ---------------- | --------------------- | ------------------------------- |
| **Latency**        | 1 long cycle     | several short cycles  | 5 short stages (≥ single-cycle) |
| **Throughput**     | 1/long           | variable              | ≈ 1 / short cycle (after fill)  |
| **Clock**          | low              | high                  | high                            |

> Quiz: vs pipelined, single-cycle has **lower CPI (1)** + **simpler control logic** but **lower throughput + slower clock**.

## 6. Pipeline-Oriented ISA Design (Why RISC-V Helps)

- **Fixed 32b base instr fetch** → simple IF (vs x86 1–17 byte instrs).
- **`rs1, rs2, rd` in fixed positions** → start regfile read in IF/early-ID.
- **Load/store-only memory** → exactly one stage (MEM) accesses data memory.
- **Simple ALU + addressing modes** → EX stage clean.
- Address calc in stage 3 (EX), memory access in stage 4 (MEM); if instrs had memory operands, would need extra stages.

> Variable-length / memory-operand ISAs need **complex front-ends + μop translation**.

## 7. Pipeline Lessons

==**Pipeline losses**==:

- Slowest stage dominates (unbalanced stages waste).
- Pipeline-register overhead.
- Fill / drain for short sequences.
- ==Structural / data / control hazards==.
- I-cache miss empties front end (wastes filled work).

> [!IMPORTANT]
> **Pipeline does NOT help latency of a single instr**, just throughput. Avoid bubbles from data + control deps.

## 8. Pipelined RV32I Datapath

==**Regfile trick**==: **write in first half** of cycle, **read in second half** → same-cycle WB→ID forwarding through the regfile (no extra mux for that case).

==**Bug to avoid**==: do **NOT** use the **current ID instruction's `rd` field** as the write target for WB. The correct `rd` for WB is the one carried in **MEM/WB** pipeline register.

```text
Same cycle: WB writes first half → ID reads second half.
Wrong: using IF/ID.rd for WB writes the YOUNGER instr's reg.
```

## 9. Long-Latency Ops & Retirement

==**Three options**== for long-latency (mul/div/FP) ops:

1. **Stall** at ID/EX until op finishes (simple but costly).
2. **Separate iterative / pipelined FU** (independent younger ops continue).
3. **OoO core**: independent younger ops execute, but **retire in-order via ROB** (reorder buffer).

==**Precise trap requirement**==:

```text
At trap, architectural state must look as if all OLDER instrs completed
and NO younger instr completed.
```

==**Why RV64IFD avoids int arith exceptions**==: makes aggressive OoO + late retirement easier. Compare with ISAs that trap on every int overflow.

## 10. Multiple Instructions On-the-Fly

| Question | Source |
|---|---|
| current instr in EX (operands, imm) | **ID/EX** |
| `rd` to write in WB | **MEM/WB** (NOT ID/EX!) |
| ALU result for MEM | **EX/MEM** |
| WBSel + RegWr for WB | carried in pipeline regs |

> Each pipeline reg "snapshots" one instr per stage. Order is preserved → in-order retirement.

## 11. Pipeline Registers

| Reg | Carries |
|---|---|
| **IF/ID** | instr bits, PC, predicted-PC |
| **ID/EX** | `R[rs1]`, `R[rs2]`, imm, PC, `rd` field, `rs1/rs2` desigs, EX/MEM/WB control bits |
| **EX/MEM** | ALU result, store-data (`rs2` value), branch info (taken/target), `rd`, MEM/WB control bits |
| **MEM/WB** | mem-data, ALU result, `PC+4`, `rd`, WB control bits |

> Quiz: among IF/ID, ID/EX, EX/MEM, MEM/WB → **MEM/WB has the least stored info** (only data + WB control).

## 12. Control Signals in Pipeline

Control decoded in **ID**, then propagated forward in pipeline regs. Each signal is used at the stage indicated:

| Stage | Signals (when used) | Decoded → used delay |
|---|---|---|
| **EX** | `ASel/BSel`, `ALUCtrl`, `BrUn` (operand sources, ALU op, signed/unsigned branch) | **1 cycle** after ID |
| **MEM** | `MemRW`, `PCSel`, `BrEq/BrLt` results | **2 cycles** after ID |
| **WB** | `RegWr/WRen`, `WBSel`, `rd` | **3 cycles** after ID |

==**Quiz #25 Q3**: which signals must propagate to WB? `Rd`, `WRen`, `WBsel`. **NOT** `ALUCtrl` (dies after EX).

## 13. Hazards Preview

| Hazard | Cause | Fix |
|---|---|---|
| ==**Structural**== | resource conflict (e.g., unified mem for IF/MEM) | duplicate / pipeline / split I/D cache |
| ==**Data**== | value not ready in time | forwarding/bypass, stall, scheduling, OoO |
| ==**Control**== | next-PC unknown / wrong | prediction, BTB/BHT/RAS, flush |

> Detail in [4_4_review.md](4_4_review.md).
