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

**选项解析：**

- A. ❌ Structure/structural hazards 是三大流水线 hazard 之一，来自硬件资源冲突；正确表述：它属于常见 hazard。
- B. ✅ Forward hazards 不是三大 hazard。forwarding 是 data hazard 的一种解决技术，不是 hazard 分类。
- C. ❌ Data hazards 是三大 hazard 之一，来自指令间 RAW 等数据依赖；正确表述：它属于常见 hazard。
- D. ❌ Control hazards 是三大 hazard 之一，来自 branch/jump 改变 PC；正确表述：它属于常见 hazard。

### Q2. Which extension, if absent, would make RISC-V a fixed-length ISA?

A. A extension
B. B extension
C. C extension
D. D extension
E. E extension

**Answer:** 3 = C — C extension

> 位于(Exam Facts; 1.3 Bases and Extensions, notes quiz 1/3_review.md), 解释是因为 RISC-V base 指令主要是固定 32-bit，`C` extension 提供 16-bit compressed instructions；没有 `C` 时就不会出现压缩 16-bit 指令，因此 ISA 会保持固定长度。

**选项解析：**

- A. ❌ A extension 是 atomic instructions，不改变基本指令长度；正确表述：缺少 A 只是不支持原子操作。
- B. ❌ B extension 是 bit-manipulation，不是压缩指令来源；正确表述：缺少 B 不会让 ISA 从变长变固定长。
- C. ✅ 对。C extension 引入 16-bit compressed instructions；没有 C 时 RISC-V 指令保持 32-bit fixed length。
- D. ❌ D extension 是 double-precision floating point；正确表述：它影响 FP 功能，不决定指令是否压缩。
- E. ❌ E extension 是 embedded base variant，减少寄存器数；正确表述：它不引入 16-bit 指令长度。

### Q3. Which of the following microarchitectures could have a CPI lower than 1?

A. Single-cycle data path implementation
B. Multi-cycle data path implementation
C. Pipelined implementation
D. Superscalar implementation

**Answer:** 4 = D — Superscalar implementation

> 位于(3. Performance Model, notes quiz 2/4_1_review.md), 解释是因为 review 写明 CPI < 1 只有 superscalar / multi-issue 才可能做到；single-cycle、multi-cycle、普通 pipeline 都不能稳定低于 1。

**选项解析：**

- A. ❌ Single-cycle 每条指令一个周期完成，理想 CPI = 1；正确表述：它不能低于 1。
- B. ❌ Multi-cycle 一条指令需要多个较短周期，CPI 通常大于 1；正确表述：它牺牲 CPI 换较短 clock。
- C. ❌ 普通 single-issue pipeline 理想 CPI 接近 1，但每周期最多完成一条指令；正确表述：不能靠单发射低于 1。
- D. ✅ 对。Superscalar/multi-issue 每周期可完成多条指令，因此平均 CPI 可以小于 1。

### Q4. When comparing the performance of single-cycle, multi-cycle, and pipelined data paths, which statements is correct?

A. Single-cycle > Multi-cycle > Pipelined
B. Pipelined > Multi-cycle > Single-cycle
C. Pipelined > Single-cycle > Multi-cycle
D. Multi-cycle > Pipelined > Single-cycle

**Answer:** 2 = B — Pipelined > Multi-cycle > Single-cycle

> 位于(Exam Facts; 3. Performance Model, notes quiz 2/4_1_review.md), 解释是因为 review 给出的吞吐量顺序是 superscalar > pipelined > multi-cycle > single-cycle；本题比较后三者，所以 pipelined 最高，multi-cycle 次之，single-cycle 最低。

**选项解析：**

- A. ❌ 把 single-cycle 排最高不对；正确表述：single-cycle clock 由最慢指令决定，吞吐通常最低。
- B. ✅ 对。按吞吐量比较，pipelined 高于 multi-cycle，高于 single-cycle。
- C. ❌ Pipelined 高于 single-cycle 对，但 single-cycle 不应高于 multi-cycle；正确表述：multi-cycle 通常比 single-cycle 吞吐更好。
- D. ❌ Multi-cycle 不应高于 pipelined；正确表述：pipeline 通过重叠执行提高 throughput。

### Q5. Frequent pipeline stalls are likely to occur when traversing a long linked list due to

A. Delay hazards
B. Date hazards
C. Data hazards
D. Control hazards

**Answer:** 3 = C — Data hazards

> 位于(Exam Facts, notes quiz 2/4_4_review.md), 解释是因为 linked-list pointer chase 被标注为 data hazard only，本质是 `p = p->next` 形成连续 load-use 依赖链。

**选项解析：**

- A. ❌ Delay hazards 不是本课程三大 hazard 分类；正确表述：这里是数据依赖造成的 stall。
- B. ❌ Date hazards 是拼写干扰项；正确表述：应为 Data hazards。
- C. ✅ 对。链表遍历的下一次地址依赖上一次 load 出来的 pointer，形成 load-use/data hazard。
- D. ❌ 循环里有 branch，但频繁 stall 的关键不是控制流难预测；正确表述：pointer chasing 的瓶颈是 data hazard。

### Q6. Branch prediction should be carried out during which stages of the pipeline?

A. IF
B. ID
C. EXE
D. MEM
E. WB

**Answer:** 1 = A — IF

> 位于(Exam Facts, notes quiz 2/4_4_review.md), 解释是因为分支预测必须在 IF 阶段预测 next PC，才能决定下一条该取哪条指令；等到 ID/EX 已经太晚。

**选项解析：**

- A. ✅ 对。IF 阶段就要预测 next PC，才能连续取指。
- B. ❌ ID 已经晚了一拍；正确表述：ID 可解析部分信息，但预测应尽早在 IF。
- C. ❌ EXE 常用于实际 resolve 分支，不是最佳预测点；正确表述：等到 EXE penalty 已产生。
- D. ❌ MEM 更晚，会扩大 control hazard penalty；正确表述：不应等到 MEM。
- E. ❌ WB 已接近指令结束；正确表述：WB 做预测没有减少取指停顿的意义。

### Q7. Which of the following functional units is the most difficult to pipeline?

A. Integer multiply
B. Floating point add
C. Floating point multiply
D. Integer divide
E. Fused multiply-and-accumulate (FMAC)

**Answer:** 4 = D — Integer divide

> 位于(5.4 Multiply / Divide, notes quiz 1/2_review.md), 解释是因为 divider 被描述为 iterative、control-heavy、hardest to pipeline；integer divide 延迟也远高于加法、乘法和常见 FP 单元。

**选项解析：**

- A. ❌ Integer multiply 可用 partial-product tree/pipeline 组织，通常比 divide 更容易流水化。
- B. ❌ FP add 有对阶、加法、规格化等步骤，但可分阶段 pipeline；正确表述：难度低于 iterative divide。
- C. ❌ FP multiply 也可用乘法阵列/tree pipeline；正确表述：不是最难。
- D. ✅ 对。Integer divide 通常迭代、控制复杂、延迟长，最难高效流水化。
- E. ❌ FMAC 复杂但现代设计会专门 pipeline；正确表述：课堂强调最难的是 divide。

### Q8. A Von Neumann machine is depicted on the right. What is the so-called “Von Neumann bottleneck” in a pipelined data path?

A. It is like a structural hazard
B. It is like a data hazard
C. It is like a control hazard
D. It is like a memory hazard

**Answer:** 1 = A — It is like a structural hazard

> 位于(Exam Facts; 1. Structural Hazards, notes quiz 2/4_4_review.md), 解释是因为 Von Neumann bottleneck 在流水线里表现为 IF 取指和 MEM 访存争用同一存储器资源，因此等价于 structural hazard。

**选项解析：**

- A. ✅ 对。统一 instruction/data memory 会让 IF 和 MEM 同时争用同一资源，属于 structural hazard。
- B. ❌ Data hazard 是指令间数据依赖，不是统一存储器带宽冲突；正确表述：这里是资源冲突。
- C. ❌ Control hazard 来自 branch/jump 改变 PC；正确表述：Von Neumann bottleneck 不是分支预测问题。
- D. ❌ Memory hazard 不是本课程三大标准分类；正确表述：应归入 structural hazard。

### Q9. Which of the following microarchitectures is unlikely to be used by Apple’s M4 processor (i.e., the latest one)?

A. Dynamic branch prediction
B. Pipelined data path
C. Static branch prediction
D. BTB-based prediction

**Answer:** 3 = C — Static branch prediction

> 位于(4.1 Accuracy, notes quiz 2/4_4_review.md), 解释是因为 review 把 TAGE 等动态预测器列为 Intel/AMD/ARM/Apple 这类现代处理器使用的高精度方案；static branch prediction 精度低，最不像现代 Apple M 系列处理器的主要微架构技术。

**选项解析：**

- A. ❌ Dynamic branch prediction 是现代高性能处理器常见技术；正确表述：Apple M 系列很可能使用复杂动态预测。
- B. ❌ Pipelined datapath 是现代 CPU 基本实现方式；正确表述：不可能不用流水线思想。
- C. ✅ 对。Static branch prediction 精度和适应性低，最不像现代 Apple M4 的主要预测机制。
- D. ❌ BTB-based prediction 是现代 control-hazard 处理常见组成；正确表述：BTB 用来预测目标地址。

### Q10. Which RV32I instruction has the greatest impact on the clock rate of the single-cycle data path?

A. JALR X0, 0(X2)
B. LW X1,4(X2)
C. SLL X1,X2,X3
D. LUI X5, 0x12345

**Answer:** 2 = B — LW X1,4(X2)

> 位于(7. Single-Cycle Limits & Comparison, notes quiz 2/4_1_review.md), 解释是因为 single-cycle 的时钟周期必须容纳最慢指令，而 review 明确指出 `LW` 的路径最长：PC -> IMem -> Regfile -> ALU -> DMem -> WB mux -> Regfile setup。

**选项解析：**

- A. ❌ JALR 需要取指、读寄存器、加目标和更新 PC，但通常不经过数据存储器和写回 load 数据路径；正确表述：不是最长路径。
- B. ✅ 对。LW 同时走 instruction memory、register file、ALU address、data memory、writeback，决定 single-cycle clock。
- C. ❌ SLL 是 ALU R-type 路径，不访问 data memory；正确表述：路径短于 load。
- D. ❌ LUI 主要生成 immediate 并写回；正确表述：不经过长的 memory load 路径。

### Section II
*(multiple answers)*

### Q11. MIPS (Microprocessor without Interlocked Pipeline Stages) reduces hardware cost by using software to avoid hazards, making the processor cheaper and faster. What was the primary reason for its lack of success?

A. Compatibility and Scalability
B. Non-competitive performance
C. Incompatible with x86
D. John Hennessy was too occupied.

**Answer:** 1 = A — Compatibility and Scalability

> 位于(2.4 Compiler Scheduling Limits, notes quiz 2/4_4_review.md), 解释是因为 review 对 MIPS history 的结论是 compiler-only/no interlock 的思路最终受 compatibility 与 scalability 限制。

**选项解析：**

- A. ✅ 对。依赖软件规避 hazard 的 ISA/二进制接口难以兼容不同实现和扩展到更深/更复杂流水线。
- B. ❌ 不是主要历史原因；正确表述：性能问题背后核心是兼容性和可扩展性限制。
- C. ❌ “不兼容 x86”不是 MIPS no-interlock 思路失败的核心；正确表述：RISC 体系本来就不以 x86 兼容为目标。
- D. ❌ 人物忙碌是玩笑干扰项；正确表述：技术原因是 compatibility/scalability。

### Q12. In which cases should callee-saved registers be considered for allocation?

A. Leaf routines
B. A temporary value used heavily across multiple calls
C. Temporaries in expression evaluation
D. C Strings
E. Local variables

**Answer:** 2,5 = B — A temporary value used heavily across multiple calls; E — Local variables

