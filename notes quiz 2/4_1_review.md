# Lec 4.1: Processor Architecture & Logic Design

## Exam Facts

- ==**Microarchitecture**==: implementation of an ISA: single-cycle, multi-cycle, pipeline, superscalar, OoO, caches, predictors.
- ==**Datapath**==: moves/computes data. ==**Control**==: selects paths and write enables.
- **Execution cycle**: `fetch -> decode/read regs -> execute -> memory -> writeback -> update PC`.
- **CPU time**: `IC x CPI x clock cycle time`.
- **Single-cycle**: `CPI=1`; clock period must cover slowest instr, usually `lw`.
- **Multi-cycle**: shorter clock, reused resources, variable CPI.
- **Pipeline**: overlapped instrs, high throughput, hazards add stalls.
- **CPI < 1**: only superscalar/multiple-issue style, not ordinary scalar pipeline.
- **Throughput order**: **superscalar+pipelined > pipelined > multi-cycle > single-cycle**.
- **Scalar RV32I regfile**: **2 read ports + 1 write port**; reads are combinational, writes are clocked.
- **Branch signed compare**: subtraction sign can be wrong on overflow; use comparator or `sign(A-B)^overflow`.

## 1. Processors and Logic Designs

| Level | Examples |
|---|---|
| ISA | RISC-V, ARM, other software-visible contracts |
| microarchitecture | single-cycle, pipeline, superscalar, OoO, SMT, SIMD |
| logic/circuit | mux, adder, regfile, SRAM, gates |

Same ISA can have many microarchitectures with different cost/performance.

## 2. Computer Organization

| Part | Job | Examples |
|---|---|---|
| datapath | stores/moves/computes values | PC, regfile, ALU, memories, adders, muxes |
| control | decides actions | `RegWr`, `MemWr`, `ALUSrc`, `WBSel`, `PCSrc`, `ALUCtrl` |

## 3. RV32I Subset and Execution Cycle

Teaching subset:

| Class | Instrs |
|---|---|
| memory | `lw`, `sw` |
| ALU | `add`, `sub`, `and`, `or` |
| control | `beq`, `jal` |

Logical work:

```text
IF:  instr = IMem[PC]
ID:  decode, read R[rs1], R[rs2], make imm
EX:  ALU op / address / branch compare
MEM: load/store data memory
WB:  write rd
PC:  PC+4 or target
```

## 4. Performance Model

$$
CPU\ Time=Instruction\ Count\times CPI\times Clock\ Cycle\ Time
$$

| Design | CPI | Clock | Notes |
|---|---:|---|---|
| single-cycle | 1 | slowest instr | simple, inefficient |
| multi-cycle | variable | one stage | resource reuse |
| pipeline | about 1 | slowest stage + reg overhead | hazards matter |
| superscalar | <1 possible | complex | multiple issue/retire |

RISC vs CISC:

```text
RISC: more simple instrs, lower CPI/cycle
CISC: fewer complex instrs, higher CPI/cycle/decode cost
```

## 5. Logic Design Basics

| Element | Stores state? | Output depends on |
|---|---|---|
| combinational | no | current inputs only |
| sequential | yes | stored state + inputs |

Examples:

- **Combinational**: ALU, adder, mux, decoder.
- **Sequential**: PC, regs, regfile writes, memories, pipeline regs.

### 5.1 Clocking

```text
clock edge -> state outputs stable -> combinational logic -> setup before next edge
```

Clock period must cover clk-to-Q + critical path + setup + skew.

Regfile timing:

| Action | Timing |
|---|---|
| read `rs1/rs2` | combinational after addresses settle |
| write `rd` | clock edge when `RegWr=1` |
| branches/stores | `RegWr=0` |

## 6. Abstract RV32I Datapath

Required components:

- PC and next-PC mux.
- instr memory/I-cache.
- regfile (`rs1`, `rs2`, `rd`, 2R/1W).
- immediate generator.
- ALU.
- data memory/D-cache.
- adders for `PC+4` and `PC+imm`.
- writeback mux.

| Mux | Choices |
|---|---|
| `PCSrc` | `PC+4`, `PC+imm`, `(rs1+imm)&~1` |
| `ALUSrcB` | `R[rs2]` or imm |
| `WBSel` | ALU, memory, `PC+4`, imm/U result |

## 7. Processor Design Procedure

1. Analyze ISA register transfers.
2. Pick datapath state/combinational blocks.
3. Assemble datapath for each instr class.
4. Determine control settings.
5. Build control logic.

### 7.1 RISC-V Regularity

Fixed field positions:

| Field | Bits |
|---|---|
| opcode | `[6:0]` |
| `rd` | `[11:7]` |
| `funct3` | `[14:12]` |
| `rs1` | `[19:15]` |
| `rs2` | `[24:20]` |

This lets regfile read begin before full decode finishes.

### 7.2 Register File Ports

| Machine | Needed ports |
|---|---|
| scalar RV32I | 2R/1W |
| 2-issue scalar integer | about 4R/2W |
| 2-issue FMA | 6R/2W FP regfile |

## 8. Branch Datapath and Subtraction Trap

`beq rs1,rs2,imm`: compare two regs; if true `PC=PC+B-imm`, else `PC+4`.

Why two adders in EX/IF datapath:

- one for `PC+4`.
- one for `PC+imm`.
- ALU/comparator may be busy comparing.

### 8.1 Signed Compare Trap

Using sign of `A-B` for signed `<` is wrong on overflow.

```text
signed_lt = sign(A-B) ^ overflow
```

Equality via subtraction zero is safe.

## 9. Single-Cycle RISC-V Processor

Single-cycle rule: all instrs finish in one long cycle; all state updates at clock edge.

Slowest common path:

```text
PC -> IMem -> RegFile -> ALU address -> DMem -> WB mux -> RegFile setup
```

Among `JALR`, `LW`, `SLL`, `LUI`, **`LW`** determines clock rate.

Limitations:

- slowest instr sets clock for all.
- resources cannot be reused in same cycle.
- result is committed on the clock edge after the combinational path, not early inside the cycle.
- separate I/D memories or caches avoid IF/MEM structural hazard.
- multiply/divide bad fit for one cycle.

## 10. Single-Cycle vs Multi-Cycle vs Pipeline

| Design | Strength | Weakness |
|---|---|---|
| single-cycle | simplest, CPI=1 | long clock |
| multi-cycle | short clock, reuse | CPI>1 |
| pipeline | throughput | hazards, pipeline regs |
| superscalar | CPI<1 possible | ports/issue/rename/scheduling |

## 11. Control Points Preview

| Signal | Meaning |
|---|---|
| `RegWr` | write `rd` |
| `MemRd/MemWr` | data memory access |
| `ALUSrc` | operand B mux |
| `ALUCtrl` | ALU op |
| `WBSel` | WB data mux |
| `PCSrc` | next PC mux |
