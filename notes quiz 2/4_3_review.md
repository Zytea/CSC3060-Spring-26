# Lec 4.3: Pipelined Implementation

## Exam Facts

- ==**Pipeline**==: improves **throughput**, NOT single-instr latency (may **increase** due to pipeline-reg overhead).
  - ==**5 stages**==: **IF → ID → EX → MEM → WB**.
  - ==**Ideal N-stage cycles**== = $n + N - 1$ for `n` instrs (drain = $N-1$).
  - **Speedup** = $\frac{n \cdot T_{long}}{(n+N-1) \cdot T_{stage}} \xrightarrow{n\to\infty} \frac{T_{long}}{T_{stage}} \le N$ (balanced).
  - ==**Scalar CPI ≈ 1**==; ==**CPI < 1** requires superscalar / multi-issue==.
  - **Loss sources**: slowest stage, imbalanced stages, pipeline-reg overhead, hazards, fill/drain.

- ==**Pipeline-friendly RISC-V**==: fixed 32b base, regular field positions, load/store-only memory, simple ALU/addressing.

- **Deep pipeline trap**: 5→20 stages ≠ 4× faster. Branch/data penalties grow; pipeline-reg overhead grows; CPI ↑. **Throughput** modest gain; **latency** does not improve.
  - **Bad for deep pipeline**: frequent branch mispred, heavy data deps, frequent I-cache miss.

- **Long-latency ops** (mul/div/FP): **stall** at EX/ID OR **separate iterative/pipelined FU** OR **OoO + ROB**.

- ==**In-order retirement at WB**==: ensures **precise architectural state** for traps. RV avoids int arith exceptions, so **OoO exec + in-order retirement** is viable.

- **Pipeline regs carry**: control bits, data, addresses, register designators.
  - ==**WB signals propagated**== (3 cy after ID): `rd`, `RegWr/WRen`, `WBSel`. **NOT** `ALUCtrl` (dies after EX).
  - **EX signals** (1 cy): `ALUOp/ALUCtrl, ASel, BSel, BrUn`.
  - **MEM signals** (2 cy): `MemRW`, `PCSel`, `BrEq/BrLt`.
  - ==**Pipeline regs least info**==: **MEM/WB** (only data + WB control).

- **Regfile trick**: write in 1st half of cycle, read in 2nd half → same-cycle WB→ID forwarding via regfile.

## 1. Timing & Latency vs Throughput

```text
Cycle:  1   2   3   4   5   6   7
I1:     IF  ID  EX  MEM WB
I2:         IF  ID  EX  MEM WB
I3:             IF  ID  EX  MEM WB
I4:                 IF  ID  EX  MEM WB
```

> [!IMPORTANT]
> ==**Pipeline raises throughput at the cost of (possibly) higher per-instr latency**==.
>
> Ideal speedup assumes balanced stages, ignores pipeline-reg OH + hazards. Short sequences lose to fill/drain.

==**Latency trap**==: single-cycle `lw` = 800 ps; pipelined `lw` = $5 \times 200 = 1000$ ps (latency **worse**), but throughput = 1 instr/200 ps (4× better).

> Pipeline appears in DRAM (RAS/CAS/transfer), Cache (decode/way/tag/data), FP unit (align/op/norm/round), GPU (vertex/raster/fragment), network packets.

## 2. Five Stages

| Stage      | **IF**             | **ID**                          | **EX**             | **MEM**          | **WB**           |
| ---------- | ------------------ | ------------------------------- | ------------------ | ---------------- | ---------------- |
| **Work**   | fetch + next-PC    | decode, read regs, imm, control | ALU / addr / br    | DMem R/W         | write `rd`       |

==**Last useful stage**==: Branch → **EX**; Store → **MEM**; R/I-ALU/U/J → **WB**; Load → **WB** (data).

> Even if an instr has no work in some stage, it **still occupies that slot**.

## 3. Pipeline Clock

Clock = `slowest stage + pipeline-reg overhead`.

==**Example**== (regfile R/W = 100 ps, IMem/ALU/DMem = 200 ps):

