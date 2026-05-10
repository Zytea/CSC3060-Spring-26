# Lec 4.3: Pipelined Implementation

## Exam Facts

- ==**Pipelining**== overlaps stages of consecutive instructions to **increase throughput** (NOT single-instruction latency).
- 5 stages: ==**IF, ID, EX, MEM, WB**==.
- Ideal N-stage pipeline for n instructions: $T = (n + N - 1) \times T_{stage}$. **Fill/drain cost = N − 1**.
- Speedup is limited by **slowest stage** (imbalance), pipeline-register overhead, fill/drain, hazards.
- Scalar pipeline CPI ≈ 1; superscalar pipeline can have **CPI < 1**.
- **Pipeline-friendly ISA**: fixed/regular instr length, simple formats, load/store memory access, few addressing modes.
- MIPS (no Interlocks) "failed" mainly due to **compatibility & scalability**, NOT non-competitive performance.
- EX stage of RV32I pipeline needs **TWO adders**: ALU (compute / address) + branch-target adder.
- Pipeline registers: ==**IF/ID, ID/EX, EX/MEM, MEM/WB**==. Each stores **control signals + data + addresses + register designators**.
- **MEM/WB has the least info** (just final write data + rd + RegWr).
- **In-order retirement at WB** ⇒ precise architectural state for traps (even if later instr finishes EX sooner).
- **OoO precise state** needs reorder buffer + commit logic.
- Hardest functional unit to pipeline: ==**integer divide**== (long, iterative, hard to break into stages).
- Quiz operation latencies (cycles): int **mul 3-5**, int **div ~32**, **FADD 4**, **FMUL 5**, **FMA 5-6**, **FP→int 3-5**.
- Deep pipeline (5→20): clock NOT 4× faster; **branch-misprediction ↑, data-hazard penalty ↑, CPI ↑, more pipeline regs**.
- Long/deep pipeline less desirable when: **frequent branch mispredictions, heavy data deps, frequent I-cache misses, frequent procedure calls**.
- Split L1I/L1D ⇒ removes IF↔MEM structural hazard + increases bandwidth.

## 1.1 Pipelining Concept

Like an assembly line: each stage works on a different instruction simultaneously.

> [!IMPORTANT] Pipelining is **throughput-driven**, not latency-driven. Single-instruction latency may even **increase** by pipeline-register overhead.

## 1.2 Five Stages

| Stage | Action |
|---|---|
| **IF** | Fetch from IMem using PC; compute `PC + 4`; branch prediction |
| **ID** | Decode + read regs; sign-extend imm; generate control |
| **EX** | ALU op / address calc / branch compare / branch target |
| **MEM** | Data cache read (load) or write (store) |
| **WB** | Write result back to regfile |

> EX needs **two adders**: ALU output + branch target (`PC + imm`). One alone would be a structural hazard.

### What instr uses what stages?

| Instr type | Uses |
|---|---|
| B-type (BEQ…) | IF→ID→EX (compare + PC update) |
| S-type (SW…) | IF→ID→EX (addr) →MEM (write); no WB |
| R-type / I-ALU / U / J | IF→ID→EX→ (—) →WB |
| Load (LW…) | IF→ID→EX (addr) →MEM→WB |

> All 5 stages still **clocked through** for every instruction in the actual pipeline (NOPs in unused stages); the table above shows where the meaningful work happens.

## Instruction Timing Example

If stages: 100 ps regfile r/w, 200 ps everything else:

| Implementation | Max clock |
|---|---|
| Single-cycle | 1 / **800 ps** = 1.25 GHz (slowest path) |
| Multi-cycle | 1 / **200 ps** = 5 GHz (slowest stage) |
| Pipelined (5-stage) | 1 / 200 ps = 5 GHz throughput; latency = 5×200 = **1000 ps** |

Single-cycle latency 800 ps; pipeline latency 1000 ps. Pipeline wins on **throughput** (1 inst / 200 ps).

## Pipeline Speedup Formula

$$\text{Speedup} = \frac{T_{\text{single}}}{T_{\text{pipe}}} = \frac{n \cdot T_{\text{long}}}{(n+N-1)\cdot T_{\text{stage}}}\to \frac{T_{\text{long}}}{T_{\text{stage}}}\;\text{as}\; n\to\infty$$

Ideal speedup ≈ N (number of stages) when stages are balanced.

> [!IMPORTANT] Pipeline speedup limits:
> - Stage imbalance (slowest stage caps throughput).
> - Pipeline-register delay & setup overhead.
> - **Fill / drain time = N − 1 cycles**.
> - Hazards (data, control, structural) → bubbles.

## 1.4 Pipeline-Oriented ISA Design (RV)

- ==Fixed-length 32b instructions== (16b w/ C-ext) → easy IF + ID.
- Few **regular formats** → decode + read regs in ONE step.
- **Load/store** is the only memory access → addr in EX (3rd stage), DMem in MEM (4th).
- Simple instructions ⇒ few stages.

> CISC failure example: x86 1–17 byte instructions → impossible to fetch+decode in one cycle (must decode to µops first).

## 1.5 Pipeline Lessons

1. Pipeline boosts **throughput**, not latency.
2. Throughput limited by the **slowest stage**.
3. **Multiple instructions in flight** using different resources.
4. Ideal speedup ≈ N (number of stages).
5. **Fill/drain** time hurts (N − 1 cycles).
6. Avoid **bubbles** from data + control dependencies.

> Pipelining everywhere: DRAM, caches, FPU, GPU vertex/raster, network packet pipelines.

## 2.1 Pipelined Datapath: Pipeline Registers

| Register | Stores |
|---|---|
| **IF/ID** | fetched instruction + PC |
| **ID/EX** | regfile data (rs1, rs2), imm, decoded control, rs1/rs2/rd designators, PC, PC+4 |
| **EX/MEM** | ALU result, store-data (rs2 forwarded), branch target, MEM/WB control, rd |
| **MEM/WB** | mem-read data, ALU result, rd, WB control |

> [!IMPORTANT]
> - Pipeline regs carry **control + data + addresses + register designators**.
> - **MEM/WB stores least** (just final write data + rd + WBsel + RegWr).
> - Same-cycle WB write + ID read of same register: **write in 1st half-cycle, read in 2nd half-cycle**.

## 2.2 Long-Latency Ops & Retirement

Two options for long-latency ops (multiply, divide, FP):

1. **Stall** at EX until done.
2. **Separate long-latency pipeline** so subsequent independent instructions proceed.

> [!IMPORTANT]
> - **In-order retirement at WB** ⇒ precise architectural state for traps (even if later add finishes before earlier divide).
> - RV avoids hardware integer-overflow traps ⇒ OoO retirement is viable.
> - OoO + precise state needs **reorder buffer + commit logic**.

## Hazards in Pipeline (preview — full coverage in 4.4)

- **Structural**: HW resource conflict (e.g., shared I/D mem) ⇒ split I/D cache.
- **Data**: producer not yet written ⇒ forwarding / bubble.
- **Control**: branch outcome unknown ⇒ predict + flush on miss.
