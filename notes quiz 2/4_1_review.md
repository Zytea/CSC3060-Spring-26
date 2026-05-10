# Lec 4.1: Processor Architecture & Logic Design

## Exam Facts

- ==**Microarchitecture**==: implementation of an ISA: single-cycle, multi-cycle, pipeline, superscalar, OoO, speculation, caches, branch predictors.
- ==**Datapath**== moves/computes data: ALU, regfile, memory interface, buses.
- ==**Control**== generates signals and selects paths: PC update, mux selects, register/memory write enables.
- Instruction execution cycle: **fetch -> decode/read regs -> execute -> memory -> writeback -> PC update**.
- CPU time = **instruction count x CPI x clock cycle time**.
- RISC vs CISC tradeoff: RISC may use more instrs, but lower CPI and shorter cycle time.
- Single-cycle: CPI=1, but clock is as slow as slowest instr, usually `lw`.
- Multi-cycle: shorter clock and reused resources, but CPI varies.
- Pipeline: overlapped instrs, throughput close to 1 instr/cycle after fill, hazards may add stalls.
- Superscalar + pipeline may issue >1 instr/cycle, so ==**CPI < 1**==.
- Quiz order: **superscalar+pipelined > pipelined > multi-cycle > single-cycle** for throughput.
- RV32I scalar regfile needs **2 read ports + 1 write port**.
- Branch compare via subtraction can be wrong if overflow affects sign; true comparator or flags avoid this.

## 1. Processors and Logic Designs

Computer architecture levels:

| Level | Examples |
|---|---|
| ISA family | x86, IBM 360, ARM, RISC-V |
| microarchitecture | single-cycle, multi-cycle, pipelined, superscalar, OoO, SMT, SIMD, caches, predictors |
| logic/circuit | gates, muxes, adders, regfiles, memories |

Different microarchitectures can implement the same ISA with different cost/performance.

| x86 history idea | Microarchitecture feature |
|---|---|
| 8086/286/386 | multi-cycle |
| 486 | pipelined |
| Pentium P5 | superscalar |
| Pentium Pro / Core | OoO |
| Nehalem | SMT / Hyper-threading |
| Sandy Bridge+ | wider SIMD/AVX |
| Alder/Raptor Lake | heterogeneous P/E cores |

## 2. Computer Organization

| Part | Role | Mnemonic |
|---|---|---|
| Datapath | arithmetic, load/store, data movement | brawn |
| Control | instruction flow, PC choice, control signals | brain |

Datapath elements include ALU, regfile, PC, memories/cache ports, immediate generator, adders, and muxes.

Control decides `RegWr`, `MemRd`, `MemWr`, `ALUSrc`, `PCSrc`, `WBSel`, ALU function, and branch/jump behavior.

## 3. RV32I Subset and Execution Cycle

Subset used for datapath design:

| Class | Instrs |
|---|---|
| memory | `lw`, `sw` |
| ALU | `add`, `sub`, `and`, `or` |
| control | `beq`, `jal` |

Logical instruction cycle:

1. Fetch instr at `PC`.
2. Decode instr fields and read `rs1/rs2`.
3. Execute ALU op, address calc, branch compare, or target calc.
4. Access data memory for load/store.
5. Write result to `rd` if needed.
6. Set next `PC` to `PC+4`, branch/JAL target, or JALR target.

> These are logical steps. A single-cycle CPU performs all combinational work in one long cycle; a multi-cycle CPU spreads them over cycles; a pipeline overlaps steps from multiple instrs.

## 4. Performance Model

$$
CPU\ Time = Instruction\ Count \times CPI \times Clock\ Cycle\ Time
$$

Example with 4 instrs whose required steps are `w=4`, `x=2`, `y=3`, `z=4` short cycles:

| Implementation | CPI idea | Clock | Total short cycles |
|---|---|---|---:|
| single-cycle | 1 | 1 long = 4 short | `4*4=16` |
| multi-cycle | variable | 1 short | `4+2+3+4=13` |
| pipelined | about 1 after fill | 1 short | about `5+4-1=8`, examples may count 7 depending stage model |

RISC vs CISC:

| | Instruction count | CPI | cycle time |
|---|---:|---:|---:|
| CISC | lower | higher | longer |
| RISC | higher | lower | shorter |

Modern x86 decodes x86 instrs into internal micro-ops, which are closer to RISC-like operations.

## 5. Logic Design Basics

| Element | Stores state? | Output depends on | Examples |
|---|---|---|---|
| combinational | no | current inputs only | gates, ALU, adder, mux, decoder |
| sequential/state | yes | stored state + inputs | PC, regs, regfile, memory, pipeline regs |

Binary signals: low voltage = 0, high voltage = 1. A bus uses one wire per bit.

HDLs: Verilog, SystemVerilog, VHDL, Chisel. HDL describes hardware structure/behavior and can be synthesized to a netlist.

### 5.1 Combinational Delay

Combinational logic is always active: output changes after propagation delay when inputs change.

==**Critical path**==: longest delay path from any input to any output. Clock period must cover state-element clk-to-Q + critical path + setup + skew.

### 5.2 Sequential Elements and Clocking

