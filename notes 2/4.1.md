# 4.1: Processor Architecture & Logic Designs

## 1.1 Processors and Logic Designs

* So far, we have covered data representation and machine languages such as ISA and instruction encoding.
* This chapter will discuss the processor and basic logic designs for various microarchitectures.
* Computer architectures
  * ISA family: Intel x86, IBM 360, ARM, RISC-V, …
* Processor Microarchitectures
  * Different implementations of the same ISA: **Single cycle, Multi-cycle, Pipelined, Superscalar, Out-Of-Order, Speculative Execution, Cache Hierarchies, and Various Predictions.**
  * Different implementations support various performance and cost

| Intel x86 µ-arch | Multi-cycle | Pipelined | Super-scalar | Out-of-Order | OOO Era | SMT / Hyper-threading | SIMD / AVX Vector | Heterogeneous |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| Example | 8086 / 80286 / 80386 | 80486 | Pentium P5 | Pentium-pro P6 | P6, Pentium II, Core, Core2 | Nehalem | Sandy Bridge / Rocket Lake | Alder Lake / Raptor Lake (P-core + E-core) |

## 1.2 Computer Organization

- Data Path

  * Handles the actual processing of data (arithmetic operations, data movement, etc.), e.g., ALU, Register, Memory interface, Buses
  * Manages ==Data== Flow
  * The “Brawn”
* Control
  * Handles the flow of instructions and signals within the processor, such as PC, Instruction fetch, and Control signal generation
  * Manages ==Instruction== flow
  * The “Brain”

## 1.3 RV32I Data Path and Control

* We focus on the implementation of a subset of the RV32I core:
  * Memory reference instructions: `lw`, `sw`
  * Arithmetic/logical instructions: `add`, `sub`, `and`, `or`
  * Control flow instructions: `beq`, `jal`
* A subset, but sufficient to illustrate the key principles in creating a data path and designing the control.

## 1.4 Instruction Execution Cycle

```
Fetch → Decode → Execute
```

* Use the program counter (PC) to supply the instruction address and ==fetch== the instruction from memory
* ==Decode== the instruction (and read registers)
* ==Execute== the instruction
  * Use ALU to calculate
    * Arithmetic result
    * Memory address for load/store
    * Branch target address
  * Access data memory for load/store
  * PC ← target address or PC + 4

> **Cycle: ==Fetch-Decode-Execute==**

## Instruction Execution

* Use the program counter (PC) to supply the instruction address and ==fetch== the instruction from memory
* ==Decode== the instruction (and read registers)
* ==Execute== the instruction
  * Use ALU to calculate
    * Arithmetic result
    * Memory address for load/store
    * Branch target address
  * Access data memory for load/store
  * PC ← target address or PC + 4

==Cycle:==

==Fetch-Decode-Execute==

> Execute paths: **Ld/St** (memory access) · **Branch** (compare + PC update) · **ALU** (arithmetic/logic)

## 2.1 Single Cycle vs. Multi-Cycles

**Single cycle:** Each instruction is executed in a single clock cycle, which means that all operations—fetching, decoding, executing, accessing memory, and writing back—happen within that one cycle. This requires a longer clock cycle to accommodate the slowest instruction, often resulting in a lower clock frequency. (==The complexity of a given instruction can influence the cycle time.==  **This leads to the revolution of RISC architecture.**)

**Multi-cycle:** Instructions are broken down into multiple steps, each taking one clock cycle. This allows for a shorter clock cycle, higher clock frequency, and more efficient use of hardware resources.

> By the way, before RISC, cycle time was about *1us in the late 70's*
>
> After RISC, *MIPS(1985) cycle time was 40 ns, SPARC(1987), 28ns*

## ==CPU Time = Inst count X CPI X Clock cycle time==

![](assets%5CCA3060-4-1-ProcessorArchitecture_1.png)

---

clock time： the time to complete a task

## CISC vs RISC Examples

