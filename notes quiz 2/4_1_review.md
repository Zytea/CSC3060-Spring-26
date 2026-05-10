# Lec 4.1: Processor Architecture & Logic Design

## Exam Facts

- ==**Microarchitecture**==: implementation of an ISA. Variants:
  - **Single-cycle** → CPI = 1, but clock = slowest instr.
  - **Multi-cycle** → variable CPI, shorter clock, reuses HW.
  - **Pipelined** → throughput ≈ 1 inst/cyc, latency may not improve.
  - **Superscalar** → can issue >1 per cycle, **CPI < 1**.
  - + OoO, speculative exec, cache hierarchies, predictors.
- ==**CPU time = Instr count × CPI × Clock cycle time**==.
- **CISC**: low IC, high CPI, long cycle. **RISC**: high IC, low CPI, short cycle.
  - Modern x86: complex CISC instrs decoded **into RISC-like µ-ops** internally, then executed.
- **Performance ranking**: ==Superscalar+pipelined > Pipelined > Multi-cycle > Single-cycle==.
- Single-cycle CPI = 1 but **clock long** because all stages cascade in 1 cycle. The slowest instr (usually `LW`: PC → IMem → RegFile → ALU → DMem → WB) sets clock period.
- RV32I scalar regfile: **2 read + 1 write** ports.
- 2-issue superscalar (int): ~**4R / 2W**.
- FMA needs **3 read** ports per issue.
- `RegWr = 0` for **branches and stores** (no register written).
- Single-cycle limitations: cannot reuse same combinational/state element twice/cycle ⇒ need **separate I-mem and D-mem**, multiple adders (PC+4, branch target, ALU).
- Compare-and-branch using ALU subtraction has overflow trap: **better use a true comparison unit** to avoid wrong taken/not-taken.

## 1. Processors and Microarchitectures

Different µ-arch implementations of the **same** ISA: single-cycle / multi-cycle / pipelined / superscalar / OoO / speculative / cache hierarchies / predictors.

| Era (x86 example) | Microarchitecture |
|---|---|
| 8086/286/386 | multi-cycle |
| 80486 | pipelined |
| Pentium P5 | superscalar |
| Pentium Pro / II / Core2 | OoO + speculative |
| Nehalem | + SMT/Hyperthreading |
| Sandy Bridge / Rocket Lake | + AVX/SIMD |
| Alder/Raptor Lake | heterogeneous (P-core + E-core) |

## 2. Computer Organization: Datapath vs Control

| | Datapath | Control |
|---|---|---|
| Job | data flow | instruction flow / signals |
| Components | ALU, regs, mem interface, buses, muxes | decode, `PCSrc`, `RegWr`, ALU control, MemRd/Wr, `WBsel` |
| Role | "**Brawn**" | "**Brain**" |

## 3. Instruction Execution Cycle

==**Fetch → Decode → Execute → Update PC**==

In Execute:
- ALU computes arithmetic OR address (LW/SW) OR branch comparison + target.
- Data memory accessed for load/store.
- PC ← `PC+4` or branch target.

## 4. CPU Time and Three Implementation Styles

For 4 instructions w (4 cyc), x (2), y (3), z (4):

| Implementation | CPI | Clock | Total |
|---|---|---|---|
| Single-cycle | 1 | 1 long cycle (= 4 short) | **16 short cycles** |
| Multi-cycle | variable | 1 short | 4+2+3+4 = **13 short** |
| Pipelined | ~1 | 1 short | overlapped → **7 short** |

> Note: Single-cycle CPI=1 is misleading — clock is long because it must accommodate the slowest instruction.

## 5. Logic Design Basics

### Three component types

| Type | Behavior | Example |
|---|---|---|
| **Combinational** | output = f(inputs only); stateless | gates, ALU, MUX, decoder |
| **Sequential / state** | output = f(input + stored state) | register, memory, FF |
| **Clock** | regulates state updates | edge-triggered FF |

- **Critical path** delay = longest gate-chain → sets minimum clock period.
- Clock methodology: **edge-triggered**, state updates on rising edge; combinational logic runs between edges.

### HDL languages: Verilog, SystemVerilog, VHDL, Chisel (used by SiFive for RV).

> SW: C → compiler → asm.
> HW: Verilog/Chisel → Boolean eqs + FSM → logic synthesizer → netlist → silicon.

## 6. Single-Cycle RISC-V Subset