> 位于(Exam Facts; 6. Allocation Quiz Anchors, notes quiz 1/4_review.md), 解释是因为 callee-saved registers 适合长期活跃的 local scalars，以及跨多个 calls 仍要保留的重复使用值；leaf temporaries 和 expression temporaries 更适合 caller-saved。

**选项解析：**

- A. ❌ Leaf routine 不调用其他函数，短期临时值更适合 caller-saved；正确表述：leaf 本身不是优先使用 callee-saved 的理由。
- B. ✅ 对。跨多个 calls 仍频繁使用的值放 callee-saved，可避免 caller 每次 call 前后反复保存。
- C. ❌ 表达式求值 temporaries 生命周期短；正确表述：通常用 caller-saved/temp registers。
- D. ❌ C strings 多为内存对象/指针数据，不是 callee-saved 分配的典型理由。
- E. ✅ 对。长期活跃 local variables 常适合 callee-saved registers。

### Q13. Which of the following is a common hardware technique to reduce the penalty of data hazards?

A. Data forwarding
B. A deeper pipeline
C. Data Bypassing
D. Compiler code scheduling

**Answer:** 1,3 = A — Data forwarding; C — Data Bypassing

> 位于(Exam Facts; 2. Data Hazards, notes quiz 2/4_4_review.md), 解释是因为 forwarding/bypassing 是硬件层面把后面阶段的结果直接送回 EX 阶段的 data hazard 修复技术；deeper pipeline 不是修复，compiler scheduling 属于软件技术。

**选项解析：**

- A. ✅ 对。Data forwarding 是硬件 bypass 路径，可减少 RAW hazard stall。
- B. ❌ Deeper pipeline 通常增加依赖距离和 penalty；正确表述：它不是 data hazard penalty 的常见修复。
- C. ✅ 对。Data bypassing 与 forwarding 是同一类硬件技术。
- D. ❌ Compiler code scheduling 可减少 stall，但它是软件/编译器技术，不是本题问的 hardware technique。

### Q14. Most modern microprocessors have split I/D caches. Why?

A. To avoid structural hazards in the pipeline
B. To get a higher cache hit rate
C. To increase reliability
D. To increase the cache access bandwidth

**Answer:** 1,4 = A — To avoid structural hazards in the pipeline; D — To increase the cache access bandwidth

> 位于(Exam Facts; 1. Structural Hazards, notes quiz 2/4_4_review.md), 解释是因为 split I/D cache 的目的就是避免 IF 取指和 MEM 数据访问同时争用同一 cache，并增加访问带宽；review 明确说不是为了提高 hit rate 或 reliability。

**选项解析：**

- A. ✅ 对。分离 I-cache/D-cache 可避免取指和数据访问争用同一 cache port。
- B. ❌ Split I/D 的主要目标不是提高 hit rate；正确表述：hit rate 取决于容量、相联度、line size 和访问模式。
- C. ❌ Reliability 不是分离 I/D cache 的课程原因；正确表述：重点是 bandwidth 和 structural hazard。
- D. ✅ 对。I 和 D 可并行访问，cache access bandwidth 增加。

### Q15. Compared to a pipelined data path, a single-cycle data path typically has:

A. Higher throughput
B. Faster clock rate
C. Simple control logic
D. A longer instruction latency
E. A lower CPI

**Answer:** 3,5 = C — Simple control logic; E — A lower CPI

> 位于(7. Single-Cycle Limits & Comparison, notes quiz 2/4_1_review.md), 解释是因为 single-cycle CPI 固定为 1，控制逻辑也更简单；pipeline 的优势是更高 throughput 和更短 clock，而不是单条指令 latency 或更低 CPI。

**选项解析：**

- A. ❌ Single-cycle clock 由最慢指令决定，吞吐通常低于 pipeline；正确表述：pipeline throughput 更高。
- B. ❌ Single-cycle clock period 很长；正确表述：pipeline 将路径切段后 clock 更快。
- C. ✅ 对。Single-cycle 没有跨周期控制和 hazard 控制，control logic 更简单。
- D. ❌ 以周期数看 single-cycle latency 是 1 cycle，但这个 cycle 很长；正确表述：不能说典型有更长 instruction latency。
- E. ✅ 对。Single-cycle CPI=1；普通 pipeline 由于 stall/flush，实际 CPI 常高于 1。

### Q16. Function A calls function B. In function A, three registers live across the call to B: $s1, $t0, and $a1. What registers must be saved/restored across the call?

A. $s1
B. $t0
C. $a1
D. None of them

**Answer:** 2,3 = B — $t0; C — $a1

> 位于(Exam Facts; 6. Allocation Quiz Anchors, notes quiz 1/4_review.md), 解释是因为 `t0` 和 `a1` 属于 caller-saved，若 A 在调用 B 后还要用它们，A 必须自己保存；`s1` 属于 callee-saved，由 B 在修改时负责恢复。

**选项解析：**

- A. ❌ `$s1` 是 callee-saved；正确表述：如果 B 修改它，B 负责保存恢复，A 不必因 live across call 主动保存它。
- B. ✅ 对。`$t0` 是 caller-saved，A 调用 B 后还要用就必须由 A 保存。
- C. ✅ 对。`$a1` 也是 caller-saved/argument register，live across call 时由 caller A 保护。
- D. ❌ 有 caller-saved live values；正确表述：至少 `$t0` 和 `$a1` 要保存恢复。

### Q17. What are the essential principles of designing a pipelined datapath?

A. Multi-stage partitioning
B. Overlapped execution
C. Increased throughput
D. Lowered instruction latency
E. Improved resource utilization

**Answer:** 1,2,3,5 = A — Multi-stage partitioning; B — Overlapped execution; C — Increased throughput; E — Improved resource utilization

> 位于(Exam Facts; 1. Five Stages & Pipeline Registers, notes quiz 2/4_3_review.md), 解释是因为流水线把执行拆成多个 stages，并让多条指令 overlapped execution，从而提高 throughput 和资源利用率；review 也强调 pipeline 提升 throughput 而不是降低单条指令 latency。

**选项解析：**

- A. ✅ 对。流水线设计的前提是把执行路径分成多个 stage。
- B. ✅ 对。多条指令在不同 stage 同时推进，是 pipeline 的核心。
- C. ✅ 对。Pipeline 提高单位时间完成指令数，也就是 throughput。
- D. ❌ 单条指令经过所有 stages，latency 通常不降低甚至增加；正确表述：pipeline 主要提高 throughput。
- E. ✅ 对。不同 stage 的硬件可在同一周期服务不同指令，资源利用率提高。

### Q18. Which of the following are techniques used to reduce the penalty caused by control hazards?

A. Pipeline stalls
B. BTB (Branch Target Buffer)
C. BHT (Branch History Table)
D. Data Bypassing
E. Data forwarding

**Answer:** 2,3 = B — BTB (Branch Target Buffer); C — BHT (Branch History Table)

> 位于(3. Control Hazards; 4.5 BHT vs BTB vs RAS, notes quiz 2/4_4_review.md), 解释是因为 BHT 预测方向、BTB 预测目标地址，都是降低 control hazard penalty 的分支预测结构；data forwarding/bypassing 解决的是 data hazard。

**选项解析：**

- A. ❌ Stall 是保守处理方式，会付出 penalty，不是“降低 penalty”的技术；正确表述：预测结构才用于减少等待。
- B. ✅ 对。BTB 缓存 branch target，使 IF 能更早取目标路径。
- C. ✅ 对。BHT 预测 taken/not-taken，减少 control hazard 造成的停顿和 flush。
- D. ❌ Data bypassing 解决 RAW data hazard；正确表述：不解决分支方向/目标问题。
- E. ❌ Data forwarding 同样是 data hazard 技术；正确表述：control hazard 依赖 branch prediction/BTB/BHT/RAS 等。

### Q19. What (HW/SW) strategies can reduce pipeline stalls caused by data hazards?

A. Deeper pipeline
B. Data forwarding
C. Out-of-Order instruction execution
D. Compiler instruction scheduling
E. Branch prediction

**Answer:** 2,3,4 = B — Data forwarding; C — Out-of-Order instruction execution; D — Compiler instruction scheduling

> 位于(Exam Facts; 2. Data Hazards, notes quiz 2/4_4_review.md), 解释是因为 review 把 data hazard 的修复列为 forwarding/bypass、stall、OoO execution 和 compiler scheduling；deeper pipeline 会加重依赖惩罚，branch prediction 属于 control hazard。

**选项解析：**

- A. ❌ Deeper pipeline 往往让 producer/consumer 间隔更长，可能加重 data hazard penalty；正确表述：不是减少 stall 的策略。
- B. ✅ 对。Forwarding 把结果直接送到需要它的后续 stage，减少等待写回。
- C. ✅ 对。Out-of-order execution 可绕开暂时等待的依赖，执行其他 ready 指令。
- D. ✅ 对。Compiler scheduling 可把独立指令插入依赖之间，填掉 bubbles。
- E. ❌ Branch prediction 处理 control hazards；正确表述：不是 data hazard stall 的修复手段。

### Q20. Which of the following are considered “Microarchitecture states”?

A. BHT
B. BTB
C. Floating-point registers
D. PC
E. Pipelined registers

**Answer:** 1,2,5 = A — BHT; B — BTB; E — Pipelined registers

> 位于(2.2 Architectural State, notes quiz 1/3_review.md), 解释是因为 BHT、BTB、pipeline registers 被列为 microarchitectural state，可再生且中断时不保存；PC 和 FP registers 属于 architectural state。

**选项解析：**

- A. ✅ 对。BHT 是分支预测器内部状态，属于 microarchitecture state。
- B. ✅ 对。BTB 缓存预测目标，是实现细节状态。
- C. ❌ Floating-point registers 是 ISA 暴露的 architectural state；正确表述：中断/上下文切换需要保存。
- D. ❌ PC 是 architectural state；正确表述：程序恢复执行必须恢复 PC。
- E. ✅ 对。Pipeline registers 是流水线实现内部暂存，不属于 ISA 可见状态。

### Q21. In practice, what might occur if we increase the number of pipeline stages from 5 to 20?

A. The clock rate becomes 4X faster
B. The branch misprediction penalty would increase
C. The data hazard penalty would increase
D. The CPI would increase
E. More pipelined registers will be required

**Answer:** 2,3,4,5 = B — The branch misprediction penalty would increase; C — The data hazard penalty would increase; D — The CPI would increase; E — More pipelined registers will be required

> 位于(Exam Facts, notes quiz 2/4_3_review.md), 解释是因为 review 明确提醒 deep-pipe trap：5 到 20 stages 不等于 4 倍提速，branch penalty/data penalty 增加，CPI 可能增加，还需要更多 pipeline registers。

**选项解析：**

- A. ❌ 不能保证 clock rate 4X faster；正确表述：stage 变短可能提频，但 latch overhead、balance 和 hazards 会限制收益。
- B. ✅ 对。分支解析越晚，misprediction flush 的 stage 越多。
- C. ✅ 对。更深 pipeline 会拉大 producer 到 consumer 的距离，data hazard penalty 可能增加。
- D. ✅ 对。更多 stall/flush 会让实际 CPI 增加。
- E. ✅ 对。stage 数增加需要更多 pipeline registers/latches。

### Q22. What information is used to index a branch prediction table in correlated branch prediction (also known as 2-level adaptive branch prediction)?

A. Current PC
B. Branch instruction address
C. PC+4
D. Global branch history

**Answer:** 1,4 = A — Current PC; D — Global branch history

> 位于(4.3 Correlated / 2-Level, notes quiz 2/4_4_review.md), 解释是因为 correlated predictor 使用 global branch history register，并用 PC XOR GHR 索引预测表，所以 current PC 和 global branch history 都参与索引。

**选项解析：**

- A. ✅ 对。Current PC/branch PC 是定位预测表项的一部分。
- B. ❌ Branch instruction address 本质上和 current PC 重复，但题目 key 采用 current PC 表述；正确表述：索引用 PC 与 global history 组合。
- C. ❌ PC+4 是顺序下一条地址，不携带 branch identity/history；正确表述：不用 PC+4 索引 correlated predictor。
- D. ✅ 对。Global branch history 是 2-level/correlated prediction 的关键输入。

