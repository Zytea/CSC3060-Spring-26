# Lec 4.1: Processor Architecture & Logic Design

## Exam Facts

- ==**Microarchitecture**==: implementation of an ISA: single-cycle, multi-cycle, pipeline, superscalar, OoO, caches, predictors. Same ISA → many μarches with different cost/perf.
- ==**Datapath**==: stores/moves/computes data ("brawn"); ALU, regfile, memory, muxes, adders.
- ==**Control**==: decides actions ("brain"); selects mux inputs, asserts write enables, decodes opcode.
- **Execution cycle**: ==`fetch → decode/read regs → execute → memory → writeback → update PC`==.
- ==**Iron Law**==: $CPU\ Time = IC \times CPI \times Clock\ Cycle\ Time$.
- **Single-cycle**: ==**CPI = 1**==; clock period must cover **slowest instr** (usually `lw`).
- **Multi-cycle**: shorter clock, resource reuse, **variable CPI**.
- **Pipeline**: overlapped instrs, **CPI ≈ 1**, throughput up; hazards add stalls.
- ==**CPI < 1**==: only **superscalar / multiple-issue**, NOT single/multi/scalar pipeline.
- ==**Throughput order**== (high→low): **superscalar > pipelined > multi-cycle > single-cycle**.
- ==**Single-cycle vs pipeline**==: single-cycle has lower CPI (1) but **worse throughput / clock** due to long cycle. Pipelined wins **throughput**; single-cycle wins **simplicity + control logic** + per-instr CPI.
- **Scalar RV32I regfile**: ==**2 read ports + 1 write port**==. Reads = combinational; writes = clocked.
- **2-issue superscalar regfile**: ~4R/2W. **2-issue FMA FP**: 6R/2W.
- **Branch signed compare via subtract**: sign of `A-B` can be wrong on overflow → use **comparator** or `sign(A-B) ⊕ overflow`.
- ==**Why a separate branch comparison unit**==: avoid subtract-overflow compare bugs; faster than full subtract; frees ALU for address/ALU work in same cycle. **NOT** because "comparison cannot trap".
- **Slowest path on single-cycle** = `lw`: PC → IMem → Regfile → ALU(addr) → DMem → WBmux → Regfile setup. So `lw` sets the clock period.
- ==**Limitations of single-cycle**==: clock = slowest instr; resources cannot be reused in one cycle → need separate I/D mem (IF + MEM in same cycle); commit only at clock edge; multiply/divide bad fit (would need replicated logic).

## 1. Levels of Abstraction

| Level | Examples |
|---|---|
| **ISA** | RISC-V, ARM, x86 (SW-visible contracts) |
| **microarchitecture** | single-cycle, multi-cycle, pipeline, superscalar, OoO, SMT, SIMD, cache |
| **logic / circuit** | mux, adder, regfile, SRAM, gates |

> Same ISA, many μarch implementations with different cost/perf trade-offs. Modern x86 example: 8086 (multi-cycle) → 80486 (pipelined) → P5 Pentium (superscalar) → P6 (OoO) → Nehalem (SMT) → Sandy Bridge (AVX/SIMD) → Alder Lake (heterogeneous P/E cores).

## 2. Computer Organization

| Part | Job | Examples |
|---|---|---|
| ==**Datapath**== ("brawn") | stores/moves/computes data | PC, regfile, ALU, memory, adders, muxes |
| ==**Control**== ("brain") | selects + enables | `RegWr`, `MemWr`, `ALUSrc`, `WBSel`, `PCSrc`, `ALUCtrl` |

## 3. RV32I Subset and Execution Cycle

==**Teaching subset**==:

| Class | Instrs |
|---|---|
| memory | `lw`, `sw` |
| ALU | `add`, `sub`, `and`, `or` |
| control | `beq`, `jal` |

==**Logical work per stage**==:

```text
IF:  instr ← IMem[PC]
ID:  decode; R[rs1], R[rs2] read; imm-gen
EX:  ALU op / addr calc / branch compare / target calc
MEM: load → DMem read; store → DMem write
WB:  R[rd] ← {ALU | Mem | PC+4 | imm}
PC:  PC+4 (default) or branch/jump target
```

==**Effective stages used**== (others = idle but still occupy slot in pipeline):

