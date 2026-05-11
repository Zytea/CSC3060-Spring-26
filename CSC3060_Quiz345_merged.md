# CSC3060 Quiz 3–5 Merged Markdown

## Quiz3-2026 (2)

**CSC3060 – Computer Systems / Quiz 3**

### Section I
*(Single Answer)*

### Q1. Three common hazards can often reduce the efficiency of a pipelined datapath. Which of the following is not one of the three hazards?

A. Structure hazards
B. Forward hazards
C. Data hazards
D. Control hazards

**Answer:** 2 = B — Forward hazards

> 位于(Exam Facts, notes quiz 2/4_4_review.md), 解释是因为 review 明确列出流水线三类 hazard 是 Structural、Data、Control；Forwarding/Bypassing 是解决 data hazard 的技术，不是第四类 hazard，所以 Forward hazards 不属于三大类。

### Q2. Which extension, if absent, would make RISC-V a fixed-length ISA?

A. A extension
B. B extension
C. C extension
D. D extension
E. E extension

**Answer:** 3 = C — C extension

> 位于(Exam Facts; 1.3 Bases and Extensions, notes quiz 1/3_review.md), 解释是因为 RISC-V base 指令主要是固定 32-bit，`C` extension 提供 16-bit compressed instructions；没有 `C` 时就不会出现压缩 16-bit 指令，因此 ISA 会保持固定长度。

### Q3. Which of the following microarchitectures could have a CPI lower than 1?

A. Single-cycle data path implementation
B. Multi-cycle data path implementation
C. Pipelined implementation
D. Superscalar implementation

**Answer:** 4 = D — Superscalar implementation

> 位于(3. Performance Model, notes quiz 2/4_1_review.md), 解释是因为 review 写明 CPI < 1 只有 superscalar / multi-issue 才可能做到；single-cycle、multi-cycle、普通 pipeline 都不能稳定低于 1。

### Q4. When comparing the performance of single-cycle, multi-cycle, and pipelined data paths, which statements is correct?

A. Single-cycle > Multi-cycle > Pipelined
B. Pipelined > Multi-cycle > Single-cycle
C. Pipelined > Single-cycle > Multi-cycle
D. Multi-cycle > Pipelined > Single-cycle

**Answer:** 2 = B — Pipelined > Multi-cycle > Single-cycle

> 位于(Exam Facts; 3. Performance Model, notes quiz 2/4_1_review.md), 解释是因为 review 给出的吞吐量顺序是 superscalar > pipelined > multi-cycle > single-cycle；本题比较后三者，所以 pipelined 最高，multi-cycle 次之，single-cycle 最低。

### Q5. Frequent pipeline stalls are likely to occur when traversing a long linked list due to

A. Delay hazards
B. Date hazards
C. Data hazards
D. Control hazards

**Answer:** 3 = C — Data hazards

> 位于(Exam Facts, notes quiz 2/4_4_review.md), 解释是因为 linked-list pointer chase 被标注为 data hazard only，本质是 `p = p->next` 形成连续 load-use 依赖链。

### Q6. Branch prediction should be carried out during which stages of the pipeline?

A. IF
B. ID
C. EXE
D. MEM
E. WB

**Answer:** 1 = A — IF

> 位于(Exam Facts, notes quiz 2/4_4_review.md), 解释是因为分支预测必须在 IF 阶段预测 next PC，才能决定下一条该取哪条指令；等到 ID/EX 已经太晚。

### Q7. Which of the following functional units is the most difficult to pipeline?

A. Integer multiply
B. Floating point add
C. Floating point multiply
D. Integer divide
E. Fused multiply-and-accumulate (FMAC)

**Answer:** 4 = D — Integer divide

> 位于(5.4 Multiply / Divide, notes quiz 1/2_review.md), 解释是因为 divider 被描述为 iterative、control-heavy、hardest to pipeline；integer divide 延迟也远高于加法、乘法和常见 FP 单元。

### Q8. A Von Neumann machine is depicted on the right. What is the so-called “Von Neumann bottleneck” in a pipelined data path?

A. It is like a structural hazard
B. It is like a data hazard
C. It is like a control hazard
D. It is like a memory hazard

**Answer:** 1 = A — It is like a structural hazard

> 位于(Exam Facts; 1. Structural Hazards, notes quiz 2/4_4_review.md), 解释是因为 Von Neumann bottleneck 在流水线里表现为 IF 取指和 MEM 访存争用同一存储器资源，因此等价于 structural hazard。

### Q9. Which of the following microarchitectures is unlikely to be used by Apple’s M4 processor (i.e., the latest one)?

A. Dynamic branch prediction
B. Pipelined data path
C. Static branch prediction
D. BTB-based prediction

**Answer:** 3 = C — Static branch prediction

> 位于(4.1 Accuracy, notes quiz 2/4_4_review.md), 解释是因为 review 把 TAGE 等动态预测器列为 Intel/AMD/ARM/Apple 这类现代处理器使用的高精度方案；static branch prediction 精度低，最不像现代 Apple M 系列处理器的主要微架构技术。

### Q10. Which RV32I instruction has the greatest impact on the clock rate of the single-cycle data path?

A. JALR X0, 0(X2)
B. LW X1,4(X2)
C. SLL X1,X2,X3
D. LUI X5, 0x12345

**Answer:** 2 = B — LW X1,4(X2)

> 位于(7. Single-Cycle Limits & Comparison, notes quiz 2/4_1_review.md), 解释是因为 single-cycle 的时钟周期必须容纳最慢指令，而 review 明确指出 `LW` 的路径最长：PC -> IMem -> Regfile -> ALU -> DMem -> WB mux -> Regfile setup。

### Section II
*(multiple answers)*

### Q11. MIPS (Microprocessor without Interlocked Pipeline Stages) reduces hardware cost by using software to avoid hazards, making the processor cheaper and faster. What was the primary reason for its lack of success?

A. Compatibility and Scalability
B. Non-competitive performance
C. Incompatible with x86
D. John Hennessy was too occupied.

**Answer:** 1 = A — Compatibility and Scalability

> 位于(2.4 Compiler Scheduling Limits, notes quiz 2/4_4_review.md), 解释是因为 review 对 MIPS history 的结论是 compiler-only/no interlock 的思路最终受 compatibility 与 scalability 限制。

### Q12. In which cases should callee-saved registers be considered for allocation?

A. Leaf routines
B. A temporary value used heavily across multiple calls
C. Temporaries in expression evaluation
D. C Strings
E. Local variables

**Answer:** 2,5 = B — A temporary value used heavily across multiple calls; E — Local variables