**CPU Time =** ==Inst count== X **CPI** X **Clock cycle time**

**CISC machines:** Lower instruction count, higher CPI, longer cycle time

==RISC machines== : higher instruction count, lower CPI, shorter cycle time

How about modern x86 processors? Their cycle times are pretty short.

Modern x86 processors take x86 instructions in, translate in hardware into micro-operations for execution (and cached). Those micro-operations are RISC.

## CPU Time = Inst count X CPI X Clock cycle time

Assuming 4 instructions to execute — `w (4 cycles), x (2 cycles), y (3 cycles), z (4 cycles)`:

| Implementation | CPI | Clock | Total |
|----------------|:---:|-------|-------|
| Single cycle | 1 | 1 long cycle (= 4 short) | 4 × 4 = **16 short cycles** |
| Multi-cycle | variable | 1 short cycle | (4+2+3+4) = **13 short cycles** |
| Pipelined | ~1 | 1 short cycle | fully overlapped → **7 short cycles** |

> Assume 1 long cycle = 4 short cycles.

## 3.1 Logic Design Basics

* ==IF you have no background in logic designs, please read Appendix A in the reference book==
* Information encoded in binary
  * Low voltage = 0, High voltage = 1
  * One wire per bit, Multi-bit data encoded on multi-wire buses
* ==Three major components:==
  * Combinational element
    * Operate on data
    * Output is a function of input
  * State (sequential) elements
    * Store information (如寄存器、存储器)
  * Clock signals
    * Regulate the updating of the memory elements

> **What is the difference between** *combinational* **logic and** *sequential* **logic?**
>
> One is **stateless** — output purely depends on the inputs (e.g. ALU)
>
> The other has **states** — output depends on both inputs and internal state (e.g. register)

---

The datapath elements in the MIPS implementation consist of two different types of logic elements: elements that operate on data values and elements that contain state.

Recall the previous figure, The instruction and data memories, as well as the registers, are all examples of state elements.

Logic components that contain state are also called sequential element, because their outputs depend on both their inputs and the contents of the internal state.

## 3.2 Logic Design Past and Now

At one time, hardware designers created circuit designs by drawing schematic diagrams of logic circuits (with paper and pencil) or writing Boolean expressions.

Nowadays, most designs are expressed in a ==hardware description language== (HDL), a textual notation that looks similar to a programming language, but is used to describe hardware structures rather than program behaviors.

The most commonly used HDLs are Verilog, SystemVerilog, VHDL, and Chisel.

The textbook defines Hardware Control Language (HCL) to describe control logics.

**SW 层：** High-Level Language (C/C++) → *Compiler* → Assembly / Machine language

**HW 层：** High-Level Description Language (Verilog/VHDL/Chisel) → Boolean equations + FSM → *Logical Synthesizer* (⊂ Silicon Compiler) → Netlist

---

SystemVerilog is a superset of Verilog, Chisel is used by SiFive for RISC-V
Recall the previous figure, The instruction and data memories, as well as the registers, are all examples of state elements.

Logic components that contain state are also called sequential element, because their outputs depend on both their inputs and the contents of the internal state.

### 3.3.1 Logic Gates

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_2.png" style="zoom:50%;" />

### 3.3.2 Combinational Elements

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_3.png" style="zoom:50%;" alt="v"/>

Logic gates and combinational circuits are always active: if the inputs change, the outputs also change after some delay.

The propagation delay of a combinational circuit is determined by the delay of the critical path, which is the longest path of logic gates from any input to any output.

### 3.3.3 Word-Level Combinational Circuits

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_7.png" style="zoom: 50%;" />

## 3.4 Sequential Elements

* Register: stores data in a circuit
  * Use a clock signal to determine when to update the stored value
  * Edge-triggered: **update when Clk changes from 0 to 1**

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_8.png" style="zoom: 67%;" />

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_6.png" style="zoom: 67%;" />

