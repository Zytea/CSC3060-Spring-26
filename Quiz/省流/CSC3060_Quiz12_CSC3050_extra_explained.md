# Extra Quizzes Converted and Explained

说明：本文件为人工核对版。`位于(...)` 只引用 `*_review.md`；若题目必须依赖原 DOCX/PPTX 的代码块、图或 key，我会在说明中单独标出，无法由 review 直接支撑的部分不会伪装成 review 内容。

## CSC3060 Quiz2-2026.key.docx

### Q1. Branch prediction should be performed at which pipeline stage?

A. IF  
B. ID  
C. EXE  
D. MEM  
E. WB

**Answer:** A — IF

> 位于(notes quiz 2/4_4_review.md), 解释：control hazard 的 penalty 要靠尽早给出 next PC；BHT/BTB 在 IF 阶段配合取指。

**选项解析：**

- A. ✅ IF 对。预测必须在取指时决定下一条 PC，否则下一周期取不到正确路径。
- B. ❌ ID 太晚。到 decode 才预测，IF 已经错过一次取指机会；正确表述：branch prediction 放在 IF。
- C. ❌ EXE 更晚。EXE 可解析分支条件/目标，但不是预测阶段；正确表述：EXE 用于验证/纠错。
- D. ❌ MEM 太晚。若到 MEM 才 redirect，会产生更多 bubbles；正确表述：MEM 不是预测位置。
- E. ❌ WB 最晚。WB 只写回结果，与预测 next PC 无关；正确表述：预测要早于流水线后段。

### Q2. Which branch/jump instruction generated from C statements is most difficult to predict?

A. if  
B. for  
C. switch  
D. while  
E. function call

**Answer:** C — switch

> 位于(notes quiz 2/4_4_review.md; 5_review.md), 解释：普通条件分支/循环可由方向历史学习；dense switch 常生成 jump table/indirect branch，目标更依赖数据。

**选项解析：**

- A. ❌ `if` 通常是直接条件分支，BHT 可以学习 taken/not-taken 模式；正确表述：普通 if 比间接 switch 容易预测。
- B. ❌ `for` 循环多为 backward branch，静态 backward-taken 和动态预测都有效；正确表述：loop branch 往往规律强。
- C. ✅ `switch` 对。它常被编译为 jump table，通过寄存器间接跳转，目标数量多且取决于 case 值。
- D. ❌ `while` 与 for 类似，多数是一个条件分支反复执行；正确表述：循环分支通常有可学习历史。
- E. ❌ 直接 function call 的目标通常固定，return 还有 RAS；正确表述：更难的是 indirect branch/jump table。

### Q3. Which microarchitecture may have CPI lower than 1?

A. Superscalar implementation  
B. Single-cycle datapath  
C. Multi-cycle datapath  
D. Pipelined implementation

**Answer:** A — Superscalar implementation

> 位于(notes quiz 2/4_1_review.md), 解释：CPI < 1 需要一个 cycle 完成/提交多条指令；普通 single-issue pipeline 理想 CPI 约为 1。

**选项解析：**

- A. ✅ Superscalar 对。多发射/多提交可以让平均每条指令少于一个 cycle。
- B. ❌ Single-cycle 每条指令一个长 cycle，CPI 固定约 1；正确表述：它不能 CPI<1。
- C. ❌ Multi-cycle 一条指令分多个 cycle，CPI 通常大于 1；正确表述：它缩短 clock，不降低到 CPI<1。
- D. ❌ 普通 pipeline 提高 throughput，但 single issue 理想 CPI 仍约 1；正确表述：要 CPI<1 需 superscalar。

### Q4. In the RISC-V calling convention, which register is callee-saved?

A. x0  
B. ra  
C. t1  
D. s1  
E. a1

**Answer:** D — s1

> 位于(notes quiz 1/4_review.md), 解释：RISC-V ABI 中 `s0-s11` 为 callee-saved；`ra/t/a` 为 caller-saved，`x0` 恒为 0。

**选项解析：**

- A. ❌ `x0` 不能保存状态，它硬连线为 0；正确表述：callee-saved 是 `s` registers。
- B. ❌ `ra` 是 return address，调用者/调用序列负责保护；正确表述：`ra` 不属于 `s0-s11`。
- C. ❌ `t1` 是 temporary，caller-saved；正确表述：callee 可以覆盖 `t` registers。
- D. ✅ `s1` 对。callee 若修改 `s1`，必须在返回前恢复。
- E. ❌ `a1` 是参数寄存器，也是 caller-saved；正确表述：参数寄存器不能假定跨调用保持。

### Q5. Which implementation has the highest instruction execution throughput?

A. Single-cycle datapath  
B. Multi-cycle datapath  
C. Pipelined datapath  
D. Superscalar and pipelined datapath

**Answer:** D — Superscalar and pipelined datapath

> 位于(notes quiz 2/4_1_review.md; notes quiz 2/4_3_review.md), 解释：pipeline 重叠执行提升吞吐；superscalar 进一步允许每 cycle 多条指令。

**选项解析：**

- A. ❌ Single-cycle 不重叠执行，且 clock 由最慢指令决定；正确表述：吞吐最低。
- B. ❌ Multi-cycle 可复用硬件但一条指令多 cycle；正确表述：吞吐低于 pipeline。
- C. ❌ Pipelined 已能接近每 cycle 一条，但不是最高；正确表述：single-issue pipeline 理想吞吐约 1 instr/cycle。
- D. ✅ 对。pipelining + superscalar 同时利用重叠执行和多发射，吞吐最高。

### Q6. ARM Cortex-A57 has 16 stages, 20% branches, CPI=1, no prediction. What branch performance penalty?

A. 90%  
B. 75%  
C. 50%  
D. 20%

**Answer:** B — 75%

> 位于(notes quiz 2/4_4_review.md), 解释：branch penalty 进入 CPI 后要用 added cycles / total cycles 计算。

**选项解析：**

- A. ❌ 90% 过高。每条指令平均增加 `0.2 * 15 = 3` cycles，不是 90%；正确表述：stall fraction = `3/(1+3)`。
- B. ✅ 75% 对。总 CPI = `1 + 0.2*15 = 4`，其中 branch stall 占 `3/4 = 75%`。
- C. ❌ 50% 少算了 stall 占比；正确表述：branch stall cycles 是 base CPI 的 3 倍。
- D. ❌ 20% 只是 branch instruction 频率，不是性能损失比例；正确表述：每个 branch 还带 15-cycle penalty。

### Q7. Why use a comparison unit for compare-and-branch instead of the standard ALU?

A. To avoid structural hazards  
B. To avoid wrong branch condition due to subtraction overflow  
C. Because comparison does not trap  
D. ALU is reserved to compute PC+immediate

**Answer:** B — To avoid wrong branch condition due to subtraction overflow

> 位于(notes quiz 2/4_1_review.md; notes quiz 2/4_4_review.md), 解释：用 `A-B` 的符号判断大小会被 overflow 破坏；branch comparator 可直接给出 BrEq/BrLT。

**选项解析：**

- A. ❌ structural hazard 不是主要原因；正确表述：关键是比较逻辑不能被 subtract overflow 误导。
- B. ✅ 对。signed compare 若靠减法结果符号位，overflow 时 taken/not-taken 可能错。
- C. ❌ “comparison does not trap”不是本题考点；正确表述：RISC-V integer overflow 不 trap，但比较正确性仍需保证。
- D. ❌ ALU 是否算 PC+imm 不是该题主要解释；正确表述：分支比较单元用于可靠地产生比较结果。

### Q8. Which control signal is most difficult to generate?

A. ALUsrc  
B. PCsrc  
C. Wren  
D. ALUctr  
E. MemRd

**Answer:** D — ALUctr

> 位于(notes quiz 2/4_2_review.md), 解释：ALU control 需要综合 opcode、funct3、funct7 和指令类别；其他多为简单 mux/enable 控制。

**选项解析：**

- A. ❌ ALUsrc 通常由指令类型决定，选择寄存器或 immediate；正确表述：复杂的是 ALUctr。
- B. ❌ PCsrc 主要由 branch/jump 判定选择 next PC；正确表述：它不是最复杂 decoder。
- C. ❌ Wren 是写回使能，很多指令可直接由 opcode 判定；正确表述：控制复杂度低于 ALUctr。
- D. ✅ 对。ALUctr 要区分 add/sub/and/or/shift/compare 等具体运算。
- E. ❌ MemRd 只表示是否读内存，load 类指令触发；正确表述：不是最复杂控制信号。

### Q9. Which pipeline register stores the least information?

A. IF/ID  
B. ID/EX  
C. EX/MEM  
D. MEM/WB

**Answer:** D — MEM/WB

> 位于(notes quiz 2/4_3_review.md), 解释：`MEM/WB` 只需携带 mem-data、ALU result、PC+4、rd 和 WB control；`ID/EX`、`EX/MEM` 字段更多。

**选项解析：**

- A. ❌ IF/ID 至少要携带 instruction 和 PC/PC+4；正确表述：不是字段最少的最终寄存器。
- B. ❌ ID/EX 要带寄存器读数、immediate、rd/rs、EX/MEM/WB 控制；正确表述：字段很多。
- C. ❌ EX/MEM 要带 ALU result、store data、branch info、rd、MEM/WB 控制；正确表述：多于 MEM/WB。
- D. ✅ 对。MEM/WB 只服务写回选择和写回目标，review 明确标为 fewest。

### Q10. Which DRAM is used in Nvidia high-end GPU global memory?

A. Traditional DRAM  
B. HBM  
C. SDRAM  
D. RDRAM  
E. DDR5 DRAM

**Answer:** B — HBM

> 位于(notes quiz 2/6_review.md), 解释：GPU 需要极高 memory bandwidth，课程 memory hierarchy review 将高端 GPU global memory 与 HBM 关联。

**选项解析：**

- A. ❌ Traditional DRAM 带宽不足以描述高端 GPU 方案；正确表述：高端 GPU 使用 HBM。
- B. ✅ 对。HBM 通过堆叠和宽接口提供高带宽。
- C. ❌ SDRAM 是泛称/旧式同步 DRAM，不是此题指定答案；正确表述：HBM。
- D. ❌ RDRAM 不是现代高端 Nvidia GPU global memory 的主流；正确表述：HBM。
- E. ❌ DDR5 常用于 CPU 主存/显存语境不同；正确表述：高端 GPU 重点是 HBM。

### Q11. How do we index a BHT in correlated/2-level adaptive branch prediction?

A. Current PC XOR global history shift register  
B. PC address only  
C. PC + global history  
D. Current PC XOR branch address

**Answer:** A — Current PC XOR global history shift register

> 位于(notes quiz 2/4_4_review.md), 解释：correlated predictor 用当前 PC 与 global history 共同索引，review 写作 PC xor GHR。

**选项解析：**

- A. ✅ 对。PC 给出分支身份，global history 给出相关历史，XOR 用于混合索引。
- B. ❌ PC-only 是简单 per-branch predictor，不是 correlated/two-level；正确表述：还要结合 global history。
- C. ❌ 课程写的是 XOR，不是算术加法；正确表述：PC ⊕ GHR。
- D. ❌ branch address 与 current PC 对同一分支没有提供全局相关历史；正确表述：用 PC 和 global history。

### Q12. Which dependency type is true dependence in code scheduling?

A. WAW  
B. RAW  
C. WAR  
D. RAR

**Answer:** B — RAW

> 位于(notes quiz 2/4_5_review.md; notes quiz 2/4_4_review.md), 解释：RAW 是 producer 写、consumer 读同一值，是真数据依赖；WAR/WAW 是 name/order dependence，可由 renaming 处理。

**选项解析：**

- A. ❌ WAW 是两次写同一名字的输出依赖，不传递数据值；正确表述：可通过重命名消除。
- B. ✅ RAW 对。后一条读前一条写出的值，必须保持顺序或等待/转发。
- C. ❌ WAR 是后一条写会覆盖前一条还没读的名字，属于反依赖；正确表述：不是真依赖。
- D. ❌ RAR 两条都读，不产生顺序约束；正确表述：没有 producer-consumer 数据流。

### Q13. In Project #2, which GDB command prints only register a0 in decimal?

A. print a0  
B. info registers  
C. x/d a0  
D. print/x a0

**Answer:** A — print a0

> 位于(notes quiz 1/3_review.md), 解释：review 的 GDB 表写 `info registers` 打印全部寄存器；严格 GDB 寄存器语法应写 `$a0`，即 `print $a0`/`p $a0`。

**选项解析：**

- A. ✅ 按 key 选 A；但严格写法应为 `print $a0`。这项最接近“只打印 a0 且默认 decimal”。
- B. ❌ `info registers` 会列出所有寄存器，不是 only a0；正确表述：打印单个寄存器用 `print $a0`。
- C. ❌ `x/d` 是 examine memory，会把表达式当地址看内存；正确表述：寄存器值不是这样打印。
- D. ❌ `/x` 指定十六进制，不符合 decimal；正确表述：decimal 不加 `/x`。

### Q14. Regarding Project #2 Bomb Lab, which statement is correct?

A. Only brute-force guessing solves it  
B. The bomb runs on any RISC-V platform  
C. Determine correct inputs for each phase without explosion  
D. a0/a1 stay unchanged throughout function lifetime

**Answer:** C — Determine correct inputs for each phase without explosion

> 位于(notes quiz 1/3_review.md; notes quiz 1/4_review.md), 解释：Bomb Lab 依赖反汇编/调试理解程序；`a0/a1` 属于 caller-saved，不能假设整个函数生命期不变。

**选项解析：**

- A. ❌ 不是 brute force。正确表述：通过分析汇编、寄存器和控制流推出输入。
- B. ❌ 二进制依赖 ABI/OS/运行环境，不是任意 RISC-V 平台直接可跑；正确表述：应在指定环境中调试。
- C. ✅ 对。Bomb Lab 的目标就是找出每个 phase 的合法输入。
- D. ❌ `a0/a1` 是参数/返回寄存器且 caller-saved，可被调用覆盖；正确表述：需长期保留就放 `s` register 或栈。

### Q15. RISC-V would be fixed-length ISA if it did not have which extension?

A. A extension  
B. B extension  
C. C extension  
D. D extension  
E. F extension

**Answer:** C — C extension

> 位于(notes quiz 1/3_review.md), 解释：base RISC-V 大多 fixed 32-bit；`C` extension 引入 16-bit compressed instructions。

**选项解析：**

- A. ❌ A 是 atomic extension，不改变基本指令长度；正确表述：混合长度来自 C。
- B. ❌ B 是 bit-manipulation 相关扩展，不是 compressed 指令；正确表述：固定长度被 C 打破。
- C. ✅ 对。没有 C extension 时，base instruction length 固定为 32-bit。
- D. ❌ D 是 double-precision floating-point extension；正确表述：它不引入 16-bit 指令。
- E. ❌ F 是 single-precision floating-point extension；正确表述：不是指令压缩扩展。

### QII-1. Which codes are latency-bound rather than bandwidth-bound?

A. Single account-balance query  
B. Large matrix multiplication  
C. Chasing a linked list to locate the end  
D. Traversing a binary tree to find a data item

**Answer:** A, C, D

> 位于(5_review.md; notes quiz 2/6_review.md), 解释：latency-bound 包括单次查询、linked-list/tree pointer chasing；large matmul 更偏 bandwidth/throughput/locality。

**选项解析：**

- A. ✅ 对。单个账户查询常是少量依赖访问，不能靠大批量带宽摊平 latency。
- B. ❌ 大矩阵乘法有规则数据访问和大量运算，可用 blocking/SIMD 提升带宽与吞吐；正确表述：它不是典型 pointer-chasing latency-bound。
- C. ✅ 对。链表每步地址依赖上一步 load 的结果，是典型 memory latency chain。
- D. ✅ 对。二叉树搜索每层走向由当前节点决定，也形成 pointer load 和 branch 依赖。

### QII-2. When should caller-saved registers be considered for allocation?

A. Leaf routines  
B. A temporary value used across multiple calls  
C. Temporaries in expression evaluation  
D. Array variables  
E. Local scalar variables

**Answer:** A, C

> 位于(notes quiz 1/4_review.md), 解释：caller-saved 适合 leaf routine、短命 expression temps；跨多次调用的值更适合 callee-saved。

**选项解析：**

- A. ✅ 对。leaf routine 不调用别人，使用 `a/t` caller-saved 通常无需保存恢复。
- B. ❌ 跨多个 call 的值若放 caller-saved，调用者每次都要 save/restore；正确表述：更适合 callee-saved。
- C. ✅ 对。表达式临时值生命期短，适合 `t` registers。
- D. ❌ 数组通常需要内存布局和地址计算，不能整体分配到少数寄存器；正确表述：寄存器分配主要针对标量。
- E. ❌ long-lived local scalar 若跨调用存活，callee-saved 往往更合适；正确表述：是否 caller-saved 取决于 live range。

### QII-3. What hazards might commonly occur when performing binary tree search on a pipelined datapath?

A. Structure hazards  
B. Data hazards  
C. Control hazards

**Answer:** B, C

> 位于(notes quiz 2/4_4_review.md), 解释：binary-tree search 有 pointer load-use data hazard，也有比较后决定左右子树的 control hazard。

**选项解析：**