> 位于(Exam Facts; 6. Allocation Quiz Anchors, notes quiz 1/4_review.md), 解释是因为 callee-saved registers 适合长期活跃的 local scalars，以及跨多个 calls 仍要保留的重复使用值；leaf temporaries 和 expression temporaries 更适合 caller-saved。

### Q13. Which of the following is a common hardware technique to reduce the penalty of data hazards?

A. Data forwarding
B. A deeper pipeline
C. Data Bypassing
D. Compiler code scheduling

**Answer:** 1,3 = A — Data forwarding; C — Data Bypassing

> 位于(Exam Facts; 2. Data Hazards, notes quiz 2/4_4_review.md), 解释是因为 forwarding/bypassing 是硬件层面把后面阶段的结果直接送回 EX 阶段的 data hazard 修复技术；deeper pipeline 不是修复，compiler scheduling 属于软件技术。

### Q14. Most modern microprocessors have split I/D caches. Why?

A. To avoid structural hazards in the pipeline
B. To get a higher cache hit rate
C. To increase reliability
D. To increase the cache access bandwidth

**Answer:** 1,4 = A — To avoid structural hazards in the pipeline; D — To increase the cache access bandwidth

> 位于(Exam Facts; 1. Structural Hazards, notes quiz 2/4_4_review.md), 解释是因为 split I/D cache 的目的就是避免 IF 取指和 MEM 数据访问同时争用同一 cache，并增加访问带宽；review 明确说不是为了提高 hit rate 或 reliability。

### Q15. Compared to a pipelined data path, a single-cycle data path typically has:

A. Higher throughput
B. Faster clock rate
C. Simple control logic
D. A longer instruction latency
E. A lower CPI

**Answer:** 3,5 = C — Simple control logic; E — A lower CPI

> 位于(7. Single-Cycle Limits & Comparison, notes quiz 2/4_1_review.md), 解释是因为 single-cycle CPI 固定为 1，控制逻辑也更简单；pipeline 的优势是更高 throughput 和更短 clock，而不是单条指令 latency 或更低 CPI。

### Q16. Function A calls function B. In function A, three registers live across the call to B: $s1, $t0, and $a1. What registers must be saved/restored across the call?

A. $s1
B. $t0
C. $a1
D. None of them

**Answer:** 2,3 = B — $t0; C — $a1

> 位于(Exam Facts; 6. Allocation Quiz Anchors, notes quiz 1/4_review.md), 解释是因为 `t0` 和 `a1` 属于 caller-saved，若 A 在调用 B 后还要用它们，A 必须自己保存；`s1` 属于 callee-saved，由 B 在修改时负责恢复。

### Q17. What are the essential principles of designing a pipelined datapath?

A. Multi-stage partitioning
B. Overlapped execution
C. Increased throughput
D. Lowered instruction latency
E. Improved resource utilization

**Answer:** 1,2,3,5 = A — Multi-stage partitioning; B — Overlapped execution; C — Increased throughput; E — Improved resource utilization

> 位于(Exam Facts; 1. Five Stages & Pipeline Registers, notes quiz 2/4_3_review.md), 解释是因为流水线把执行拆成多个 stages，并让多条指令 overlapped execution，从而提高 throughput 和资源利用率；review 也强调 pipeline 提升 throughput 而不是降低单条指令 latency。

### Q18. Which of the following are techniques used to reduce the penalty caused by control hazards?

A. Pipeline stalls
B. BTB (Branch Target Buffer)
C. BHT (Branch History Table)
D. Data Bypassing
E. Data forwarding

**Answer:** 2,3 = B — BTB (Branch Target Buffer); C — BHT (Branch History Table)

> 位于(3. Control Hazards; 4.5 BHT vs BTB vs RAS, notes quiz 2/4_4_review.md), 解释是因为 BHT 预测方向、BTB 预测目标地址，都是降低 control hazard penalty 的分支预测结构；data forwarding/bypassing 解决的是 data hazard。

### Q19. What (HW/SW) strategies can reduce pipeline stalls caused by data hazards?

A. Deeper pipeline
B. Data forwarding
C. Out-of-Order instruction execution
D. Compiler instruction scheduling
E. Branch prediction

**Answer:** 2,3,4 = B — Data forwarding; C — Out-of-Order instruction execution; D — Compiler instruction scheduling

> 位于(Exam Facts; 2. Data Hazards, notes quiz 2/4_4_review.md), 解释是因为 review 把 data hazard 的修复列为 forwarding/bypass、stall、OoO execution 和 compiler scheduling；deeper pipeline 会加重依赖惩罚，branch prediction 属于 control hazard。

### Q20. Which of the following are considered “Microarchitecture states”?

A. BHT
B. BTB
C. Floating-point registers
D. PC
E. Pipelined registers

**Answer:** 1,2,5 = A — BHT; B — BTB; E — Pipelined registers

> 位于(2.2 Architectural State, notes quiz 1/3_review.md), 解释是因为 BHT、BTB、pipeline registers 被列为 microarchitectural state，可再生且中断时不保存；PC 和 FP registers 属于 architectural state。

### Q21. In practice, what might occur if we increase the number of pipeline stages from 5 to 20?

A. The clock rate becomes 4X faster
B. The branch misprediction penalty would increase
C. The data hazard penalty would increase
D. The CPI would increase
E. More pipelined registers will be required

**Answer:** 2,3,4,5 = B — The branch misprediction penalty would increase; C — The data hazard penalty would increase; D — The CPI would increase; E — More pipelined registers will be required

> 位于(Exam Facts, notes quiz 2/4_3_review.md), 解释是因为 review 明确提醒 deep-pipe trap：5 到 20 stages 不等于 4 倍提速，branch penalty/data penalty 增加，CPI 可能增加，还需要更多 pipeline registers。

### Q22. What information is used to index a branch prediction table in correlated branch prediction (also known as 2-level adaptive branch prediction)?

A. Current PC
B. Branch instruction address
C. PC+4
D. Global branch history

**Answer:** 1,4 = A — Current PC; D — Global branch history

> 位于(4.3 Correlated / 2-Level, notes quiz 2/4_4_review.md), 解释是因为 correlated predictor 使用 global branch history register，并用 PC XOR GHR 索引预测表，所以 current PC 和 global branch history 都参与索引。

### Q23. Which of the following could be effective for static branch predictions?

A. Predict a backward branch taken
B. Predict a forward “beq  rs1, x0” not taken
C. Predict the “beq  rs1, rs2” not taken
D. Predict the blt instructions taken
E. Predict the JALR instruction not taken

**Answer:** 1,2 = A — Predict a backward branch taken; B — Predict a forward “beq  rs1, x0” not taken

> 位于(4.1 Accuracy, notes quiz 2/4_4_review.md), 解释是因为 review 的 static rules 写明 backward branch taken 常用于 loop，forward `beq rs1,x0` 预测 not taken；普通 `beq rs1,rs2`、`blt`、`JALR` 没有这些静态信息。