### Q23. Which of the following could be effective for static branch predictions?

A. Predict a backward branch taken
B. Predict a forward “beq  rs1, x0” not taken
C. Predict the “beq  rs1, rs2” not taken
D. Predict the blt instructions taken
E. Predict the JALR instruction not taken

**Answer:** 1,2 = A — Predict a backward branch taken; B — Predict a forward “beq  rs1, x0” not taken

> 位于(4.1 Accuracy, notes quiz 2/4_4_review.md), 解释是因为 review 的 static rules 写明 backward branch taken 常用于 loop，forward `beq rs1,x0` 预测 not taken；普通 `beq rs1,rs2`、`blt`、`JALR` 没有这些静态信息。

**选项解析：**

- A. ✅ 对。Backward branch 常是 loop back-edge，静态预测 taken 往往有效。
- B. ✅ 对。Forward `beq rs1,x0` 常用于 early-exit/error checks，review 给出 not taken 静态规则。
- C. ❌ 普通 `beq rs1,rs2` 缺少足够语义信息；正确表述：不能仅凭 opcode 总预测 not taken。
- D. ❌ `blt` 是否 taken 强依赖运行时数据；正确表述：不能作为通用有效静态规则。
- E. ❌ `JALR` 是 indirect jump/call/return 类，目标和行为依赖寄存器；正确表述：通常需要 BTB/RAS/动态机制。

### Q24. Why is a BHT (Branch History Table) usually untagged?

A. Simple
B. Fast access
C. Consume less energy
D. Good for high-performance microprocessors
E. Cost-effective

**Answer:** 1,2,3,5 = A — Simple; B — Fast access; C — Consume less energy; E — Cost-effective

> 位于(4.1 Accuracy, notes quiz 2/4_4_review.md), 解释是因为 untagged BHT 的优点是结构简单、IF 阶段访问快、能耗低、成本低；review 还说明高性能处理器不会仅靠这种简单 untagged BHT。

**选项解析：**

- A. ✅ 对。不存 tag，结构更简单。
- B. ✅ 对。少做 tag match，IF 阶段访问更快。
- C. ✅ 对。表项少、比较逻辑少，能耗更低。
- D. ❌ 高性能处理器更关注减少 aliasing 和提高准确率；正确表述：untagged BHT 适合简单低成本设计。
- E. ✅ 对。面积和逻辑成本低，因此 cost-effective。

### Q25. Which of the following control signals must be propagated through the pipelined registers to the WB stage?

A. Rd (target register)
B. WRen (write-enable)
C. WBsel (Write back selection)
D. ALUctl (ALU control)

**Answer:** 1,2,3 = A — Rd (target register); B — WRen (write-enable); C — WBsel (Write back selection)

> 位于(Exam Facts, notes quiz 2/4_2_review.md), 解释是因为 WB-stage 需要知道写哪个 rd、是否 RegWr、以及 WBSel 从哪里写回；ALU control 在 EX 阶段用完后不会继续传到 WB。

**选项解析：**

- A. ✅ 对。WB 必须知道 target register `rd` 才能写回。
- B. ✅ 对。WRen/RegWr 决定是否写 register file。
- C. ✅ 对。WBsel 选择写回 ALU result、memory data、PC+4 等来源。
- D. ❌ ALUctl 在 EX 阶段控制 ALU，WB 不再需要；正确表述：不必一路传到 WB。

### Q26. Which of the following statements about single-cycle data path implementation is true?

A. CPI is 1, every instruction must finish in one cycle
B. The clock cycle must accommodate the slowest instruction
C. The resources in the data path cannot be reused in the same cycle
D. The result is written back to the register file in the same clock cycle.

**Answer:** 1,2,3 = A — CPI is 1, every instruction must finish in one cycle; B — The clock cycle must accommodate the slowest instruction; C — The resources in the data path cannot be reused in the same cycle

> 位于(Exam Facts; 7. Single-Cycle Limits & Comparison, notes quiz 2/4_1_review.md), 解释是因为 single-cycle 每条指令一个周期完成，CPI=1，clock 由最慢指令决定，并且同一周期资源不能重复使用；这也是 single-cycle 简单但低效的核心限制。

**选项解析：**

- A. ✅ 对。Single-cycle 定义就是每条指令在一个长周期内完成，理想 CPI=1。
- B. ✅ 对。所有指令共用一个 clock period，因此必须按最慢路径设置周期。
- C. ✅ 对。同一周期内同一资源不能给同一指令的不同时间点重复使用，通常需要复制硬件或拉长路径。
- D. ❌ 不是所有指令都写回 register file；正确表述：需要写寄存器的指令会在同一周期末写回。

### Q27. A basic block has 50 instructions; how many legal schedules are possible?

A. In the best case, there is only one schedule
B. In the best case, there are 50 legal schedules
C. In the worst case, there are 50! possible schedules
D. It is quadratic; the worst case has 50² schedules

**Answer:** 1,3 = A — In the best case, there is only one schedule; C — In the worst case, there are 50! possible schedules

> 位于(Exam Facts, notes quiz 2/4_5_review.md), 解释是因为 schedule count 的结论是：如果 50 条指令形成完整依赖链，合法调度只有 1 个；如果互相独立，最坏可有 50! 个拓扑排序。

**选项解析：**

- A. ✅ 对。全依赖链时所有指令顺序被固定，只剩一个合法 schedule。
- B. ❌ Best case 不是 50 个；正确表述：依赖最强时只有 1 个。
- C. ✅ 对。完全独立时 50 条指令任意排列都合法，共 `50!`。
- D. ❌ 调度数量不是简单二次规模；正确表述：独立指令的排列数是阶乘级。

### Q28. A compiler can reorder instructions to avoid data hazards. However, what limitations does it often encounter?

A. Code scheduling is error-prone
B. Memory dependencies may not be known due to possible memory aliasing
C. Structural hazards are hard to deal with
D. Memory operation latencies are unknown and non-deterministic

**Answer:** 2,4 = B — Memory dependencies may not be known due to possible memory aliasing; D — Memory operation latencies are unknown and non-deterministic

> 位于(Exam Facts; 2. Memory Aliasing, notes quiz 2/4_5_review.md), 解释是因为 compiler scheduling 不能随意跨过可能 alias 的 load/store，且 cache hit/miss 造成 memory latency 不确定，所以会限制重排能力。

**选项解析：**

- A. ❌ “error-prone”不是课程给出的主要技术限制；正确表述：限制来自可证明性和运行时不确定性。
- B. ✅ 对。可能 alias 的 memory operations 不能安全重排。
- C. ❌ Structural hazards 主要由硬件资源决定，编译器可帮助但不是本题重点限制。
- D. ✅ 对。Cache hit/miss 使 load latency 运行时变化，编译器难以静态安排完美 schedule。

### Q29. In our RV32I pipelined data path, which stage requires two adders?

A. IF
B. ID
C. EXE
D. MEM
E. WB

**Answer:** 3 = C — EXE

> 位于(6. Branch Datapath, notes quiz 2/4_1_review.md), 解释是因为 EX 阶段需要同时计算 PC+4 和 PC+B-imm，而 ALU 还可能用于比较/地址计算，所以该设计需要两个 adders。

**选项解析：**

- A. ❌ IF 通常有 PC+4 adder，但不是题目所说需要两个 adders 的阶段。
- B. ❌ ID 主要 decode/read registers/generate immediate；正确表述：不是两个加法器集中使用处。
- C. ✅ 对。EXE 同时涉及 branch target/PC 相关加法和 ALU/地址计算路径。
- D. ❌ MEM 主要访问 data memory；正确表述：不需要两个 adders。
- E. ❌ WB 主要选择并写回结果；正确表述：不执行两个加法。

### Q30. When running a binary tree search on a pipelined data path, what hazards are likely to occur?

A. Dependence hazards
B. Structure hazards
C. Data hazards
D. Control hazards
E. Branch hazards

**Answer:** 3,4 = C — Data hazards; D — Control hazards

> 位于(Exam Facts, notes quiz 2/4_4_review.md), 解释是因为 binary-tree search 同时有 pointer load-use 造成的数据依赖，又有根据 key compare 决定方向的 branch，因此 data hazard 和 control hazard 都会出现。

**选项解析：**

- A. ❌ Dependence hazards 不是本课程三大标准 hazard 名称；正确表述：这里具体是 data hazards。
- B. ❌ Binary-tree search 的主要问题不是 IF/MEM 资源争用；正确表述：不是典型 structural hazard。
- C. ✅ 对。访问 child pointer 依赖当前 node load，形成 pointer-chasing data hazard。
- D. ✅ 对。每层比较后选择 left/right 分支，存在 control hazard。
- E. ❌ Branch hazards 不是标准分类；正确表述：应称为 control hazards。

### Q31. Why do some RV pipelined data path designs utilize a comparison unit to execute the compare-and-branch instructions instead of using the standard ALU?

A. To avoid structural hazards
B. Avoid setting the wrong ‘taken/not-taken’ due to integer subtraction overflows.
C. The ALU at the EXE stage is needed for R-type instructions and Load/Store instructions
D. Comparison operation does not trap

**Answer:** 2 = B — Avoid setting the wrong ‘taken/not-taken’ due to integer subtraction overflows.

> 位于(Exam Facts; 6. Branch Datapath, notes quiz 2/4_1_review.md), 解释是因为用 ALU subtraction 的 sign(A-B) 判断大小会在 overflow 时出错，必须修正；独立 comparison unit 可以避免错误的 taken/not-taken 判定。

**选项解析：**

- A. ❌ Comparator 的主要原因不是避免资源冲突；正确表述：资源冲突可通过复制/调度资源处理。
- B. ✅ 对。直接用 subtraction sign 判断大小可能因 overflow 错判 taken/not-taken。
- C. ❌ ALU 服务 R-type/load/store 是事实，但不是采用 comparison unit 的核心正确性理由。
- D. ❌ Comparison 不 trap 不是主要原因；正确表述：关键是比较语义不能被 subtraction overflow 破坏。

### Q32. Intel Pentium 4 has 31 pipeline stages. A branch instruction is resolved pretty late, near the 31st stage.  If the branch misprediction rate is 2%, what would be the performance impact? (Assuming 20% of instructions are branches, and the average CPI is 1).

A. 2%
B. 6%
C. 20%
D. 12%
E. 60%

**Answer:** 4 = D — 12%

> 位于(3. Control Hazards, notes quiz 2/4_4_review.md), 解释是因为 review 给出 Pentium 4 例子：added CPI = 0.2 * 0.02 * 30 = 0.12，在 base CPI=1 时约等于 12% performance impact。

**选项解析：**

- A. ❌ 2% 只看 misprediction rate，漏掉 branch frequency 和 penalty；正确表述：要乘 `0.2 * 0.02 * 30`。
- B. ❌ 6% 对应少算约一半 penalty；正确表述：31-stage late resolve 约 30-cycle penalty。
- C. ❌ 20% 只像 branch frequency，不是性能损失。
- D. ✅ 对。额外 CPI 约 `0.12`，base CPI=1 时性能影响约 12%。
- E. ❌ 60% 过高，像把 misprediction 或 penalty 乘错。

### Q33. What information is stored in the pipelined registers?

A. Control signals
B. Data (ALU results, Register values, Immediates)
C. Addresses (PC, PC+4, memory address)
D. Register designators

**Answer:** 1,2,3,4 = A — Control signals; B — Data (ALU results, Register values, Immediates); C — Addresses (PC, PC+4, memory address); D — Register designators

> 位于(Exam Facts; 1. Five Stages & Pipeline Registers, notes quiz 2/4_3_review.md), 解释是因为 pipeline registers 会携带 downstream control signals，也会携带 ALU result、register values、immediates、PC/PC+4、memory data/address 和 rd 等 register designators。