**For general purpose register updates, WRITE is 0 for what RV instructions?**

- **Branches and Stores**

## Clocking Methodology

* Combinational logic transforms data during clock cycles
  * Between clock edges, `edge triggered clocking`
  * Input from state elements, output to state element
  * Longest delay determines clock period

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_9.png" style="zoom: 33%;" />

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_10.png" style="zoom:33%;" />

*enable read and write in a same clock*

## 3.5 Abstract View of RV32I Subset

![](assets%5CCA3060-4-1-ProcessorArchitecture_11.png)

Key components: PC → Instruction Memory → Registers → ALU → Data Memory

Instruction types shown: `Load, Store, Add, BEQ`

Three MUX decisions to make:

1. **PC 来源** (`PCSrc`): branch taken or JAL → `PC + imm`; otherwise → `PC + 4`
2. **写回数据来源** (`WBsel`): load → Mem output; R-type → ALU output
3. **ALU 第二操作数** (`ALUSrc`): R-type → `reg[rs2]`; I-type → `imm`

## 4.1 How to Design a Processor

1. Analyze the required instruction set (data path requirements)

     * The register transfers give the meaning of each instruction Datapath must include a storage element
     * Datapath must support each register transfer
2. Select a set of data path components and establish a clocking methodology
3. Assemble data path meeting the requirements
4. Analyze the implementation of each instruction to determine the setting of control points affecting register transfers
5. Assemble the control logic

流程：**① Check data path requirements** → **② Assemble data path components** → **③ Add control signals**

## Step 1 - Analyze Instruction Set

* Subset of RISC-V instructions are 32 bits long with 4 formats

![](assets%5CCA3060-4-1-ProcessorArchitecture_13.png)

* The different fields are:
  * opcode: Operation of the instruction
  * rs1,rs2, rd: Source and destination registers
  * funct3: Selects variant of the “opcode” field
  * Immediate: for computing memory addresses (data and instruction)

### Logical Register Transfer

All start by fetching the instruction, reading registers, then use ALU => simplicity and regularity help

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_16.png" style="zoom:67%;" />

### ==Regularity in RISC-V Instruction Format==

Opcode: The major opcode is always in bits 0-6.

Destination register (rd): when present, is always in bits 7-11.

First source register (rs1): when present, is always in bits 15-19.

Second source register (rs2): when present, is always in bits 20-24.

Instructions are fixed length: 16 or 32

Immediate values are placed in the high bits of the instructions (branch and store have some bits use the “rd” field)

### Data Path Requirements

* After checking the register transfers, we can see that data path needs the followings:
  * **Memory**
    * Store instructions and data	(we have I-cache and D-cache)
  * **Registers (32 x 32b)**
    * Read RS1
    * Read RS2
    * Write RD
  * PC
  * Extender for zero- or sign-extension
  * Add and sub register or extended immediate (ALU)
  * Add 4 or extended immediate to PC

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_18.png" style="zoom: 50%;" />

* Register: Similar to the D Flip Flop except
  
  * N-bit input and output
  * Write Enable input
  
    * negated (0): Data Out will not change
  
    * asserted (1): Data Out will become Data In

### Storage Element - Register File

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_19.png" style="zoom: 50%;" />

* Register is selected by
  * Rs1 selects the register to put on busA (data)
  * Rs2 selects the register to put on busB (data)
  * Rd selects the register to be written via busW (data) when Write Enable is 1
* Clock input (CLK)
  * The CLK input is a factor ONLY during write operation
  * During read, behaves as a combinational circuit

> 🤔 How many **read ports** are needed for a 2-wide superscalar processor? **4.**

> 🤔 How many **read ports** are needed for the `fma` (fused multiply-add) instruction? **3.**

### Storage Element - Memory

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_20.png" style="zoom: 50%;" />

* Word is selected by
  * Address selects the word to put on Data Out
  * Write Enable = 1: address selects the memory word to be written via the Data In bus