- A. ❌ 主要不是硬件资源争用；正确表述：树搜索问题来自依赖 load 和分支。
- B. ✅ 对。下一节点地址依赖当前节点 load 出来的 pointer。
- C. ✅ 对。每次比较 key 后选择 left/right branch，产生 control hazard。

### QII-4. In the RV32I datapath, what are possible next-instruction address selections?

A. PC  
B. PC + 4  
C. PC + immediate  
D. RS1 + immediate  
E. (RS1 + immediate) via memory indirection

**Answer:** B, C, D

> 位于(notes quiz 1/3_review.md; notes quiz 2/4_2_review.md), 解释：顺序执行为 PC+4，branch/JAL 为 PC+imm，JALR 为 rs1+imm；没有通过内存再取 next PC 的间接层。

**选项解析：**

- A. ❌ 当前 PC 本身不是下一条地址；正确表述：顺序 next PC 是 PC+4。
- B. ✅ 对。普通顺序执行取下一条指令。
- C. ✅ 对。branch/JAL 使用 PC-relative immediate。
- D. ✅ 对。JALR 使用 `rs1 + imm` 形成目标。
- E. ❌ JALR 不从内存读取目标地址；正确表述：目标直接来自寄存器加 immediate。

### QII-5. Why do modern microprocessors have split I/D caches?

A. Avoid structural hazards in the pipeline  
B. Get higher overall cache hit rate  
C. Increase processor reliability  
D. Increase cache access bandwidth

**Answer:** A, D

> 位于(notes quiz 2/4_4_review.md; notes quiz 2/6_review.md), 解释：split L1I/L1D 避免 IF 与 MEM 同周期争用统一 cache，并提高 instruction/data 并行访问带宽。

**选项解析：**

- A. ✅ 对。取指和 load/store 可同时访问不同 cache，减少 structural hazard。
- B. ❌ split 的主因不是 overall hit rate；正确表述：主要是 bandwidth 和结构冲突。
- C. ❌ 可靠性不是 L1 split 的课程理由；正确表述：I/D 可分开策略和端口。
- D. ✅ 对。I-cache 与 D-cache 可并行服务请求，总访问带宽更高。

### QII-6. When might a longer/deeper pipeline be less desirable?

A. Frequent branch mispredictions  
B. Intensive data dependencies  
C. Frequent memory operations  
D. Lots of instruction cache misses  
E. Frequent procedure calls

**Answer:** A, B, D

> 位于(notes quiz 2/4_3_review.md; notes quiz 2/4_4_review.md), 解释：更深 pipeline 会放大 control/data hazard penalty；I-cache miss 会让取指端停顿更明显。

**选项解析：**

- A. ✅ 对。分支错预测要 flush 更多阶段，penalty 更大。
- B. ✅ 对。数据依赖链让更多阶段无法被独立指令填满，stall 更贵。
- C. ❌ “memory operations”本身不一定坏，关键是 miss 或 load-use dependence；正确表述：频繁 miss 才是问题。
- D. ✅ 对。I-cache miss 会阻塞取指，深 pipeline 更难保持满载。
- E. ❌ procedure call 可被 call/return predictor 和 ABI 优化处理，不必然是深 pipeline 主要劣势；正确表述：主要看 misprediction 和依赖。

### QII-7. Which schedules are valid for the dependency graph on the right?

Graph edges from the original question image: `I0→I1`, `I1→I4`, `I1→I7`, `I2→I4`, `I3→I7`, `I5→I8`, and `I4/I6/I7/I8/I9→I10`.

A. `0 1 2 5 3 9 4 7 6 8 10`  
B. `0 2 1 5 3 8 4 7 9 6 10`  
C. `0 2 4 1 3 7 9 6 5 8 10`  
D. `0 1 2 3 5 4 7 8 6 9 10`  
E. `0 1 2 3 4 5 6 7 8 9 10`

**Answer:** A, B, D, E

> 位于(notes quiz 2/4_5_review.md), 解释：合法 schedule 必须是 dependence DAG 的 topological order，不能把 consumer 排在 producer 前。

**选项解析：**

- A. ✅ 对。所有边的 source 都在 destination 前，例如 `I1` 在 `I4/I7` 前，所有 `I10` 前驱也都在 `I10` 前。
- B. ✅ 对。`I2` 可早于 `I1`，只要 `I1` 仍早于 `I4/I7`；`I5` 也早于 `I8`，合法。
- C. ❌ 错。`I4` 出现在 `I1` 前，违反 `I1→I4`；正确表述：`I1` 必须先于 `I4`。
- D. ✅ 对。该顺序满足所有 producer-before-consumer 约束。
- E. ✅ 对。原编号顺序本身满足图中所有依赖。

### QII-8. Which techniques reduce the penalty caused by control hazards?

A. Pipeline stalls  
B. BTB  
C. Untagged BHT  
D. Always predict backward branches taken  
E. Data forwarding

**Answer:** B, C, D

> 位于(notes quiz 2/4_4_review.md), 解释：BTB 预测目标，BHT 预测方向，backward-taken 是静态分支预测规则；data forwarding 属于 data hazard。

> 注意：原 key 写 “B,C,D or B,C”。按 “reduce penalty” 语义，D 也属于有效静态预测，因此保留 B/C/D。

**选项解析：**

- A. ❌ stall 是保守处理/等待，不是降低预测 penalty 的技术；正确表述：预测可减少停顿，stall 是付出停顿。
- B. ✅ 对。BTB 提供 branch target，让 IF 能提前取目标路径。
- C. ✅ 对。BHT 即使 untagged，也可低成本预测 taken/not-taken。
- D. ✅ 对。backward branch 多为 loop，预测 taken 是有效静态策略。
- E. ❌ data forwarding 绕过数据结果，只解决 data hazard；正确表述：control hazard 用预测、BTB/BHT、早解析等。

### QII-9. What locality is exhibited by `while (A != NULL) A = A->next;`?

A. Data spatial locality  
B. Structural locality  
C. Instruction temporal locality  
D. Instruction spatial locality

**Answer:** C, D

> 位于(notes quiz 2/6_review.md; 5_review.md), 解释：linked-list pointer chasing 数据局部性差；循环体指令反复执行且顺序取指，有 instruction temporal/spatial locality。

**选项解析：**

- A. ❌ 链表节点可能分散在内存，`next` 追踪不是连续数组扫描；正确表述：data spatial locality 差。
- B. ❌ structural locality 不是 review 中的 locality 分类；正确表述：使用 temporal/spatial，并区分 instruction/data。
- C. ✅ 对。while 循环里的少量指令反复执行。
- D. ✅ 对。循环体指令在地址上连续，取指有空间局部性。

### QII-10. What information is stored in each cache block/line?

A. Byte offset  
B. Cache line data  
C. Cache line tag  
D. A valid bit  
E. A set number

**Answer:** B, C, D

> 位于(notes quiz 2/6_review.md), 解释：cache line 保存 data、tag、valid bit；byte offset 和 set index 是地址字段，不存在线内。

**选项解析：**

- A. ❌ byte offset 用于从 line 内选字节，不作为 line metadata 保存；正确表述：offset 来自地址低位。
- B. ✅ 对。cache line 的主体就是被缓存的数据块。
- C. ✅ 对。tag 用于判断该 set/way 中的数据是否对应目标地址。
- D. ✅ 对。valid bit 表示该 line 内容是否有效。
- E. ❌ set number 是地址索引结果，已经由位置隐含；正确表述：line 不需要再保存 set number。

### QIII-1. Data hazards in the 12-instruction RV32I sequence

Original sequence:

```asm
1.  LW  S1, 8(S0)
2.  LW  S2, 16(S0)
3.  SUB T4, S2, S1
4.  AND T5, T4, T3
5.  SUB S4, T4, T3
6.  ADD T6, S4, T4
7.  SW  T6, 4(S7)
8.  LW  S3, 24(S7)
9.  LW  S1, 8(S7)
10. LW  S5, 32(S0)
11. ADD T7, S3, S1
12. LW  S6, 64(S0)
```

**Answer:** Without forwarding: 9 bubbles. The RAW stalls are `2→3:2`, `3→4:2`, `5→6:2`, `6→7:2`, `9→11:1`. With forwarding: the key says 1 bubble remains, because the immediate load-use `2→3` still needs one bubble; ALU-to-ALU and one-gap load uses can be forwarded. Forwarding conditions are `EX/MEM.RegWr && EX/MEM.rd != 0 && EX/MEM.rd == ID/EX.rs1/rs2`, and similarly `MEM/WB.RegWr && MEM/WB.rd != 0 && MEM/WB.rd == ID/EX.rs1/rs2`, with EX/MEM taking priority when both match. A reduced schedule can move independent loads up and rename the later `S1` load to `S8`, but the key explicitly says the shown schedule is “not free of data hazards”; loads 10 and 12 must not be moved before store 7 unless non-aliasing is proven.

> 位于(notes quiz 2/4_4_review.md; notes quiz 2/4_5_review.md), 解释：review 明确列出 no-forwarding 9 bubbles、load-use 规则、forwarding equations、以及 code scheduling 必须保持 dependence/aliasing 语义。

> 注意：`notes quiz 2/4_5_review.md` 有一行 “With forwarding: 2”，但 `3060Quiz2-2026.key.docx` 和 `notes quiz 2/4_4_review.md` 都写该序列 forwarding 后只剩 1 bubble；按 load-use 推导也只剩 `2→3` 这一处。

### QIII-2. Register ports

**Answer:** RV32I scalar register file needs 2 read ports and 1 write port. A two-issue superscalar RV64IFD issuing two FMA instructions needs 6 FP read ports and 2 FP write ports, because each FMA reads 3 source operands and writes 1 destination.

> 位于(notes quiz 1/3_review.md), 解释：review 写明 scalar RV32I regfile = 2R/1W；2-issue FMA FP = 6R/2W。

### QIII-3. Memory wall and hierarchy management

**Answer:** Memory wall is the growing gap between processor speed and main-memory speed/bandwidth. Latency wall can be mitigated by cache/local memory and hidden by multithreading or memory-level parallelism. Bandwidth wall can be mitigated by HBM, wider buses, multiple/interleaved banks, and reducing data movement. Registers and local/shared memory are managed by software/compiler/programmer; caches are hardware managed; virtual memory/main memory involve OS + hardware/MMU.

> 位于(notes quiz 2/6_review.md), 解释：review 对 memory wall、HBM、register/local memory/software management、cache/hardware management 都有对应条目。

### QIII-4. Architecture vs microarchitecture states

**Answer:** RV32I architectural state includes GPRs and PC, plus CSRs in the full ISA model. RV64IFV adds FP/vector architectural registers. In-order retirement keeps traps precise by exposing state in program order. Microarchitectural states include pipeline registers, BHT, BTB, L1I/L1D contents, predictors, and temporary control state; they are not saved as architectural state because they can be refilled or reconstructed after restart.

> 位于(notes quiz 1/3_review.md; notes quiz 2/4_3_review.md; notes quiz 2/4_4_review.md), 解释：review 区分 architectural state 与 pipeline/predictor/cache 等 microarchitectural state，并说明 pipeline registers 和 branch predictors 的角色。

### QIII-5. Data structures and data hazards

**Answer:** Use data layouts that avoid pointer chasing when possible: arrays/vectors instead of linked lists, B/B+ trees or cache-friendly layouts instead of pointer-heavy binary trees, and open addressing instead of chained hash lists when appropriate. Batch independent lookups to expose MLP, use non-blocking caches/MSHRs, and improve locality through layout changes. These reduce the serial load-use chain that causes data hazards.

> 位于(5_review.md; notes quiz 2/6_review.md), 解释：review 写 linked list/tree search 是 latency-bound；data layout can move linked list → array/vector；MSHR/non-blocking cache exposes MLP。

### QIII-6. Control hazards and early branch target calculation

**Answer:** Computing branch target `PC+imm` earlier can let IF fetch the target sooner for predicted-taken branches. It is not always worth extra ID-stage hardware because modern BTB/BHT can predict direction and target in IF. Further gains focus on indirect branches, returns, switch/jump-table targets, virtual calls, and better BTB/RAS handling. Textbook 3 bubbles assumes redirect is used later, e.g. MEM; class 2 bubbles assumes branch condition/target are available in EX and fetch is resteered earlier.

> 位于(notes quiz 2/4_4_review.md; notes quiz 2/4_3_review.md), 解释：review 写 BHT/BTB/RAS、early resolution、control hazard penalty 与 pipeline redirect 时机。

## CSC3060 Quiz1-0205 key.docx

### Q1. What is computer architecture?

A. It is the hardware implementation of a computer  
B. It is the interface between the software and the hardware  
C. It is the rules and conventions that a programmer must follow  
D. It is the components of a computer, including I/O, CPU, and memory

**Answer:** B — It is the interface between the software and the hardware

> 位于(notes quiz 1/3_review.md), 解释：review 定义 ISA/computer architecture 为 software-visible contract / SW-HW interface；具体 hardware implementation 是 microarchitecture。

**选项解析：**

- A. ❌ 硬件实现是 microarchitecture，不是 architecture 的核心定义；正确表述：architecture 是软硬件接口。
- B. ✅ 对。它直接对应 review 的 SW/HW interface。
- C. ❌ 程序员遵守的规则更像 ABI/calling convention 的一部分；正确表述：architecture 包含 ISA 等软件可见接口。
- D. ❌ I/O、CPU、memory 是组织/组成部件；正确表述：部件如何实现属于 organization/microarchitecture。

### Q2. Which of the following is not a system program?

A. ChatGPT  
B. Compiler  
C. OS  
D. Linker

**Answer:** A — ChatGPT

> 位于(notes quiz 1/1_review.md; 7_review.md), 解释：system programs 包括 compiler/assembler/linker/loader/OS 等支撑程序执行的软件；ChatGPT 是应用/服务。

**选项解析：**

- A. ✅ 对。ChatGPT 不是课程意义上的 compiler、OS、linker 这类系统程序。
- B. ❌ Compiler 是系统程序；正确表述：它把源程序翻译到低层表示。
- C. ❌ OS 是系统程序；正确表述：它提供进程、虚拟内存、文件等抽象。
- D. ❌ Linker 是系统程序；正确表述：linker 做 symbol resolution、relocation、library handling。

### Q3. In memory, there is a sequence of 128 bits of 0. Which is not a possible representation?

A. It may be two long integer zeros  
B. It may be four single-precision floating-point +0.0  
C. It may be a character string `"000000000000000"`  
D. It may be one quad-precision floating-point value

**Answer:** C — It may be a character string `"000000000000000"`

> 位于(notes quiz 1/1_review.md; notes quiz 1/2_review.md), 解释：bits 的含义取决于解释方式；全 0 可为整数 0 或浮点 +0，但 ASCII 字符 `'0'` 是 `0x30`，不是 `0x00`。

**选项解析：**

- A. ❌ 这其实可能。128 个 0 可拆成两个 64-bit long integer 0；正确表述：整数 0 可用全 0 bits。
- B. ❌ 这其实可能。IEEE single +0.0 编码为全 0，128 bits 可表示四个 fp32 +0.0。
- C. ✅ 对。字符串 `"000..."` 需要每个字符为 ASCII `0x30`；全 0 bytes 是 NUL，不是字符 `'0'`。
- D. ❌ 这也可能。quad precision 的 +0 同样可编码为全 0；正确表述：全 0 可按浮点零解释。

### Q4. What illusion does a memory hierarchy give you?

A. The memory space is all yours  
B. A memory that is fast, large, and inexpensive  
C. A memory that is small, large, and expensive  
D. A memory that is fast, small, and inexpensive

**Answer:** B — A memory that is fast, large, and inexpensive

> 位于(notes quiz 2/6_review.md), 解释：memory hierarchy 用小而快的上层和大而便宜的下层组合，给程序员 fast + large + inexpensive 的近似抽象。

**选项解析：**

- A. ❌ “memory space is all yours”更接近 virtual memory 给进程私有地址空间的错觉；正确表述：层次结构解决快/大/便宜矛盾。
- B. ✅ 对。它正是 cache + DRAM + lower storage 组合想提供的效果。
- C. ❌ small 和 large 自相矛盾，expensive 也违背低平均成本目标；正确表述：fast, large, inexpensive。
- D. ❌ fast/small/inexpensive 只像 cache，不满足 large；正确表述：层次结构要让整体看起来 large。

### Q5. Which phase is not part of the gcc command pipeline?

A. Preprocess  
B. Linking  
C. Compiling  
D. Loading

**Answer:** D — Loading

> 位于(7_review.md), 解释：`gcc` 是 compiler driver，调用 cpp/cc1/as/ld；loading into memory 是 loader/dynamic linker 在运行时做，不是 gcc 静态命令管线。

**选项解析：**

- A. ❌ Preprocess 属于 gcc 管线，处理宏和 include。
- B. ❌ Linking 属于 gcc driver 调用 `ld` 的阶段。
- C. ❌ Compiling 是 gcc 核心阶段。
- D. ✅ 对。Loading 是运行时把程序装入内存，不是编译/链接管线步骤。

### Q6. Which architecture has only 16 general-purpose registers?

A. RV32MI  
B. RV32EM  
C. RV64IM  
D. RV32ME

**Answer:** B — RV32EM

> 位于(notes quiz 1/3_review.md), 解释：`E` 是 embedded base，只有 16 个 GPR；`M` 只是乘除扩展，不决定寄存器数。

**选项解析：**

