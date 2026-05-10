# Lec 4.3: Pipelined Implementation

## Exam Facts

- ==**Pipelining**==: overlap stages of consecutive instrs to **increase throughput** (NOT single-instr latency).
- 5 stages: ==**IF, ID, EX, MEM, WB**==.
- Ideal N-stage for n instrs: $T = (n + N - 1) \cdot T_{stage}$. **Fill/drain = N − 1**.
- Speedup limited by **slowest stage**, imbalance, pipeline-reg overhead, hazards.
- Scalar pipe CPI≈1; ==**superscalar CPI<1**==.
- Pipeline-friendly ISA: fixed/regular instr, simple formats, load/store, few addr modes.
- MIPS-without-interlocks failed mainly due to ==**compatibility/scalability**==, NOT non-competitive perf.
- EX needs ==**TWO adders**== (ALU + branch target).
- Pipeline regs: ==**IF/ID, ID/EX, EX/MEM, MEM/WB**== — store **ctrl + data + addr + reg designators**.
- ==**MEM/WB has least info**==; ==**ID/EX has most**==.
- ==In-order retirement at WB== ⇒ precise architectural state for traps. OoO precise state needs reorder buffer + commit.
- Hardest functional unit to pipeline: ==**integer divide**==.
- Quiz latencies (cyc): int **mul 3-5**, **div ~32**, **FADD 4**, **FMUL 5**, **FMA 5-6**, **FP→int 3-5**.
- Deep pipe (5→20): clock NOT 4× faster; ==**branch-misprediction↑, data-hazard↑, CPI↑, more pipeline regs**==.
- Long pipe less desirable when: frequent mispredictions / heavy data deps / freq I-cache misses / freq calls.
- Split L1I/L1D ⇒ avoid IF↔MEM struct hazard + double bandwidth.

## 1. Pipelining Concept

Like an assembly line: each stage works on a different instruction simultaneously.

> [!IMPORTANT] Pipelining is **throughput-driven**, not latency-driven. Single-instr latency may even **increase** by pipeline-reg overhead.

## 2. Five Stages

| Stage | Action |
|---|---|
| **IF** | Fetch using PC; compute `PC+4`; **branch prediction** |
| **ID** | Decode + read regs; sign-extend imm; generate control |
| **EX** | ALU op / addr calc / branch compare + target |
| **MEM** | Data cache R (load) or W (store) |
| **WB** | Write result to regfile |

> EX needs **two adders**: ALU + branch target (`PC+imm`).

### 2.1 Stages by Instr Type

| Type | Uses |
|---|---|
| B-type (BEQ…) | IF→ID→EX |
| S-type (SW…) | IF→ID→EX→MEM (no WB) |
| R / I-ALU / U / J | IF→ID→EX→WB |
| Load (LW…) | IF→ID→EX→MEM→WB |

> All 5 stages still clocked through (NOPs in unused stages).

## 3. Latency vs Throughput

If stages 100ps regfile r/w, 200ps else:

| Implementation | Max clock | Latency |
|---|---|---|
| Single-cycle | 1/800ps = 1.25GHz | 800ps |
| Multi-cycle | 1/200ps = 5GHz | varies |
| 5-stage pipe | 5GHz throughput | 5×200 = 1000ps |

Pipe wins on **throughput** (1 inst / 200ps).

## 4. Pipeline Speedup

$$\text{Speedup}=\frac{n\cdot T_{long}}{(n+N-1)\cdot T_{stage}}\xrightarrow{n\to\infty}\frac{T_{long}}{T_{stage}}$$

Ideal speedup ≈ N when stages balanced.

> [!IMPORTANT] Pipeline speedup limits: stage imbalance (slowest caps throughput), pipeline-reg delay, fill/drain (N−1), hazards.

## 5. Pipeline-Oriented ISA Design (RV)

- ==Fixed-length 32b instr== (16b w/ C-ext) → easy IF + ID.
- Few **regular formats** → decode + read regs in one step.
- **Load/store** is only mem access → addr in EX (3rd stage), DMem in MEM (4th).
- Simple instrs ⇒ few stages.

> CISC: x86 1–17B instr → cannot fetch+decode in one cycle (must decode to µops first).

## 6. Pipeline Lessons

1. Pipe boosts **throughput**, not latency.
2. Limited by **slowest stage**.
3. Multiple instrs in flight using different resources.
4. Ideal speedup ≈ N.
5. **Fill/drain** = N−1 cyc.
6. Avoid bubbles from data + control deps.

> Pipelining everywhere: DRAM, caches, FPU, GPU, network packets.

## 7. Long-Latency Ops & Retirement

Two options:
1. **Stall** at EX until done.
2. **Separate long-latency pipe** so subsequent indep instrs proceed.

> [!IMPORTANT]
> - In-order retirement at WB ⇒ precise architectural state.
> - RV avoids HW int-overflow trap ⇒ OoO retirement is viable.
> - OoO + precise state needs **reorder buffer + commit logic**.
> - Hardest to pipeline: ==**integer divide**==.

## 8. Pipeline Registers

| Register | Stores |
|---|---|
| **IF/ID** | fetched instr + PC |
| ==**ID/EX** (most info)== | regfile data, imm, decoded ctrl, rs1/rs2/rd, PC, PC+4 |
| **EX/MEM** | ALU result, store-data, branch target, MEM/WB ctrl, rd |
| ==**MEM/WB** (least info)== | mem data, ALU result, rd, WB ctrl |

> Carry **ctrl + data + addr + reg designators**. Same-cycle WB+ID of same reg: write 1st half / read 2nd half.

## 9. Hazards Preview (full in 4.4)

- **Structural**: HW resource conflict ⇒ split I/D cache.
- **Data**: producer not yet written ⇒ forwarding/bubble.
- **Control**: branch outcome unknown ⇒ predict + flush on miss.
