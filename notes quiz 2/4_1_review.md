# 4.1 Processor Architecture & Logic Design

## Exam Facts

- ==**Microarchitecture**==: implementation of ISA: single-cycle, multi-cycle, pipeline, superscalar, OoO, cache, prediction.
- CPU time = **instruction count x CPI x clock cycle time**.
- Single-cycle: **CPI=1**, but clock must fit slowest instruction; resources cannot be reused in same cycle.
- Multi-cycle: shorter clock, variable CPI, reuses hardware across cycles.
- Pipeline: higher throughput, near CPI 1 after fill; single-instruction latency may not improve.
- Superscalar pipeline can **issue/execute >1 instruction per cycle**, so CPI can be **<1**.
- RV32I regfile in scalar datapath needs **2R/1W**.
- Single-cycle `LW` usually sets clock cycle time because it uses IMem + reg read + ALU + DMem + WB.

## Datapath and Control

- Datapath = data flow: PC, instruction memory, register file, ALU, data memory, muxes.
- Control = instruction flow/signals: decode, `PCSrc`, `RegWr`, ALU control, memory read/write, WB select.
- Instruction cycle: **fetch -> decode/read regs -> execute/address/branch -> memory -> writeback**.
- RV regularity simplifies datapath: `rd`, `rs1`, `rs2` fields in fixed positions; immediates mostly high bits.

## Logic Design Basics

- Combinational circuit: output depends only on current inputs; delay set by critical path.
- Sequential element: stores state; output depends on input + stored state.
- Clocking: state updates on clock edge; combinational logic runs between edges.
- Critical path determines minimum clock period.

## Single-Cycle RISC-V

- Every instruction completes in 1 long cycle; CPI=1 but slow clock.
- Cannot pass through same combinational resource/state twice in one cycle.
- Needs separate I/D memory to avoid structural hazard.
- Needs multiple adders: PC+4, branch target, ALU.
- Regfile must read 2 regs and write 1 reg in same cycle.
- `RegWr=0` for **branches and stores**.

## Compare-and-Branch

- Branch can use ALU subtraction, but signed subtraction overflow can produce wrong comparison if using sign only.
- Better design uses true comparison unit that **does not trap** and avoids overflow-condition errors.
- Quiz answer: RV designs may use compare unit because subtraction overflow can make taken/not-taken wrong.

## Performance Ordering

- Single-cycle: simple control, CPI=1, long clock.
- Multi-cycle: shorter clock, variable CPI.
- Pipelined: higher throughput than multi-cycle after fill.
- Superscalar+pipelined: highest throughput; may issue >1 inst/cycle.