| Instr type | Last useful stage |
|---|---|
| B (`beq`, `bne`, …) | EX (compare + target) |
| S (`sw`, `sh`, `sb`) | MEM (store) |
| R / I-ALU / U / J | WB (write reg) |
| Load (`lw`) | WB (write loaded data) |

## 4. Performance Model

$$
CPU\ Time = Instruction\ Count \times CPI \times Clock\ Cycle\ Time
$$

| Design | CPI | Clock | Notes |
|---|---:|---|---|
| **single-cycle** | **1** | slowest instr | simple, inefficient (long cycle) |
| **multi-cycle** | variable (per instr) | one stage | resource reuse, shorter clock |
| **pipeline** | ≈ 1 (+ hazards) | slowest stage + reg overhead | high throughput |
| **superscalar** | **< 1** possible | complex | multiple issue/retire; rename, reorder |

==**RISC vs CISC iron-law**==:

| Metric         | **IC** | **CPI** | **Cycle Time**       |
| -------------- | ------ | ------- | -------------------- |
| **RISC**       | higher | lower   | shorter              |
| **CISC**       | lower  | higher  | longer (decode-heavy)|

==**Iron-law levers**==:

| Technique | Mainly improves |
|---|---|
| SIMD / vector / RVV | **IC** (many elems / instr) |
| pipelining / multi-cycle partitioning | **cycle time** |
| superscalar / OoO / pred / cache / scheduling | **CPI** |
| FMA | reduces IC + rounding for `a*b+c`; doesn't auto-improve all 3 |
| RISC regularity | lower CPI / cycle time, may raise IC |
| CISC compactness | lower IC, often higher CPI/cycle |
| calling convention | lower IC + memory ops at calls |

==**Worked timing**== for 4 instrs `w(4),x(2),y(3),z(4)` short-cycles each:

| Design       | single-cycle  | multi-cycle | pipeline (5-stage)             |
| ------------ | ------------- | ----------- | ------------------------------ |
| **Cycles**   | $4 \times 4 = 16$ | $4+2+3+4 = 13$ | $N + \text{stages}-1 = 7$ |

> Pipeline wins on throughput (≈ 1 instr/short-cycle steady state); multi-cycle reuses HW; single-cycle is simplest control.

## 5. Logic Design Basics

| Element              | Stores state? | Output depends on        | Examples                                          |
| -------------------- | ------------- | ------------------------ | ------------------------------------------------- |
| ==**combinational**==| NO            | current inputs only      | ALU, adder, mux, decoder, sign-extender           |
| ==**sequential**==   | YES           | stored state + inputs    | PC, regs, regfile, IMem/DMem, pipeline regs       |

==**HDL**==: hardware description languages (Verilog, SystemVerilog, VHDL, Chisel). Synthesizable into a netlist via design compilers (Synopsys/Cadence). Textbook uses HCL.

```
SW: C/C++ → Compiler → asm/machine code
HW: Verilog/VHDL → Boolean + FSM → Synthesizer → Netlist
```

### 5.1 Clocking

```text
clock edge → state outputs stable → combinational logic → setup before next edge
```

Clock period $\geq$ `clk-to-Q + critical-path-delay + setup + skew`.

==**Edge-triggered**==: state updates on clock rising edge.

==**Regfile timing**==:

| Action | Timing |
|---|---|
| read `rs1/rs2` | combinational once addrs settle |
| write `rd` | clocked, on rising edge when `RegWr=1` |
| branches / stores | `RegWr = 0` |

> Pipeline trick: write in **first half** of cycle, read in **second half** → same-cycle WB→ID forwarding via regfile (no extra mux).

## 6. Abstract RV32I Datapath

==**Required components**==:

- PC + next-PC mux.
- IMem / I-cache.
- ==**Regfile (`rs1`, `rs2`, `rd`, 2R/1W)**==.
- Immediate generator (signext per instr type).
- ALU.
- DMem / D-cache.
- Adders for `PC+4` and `PC+imm`.
- Writeback mux.

==**Three MUX selects (single-cycle)**==:

| Mux | Choices |
|---|---|
| ==**`PCSrc`**== | `PC+4`, `PC+imm` (branch/JAL), `(rs1+imm)&~1` (JALR) |
| ==**`ALUSrcB`**== | `R[rs2]` (R-type/branch) or imm (I/load/store/JALR) |
| ==**`WBSel`**== | ALU result, memory, `PC+4` (JAL/JALR), imm (LUI/AUIPC) |