**选项解析：**

- A. ✅ 对。后续 stage 需要的 control signals 必须随指令推进。
- B. ✅ 对。ALU result、register values、immediates 等数据会存在 pipeline registers。
- C. ✅ 对。PC、PC+4、memory address 等地址信息也会跨 stage 传递。
- D. ✅ 对。`rd` 等 register designators 要传到 WB 才知道写哪里。

### Q34. Which RV32I branch/jump instructions are most difficult to predict?

A. Conditional branches such as BLT/BEQ/BNE
B. Unconditional jumps such as JAL, X0, target
C. Function calls such as JAL X1, function_name
D. Indirect branch for switches, such as JALR, 4(X1)
E. Return branch, such as JALR, X0, 0($ra)

**Answer:** 4 = D — Indirect branch for switches, such as JALR, 4(X1)

> 位于(4.5 BHT vs BTB vs RAS, notes quiz 2/4_4_review.md), 解释是因为 indirect `JALR` 的目标依赖运行时数据，例如 switch jump table、function pointer、virtual call；直接跳转和 return 更容易由 BTB/RAS 预测。

**选项解析：**

- A. ❌ Conditional branch 方向要预测，但目标通常 PC-relative 固定；正确表述：不如 indirect branch target 难。
- B. ❌ Unconditional direct `JAL` 的目标编码在指令里；正确表述：基本不需要方向预测。
- C. ❌ Direct function call 的目标通常固定；正确表述：BTB/直接编码容易处理。
- D. ✅ 对。Indirect `JALR` 的目标由寄存器运行时决定，switch jump table 等最难预测。
- E. ❌ Return 也是 indirect，但 RAS 可较好预测返回地址；正确表述：通常比一般 indirect branch 容易。

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

**选项解析：**

- A. ❌ 使用频率不是 review 给出的主要否定理由；正确表述：核心是硬件复杂度和 ISA regularity。
- B. ✅ 对。该指令既写 load 结果到 `rd`，又写回更新后的 `rs1`，需要两个 write ports/写回路径。
- C. ✅ 对。`rs1` 同时是 base source 又被自增写回为 destination，破坏 RISC-V 简洁规则。
- D. ❌ NIH 是玩笑项；正确表述：不是因为“不是这里发明的”。

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

**选项解析：**

- A. ❌ Disk 和 memory 的差距属于存储层级/I-O 访问问题；正确表述：memory wall 指 CPU 与 DRAM 主存差距。
- B. ❌ DRAM 和 SRAM 的差距是层次结构内部差异；正确表述：memory wall 强调 processor vs main memory。
- C. ❌ Registers 和 L1D 的差距不是该术语核心；正确表述：寄存器/L1 属于片上高速层。
- D. ✅ 对。Memory wall 是 CPU 速度增长与 DRAM latency/bandwidth 改善不匹配造成的瓶颈。

### Q2. Which of the following pieces of information is not stored as part of a data cache line?

A. Data of the cache block
B. Set number
C. The valid bit
D. The address tag
E. The dirty bit

**Answer:** 2 = B — Set number

> 位于(Exam Facts; 2. Cache Basics, notes quiz 2/6_review.md), 解释是因为 cache line 存 valid bit、tag、data，write-back cache 还会有 dirty bit；set number 是地址中的 index 字段，不作为 line metadata 存储。

**选项解析：**

- A. ❌ Data block 是 cache line 的主体内容；正确表述：它会存储在 line 中。
- B. ✅ 对。Set number/index 由地址位和 cache 位置隐含，不作为每条 line 的字段存储。
- C. ❌ Valid bit 用来说明 line 是否有效；正确表述：它属于 line metadata。
- D. ❌ Address tag 用于命中比较；正确表述：tag 存在 line metadata 中。
- E. ❌ Dirty bit 在 write-back cache 中标记是否被修改；正确表述：它也可能是 line metadata。

### Q3. In a memory hierarchy, which layer is managed by the compiler or the programmers?

A. The local memory
B. The L1 cache
C. The L2 cache
D. The write buffer

**Answer:** 1 = A — The local memory

> 位于(Exam Facts, notes quiz 2/6_review.md), 解释是因为 review 把 local memory/scratch-pad 标为由 compiler/programmer 管理，而 L1/L2/L3 cache 由硬件管理。

**选项解析：**

- A. ✅ 对。Local memory/scratchpad 通常由程序员或编译器显式管理数据放置。
- B. ❌ L1 cache 由硬件自动管理 tags、replacement、fills；正确表述：不是 compiler/programmer 直接管理。
- C. ❌ L2 cache 同样由硬件管理；正确表述：程序只能间接影响访问局部性。
- D. ❌ Write buffer 是硬件微架构队列；正确表述：不是软件管理的层。

### Q4. We have a 64 KB, 4-way set-associative cache with a 32-byte block (line) size. When the CPU issues a 32-bit memory address, how many bits are allocated to the Tag, the Set Index, and the Block Offset, respectively?

A. 16, 11, 5
B. 18, 8, 6
C. 18, 9, 5
D. 17, 9, 6

**Answer:** 3 = C — 18, 9, 5

> 位于(2.1 Parameter Formulas, notes quiz 2/6_review.md), 解释是因为 S=C/(B*E)=64KB/(32B*4)=512 sets，所以 offset=log2(32)=5，set index=log2(512)=9，tag=32-9-5=18。

**选项解析：**

- A. ❌ `16,11,5` 的 offset 对，但 sets 被算成 2048，忽略了 4-way；正确表述：set index 应为 9。
- B. ❌ `18,8,6` 把 block offset 当成 64B line；正确表述：32B line offset 是 5。
- C. ✅ 对。64KB/(32B*4)=512 sets，offset=5，index=9，tag=18。
- D. ❌ `17,9,6` 的 index 对但 offset 对应 64B line；正确表述：offset 5，tag 18。

### Q5. Which of the following data structures is used in a non-blocking cache?

A. A prefetch buffer
B. AMAT counter
C. MSHR
D. Interlock table

**Answer:** 3 = C — MSHR

> 位于(10. MSHR & Non-Blocking Cache, notes quiz 2/6_review.md), 解释是因为 MSHR 用来跟踪 outstanding misses，使 non-blocking cache 支持 hit-under-miss / miss-under-miss 和 miss merging。

**选项解析：**

- A. ❌ Prefetch buffer 用来暂存预取数据，不是跟踪 outstanding miss 状态的核心结构。
- B. ❌ AMAT counter 不是 cache 运行时管理结构；正确表述：AMAT 是性能分析指标。
- C. ✅ 对。MSHR 记录 miss address、等待者、返回数据去向等状态，是 non-blocking cache 的关键。
- D. ❌ Interlock table 不是课程中 non-blocking cache 的标准结构；正确表述：应为 MSHR。

### Q6. Which of the following cache organizations does not make sense?

A. L3 is write-through
B. L1 is direct-mapped plus a victim cache
C. L2 write-back with write allocate
D. Split L1I / L1D

**Answer:** 1 = A — L3 is write-through