| Design        | single-cycle (`lw` = 800 ps) | multi-cycle (200 ps stage) | 5-stage pipeline (200 ps stage) |
| ------------- | ---------------------------- | -------------------------- | ------------------------------- |
| **Max clock** | 1.25 GHz                     | 5.0 GHz                    | ≈ 5.0 GHz                       |

## 4. Single-Cycle vs Multi-Cycle vs Pipeline

| Design             | **single-cycle** | **multi-cycle**       | **pipeline**                    |
| ------------------ | ---------------- | --------------------- | ------------------------------- |
| **Latency**        | 1 long cycle     | several short cycles  | 5 short stages (≥ single-cycle) |
| **Throughput**     | 1/long           | variable              | ≈ 1 / short cycle (after fill)  |
| **Clock**          | low              | high                  | high                            |

> Quiz: vs pipelined, single-cycle has **lower CPI (1)** + **simpler control** but **lower throughput + slower clock**.

## 5. Why RISC-V Helps Pipelining

- **Fixed 32b fetch** → simple IF (vs x86 1–17 byte).
- **`rs1, rs2, rd` fixed positions** → regfile read can start in IF/early-ID.
- **Load/store-only memory** → only MEM stage accesses DMem.
- **Simple ALU + addressing** → clean EX stage.
- Address calc in EX (stage 3), mem in MEM (stage 4); memory-operand ISAs would need extra stages.

> Variable-length / memory-operand ISAs need **complex front-ends + μop translation**.

## 6. Pipelined Datapath & Regfile Trick

==**Regfile trick**==: **write 1st half**, **read 2nd half** → same-cycle WB→ID forwarding via regfile.

> [!NOTE]
> ==**Bug to avoid**==: do NOT use the **current ID instr's `rd`** as WB target. Correct `rd` is carried in **MEM/WB** pipeline reg. Using `IF/ID.rd` writes the YOUNGER instr's reg.

## 7. Long-Latency Ops & Retirement

==**Three options**== for mul/div/FP:

1. **Stall** at ID/EX (simple, costly).
2. **Separate iterative/pipelined FU** (younger ops continue).
3. **OoO core**: younger ops exec, **retire in-order via ROB**.

==**Precise trap**==: arch state looks as if all OLDER completed + NO younger completed.

> ==**Why RV64IFD avoids int arith exceptions**==: enables aggressive OoO + late retirement. Compare with ISAs that trap on every int overflow.

## 8. Pipeline Registers

| Reg          | Carries                                                                                       |
| ------------ | --------------------------------------------------------------------------------------------- |
| **IF/ID**    | instr bits, PC, predicted-PC                                                                  |
| **ID/EX**    | `R[rs1]`, `R[rs2]`, imm, PC, `rd`, `rs1/rs2` desigs, EX/MEM/WB control                        |
| **EX/MEM**   | ALU result, store-data (`rs2`), branch info (taken/target), `rd`, MEM/WB control              |
| **MEM/WB**   | mem-data, ALU result, `PC+4`, `rd`, WB control                                                |

> Quiz: ==**MEM/WB has least stored info**== (data + WB control only).

## 9. Control Signals in Pipeline

Decoded in **ID**, propagated forward:

| Stage      | **EX** (1 cy)                          | **MEM** (2 cy)              | **WB** (3 cy)             |
| ---------- | -------------------------------------- | --------------------------- | ------------------------- |
| **Signals**| `ASel/BSel`, `ALUCtrl`, `BrUn`         | `MemRW`, `PCSel`, `BrEq/BrLt` | `RegWr/WRen`, `WBSel`, `rd` |

==**Quiz**==: signals propagated to WB = `Rd`, `WRen`, `WBSel`. **NOT** `ALUCtrl` ❌ (dies after EX).

## 10. Hazards Preview

| Hazard            | Cause                                          | Fix                                              |
| ----------------- | ---------------------------------------------- | ------------------------------------------------ |
| ==**Structural**==| resource conflict (unified mem for IF/MEM)     | duplicate / pipeline / split I/D cache           |
| ==**Data**==      | value not ready in time                        | forwarding, stall, scheduling, OoO               |
| ==**Control**==   | next-PC unknown / wrong                        | prediction, BTB/BHT/RAS, flush                   |

> Detail in [4_4_review.md](4_4_review.md).