### Q24. Why is a BHT (Branch History Table) usually untagged?

A. Simple
B. Fast access
C. Consume less energy
D. Good for high-performance microprocessors
E. Cost-effective

**Answer:** 1,2,3,5 = A — Simple; B — Fast access; C — Consume less energy; E — Cost-effective

> 位于(4.1 Accuracy, notes quiz 2/4_4_review.md), 解释是因为 untagged BHT 的优点是结构简单、IF 阶段访问快、能耗低、成本低；review 还说明高性能处理器不会仅靠这种简单 untagged BHT。

### Q25. Which of the following control signals must be propagated through the pipelined registers to the WB stage?

A. Rd (target register)
B. WRen (write-enable)
C. WBsel (Write back selection)
D. ALUctl (ALU control)

**Answer:** 1,2,3 = A — Rd (target register); B — WRen (write-enable); C — WBsel (Write back selection)

> 位于(Exam Facts, notes quiz 2/4_2_review.md), 解释是因为 WB-stage 需要知道写哪个 rd、是否 RegWr、以及 WBSel 从哪里写回；ALU control 在 EX 阶段用完后不会继续传到 WB。

### Q26. Which of the following statements about single-cycle data path implementation is true?

A. CPI is 1, every instruction must finish in one cycle
B. The clock cycle must accommodate the slowest instruction
C. The resources in the data path cannot be reused in the same cycle
D. The result is written back to the register file in the same clock cycle.

**Answer:** 1,2,3 = A — CPI is 1, every instruction must finish in one cycle; B — The clock cycle must accommodate the slowest instruction; C — The resources in the data path cannot be reused in the same cycle

> 位于(Exam Facts; 7. Single-Cycle Limits & Comparison, notes quiz 2/4_1_review.md), 解释是因为 single-cycle 每条指令一个周期完成，CPI=1，clock 由最慢指令决定，并且同一周期资源不能重复使用；这也是 single-cycle 简单但低效的核心限制。

### Q27. A basic block has 50 instructions; how many legal schedules are possible?

A. In the best case, there is only one schedule
B. In the best case, there are 50 legal schedules
C. In the worst case, there are 50! possible schedules
D. It is quadratic; the worst case has 50² schedules

**Answer:** 1,3 = A — In the best case, there is only one schedule; C — In the worst case, there are 50! possible schedules

> 位于(Exam Facts, notes quiz 2/4_5_review.md), 解释是因为 schedule count 的结论是：如果 50 条指令形成完整依赖链，合法调度只有 1 个；如果互相独立，最坏可有 50! 个拓扑排序。

### Q28. A compiler can reorder instructions to avoid data hazards. However, what limitations does it often encounter?

A. Code scheduling is error-prone
B. Memory dependencies may not be known due to possible memory aliasing
C. Structural hazards are hard to deal with
D. Memory operation latencies are unknown and non-deterministic

**Answer:** 2,4 = B — Memory dependencies may not be known due to possible memory aliasing; D — Memory operation latencies are unknown and non-deterministic

> 位于(Exam Facts; 2. Memory Aliasing, notes quiz 2/4_5_review.md), 解释是因为 compiler scheduling 不能随意跨过可能 alias 的 load/store，且 cache hit/miss 造成 memory latency 不确定，所以会限制重排能力。

### Q29. In our RV32I pipelined data path, which stage requires two adders?

A. IF
B. ID
C. EXE
D. MEM
E. WB

**Answer:** 3 = C — EXE

> 位于(6. Branch Datapath, notes quiz 2/4_1_review.md), 解释是因为 EX 阶段需要同时计算 PC+4 和 PC+B-imm，而 ALU 还可能用于比较/地址计算，所以该设计需要两个 adders。

### Q30. When running a binary tree search on a pipelined data path, what hazards are likely to occur?

A. Dependence hazards
B. Structure hazards
C. Data hazards
D. Control hazards
E. Branch hazards

**Answer:** 3,4 = C — Data hazards; D — Control hazards

> 位于(Exam Facts, notes quiz 2/4_4_review.md), 解释是因为 binary-tree search 同时有 pointer load-use 造成的数据依赖，又有根据 key compare 决定方向的 branch，因此 data hazard 和 control hazard 都会出现。

### Q31. Why do some RV pipelined data path designs utilize a comparison unit to execute the compare-and-branch instructions instead of using the standard ALU?

A. To avoid structural hazards
B. Avoid setting the wrong ‘taken/not-taken’ due to integer subtraction overflows.
C. The ALU at the EXE stage is needed for R-type instructions and Load/Store instructions
D. Comparison operation does not trap

**Answer:** 2 = B — Avoid setting the wrong ‘taken/not-taken’ due to integer subtraction overflows.

> 位于(Exam Facts; 6. Branch Datapath, notes quiz 2/4_1_review.md), 解释是因为用 ALU subtraction 的 sign(A-B) 判断大小会在 overflow 时出错，必须修正；独立 comparison unit 可以避免错误的 taken/not-taken 判定。

### Q32. Intel Pentium 4 has 31 pipeline stages. A branch instruction is resolved pretty late, near the 31st stage.  If the branch misprediction rate is 2%, what would be the performance impact? (Assuming 20% of instructions are branches, and the average CPI is 1).

A. 2%
B. 6%
C. 20%
D. 12%
E. 60%

**Answer:** 4 = D — 12%

> 位于(3. Control Hazards, notes quiz 2/4_4_review.md), 解释是因为 review 给出 Pentium 4 例子：added CPI = 0.2 * 0.02 * 30 = 0.12，在 base CPI=1 时约等于 12% performance impact。

### Q33. What information is stored in the pipelined registers?

A. Control signals
B. Data (ALU results, Register values, Immediates)
C. Addresses (PC, PC+4, memory address)
D. Register designators

**Answer:** 1,2,3,4 = A — Control signals; B — Data (ALU results, Register values, Immediates); C — Addresses (PC, PC+4, memory address); D — Register designators

> 位于(Exam Facts; 1. Five Stages & Pipeline Registers, notes quiz 2/4_3_review.md), 解释是因为 pipeline registers 会携带 downstream control signals，也会携带 ALU result、register values、immediates、PC/PC+4、memory data/address 和 rd 等 register designators。

### Q34. Which RV32I branch/jump instructions are most difficult to predict?

A. Conditional branches such as BLT/BEQ/BNE
B. Unconditional jumps such as JAL, X0, target
C. Function calls such as JAL X1, function_name
D. Indirect branch for switches, such as JALR, 4(X1)
E. Return branch, such as JALR, X0, 0($ra)

**Answer:** 4 = D — Indirect branch for switches, such as JALR, 4(X1)

