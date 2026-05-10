# Lec 4.1: Processor Architecture & Logic Design

## Exam Facts

- ==**Architecture/ISA**==: SW-visible interface. ==**Microarchitecture**==: one HW implementation of an ISA.
- Microarchitectures: **single-cycle, multi-cycle, pipelined, superscalar, OoO, caches, predictors**.
- ==**CPU time = Instruction count x CPI x clock cycle time**==.
- Single-cycle: **CPI=1**, simple control, but clock = slowest instr path, usually `LW`.
- Multi-cycle: shorter clock, variable CPI, reuses HW across cycles.
- Pipelined: overlaps instrs, throughput near 1 instr/cyc.
- Superscalar + pipelined: can issue >1 instr/cyc, so ==**CPI < 1**==; highest throughput among choices.
- Quiz order: ==**superscalar+pipeline > pipeline > multi-cycle > single-cycle**==.
- RV32I GPR file needs **2R/1W**. 2-issue integer about **4R/2W**; 2-issue FMA FP file **6R/2W**.
- Single-cycle cannot reuse a resource in the same cycle -> duplicate memories/adders.
- Branch compare by ALU subtraction can be wrong on signed overflow -> use a dedicated comparison unit.

## 1. Processors and Logic Designs

==**Computer organization**== explains how datapath, control, memory, I/O, and interconnect implement an ISA.

| Term | Meaning |
|---|---|
| Datapath | values move/compute: PC, regfile, ALU, memories, muxes |
| Control | selects what datapath does: `PCSel`, `RegWEn`, `ALUSel`, `WBSel`, etc. |
| Combinational logic | output depends only on current inputs |
| Sequential logic | stores state; updates on clock edge |

Critical path = longest delay path in a clocked design -> sets minimum clock period.

## 2. Computer Organization

Instruction execution cycle:

1. **Fetch** instr at `PC`.
2. **Decode** instr bits; read registers; generate control.
3. **Execute** ALU / address / branch compare.
4. **Memory** access for load/store.
5. **Write back** result and update PC.

> [!IMPORTANT]
> These are logical steps. A single-cycle CPU does all in one long cycle; a multi-cycle CPU spreads them over cycles; a pipeline overlaps them across instrs.

## 3. RV32I Datapath and Control

Subset often used in datapath questions: `lw, sw, add, sub, and, or, beq, jal`.

Datapath requirements:

- PC register, instruction memory, data memory.
- Register file: 32 regs, **2 read ports + 1 write port**.
- Immediate generator for I/S/B/U/J formats.
- ALU for arithmetic/address/compare support.
- Adders for `PC+4` and branch/jump target.
- MUXes for next PC, ALU input, write-back source.

### 3.1 Main MUX Choices

| MUX | Choices | Typical use |
|---|---|---|
| `PCSel/PCSrc` | `PC+4`, `PC+imm`, `rs1+imm` | sequential, branch/JAL, JALR |
| `ASel` | `rs1`, `PC` | ALU op vs AUIPC/JAL target |
| `BSel` | `rs2`, immediate | R-type vs I/load/store |
| `WBSel` | ALU, memory, `PC+4` | ALU/U, load, JAL/JALR link |

Quiz next-PC choices in RV32I: ==**`PC+4`, `PC+imm`, `rs1+imm`**==. Not memory indirection.

## 4. Single-Cycle vs Multi-Cycle vs Pipeline

For instr costs in short cycles `4,2,3,4`:

| Impl | Clock | CPI | Time for 4 instrs |
|---|---|---|---|
| Single-cycle | longest = 4 | 1 | `4*4=16` |
| Multi-cycle | short = 1 | variable | `4+2+3+4=13` |
| Pipeline | short = 1 | about 1 | fill/drain -> `4+5-1=8` for 5-stage, class example may use 7 if 4 stages |

> Single-cycle CPI=1 is not "fast"; the clock is long.

## 5. Logic Design Basics

| Element | Examples | Exam role |
|---|---|---|
| Combinational | gates, mux, decoder, ALU, comparator | no stored state |
| Sequential | PC, regfile, pipeline regs, memory, FF | stores state |
| Clocked write | regfile write, PC update | state changes on edge |

HDL flow: HDL -> Boolean/FSM -> synthesis -> netlist -> silicon.

## 6. Branch via Subtraction Trap

If branch condition `rs1 < rs2` is computed by `rs1-rs2` sign bit, signed overflow can flip the sign.

> [!IMPORTANT]
> Dedicated branch comparator avoids wrong taken/not-taken caused by subtraction overflow. This is the Quiz answer; not structural hazard, not "comparison does not trap".

## 7. Single-Cycle Limitations

1. Cannot reuse HW in one cycle -> separate I/D memory, multiple adders.
2. Clock must cover slowest instruction: `PC -> I-Mem -> RegFile -> ALU -> D-Mem -> WB`.
3. Iterative `mul/div` would need huge combinational hardware or make clock impossible.
4. Low throughput despite CPI=1.

## 8. Performance Ordering Summary

| Impl | Throughput | Clock | Control | Key trap |
|---|---|---|---|---|
| Single-cycle | lowest | longest | simplest | CPI=1 but slow clock |
| Multi-cycle | medium | shorter | FSM | variable CPI |
| Pipeline | high | short | medium | hazards add CPI |
| Superscalar+pipe | highest | short | hardest | CPI can be <1 |
