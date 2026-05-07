# Chapter 4.3: Pipelined Implementation

## 通用公式

(short cycle = n；流水线阶段数 = N)

- **单周期** (用最慢指令定周期)：$T=n\times T_{long}$
- **多周期** (指令数为 i)：$T=\sum_i CPI(i)\times T_{long}$
- **理想 N 级流水**：$T=(n+N-1)\times T_{stage\_long}$,，即 **drain = latency - 1**。
- **流水的提速 (speedup) 公式**：$\text{Speedup} = \frac{T_{single\_cycle}}{T_{pipelined}} = \frac{n\times T_{long}}{(n+N-1)\times T_{stage\_long}}$, or simply $$\frac{T_\text{long}}{T_\text{stage\_long}}$$，即各阶段平衡下，提速 N 倍。(如果各阶段耗时差异大，会导致提速下降)
- ⚠️ 流水相对于多周期非流水的提速： “平均 CPI” 倍。

> ⚠️ 流水线加速来自 throughput 增加，而不是 latency 减少，事实上单条指令的 latency 反而可能更大 (若不平衡)。

## 1.1 Pipelining

<img src="img%5CCA3060-4-3-Pipeline_0.png" style="zoom: 50%;" />

## 1.2 Five Stages of the Simple Data Path

`IF` : Instruction fetch from (instruction) memory

`ID` : Instruction decode & register read

`EX` : Execute operation or calculate address

`MEM` : Access (data) memory operand

`WB` : Write the result back to register

Initially, this partition is for **multi-cycle** implementation: an instruction can finish at stage 3, stage 4 or stage 5

| 完成阶段 | Stage 数 | Instruction Type | 说明 |
| :-: | :-: | :-: | :-: |
| **Stage 3（EX）** | 3 | B-type（beq, bne…） | 比较+跳转在 EX 完成，无需访存或写寄存器 |
| **Stage 4（MEM）** | 4 | S-type（sw, sh, sb…） | 写入内存后完成，不写回寄存器 |
| **Stage 5（WB）** | 5 | R-type（add, sub, and…） | EX 计算结果写回寄存器，MEM 阶段空置 |
| | 5 | I-type ALU（addi, ori…） | 同 R-type，MEM 空置 |
| | 5 | I-type Load（lw, lh, lb…） | 需要 MEM 读内存，再 WB 写寄存器 |
| | 5 | J-type（jal） | 需要 WB 将 PC+4 写回 rd |
| | 5 | U-type（lui, auipc） | 需要 WB 写回寄存器 |

| 有效阶段数 | Instruction Type | 使用的阶段 | 有效阶段数 |
| :-: | :-: | :-: | :-: |
| **3 stages** | B-type（beq, bne, blt…） | IF → ID → EX | **3 stages** |
| **4 stages** | S-type（sw, sh, sb…） | IF → ID → EX → MEM | **4 stages** |
| | R-type（add, sub, and…） | IF → ID → EX → WB | |
| | I-type ALU（addi, ori, slli…） | IF → ID → EX → WB | |
| | J-type（jal） | IF → ID → EX → WB | |
| | U-type（lui, auipc） | IF → ID → EX → WB | |
| **5 stages** | I-type Load（lw, lh, lb, lbu, lhu） | IF → ID → EX → MEM → WB | **5 stages** |

### Divide the Single Cycle Data Path into 5 Stages

<img src="img%5CCA3060-4-3-Pipeline_1.png" style="zoom: 67%;" />

### Instruction Timing and Clock Cycle Time

* Assume time for a stage is
  * 100 ps for register to read or write
  * 200 ps for other stages (Mem and ALU)

Maximum clock frequency for single-cycle implementation= 1/800ps = 1.25 GHz (==the longest instruction==)

For multi-cycle implementation, 1/200ps = 5 GHz (==the longest stage==)

### Overlapped Execution in Pipeline

| Instruction | Cycle 1 | Cycle 2 | Cycle 3 | Cycle 4 | Cycle 5 | Cycle 6 | Cycle 7 | Cycle 8 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| LW  | IF | ID | EXE | MEM | WB | | | |
| ADD | | IF | ID | EXE | MEM | WB | | |
| BEQ | | | IF | ID | EXE | MEM | WB | |
| SUB | | | | IF | ID | EXE | MEM | WB |

## 1.3 Single cycle vs. multi-cycle vs. pipeline

<img src="img%5CCA3060-4-3-Pipeline_2.png" style="zoom: 50%;" />

### Pipeline Speedup

- If all stages are balanced, i.e., all take the same time, in an ideal situation; if not, speedup would be less. The speedup is a result of increased ==throughput== .

==Instruction Latency==, the time for each instruction to be executed — it does not decrease with pipelining; in fact, it may even increase.
$$
\text{Time between instructions}_{pipelined} = \frac{\text{Time between instructions}_{nonpipelined}}{\text{Number of pipeline stages}}
$$


## 1.4 Pipeline-oriented ISA Design

* RISC-V ISA is designed for pipelining
  * All ==instructions== are fixed length: ==32-bits== **(**except for the C extension **)**
    * Easier to fetch and decode in one cycle
    * c.f. x86: 1- to 17-byte instructions
  * Few and ==regular== instruction ==formats==
    * Decode and read registers in one step
  * Only load/store instructions accessing memory
    * ==Calculate address== in the 3rd stage, ==access memory== in the 4th stage
    * If the operand is in memory, additional execution stages are needed after stage 4.
  * Instructions are simple and do not require a large number of steps

## 1.5 Pipeline Lessons