Subset: `lw, sw, add, sub, and, or, beq, jal`.

### Three key MUX decisions

| MUX | Source choices |
|---|---|
| **`PCSrc`** | branch/JAL → `PC + imm`; else → `PC + 4` |
| **`WBsel`** | load → DMem out; ALU op → ALU out |
| **`ALUSrc`** | R-type → `reg[rs2]`; I/Load/Store → imm |

### Datapath requirements

- **Memory**: instruction memory + data memory (separated to avoid structural hazard).
- **Register file**: 32 × 32b, **2R + 1W** ports.
- **PC** (32b).
- **Sign/zero extender** for immediates.
- **ALU** for ADD/SUB/AND/OR/SLT.
- **Adders** for PC+4 and PC+imm (branch target).

### Why two adders?

> EX stage simultaneously needs **branch target (PC+imm)** and **ALU result** (e.g., for the live data). Sharing one adder would cause a structural hazard.

### Branch via subtraction trap

- Using ALU subtract → sign bit decides taken/not-taken.
- But **subtraction can overflow** → wrong sign → wrong outcome.
- RV does NOT trap on overflow → would need explicit check on every compare-and-branch.
- ⇒ many RV processors use a **dedicated comparison unit** (or carry/overflow flags in a status register) to avoid mis-branching.

> [!IMPORTANT] Quiz answer: "Why use a comparison unit instead of ALU sub?" → **Avoid wrong taken/not-taken due to subtraction overflow.**

## 7. RV32I Format Regularity (helps datapath simplicity)

- Opcode always **bits 0–6**.
- `rd` (when present) always **bits 7–11**.
- `rs1` always **bits 15–19**.
- `rs2` always **bits 20–24**.
- Immediate placed in high bits (B/S split using rd field).
- Fixed length 32b (or 16b w/ C-ext).

⇒ Decoder is small + fast; reg-read can begin **before decode finishes**.

## 8. Storage Elements

### Register file

- 2 read ports (busA, busB) selected by rs1, rs2.
- 1 write port (busW) selected by rd, gated by `RegWrite`.
- CLK matters only for **writes**; reads behave combinationally.

> Quiz: For 2-wide superscalar, GPRs need **4 read + 2 write** ports.
> For FMA (3-source instr), FP regfile needs **3 reads per FMA**.

### Memory

- Address selects word.
- `WriteEnable=1` → address selects word written via DataIn bus.

## 9. Single-Cycle Limitations

> [!IMPORTANT]
> 1. **Resources cannot be reused** in same cycle → must duplicate adders, separate I/D mem.
> 2. Cannot pass through the same combinational/state element twice/cycle → multi-cycle iterative ops (mul/div) would have to be **fully unrolled in HW** (very expensive).
> 3. Clock = slowest instruction → typically `LW` path: PC → IMem → RegFile → ALU → DMem → WB.
> 4. ⇒ leads to **multi-cycle / pipelined** implementations.

## 10. Performance Ordering Summary

> [!IMPORTANT] Throughput: ==**Superscalar+Pipelined > Pipelined > Multi-cycle > Single-cycle**==.

| | Single-cycle | Multi-cycle | Pipelined | Superscalar+Pipe |
|---|---|---|---|---|
| CPI | 1 | variable | ≈1 | **<1** |
| Clock | long | short | short | short |
| Control | **simple** | complex FSM | medium | hardest |
| Throughput | low | medium | high | highest |
| Resource sharing | none | yes | yes (across instrs) | yes |

> Single-cycle "advantages" vs pipelined: **Simple control + lower CPI (=1)**. Drawback: long clock, low throughput.

## 11. Quiz Cheat Sheet

| Q | A |
|---|---|
| Which µ-arch can have CPI<1? | **Superscalar** (with pipelining) |
| Highest throughput | **Superscalar + pipelined** |
| What sets single-cycle clock? | The slowest instruction (typically `LW`) |
| `RegWr=0` for what? | **Branches, Stores** |
| Why need 2 adders in EX? | One for ALU result, one for branch target (`PC+imm`) |
| Why split I-mem and D-mem? | Avoid structural hazard in 1 cycle |
| Why dedicated compare unit for branch? | Avoid wrong outcome from sub overflow |
| RV32I regfile ports | 2R / 1W |
| FMA reads | 3 sources per issue |
| 2-issue superscalar GPR | ~4R / 2W |
