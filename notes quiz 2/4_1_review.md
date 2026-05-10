# Lec 4.1: Processor Architecture & Logic Design

## Exam Facts

- ==**Microarch**==: ISA implementation. **Single-cycle / Multi-cycle / Pipelined / Superscalar / OoO / cache / predictors**.
- ==**CPU time = IC × CPI × cycle**==.
- **Single-cycle**: CPI=1, but clock = slowest instr (usually `LW`).
- **Multi-cycle**: variable CPI, shorter clock, reuses HW.
- **Pipelined**: throughput ≈ 1 inst/cyc.
- **Superscalar+pipelined**: ==**CPI<1**==, **highest throughput**.
- ==Performance order: **Superscalar+pipe > Pipe > Multi > Single**==.
- RV32I scalar regfile: ==**2R / 1W**==. 2-issue superscalar (int) ~**4R / 2W**. FMA: 3 reads/issue.
- `RegWr=0` for ==**branches and stores**==.
- Single-cycle: cannot reuse HW in 1 cyc → split I/D mem, multiple adders (PC+4, branch target, ALU).
- Compare-and-branch via ALU sub: subtraction overflow can give wrong sign → ==use **dedicated comparison unit**==.

## 1. Microarchitectures

Different µ-arch implementations of the **same ISA** support different perf/cost tradeoffs.

| Era (x86 example) | Microarch |
|---|---|
| 8086/286/386 | multi-cycle |
| 80486 | pipelined |
| Pentium P5 | superscalar |
| Pentium Pro/II/Core2 | OoO + speculative |
| Nehalem | + SMT/Hyperthreading |
| Sandy Bridge / Rocket Lake | + AVX/SIMD |
| Alder/Raptor Lake | heterogeneous (P+E core) |

## 2. Datapath vs Control

| | Datapath | Control |
|---|---|---|
| Job | data flow | instr flow / signals |
| Components | ALU, regs, mem, buses, muxes | decode, `PCSrc`, `RegWr`, ALU ctrl, `WBsel` |
| Role | "Brawn" | "Brain" |

Instr cycle: ==**Fetch → Decode → Execute → Update PC**==. Execute paths: **Ld/St / Branch / ALU**.

## 3. CPU Time and Three Implementation Styles

For 4 instrs `w(4) x(2) y(3) z(4)` (1 long cyc = 4 short):

| Implementation | CPI | Clock | Total |
|---|---|---|---|
| Single-cycle | 1 | 1 long (=4 short) | **16 short** |
| Multi-cycle | variable | 1 short | 4+2+3+4 = **13** |
| Pipelined | ~1 | 1 short | overlapped → **7** |

> Single-cycle CPI=1 is misleading: clock is long because all stages cascade in 1 cycle.

## 4. Logic Design Basics

| Type | Behavior |
|---|---|
| **Combinational** | output = f(inputs); stateless (gates, ALU, MUX) |
| **Sequential / state** | output = f(input + stored state) (regs, memory, FF) |
| **Clock** | edge-triggered; state updates on rising edge |

- **Critical path** (longest gate chain) sets minimum clock period.
- HDLs: Verilog, SystemVerilog, VHDL, Chisel (SiFive RV).

> SW: C → compiler → asm. HW: HDL → Boolean+FSM → synthesizer → netlist → silicon.

## 5. Single-Cycle RISC-V Subset

Subset: `lw, sw, add, sub, and, or, beq, jal`.

### 5.1 Three Key MUX Decisions

| MUX | Source choices |
|---|---|
| ==`PCSrc`== | branch/JAL → `PC+imm`; else `PC+4` |
| ==`WBsel`== | load → DMem; ALU op → ALU |
| ==`ALUSrc`== | R-type → `reg[rs2]`; I/Load/Store → imm |

### 5.2 Datapath Requirements

- Memory: **separate I-mem + D-mem** (avoid struct hazard).
- Regfile: 32×32b, **2R + 1W** ports.
- PC, sign/zero extender, ALU, adders for PC+4 + PC+imm.

> Why two adders in EX: simultaneously need branch target (PC+imm) AND ALU result.

### 5.3 Branch via Subtraction Trap

- ALU sub → sign decides taken; but **sub can overflow** → wrong sign.
- RV doesn't trap overflow → would need explicit check on every branch.
- ⇒ many RV designs use a ==**dedicated comparison unit**== or `V/C` flags.

## 6. Storage Elements

### 6.1 Register File

- 2 read ports (busA/busB) selected by rs1/rs2; 1 write port (busW) by rd, gated by `RegWrite`.
- CLK matters only on writes; reads behave combinationally.

> 2-wide superscalar GPR: **4R / 2W**. FMA FP regfile: **3 reads/issue** (6R/2W for 2-issue).

### 6.2 Memory

Address selects word; `WriteEnable=1` → write via DataIn.

## 7. Single-Cycle Limitations

> [!IMPORTANT]
> 1. Resources cannot be reused in same cycle → duplicate adders, separate I/D mem.
> 2. Iterative ops (mul/div) must be fully unrolled in HW (expensive).
> 3. Clock = slowest instr (`LW`: PC → IMem → RegFile → ALU → DMem → WB).
> 4. ⇒ leads to multi-cycle / pipelined.

## 8. Performance Ordering Summary

| | Single | Multi | Pipe | Superscalar+Pipe |
|---|---|---|---|---|
| CPI | 1 | variable | ≈1 | **<1** |
| Clock | long | short | short | short |
| Control | **simple** | complex FSM | medium | hardest |
| Throughput | low | medium | high | highest |

> Single-cycle "advantages" vs pipe: **simple control + low CPI**. Drawback: long clock, low throughput.