> 位于(4.2 Write Hit: WT vs WB; 8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 write-through 会造成高 memory traffic，而 L3 的主要目标是减少 DRAM traffic；因此把 L3 设计成 write-through 通常不合理。

**选项解析：**

- A. ✅ 对。L3/LLC 若 write-through，会把大量写流量推向内存，违背减少 DRAM traffic 的目的。
- B. ❌ L1 direct-mapped + victim cache 是合理组合，可降低 conflict misses。
- C. ❌ L2 write-back with write-allocate 是常见合理策略。
- D. ❌ Split L1I/L1D 是现代处理器常见组织，用于带宽和结构冲突。

### Q7. In a typical modern multi-core processor, which level of cache is usually shared among all the CPU cores?

A. L1
B. L2
C. L3
D. L4

**Answer:** 3 = C — L3

> 位于(8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 review 明确写出 L3/LLC 是 multi-MB 并 shared by all cores，用来减少 DRAM traffic。

**选项解析：**

- A. ❌ L1 通常是每核私有，追求低 hit latency。
- B. ❌ L2 常见为每核私有或小范围共享，不是“通常所有核心共享”的层。
- C. ✅ 对。L3/LLC 在典型多核 CPU 中由多个或全部核心共享。
- D. ❌ L4 不一定存在；正确表述：若存在也不是本题典型答案。

### Q8. For a single-cycle data path design, if the D-cache miss rate is 5%, 40% of instructions are load/stores, and the memory latency is 100 cycles. What would be the average CPI?

A. 2.0
B. 1.4
C. 1.6
D. 3.0

**Answer:** 4 = D — 3.0

> 位于(5. Cache Performance, notes quiz 2/6_review.md), 解释是因为 CPI = base CPI + data accesses/instr * miss rate * miss penalty = 1 + 0.4 * 0.05 * 100 = 3.0。

**选项解析：**

- A. ❌ 2.0 少算了部分 miss penalty；正确表述：额外 CPI 是 `0.4*0.05*100=2`，总 CPI 是 3。
- B. ❌ 1.4 像只加了 load/store 比例，没有乘完整 miss penalty。
- C. ❌ 1.6 也没有按公式计算出额外 2.0 cycles/instr。
- D. ✅ 对。Base CPI 1 加 data miss penalty 2，平均 CPI = 3.0。

### Q9. The instruction cache is usually easier to manage than the data cache. Why?

A. It does not need to handle write operations
B. It does not need the valid bit
C. It does not need to handle cache line replacements
D. It does not need the tag bits

**Answer:** 1 = A — It does not need to handle write operations

> 位于(4.5 I-cache Specifics, notes quiz 2/6_review.md), 解释是因为 I-cache 不接收来自 CPU 的 store，所以不需要写策略或 dirty bit；data cache 必须处理 read/write hit/miss 四种情况。

**选项解析：**

- A. ✅ 对。I-cache 正常只取指，不处理 CPU store，所以管理比 D-cache 简单。
- B. ❌ I-cache 仍需要 valid bit 判断 line 是否有效。
- C. ❌ I-cache 也会发生 miss 并需要 line replacement；正确表述：只是没有普通 store 写入。
- D. ❌ I-cache 仍需要 tag bits 判断取指地址是否命中。

### Q10. In modern processors, what is the likely L1D cache hit latency?

A. 1 cycle
B. 3-4 cycles
C. 5-6 cycles
D. 10+ cycles

**Answer:** 2 = B — 3-4 cycles

> 位于(5. Cache Performance, notes quiz 2/6_review.md), 解释是因为 review 直接给出现代 L1D hit latency 通常是 3-4 cycles。

**选项解析：**

- A. ❌ 1 cycle 对现代高频、多路 L1D 通常过于乐观；正确表述：典型 L1D hit 约 3-4 cycles。
- B. ✅ 对。Review 给出的现代 L1D hit latency 是 3-4 cycles。
- C. ❌ 5-6 cycles 更像较慢/更大层级或特殊设计，不是 likely L1D。
- D. ❌ 10+ cycles 通常已接近更低级 cache/复杂访问，不是 L1D hit。

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

**选项解析：**

- A. ❌ 4-way 合理，但 write-through 会增加下级带宽压力；正确表述：现代 L1D 常用 write-back。
- B. ❌ Fully-associative L1D 成本/延迟过高，write-through + no-allocate 也不是典型组合。
- C. ❌ Direct-mapped 简单但 conflict misses 多；正确表述：现代 L1D 更常用小路数 set-associative。
- D. ✅ 对。4-way set-associative、write-back、write-allocate 是典型现代 L1D 组织。
- E. ❌ Direct-mapped 和 write-no-allocate 都不符合典型 L1D 常见组合。

### Q12. If minimizing the tag space is the primary goal, which cache features should be used?

A. Set associative caches
B. Direct-mapped caches
C. Write no-allocate policy
D. Large cache blocks (lines)
E. Inclusive caches

**Answer:** 2, 4 = B — Direct-mapped caches; D — Large cache blocks (lines)

> 位于(Exam Facts; 3. 4 Cache-Design Questions, notes quiz 2/6_review.md), 解释是因为 direct-mapped cache 的 tag overhead 最低；较大的 cache line 会减少 line 数量，从而节省 tag/meta space。

**选项解析：**

- A. ❌ Set associative 通常每个 set 多个 way/tag，tag/comparator 开销更高；正确表述：不是最省 tag space。
- B. ✅ 对。Direct-mapped 每个 set 只有一个 way，metadata 和比较逻辑最少。
- C. ❌ Write no-allocate 是写 miss 策略，不直接减少 tag 数量。
- D. ✅ 对。Line 变大时同容量下 line 数减少，tag entries 也减少。
- E. ❌ Inclusive cache 是多级包含策略，不是减少 tag space 的直接特性。

### Q13. Modern processors typically include on-chip L1, L2, and L3 caches. Which statement is TRUE?

A. The primary goal of L3 cache is to reduce the memory traffic to the memory
B. The primary goal of the L1 cache is to have a fast hit time
C. The L3 cache is often shared by multiple cores
D. The L2’s goal is to balance the speed and the capacity

**Answer:** 1,2,3,4 = A — The primary goal of L3 cache is to reduce the memory traffic to the memory; B — The primary goal of the L1 cache is to have a fast hit time; C — The L3 cache is often shared by multiple cores; D — The L2’s goal is to balance the speed and the capacity

> 位于(8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 L1 的目标是 fast hit time，L2 平衡 speed 和 capacity，L3/LLC 由多核共享并减少 DRAM traffic；四个说法都符合 review。

**选项解析：**

- A. ✅ 对。L3/LLC 的重要目标是过滤 DRAM 访问、减少 memory traffic。
- B. ✅ 对。L1 靠近 pipeline，首要目标是 fast hit time。
- C. ✅ 对。L3 常作为 shared last-level cache。
- D. ✅ 对。L2 处在 L1 与 L3/DRAM 之间，通常平衡速度和容量。

### Q14. What are the four types of cache misses (4C’s) ?

A. Compulsory misses, Conflict misses, Capacity misses, Coherence misses
B. Cold misses, Collision misses, Capacity misses, Coherence misses
C. Cascaded misses, Controlled misses, Contiguous misses, Conditional misses
D. Cool misses, Cold misses, Capacity misses, Coherence misses

**Answer:** 1,2 = A — Compulsory misses, Conflict misses, Capacity misses, Coherence misses; B — Cold misses, Collision misses, Capacity misses, Coherence misses

> 位于(6. 4 C's of Misses, notes quiz 2/6_review.md；未在 *_review.md 中直接写出 Cold/Collision 的同义说明), 解释是因为 review 列出的 4C 是 Compulsory、Conflict、Capacity、Coherence；选项 B 用 Cold 对应 compulsory、Collision 对应 conflict，所以 A/B 都表达同一组概念。

**选项解析：**

- A. ✅ 对。这是 review 明确列出的 4C：Compulsory、Conflict、Capacity、Coherence。
- B. ✅ 对。Cold miss 是 compulsory miss 的常见同义说法，collision miss 对应 conflict miss。
- C. ❌ Cascaded/Controlled/Contiguous/Conditional 不是 cache miss 的 4C 分类；正确表述：应为 compulsory/conflict/capacity/coherence。
- D. ❌ Cool miss 不是标准类型，且缺少 conflict/collision；正确表述：Cold 可替代 compulsory，但 Cool 不可。

### Q15. Among the 4C’s, which cache misses are the most difficult to remove?

A. Compulsory
B. Collision
C. Capacity
D. Coherence

**Answer:** 4 = D — Coherence

> 位于(6. 4 C's of Misses, notes quiz 2/6_review.md), 解释是因为 coherence misses 通常来自其他核心的 invalidation，review 明确说 hardest to remove，需要减少共享或改写程序。

**选项解析：**

- A. ❌ Compulsory misses 可用 prefetch/large line 缓解；正确表述：不是最难去除。
- B. ❌ Collision/conflict misses 可通过 associativity、victim cache、layout 等减少。
- C. ❌ Capacity misses 可通过增大 cache、降低 working set、prefetch 等缓解。
- D. ✅ 对。Coherence misses 由多核共享写入和 invalidation 引起，最难从 cache 组织本身消除。

### Q16. For the compulsory misses, how may we reduce them?

A. Hardware prefetching
B. Having a larger cache line size
C. Increase the cache size
D. Add a victim cache

**Answer:** 1,2 = A — Hardware prefetching; B — Having a larger cache line size

> 位于(6. 4 C's of Misses; 3. 4 Cache-Design Questions, notes quiz 2/6_review.md), 解释是因为 compulsory miss 是首次访问导致，能用 prefetch 或 larger block/line 借助空间局部性减少；单纯增大 cache 不会消除首次访问。

**选项解析：**

- A. ✅ 对。Hardware prefetching 可在真正首次使用前提前取入，降低观察到的 compulsory miss。
- B. ✅ 对。更大 line 一次带入相邻数据，可减少后续第一次访问相邻块的 compulsory misses。
- C. ❌ 增大 cache 主要减少 capacity misses；正确表述：首次访问仍然会 miss。
- D. ❌ Victim cache 主要缓解 conflict misses；正确表述：不解决第一次访问问题。

### Q17. Compare the L2 to the L1 cache, the L2 cache is usually

A. Larger
B. Slower
C. Unified
D. Shared

**Answer:** 1,2,3 = A — Larger; B — Slower; C — Unified

> 位于(8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 L2 通常比 L1 更大、更慢，并且 often private/unified；shared by all cores 更典型的是 L3。

**选项解析：**

- A. ✅ 对。L2 通常容量大于 L1。
- B. ✅ 对。L2 离核心更远/容量更大，hit latency 通常高于 L1。
- C. ✅ 对。L2 通常 unified，存 instruction 和 data。
- D. ❌ Shared by all cores 更常见于 L3/LLC；正确表述：L2 常为 private 或局部共享。

### Q18. Four processors are connected to the main memory via a global bus. What are the possible solutions to maintain cache coherence?

A. Use a shared cache; no private cache allowed
B. If caches are private, use the Snoopy protocol
C. Build an inclusive multi-level cache
D. Split the instruction and the data cache

**Answer:** 1,2 = A — Use a shared cache; no private cache allowed; B — If caches are private, use the Snoopy protocol

> 位于(9. Cache Coherence, notes quiz 2/6_review.md), 解释是因为 review 给出的 coherence solutions 是使用 shared cache，或者在 private caches 上用 snoopy protocol 监听共享总线。

**选项解析：**

- A. ✅ 对。若只有 shared cache 而无 private cache，就没有 private copies 之间的一致性问题。
- B. ✅ 对。Private caches 连接共享总线时可用 snoopy protocol 监听并维护 coherence。
- C. ❌ Inclusive multi-level cache 可帮助 snoop/filter，但本身不是完整 coherence solution。
- D. ❌ Split I/D cache 解决结构冲突/带宽，不维护多处理器数据一致性。

### Q19. Assume the same cache size and the same line size. Which of the following statements are always true?

A. A direct-mapped cache is faster than set associative caches
B. A fully associative cache has the lowest cache miss rate
C. A direct-mapped cache has the lowest tag overhead
D. Replacement policy in a direct-mapped cache is the simplest

**Answer:** 3,4 = C — A direct-mapped cache has the lowest tag overhead; D — Replacement policy in a direct-mapped cache is the simplest

> 位于(3. 4 Cache-Design Questions, notes quiz 2/6_review.md), 解释是因为在相同 cache size 和 line size 下，direct-mapped 的 tag overhead 最低且 replacement 最简单；review 同时指出它不一定总是 hit latency 最快，fully associative 也不保证 miss rate 最低。

**选项解析：**

- A. ❌ Direct-mapped 常更简单，但“always faster”过绝对；正确表述：速度取决于容量、电路和实现。
- B. ❌ Fully associative 消除 conflict misses，但 replacement/容量等仍影响实际 miss rate；正确表述：不保证 always lowest。
- C. ✅ 对。相同容量和 line size 下，direct-mapped tag/meta overhead 最低。
- D. ✅ 对。Direct-mapped 每个 set 只有一个位置，没有替换选择，replacement 最简单。

### Q20. What are the advantages of using a large cache line size?

A. It exploits more spatial locality
B. It exploits more temporal locality
C. It saves tag space
D. It could reduce compulsory misses

**Answer:** 1,3,4 = A — It exploits more spatial locality; C — It saves tag space; D — It could reduce compulsory misses

> 位于(3. 4 Cache-Design Questions, notes quiz 2/6_review.md), 解释是因为 large cache line 能利用更多 spatial locality、降低 tag overhead，并减少 compulsory misses；但它不直接提升 temporal locality，还会增加 miss penalty 和 bandwidth 压力。

**选项解析：**

- A. ✅ 对。大 line 一次带入相邻地址，利用 spatial locality。
- B. ❌ Temporal locality 是重复访问同一数据；正确表述：line 变大不直接增加时间局部性。
- C. ✅ 对。同容量下 line 数减少，tag entries 减少。
- D. ✅ 对。相邻数据被首次访问前可能已随大 line 带入，减少 compulsory misses。

### Q21. My computer has a two-way set associative cache with 4KB and 32B line size, which of the following memory reference sequences would run into conflict misses?

A. 0x01ABC000, 0x01ABC004, 0x01ABC010, 0x01ABC002,
B. 0x01ABC000, 0x01ABC020, 0x01ABC030, 0x01ABC040,
C. 0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010,
D. 0x01ABC020, 0x01ABC030, 0x01ABC02A, 0x01ABC03A,

**Answer:** 3 = C — 0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010,

> 位于(2.2 Direct-Mapped Conflict, notes quiz 2/6_review.md), 解释是因为 4KB、2-way、32B line 有 S=64 sets，set 每 2KB 重复；选项 C 的多个地址落到同一 set 且超过 2-way 可容纳的 live blocks，因此会产生 conflict misses。

**选项解析：**

- A. ❌ 这些地址都在同一个 32B line 内，不形成多个 blocks 争同一 set。
- B. ❌ `0x...000`、`0x...020/030`、`0x...040` 分布在相邻 sets 或同一 line 内，不超过 2-way 同 set 容量。
- C. ✅ 对。多个不同 32B blocks 映射到同一 set，超过 2-way 可容纳数量，会 conflict。
- D. ❌ 地址主要落在 `0x...020` 同一 line 或相邻 line，未形成超过 2-way 的同 set 冲突。

### Q22. What is the multi-level cache implemented in your project #4?

A. Inclusive cache
B. Exclusive cache
C. NINE cache
D. Shared cache

**Answer:** 3 = C — NINE cache

> 位于(未在 *_review.md 中找到 project #4 具体实现的直接出处；参考 8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 review 只定义了 NINE = non-inclusive, non-exclusive；题目所问 project #4 的实现结论应选 NINE，但这个项目事实没有在 review 中直接写出。

**选项解析：**

- A. ❌ Inclusive cache 要求上层内容包含在下层中；正确表述：Project #4 key 不选 inclusive。
- B. ❌ Exclusive cache 要求上下层内容互斥；正确表述：Project #4 key 不选 exclusive。
- C. ✅ 对。按题目 key，Project #4 实现的是 NINE，即 non-inclusive, non-exclusive。
- D. ❌ Shared cache 描述多核共享关系，不是这里 multi-level inclusion policy 的答案。

### Q23. What replacement algorithm is implemented in the typical set-associative caches today?

A. LRU
B. FIFO
C. Approximate LRU
D. Random
E. Belady’s algorithm

**Answer:** 3 = C — Approximate LRU

> 位于(7. Replacement Policies, notes quiz 2/6_review.md), 解释是因为真实 set-associative cache 中精确 LRU 成本高，review 写明 typical in real caches 的是 pseudo-LRU / approximate LRU。

**选项解析：**

- A. ❌ True LRU 精确维护顺序成本高；正确表述：真实 cache 通常不用精确 LRU。
- B. ❌ FIFO 简单但不代表典型现代 set-associative cache replacement。
- C. ✅ 对。Approximate/pseudo LRU 在成本和效果之间折中，是典型实现。
- D. ❌ Random 可用但不是 review 所说 typical replacement。
- E. ❌ Belady 是离线最优基准，需要未来信息，不能实际实现。

### Q24. If you would like to implement a TRUE LRU replacement algorithm, what data structure should be used?

A. A queue
B. A stack
C. A tree
D. A heap

**Answer:** 2 = B — A stack

> 位于(7. Replacement Policies, notes quiz 2/6_review.md), 解释是因为 true LRU 需要维护从最近使用到最久未使用的精确顺序，review 明确给出数据结构是 stack。

**选项解析：**

- A. ❌ Queue 更像 FIFO，不能在每次 hit 时把任意元素移到 MRU 位置来精确表示 LRU。
- B. ✅ 对。True LRU 用 stack/order list 维护 MRU 到 LRU 的精确顺序。
- C. ❌ Tree 常用于 pseudo-LRU，不是 true LRU 的精确结构。
- D. ❌ Heap 适合优先级，不适合按每次访问维护精确 recency order。

### Q25. You developed a new cache replacement algorithm that effectively balances procedure calls and looping behaviors. Now, what is the upper bound you need to evaluate against?

A. Against LRU
B. Against Random
C. Against Belady’s algorithm
D. Against a perfect cache

**Answer:** 3 = C — Against Belady’s algorithm

> 位于(7. Replacement Policies, notes quiz 2/6_review.md), 解释是因为 Belady optimal 会淘汰未来最晚再用的块，是不可实现但可作为 miss-rate 上界/最优基准的算法。

**选项解析：**

- A. ❌ LRU 是现实可实现/近似基准，但不是理论上界。
- B. ❌ Random 是弱 baseline，不是新算法评估的 upper bound。
- C. ✅ 对。Belady's algorithm 使用未来信息，给出离线最优 miss rate 上界。
- D. ❌ Perfect cache 太理想化，通常不是 replacement algorithm 的可比上界；正确表述：应对比 Belady optimal。

### Q26. My cache supports both write-allocate and write-no-allocate policies; it is controlled by a bit in the store instruction. Under what condition should the store instruction turn on “write-no-allocate”?

A. In the memcpy(a,b,n) lib call when n is large
B. When storing local variables in a procedure
C. When storing a struct member (e.g., st.a or st->a)
D. In the memset(a,b,n) lib call when n is large.
E. When writing database logs

**Answer:** 1,4,5 = A — In the memcpy(a,b,n) lib call when n is large; D — In the memset(a,b,n) lib call when n is large.; E — When writing database logs

> 位于(4.3 Write Miss: WA vs NWA, notes quiz 2/6_review.md), 解释是因为 no-write-allocate 适合 streaming writes，例如 large `memcpy`、large `memset` 和 database logs；local variables 或 struct member 通常会复用，适合 write-allocate。

**选项解析：**

- A. ✅ 对。Large `memcpy` 的 streaming writes 往往不需要把目标 line 读入 cache，适合 write-no-allocate。
- B. ❌ Local variables 往往很快复用；正确表述：更适合 write-allocate/cache 住。
- C. ❌ Struct member store 可能与同一对象其他字段有局部性；正确表述：不应默认 no-allocate。
- D. ✅ 对。Large `memset` 是连续写入且可能少读，适合 no-write-allocate。
- E. ✅ 对。Database logs 常是 streaming append writes，避免污染 cache 合理。

### Q27. Which cache features require greater bus and memory bandwidth?

A. Large cache lines
B. Cache prefetching
C. Non-blocking caches
D. Exclusive, multi-level, write-back caches
E. Write-through caches

**Answer:** 1,2,3,5 = A — Large cache lines; B — Cache prefetching; C — Non-blocking caches; E — Write-through caches

> 位于(10. MSHR & Non-Blocking Cache, notes quiz 2/6_review.md), 解释是因为 review 将 large lines、prefetch、non-blocking cache、write-through 都归为 bandwidth-heavy features；它们会增加总线和内存带宽压力。

**选项解析：**

- A. ✅ 对。Large cache lines 每次 miss 搬运更多 bytes，需要更高带宽。
- B. ✅ 对。Prefetch 会产生额外提前请求，可能增加总线/内存流量。
- C. ✅ 对。Non-blocking caches 允许多个 outstanding misses，需要并发服务带宽。
- D. ❌ Exclusive multi-level write-back 不必然增加总线/内存带宽；正确表述：write-back 通常减少写流量。
- E. ✅ 对。Write-through 每次写都向下级传播，带宽需求更高。

### Q28. Which of the following statements about the “snoopy” cache are true?

A. It works as a watchdog for preventing illegal cache references
B. It is designed to maintain cache coherence for bus-connected multi-processor systems
C. It is designed for data security enforcement
D. It will generate significant snooping bus traffic

**Answer:** 2,4 = B — It is designed to maintain cache coherence for bus-connected multi-processor systems; D — It will generate significant snooping bus traffic

> 位于(9. Cache Coherence, notes quiz 2/6_review.md), 解释是因为 snoopy cache 是 private caches 在 shared bus 上监听其他 cache 行为以维持 coherence；review 也指出它会带来显著 snoop traffic。

**选项解析：**

- A. ❌ Snoopy 不是安全 watchdog，也不是防非法访问机制；正确表述：它监听总线维护一致性。
- B. ✅ 对。Snoopy protocol 正是 bus-connected multiprocessor private caches 的 coherence 方案。
- C. ❌ 它不负责 data security enforcement；正确表述：安全 enforcement 属于权限/保护机制。
- D. ✅ 对。所有 cache 监听总线事务，会产生显著 snooping traffic。

### Q29. Which of the following could reduce conflict misses incurred in a direct-mapped L1D cache?

A. Increase the cache sizes
B. Increase the cache block (line) sizes
C. Add a victim cache
D. Change to set associative cache
E. Use the best replacement algorithm

**Answer:** 1,3,4 = A — Increase the cache sizes; C — Add a victim cache; D — Change to set associative cache

> 位于(6. 4 C's of Misses, notes quiz 2/6_review.md), 解释是因为 direct-mapped conflict misses 可通过 larger cache、victim cache 或提高 associativity 减少；larger line 可能减少 compulsory miss 但也可能加剧 conflict，replacement policy 对 direct-mapped 没有选择空间。

**选项解析：**

- A. ✅ 对。增大 cache 可增加 sets/容量，减少不同 blocks 映射同一位置的概率。
- B. ❌ 增大 line size 会减少 line 数，可能加剧 conflict；正确表述：它主要帮助 spatial/compulsory misses。
- C. ✅ 对。Victim cache 可接住刚被 direct-mapped cache 冲掉的 line，缓解 conflict。
- D. ✅ 对。改成 set-associative 允许同一 set 容纳多个 blocks，直接减少 conflict。
- E. ❌ Direct-mapped 没有 replacement choice；正确表述：replacement algorithm 对它不起作用。

### Q30. Which of the following are often useful in reducing cache capacity misses?

A. Increase the cache sizes
B. Increase the cache block (line) sizes
C. Add one victim cache
D. Change to set associative cache
E. Cache prefetching

**Answer:** 1,5 = A — Increase the cache sizes; E — Cache prefetching

> 位于(6. 4 C's of Misses, notes quiz 2/6_review.md), 解释是因为 capacity miss 来自 working set 超过 cache，review 给出的常见改善是 bigger cache 和 prefetching；victim cache/associativity 主要针对 conflict。

**选项解析：**

- A. ✅ 对。增大 cache 可容纳更大 working set，直接减少 capacity misses。
- B. ❌ 固定容量下 line 变大会减少 line 数，不一定减少 capacity misses；正确表述：主要影响 spatial/compulsory。
- C. ❌ Victim cache 主要减少 conflict misses，不扩大主 cache working-set 容量。
- D. ❌ Set associativity 主要减少 conflict misses；正确表述：容量不变时不直接解决 working set 过大。
- E. ✅ 对。Review 把 prefetching 列为 reducing capacity 相关帮助；它可提前带入将要用的数据、隐藏/改善容量相关 miss 行为。

### Q31. MSHR (Miss Status Handling Registers) are used to track multiple outstanding cache misses. Each level of cache has its own MSHR. On a multicore chip, the number of entries in the L3 MSHR would likely be influenced by

A. The memory latency
B. The memory bus width
C. The size of the L2 cache
D. The number of cores sharing the L3

**Answer:** 1,2 = A — The memory latency; B — The memory bus width

> 位于(10. MSHR & Non-Blocking Cache, notes quiz 2/6_review.md), 解释是因为 L3 MSHR entries 用来覆盖 outstanding memory misses，review 明确说数量受 memory latency 和 bus width 影响，而不是 L2 size 或 sharing cores 数量。

**选项解析：**

- A. ✅ 对。Memory latency 越长，需要更多 outstanding misses 才能覆盖等待时间。
- B. ✅ 对。Memory bus width/bandwidth 影响可并发服务和返回数据的能力。
- C. ❌ Review 明确说不是 L2 cache size；正确表述：L3 MSHR 跟下游内存系统延迟/带宽更相关。
- D. ❌ Review 明确说不是 sharing L3 的 cores 数；正确表述：核心数可能影响请求压力，但该题按 review 不作为决定项。

### Q32. I-cache does not take stores from the processor. However, modern applications use “instruction patching” or “JIT” code generation to either modify instructions or generate a new code section for subsequent execution.  Which of the following solutions are required for evicting stale instructions in the I-cache?

A. Flush the I-cache to purge all old instructions
B. Invalidate the I-cache lines containing the instructions
C. Flush the data caches
D. Maintain coherence between I- and D-cache: any updates to the D-cache will also write into the respective lines in I-cache.

**Answer:** 1,2,4 = A — Flush the I-cache to purge all old instructions; B — Invalidate the I-cache lines containing the instructions; D — Maintain coherence between I- and D-cache: any updates to the D-cache will also write into the respective lines in I-cache.

> 位于(4.5 I-cache Specifics, notes quiz 2/6_review.md), 解释是因为 JIT/self-modifying code 会让 I-cache 中旧指令过期，需要 flush I-cache、invalidate affected I-lines，或维护 I/D coherence；单独 flush D-cache 不足以清除 I-cache stale instructions。

**选项解析：**

- A. ✅ 对。Flush I-cache 可清掉所有旧指令，保证后续重新取新代码。
- B. ✅ 对。Invalidate 包含修改指令的 I-cache lines 是更精确的做法。
- C. ❌ Flush data caches 只处理 D-cache 中的数据，不保证 I-cache 不继续持有旧指令。
- D. ✅ 对。维护 I/D cache coherence 可让 D-cache 更新同步反映到 I-cache，避免 stale instruction。

### Q33. Which of the following multi-level cache organizations does not make sense?

A. L1I copy back and L1D write-through
B. L1/L2 exclusive, L2/L3 inclusive
C. L1D 4-way set associative, L2 direct mapped
D. L1/L2 inclusive, L2/L3 exclusive

**Answer:** 1,2,3 = A — L1I copy back and L1D write-through; B — L1/L2 exclusive, L2/L3 inclusive; C — L1D 4-way set associative, L2 direct mapped

> 位于(8. Multi-Level Caches, notes quiz 2/6_review.md), 解释是因为 review 的 nonsensical orgs 包括 L1I write-back、L1/L2 exclusive 同时 L2/L3 inclusive，以及 L1D 4-way 但 L2 direct-mapped；L1/L2 inclusive 且 L2/L3 exclusive 在 review 中标为 OK。

**选项解析：**

- A. ✅ 不合理。L1I 不接受普通 store，copy-back/write-back I-cache 语义不合适；L1D write-through 又会增加下级流量。
- B. ✅ 不合理。L1/L2 exclusive 与 L2/L3 inclusive 组合会让包含关系和唯一性目标互相冲突。
- C. ✅ 不合理。L1D 比 L2 更高相联而 L2 direct-mapped，容易在下级制造严重 conflict/包含管理问题。
- D. ❌ 这组在 review 中标为可行；正确表述：L1/L2 inclusive、L2/L3 exclusive 并非题目所问 nonsensical。

### Q34. In contemporary processors, the vast majority of chip space is dedicated to what?

A. Branch prediction
B. Register files
C. Pipelined registers
D. Floating-point functional units
E. Caches

**Answer:** 5 = E — Caches

> 位于(Exam Facts, notes quiz 2/6_review.md), 解释是因为现代处理器芯片面积中很大一部分用于 cache 层级，review 直接写出 vast chip area = caches。

**选项解析：**

- A. ❌ Branch prediction 很重要但面积占比通常不如 cache 层级。
- B. ❌ Register files 占面积但不是 contemporary processors vast majority。
- C. ❌ Pipeline registers 分布广但面积占比不是最大。
- D. ❌ FP units 重要但数量有限，不是大多数芯片面积。
- E. ✅ 对。多级 caches 尤其 LLC 往往占据大量芯片面积。

### Q35. Which of the following sorting algorithms is known to have high data locality?

A. Quicksort
B. Insertion sort
C. Heapsort
D. Radix sort
E. Bubble sort

**Answer:** 1,2,5 = A — Quicksort; B — Insertion sort; E — Bubble sort

> 位于(11. Locality Application Patterns, notes quiz 2/6_review.md), 解释是因为 review 把 Quicksort、Insertion sort、Bubble sort 标为 high locality；Heapsort 和 Radix sort 因访问模式更分散而 locality 较差。

**选项解析：**

- A. ✅ 对。Quicksort partition 多为连续数组扫描，局部性较好。
- B. ✅ 对。Insertion sort 在小范围相邻元素上操作，局部性高。
- C. ❌ Heapsort 在 heap 树形索引中跳跃访问，cache locality 较差。
- D. ❌ Radix sort 多趟分桶/散布访问，局部性不如这些高 locality 排序。
- E. ✅ 对。Bubble sort 反复访问相邻元素，空间局部性高。

### Q36. What is the difference between a hardware cache and a software cache (such as a disk file cache)?

A. Software caches are managed by system software or applications, whereas hardware caches are managed by the hardware
B. Hardware caches support associative search, while software caches utilize lookup data structures such as hash tables.
C. Hardware caches must implement simple and fast replacement algorithms; software caches can use more complex algorithms.
D. Hardware caches are flexible in size, but software caches are not.

**Answer:** 1,2,3 = A — Software caches are managed by system software or applications, whereas hardware caches are managed by the hardware; B — Hardware caches support associative search, while software caches utilize lookup data structures such as hash tables.; C — Hardware caches must implement simple and fast replacement algorithms; software caches can use more complex algorithms.

> 位于(11. Locality Application Patterns, notes quiz 2/6_review.md), 解释是因为 hardware cache 由硬件透明管理、用 associative tag compare、replacement 必须简单快速；software cache 由 OS/app 管理，可用 hash/tree lookup 和更复杂策略。

**选项解析：**

- A. ✅ 对。Software cache 由 OS/app/system software 管理，hardware cache 由硬件自动管理。
- B. ✅ 对。Hardware cache 依赖 tag/associative compare；software cache 常用 hash table/tree 等 lookup structure。
- C. ✅ 对。Hardware replacement 必须极快，software cache 可承受更复杂策略。
- D. ❌ Hardware cache 大小通常固定在芯片上，software cache 更容易调整策略和大小；正确表述：选项把灵活性说反了。

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

**选项解析：**

- A. ❌ `gcc` 是 compiler driver，可调用 assembler/linker；正确表述：它不是标准 linker 本体。
- B. ❌ `ln` 是创建文件 link 的 Unix 命令；正确表述：不是程序链接器。
- C. ✅ 对。Unix/Linux 标准 linker 是 `ld`。
- D. ❌ `ll` 不是标准 linker 命令。
- E. ❌ `link` 不是本课程 Unix/Linux 标准 linker 答案；正确表述：应为 `ld`。

### Q2. How do you read the detailed information of an ELF file?

A. objdump
B. gdb
C. ldd
D. readelf
E. nm

**Answer:** 4 = D — readelf

> 位于(Exam Facts, 7_review.md), 解释是因为 review 把 `readelf` 标为查看 ELF full details 的工具；`objdump` 更偏 disassembly/relocations，`nm` 更偏 symbol list。

**选项解析：**

- A. ❌ `objdump` 适合反汇编和查看部分 section/relocation；正确表述：详细 ELF 元数据首选 `readelf`。
- B. ❌ `gdb` 是 debugger，不是专门读取 ELF detailed information 的工具。
- C. ❌ `ldd` 查看动态库依赖；正确表述：不用于完整 ELF 结构细节。
- D. ✅ 对。`readelf` 用来读取 ELF headers、sections、symbols、relocations 等详细信息。
- E. ❌ `nm` 主要列 symbol table；正确表述：信息范围小于 `readelf`。

### Q3. Which of the following is NOT a job for the linker?

A. Symbol resolution
B. Handling libraries
C. Loading into the memory
D. Section merging
E. Relocation

**Answer:** 3 = C — Loading into the memory

> 位于(Exam Facts, 7_review.md), 解释是因为 linker 的工作包括 symbol resolution、relocation、section merging、library handling；loading into memory 是 loader/dynamic linker 的工作。

**选项解析：**

- A. ❌ Symbol resolution 是 linker 核心工作；正确表述：它会把引用绑定到定义。
- B. ❌ Handling libraries 是 linker 工作之一；正确表述：它会搜索/合并需要的库对象。
- C. ✅ 对。Loading into memory 是 loader/OS/dynamic loader 的工作，不是静态 linker 的 job。
- D. ❌ Section merging 是 linker 会做的事；正确表述：它合并同类 sections 并布局输出文件。
- E. ❌ Relocation 是 linker 核心工作；正确表述：它 patch 地址引用。

### Q4. If you want to enable cross-module procedure inlining optimization, which of the following flags are required?

A. -O
B. -O5
C. -O3 -flto
D. -O3 -ffast

**Answer:** 3 = C — -O3 -flto

> 位于(2. Compiler Flag Reference, 5_review.md), 解释是因为 `-flto` 是 link-time/whole-program optimization，可让跨模块 inlining 成立；class note 中 `-O4` 等价于 `-O3 -flto`，选项里对应 `-O3 -flto`。

**选项解析：**

- A. ❌ `-O` 只打开普通优化，不提供跨模块 LTO；正确表述：需要 `-flto`。
- B. ❌ `-O5` 不是 GCC/Clang 标准优化级别；正确表述：课堂对应的是 `-O3 -flto`。
- C. ✅ 对。`-O3` 开高优化，`-flto` 让链接期看到跨模块信息，从而做 procedure inlining。
- D. ❌ `-ffast` 不是标准完整选项，且 fast-math 类选项不提供跨模块内联；正确表述：关键是 LTO。

### Q5. Which of the following optimizations have no primary attempt to improve locality?

A. Loop unrolling
B. Loop interchange
C. Loop fusion
D. Loop tiling

**Answer:** 1 = A — Loop unrolling

> 位于(6.1 Loop Unrolling, 5_review.md), 解释是因为 review 明确写出 loop unrolling 不是 locality optimization，它主要减少 branch/index overhead 并暴露 ILP/SIMD；loop interchange、fusion、tiling 才是 locality opts。

**选项解析：**

- A. ✅ 对。Loop unrolling 主要减少循环控制开销、暴露 ILP/SIMD，不是主要为了 locality。
- B. ❌ Loop interchange 可改变访问顺序以匹配 row-major/column-major，提高 locality。
- C. ❌ Loop fusion 合并循环，能复用刚访问的数据，提升 temporal locality。
- D. ❌ Loop tiling/blocking 把工作集限制在 cache 中，是典型 locality optimization。

### Q6. Which of the following compiler optimizations may lead to 1000x speedup?

A. Procedure inlining
B. Cascading DCE
C. Loop unrolling
D. Register allocation
E. Code scheduling

**Answer:** 2 = B — Cascading DCE

> 位于(Exam Facts; 4.2 Constant Fold / DCE / CSE / LICM / Strength, 5_review.md), 解释是因为 cascading DCE 可以由一个常量消除 branch、calls、loop 等整串代码，review 明确说可能带来 1000x speedup。

**选项解析：**

- A. ❌ Procedure inlining 可减少 call overhead 并暴露优化，但通常不是 review 中 1000x 的例子。
- B. ✅ 对。Cascading DCE 可能触发整段不可达/无用代码连锁删除，极端情况下有 1000x speedup。
- C. ❌ Loop unrolling 通常是常数倍改善，不是 1000x 来源。
- D. ❌ Register allocation 减少 memory traffic，但通常不是数量级 1000x。
- E. ❌ Code scheduling 减少 stalls，收益有限；正确表述：不是这题的极端优化。

### Q7. Which of the following compiler optimizations have been discussed in class?

A. Multi-threading on multi-cores
B. SIMT using CUDA
C. Vectorization using a compiler auto-vectorization
D. Loop transformations to improve data locality

**Answer:** 4 = D — Loop transformations to improve data locality

> 位于(Exam Facts; 10. Data Structure & Layout Fixes, 5_review.md), 解释是因为 review 讨论的 locality 改善主要是 loop interchange、fusion、tiling 等 loop transformations；multithreading、CUDA SIMT、compiler auto-vectorization 不是这里列出的课堂重点答案。

**选项解析：**

- A. ❌ Multi-threading on multi-cores 属于并行编程/体系结构主题，不是这题所指 compiler locality optimization。
- B. ❌ CUDA SIMT 是 GPU 编程模型，不是本题课堂讨论的编译器优化答案。
- C. ❌ Auto-vectorization 可能由编译器做，但该题 key 指向 locality loop transformations；正确表述：不是这里的答案。
- D. ✅ 对。课堂讨论了 loop interchange/fusion/tiling 等改善 data locality 的 loop transformations。

### Q8. To build executables for embedded systems where the memory size is severely limited, which optimization flags should be used?

A. -O0
B. -Os
C. -O3 -flto
D. -O3

**Answer:** 2 = B — -Os

> 位于(2. Compiler Flag Reference, 5_review.md), 解释是因为 `-Os` 的含义是 optimize for size，review 明确标注适合 embedded / size-constrained 场景。

**选项解析：**

- A. ❌ `-O0` 关闭优化，代码通常更大更慢；正确表述：不适合严苛内存限制。
- B. ✅ 对。`-Os` 明确 optimize for size，适合 embedded/size-constrained build。
- C. ❌ `-O3 -flto` 偏性能和跨模块优化，可能增大代码；正确表述：不是首选 size flag。
- D. ❌ `-O3` 偏速度，可能通过 unrolling/inlining 增大 code size。

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

**选项解析：**

- A. ✅ 对。Linking 支持模块化开发，不同源文件/对象可独立组织。
- B. ✅ 对。Separate compilation 让改一个模块时只需重编相关部分，再重新链接。
- C. ✅ 对。Libraries 让代码复用成为可能。
- D. ✅ 对。模块边界和库复用让维护更容易。
- E. ❌ Linking 本身增加了符号解析/重定位等步骤；正确表述：它带来模块化等好处，不是让 executable 构建更简单。

### Q10. What can a linker do?

A. Can enable Link Time Optimization
B. Can resolve symbol definition/reference
C. Can tune a program’s performance via page sizes and alignments
D. Can relocate global variable references and function calls

**Answer:** 1,2,3,4 = A — Can enable Link Time Optimization; B — Can resolve symbol definition/reference; C — Can tune a program’s performance via page sizes and alignments; D — Can relocate global variable references and function calls

> 位于(Exam Facts, 7_review.md), 解释是因为 linker jobs 包括 LTO、symbol resolution、relocation，并且可通过 page alignment、function/code layout 等影响性能；四个选项都是 linker 可做的事。

**选项解析：**

- A. ✅ 对。Linker 可启用/承载 Link Time Optimization。
- B. ✅ 对。Symbol definition/reference resolution 是 linker 核心任务。
- C. ✅ 对。Linker 可通过 page size、alignment、code/function layout 等影响性能。
- D. ✅ 对。Relocation 会修正 global variable references 和 function calls 的地址。

### Q11. What are the three different object files?

A. Relocatable object file
B. Static object file
C. Executable object file
D. Shared object file
E. Dynamic object file

**Answer:** 1,3,4 = A — Relocatable object file; C — Executable object file; D — Shared object file

> 位于(Exam Facts; 3. ELF Object Format, 7_review.md), 解释是因为 object file 的三类是 relocatable `.o`、executable、shared object `.so`；`.a` 是 archive library，不是第四类 object file。

**选项解析：**

- A. ✅ 对。Relocatable object file 是 `.o`，可继续链接。
- B. ❌ Static object file 不是 ELF object file 三大类的标准名称；正确表述：static library `.a` 是 archive。
- C. ✅ 对。Executable object file 是可执行 ELF。
- D. ✅ 对。Shared object file `.so` 是动态链接共享对象。
- E. ❌ Dynamic object file 不是三类之一；正确表述：动态链接常用 shared object。

### Q12. What are the data structures to support dynamic linking?

A. GOT (Global Offset Table)
B. JT (Jump Table)
C. PLT (Procedure Linkage Table)
D. SHT (Section Header Table)

**Answer:** 1,3 = A — GOT (Global Offset Table); C — PLT (Procedure Linkage Table)

> 位于(Exam Facts; 9. PIC, GOT, PLT, 7_review.md), 解释是因为 dynamic linking 依赖 GOT 保存运行时地址、PLT 作为外部函数调用 stub；JT 和 SHT 不是 dynamic linking 的核心数据结构。

**选项解析：**

- A. ✅ 对。GOT 保存全局对象/函数的运行时地址，是 PIC/dynamic linking 关键结构。
- B. ❌ JT/jump table 常用于 switch 等间接跳转，不是 dynamic linking 核心表。
- C. ✅ 对。PLT 提供外部函数调用 stub，并配合 GOT 做 lazy binding。
- D. ❌ SHT 是 ELF section header table，用于描述 sections，不是支持动态链接调用/寻址的核心结构。

### Q13. What are the major advantages of dynamic linking?

A. Faster execution
B. Significant Memory (RAM) Savings
C. Centralized Security Updates and Bug Fixes
D. Fast build time linking

**Answer:** 2,3,4 = B — Significant Memory (RAM) Savings; C — Centralized Security Updates and Bug Fixes; D — Fast build time linking

> 位于(Exam Facts; 8. Shared Libraries / Dynamic Linking, 7_review.md), 解释是因为 shared libraries 的优势是 RAM memory savings、集中安全/bug-fix 更新和快速 build-time linking；由于 PLT/GOT 间接跳转，它不是为了更快执行。

**选项解析：**

- A. ❌ Dynamic linking 通常有 PLT/GOT 间接和运行时绑定开销；正确表述：不是为了 faster execution。
- B. ✅ 对。多个进程可共享同一份 library text pages，节省 RAM。
- C. ✅ 对。更新共享库可集中修复安全漏洞和 bug。
- D. ✅ 对。构建时不必把库代码全部拷入 executable，link time 更快/输出更小。

### Q14. Where do we keep the PLT, GOT and GOT.plt?

A. PLT is in the .text section
B. GOT is in the .data section
C. GOT.plt is in the .data section
D. GOT is in the .text section

**Answer:** 1,2,3 = A — PLT is in the .text section; B — GOT is in the .data section; C — GOT.plt is in the .data section

> 位于(Exam Facts; 9. PIC, GOT, PLT, 7_review.md), 解释是因为 PLT 是可执行 stub，位于 `.text`/`.plt`；GOT 和 `.got.plt` 是可写地址表，位于 `.data`-like writable region。

**选项解析：**

- A. ✅ 对。PLT 包含可执行跳转 stub，放在 `.text`/`.plt` 这类代码区域。
- B. ✅ 对。GOT 是运行时地址表，位于 writable data-like section。
- C. ✅ 对。`.got.plt` 也属于可写 GOT 相关区域。
- D. ❌ GOT 不是代码 stub，不放在 `.text`；正确表述：GOT 在 data-like writable region。

### Q15. What are the symbols in the .symtab section?

A. Global variables
B. Local variables
C. External functions
D. Static local symbols

**Answer:** 1,3,4 = A — Global variables; C — External functions; D — Static local symbols

> 位于(Exam Facts; 2. Linker Symbols, 7_review.md), 解释是因为 `.symtab` 包含 global variables、external function references 和 static linker symbols；auto local variables、parameters、temporary registers 不属于 linker symbols。

**选项解析：**

- A. ✅ 对。Global variables 需要被 linker 解析/重定位，属于 `.symtab` 可见符号。
- B. ❌ 普通 automatic local variables 在栈上，由编译器管理，不是 linker symbols。
- C. ✅ 对。External functions 的引用/定义需要符号解析，出现在 symbol table 相关信息中。
- D. ✅ 对。`static` local/file-scope symbols 虽有局部链接可见性，仍可作为 linker/static symbols 出现在 `.symtab`。

### Q16. Which of the following symbol resolution rules is incorrect?

A. Two weak symbols are not allowed
B. Two strong symbols are not allowed
C. One strong symbol and multiple weak symbol are allowed
D. Two weak symbols with different data types are allowed

**Answer:** 1 = A — Two weak symbols are not allowed

> 位于(Exam Facts; 4. Duplicate Symbol Resolution, 7_review.md), 解释是因为 duplicate symbol rules 中 two strong 是错误，strong + weak 由 strong 胜出，multiple weak 在 legacy common model 中允许且由 linker 任意选择；所以“two weak symbols are not allowed”是错误规则。

**选项解析：**

- A. ✅ 对。本题问 incorrect rule；two weak symbols 在规则中可以允许/由 linker 选择，所以“not allowed”是错误表述。
- B. ❌ Two strong symbols are not allowed 是正确规则，因此不是 incorrect。
- C. ❌ One strong + multiple weak allowed，且 strong wins；这是正确规则。
- D. ❌ Two weak symbols with different data types 在 legacy common 情况下可能被允许但危险；按 review 不是本题错误规则。

### Q17. Which of the following descriptions are incorrect?

A. .so is for a shared object file
B. .a is for an archived library
C. .o is for relocatable object file
D. .a is a collection of .o files with an index

**Answer:** NONE

> 位于(3. ELF Object Format, 7_review.md), 解释是因为 review 的 trick quiz 说明 `.so` 是 shared object，`.a` 是带 index 的 `.o` 集合，`.o` 是 relocatable object file；这些描述都正确，所以没有 incorrect description。

**选项解析：**

- A. ❌ 本题问 incorrect；`.so` 确实是 shared object file，因此它不是错误描述。
- B. ❌ `.a` 确实是 archived/static library，因此不是错误描述。
- C. ❌ `.o` 确实是 relocatable object file，因此不是错误描述。
- D. ❌ `.a` 确实是带索引的 `.o` 文件集合，因此不是错误描述。

### Q18. How do we know which instructions and which data references require relocation?

A. The compiler or assembler leaves that information in the
   .rel.text and .rel.data sections.
B. The linker leaves the information in the .rel.text and .rel.data sections.
C. The loader leaves the information in the .rel.text and .rel.data sections.
D. The dynamic linker leaves the information in GOT and PLT

**Answer:** 1 = A — The compiler or assembler leaves that information in the .rel.text and .rel.data sections.

> 位于(5. Relocation, 7_review.md), 解释是因为最终地址在编译/汇编时未知，所以 compiler/assembler 会在 `.rel.text` 和 `.rel.data` 中留下 relocation entries，供 linker 后续 patch。

**选项解析：**

- A. ✅ 对。Compiler/assembler 生成 relocation entries，记录哪些 instruction/data references 后续要修正。
- B. ❌ Linker 消费这些 relocation entries 并执行 relocation；正确表述：不是 linker 先留下给自己。
- C. ❌ Loader 处理装载/动态重定位，不是生成 `.rel.text/.rel.data` 的主要阶段。
- D. ❌ GOT/PLT 支持动态链接调用/寻址，但不等同于“哪些引用需要 relocation”的原始记录。

### Q19. Which of the following procedures are good candidates for inlining?

A. Small procedures
B. Procedures with multiple constant arguments
C. Recursive procedures
D. Procedures with many call sites
E. Procedures that are called only once in a loop

**Answer:** 1,2,5 = A — Small procedures; B — Procedures with multiple constant arguments; E — Procedures that are called only once in a loop

> 位于(4.3 Inlining, 5_review.md), 解释是因为 small procedures、constant arguments、inside loop/called once 都是 good candidates；recursive、deep call graph、many call sites 会导致不适合或 code bloat。

**选项解析：**

- A. ✅ 对。Small procedures 内联后 code growth 小，还能消除 call overhead。
- B. ✅ 对。Constant arguments 可在内联后触发 constant propagation、DCE 等后续优化。
- C. ❌ Recursive procedures 内联可能无限展开或收益差；正确表述：通常不是好候选。
- D. ❌ Many call sites 会造成 code bloat；正确表述：调用点太多时要谨慎。
- E. ✅ 对。在 loop 中只调用一次的小/合适函数，内联可消除循环内 call overhead 并暴露优化。

### Q20. Two parameters *a and *b are used frequently, and they are not pointing to the same object. The compiler did not allocate them to registers. What can you do?

A. Turn on –O3
B. Change from gcc to clang
C. Use restricted pointers
D. Allocate *a and *b to local variables manually

**Answer:** 3,4 = C — Use restricted pointers; D — Allocate *a and *b to local variables manually

> 位于(5. Memory Aliasing, 5_review.md), 解释是因为当 `*a` 和 `*b` 实际不 alias 但编译器无法证明时，应使用 `restrict` 或手动 local copy 让值进入寄存器；review 明确说不要只靠换 compiler 或开 `-O3`。

**选项解析：**

- A. ❌ 单纯打开 `-O3` 不能突破编译器对 pointer aliasing 的保守假设；正确表述：要提供 no-alias 信息。
- B. ❌ 换 clang 也不保证能证明 `a` 和 `b` 不 alias；正确表述：问题在语义信息不足。
- C. ✅ 对。`restrict` 告诉编译器这些指针不指向同一对象，可放心放寄存器/重排。
- D. ✅ 对。手动把 `*a`、`*b` 拷到 local variables 可减少重复内存访问，帮助寄存器分配。

### Q21. For the expressions (a+b+c+d) and (a+d+b+c), we may consider them as a CSE (Common Sub-Expression) if the data type is

A. Long long
B. Float
C. Double
D. char

**Answer:** 1,4 = A — Long long; D — char

> 位于(4.2 Constant Fold / DCE / CSE / LICM / Strength, 5_review.md), 解释是因为 integer-like 类型的加法可按模运算重关联，`long long` 和 promoted `char` 可做 CSE；`float`/`double` 因 FP non-associativity 不能安全认为两式等价。

**选项解析：**

- A. ✅ 对。`long long` 是整数类型，编译器可在相同语义约束下把重排加法视作等价。
- B. ❌ `float` 加法不满足严格结合律，舍入可能让 `(a+b+c+d)` 与 `(a+d+b+c)` 不同。
- C. ❌ `double` 同样受 floating-point rounding/non-associativity 影响，不能默认 CSE。
- D. ✅ 对。`char` 表达式通常提升为整数运算，属于 integer-like 情况，可安全做这类 CSE。