## Step 3a  - Datapath Assembly

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_21.png" style="zoom: 33%;" />

* Instruction fetch unit: common operations
  * Fetch the instruction: `mem[PC]`
  * Update the program counter

### Datapath for Branch Operations

beq rs1, rs2, imm12

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_12.png" style="zoom:50%;" />

Why do we need two adders? Is one enough?

### ⚠️Branch with Subtraction

Intuitively, a **compare and branch** instruction could be handled by **a subtraction.** 

The above implementation is **cost-effective** because we have the ALU to support ADD/SUB operations. The same ALU could be used.

The trouble is, what if the subtraction caused an **overflow**? So, the sign of the result is incorrect, and cannot be used to decide the branch outcome.

If overflow, the trap handler can handle this, but RISC-V does not support such hardware traps. It requires explicit software checks. Does that mean we always generate a check for overflow for each compare and branch?

One way to handle this correctly is to use **a true comparison operation** instead of the subtraction. Yet in practice, most RV processor implementations will include **V (overflow) and C (Carry) flags** in a temporary status register if they use subtraction to determine conditions.

## Step 3b - Add and Subtract

* `R[rd] ← R[rs1] op R[rs2]`  —  e.g. `add rd, rs1, rs2`
  * Ra, Rb, Rw come from instruction’s rs1, rs2, and rd fields
  * ALU and RegWrite: control logic after decode

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_22.png" style="zoom:50%;" />

---

**控制信号**：控制单元会将 `RegWr`（写使能）信号设为 1，允许数据存入寄存器堆 。

**时钟触发**：虽然运算在周期内完成，但结果只有在**下一个时钟滴答（Clock Tick）**到来时，才会被正式写入目标寄存器 。

## Step 3c - Load/Store Operations

R[rd] ← Mem[R[rs1] + SignExt(imm12)] — e.g. `lw rd, rs1, imm12`

Instruction fields: `rs1` (base), `rd` (dest), `rs2` (store data), `imm12` (12-bit offset)

### Combine Mem and R-type Instructions

## 5.1 A Single Cycle RISC-V Processor

* On every tick of the clock, the processor executes one instruction
  * Current outputs of the state elements drive the inputs to the combinational logic.
  * The outputs of the combinational logic settle at the inputs to the state elements before the rising of the next clock edge.
* At the next rising edge of the clock
  * All state elements are updated with the combinational logic outputs
  * The execution moves to the next clock cycle

### A Single Cycle Data Path

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_15.png" style="zoom: 50%;" />

### Limitations of a Single-Cycle Implementation

Resources cannot be reused. So there are multiple adders – for PC updates, and for ALU.

Instruction memory and data memory are separated. In a single cycle, you may not go through the same combinational logic or the state more than once.

Do we need duplicated register file? How to read two registers, and write one at the same time? We will need two ==read ports== and one ==write port== .

A single cycle design, registers are updated at the rise of the clock, and the registers are updated, and then the outputs from registers are send to the combinational logic.

### Inefficiency in a Single Cycle Implementation

Some computations are iterative such as multiply and divide.

Multiply and divide may need to iterate through the same combinational logic resources many times. In a single-cycle implementation, the logic must be replicated many times.

The above implementation is way too **expensive**. So, one way to reduce the cost is to allow the implementation to iterate through the same resource using a counter. However, that means we need to use a faster clock to sync each step. Such instructions then become multi-cycle instructions.

Multi-cycle implementation is one step between single-cycle implementation and pipelined implementation.

> Example: `add rd, rs1, rs2` instruction (encoded as `0000000_rs2_rs1_000_rd_0110011`). Active signals: `RegWr=1`, `ALUSrc=0`, `WBsel=1`.

## Step 4 - Control Points and Signals

<img src="assets%5CCA3060-4-1-ProcessorArchitecture_23.png" style="zoom:50%;" />