- A. ❌ RV32I base 仍有 32 个 GPR，`M` 不减少寄存器；正确表述：需要 `E` base。
- B. ✅ 对。RV32E + M 扩展即 RV32EM，GPR 数为 16。
- C. ❌ RV64I 是 64-bit base 且有 32 个 GPR；正确表述：RV64E 才是 16 GPR 的 64-bit embedded base。
- D. ❌ 命名顺序不规范，base 应写 `RV32E` 再列扩展 `M`；正确表述：RV32EM。

### Q7. Which description of RV32I ISA is NOT true?

A. It is for 32-bit processor implementations; the address range is limited to 4GB  
B. Its memory is byte-addressable  
C. It requires an on-chip cache hierarchy implemented  
D. It supports 32 general-purpose registers: X0-X31

**Answer:** C — It requires an on-chip cache hierarchy implemented

> 位于(notes quiz 1/3_review.md), 解释：RV32I 定义 ISA、寄存器、地址宽度和指令语义；cache hierarchy 是实现选择，ISA 不强制。

**选项解析：**

- A. ❌ 这是正确描述，不是 NOT true；RV32I 的 address width 是 32-bit，可寻址 4GB。
- B. ❌ 这是正确描述；RISC-V memory 是 byte-addressable。
- C. ✅ 对。cache 属于 microarchitecture，可有可无，不是 RV32I ISA 要求。
- D. ❌ 这是正确描述；RV32I 有 `x0-x31` 共 32 个 GPR。

### Q8. When a program is interrupted, what must be saved so it can resume?

A. The memory  
B. All files used by this application  
C. The architectural states  
D. The cache content

**Answer:** C — The architectural states

> 位于(notes quiz 1/3_review.md), 解释：能恢复程序语义的是 PC/GPR/CSR 等 architectural state；cache/BHT/pipeline registers 等 microarchitectural state 可再生。

**选项解析：**

- A. ❌ 内存不需要在每次 interrupt 时复制保存；正确表述：保持地址空间一致，保存 CPU architectural state。
- B. ❌ 文件由 OS 管理，不是处理器 resume 的核心状态；正确表述：保存寄存器/PC 等。
- C. ✅ 对。architectural state 是软件可见、必须精确恢复的状态。
- D. ❌ cache 内容可 miss/refill，不必作为程序状态保存；正确表述：cache 是 microarchitectural state。

### Q9. How do you set up constant `0xAABBCCDD` in register X2?

A. `li X2, 0xAABBCCDD`  
B. `addi X2, X0, 0xAABBCCDD`  
C. `lui X2, 0xAABBC; addi X2, X2, 0xCDD`  
D. `lw X2, 0xAABBCCDD(X0)`

**Answer:** A — `li X2, 0xAABBCCDD`

> 位于(notes quiz 1/3_review.md), 解释：RV32I immediate 宽度有限；装 32-bit 常数用 pseudo `li`，assembler 会处理 `lui/addi` 和低 12 位符号扩展修正。

**选项解析：**

- A. ✅ 对。`li` 是正确伪指令，交给 assembler 展开。
- B. ❌ `addi` 只有 12-bit sign-extended immediate；正确表述：不能直接带 32-bit literal。
- C. ❌ 低 12 位 `0xCDD` 会作为负数符号扩展，简单拼接会错；正确表述：需调整 upper immediate 或用 `li`。
- D. ❌ `lw` 是从内存地址读值，不是装立即数；正确表述：装常数用 `li/lui/addi`。

### Q10. Why do RISC machines often require data to be naturally aligned?

A. Address generation would be easier  
B. To make data memory more compact  
C. To support the C and E extension  
D. To avoid data items crossing cache lines or page boundaries

**Answer:** D — To avoid data items crossing cache lines or page boundaries

> 位于(notes quiz 1/3_review.md; notes quiz 2/6_review.md), 解释：natural alignment 避免一次数据访问跨 cache line/page，减少硬件复杂度、额外访问和异常处理。

**选项解析：**

- A. ❌ 地址生成简单不是主因；正确表述：关键是避免跨 line/page。
- B. ❌ 对齐可能引入 padding，不一定更紧凑；正确表述：对齐换取访问效率。
- C. ❌ C/E extension 与数据自然对齐无直接关系；正确表述：对齐是内存访问和 cache/page 问题。
- D. ✅ 对。跨 cache line/page 会增加访存次数或触发额外处理。

### Q11. What range can an indirect Jump (`JALR`) instruction in RV32I reach?

A. 512KB  
B. 1MB  
C. 4MB  
D. 4GB

**Answer:** D — 4GB

> 位于(notes quiz 1/3_review.md), 解释：`JALR` 目标为 `rs1 + imm12`，`rs1` 可保存任意 32-bit 地址，因此可覆盖 RV32I 4GB 地址空间。

**选项解析：**

- A. ❌ 这像短 immediate reach，不适用于寄存器间接跳转；正确表述：JALR 可由寄存器到达全地址空间。
- B. ❌ 1MB 是 JAL 的 PC-relative 量级；正确表述：JALR 是 4GB。
- C. ❌ 4MB 不是 RV32I JALR reach；正确表述：寄存器给出完整地址。
- D. ✅ 对。RV32I 地址宽度为 32-bit，即 4GB byte address space。

### Q12. In Project 1 `add(a,b)`, what does `(a & b) << 1` represent?

A. The bitwise sum without carries  
B. The carry bits to add in the next iteration  
C. The absolute difference  
D. A logical shift to check overflow

**Answer:** B — The carry bits to add in the next iteration

> 位于(notes quiz 1/2_review.md), 解释：无加法器实现加法时，`a ^ b` 是无进位和，`(a & b) << 1` 是下一轮要加的 carry。

**选项解析：**

- A. ❌ 无进位和是 XOR，不是 AND-left-shift；正确表述：`a ^ b`。
- B. ✅ 对。两个 bit 同为 1 才产生 carry，左移一位送到更高位。
- C. ❌ 该表达式不做大小比较或减法；正确表述：它只表示进位贡献。
- D. ❌ 不是 overflow 检查；正确表述：它是 carry propagation。

### Q13. In `subtract(a,b)`, how is subtraction transformed to use `add()`?

A. `add(a, ~b)`  
B. Bitwise XOR then right shift  
C. `add(a, add(~b, 1))` using two's complement  
D. Loop to count the difference

**Answer:** C — `add(a, add(~b, 1))`

> 位于(notes quiz 1/2_review.md), 解释：two's complement 中 `-b = ~b + 1`，所以 `a-b = a + (~b+1)`。

**选项解析：**

- A. ❌ 少了 `+1`，只是 one's complement；正确表述：必须 `~b + 1`。
- B. ❌ XOR/shift 属于加法迭代，不是减法变换；正确表述：用 two's complement 取负。
- C. ✅ 对。把减法转为加上 `b` 的 two's complement。
- D. ❌ 项目实现不是循环计数差值；正确表述：调用已有 `add()` 完成。

### Q14. On RV64IFD, for `struct S1 A[1000]`, what instruction stores 0 to `A[10].blue`?

A. `SW x0, 322(x1)`  
B. `SW x0, -520(x1)`  
C. `SW x0, 340(x1)`  
D. `SW x0, 4840(x1)`  
E. `SW x0, 520(x1)`

**Answer:** E — `SW x0, 520(x1)`

> 位于(notes quiz 1/3_review.md), 解释：review 的 struct alignment 规则：LP64 下字段按 alignment 排布；该题 key 给出 struct size 48B、`blue` offset 40B，所以 `10*48+40=520`。

**选项解析：**

- A. ❌ 322 没有按 48B stride 与 40B 字段偏移计算；正确表述：offset 是 520。
- B. ❌ 符号方向错，`A[10]` 相对 `A[0]` 是正偏移；正确表述：`520(x1)`。
- C. ❌ 340 说明 stride/field offset 算错；正确表述：`10*48+40`。
- D. ❌ 4840 接近把元素数/大小用错，不是第 10 个元素字段；正确表述：520。
- E. ✅ 对。`x0` 存 0，`SW` 存 32-bit int field，offset 为 520。

### Q15. Which decimal number has exact representation in IEEE 754 FP format?

A. 1.625  
B. 1.405  
C. 1.35  
D. 1.245  
E. 1.11

**Answer:** A — 1.625

> 位于(notes quiz 1/2_review.md), 解释：有限十进制能被二进制浮点精确表示，当且仅当化简分母只含因子 2；`1.625 = 13/8`。

**选项解析：**

- A. ✅ 对。`1.625 = 13/8`，分母是 `2^3`。
- B. ❌ `1.405 = 281/200`，分母含 5；正确表述：不能有限二进制表示。
- C. ❌ `1.35 = 27/20`，分母含 5；正确表述：会被舍入。
- D. ❌ `1.245 = 249/200`，分母含 5；正确表述：不能精确。
- E. ❌ `1.11 = 111/100`，分母含 5；正确表述：不能精确。

### QII-1. Which options represent the same 16-bit value `0x0802`?

A. `0b 0000100000000010`  
B. `0x0813`  
C. `0x0802`  
D. `0b 0000100000010011`

**Answer:** A, C

> 位于(notes quiz 1/2_review.md), 解释：十六进制每位对应 4 个二进制位；`0x0802 = 0000 1000 0000 0010`。

**选项解析：**

- A. ✅ 对。该二进制正好是 `0x0802`。
- B. ❌ `0x0813` 不等于 `0x0802`；正确表述：低字节应为 `02`。
- C. ✅ 对。它就是目标十六进制值。
- D. ❌ 该二进制对应 `0x0813`；正确表述：应为 `0000100000000010`。

### QII-2. What is ABI?

A. ABI stands for Application Binary Interface  
B. ABI is just like API  
C. ABI includes OS system calls, ISA, and calling convention  
D. ABI defines whether an application binary is compatible with a computer system

**Answer:** A, C, D

> 位于(notes quiz 1/3_review.md; notes quiz 1/4_review.md), 解释：ABI = ISA + OS interface + calling convention，定义 binary-level compatibility；API 是 source-level。

**选项解析：**

- A. ✅ 对。ABI 即 Application Binary Interface。
- B. ❌ API 和 ABI 层级不同；正确表述：API 面向源代码，ABI 面向二进制兼容。
- C. ✅ 对。OS syscall、ISA、calling convention 都影响二进制能否运行。
- D. ✅ 对。ABI 的核心作用就是定义 application binary compatibility。

### QII-3. Which instructions belong to RV64I instead of RV32I?

A. `SRA X1, X6, X7`  
B. `LD X1, 0(X2)`  
C. `LWU X1, 0(X2)`  
D. `SLLI X5, X6, 35`

**Answer:** B, C, D

> 位于(notes quiz 1/3_review.md), 解释：RV64I 增加 `LD/LWU` 和更宽 shift-immediate shamt；RV32I 中 `SLLI` shamt 不能超过 31。

**选项解析：**

- A. ❌ `SRA` register form 在 RV32I 已存在；正确表述：不是 RV64I-only。
- B. ✅ 对。`LD` 是 64-bit load，只在 RV64I 有意义。
- C. ✅ 对。`LWU` 是 RV64I 中 zero-extend 32-bit word 到 64-bit 的 load。
- D. ✅ 对。`SLLI ... 35` 需要 6-bit shamt/64-bit XLEN，RV32I shamt 最大 31。

### QII-4. Given `F1=0x40800000`, `F2=0x3F800000`, `F3=0xC0800000`, which statements are correct?

A. `(F3+F1) == 0.0`  
B. `F3 < F2 < F1`  
C. `F2 = F1/F3`  
D. `F3 = -(F1*F2)`

**Answer:** A, B, D

> 位于(notes quiz 1/2_review.md), 解释：IEEE fp32 解码为 `F1=4.0`、`F2=1.0`、`F3=-4.0`。

**选项解析：**

- A. ✅ 对。`-4.0 + 4.0 = 0.0`。
- B. ✅ 对。`-4.0 < 1.0 < 4.0`。
- C. ❌ `F1/F3 = 4.0/(-4.0) = -1.0`，不是 `F2=1.0`。
- D. ✅ 对。`-(4.0*1.0) = -4.0 = F3`。

### QII-5. Which statements about jump instructions are true?

A. JAL and JALR have 20-bit and 12-bit immediates  
B. Jump instructions are in UJ type  
C. Jump instructions can be used for function calls  
D. JALR has a larger jump range than JAL

**Answer:** A, C, D

> 位于(notes quiz 1/3_review.md), 解释：`JAL` 是 J-type 约 20-bit immediate；`JALR` 是 I-type 12-bit immediate + register target；`rd=ra` 可保存返回地址。

**选项解析：**

- A. ✅ 对。JAL 用 J-immediate，JALR 用 I-immediate。
- B. ❌ 只有 JAL 是 J/UJ 类格式；JALR 是 I-type。正确表述：jump 不全是 UJ type。
- C. ✅ 对。写 `rd=ra/x1` 时，jump 同时保存返回地址，可作 call。
- D. ✅ 对。JALR 通过寄存器可达全 32-bit 地址空间，范围大于 JAL 的 PC-relative reach。

### QII-6. Which number systems have both +0 and -0?

A. Signed magnitude integer  
B. Two's complement integer  
C. One's complement integer  
D. IEEE-754 floating-point numbers

**Answer:** A, C, D

> 位于(notes quiz 1/2_review.md), 解释：signed magnitude、one's complement 和 IEEE floating point 都有符号零；two's complement 只有一个零。

**选项解析：**

- A. ✅ 对。符号位可为正/负，数值位全 0。
- B. ❌ two's complement 的全 0 只有一个 0；正确表述：没有 -0。
- C. ✅ 对。one's complement 中全 0 与全 1 分别表示 +0 和 -0。
- D. ✅ 对。IEEE 754 有 sign bit，因此 `+0.0` 和 `-0.0` 都存在。

### QII-7. Which statements about branch and store are TRUE?

A. Both generate a 12-bit byte offset  
B. Store immediate is `rs1`-relative; branch immediate is PC-relative  
C. Both generate a 12-bit offset relative to `rs1`  
D. Branch instructions lack the `rd` field

**Answer:** B, D

> 位于(notes quiz 1/3_review.md), 解释：S-type store offset 是 base register + imm；B-type branch 是 PC-relative 且没有 `rd` 字段。

**选项解析：**

- A. ❌ branch immediate 有隐含低位对齐，不应简单说同样 12-bit byte offset；正确表述：两者编码/基准不同。
- B. ✅ 对。store 用 `rs1+imm` 形成地址，branch 用 `PC+imm`。
- C. ❌ branch 不相对 `rs1`；正确表述：branch 相对 PC。
- D. ✅ 对。B-type 没有 destination register。

### QII-8. Assume A/B/C are `int` and X/Y/Z are floating-point. Which expression is always TRUE?

A. `A*A >= 0`  
B. `(X+Y)+Z == X+(Y+Z)`  
C. If `A < 0` then `-A > 0`  
D. `A == (int)(double)A`

**Answer:** D

> 位于(notes quiz 1/2_review.md), 解释：32-bit int 可由 double 的 53-bit significand 精确表示；int overflow、FP non-associativity、INT_MIN negation 都会破坏其他式子。

**选项解析：**

- A. ❌ `A*A` 可能发生 signed overflow；正确表述：有限位整数不是数学整数。
- B. ❌ floating-point addition 不满足结合律；正确表述：rounding 会改变结果。
- C. ❌ `A` 可能是 INT_MIN，`-A` 不可表示；正确表述：two's complement 最小负数取负会 overflow。
- D. ✅ 对。32-bit int 转 double 不丢精度，再转回 int 保持原值。

### QII-9. When would big-endian and little-endian results differ for integer A?

A. Store A as int but read as char sequence  
B. Store A as long and read as long  
C. Store A as int and read as int  
D. Store A as char sequence but read as int

**Answer:** A, D

> 位于(notes quiz 1/2_review.md), 解释：endianness 影响 multi-byte object 的 byte order；同类型写同类型读不改变抽象值，跨 byte sequence 与 integer 重解释会不同。

**选项解析：**

- A. ✅ 对。按字符逐字节观察 int 存储顺序时，大小端不同。
- B. ❌ long 写 long 读得到同一抽象值；正确表述：差异不会暴露。
- C. ❌ int 写 int 读同理不会暴露 endian 差异；正确表述：同类型读写结果相同。
- D. ✅ 对。把 char byte sequence 重解释成 int 时，byte order 会改变数值。

### QII-10. What does 32 mean in RV32I?

A. The ISA has 32 GPRs  
B. The ISA can address up to `2^32` bytes  
C. The instructions are 32-bit long  
D. The GPRs are 32-bit wide  
E. The ISA contains 32 instructions

**Answer:** B, D

> 位于(notes quiz 1/3_review.md), 解释：review 明确写 `"32" in RV32I = GPR/address width`，不是 instruction length 或 instruction count。

**选项解析：**

- A. ❌ RV32I 确实有 32 个 GPR，但名字里的 32 不是指数量；正确表述：指 XLEN/address width。
- B. ✅ 对。32-bit 地址可寻址 `2^32` bytes。
- C. ❌ base 指令多为 32-bit，但这不是 RV32I 名称中 32 的含义；正确表述：指寄存器/地址宽度。
- D. ✅ 对。RV32I 的 GPR 宽度是 32-bit。
- E. ❌ 指令数不是 32；正确表述：I 是 base integer ISA。

### QIII-1. FMA R4-type redesign