Registers update on a clock edge if write enable is asserted.

| Operation | Behavior |
|---|---|
| read regfile | combinational: selected register appears on read port |
| write regfile | sequential: value written on clock edge if `RegWr=1` |
| branch/store | no destination GPR write -> `RegWr=0` |

Edge-triggered methodology:

1. state outputs become stable after clock edge.
2. combinational logic computes during cycle.
3. result reaches next state element before next edge.
4. next edge updates state.

## 6. Abstract RV32I Datapath

Core components:

- PC.
- instruction memory / I-cache.
- register file.
- immediate generator.
- ALU.
- data memory / D-cache.
- adders for `PC+4` and branch/JAL target.
- muxes for ALU operand, writeback data, next PC.

Main mux choices:

| Mux | Choices | Used by |
|---|---|---|
| `PCSrc` | `PC+4`, `PC+imm`, `rs1+imm` | sequential, branch/JAL, JALR |
| `ALUSrc` | `reg[rs2]`, immediate | R-type vs I/load/store |
| `WBSel` | ALU result, memory data, `PC+4` | ALU/U, load, JAL/JALR link |

## 7. Processor Design Procedure

1. Analyze instruction set and required register transfers.
2. Choose datapath components and clocking methodology.
3. Assemble datapath to support each transfer.
4. Determine control settings for each instruction.
5. Build control logic.

### 7.1 Regularity in RISC-V Format

RISC-V simplifies datapath/control:

| Field | Position |
|---|---|
| opcode | bits `[6:0]` |
| `rd` | bits `[11:7]` when present |
| `rs1` | bits `[19:15]` when present |
| `rs2` | bits `[24:20]` when present |
| immediate | high bits, with store/branch using split pieces |

Fixed field positions allow decoding and regfile access in parallel with immediate extraction.

### 7.2 Datapath Requirements

Datapath must support:

- memory for instrs and data.
- 32 x 32b regfile with `rs1`, `rs2`, `rd`.
- PC storage.
- sign/zero extension.
- ALU add/sub/logic/compare/address calculation.
- add `4` or immediate to PC.
- data memory read/write.

### 7.3 Register File

| Port | Selection | Data |
|---|---|---|
| read A | `rs1` | `R[rs1]` |
| read B | `rs2` | `R[rs2]` |
| write W | `rd` + write enable | writeback data |

Quiz port counts:

- scalar RV32I: **2R/1W**.
- 2-wide integer superscalar: **4R/2W**.
- FMA has 3 FP source operands; 2-wide FMA needs **6R/2W** FP regfile.

## 8. Branch Datapath and Subtraction Trap

`beq rs1,rs2,imm`: compare `R[rs1]` and `R[rs2]`; if true, next PC = `PC + branch_imm`; else `PC+4`.

Why often two adders:

- one adder computes `PC+4`.
- another computes `PC+imm`.
- ALU may compare or perform other work.

### 8.1 Branch via Subtraction Trap

For equality, `rs1-rs2 == 0` is safe for equality. For signed less-than/greater-than, using only sign of subtraction can be wrong when subtraction overflows.

Correct signed less-than from subtraction:

```text
lt = sign(sum) ^ overflow
```

Many implementations use a true comparator or internal flags. RISC-V architectural state does not expose condition codes, and integer overflow itself does not trap.

## 9. Single-Cycle RISC-V Processor

Single-cycle rule: one instruction finishes every clock tick. All state elements update together at next rising edge.

Consequences:

- CPI = 1.
- clock period must cover slowest instr path.
- resources cannot be reused within same cycle.
- separate instruction and data memories/caches avoid IF/MEM conflict.
- regfile must read two regs and write one reg in same cycle.

Worst common path is `lw`:

```text
PC clk-to-Q
-> instruction memory
-> register file read
-> ALU address calc
-> data memory read
-> writeback mux
-> register file setup
```

Quiz: among `JALR`, `LW`, `SLL`, `LUI`, the single-cycle clock is dominated by **LW**.

## 10. Single-Cycle vs Multi-Cycle vs Pipeline

| Design | Strength | Weakness |
|---|---|---|
| single-cycle | simple CPI=1 | long clock, duplicated resources, slowest instr dominates |
| multi-cycle | shorter clock, resource reuse | CPI > 1 and variable |
| pipeline | high throughput | hazards, pipeline regs, control complexity |
| superscalar pipeline | CPI can be <1 | port pressure, issue/rename/scheduling complexity |

Multiply/divide are poor fits for single-cycle because they are iterative or need many replicated adders. Multi-cycle or separate pipelined/iterative units are cheaper.

## 11. Control Points Preview

Key control signals:

| Signal | Meaning |
|---|---|
| `RegWr` | write `rd` |
| `MemRd` | read data memory |
| `MemWr` | write data memory |
| `ALUSrc` | choose reg or imm as ALU operand B |
| `ALUCtrl` | ALU operation |
| `WBSel` | choose writeback source |
| `PCSrc` | choose next PC |

Example `add rd,rs1,rs2`: `RegWr=1`, `ALUSrc=0`, `WBSel=ALU`, `MemRd=0`, `MemWr=0`, `PCSrc=PC+4`.