* Pipeline does not help the ==latency== of a single instruction, but the ==throughput== of the entire program
* Pipeline rate is limited by the ==slowest== stage; unbalanced stage length limits the perfect speedup
* ==Multiple== tasks are working at the same time using different resources
* Potential/Ideal speedup = ==Number of pipeline stages==
* Time to “ ==fill== ” & “ ==drain== ” the pipeline reduces speedup
  * Need to reduce possible fill and drain (e.g., I-cache misses and branch
  * misprediction)
* Avoid pipeline ==bubbles== from data and control dependencies

## Pipeline Everywhere

* Aside from the instruction pipeline, many other areas have implemented pipelined architectures.
  * DRAM pipeline
    * Row activation, column selection, data transfer
  * Cache pipeline
    * Address decoding, Way selection, tag match, data retrieval
  * Floating point unit pipeline
    * Exponent alignment, operation, normalization, rounding, …
  * GPU pipeline
    * vertex processing, rasterization, fragment processing
  * Network pipeline
    * packet header processing, routing table lookup, and packet forwarding
* **Conclusion**: If you need to have a higher throughput, think about pipelining.

## 2.1 Pipelined RV32I Data Path

### What happens Sequentially? Simultaneously?

![](img%5CCA3060-4-3-Pipeline_19.png)

> 同一个时钟周期内，==前半周期写、后半周期读==

## 2.2 Latency vs Throughput

**Latency:**

- Single cycle: 800 ps
- Pipelined: 200 ps × 5 cycles = 1000 ps

**Throughput:**

- Single cycle: one instruction every 800 ps
- Pipelined: one instruction every 200 ps (4× improvement)

## What happens to long latency operations?

Two options:

1. **Stall:** the next instruction stalls at the EXE stage.
2. **Separate long-latency pipeline:** subsequent instructions continue to proceed (e.g. FP instructions).

Be aware: instructions are typically ==retired at the WB stage in order==. So even if later instructions complete sooner, they must wait at WB — this is due to the possibility of traps.

RISC-V avoids arithmetic exceptions, so ==out-of-order retirement is viable==.

## Multiple Instructions On-the-Fly

- Which Rd to write? The Rd from the **WB** stage or the ID stage?
- Which immediates to use? Which rs1/rs2? **EX**
- From the instruction at EXE stage or from ID stage?

| **问题**         | **核心答案**                       | **存放位置**  |
| ---------------- | ---------------------------------- | ------------- |
| **Rd 写回地址**  | **WB 阶段**的指令                  | MEM/WB 寄存器 |
| **Immediate**    | **EX 阶段**的指令                  | ID/EX 寄存器  |
| **rs1/rs2 数据** | **EX 阶段**使用 ID/EX 寄存器的旧值 | ID/EX 寄存器  |

## Key to Pipelining: Inserting Pipeline Registers

- **IF/ID 寄存器**：保存从内存取出的指令（inst）和对应的 PC 值，传给下一级译码 。
- **ID/EX 寄存器**：将译码后的寄存器数据（dataR1/R2）、立即数（imm）和指令信息传给执行单元 。
- **EX/MEM 寄存器**：将 ALU 计算结果、要存储的数据（rs2）传给访存阶段 。
- **MEM/WB 寄存器**：将从内存读出的数据或 ALU 结果传给写回阶段，同时也要传回指令信息以确定写回哪个寄存器（rd） 。

## Instruction Fetch/Instruction Decode Pipeline Register

<img src="img%5CCA3060-4-3-Pipeline_25.png" style="zoom:50%;" />

## ID/EX Pipeline Register

<img src="img%5CCA3060-4-3-Pipeline_26.png" style="zoom:50%;" />

## EX/MEM Pipeline Register

<img src="img%5CCA3060-4-3-Pipeline_27.png" style="zoom: 50%;" />

> Note: JAL instruction uses this stage to pass PC+4 forward to WB.

## MEM/WB Pipeline Register

![](img%5CCA3060-4-3-Pipeline_28.png)

## Control Signals in Pipelined Data Path

Control signals are derived from instruction bits, that is, after the ID stage.

![](img%5CCA3060-4-3-Pipeline_29.png)

Control information for later stages are also stored in the pipeline registers

| **阶段分组**  | **控制信号**  | **关键取值与判定条件**                                       |
| ------------- | ------------- | ------------------------------------------------------------ |
| **EX~ctrl~**  | **ALUSel**    | 根据 `funct3/funct7` 决定运算类型（如 0000 为 Add）。        |
|               | **Asel**      | **0**: 来自寄存器 `DataA`；**1**: 来自 `PC`（用于 `auipc/jal`）。 |
|               | **Bsel**      | **0**: 来自寄存器 `DataB`；**1**: 来自 `Immediate`（用于 I-type/S-type）。 |
|               | **BrUn**      | **1**: 无符号比较；**0**: 有符号比较（用于 `bltu/bgeu`）。   |
| **MEM~ctrl~** | **MemRW**     | **1 (Write)**: `sw`；**0 (Read)**: `lw`；**unused**: R-type。 |
|               | **PCSel**     | **1**: 跳转（Branch taken/Jal）；**0**: 顺序执行 `PC+4`。    |
|               | **BrEq/BrLT** | **True**: 分支条件成立；**False**: 条件不成立（由 Branch Comp 产生）。 |
| **WB~ctrl~**  | **RegWEn**    | **1**: 写回寄存器（R/I/U/J-type）；**0**: 不写回（S/B-type）。 |
|               | **WBSel**     | **0**: 写回 `ALU` 结果；**1**: 写回 `DataR` (Mem)；**2**: 写回 `PC+4`。 |