**Answer:** 可改成三操作数累加形式 `rd = rs1 * rs2 + rd`，保留 dot product/matrix multiply 常见收益。它破坏的 regularity 是：RV 格式中 `rd` 通常只作 destination，不同时作 source。FMA 不等于 5-cycle multiply + 4-cycle add 的 9 cycles，因为乘法 partial-product reduction 可与加数 exponent alignment 并行，乘积中间结果也不必先 normalize/round；最终 fused operation 只 rounding 一次，约 5-6 cycles。

> 位于(notes quiz 1/3_review.md; notes quiz 1/2_review.md), 解释：review 明确写 R4 FMA、三操作数替代、rd as src+dst 打破规则性，以及 FMA 5-6 cycles 而非 9 cycles 的原因。

### QIII-2. Why GPUs use low-precision FP, and why bfloat16 is popular

**Answer:** 低精度能让同样寄存器/内存带宽装入更多元素，提升 SIMD/tensor throughput 并降低能耗。bfloat16 比 IEEE fp16 流行，是因为 bfloat16 有 8-bit exponent，范围接近 fp32；fp16 exponent 只有 5-bit，更容易 overflow/underflow。AI/ML 是近似计算，mantissa 少一些通常可接受。

> 位于(notes quiz 1/2_review.md), 解释：review 写 bfloat16 `s|exp8|frac7`、fp32 range、ML-friendly，以及 low precision 带来的 bandwidth/throughput 优势。

### QIII-3. RV32I code generation for shifts, multiply/divide by constants, compare, and software multiply

**Answer:** `a,b,c` 按 calling convention 在 `a0,a1,a2`。`a*4`: `slli t0,a0,2`；`b*61`: `slli t0,a1,6; slli t1,a1,2; sub t0,t0,t1; add t0,t0,a1`；unsigned `a/8`: `srli t0,a0,3`；signed `b>>3`: `srai t0,a1,3`；signed `b/8`: negative 时先加 7 再 `srai`；`a%128`: `andi t0,a0,0x7f`；`pow(2,a)`: `addi t1,x0,1; sll t1,t1,a0`；`a=(b>=c)`: 可用 `slt a0,a1,a2; xori a0,a0,1` 或等价比较；`b*c`: shift-and-add loop。

> 位于(notes quiz 1/3_review.md), 解释：review 的 RV32I C-to-assembly 表包含这些 constant multiply/divide、signed/unsigned shift、comparison 和 software multiply 模式。

### QIII-4. Should RV64I incorporate 128 registers?

**Answer:** 不建议。更多寄存器会让 register file 访问更慢、端口/硬件成本更高；寄存器号字段变长会压缩 immediate/opcode 或迫使指令变长；函数调用和 context switch 保存恢复成本上升；数组、结构体、字符串等仍需要内存，不能靠更多 GPR 消除大多数内存访问。

> 位于(notes quiz 1/3_review.md), 解释：review 的 “Should We Have 1024 Registers?” 条目给出 slower access、save/restore、longer instruction、aggregates still need memory 等理由；128 registers 同理但程度较轻。

### QIII-5. Why not support `LW rd, (rs1+rs2)`?

**Answer:** A[i] 地址通常是 `base + i * sizeof(T)`，不是简单 `rs1+rs2`；若把 scaling 加进 load，会复杂化 addressing mode。该格式还需要 `rd/rs1/rs2` 三个寄存器字段并执行 memory load，混合了 R-type 三寄存器运算和 load/store 规则，破坏 ISA regularity。

> 位于(notes quiz 1/3_review.md), 解释：review 明确列出 rejected memory form `LW rd,(rs1+rs2)`，理由包括 no scaled index、regularity break。

### QIII-6. Estimated RV32IF latencies

**Answer:** Integer multiply about 3-5 cycles；integer divide about 32 cycles；single-precision FP add about 4 cycles；single-precision FP multiply about 5 cycles；FP-to-int conversion about 3-5 cycles。

> 位于(notes quiz 1/2_review.md), 解释：review 的 latency table 明确列出 int mul 3-5、int div ~32、FP add 4、FP mul 5、FP→int 3-5。

## CSC3050 final.pdf / final sol.docx

### Q1. Which is the binary representation of integer `4141` in 16-bit?

A. `0b 0001 0000 0010 0011`  
B. `0b 0001 0000 0010 1101`  
C. `0b 1001 0010 0100 1001`  
D. `0b 0001 0000 0111 0011`

**Answer:** B — `0b 0001 0000 0010 1101`

> 位于(notes quiz 1/2_review.md), 解释：整数进制转换按二进制位权；`4141 = 4096 + 45 = 0x102D`。

**选项解析：**

- A. ❌ 该值是 `0x1023 = 4131`；正确表述：低字节应为 `0x2D`。
- B. ✅ 对。`0x102D = 0001 0000 0010 1101`。
- C. ❌ 最高位为 1，数值远大于 4141；正确表述：4141 的高 nibble 是 `0001`。
- D. ❌ `0x1073` 不是 `0x102D`；正确表述：二进制低 8 位是 `0010 1101`。

### Q2. Which is the single-precision FP representation of `4141.125`?

A. `0x45815010`  
B. `0x45BA0A00`  
C. `0x45816B00`  
D. `0x45815100`

**Answer:** C — `0x45816B00` (PDF 标注为 closest choice；精确 fp32 是 `0x45816900`)

> 位于(notes quiz 1/2_review.md), 解释：IEEE fp32 = sign 1 bit, exponent 8 bits with bias 127, fraction 23 bits；按该规则计算 `4141.125` 得 `0x45816900`。

> 注意：final.pdf 高亮 C，并写明 “Although the real value is 45816900, this is the closest one”。因此考试答案按 PDF 选 C；IEEE 精确值仍是 `0x45816900`。

**选项解析：**

- A. ❌ 不是精确编码；正确表述：`4141.125` 应为 `0x45816900`。
- B. ❌ 解码数值接近 5953.25，指数/尾数都不对；正确表述：应选 `0x45816900`，但不在选项中。
- C. ✅ 按 PDF 标注为最接近选项；但严格 IEEE 解码它是 4141.375，不是精确值。正确表述：精确 bit pattern 是 `0x45816900`。
- D. ❌ 解码约 4138.125；正确表述：不是目标值。

### Q3. Row-major arrays: `for i; for j; C[j][i]=A[j][i]+B[j][i]` on small L1D. What data locality appears?

A. Spatial locality  
B. Structural locality  
C. Temporal locality  
D. None of the above

**Answer:** D — None of the above

> 位于(notes quiz 2/6_review.md), 解释：row-major 中同一行连续；该循环内层改变 `j`、固定 `i`，等于跨行按大 stride 访问，小 L1D 中很难利用 data spatial/temporal locality。

**选项解析：**

- A. ❌ 不是连续地址扫描；正确表述：若内层遍历列 `i` 才有 row-major spatial locality。
- B. ❌ structural locality 不是 review 的 locality 分类；正确表述：判断 temporal/spatial。
- C. ❌ 每个元素基本只访问一次，没有短期重用；正确表述：没有明显 data temporal locality。
- D. ✅ 对。小 L1D 下跨行 stride 访问导致上述 locality 都不成立。

### Q4. Which statement is always true?

A. A larger cache always hits better  
B. A direct-mapped cache always has lower tag overhead than same-sized set-associative cache  
C. A direct-mapped cache always has faster hit time than equal-sized set-associative cache  
D. A large cache block always yields better hit rate for same-sized caches

**Answer:** B

> 位于(notes quiz 2/6_review.md), 解释：same cache size/line size 下 direct-mapped 只有一个 way，tag/metadata 最少；hit time 和 hit rate 不能用 always 绝对化。

**选项解析：**

- A. ❌ larger cache 可能因 associativity/line size/latency/working set 变化不一定“always hits better”；正确表述：更大通常减少 capacity miss，但不是绝对。
- B. ✅ 对。相同容量和 line size 下，direct-mapped line 数/way 组织让 tag overhead 最低。
- C. ❌ direct-mapped 常更简单，但具体 hit time 取决于实现、大小和电路；正确表述：不能 always。
- D. ❌ 大 block 可利用 spatial locality，但会增加 miss penalty、减少 line 数并可能污染；正确表述：不保证 hit rate 总更好。

### Q5. Which instruction is NOT present in RV64I?

A. LWU  
B. LDU  
C. LHU  
D. LBU

**Answer:** B — LDU

> 位于(notes quiz 1/3_review.md), 解释：RV64I 有 `LD`、`LWU`、`LHU`、`LBU` 等；`LDU` 不是 RV64I 指令名。

**选项解析：**

- A. ❌ `LWU` 存在，用于 word zero-extend 到 64-bit。
- B. ✅ 对。不存在 `LDU`；64-bit load 是 `LD`。
- C. ❌ `LHU` 存在，zero-extend halfword。
- D. ❌ `LBU` 存在，zero-extend byte。

### Q6. For a low-cost mobile RV32I core, which extension should be added?

A. M  
B. F  
C. C  
D. D

**Answer:** C — C extension

> 位于(notes quiz 1/3_review.md), 解释：`C` compressed extension 提供 16-bit compressed instructions，降低 code size 和 I-cache/memory footprint，适合低成本/移动场景。

**选项解析：**

- A. ❌ M 增加乘除，不直接解决代码密度/低成本取指压力；正确表述：低成本移动优先 C。
- B. ❌ F 增加单精度浮点硬件，成本更高；正确表述：不是低成本通用优先项。
- C. ✅ 对。压缩指令减少程序体积和取指带宽。
- D. ❌ D 增加双精度浮点，硬件成本更高；正确表述：不适合“low-cost”优先。

### Q7. Which VA/PA statement is NOT true?

A. Load/store generated addresses are VA  
B. Cache access addresses are PA  
C. Page table mapping VA to PA is stored in disk  
D. TLB is a cache for page table

**Answer:** C

> 位于(notes quiz 2/6_review.md), 解释：程序 load/store 产生 virtual address；TLB 缓存 page table translation；page table 常驻主存，disk 只在 page fault/backing store 中相关。

**选项解析：**

- A. ❌ 这是正确说法，不是 NOT true；CPU 先产生 VA。
- B. ❌ 按课程常见 physically tagged/accessed cache 模型，cache 用 PA 访问；不是错误项。
- C. ✅ 对。页表不“存储在 disk”作为正常查表位置；正确表述：page table 在 main memory。
- D. ❌ 这是正确说法；TLB 是 page table entry 的 cache。

### Q8. 2-way 4KB cache, 16B line: which sequence runs into conflict misses?

A. `0x01ABC000, 0x01ABC004, 0x01ABC010, 0x01ABC202`  
B. `0x01ABC000, 0x01ABC120, 0x01ABCA30, 0x01ABCD40`  
C. `0x01001000, 0x01001004, 0x00100A0, 0x01AAA000`  
D. `0x01ABA0A0, 0x01ABB0A0, 0x01ABC0AA, 0x01ABD0AA`

**Answer:** D

> 位于(notes quiz 2/6_review.md), 解释：2-way 4KB、16B line 有 `4096/(2*16)=128` sets；同一 set 中超过 2 个不同 blocks 会发生 conflict miss。

**选项解析：**

- A. ❌ 前两个地址同一 block，其他地址不造成超过 2-way 的同 set 竞争；正确表述：不构成冲突序列。
- B. ❌ 地址分散到不同 set；正确表述：没有同 set 超过 2 个 blocks。
- C. ❌ set 0 中最多两个不同 blocks，2-way 可容纳；正确表述：未超过 associativity。
- D. ✅ 对。四个不同 blocks 都映射到同一 set，超过 2-way 容量，会互相驱逐。

### Q9. When does a procedure call require no register save/restore overhead?

A. A leaf routine that uses only callee-save registers  
B. A leaf routine that uses only caller-save registers  
C. A leaf routine that uses no registers, all variables on stack  
D. A non-leaf routine

**Answer:** B

> 位于(notes quiz 1/4_review.md), 解释：leaf routine 不调用别人，使用 caller-saved `a/t` temporaries 通常无需保存；修改 callee-saved `s` registers 反而要保存恢复。

**选项解析：**

- A. ❌ callee-save register 若被修改，callee 必须保存恢复；正确表述：leaf 优先 caller-saved。
- B. ✅ 对。leaf 没有内部 call，caller-saved temps 不需要为下级调用保存。
- C. ❌ 全放栈会增加内存访问，不是无 save/restore overhead 的好情况。
- D. ❌ non-leaf 通常至少要保护 `ra` 和跨调用 live values；正确表述：不是零开销。

### Q10. Single-cycle datapath: D-cache miss rate 5%, 50% load/store, memory latency 100 cycles. Average CPI?

A. 2.5  
B. 3.5  
C. 4.5  
D. 3

**Answer:** B — 3.5

> 位于(notes quiz 2/6_review.md), 解释：CPI 加上 data miss penalty：`base CPI + load/store fraction * miss rate * miss penalty`。

**选项解析：**

- A. ❌ 少算了 penalty；正确计算是 `1 + 0.5*0.05*100`。
- B. ✅ 对。`1 + 2.5 = 3.5`。
- C. ❌ 多加了 1 个 CPI；正确表述：base CPI 只加一次。
- D. ❌ 这是 40% load/store 时的类似结果；正确表述：本题 50% 得 3.5。

### QII-1. What are general RISC hardware design principles?

A. Simplicity favors regularity  
B. Make common cases fast  
C. Keep it Simple and Stupid (KISS)  
D. Smaller is faster  
E. Good design demands good compromises

**Answer:** A, B, D, E

> 位于(notes quiz 1/3_review.md), 解释：review 列出 RISC design principles：simplicity favors regularity、make common case fast、smaller is faster、good design demands good compromises。

**选项解析：**

- A. ✅ 对。规则性让 decode/control 更简单。
- B. ✅ 对。常见情况快是 Patterson/Hennessy 设计原则。
- C. ❌ KISS 是泛化口号，不是 review 中列出的正式四条之一；正确表述：simplicity favors regularity。
- D. ✅ 对。更小硬件通常更快。
- E. ✅ 对。ISA/实现设计要在性能、成本、复杂度之间折中。

### QII-2. What are typically defined in a calling convention?

A. Argument passing through registers  
B. Caller/callee save registers  
C. Function variable naming  
D. Return value placement  
E. Legal data types of arguments

**Answer:** A, B, D

> 位于(notes quiz 1/4_review.md), 解释：calling convention 定义 arg/return registers、caller/callee-saved split、stack/frame layout；不定义变量名或语言合法类型。

**选项解析：**

- A. ✅ 对。参数如何放入 `a0-a7` 等是 calling convention 内容。
- B. ✅ 对。caller/callee save 责任是 ABI 调用约定核心。
- C. ❌ 变量命名是源语言/编译器前端问题；正确表述：calling convention 管二进制调用接口。
- D. ✅ 对。返回值放在 `a0/a1` 等由 calling convention 定义。
- E. ❌ 合法数据类型由语言和 ABI 数据模型决定，不是 calling convention 核心条目。

### QII-3. If a 32-bit memory word is all zeros, what could it signify?

A. Integer value 0  
B. Floating point +0.0  
C. A denormalized number  
D. Four NUL characters

**Answer:** A, B, D

> 位于(notes quiz 1/2_review.md), 解释：全 0 bits 可表示 integer 0、IEEE +0.0、NUL bytes；denormal/subnormal 要求 exponent=0 且 fraction 非 0。

**选项解析：**

- A. ✅ 对。two's complement integer 0 是全 0。
- B. ✅ 对。IEEE fp32 `+0.0` 是 sign=0、exp=0、frac=0。
- C. ❌ denormal 不是全 0 fraction；正确表述：exp=0 且 fraction 非 0。
- D. ✅ 对。每个 byte `0x00` 是 NUL 字符。

### QII-4. Which caches are usually fully associative?

A. A TLB  
B. A branch predictor  
C. L1D  
D. A victim cache

**Answer:** A, D

> 位于(notes quiz 2/6_review.md), 解释：review 写 fully-associative structures: TLB + victim cache；L1D 通常 set-associative，BHT/PHT 通常 indexed/untagged。

**选项解析：**

- A. ✅ 对。TLB 较小，适合全相联查找减少 translation conflict。
- B. ❌ branch predictor table 通常按 PC/history index，不是 fully associative cache。
- C. ❌ L1D 命中路径要求快，通常 direct/set-associative；正确表述：不是 usually fully associative。
- D. ✅ 对。victim cache 很小，常用 fully associative 来接住 conflict lines。

### QII-5. Virtual address aliasing complicates which structures?

A. A multi-level indexing page table  
B. A virtual addressed/tagged cache  
C. An inverted page table  
D. A TLB

**Answer:** B, C, D

> 位于(notes quiz 2/6_review.md), 解释：review 明确写 virtual-tagged cache complicated by synonyms/aliasing；final.pdf 还高亮 inverted page table 和 TLB。后两项在 `*_review.md` 中没有同等直接表述，但按 PDF 标注保留。

**选项解析：**

- A. ❌ PDF 未标。多级页表按 VA 层级索引 PTE，不是这题高亮答案。
- B. ✅ 对。virtual tag 无法自动识别两个 VA 的同一 PA 身份。
- C. ✅ 按 PDF 标注。解释：inverted page table 以 physical page 为中心记录映射，多个 VA/进程 alias 到同一 PA 会让反向/共享映射管理更复杂；但这条没有在 `*_review.md` 中直接展开。
- D. ✅ 按 PDF 标注。解释：TLB 缓存 VA→PA translation，alias/synonym 与 ASID/一致性处理会增加复杂度；但 review 最直接强调的是 virtual-tagged cache。