## 7. Processor Design Procedure

1. Analyze ISA register transfers per instr.
2. Pick datapath state + combinational blocks.
3. Assemble datapath for each instr class.
4. Determine control settings per instr.
5. Build control logic.

> Shortcut flow: ==**check datapath requirements → assemble datapath components → add control signals**==.

### 7.1 Why RISC-V Regularity Helps

Fixed field positions: `opcode[6:0], rd[11:7], funct3[14:12], rs1[19:15], rs2[24:20]`.

→ Regfile read can **start before full decode** (because rs1/rs2 fields are at known positions for all formats).

### 7.2 Register File Ports

| Machine            | scalar RV32I | 2-issue scalar | 2-issue FMA (R4)       |
| ------------------ | ------------ | -------------- | ---------------------- |
| **Read / Write**   | **2R / 1W**  | ~4R / 2W       | **6R / 2W** (FP)       |

> FMA needs 3 reads per instr (`rs1, rs2, rs3`), so 2-issue FMA = 6 reads.

## 8. Branch Datapath and Subtraction Trap

==**`beq rs1, rs2, imm`**==: read regs; compare; if equal, `PC = PC + B-imm`, else `PC+4`.

==**Why two adders in EX/IF**==:

- one for `PC+4` (always needed).
- one for `PC + B-imm` (branch target).
- ALU might be busy doing the comparison; can't reuse it for PC+imm.

> Quiz: in pipelined RV32I datapath, **EX stage requires 2 adders**.

### 8.1 Signed Compare via Subtract: Overflow Trap

Naive: `signed_lt = sign(A-B)`. **WRONG** when subtraction overflows.

Correct: `signed_lt = sign(A-B) XOR overflow`.

> [!IMPORTANT]
> ==**Why a separate branch comparison unit (not ALU subtract)**==:
> 1. **avoid subtract-overflow compare bug** (RV doesn't trap on int overflow);
> 2. comparator can be **faster** than full subtractor;
> 3. frees ALU for address/ALU work in same cycle.
>
> NOT because "comparison cannot trap" (irrelevant — RV doesn't trap on int overflow either).

> Equality (`beq/bne`) via subtract-then-zero is safe (XOR=0 means equal).

## 9. Single-Cycle RV32I Processor

==**Single-cycle rule**==: every instr finishes in **one long cycle**; all state updates at the **clock edge**.

==**Slowest path**== (= `lw`):

```text
PC → IMem → Regfile → ALU(addr calc) → DMem → WBmux → Regfile setup
```

Among `JALR`, `LW`, `SLL`, `LUI`: ==**`LW`** sets clock rate==.

==**Limitations**==:

1. **Slowest instr** sets clock period for **all**.
2. **Resources cannot be reused** in same cycle → need separate IMem + DMem (else IF/MEM structural conflict).
3. Result is committed at clock edge **after** combinational settle.
4. **Multiply/divide** bad fit (iterative; would need replicated logic).
5. Inefficient for varying instr complexity.

## 10. Single-Cycle vs Multi-Cycle vs Pipeline

| Design           | **single-cycle** | **multi-cycle**           | **pipeline**                   | **superscalar**                 |
| ---------------- | ---------------- | ------------------------- | ------------------------------ | ------------------------------- |
| **Strength**     | simplest, CPI=1  | shorter clock, HW reuse   | high throughput                | CPI < 1                         |
| **Weakness**     | long clock       | CPI > 1                   | hazards, pipeline regs         | many ports, scheduling, rename  |

==**Quiz anchor**== (vs pipelined): single-cycle has **lower CPI (1)** + **simpler control logic**; pipelined has **higher throughput**.

## 11. Control Points Preview (Step 4)

| Signal | Meaning |
|---|---|
| `RegWr` | enable write to `rd` |
| `MemRd` | DMem read enable (Load) |
| `MemWr` | DMem write enable (Store) |
| `ALUSrc` | ALU operand B mux: 0=R[rs2], 1=imm |
| `ALUCtrl` | ALU op (decoded from `ALUOp + funct3 + funct7[5]`) |
| `WBSel` | WB-mux source: ALU / mem / PC+4 / imm |
| `PCSrc` | next-PC mux: PC+4 / PC+imm / (rs1+imm)&~1 |

> Detail in [4_2_review.md](4_2_review.md).