> 位于(4.5 BHT vs BTB vs RAS, notes quiz 2/4_4_review.md), 解释是因为 indirect `JALR` 的目标依赖运行时数据，例如 switch jump table、function pointer、virtual call；直接跳转和 return 更容易由 BTB/RAS 预测。

### Q35. Intel Itanium has a post-increment load instruction:
		LW	rd, imm(rs1)
	  Its register transfer behavior is as follows
		rd  mem[rs1 + imm]
		rs1  rs1 + imm
Why does RISC-V not adopt this instruction?

A. This instruction is rarely used by the compiler
B. This instruction requires two register write ports
C. This instruction breaks the regularity: rs1 is both a source and a destination.
D. This instruction is NIH (Not-Invented-Here)

**Answer:** 2,3 = B — This instruction requires two register write ports; C — This instruction breaks the regularity: rs1 is both a source and a destination.

> 位于(6.4 No Post-Increment Load, notes quiz 1/3_review.md), 解释是因为 post-increment load 同时写 `rd` 和更新 `rs1`，需要两个 register write ports，并让 `rs1` 同时作为 source 和 destination，破坏 RISC-V 的规则性。

## Quiz4-2026

**CSC3060 – Computer Systems / Review Pop Quiz**

### Section I
*(single answer) / For students who have not received >2 points before*

### Q1. In computer architecture, the term “memory wall” refers to which of the following?

A. The gap between the disk and the memory
B. The gap between DRAM and SRAM
C. The gap between the registers and the L1 data cache
D. The gap between CPU and the main memory (DRAM)

**Answer:** 4 = D — The gap between CPU and the main memory (DRAM)

> 位于(Exam Facts, notes quiz 2/6_review.md), 解释是因为 memory wall 被定义为 CPU speed 与 DRAM latency/bandwidth 之间的差距，也就是处理器和主存之间速度差越来越大。

### Q2. Which of the following pieces of information is not stored as part of a data cache line?

A. Data of the cache block
B. Set number
C. The valid bit
D. The address tag
E. The dirty bit

**Answer:** 2 = B — Set number

> 位于(Exam Facts; 2. Cache Basics, notes quiz 2/6_review.md), 解释是因为 cache line 存 valid bit、tag、data，write-back cache 还会有 dirty bit；set number 是地址中的 index 字段，不作为 line metadata 存储。

### Q3. In a memory hierarchy, which layer is managed by the compiler or the programmers?

A. The local memory
B. The L1 cache
C. The L2 cache
D. The write buffer

**Answer:** 1 = A — The local memory

> 位于(Exam Facts, notes quiz 2/6_review.md), 解释是因为 review 把 local memory/scratch-pad 标为由 compiler/programmer 管理，而 L1/L2/L3 cache 由硬件管理。

### Q4. We have a 64 KB, 4-way set-associative cache with a 32-byte block (line) size. When the CPU issues a 32-bit memory address, how many bits are allocated to the Tag, the Set Index, and the Block Offset, respectively?

A. 16, 11, 5
B. 18, 8, 6
C. 18, 9, 5
D. 17, 9, 6

**Answer:** 3 = C — 18, 9, 5

> 位于(2.1 Parameter Formulas, notes quiz 2/6_review.md), 解释是因为 S=C/(B*E)=64KB/(32B*4)=512 sets，所以 offset=log2(32)=5，set index=log2(512)=9，tag=32-9-5=18。

### Q5. Which of the following data structures is used in a non-blocking cache?

A. A prefetch buffer
B. AMAT counter
C. MSHR
D. Interlock table

**Answer:** 3 = C — MSHR

> 位于(10. MSHR & Non-Blocking Cache, notes quiz 2/6_review.md), 解释是因为 MSHR 用来跟踪 outstanding misses，使 non-blocking cache 支持 hit-under-miss / miss-under-miss 和 miss merging。

### Q6. Which of the following cache organizations does not make sense?

A. L3 is write-through
B. L1 is direct-mapped plus a victim cache
C. L2 write-back with write allocate
D. Split L1I / L1D

**Answer:** 1 = A — L3 is write-through