### QII-6. Which mapping tables do not have tags?

A. A single-level page table  
B. A branch predictor  
C. A L3 data cache  
D. A TLB

**Answer:** A, B

> 位于(notes quiz 2/6_review.md; notes quiz 2/4_4_review.md), 解释：single-level page table 可由 VPN 直接 index PTE；BHT/PHT 常可 untagged；L3 cache/TLB 需要 tag 区分命中。

**选项解析：**

- A. ✅ 对。VPN 直接决定 PTE 位置，不需要 tag 比较。
- B. ✅ 对。简单 BHT/PHT 可只用 index，允许 aliasing。
- C. ❌ L3 data cache 必须有 tag 判断 block identity。
- D. ❌ TLB 需要 VPN/ASID tag 来判断 translation 是否命中。

### QII-7. When cache size increases, which misses decrease?

A. Compulsory  
B. Conflict  
C. Capacity  
D. Coherence

**Answer:** B, C

> 位于(notes quiz 2/6_review.md), 解释：更大 cache 通常减少 capacity misses，也常减少 conflict misses；first-touch compulsory 和多核 coherence misses 不靠容量直接消除。

**选项解析：**

- A. ❌ compulsory miss 是第一次访问，单纯增大 cache 不消除；正确表述：可用 prefetch/更大 line 影响。
- B. ✅ 对。更多 sets/容量可降低同 set 竞争概率。
- C. ✅ 对。working set 更可能装下，capacity miss 减少。
- D. ❌ coherence miss 来自多核 invalidation/sharing；正确表述：容量增大不是直接解法。

### QII-8. Which are useful in reducing cache capacity misses?

A. Increase cache size  
B. Increase line size  
C. Add victim cache  
D. Change to set associative  
E. Cache prefetching

**Answer:** A

> 位于(notes quiz 2/6_review.md), 解释：capacity miss 来自 working set 超过 cache；final.pdf 只高亮 “increase cache size”。prefetch 可隐藏/提前处理 miss penalty，但不直接减少 working-set capacity miss count。

**选项解析：**

- A. ✅ 对。容量更大可容纳更多 working set。
- B. ❌ line size 变大在总容量固定时减少 line 数，不一定减少 capacity miss；正确表述：它主要利用 spatial locality/减少 compulsory。
- C. ❌ victim cache 主要缓解 direct-mapped conflict misses。
- D. ❌ associativity 主要缓解 conflict misses，不改变总容量。
- E. ❌ PDF 未标。prefetch 更准确说是隐藏/提前 miss latency，不是从根本上减少 capacity miss 数量；正确表述：capacity miss 的直接手段是增大 cache 或减少工作集。

### QII-9. A calls B in a loop and both have many I-cache misses. How improve?

A. Turn off instruction cache  
B. Increase D-cache associativity  
C. Inline B into A  
D. Ask linker to place A and B next to each other

**Answer:** D

> 位于(7_review.md; 5_review.md), 解释：final.pdf 只高亮 linker layout；7_review.md 明确写 linker 可通过 function/code layout 改善 I-cache locality。5_review.md 也提到 inlining 可改善 I-cache locality，但考试 PDF 未标 C，因此此处按 PDF 只选 D。

**选项解析：**

- A. ❌ 关闭 I-cache 会让取指更慢；正确表述：改善代码布局而不是禁用 cache。
- B. ❌ 问题是 instruction cache，不是 data cache。
- C. ❌ PDF 未标。技术上 5_review.md 提到 inlining 可改善 hot caller/callee 的 I-cache locality，但该题标答只接受 linker layout；正确表述：按 final.pdf 选 D。
- D. ✅ 对。linker layout 让 A/B 邻近可减少 I-cache 冲突/跳转局部性差。

### QII-10. Which memory mappings are managed by compiler?

A. Memory to registers  
B. Memory to cache  
C. Disk to memory  
D. Memory to local/shared memory

**Answer:** A, D

> 位于(notes quiz 2/6_review.md; 5_review.md), 解释：register allocation 和 local/shared memory placement 可由 compiler/programmer 管理；cache 由硬件管理，disk-memory paging 由 OS 管理。

**选项解析：**

- A. ✅ 对。寄存器分配是编译器优化。
- B. ❌ cache placement/replacement/write policy 通常由硬件管理。
- C. ❌ disk-to-memory 是 OS 虚拟内存/文件系统职责。
- D. ✅ 对。GPU local/shared memory 等显式层级可由 compiler/programmer 控制。

### QIII-1. ISA design issues: 1024 registers, post-increment load, condition codes

**Answer:** 1024 registers: generally no, because register fields widen, register file access gets slower/costlier, save/restore and context-switch cost rise, and arrays/strings/structures still need memory. Post-increment load: generally no, because it writes both `rd` and base register, needs extra write ports, complicates forwarding/hazards/precise exceptions. Condition-code side effects: generally no for RISC-V style, because hidden flag state creates implicit dependencies and complicates OoO/precise state; compare-and-branch is more explicit.

> 位于(notes quiz 1/3_review.md), 解释：review 有 “1024 GPRs”、no post-increment load、compare-and-branch vs condition codes 三个对应条目。

### QIII-2. Standard data formats

**Answer:** signed integers: two's complement；single/double precision FP: IEEE 754-1985 fp32/fp64；English characters: ASCII；international characters: Unicode；FP16: IEEE 754-2008 half precision, `1/5/10` sign/exponent/fraction；FP8/HP8 mini-float: PDF 标注 `1/4/3` sign/exponent/fraction。

> 位于(notes quiz 1/2_review.md), 解释：review 的 Data format standards 条目列出 two's complement、IEEE 754、ASCII、Unicode，并说明 FP8/FP4/HP8 是 AI mini-floats 而非 core IEEE；`1/4/3` 是 final.pdf 的标注。

### QIII-3. Pipelining hazards and strategies

**Answer:** Structural hazards: duplicate/pipeline resources, split I/D cache, enough ports/adders. Data hazards: forwarding/bypassing, stall, compiler scheduling, OoO/renaming where applicable. Control hazards: branch prediction, BTB/BHT/RAS, early branch resolution, stall/flush when necessary。

> 位于(notes quiz 2/4_4_review.md), 解释：review 明确列出 structural/data/control 三类 hazards 和 fixes。

### QIII-4. Cache organization: 2-way, 64 sets, 16B block, address `0x1234`

**Answer:** Cache size = `2 * 64 * 16 = 2048B`. Block offset bits = 4, set index bits = 6. Set index for `0x1234` is `(0x1234 >> 4) & 0x3f = 0x23 = 35`. If the set holds `0x1230` and `0x4230`, access `0x1234` hits the `0x1230` line. If the set holds `0x7230` and `0x4230`, access `0x1234` misses and must evict one of the two ways.

> 位于(notes quiz 2/6_review.md), 解释：review 的 cache address decomposition 用 block offset、set index、tag 判断 hit/miss。

### QIII-5. Parallelism acronyms and feature mapping

**Answer:** ILP = Instruction-Level Parallelism, TLP = Thread-Level Parallelism, DLP = Data-Level Parallelism, MLP = Memory-Level Parallelism. PDF 标注映射：Branch predictors = ILP；Snoopy caches = TLP；Out-of-order execution = MLP, ILP；Vector instructions = DLP；Non-blocking caches = MLP；GPU = DLP, MLP, TLP；Pipelining = ILP；Sub-word parallel instructions = DLP；Multi-cores = TLP；Inclusive caches = TLP；MSHR = MLP；Interleaved memory banks = MLP。

> 位于(notes quiz 1/1_review.md; notes quiz 2/6_review.md; notes quiz 2/4_4_review.md), 解释：review 中的 parallelism 表和 MSHR/non-blocking cache/coherence 条目支撑这些分类。

## CSC3050 Quiz1.pptx

### Q1. What is Computer Architecture?

A. It is all about the hardware organization of a computer  
B. It is all about writing assembly code  
C. It is the interface between hardware and software  
D. It includes ISA and its microarchitectures

**Answer:** C, D

> 位于(notes quiz 1/3_review.md), 解释：computer architecture 是 SW/HW interface；ISA 是软件可见 contract，microarchitecture 是实现 architecture 的方式。

**选项解析：**

- A. ❌ 只讲 hardware organization，偏 microarchitecture；正确表述：architecture 是软硬件接口。
- B. ❌ 写汇编只是使用 ISA，不是定义 architecture；正确表述：architecture 包含 ISA。
- C. ✅ 对。直接对应 SW/HW interface。
- D. ✅ 对。课程语境中 architecture discussion 包括 ISA 及其 microarchitectures。

### Q2. What are the general RISC hardware design principles?

A. Simplicity favors regularity  
B. Smaller is faster  
C. KISS  
D. Good design demands good compromises  
E. Make common cases fast

**Answer:** A, B, D, E

> 位于(notes quiz 1/3_review.md), 解释：review 列出 RISC principles：regularity、smaller faster、common case fast、good compromises。

**选项解析：**

- A. ✅ 对。规则性简化硬件。
- B. ✅ 对。小结构通常更快。
- C. ❌ KISS 是泛化口号，不是 review 列出的正式原则；正确表述：simplicity favors regularity。
- D. ✅ 对。设计需要性能/成本/复杂度折中。
- E. ✅ 对。常见情况优化是核心原则。

### Q3. Which RV32I instructions can clear register X1?

A. `XOR X1, X1, X1`  
B. `ADD X1, X0, X0`  
C. `ADD X1, X0, X1`  
D. `AND X1, X0, X1`

**Answer:** A, B, D

> 位于(notes quiz 1/3_review.md), 解释：`x0` hardwired 0；`xor` self 得 0，`and` with 0 得 0。

**选项解析：**

- A. ✅ 对。任意值 XOR 自身为 0。
- B. ✅ 对。`x0+x0=0` 写入 X1。
- C. ❌ `x0+x1` 仍为原 X1；正确表述：不会清零。
- D. ✅ 对。任意值 AND 0 为 0。

### Q4. What localities are exhibited in `for (i=0; i<100; i++) a[i] += b[i];`?

A. Structural locality  
B. Temporal locality  
C. Spatial locality  
D. Special locality

**Answer:** B, C

> 位于(notes quiz 2/6_review.md; 5_review.md), 解释：顺序数组访问有 data spatial locality；循环体指令反复执行有 instruction temporal locality。

**选项解析：**

- A. ❌ structural locality 不是 review 的 locality 分类；正确表述：temporal/spatial locality。
- B. ✅ 对。循环指令会重复执行，体现 temporal locality。
- C. ✅ 对。`a[i]`、`b[i]` 顺序访问连续元素，体现 spatial locality。
- D. ❌ special locality 是干扰项；正确表述：spatial locality。

### Q5. What does the 32 mean in RV32I?

A. GPR is 32-bit wide  
B. There are 32 GPRs  
C. Instructions are 32-bit long  
D. Addressability is 32-bit  
E. Core ISA has 32 instructions

**Answer:** A, D

> 位于(notes quiz 1/3_review.md), 解释：`32` in RV32I = GPR/address width。

**选项解析：**

- A. ✅ 对。XLEN=32，GPR 宽度 32-bit。
- B. ❌ RV32I 确实有 32 GPR，但名字里的 32 不是数量；正确表述：指宽度。
- C. ❌ base instruction 多为 32-bit，但不是名称含义；正确表述：指 GPR/address width。
- D. ✅ 对。地址宽度 32-bit。
- E. ❌ ISA 指令数不是 32；正确表述：`I` 表 base integer ISA。

### Q6. Which instructions belong to RV64I instead of RV32I?

A. `LD X1, 0(X2)`  
B. `LWU X1, 0(X2)`  
C. `SLLI X5, X6, 48`  
D. `SLL X5, X6, X7`

**Answer:** A, B, C

> 位于(notes quiz 1/3_review.md), 解释：RV64I-only 包含 `LD/LWU` 和更宽 shamt；register-form `SLL` 在 RV32I 已有。

**选项解析：**

- A. ✅ 对。`LD` 是 64-bit load。
- B. ✅ 对。`LWU` 是 RV64I 的 word zero-extend。
- C. ✅ 对。shift immediate 48 超出 RV32I shamt 范围。
- D. ❌ `SLL` register form 属于 RV32I；正确表述：不是 RV64I-only。

### Q7. Which are microarchitecture instead of architecture?

A. Out-of-order instruction execution  
B. RISC-V ISA  
C. Fast integer multiplier  
D. Intel x86 family  
E. Microprocessors with L1/L2/L3 on-chip caches

**Answer:** A, C, E

> 位于(notes quiz 1/3_review.md; notes quiz 2/4_1_review.md), 解释：ISA 是 software-visible architecture；OoO、multiplier latency/cache hierarchy 是 processor implementation choices。

**选项解析：**

- A. ✅ 对。OoO 是实现如何执行 ISA 的 microarchitecture。
- B. ❌ RISC-V ISA 是 architecture，不是 microarchitecture。
- C. ✅ 对。fast multiplier 是功能单元实现选择。
- D. ❌ x86 family 是 ISA/architecture family。
- E. ✅ 对。片上 cache 层级是具体实现。

### Q8. Which instruction can be inferred as a procedure return?

A. `JAL X1, 1020`  
B. `JALR X0, 0(X1)`  
C. `JALR X3, 0(X3)`  
D. `JALR X1, 1024(X1)`

**Answer:** B

> 位于(notes quiz 1/3_review.md; notes quiz 1/4_review.md), 解释：return idiom 是跳到 `ra/x1` 且不写 link，即 `jalr x0,0(ra)`。

**选项解析：**

- A. ❌ `JAL X1` 保存 link，像 call 不是 return。
- B. ✅ 对。跳到 `x1/ra`，`rd=x0` 丢弃 link。
- C. ❌ base 不是 `ra` 且还写 `x3`；正确表述：return 应 `rd=x0, rs1=ra`。
- D. ❌ 写回 `x1` 且 offset 1024，不是标准 return。

### Q9. Which instruction can be inferred as a procedure call?

A. `JAL X1, 1020`  
B. `JALR X0, 0(X1)`  
C. `JAL X0, 1020`  
D. `JALR X1, 4(X1)`

**Answer:** A

> 位于(notes quiz 1/3_review.md; notes quiz 1/4_review.md), 解释：call 必须跳转并保存返回地址到 `ra/x1`；`rd=x0` 是 plain jump/return-like discard。

**选项解析：**

- A. ✅ 对。`JAL X1` 把 `PC+4` 写入 ra，同时跳转。
- B. ❌ `rd=x0` 不保存返回地址，且像 return。
- C. ❌ `JAL X0` 丢弃 link，只是跳转。
- D. ❌ 以 `x1` 为 base 又覆盖 `x1`，不是正常 call idiom。

### Q10. RV32I ISA is

A. One-operand format  
B. Two-operand format  
C. Three-operand format  
D. Four-operand format

**Answer:** C

> 位于(notes quiz 1/3_review.md), 解释：RV32I 常规 ALU 指令是 `rd, rs1, rs2/imm` 三操作数 load/store RISC 风格。

**选项解析：**

- A. ❌ 不是 accumulator/one-operand ISA。
- B. ❌ 不采用 x86 式 two-operand destructive form。
- C. ✅ 对。R-type 典型格式为 `rd = rs1 op rs2`。
- D. ❌ 四操作数只出现在特殊 R4 FMA，不是 RV32I 基本格式。

### Q11. Which are I-type instructions?

A. `JAL X1, 1020`  
B. `JALR X0, 0(X2)`  
C. `LW X1, 0(X2)`  
D. `SW X1, 0(X2)`  
E. `SLLI X1, X1, 4`

**Answer:** B, C, E

> 位于(notes quiz 1/3_review.md), 解释：I-type 包括 load、JALR、immediate ALU/shift-immediate；JAL 是 J-type，store 是 S-type。

**选项解析：**

- A. ❌ JAL 是 J-type。
- B. ✅ 对。JALR 是 I-type。
- C. ✅ 对。load 使用 I-type immediate。
- D. ❌ store 是 S-type，没有 `rd`。
- E. ✅ 对。SLLI 是 I-type shift-immediate。

### Q12. What is the branch reach in RV32I?

A. ±512KB  
B. ±1KB  
C. ±2KB  
D. ±4KB

**Answer:** D

> 位于(notes quiz 1/3_review.md), 解释：B-type branch immediate 约 12 bits 加隐含低位 0，reach 约 ±4KiB。

**选项解析：**

- A. ❌ 过大；正确表述：branch 不是 JAL。
- B. ❌ 过小；正确表述：B-type reach 约 ±4KB。
- C. ❌ 少算符号/对齐范围；正确表述：约 ±4KB。
- D. ✅ 对。

### Q13. What is the JAL reach in RV32I?

A. ±512KB  
B. ±1MB  
C. ±2MB  
D. ±4MB

**Answer:** B

> 位于(notes quiz 1/3_review.md), 解释：JAL J-type immediate 约 20 bits 加隐含低位 0，PC-relative reach 约 ±1MiB。

**选项解析：**

- A. ❌ 少一倍量级。
- B. ✅ 对。
- C. ❌ 这是常见误算；正确表述：约 ±1MB。
- D. ❌ 过大。

