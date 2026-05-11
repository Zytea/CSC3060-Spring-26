# Lec 4.1: Processor Architecture & Logic Design

## Exam Facts

- ==**Microarchitecture**==: implementation of an ISA. Same ISA → many μarches with different cost/perf.
  - ==**Datapath**== ("brawn"): ALU, regfile, memory, muxes, adders.
  - ==**Control**== ("brain"): selects mux inputs, asserts write enables, decodes opcode.
  - **Execution cycle**: ==IF → ID → EX → MEM → WB==.
- ==**Iron Law**==: $\text{CPU Time} = IC \times CPI \times \text{Clock Cycle Time}$.
  - **Single-cycle**: ==**CPI = 1**==; clock = **slowest instr** (`lw`).
  - **Multi-cycle**: shorter clock, resource reuse, **CPI > 1**.
  - **Pipeline**: overlapped, **CPI ≈ 1**, throughput up; hazards add stalls.
  - ==**CPI < 1**==: only **superscalar / multi-issue**.
  - ==**Throughput**== (high→low): **superscalar > pipelined > multi-cycle > single-cycle**.
  - ==**Single-cycle vs pipeline**==: SC has lower CPI (1) + simpler control; pipeline wins **throughput + clock**.
- ==**Branch comparator (not ALU subtract)**==:
  - Naive `sign(A-B)` ❌ on overflow → must be `sign(A-B) ⊕ overflow`.
  - Reasons: avoid subtract-overflow bug; faster than full subtractor; frees ALU for addr in same cycle.
  - **NOT** "comparison cannot trap" (irrelevant — RV doesn't trap on int overflow).
- ==**Single-cycle limitations**==:
  - clock = slowest instr (`lw` = `PC → IMem → Regfile → ALU → DMem → WBmux → Regfile setup`);
  - resources can't be reused in 1 cycle → need separate I/D mem;
  - commit only at clock edge;
  - multiply/divide bad fit (iterative).

## 1. Levels of Abstraction

| **Level**       | examples                                                              |
| --------------- | --------------------------------------------------------------------- |
| **ISA**         | RISC-V, ARM, x86 (SW-visible contracts)                               |
| **μarch**       | single-cycle, multi-cycle, pipeline, superscalar, OoO, SMT, SIMD, cache |
| **logic**       | mux, adder, regfile, SRAM, gates                                      |

> Modern x86: 8086 (multi-cycle) → 80486 (pipelined) → P5 Pentium (superscalar) → P6 (OoO) → Nehalem (SMT) → Sandy Bridge (AVX/SIMD) → Alder Lake (P/E cores).

## 2. RV32I Subset & Stages

==**Teaching subset**==: `lw, sw`; `add, sub, and, or`; `beq, jal`.

```text
IF:  instr ← IMem[PC]
ID:  decode; R[rs1], R[rs2] read; imm-gen
EX:  ALU op / addr calc / branch compare / target calc
MEM: load → DMem read; store → DMem write
WB:  R[rd] ← {ALU | Mem | PC+4 | imm}
PC:  PC+4 (default) or branch/jump target
```

==**Last useful stage**== (others = idle slot in pipeline):

| **Instr**   | B (`beq`,…) | S (`sw`,…) | R / I-ALU / U / J | Load (`lw`)       |
| ----------- | ----------- | ---------- | ----------------- | ----------------- |
| **Stage**   | EX          | MEM        | WB                | WB (loaded data)  |

## 3. Performance Model

| Design           | **single-cycle** | **multi-cycle**  | **pipeline**           | **superscalar**                 |
| ---------------- | ---------------- | ---------------- | ---------------------- | ------------------------------- |
| **CPI**          | **1**            | variable         | ≈ 1 (+ hazards)        | **< 1** possible                |
| **Clock**        | slowest instr    | one stage        | slowest stage + reg OH | complex                         |
| **Notes**        | simple/inefficient | reuse HW       | high throughput        | multi-issue + rename/reorder    |

==**RISC vs CISC iron-law**==:

| Metric   | **IC** | **CPI** | **Cycle Time**   |
| -------- | ------ | ------- | ---------------- |
| **RISC** | ↑      | ↑       | ↓                |
| **CISC** | ↓      | ↓       | ↑ (decode-heavy) |

==**Iron-law levers**==:

| Metric              | RISC simplicity     | CISC compactness    | SIMD/vector                | Pipeline        | SS / OoO / Pred / Cache | FMA                          |
| ------------------- | ------------------- | ------------------- | -------------------------- | --------------- | ----------------------- | ---------------------------- |
| **Mainly improves** | CPI↓ / cycle↓ (IC↑) | IC↓ (CPI↑ / cycle↑) | **IC↓** (many elems/instr) | **cycle time↓** | **CPI↓**                | IC↓ + 1 rounding for `a*b+c` |

==**Worked**==: 4 instrs `w(4),x(2),y(3),z(4)` short-cycles each:

| Design       | single-cycle      | multi-cycle    | pipeline (5-stage)               |
| ------------ | ----------------- | -------------- | -------------------------------- |
| **Cycles**   | $4 \times 4 = 16$ | $4+2+3+4 = 13$ | $N + \text{stages}-1 = 7$        |

## 4. Logic Design Basics

| Element                | Stores state? | Output depends on        | Examples                                          |
| ---------------------- | ------------- | ------------------------ | ------------------------------------------------- |
| ==**combinational**==  | ❌            | current inputs only      | ALU, adder, mux, decoder, sign-extender           |
| ==**sequential**==     | ✅            | stored state + inputs    | PC, regs, regfile, IMem/DMem, pipeline regs       |

<img src="assets/image-20260511162635502.png" alt="image-20260511162635502" style="zoom:33%;" /><img src="assets/image-20260511162644859.png" alt="image-20260511162644859" style="zoom:33%;" />

==**HDL**==: Verilog, SystemVerilog, VHDL, Chisel; synthesized to netlist via Synopsys/Cadence. Textbook uses HCL.

> [!IMPORTANT]
>
> ```
>         Launch Edge                        Capture Edge
>              ↓      W                  R         ↓
> CLK  _______/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\_________________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\____
>             ↑                                   ↑
>         Source FF                           Dest FF
>             |<--------- Clock Period (T) ------>|
>             |-- Tclk-to-q --|-- Tcritical --|-- Tsetup --|
>             |<----------- Data Arrival Time ------------>| (Must be ≤ T)
> ```
>
> $$
> \text{Clock\ Period}\ge T_{\text{clk-to-Q}}+T_{\text{critical-path}}+T_{\text{setup}}+T_{\text{skew}}
> $$
>
> ==**Edge-triggered**== state updates on rising edge.

==**Regfile timing**==:

- read `rs1/rs2`: **combinational** once addrs settle; write `rd`: **sequential**, clocked, on rising edge when `RegWr=1`.
- branches/stores: `RegWr = 0`.

> **Pipeline trick**: write in **first half**, read in **second half** → same-cycle WB→ID forwarding (no extra mux).

## 5. Processor Design Procedure

1. Analyze register transfers per instr.
2. Pick datapath state + combinational blocks.
3. Assemble datapath for each class.
4. Determine control settings.
5. Build control logic.

> ==**Why RISC-V regularity helps**==: fixed field positions (`rs1[19:15], rs2[24:20]`) → regfile read can **start before full decode**.

## 6. Branch Datapath

==**`beq rs1, rs2, imm`**==: read regs; compare; taken → `PC + B-imm`, else `PC+4`.

==**Why 2 adders in EX**==: `PC+4` (always) + `PC + B-imm` (branch target); ALU busy comparing.

> [!IMPORTANT]
> ==**Branch comparator vs ALU subtract**==:
>
> 1. **avoid subtract-overflow compare bug**;
> 2. comparator **faster** than full subtractor;
> 3. frees ALU for addr/ALU in same cycle.
>
> NOT "comparison cannot trap" (irrelevant — RV doesn't trap on int overflow).

> Equality (`beq/bne`) via subtract-then-zero is safe (XOR=0 means equal).

## 7. Single-Cycle Limits & Comparison

Among `JALR`, `LW`, `SLL`, `LUI`: ==**`LW`** sets clock rate==.

| Design           | **single-cycle** | **multi-cycle**           | **pipeline**                   | **superscalar**                 |
| ---------------- | ---------------- | ------------------------- | ------------------------------ | ------------------------------- |
| **Strength**     | simplest, CPI=1  | shorter clock, HW reuse   | high throughput                | CPI < 1                         |
| **Weakness**     | long clock       | CPI > 1                   | hazards, pipeline regs         | many ports, scheduling, rename  |

==**Quiz**==: vs pipelined, SC has **lower CPI (1)** + **simpler control logic**; pipelined has **higher throughput**.

> [!NOTE]
>
> Clock = `lw` critical path: `PC → IMem → Regfile → ALU(addr) → DMem → WBmux → Regfile setup` + clk-to-Q + skew. Shorter instrs (R, branch) **waste** the long clock. → Solution: pipeline stages.
>
> > ==**RISC-V regularity simplifies control**==: fixed instr size, regular field positions, 12b/20b imm only, reg/imm operands only.