> 位于(4.2 Write Hit: WT vs WB; 8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 write-through 会造成高 memory traffic，而 L3 的主要目标是减少 DRAM traffic；因此把 L3 设计成 write-through 通常不合理。

### Q7. In a typical modern multi-core processor, which level of cache is usually shared among all the CPU cores?

A. L1
B. L2
C. L3
D. L4

**Answer:** 3 = C — L3

> 位于(8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 review 明确写出 L3/LLC 是 multi-MB 并 shared by all cores，用来减少 DRAM traffic。

### Q8. For a single-cycle data path design, if the D-cache miss rate is 5%, 40% of instructions are load/stores, and the memory latency is 100 cycles. What would be the average CPI?

A. 2.0
B. 1.4
C. 1.6
D. 3.0

**Answer:** 4 = D — 3.0

> 位于(5. Cache Performance, notes quiz 2/6_review.md), 解释是因为 CPI = base CPI + data accesses/instr * miss rate * miss penalty = 1 + 0.4 * 0.05 * 100 = 3.0。

### Q9. The instruction cache is usually easier to manage than the data cache. Why?

A. It does not need to handle write operations
B. It does not need the valid bit
C. It does not need to handle cache line replacements
D. It does not need the tag bits

**Answer:** 1 = A — It does not need to handle write operations

> 位于(4.5 I-cache Specifics, notes quiz 2/6_review.md), 解释是因为 I-cache 不接收来自 CPU 的 store，所以不需要写策略或 dirty bit；data cache 必须处理 read/write hit/miss 四种情况。

### Q10. In modern processors, what is the likely L1D cache hit latency?

A. 1 cycle
B. 3-4 cycles
C. 5-6 cycles
D. 10+ cycles

**Answer:** 2 = B — 3-4 cycles

> 位于(5. Cache Performance, notes quiz 2/6_review.md), 解释是因为 review 直接给出现代 L1D hit latency 通常是 3-4 cycles。

### Section II
*(multiple answers)*

### Q11. What is the most likely cache organization for L1D in modern processors?

A. 4-way set-associative, write-through, write-allocate,
B. Fully-associative, write-through, write-noallocate,
C. Direct-mapped, write-back, write-allocate,
D. 4-way set-associative, write-back, write-allocate,
E. Direct-mapped, write-back, write-noallocate,

**Answer:** 4 = D — 4-way set-associative, write-back, write-allocate,

> 位于(Exam Facts; 4.4 Common Pairings, notes quiz 2/6_review.md), 解释是因为现代 L1D 的典型组合是 4-way set-associative、write-back、write-allocate，以平衡命中延迟、miss rate 和写流量。

### Q12. If minimizing the tag space is the primary goal, which cache features should be used?

A. Set associative caches
B. Direct-mapped caches
C. Write no-allocate policy
D. Large cache blocks (lines)
E. Inclusive caches

**Answer:** 2, 4 = B — Direct-mapped caches; D — Large cache blocks (lines)

> 位于(Exam Facts; 3. 4 Cache-Design Questions, notes quiz 2/6_review.md), 解释是因为 direct-mapped cache 的 tag overhead 最低；较大的 cache line 会减少 line 数量，从而节省 tag/meta space。

### Q13. Modern processors typically include on-chip L1, L2, and L3 caches. Which statement is TRUE?

A. The primary goal of L3 cache is to reduce the memory traffic to the memory
B. The primary goal of the L1 cache is to have a fast hit time
C. The L3 cache is often shared by multiple cores
D. The L2’s goal is to balance the speed and the capacity

**Answer:** 1,2,3,4 = A — The primary goal of L3 cache is to reduce the memory traffic to the memory; B — The primary goal of the L1 cache is to have a fast hit time; C — The L3 cache is often shared by multiple cores; D — The L2’s goal is to balance the speed and the capacity

> 位于(8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 L1 的目标是 fast hit time，L2 平衡 speed 和 capacity，L3/LLC 由多核共享并减少 DRAM traffic；四个说法都符合 review。

### Q14. What are the four types of cache misses (4C’s) ?

A. Compulsory misses, Conflict misses, Capacity misses, Coherence misses
B. Cold misses, Collision misses, Capacity misses, Coherence misses
C. Cascaded misses, Controlled misses, Contiguous misses, Conditional misses
D. Cool misses, Cold misses, Capacity misses, Coherence misses

**Answer:** 1,2 = A — Compulsory misses, Conflict misses, Capacity misses, Coherence misses; B — Cold misses, Collision misses, Capacity misses, Coherence misses

> 位于(6. 4 C's of Misses, notes quiz 2/6_review.md；未在 *_review.md 中直接写出 Cold/Collision 的同义说明), 解释是因为 review 列出的 4C 是 Compulsory、Conflict、Capacity、Coherence；选项 B 用 Cold 对应 compulsory、Collision 对应 conflict，所以 A/B 都表达同一组概念。

### Q15. Among the 4C’s, which cache misses are the most difficult to remove?

A. Compulsory
B. Collision
C. Capacity
D. Coherence

**Answer:** 4 = D — Coherence

> 位于(6. 4 C's of Misses, notes quiz 2/6_review.md), 解释是因为 coherence misses 通常来自其他核心的 invalidation，review 明确说 hardest to remove，需要减少共享或改写程序。

### Q16. For the compulsory misses, how may we reduce them?

A. Hardware prefetching
B. Having a larger cache line size
C. Increase the cache size
D. Add a victim cache

**Answer:** 1,2 = A — Hardware prefetching; B — Having a larger cache line size

> 位于(6. 4 C's of Misses; 3. 4 Cache-Design Questions, notes quiz 2/6_review.md), 解释是因为 compulsory miss 是首次访问导致，能用 prefetch 或 larger block/line 借助空间局部性减少；单纯增大 cache 不会消除首次访问。

### Q17. Compare the L2 to the L1 cache, the L2 cache is usually

A. Larger
B. Slower
C. Unified
D. Shared

**Answer:** 1,2,3 = A — Larger; B — Slower; C — Unified

> 位于(8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 L2 通常比 L1 更大、更慢，并且 often private/unified；shared by all cores 更典型的是 L3。

### Q18. Four processors are connected to the main memory via a global bus. What are the possible solutions to maintain cache coherence?

A. Use a shared cache; no private cache allowed
B. If caches are private, use the Snoopy protocol
C. Build an inclusive multi-level cache
D. Split the instruction and the data cache

**Answer:** 1,2 = A — Use a shared cache; no private cache allowed; B — If caches are private, use the Snoopy protocol

> 位于(9. Cache Coherence, notes quiz 2/6_review.md), 解释是因为 review 给出的 coherence solutions 是使用 shared cache，或者在 private caches 上用 snoopy protocol 监听共享总线。

### Q19. Assume the same cache size and the same line size. Which of the following statements are always true?

A. A direct-mapped cache is faster than set associative caches
B. A fully associative cache has the lowest cache miss rate
C. A direct-mapped cache has the lowest tag overhead
D. Replacement policy in a direct-mapped cache is the simplest

**Answer:** 3,4 = C — A direct-mapped cache has the lowest tag overhead; D — Replacement policy in a direct-mapped cache is the simplest

> 位于(3. 4 Cache-Design Questions, notes quiz 2/6_review.md), 解释是因为在相同 cache size 和 line size 下，direct-mapped 的 tag overhead 最低且 replacement 最简单；review 同时指出它不一定总是 hit latency 最快，fully associative 也不保证 miss rate 最低。

### Q20. What are the advantages of using a large cache line size?

A. It exploits more spatial locality
B. It exploits more temporal locality
C. It saves tag space
D. It could reduce compulsory misses

**Answer:** 1,3,4 = A — It exploits more spatial locality; C — It saves tag space; D — It could reduce compulsory misses

> 位于(3. 4 Cache-Design Questions, notes quiz 2/6_review.md), 解释是因为 large cache line 能利用更多 spatial locality、降低 tag overhead，并减少 compulsory misses；但它不直接提升 temporal locality，还会增加 miss penalty 和 bandwidth 压力。

### Q21. My computer has a two-way set associative cache with 4KB and 32B line size, which of the following memory reference sequences would run into conflict misses?

A. 0x01ABC000, 0x01ABC004, 0x01ABC010, 0x01ABC002,
B. 0x01ABC000, 0x01ABC020, 0x01ABC030, 0x01ABC040,
C. 0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010,
D. 0x01ABC020, 0x01ABC030, 0x01ABC02A, 0x01ABC03A,

**Answer:** 3 = C — 0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010,

> 位于(2.2 Direct-Mapped Conflict, notes quiz 2/6_review.md), 解释是因为 4KB、2-way、32B line 有 S=64 sets，set 每 2KB 重复；选项 C 的多个地址落到同一 set 且超过 2-way 可容纳的 live blocks，因此会产生 conflict misses。

### Q22. What is the multi-level cache implemented in your project #4?

A. Inclusive cache
B. Exclusive cache
C. NINE cache
D. Shared cache

**Answer:** 3 = C — NINE cache

> 位于(未在 *_review.md 中找到 project #4 具体实现的直接出处；参考 8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 review 只定义了 NINE = non-inclusive, non-exclusive；题目所问 project #4 的实现结论应选 NINE，但这个项目事实没有在 review 中直接写出。

### Q23. What replacement algorithm is implemented in the typical set-associative caches today?

A. LRU
B. FIFO
C. Approximate LRU
D. Random
E. Belady’s algorithm

**Answer:** 3 = C — Approximate LRU

> 位于(7. Replacement Policies, notes quiz 2/6_review.md), 解释是因为真实 set-associative cache 中精确 LRU 成本高，review 写明 typical in real caches 的是 pseudo-LRU / approximate LRU。

### Q24. If you would like to implement a TRUE LRU replacement algorithm, what data structure should be used?

A. A queue
B. A stack
C. A tree
D. A heap

**Answer:** 2 = B — A stack

> 位于(7. Replacement Policies, notes quiz 2/6_review.md), 解释是因为 true LRU 需要维护从最近使用到最久未使用的精确顺序，review 明确给出数据结构是 stack。

### Q25. You developed a new cache replacement algorithm that effectively balances procedure calls and looping behaviors. Now, what is the upper bound you need to evaluate against?

A. Against LRU
B. Against Random
C. Against Belady’s algorithm
D. Against a perfect cache

**Answer:** 3 = C — Against Belady’s algorithm

> 位于(7. Replacement Policies, notes quiz 2/6_review.md), 解释是因为 Belady optimal 会淘汰未来最晚再用的块，是不可实现但可作为 miss-rate 上界/最优基准的算法。

### Q26. My cache supports both write-allocate and write-no-allocate policies; it is controlled by a bit in the store instruction. Under what condition should the store instruction turn on “write-no-allocate”?

A. In the memcpy(a,b,n) lib call when n is large
B. When storing local variables in a procedure
C. When storing a struct member (e.g., st.a or st->a)
D. In the memset(a,b,n) lib call when n is large.
E. When writing database logs

**Answer:** 1,4,5 = A — In the memcpy(a,b,n) lib call when n is large; D — In the memset(a,b,n) lib call when n is large.; E — When writing database logs

> 位于(4.3 Write Miss: WA vs NWA, notes quiz 2/6_review.md), 解释是因为 no-write-allocate 适合 streaming writes，例如 large `memcpy`、large `memset` 和 database logs；local variables 或 struct member 通常会复用，适合 write-allocate。

### Q27. Which cache features require greater bus and memory bandwidth?

A. Large cache lines
B. Cache prefetching
C. Non-blocking caches
D. Exclusive, multi-level, write-back caches
E. Write-through caches

**Answer:** 1,2,3,5 = A — Large cache lines; B — Cache prefetching; C — Non-blocking caches; E — Write-through caches

> 位于(10. MSHR & Non-Blocking Cache, notes quiz 2/6_review.md), 解释是因为 review 将 large lines、prefetch、non-blocking cache、write-through 都归为 bandwidth-heavy features；它们会增加总线和内存带宽压力。

### Q28. Which of the following statements about the “snoopy” cache are true?

A. It works as a watchdog for preventing illegal cache references
B. It is designed to maintain cache coherence for bus-connected multi-processor systems
C. It is designed for data security enforcement
D. It will generate significant snooping bus traffic

**Answer:** 2,4 = B — It is designed to maintain cache coherence for bus-connected multi-processor systems; D — It will generate significant snooping bus traffic

> 位于(9. Cache Coherence, notes quiz 2/6_review.md), 解释是因为 snoopy cache 是 private caches 在 shared bus 上监听其他 cache 行为以维持 coherence；review 也指出它会带来显著 snoop traffic。

### Q29. Which of the following could reduce conflict misses incurred in a direct-mapped L1D cache?

A. Increase the cache sizes
B. Increase the cache block (line) sizes
C. Add a victim cache
D. Change to set associative cache
E. Use the best replacement algorithm

**Answer:** 1,3,4 = A — Increase the cache sizes; C — Add a victim cache; D — Change to set associative cache

> 位于(6. 4 C's of Misses, notes quiz 2/6_review.md), 解释是因为 direct-mapped conflict misses 可通过 larger cache、victim cache 或提高 associativity 减少；larger line 可能减少 compulsory miss 但也可能加剧 conflict，replacement policy 对 direct-mapped 没有选择空间。

### Q30. Which of the following are often useful in reducing cache capacity misses?

A. Increase the cache sizes
B. Increase the cache block (line) sizes
C. Add one victim cache
D. Change to set associative cache
E. Cache prefetching

**Answer:** 1,5 = A — Increase the cache sizes; E — Cache prefetching

> 位于(6. 4 C's of Misses, notes quiz 2/6_review.md), 解释是因为 capacity miss 来自 working set 超过 cache，review 给出的常见改善是 bigger cache 和 prefetching；victim cache/associativity 主要针对 conflict。

### Q31. MSHR (Miss Status Handling Registers) are used to track multiple outstanding cache misses. Each level of cache has its own MSHR. On a multicore chip, the number of entries in the L3 MSHR would likely be influenced by

A. The memory latency
B. The memory bus width
C. The size of the L2 cache
D. The number of cores sharing the L3

**Answer:** 1,2 = A — The memory latency; B — The memory bus width

> 位于(10. MSHR & Non-Blocking Cache, notes quiz 2/6_review.md), 解释是因为 L3 MSHR entries 用来覆盖 outstanding memory misses，review 明确说数量受 memory latency 和 bus width 影响，而不是 L2 size 或 sharing cores 数量。

### Q32. I-cache does not take stores from the processor. However, modern applications use “instruction patching” or “JIT” code generation to either modify instructions or generate a new code section for subsequent execution.  Which of the following solutions are required for evicting stale instructions in the I-cache?

A. Flush the I-cache to purge all old instructions
B. Invalidate the I-cache lines containing the instructions
C. Flush the data caches
D. Maintain coherence between I- and D-cache: any updates to the D-cache will also write into the respective lines in I-cache.

**Answer:** 1,2,4 = A — Flush the I-cache to purge all old instructions; B — Invalidate the I-cache lines containing the instructions; D — Maintain coherence between I- and D-cache: any updates to the D-cache will also write into the respective lines in I-cache.

> 位于(4.5 I-cache Specifics, notes quiz 2/6_review.md), 解释是因为 JIT/self-modifying code 会让 I-cache 中旧指令过期，需要 flush I-cache、invalidate affected I-lines，或维护 I/D coherence；单独 flush D-cache 不足以清除 I-cache stale instructions。

### Q33. Which of the following multi-level cache organizations does not make sense?

A. L1I copy back and L1D write-through
B. L1/L2 exclusive, L2/L3 inclusive
C. L1D 4-way set associative, L2 direct mapped
D. L1/L2 inclusive, L2/L3 exclusive

**Answer:** 1,2,3 = A — L1I copy back and L1D write-through; B — L1/L2 exclusive, L2/L3 inclusive; C — L1D 4-way set associative, L2 direct mapped

> 位于(8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 review 的 nonsensical orgs 包括 L1I write-back、L1/L2 exclusive 同时 L2/L3 inclusive，以及 L1D 4-way 但 L2 direct-mapped；L1/L2 inclusive 且 L2/L3 exclusive 在 review 中标为 OK。

### Q34. In contemporary processors, the vast majority of chip space is dedicated to what?

A. Branch prediction
B. Register files
C. Pipelined registers
D. Floating-point functional units
E. Caches

**Answer:** 5 = E — Caches

> 位于(Exam Facts, notes quiz 2/6_review.md), 解释是因为现代处理器芯片面积中很大一部分用于 cache 层级，review 直接写出 vast chip area = caches。

### Q35. Which of the following sorting algorithms is known to have high data locality?

A. Quicksort
B. Insertion sort
C. Heapsort
D. Radix sort
E. Bubble sort

**Answer:** 1,2,5 = A — Quicksort; B — Insertion sort; E — Bubble sort

> 位于(11. Locality Application Patterns, notes quiz 2/6_review.md), 解释是因为 review 把 Quicksort、Insertion sort、Bubble sort 标为 high locality；Heapsort 和 Radix sort 因访问模式更分散而 locality 较差。

### Q36. What is the difference between a hardware cache and a software cache (such as a disk file cache)?

A. Software caches are managed by system software or applications, whereas hardware caches are managed by the hardware
B. Hardware caches support associative search, while software caches utilize lookup data structures such as hash tables.
C. Hardware caches must implement simple and fast replacement algorithms; software caches can use more complex algorithms.
D. Hardware caches are flexible in size, but software caches are not.

**Answer:** 1,2,3 = A — Software caches are managed by system software or applications, whereas hardware caches are managed by the hardware; B — Hardware caches support associative search, while software caches utilize lookup data structures such as hash tables.; C — Hardware caches must implement simple and fast replacement algorithms; software caches can use more complex algorithms.

> 位于(11. Locality Application Patterns, notes quiz 2/6_review.md), 解释是因为 hardware cache 由硬件透明管理、用 associative tag compare、replacement 必须简单快速；software cache 由 OS/app 管理，可用 hash/tree lookup 和更复杂策略。

## Quiz5-2026

**CSC3060 – Computer Systems / Review Pop Quiz**

### Section I
*(single answer) / For students who have not received >2 popquiz points before*

### Q1. In Unix/Linux, which of the following is the standard linker?

A. gcc
B. ln
C. ld
D. ll
E. link

**Answer:** 3 = C — ld

> 位于(Exam Facts, 7_review.md), 解释是因为标准 Unix linker 是 `ld`；`gcc` 只是 compiler driver，会在编译流程中调用 `ld`。

### Q2. How do you read the detailed information of an ELF file?

A. objdump
B. gdb
C. ldd
D. readelf
E. nm

**Answer:** 4 = D — readelf

> 位于(Exam Facts, 7_review.md), 解释是因为 review 把 `readelf` 标为查看 ELF full details 的工具；`objdump` 更偏 disassembly/relocations，`nm` 更偏 symbol list。

### Q3. Which of the following is NOT a job for the linker?

A. Symbol resolution
B. Handling libraries
C. Loading into the memory
D. Section merging
E. Relocation

**Answer:** 3 = C — Loading into the memory

> 位于(Exam Facts, 7_review.md), 解释是因为 linker 的工作包括 symbol resolution、relocation、section merging、library handling；loading into memory 是 loader/dynamic linker 的工作。

### Q4. If you want to enable cross-module procedure inlining optimization, which of the following flags are required?

A. -O
B. -O5
C. -O3 -flto
D. -O3 -ffast

**Answer:** 3 = C — -O3 -flto

> 位于(2. Compiler Flag Reference, 5_review.md), 解释是因为 `-flto` 是 link-time/whole-program optimization，可让跨模块 inlining 成立；class note 中 `-O4` 等价于 `-O3 -flto`，选项里对应 `-O3 -flto`。

### Q5. Which of the following optimizations have no primary attempt to improve locality?

A. Loop unrolling
B. Loop interchange
C. Loop fusion
D. Loop tiling

**Answer:** 1 = A — Loop unrolling

> 位于(6.1 Loop Unrolling, 5_review.md), 解释是因为 review 明确写出 loop unrolling 不是 locality optimization，它主要减少 branch/index overhead 并暴露 ILP/SIMD；loop interchange、fusion、tiling 才是 locality opts。

### Q6. Which of the following compiler optimizations may lead to 1000x speedup?

A. Procedure inlining
B. Cascading DCE
C. Loop unrolling
D. Register allocation
E. Code scheduling

**Answer:** 2 = B — Cascading DCE

> 位于(Exam Facts; 4.2 Constant Fold / DCE / CSE / LICM / Strength, 5_review.md), 解释是因为 cascading DCE 可以由一个常量消除 branch、calls、loop 等整串代码，review 明确说可能带来 1000x speedup。

### Q7. Which of the following compiler optimizations have been discussed in class?

A. Multi-threading on multi-cores
B. SIMT using CUDA
C. Vectorization using a compiler auto-vectorization
D. Loop transformations to improve data locality

**Answer:** 4 = D — Loop transformations to improve data locality

> 位于(Exam Facts; 10. Data Structure & Layout Fixes, 5_review.md), 解释是因为 review 讨论的 locality 改善主要是 loop interchange、fusion、tiling 等 loop transformations；multithreading、CUDA SIMT、compiler auto-vectorization 不是这里列出的课堂重点答案。

### Q8. To build executables for embedded systems where the memory size is severely limited, which optimization flags should be used?

A. -O0
B. -Os
C. -O3 -flto
D. -O3

**Answer:** 2 = B — -Os

> 位于(2. Compiler Flag Reference, 5_review.md), 解释是因为 `-Os` 的含义是 optimize for size，review 明确标注适合 embedded / size-constrained 场景。

### Section II
*(multiple answers) / Open to everyone*

### Q9. What are the benefits of linking?

A. Modularity
B. Fast compilation/recompilation
C. Code reuse via libraries
D. Easier to maintain
E. Simpler to build an executable

**Answer:** 1,2,3,4 = A — Modularity; B — Fast compilation/recompilation; C — Code reuse via libraries; D — Easier to maintain

> 位于(Exam Facts; 1. What Is Linking?, 7_review.md), 解释是因为 linking 的好处包括 modularity、separate/fast recompilation、library reuse 和 easier maintenance；review 明确说不是让构建 executable 更简单。

### Q10. What can a linker do?

A. Can enable Link Time Optimization
B. Can resolve symbol definition/reference
C. Can tune a program’s performance via page sizes and alignments
D. Can relocate global variable references and function calls

**Answer:** 1,2,3,4 = A — Can enable Link Time Optimization; B — Can resolve symbol definition/reference; C — Can tune a program’s performance via page sizes and alignments; D — Can relocate global variable references and function calls

> 位于(Exam Facts, 7_review.md), 解释是因为 linker jobs 包括 LTO、symbol resolution、relocation，并且可通过 page alignment、function/code layout 等影响性能；四个选项都是 linker 可做的事。

### Q11. What are the three different object files?

A. Relocatable object file
B. Static object file
C. Executable object file
D. Shared object file
E. Dynamic object file

**Answer:** 1,3,4 = A — Relocatable object file; C — Executable object file; D — Shared object file

> 位于(Exam Facts; 3. ELF Object Format, 7_review.md), 解释是因为 object file 的三类是 relocatable `.o`、executable、shared object `.so`；`.a` 是 archive library，不是第四类 object file。

### Q12. What are the data structures to support dynamic linking?

A. GOT (Global Offset Table)
B. JT (Jump Table)
C. PLT (Procedure Linkage Table)
D. SHT (Section Header Table)

**Answer:** 1,3 = A — GOT (Global Offset Table); C — PLT (Procedure Linkage Table)

> 位于(Exam Facts; 9. PIC, GOT, PLT, 7_review.md), 解释是因为 dynamic linking 依赖 GOT 保存运行时地址、PLT 作为外部函数调用 stub；JT 和 SHT 不是 dynamic linking 的核心数据结构。

### Q13. What are the major advantages of dynamic linking?

A. Faster execution
B. Significant Memory (RAM) Savings
C. Centralized Security Updates and Bug Fixes
D. Fast build time linking

**Answer:** 2,3,4 = B — Significant Memory (RAM) Savings; C — Centralized Security Updates and Bug Fixes; D — Fast build time linking

> 位于(Exam Facts; 8. Shared Libraries / Dynamic Linking, 7_review.md), 解释是因为 shared libraries 的优势是 RAM memory savings、集中安全/bug-fix 更新和快速 build-time linking；由于 PLT/GOT 间接跳转，它不是为了更快执行。

### Q14. Where do we keep the PLT, GOT and GOT.plt?

A. PLT is in the .text section
B. GOT is in the .data section
C. GOT.plt is in the .data section
D. GOT is in the .text section

**Answer:** 1,2,3 = A — PLT is in the .text section; B — GOT is in the .data section; C — GOT.plt is in the .data section

> 位于(Exam Facts; 9. PIC, GOT, PLT, 7_review.md), 解释是因为 PLT 是可执行 stub，位于 `.text`/`.plt`；GOT 和 `.got.plt` 是可写地址表，位于 `.data`-like writable region。

### Q15. What are the symbols in the .symtab section?

A. Global variables
B. Local variables
C. External functions
D. Static local symbols

**Answer:** 1,3,4 = A — Global variables; C — External functions; D — Static local symbols

> 位于(Exam Facts; 2. Linker Symbols, 7_review.md), 解释是因为 `.symtab` 包含 global variables、external function references 和 static linker symbols；auto local variables、parameters、temporary registers 不属于 linker symbols。

### Q16. Which of the following symbol resolution rules is incorrect?

A. Two weak symbols are not allowed
B. Two strong symbols are not allowed
C. One strong symbol and multiple weak symbol are allowed
D. Two weak symbols with different data types are allowed

**Answer:** 1 = A — Two weak symbols are not allowed

> 位于(Exam Facts; 4. Duplicate Symbol Resolution, 7_review.md), 解释是因为 duplicate symbol rules 中 two strong 是错误，strong + weak 由 strong 胜出，multiple weak 在 legacy common model 中允许且由 linker 任意选择；所以“two weak symbols are not allowed”是错误规则。

### Q17. Which of the following descriptions are incorrect?

A. .so is for a shared object file
B. .a is for an archived library
C. .o is for relocatable object file
D. .a is a collection of .o files with an index

**Answer:** NONE

> 位于(3. ELF Object Format, 7_review.md), 解释是因为 review 的 trick quiz 说明 `.so` 是 shared object，`.a` 是带 index 的 `.o` 集合，`.o` 是 relocatable object file；这些描述都正确，所以没有 incorrect description。

### Q18. How do we know which instructions and which data references require relocation?

A. The compiler or assembler leaves that information in the
   .rel.text and .rel.data sections.
B. The linker leaves the information in the .rel.text and .rel.data sections.
C. The loader leaves the information in the .rel.text and .rel.data sections.
D. The dynamic linker leaves the information in GOT and PLT

**Answer:** 1 = A — The compiler or assembler leaves that information in the .rel.text and .rel.data sections.

> 位于(5. Relocation, 7_review.md), 解释是因为最终地址在编译/汇编时未知，所以 compiler/assembler 会在 `.rel.text` 和 `.rel.data` 中留下 relocation entries，供 linker 后续 patch。

### Q19. Which of the following procedures are good candidates for inlining?

A. Small procedures
B. Procedures with multiple constant arguments
C. Recursive procedures
D. Procedures with many call sites
E. Procedures that are called only once in a loop

**Answer:** 1,2,5 = A — Small procedures; B — Procedures with multiple constant arguments; E — Procedures that are called only once in a loop

> 位于(4.3 Inlining, 5_review.md), 解释是因为 small procedures、constant arguments、inside loop/called once 都是 good candidates；recursive、deep call graph、many call sites 会导致不适合或 code bloat。

### Q20. Two parameters *a and *b are used frequently, and they are not pointing to the same object. The compiler did not allocate them to registers. What can you do?

A. Turn on –O3
B. Change from gcc to clang
C. Use restricted pointers
D. Allocate *a and *b to local variables manually

**Answer:** 3,4 = C — Use restricted pointers; D — Allocate *a and *b to local variables manually

> 位于(5. Memory Aliasing, 5_review.md), 解释是因为当 `*a` 和 `*b` 实际不 alias 但编译器无法证明时，应使用 `restrict` 或手动 local copy 让值进入寄存器；review 明确说不要只靠换 compiler 或开 `-O3`。

### Q21. For the expressions (a+b+c+d) and (a+d+b+c), we may consider them as a CSE (Common Sub-Expression) if the data type is

A. Long long
B. Float
C. Double
D. char

**Answer:** 1,4 = A — Long long; D — char

> 位于(4.2 Constant Fold / DCE / CSE / LICM / Strength, 5_review.md), 解释是因为 integer-like 类型的加法可按模运算重关联，`long long` 和 promoted `char` 可做 CSE；`float`/`double` 因 FP non-associativity 不能安全认为两式等价。