### Q14. What range can JALR in RV32I reach?

A. 4KB  
B. 1MB  
C. 4MB  
D. 4GB

**Answer:** D

> 位于(notes quiz 1/3_review.md), 解释：JALR 使用 register + immediate，register 可保存完整 32-bit 地址。

**选项解析：**

- A. ❌ 这是 branch 量级。
- B. ❌ 这是 JAL 量级。
- C. ❌ 不是 JALR 限制。
- D. ✅ 对。可覆盖 RV32I 4GB 地址空间。

### Q15. Signed `y >> 8` and unsigned `d >> 4`: which RV32I instructions?

A. `SRLI` for `d >> 4`  
B. `SRA` for `y >> 8`  
C. `SRAI` for `y >> 8`  
D. `SLLI` for `d >> 4`

**Answer:** A, C

> 位于(notes quiz 1/3_review.md), 解释：unsigned right shift uses logical shift right；signed right shift by constant uses arithmetic shift right immediate。

**选项解析：**

- A. ✅ 对。unsigned 右移补 0，用 `SRLI`。
- B. ❌ shift amount 是常数 8，应使用 immediate form `SRAI`，不是 register form `SRA`。
- C. ✅ 对。signed arithmetic right shift 保留符号位。
- D. ❌ `SLLI` 是左移；正确表述：`d >> 4` 是 `SRLI`。

### Q16. Which are pseudo instructions in RV32I?

A. `Li X1, 0x01ABCDEF`  
B. `Addi X2, X3, 100`  
C. `MV X2, X3`  
D. `J loop_end`  
E. `Call funct`

**Answer:** A, C, D, E

> 位于(notes quiz 1/3_review.md), 解释：review 的 pseudo-instruction table 包含 `li/mv/j/call` 展开；`addi` 是真实 I-type 指令。

**选项解析：**

- A. ✅ 对。`li` 由 assembler 展开为 `lui/addi` 等。
- B. ❌ `addi` 是硬件真实指令。
- C. ✅ 对。`mv` 通常展开为 `addi rd,rs,0`。
- D. ✅ 对。`j label` 通常展开为 `jal x0,label`。
- E. ✅ 对。`call` 是 assembler/linker 处理的伪指令序列。

### Q17. In the shown C function with local `int A[100]`, which store accesses `A[10] = b`?

A. `SW a1, 40(fp)`  
B. `SW a1, -360(fp)`  
C. `SW a0, -360(fp)`  
D. `SB a1, -360(fp)`  
E. `SW a1, -40(fp)`

**Answer:** B

> 位于(notes quiz 1/4_review.md; notes quiz 1/3_review.md), 解释：栈向低地址增长，`int A[100]` 占 400B；若 `A[0]` 在 `fp-400`，`A[10]` 在 `fp-400+40 = fp-360`，参数 `b` 在 `a1`。

**选项解析：**

- A. ❌ 正偏移不符合局部数组在 frame pointer 下方；正确表述：`-360(fp)`。
- B. ✅ 对。`SW` 存 int，源寄存器 `a1` 是 b，偏移 `-360`。
- C. ❌ 源寄存器错，`a0` 是第一个参数/idx；正确表述：存 `a1`。
- D. ❌ `SB` 只存 byte；正确表述：int 用 `SW`。
- E. ❌ `-40(fp)` 不是 `A[10]` 的位置。

### Q18. One 32-bit word is `0x00000033`. What could it be?

A. RV32I instruction `ADD X0,X0,X0`  
B. signed integer 51  
C. ASCII string `"3"`  
D. unsigned integer 51

**Answer:** A, B, C, D

> 位于(notes quiz 1/1_review.md; notes quiz 1/2_review.md; notes quiz 1/3_review.md), 解释：同一 bits 可按不同类型解释；`0x33=51`，低字节 `0x33` 是 ASCII `'3'`，作为 RV32I R-type opcode 可解码为 no-effect add to x0。

**选项解析：**

- A. ✅ 对。`0x00000033` 的 opcode/funct/regs 可解释为 `add x0,x0,x0`，虽然 canonical NOP 是 `addi x0,x0,0`。
- B. ✅ 对。作为 signed 32-bit integer，值为 51。
- C. ✅ 对。作为 byte/char 数据，`0x33` 是字符 `'3'`。
- D. ✅ 对。作为 unsigned 32-bit integer，值同样为 51。

### Q19. Which RV32I instructions use 12-bit immediates?

A. Load instructions  
B. Store instructions  
C. Branch instructions  
D. JALR instructions  
E. AUIPC instructions

**Answer:** A, B, C, D

> 位于(notes quiz 1/3_review.md), 解释：I/S/B 使用 12-bit immediate，JALR 是 I-type；AUIPC 是 U-type 20-bit immediate。

**选项解析：**

- A. ✅ 对。load 是 I-type imm12。
- B. ✅ 对。store 是 S-type split imm12。
- C. ✅ 对。branch 是 B-type imm12 加隐含低位。
- D. ✅ 对。JALR 是 I-type imm12。
- E. ❌ AUIPC 使用 U-type 20-bit immediate。

### Q20. Which RV instructions do not have destination operand `rd`?

A. Branch instructions  
B. Unconditional jump instructions  
C. Store instructions  
D. Privileged/CSR instructions

**Answer:** A, C

> 位于(notes quiz 1/3_review.md), 解释：B-type branch 和 S-type store 没有 `rd`；JAL/JALR 通常有 `rd`，CSR 指令也常有 `rd`。

**选项解析：**

- A. ✅ 对。branch 只读 `rs1/rs2` 并改变 PC。
- B. ❌ JAL/JALR 有 `rd` 保存 link，`rd=x0` 只是特殊丢弃。
- C. ✅ 对。store 读寄存器并写内存，没有 destination register。
- D. ❌ CSR 指令可把旧 CSR 值写入 `rd`；正确表述：不能笼统说无 rd。

### Q21. Which statements about RISC vs CISC are true?

A. RISC is optimized for processor speed  
B. CISC is optimized for compact code size  
C. RISC is optimized for assembly programmers  
D. CISC is optimized for compiler designers

**Answer:** A, B

> 位于(notes quiz 1/3_review.md), 解释：review 对比 RISC fixed/simple/load-store/easier pipeline 与 CISC compact/variable/many memory operands。

**选项解析：**

- A. ✅ 对。RISC 简化硬件和流水线，利于速度。
- B. ✅ 对。CISC 复杂指令/变长编码有利于代码密度。
- C. ❌ RISC 不是为手写汇编优化；正确表述：更利于硬件和编译器生成规则代码。
- D. ❌ CISC 往往让编译/解码更复杂；正确表述：其历史优势是 compact code。

### Q22. Bounds checking `int A[100]`, `idx` in X5 and 100 in X6: which branch sequence works?

A. `BGT X0,X5` and `BLE X6,X5`  
B. `BLT X5,X0` and `BGE X5,X6`  
C. `BGEU X5,X6`  
D. `BLEU X6,X5`

**Answer:** B, C

> 位于(notes quiz 1/3_review.md), 解释：signed 检查需要 `idx < 0` 或 `idx >= 100`；unsigned trick 可用一次 `idx >= 100`，因为负数当 unsigned 会变很大。

**选项解析：**

- A. ❌ 条件方向和边界不如标准写法清晰，`BGT/BLE` 也不是 RV32I 基本 mnemonic；正确表述：用 `BLT idx,0` 和 `BGE idx,100`。
- B. ✅ 对。分别捕获负数和大于等于 100。
- C. ✅ 对。`BGEU idx,100` 同时捕获负数和过大索引。
- D. ❌ `BLEU X6,X5` 是伪/反向写法且边界语义不如 `BGEU X5,X6` 明确；正确表述：使用 `BGEU X5,X6`。

### Q23. In RV32I, what registers should a leaf routine try to utilize?

A. `a0-a7`  
B. `t0-t6`  
C. `s0-s11`  
D. `X28-X31`  
E. `X18-X27`

**Answer:** A, B, D

> 位于(notes quiz 1/4_review.md), 解释：leaf routine 优先 caller-saved `a/t` registers；`X28-X31` 属于 `t3-t6`，`X18-X27` 属于 `s2-s11`。

**选项解析：**

- A. ✅ 对。`a0-a7` caller-saved，leaf 使用通常无额外保存。
- B. ✅ 对。`t0-t6` 是 caller-saved temporaries。
- C. ❌ `s0-s11` 是 callee-saved，修改要保存恢复。
- D. ✅ 对。`X28-X31` 是 `t3-t6`，caller-saved。
- E. ❌ `X18-X27` 是 saved registers，callee-saved。

### Q24. What are disadvantages if RV architecture includes 1024 GPRs?

A. Register access time may take longer  
B. Procedure call overhead increases due to more save/restore  
C. Context switching cost increases  
D. Instruction length may increase  
E. Compiler is more difficult to manage so many registers

**Answer:** A, B, C, D

> 位于(notes quiz 1/3_review.md), 解释：review 的 1024-register discussion 写 slower access、more save/restore/context switch、longer instruction；compiler difficulty 不是 key 选项。

**选项解析：**

- A. ✅ 对。更大 register file 访问更慢，可能拉长 clock。
- B. ✅ 对。调用约定下潜在保存恢复集合更大。
- C. ✅ 对。OS context switch 需要处理更多 architectural state。
- D. ✅ 对。寄存器号需要更多 bits，32-bit 指令格式难以容纳。
- E. ❌ 编译器复杂度可能增加，但课程 key 未把它作为主要 architecture 代价；正确表述：核心问题是硬件/编码/状态成本。

### Q25. Which data types are unlikely to be allocated to registers?

A. Unsigned integers  
B. Multi-dimensional arrays  
C. Strings  
D. Structures  
E. Floating point number variables

**Answer:** B, C, D

> 位于(notes quiz 1/3_review.md; notes quiz 1/4_review.md), 解释：寄存器适合标量；数组、字符串、结构体需要内存布局和地址索引，不能整体放入少数寄存器。

**选项解析：**

- A. ❌ unsigned integer 是标量，适合寄存器。
- B. ✅ 对。多维数组需要连续/分块内存布局。
- C. ✅ 对。字符串是 byte sequence，需要内存地址。
- D. ✅ 对。结构体有字段 layout/alignment，通常在内存中。
- E. ❌ 浮点标量可放 FP register。

## CSC3050 Quiz2-2025.pptx

### Q1. Which standards have been widely adopted in floating-point arithmetic?

A. IEEE 754-1985 for single/double precision  
B. IEEE 754-2008 for quad/half precision  
C. IEEE 754-2024 for FP8 and FP4  
D. IEEE 754-2008 for bfloat16 and FP16

**Answer:** A, B

> 位于(notes quiz 1/2_review.md), 解释：review 写 IEEE 754-1985 定义 fp32/fp64，IEEE 754-2008 增加 fp16/quad；bfloat16/FP8/FP4 是 AI formats，不是 core IEEE。

**选项解析：**

- A. ✅ 对。fp32/fp64 是 IEEE 754-1985 的经典标准。
- B. ✅ 对。half 和 quad 属于 IEEE 754-2008 增补。
- C. ❌ review 不把 FP8/FP4 归为 IEEE 754-2024 core standard；正确表述：它们是 AI mini-float/custom formats。
- D. ❌ FP16 是 IEEE 754-2008，但 bfloat16 不是；正确表述：bfloat16 是 Google/AI 生态格式。

### Q2. What is the value of hexadecimal `0x80000000` as IEEE single precision?

A. `80000000`  
B. `1.0`  
C. `NaN`  
D. `-0.0`  
E. `-2.0`  
F. `0.0`

**Answer:** D — `-0.0`

> 位于(notes quiz 1/2_review.md), 解释：IEEE fp32 中 `0x80000000` 的 sign=1、exp=0、frac=0，因此是 negative zero。NaN 要求 exp 全 1 且 frac 非 0。

> 注意：PPT key 标为 C/NaN，但这与 IEEE 754 review 冲突；这里按 review 修正为 D。

**选项解析：**

- A. ❌ 这是 bit pattern 本身，不是数值解释；正确表述：按 fp32 解释为 `-0.0`。
- B. ❌ `1.0` 是 `0x3F800000`。
- C. ❌ NaN 需要 exponent 全 1 且 fraction 非 0；`0x80000000` 的 exponent/fraction 都是 0。
- D. ✅ 对。sign bit 为 1 的 zero 即 `-0.0`。
- E. ❌ `-2.0` 需要非零 exponent，不是全 0 exponent/fraction。
- F. ❌ 数值比较上 `-0.0 == +0.0`，但 bit-level 表示有 sign=1，应答 `-0.0`。

### Q3. Which decimal numbers have exact IEEE 754 FP representations?

A. 0.1  
B. 0.2  
C. 0.3  
D. 0.5  
E. 0.0625

**Answer:** D, E

> 位于(notes quiz 1/2_review.md), 解释：分母化简后只含因子 2 的小数可被有限二进制精确表示。

**选项解析：**

- A. ❌ `0.1=1/10` 分母含 5，不能有限二进制表示。
- B. ❌ `0.2=1/5` 分母含 5。
- C. ❌ `0.3=3/10` 分母含 5。
- D. ✅ 对。`0.5=1/2`。
- E. ✅ 对。`0.0625=1/16`。

### Q4. What are denormalized numbers?

A. Floating-point numbers too small to fit in normalized format  
B. Floating-point numbers too large to fit  
C. Floating-point numbers not yet normalized  
D. Numbers with exponent 0 and no hidden leading 1

**Answer:** A, D

> 位于(notes quiz 1/2_review.md), 解释：subnormal/denormal 用 exp=0 且没有 hidden leading 1，表示比最小 normalized 更接近 0 的数。

**选项解析：**

- A. ✅ 对。它们处理 underflow 方向的小数。
- B. ❌ 太大时 overflow 到 infinity 或最大有限数，不是 denormal。
- C. ❌ denormal 是正式编码类别，不是“尚未 normalize”的中间状态。
- D. ✅ 对。exp=0 且 significand 不带隐藏 1 是关键编码规则。

### Q5. Project #3 partial-product adder organization is called what?

A. The Prism  
B. The Pagoda  
C. The Pyramid  
D. The Palace  
E. The Paragon

**Answer:** C — The Pyramid

> 位于(未在 *_review.md 中找到直接出处；原 PPT key 标 Answer: 3), 解释：review 只覆盖 multiplier/FMA partial-product reduction 的概念，没有出现 “Pyramid” 这个项目命名；按项目/PPT key，该组织名称为 The Pyramid。

**选项解析：**

- A. ❌ Prism 不是项目中 parallel adder reduction 的名称；正确表述：The Pyramid。
- B. ❌ Pagoda 是干扰项；正确表述：The Pyramid。
- C. ✅ 对。PPT key 指定该 partial-product adder 组织名为 Pyramid。
- D. ❌ Palace 是干扰项。
- E. ❌ Paragon 是干扰项。

### Q6. In Project #3, which RISC-V model are you constructing?

A. RV64I  
B. RV32IM  
C. RV32IF  
D. RV32G

**Answer:** B — RV32IM

> 位于(notes quiz 1/3_review.md), 解释：`M` 是 integer multiply/divide extension；Project #3 语境是构建带乘法器的 RV32I+M。

**选项解析：**

- A. ❌ RV64I 位宽不符。
- B. ✅ 对。RV32IM = 32-bit integer base + multiply/divide。
- C. ❌ F 是 single-precision floating-point，不是该项目重点。
- D. ❌ G 是通用组合扩展集合，超出项目范围。

### Q7. Why is FMAC more accurate than separate FMUL and FADD?

A. Separate FMUL/FADD require two roundings, FMAC one  
B. Separate FMUL/FADD require two normalizations, FMAC one  
C. Data dependencies cause precision loss  
D. Merged operations are always more accurate

**Answer:** A

> 位于(notes quiz 1/2_review.md), 解释：FMA/FMAC fused operation 只在最终 rounding 一次；分离 multiply 和 add 会 round twice。

**选项解析：**

- A. ✅ 对。少一次 rounding error 是精度优势核心。
- B. ❌ normalization 不是本题核心；正确表述：关键是 rounding 次数。
- C. ❌ data dependency 影响性能调度，不直接造成数值精度损失。
- D. ❌ always 太绝对；正确表述：FMA 在 `a*b+c` 语义下通常更准确，因为 fused rounding。

### Q8. Nvidia Blackwell FP4 benefits

A. FP4 can double throughput compared to FP8  
B. FP4 improves power efficiency  
C. FP4 improves prediction accuracy  
D. FP4 reduces memory bandwidth for parameters/activations

**Answer:** A, B, D

> 位于(notes quiz 1/2_review.md), 解释：review 写 FP4 benefits：更高吞吐、更低带宽/存储和能耗；代价是 precision 下降。

**选项解析：**

- A. ✅ 对。位宽更小，同样硬件/带宽可处理更多元素。
- B. ✅ 对。更少 bits 通常降低数据搬运和计算能耗。
- C. ❌ FP4 精度更低，不会天然提高预测准确率；正确表述：它以精度换效率。
- D. ✅ 对。参数和 activation 位宽减小，load/store 带宽需求下降。

### Q9. What do x86 SIMD, RISC-V Vector, and Nvidia GPUs have in common?

A. Support DLP  
B. Perform same operation on multiple data elements  
C. All originated from graphics processing  
D. Suitable for control-intensive tasks  
E. Require high memory bandwidth

