# 4.2 Control

## Exam Facts

- Control generates datapath selections and write enables from instruction bits.
- Most difficult signal: **ALU control**, because it depends on opcode/ALUOp + `funct3` + `funct7`.
- RISC-V regular format makes control easier: sources and destination in fixed bit positions.
- Single-cycle drawback: clock period must include slowest full instruction path.

## High-Level Control

- `PCSrc = BranchTaken or JAL/JALR`.
- Next PC sources: **`PC+4`**, **`PC+imm`** for branch/JAL, **`rs1+imm`** for JALR; not memory indirection.
- `RegWr = 0` for **branch/store**, 1 for ALU/load/jump/link.
- Loads: ALU computes address, memory read, WB from memory.
- Stores: ALU computes address, memory write, no reg write.
- Branches: compare regs, select `PC+imm` if taken, no reg write.

## ALU Control

ALU control uses:
- operation class / `ALUOp`;
- `funct3`;
- `funct7[5]` for `add/sub`, `srl/sra`.

Common mapping:
- load/store/address: `ADD`;
- branch compare/sub class: compare or `SUB`;
- R-type/I-type: decode `funct3/funct7`.

> [!IMPORTANT]
> `ADD`: `funct7=0000000`; `SUB`: `funct7=0100000`. Same `funct3`, different `funct7`.

## Single-Cycle Summary

- CPI=1, but long clock.
- RISC-V simplifies control: load/store use base+imm; ALU uses regs/imms; fields fixed.
- Critical path often `LW`: PC -> IMem -> RegFile -> ALU -> DMem -> WB mux -> RegFile setup.