**Answer:** A, B, E

> 位于(notes quiz 1/1_review.md; 5_review.md), 解释：SIMD/vector/GPU 共同利用 data-level parallelism，对多数据元素执行同类操作，并需要高数据带宽支撑。

**选项解析：**

- A. ✅ 对。三者都是 DLP 代表。
- B. ✅ 对。SIMD/vector/tensor lanes 都强调 same operation on multiple data。
- C. ❌ GPU 与图形关系强，但 x86 SIMD/RISC-V Vector 并非都源于图形。
- D. ❌ 控制密集任务有分支分歧，不适合 SIMD/GPU；正确表述：适合规则数据并行。
- E. ✅ 对。大量 lanes 需要高 memory bandwidth 供数。

### Q10. Compared to pipelined datapath, single-cycle datapath typically has:

A. Higher throughput  
B. Faster clock rate  
C. More complex control logic  
D. Longer operation latency  
E. Lower CPI

**Answer:** E

> 位于(notes quiz 2/4_1_review.md; notes quiz 2/4_3_review.md), 解释：single-cycle CPI=1；pipeline 理想 CPI≈1 但有 hazard stalls，优势主要是 shorter clock/higher throughput 而非 lower CPI。

**选项解析：**

- A. ❌ single-cycle 不重叠执行，throughput 低。
- B. ❌ single-cycle clock 必须容纳最慢指令，通常更慢。
- C. ❌ single-cycle 控制通常比 pipeline hazard control 简单。
- D. ❌ 单条指令以一个长 cycle 完成；与 pipeline 比，“longer operation latency”不是 key 答案。
- E. ✅ 对。相对有 stalls 的 pipeline，single-cycle CPI 固定为 1。

### Q11. Which statements about single-cycle datapath are true?

A. CPI is 1, every instruction finishes in one cycle  
B. Clock cycle accommodates the slowest instruction  
C. Resources cannot be reused in the same cycle  
D. Result is written back to register file in the same cycle

**Answer:** A, B, C

> 位于(notes quiz 2/4_1_review.md), 解释：single-cycle 的一个 cycle 覆盖完整指令路径，不能跨 cycle 复用资源；并非所有指令都有 register writeback。

**选项解析：**

- A. ✅ 对。这是 single-cycle 定义。
- B. ✅ 对。clock period 由最慢指令路径决定。
- C. ✅ 对。同一个 cycle 内不能让同一硬件分时服务不同阶段。
- D. ❌ store/branch 等不写 register file；正确表述：有写回的指令在同 cycle 完成写回。

### Q12. What hazards decrease pipeline efficiency?

A. Structural hazards  
B. Data hazards  
C. Instruction hazards  
D. Forward hazards  
E. Control hazards

**Answer:** A, B, E

> 位于(notes quiz 2/4_4_review.md), 解释：三类 hazards 是 structural、data、control；forwarding 是解决 data hazard 的方法，不是 hazard 类别。

**选项解析：**

- A. ✅ 对。资源冲突会 stall。
- B. ✅ 对。RAW load-use 等会 stall。
- C. ❌ instruction hazards 不是课程三分法。
- D. ❌ forwarding 是 fix，不是 hazard。
- E. ✅ 对。branch/jump next PC 不确定造成 control hazard。

### Q13. Which implementation may have CPI lower than 1?

A. Single-cycle  
B. Multi-cycle  
C. Pipelined  
D. Superscalar

**Answer:** D

> 位于(notes quiz 2/4_1_review.md), 解释：CPI<1 需要 multi-issue/superscalar。

**选项解析：** A ❌ CPI=1；B ❌ CPI>1；C ❌ single-issue pipeline 理想 CPI≈1；D ✅ 多发射可 CPI<1。

### Q14. Key principles of pipelined datapath design

A. Multi-stage execution  
B. Increased throughput  
C. Overlapped execution  
D. Lowered instruction latency  
E. Improved resource utilization

**Answer:** A, B, C, E

> 位于(notes quiz 2/4_3_review.md), 解释：pipeline 把执行分阶段并重叠多条指令，提升吞吐和资源利用；不保证降低单条指令 latency。

**选项解析：** A ✅ 分阶段；B ✅ 吞吐提升；C ✅ 重叠执行；D ❌ 单条 latency 通常不降低；E ✅ 各阶段资源并行工作。

### Q15. What might occur if pipeline stages double from 5 to 10?

A. Clock rate might become faster  
B. Branch misprediction penalty becomes higher  
C. Data hazard penalty might increase  
D. Throughput is likely to increase  
E. More pipeline registers are required

**Answer:** A, B, C, D, E

> 位于(notes quiz 2/4_3_review.md; notes quiz 2/4_4_review.md), 解释：更深 pipeline 缩短 stage delay 但增加 pipeline register、branch/data hazard penalty。

**选项解析：** A ✅ stage 变短可能提频；B ✅ flush 更多级；C ✅ bypass/stall 距离变复杂；D ✅ 若 hazards 可控，吞吐可能增；E ✅ stage 更多需要更多 pipeline registers。

### Q16. What strategies reduce stalls caused by data hazards?

A. Increase pipeline stages  
B. Data forwarding  
C. Add multiple functional units  
D. Compiler instruction scheduling  
E. Branch prediction

**Answer:** B, D

> 位于(notes quiz 2/4_4_review.md; notes quiz 2/4_5_review.md), 解释：data hazard fixes include forwarding/bypass and compiler scheduling；branch prediction is for control hazard。

**选项解析：** A ❌ 深流水反而可能加重；B ✅ 硬件 bypass；C ❌ 多功能单元主要解 structural/throughput，不解决 RAW；D ✅ 重排填 bubbles；E ❌ 控制冒险技术。

### Q17. Branch prediction should be performed at which stage?

A. WB  
B. ID  
C. EXE  
D. IF  
E. MEM

**Answer:** D — IF

> 位于(notes quiz 2/4_4_review.md), 解释：预测要在 IF 给 next PC。

**选项解析：**

- A. ❌ WB 太晚，分支都快完成了；正确表述：预测必须在取指前后立即产生 next PC。
- B. ❌ ID 已经晚一拍，不能让下一周期及时取到预测路径。
- C. ❌ EXE 是许多简单流水线解析分支的阶段，但这属于实际 resolve，不是 prediction 的最佳位置。
- D. ✅ 对。IF 阶段预测方向/目标，才能持续供给取指。
- E. ❌ MEM 更晚，只会扩大 control-hazard penalty。

### Q18. Which are architecture states?

A. BHT  
B. BTB  
C. General-purpose registers  
D. PC  
E. Pipeline registers

**Answer:** C, D

> 位于(notes quiz 1/3_review.md; notes quiz 2/4_3_review.md), 解释：architectural state 是软件可见状态，如 GPR 和 PC；BHT/BTB/pipeline registers 是 microarchitectural state。

**选项解析：** A ❌ predictor；B ❌ predictor target cache；C ✅ GPR；D ✅ PC；E ❌ pipeline temporary state。

### Q19. `CPU Time = Inst count * CPI * Clock cycle time`: which statements are true?

A. SIMD/Vector can reduce instruction count  
B. Pipeline processors reduce clock cycle time  
C. Multi-cycle datapaths reduce clock cycle time  
D. Superscalar processors reduce CPI  
E. FMA reduces all three parameters

**Answer:** A, B, C, D

> 位于(notes quiz 2/4_1_review.md; notes quiz 2/4_3_review.md; notes quiz 1/2_review.md), 解释：SIMD/FMA 可减少 instruction count；pipeline/multicycle 缩短 clock；superscalar 降低 CPI；FMA 不保证三项全降。

**选项解析：** A ✅ 一条向量指令处理多数据；B ✅ stage 缩短 critical path；C ✅ 多周期拆短 clock；D ✅ 多发射降低 CPI；E ❌ FMA 不必然同时降低 CPI 和 clock。

### Q20. Linked-list traversal stalls occur because of:

A. Structural hazards  
B. Date hazards  
C. Data hazards  
D. Control hazards

**Answer:** C

> 位于(notes quiz 2/4_4_review.md; notes quiz 2/6_review.md), 解释：linked-list pointer chase 是 load-use chain，主要是 data hazard/latency-bound。

**选项解析：** A ❌ 不是资源冲突；B ❌ 拼写干扰项；C ✅ next pointer 依赖前次 load；D ❌ 该题按 review 强调 data hazard，loop branch 通常可预测。

### Q21. Which integer adder can provide one-cycle latency?

A. Ripple-carry adder  
B. One's complement adder  
C. Carry-Lookahead (CLA) adder  
D. Quantum adder

**Answer:** C

> 位于(notes quiz 1/2_review.md), 解释：CLA 通过并行 carry generate/propagate 缩短进位链。

**选项解析：** A ❌ carry 串行传播较慢；B ❌ 数制/补码形式不是高速加法器结构；C ✅ CLA；D ❌ 非课程硬件。

### Q22. Effective static branch predictions

A. Predict backward branch taken  
B. Predict forward branch not taken  
C. Predict `beq rs1,x0` not taken  
D. Predict `blt` instructions taken

**Answer:** A, B, C

> 位于(notes quiz 2/4_4_review.md), 解释：review 的 static rules：backward taken、forward not-taken、`beq rs1,x0` not-taken；不能说所有 `blt` taken。

**选项解析：** A ✅ loop 常 backward taken；B ✅ forward if 常 not taken；C ✅ review 明确列出；D ❌ `blt` 是否 taken 依赖数据。

### Q23. Which are NOT techniques used to address control hazards?

A. Pipeline stalls  
B. BTB  
C. Branch prediction  
D. Data forwarding

**Answer:** D

> 位于(notes quiz 2/4_4_review.md), 解释：data forwarding 是 data hazard fix；stall/BTB/branch prediction 都可处理 control hazard。

**选项解析：** A ❌ stall 可处理控制冒险；B ❌ BTB 预测目标；C ❌ branch prediction 预测方向；D ✅ 不是 control-hazard 技术。

### Q24. What parallelism is exploited by compiler code scheduling?

A. DLP  
B. TLP  
C. ILP  
D. MLP

**Answer:** C — ILP

> 位于(notes quiz 2/4_5_review.md), 解释：code scheduling 重排独立指令来填补 stall，利用 instruction-level parallelism。

**选项解析：** A ❌ 数据并行；B ❌ 线程并行；C ✅ 指令级并行；D ❌ memory-level parallelism。

### Q25. What indexes correlated branch prediction table?

A. PC  
B. Branch target address  
C. Top of return address stack  
D. Global branch history

**Answer:** A, D

> 位于(notes quiz 2/4_4_review.md), 解释：correlated predictor 用 PC 与 global history 共同索引。

**选项解析：** A ✅ branch identity；B ❌ target 用于 BTB；C ❌ RAS 用于 return；D ✅ correlated history。

### Q26. A 32-bit memory word entirely of 1s could mean what?

A. Signed integer -1  
B. Unsigned integer `2^31-1`  
C. Single precision FP -1.0  
D. NaN in single precision FP  
E. Pointer to highest address in 4GB space

**Answer:** A, D, E

> 位于(notes quiz 1/2_review.md; notes quiz 1/3_review.md), 解释：all ones as two's complement = -1；fp32 exp all ones and frac nonzero = NaN；as address bits = `0xFFFFFFFF` highest 32-bit address.

**选项解析：**

- A. ✅ 对。32-bit all ones 按 two's complement 解释就是 signed integer `-1`。
- B. ❌ 错。unsigned all ones 是 `2^32-1`，不是 `2^31-1`；正确表述：它可表示 unsigned `4294967295`。
- C. ❌ 错。fp32 `-1.0` 是 `0xBF800000`，不是 all ones。
- D. ✅ 对。fp32 exponent 全 1 且 fraction 非 0 表示 NaN；all ones 满足这个条件。
- E. ✅ 对。若把同一 bit pattern 解释为 32-bit address，它是 `0xFFFFFFFF`，即 4GB 地址空间最高地址。

### Q27. A 32-bit memory word all 0s could mean what?

A. Signed integer 0  
B. Single precision FP 0.0  
C. Denormalized number  
D. NULL pointer  
E. NOP instruction on RISC-V

**Answer:** A, B, D

> 位于(notes quiz 1/2_review.md; notes quiz 1/3_review.md), 解释：all-zero bits 可为 integer 0、fp +0、NULL；denormal 需要 frac 非 0；RISC-V all-zero 32-bit instruction is illegal, canonical NOP is `0x00000013`。

**选项解析：**

- A. ✅ 对。整数全 0 按 signed/unsigned 解释都是 0。
- B. ✅ 对。IEEE fp32 exponent=0 且 fraction=0 是 zero；sign=0 时为 `+0.0`。
- C. ❌ 错。denormal/subnormal 要 exponent=0 且 fraction 非 0；正确表述：全 0 是 zero，不是 denormal。
- D. ✅ 对。常见 ABI/系统把空指针表示为全 0 bit pattern。
- E. ❌ 错。RISC-V canonical NOP 是 `addi x0,x0,0`，编码 `0x00000013`；全 0 是 illegal instruction。

### Q28. Saturation arithmetic is useful for which data?

A. Floating point  
B. Audio processing  
C. Video processing  
D. Quantized AI data  
E. Text data

**Answer:** B, C, D

> 位于(notes quiz 1/2_review.md), 解释：saturation arithmetic 常用于音视频和量化整数数据，避免 overflow wraparound。

**选项解析：**

- A. ❌ 错。floating point 有 IEEE overflow、NaN、infinity 和 rounding 语义；正确表述：饱和算术主要服务整数/定点信号。
- B. ✅ 对。audio sample 溢出时 clamp 到最大/最小值，比 wraparound 更符合信号处理需求。
- C. ✅ 对。pixel 颜色通道通常限制在固定范围内，例如 0-255，适合 saturation。
- D. ✅ 对。quantized AI data 常用低位整数范围，饱和可避免溢出回绕破坏数值含义。
- E. ❌ 错。text data 是编码符号序列，不是需要数值饱和的信号。

### Q29. In RV32I pipelined datapath, which stage requires two adders?

A. ID  
B. IF  
C. EXE  
D. MEM  
E. WB

**Answer:** C — EXE

> 位于(notes quiz 2/4_3_review.md; notes quiz 2/4_2_review.md), 解释：EXE 阶段可能同时涉及 ALU 结果/地址计算和 branch target 相关加法路径。

**选项解析：**

- A. ❌ ID 主要做 decode/register read/immediate generation，不是该题图中两个 adder 的阶段。
- B. ❌ IF 常有 `PC+4` adder，但不是同时需要两类 adder 的阶段。
- C. ✅ 对。EXE 既可能进行 ALU/地址计算，也涉及 branch target 相关加法路径。
- D. ❌ MEM 主要访问数据存储器，不需要两个 adder。
- E. ❌ WB 主要选择并写回结果，不进行两个加法计算。

### Q30. Which implementations are not suitable for vanilla Von Neumann architecture?

A. Single-cycle datapath  
B. Multi-cycle datapath  
C. Pipelined datapath  
D. Superscalar datapath

**Answer:** A, C, D

> 位于(notes quiz 2/4_4_review.md), 解释：vanilla Von Neumann unified memory 会让 instruction fetch 和 data access 冲突；multi-cycle 可分周期复用，single/pipeline/superscalar 更需要并行 I/D bandwidth。

**选项解析：** A ✅ 同 cycle 取指+访存冲突；B ❌ 可多周期复用统一 memory；C ✅ IF/MEM 同时需要；D ✅ 多发射更不适合单一 memory。

### Q31. Advantages of untagged BHT

A. Simple  
B. Fast  
C. Less energy  
D. Good for high-performance microprocessors  
E. Low cost

**Answer:** A, B, C, E

> 位于(notes quiz 2/4_4_review.md), 解释：untagged BHT 面积小、访问快、能耗低，但 aliasing 多，不是高性能精度优势。

**选项解析：**

- A. ✅ 对。不存 tag，BHT 表项更小，面积开销低。
- B. ✅ 对。少一次 tag 比较/匹配，访问路径更短。
- C. ✅ 对。存储和比较逻辑少，能耗通常更低。
- D. ❌ 错。untagged BHT aliasing 更多，容易让不同分支污染同一项；正确表述：高性能设计通常愿意花面积减少 aliasing、提高预测准确率。
- E. ✅ 对。面积、能耗和控制逻辑都更低，适合低成本实现。

### Q32. Which control signals must propagate to WB stage?

A. Rd  
B. WRen  
C. WBsel  
D. BReq

**Answer:** A, B, C

> 位于(notes quiz 2/4_3_review.md), 解释：MEM/WB 需要 `rd`、RegWr/WRen 和 WBSel；branch request 不需要到 WB。

**选项解析：** A ✅ 写回目标；B ✅ 写回使能；C ✅ 写回数据选择；D ❌ 分支控制不属于 WB。

### Q33. RISC-V regular fixed/simple format is suitable for which implementations?

A. Single-cycle  
B. Multi-cycle  
C. Pipelined  
D. Superscalar

**Answer:** A, C, D

> 位于(notes quiz 1/3_review.md; notes quiz 2/4_1_review.md), 解释：固定长度、规则格式、简单 load/store 特别利于 single-cycle 控制、pipeline decode/hazard logic、superscalar decode/issue。

**选项解析：** A ✅ 控制简单；B ❌ multi-cycle 不是该题 key 强调的主要收益；C ✅ pipeline 友好；D ✅ superscalar decode/issue 友好。

### Q34. A basic block has 50 instructions; how many legal schedules are possible?

A. Best case, 1 schedule only  
B. 50  
C. Worst case, 50! schedules  
D. Less than 50x50

**Answer:** A, C

> 位于(notes quiz 2/4_5_review.md), 解释：完全串行依赖时 topological order 只有 1 个；完全独立时任意排列均合法，共 `50!`。

**选项解析：** A ✅ 全依赖链；B ❌ 不是一般公式；C ✅ 全独立；D ❌ `50!` 远大于 `50*50`。

### Q35. Compiler scheduling limitations

A. Scheduling is error-prone  
B. Memory dependencies may be unknown due to aliasing  
C. Scope limited by frequent branches  
D. Users do not want to pay for optimizations

**Answer:** B, C

> 位于(notes quiz 2/4_5_review.md; 5_review.md), 解释：compiler scheduling limits include memory aliasing and reduced scope from branches/calls/traps/volatile。

**选项解析：** A ❌ 不是技术约束；B ✅ aliasing 阻止安全重排；C ✅ basic block/control-flow 边界限制调度；D ❌ 非课程技术原因。

### Q36. Binary tree search on pipeline: likely hazards?

A. Tree hazards  
B. Structure hazards  
C. Data hazards  
D. Control hazards  
E. Divergence hazards

**Answer:** C, D

> 位于(notes quiz 2/4_4_review.md), 解释：binary-tree search = pointer load-use data hazard + branch on key compare control hazard。

**选项解析：** A ❌ 非课程分类；B ❌ 非主要资源冲突；C ✅ pointer 依赖；D ✅ 比较分支；E ❌ 不是本课程流水线 hazard 名称。

### Q37. Why use a comparison unit for branch-and-compare?

A. It could be faster than subtraction  
B. Avoid wrong taken/not-taken due to subtraction overflow  
C. ALU is needed for R-type and load/store instructions  
D. Comparison operation does not trap

**Answer:** A, B, C

> 位于(notes quiz 2/4_1_review.md; notes quiz 2/4_4_review.md), 解释：专门 comparator 可缩短路径、避免 subtract overflow 误判，并减轻 ALU 资源/路径压力。

**选项解析：** A ✅ comparator 可更短；B ✅ 核心正确性理由；C ✅ 可分离 ALU 用途；D ❌ trap 不是采用 comparator 的主要理由。

## CSC3050 Quiz4.pptx

### Q1. In computer architecture, what is the “memory wall”?

A. The gap between disk and memory  
B. The gap between DRAM and SRAM  
C. The gap between registers and L1 data cache  
D. The gap between CPU and main memory (DRAM)

**Answer:** D

> 位于(notes quiz 2/6_review.md), 解释：memory wall 指 processor speed 与 main memory/DRAM latency-bandwidth 之间的差距。

**选项解析：** A ❌ disk-memory 是 storage hierarchy/I/O 问题；B ❌ DRAM-SRAM 是层级内部差距；C ❌ register-L1 不是 memory wall；D ✅ CPU-DRAM gap。

### Q2. Which information is stored in the cache?

A. Cache block data  
B. Set number  
C. Valid bit  
D. Address tag  
E. Dirty bit

**Answer:** A, C, D, E

> 位于(notes quiz 2/6_review.md), 解释：cache line = valid + tag + data；write-back cache 还需要 dirty bit；set number 是地址 index，不存在线里。

**选项解析：** A ✅ 数据本体；B ❌ set 由位置/地址 index 隐含；C ✅ 判断 line 是否有效；D ✅ 判断是否命中；E ✅ write-back 需要标记是否被修改。

### Q3. How do we give programmers large, fast, cheap memory?

A. Memory hierarchy  
B. Predictions  
C. Virtual memory  
D. Virtual machines  
E. Vector architectures

**Answer:** A, C

> 位于(notes quiz 2/6_review.md; notes quiz 1/1_review.md), 解释：memory hierarchy 提供 fast+large+cheap 的性能/成本抽象；virtual memory 提供大且私有的地址空间抽象。

**选项解析：** A ✅ 层次结构组合快/大/便宜；B ❌ prediction 不增加容量；C ✅ 虚拟内存给出大地址空间抽象；D ❌ VM 不是该内存错觉核心；E ❌ vector 提升数据并行，不提供大内存抽象。

### Q4. In a memory hierarchy, which layers are managed by compiler/programmers?

A. Registers  
B. L1/L2/L3 caches  
C. Local memory  
D. Physical memory

**Answer:** A, C

> 位于(notes quiz 2/6_review.md; 5_review.md), 解释：register allocation 和 local/shared memory 可由 compiler/programmer 管理；cache 由硬件管理，physical memory 由 OS/hardware 管理。

**选项解析：** A ✅ 编译器分配寄存器；B ❌ cache placement/replacement 是硬件；C ✅ local/shared memory 常显式管理；D ❌ physical memory 是 OS/MMU 层。

### Q5. Cache size 64KB, line size 64B. Which statements are correct?

A. Direct-mapped cache has 1024 sets  
B. Two-way set associative cache has two sets  
C. Fully associative cache has one set  
D. Eight-way set associative cache has 8 sets

**Answer:** A, C

> 位于(notes quiz 2/6_review.md), 解释：sets `S = C/(E*B)`；direct-mapped `E=1`，fully associative `S=1`。

**选项解析：** A ✅ `64KB/64B=1024` sets；B ❌ two-way sets = `1024/2=512`；C ✅ fully associative 只有 1 set；D ❌ eight-way sets = `1024/8=128`。

### Q6. Which cache may not have tag bits in practice?

A. Instruction cache  
B. L3 cache  
C. Branch prediction table  
D. TLB

**Answer:** C

> 位于(notes quiz 2/6_review.md; notes quiz 2/4_4_review.md), 解释：BHT/PHT 可做 untagged indexed table；普通 cache/TLB 需要 tag 判断命中。

**选项解析：** A ❌ I-cache 仍要 tag；B ❌ L3 必须 tag；C ✅ branch prediction table 可不带 tag；D ❌ TLB 需要 VPN/ASID tag。

### Q7. Same cache size and line size: which are always true?

A. Direct-mapped cache is faster than set-associative  
B. Fully associative cache has lowest miss rate  
C. Direct-mapped cache has lowest tag overhead  
D. Replacement in direct-mapped cache is simplest

**Answer:** C, D

> 位于(notes quiz 2/6_review.md), 解释：DM has lowest tag overhead + simplest replacement；hit time/miss rate 不能用 always 绝对化。

**选项解析：** A ❌ 具体实现决定，不能 always；B ❌ fully associative 减少 conflict 但不保证所有序列最低 miss；C ✅ tag overhead 最低；D ✅ 只有一个 way，无替换选择。

### Q8. Why is I-cache easier to manage than D-cache?

A. It does not need dirty bit  
B. It does not need valid bit  
C. It does not handle CPU writes  
D. It does not need tag bits

**Answer:** A, C

> 位于(notes quiz 2/6_review.md), 解释：I-cache 不接收 CPU store，因此没有 write policy/dirty bit；仍需要 valid/tag。

**选项解析：** A ✅ 无 CPU 写入则无需 dirty；B ❌ 仍需 valid；C ✅ 只取指不 store；D ❌ 仍需 tag 判断命中。

### Q9. If minimizing tag space is primary, which features should be used?

A. Set-associative caches  
B. Direct-mapped caches  
C. Write no-allocate policy  
D. Large cache blocks  
E. Inclusive caches

**Answer:** B, D

> 位于(notes quiz 2/6_review.md), 解释：direct-mapped metadata/ways 少；large line 减少 line 数，从而减少 tag 数量。

**选项解析：** A ❌ associativity 增加 tag comparators/metadata；B ✅ tag overhead 低；C ❌ 写分配策略不减少 tag 数；D ✅ line 大则 line/tag 数少；E ❌ inclusion policy 不是 tag-space 优化手段。

### Q10. Which statements about L1/L2/L3 caches are true?

A. L3 reduces memory traffic to memory  
B. L1 aims for fast hit time  
C. L3 should use write-through  
D. L2 is always multiple times larger than L1

**Answer:** A, B

> 位于(notes quiz 2/6_review.md), 解释：L1 目标 fast hit；LLC/L3 目标减少 DRAM traffic；低层级 cache 通常不适合 write-through 的高流量。

**选项解析：** A ✅ L3/LLC 过滤 DRAM 访问；B ✅ L1 命中时间最关键；C ❌ write-through 会增加下级流量；D ❌ always 过绝对。

### Q11. What are the four types of cache misses?

A. Compulsory, Conflict, Capacity, Coherence  
B. Cold, Collision, Capacity, Coherence  
C. Combined, Conformant, Contiguous, Conditional  
D. Cool, Conflict, Inclusive, Exclusive

**Answer:** A, B

> 位于(notes quiz 2/6_review.md), 解释：review 写 4 C's = compulsory, conflict, capacity, coherence；cold≈compulsory，collision≈conflict。

**选项解析：** A ✅ 标准名称；B ✅ 同义名称组合；C ❌ 干扰项；D ❌ inclusive/exclusive 是 cache inclusion policy，不是 miss type。

### Q12. Advantages of large cache line size

A. Exploits more spatial locality  
B. Exploits more temporal locality  
C. Saves tag space  
D. Could reduce compulsory misses

**Answer:** A, C, D

> 位于(notes quiz 2/6_review.md), 解释：larger line helps spatial locality、tag overhead、compulsory misses；不提升 temporal locality，且会增加 bandwidth/miss penalty。

**选项解析：** A ✅ 带入相邻字节；B ❌ temporal 是重复访问同一数据；C ✅ line 数少 tag 少；D ✅ 一次 miss 带入后续相邻数据。

### Q13. Advantages of splitting L1 into L1I and L1D

A. Higher hit rate  
B. Greater access bandwidth  
C. I-cache can be managed differently from D-cache  
D. Higher associativity

**Answer:** B, C

> 位于(notes quiz 2/6_review.md; notes quiz 2/4_4_review.md), 解释：split L1I/L1D 提高取指和数据访问并行带宽，并允许 I-cache 无写策略/dirty bit；不是为了 hit rate/associativity。

**选项解析：** A ❌ 主因不是 hit rate；B ✅ IF 和 MEM 可并行；C ✅ I/D 写策略不同；D ❌ split 不等于 associativity 更高。

### Q14. Weakness of Cray vector supercomputers without data caches

A. No memory spatial locality  
B. No memory temporal locality  
C. Instruction fetching much slower  
D. Cannot exploit localities for languages with extensive pointer aliasing

**Answer:** D

> 位于(notes quiz 2/6_review.md; 5_review.md), 解释：cache 对 irregular/pointer-heavy locality 更自适应；vector loads/stores 擅长规则流式访问，不擅长大量 pointer aliasing。

**选项解析：** A ❌ vector load/store 可利用规则 spatial locality；B ❌ 不应绝对说没有 temporal locality；C ❌ 问题在 data cache/locality，不是 instruction fetch；D ✅ 指针别名/不规则访问是弱点。

### Q15. 2-way 4KB cache, 32B line: which sequence causes conflict misses?

A. `0x01ABC000, 0x01ABC004, 0x01ABC010, 0x01ABC002`  
B. `0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010`  
C. `0x01ABC000, 0x01ABC020, 0x01ABC030, 0x01ABC040`  
D. `0x01ABC020, 0x01ABC030, 0x01ABC02A, 0x01ABC03A`

**Answer:** B

> 位于(notes quiz 2/6_review.md), 解释：4KB、2-way、32B line → `S=4096/(2*32)=64`，同一 set 超过 2 个不同 blocks 会 conflict。

**选项解析：** A ❌ 都在同一/邻近 block，不超过 way；B ✅ 多个不同 blocks 映射同一 set；C ❌ 分布到相邻 sets/blocks，未超 2-way；D ❌ 多数在同一 block，不构成多 block 冲突。

### Q16. When turn on write-no-allocate?

A. Large `memcpy(a,b,n)`  
B. Storing local variables  
C. Storing struct member  
D. Large `memset(a,b,n)`

**Answer:** A, D

> 位于(notes quiz 2/6_review.md), 解释：no-write-allocate 适合 streaming writes，绕过 cache；局部变量/结构成员通常有近期复用。

**选项解析：** A ✅ large copy streaming；B ❌ local variables 可能复用；C ❌ struct member 可能复用/局部性；D ✅ large memset streaming writes。

### Q17. Which cache features require greater bus/memory bandwidth?

A. Large cache lines  
B. Cache prefetching  
C. Non-blocking caches  
D. Exclusive multi-level write-back caches  
E. Write-through caches

**Answer:** A, B, C, E

> 位于(notes quiz 2/6_review.md), 解释：review 写 bandwidth-heavy features: large lines, prefetch, non-blocking, write-through。

**选项解析：** A ✅ 每次 miss 传更多 bytes；B ✅ 额外预取流量；C ✅ 多个 outstanding misses 需要并发带宽；D ❌ exclusive/write-back 不必然增加写穿流量；E ✅ 每次写都推向下级。

### Q18. Single-cycle datapath, D-cache miss 5%, 40% load/store, memory latency 100 cycles. Average CPI?

A. 2.0  
B. 1.4  
C. 1.6  
D. 3.0

**Answer:** D — 3.0

> 位于(notes quiz 2/6_review.md), 解释：`CPI = 1 + 0.40 * 0.05 * 100 = 3.0`。

**选项解析：** A ❌ 少算；B ❌ 只像加了 `0.4`；C ❌ 不是该公式；D ✅。

### Q19. Why has AMAT become less accurate recently?

A. Misses are rare and can be ignored  
B. Non-blocking caches overlap multiple misses  
C. AMAT was designed only for single-level cache  
D. OoO hides part of miss penalty

**Answer:** B, D

> 位于(notes quiz 2/6_review.md), 解释：AMAT 线性模型不包含 miss overlap；OoO 和 non-blocking cache 可隐藏/重叠 miss penalty。

**选项解析：** A ❌ misses 不能简单忽略；B ✅ overlap 不在传统 AMAT；C ❌ AMAT 可扩展到多级 local miss rates；D ✅ OoO latency hiding。

### Q20. Which statement about snoopy cache is true?

A. Maintains coherence for bus-connected multiprocessors  
B. Watchdog for illegal cache references  
C. Data security enforcement  
D. Peeking data in neighbor caches

**Answer:** A

> 位于(notes quiz 2/6_review.md), 解释：snoopy cache 监听共享总线以维护 private caches 的 coherence。

**选项解析：** A ✅ coherence；B ❌ 不是安全 watchdog；C ❌ 不是安全机制；D ❌ snoop 不是偷看数据语义。

### Q21. What reduces conflict misses in direct-mapped L1?

A. Increase cache size  
B. Increase cache line size  
C. Add victim cache  
D. Change to set-associative  
E. Use best replacement algorithm

**Answer:** A, C, D

> 位于(notes quiz 2/6_review.md), 解释：conflict miss 可用更大 cache、victim cache、associativity/padding/code reposition 缓解；direct-mapped 没有 replacement choice。

**选项解析：** A ✅ set 数增加；B ❌ 大 line 可能加重 conflict；C ✅ victim cache 接住被驱逐 line；D ✅ associativity 允许同 set 多 blocks；E ❌ direct-mapped 无替换算法选择。

### Q22. What is useful in reducing capacity misses?

A. Increase cache size  
B. Increase line size  
C. Add victim cache  
D. Change to set-associative  
E. Cache prefetching

**Answer:** A, E

> 位于(notes quiz 2/6_review.md), 解释：review 写 reduce capacity: larger cache, prefetching；victim cache/associativity 主要针对 conflict。

**选项解析：** A ✅ 容纳更大 working set；B ❌ 固定容量下 line 大减少 line 数；C ❌ conflict tool；D ❌ conflict tool；E ✅ review 列为 capacity 相关帮助。

### Q23. L3 MSHR entries on multicore chip are influenced by what?

A. Memory latency  
B. Memory bus width  
C. Size of L2 cache  
D. Number of cores sharing L3

**Answer:** A, B (按 review；PPT key 标 A, B, D)

> 位于(notes quiz 2/6_review.md), 解释：review 明确写 “L3 MSHR count depends on mem latency + bus width. NOT L2 size, NOT cores sharing L3”。

**选项解析：** A ✅ latency 越大，需更多 outstanding misses 才能覆盖等待；B ✅ bus width/bandwidth 决定可并发服务能力；C ❌ review 明确 NOT L2 size；D ❌ PPT key 标了 D，但 review 明确写 NOT cores sharing L3，因此按 review 不选。

### Q24. JIT/instruction patching: which I-cache solutions work?

A. Flush I-cache  
B. Invalidate I-cache lines containing instructions  
C. Flush data caches  
D. Maintain I/D cache coherence

**Answer:** A, B, D

> 位于(notes quiz 2/6_review.md), 解释：JIT/self-modifying code 需要 flush I-cache、invalidate affected I-cache lines，或维护 I-D coherence；只 flush D-cache 不清除旧指令。

**选项解析：** A ✅ 清掉旧指令；B ✅ 精确 invalidate 修改过的 line；C ❌ 只处理 D-cache 不保证 IF 不读旧 I-cache；D ✅ D-cache 更新同步到 I-cache 可保持一致。
