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

### Q2. Which extension, if absent, would make RISC-V a fixed-length ISA?

A. A extension
B. B extension
C. C extension
D. D extension
E. E extension

**Answer:** 3 = C — C extension

### Q3. Which of the following microarchitectures could have a CPI lower than 1?

A. Single-cycle data path implementation
B. Multi-cycle data path implementation
C. Pipelined implementation
D. Superscalar implementation

**Answer:** 4 = D — Superscalar implementation

### Q4. When comparing the performance of single-cycle, multi-cycle, and pipelined data paths, which statements is correct?

A. Single-cycle > Multi-cycle > Pipelined
B. Pipelined > Multi-cycle > Single-cycle
C. Pipelined > Single-cycle > Multi-cycle
D. Multi-cycle > Pipelined > Single-cycle

**Answer:** 2 = B — Pipelined > Multi-cycle > Single-cycle

### Q5. Frequent pipeline stalls are likely to occur when traversing a long linked list due to

A. Delay hazards
B. Date hazards
C. Data hazards
D. Control hazards

**Answer:** 3 = C — Data hazards

### Q6. Branch prediction should be carried out during which stages of the pipeline?

A. IF
B. ID
C. EXE
D. MEM
E. WB

**Answer:** 1 = A — IF

### Q7. Which of the following functional units is the most difficult to pipeline?

A. Integer multiply
B. Floating point add
C. Floating point multiply
D. Integer divide
E. Fused multiply-and-accumulate (FMAC)

**Answer:** 4 = D — Integer divide

### Q8. A Von Neumann machine is depicted on the right. What is the so-called “Von Neumann bottleneck” in a pipelined data path?

A. It is like a structural hazard
B. It is like a data hazard
C. It is like a control hazard
D. It is like a memory hazard

**Answer:** 1 = A — It is like a structural hazard

### Q9. Which of the following microarchitectures is unlikely to be used by Apple’s M4 processor (i.e., the latest one)?

A. Dynamic branch prediction
B. Pipelined data path
C. Static branch prediction
D. BTB-based prediction

**Answer:** 3 = C — Static branch prediction

### Q10. Which RV32I instruction has the greatest impact on the clock rate of the single-cycle data path?

A. JALR X0, 0(X2)
B. LW X1,4(X2)
C. SLL X1,X2,X3
D. LUI X5, 0x12345

**Answer:** 2 = B — LW X1,4(X2)

### Section II
*(multiple answers)*

### Q11. MIPS (Microprocessor without Interlocked Pipeline Stages) reduces hardware cost by using software to avoid hazards, making the processor cheaper and faster. What was the primary reason for its lack of success?

A. Compatibility and Scalability
B. Non-competitive performance
C. Incompatible with x86
D. John Hennessy was too occupied.

**Answer:** 1 = A — Compatibility and Scalability

### Q12. In which cases should callee-saved registers be considered for allocation?

A. Leaf routines
B. A temporary value used heavily across multiple calls
C. Temporaries in expression evaluation
D. C Strings
E. Local variables

**Answer:** 2,5 = B — A temporary value used heavily across multiple calls; E — Local variables

### Q13. Which of the following is a common hardware technique to reduce the penalty of data hazards?

A. Data forwarding
B. A deeper pipeline
C. Data Bypassing
D. Compiler code scheduling

**Answer:** 1,3 = A — Data forwarding; C — Data Bypassing

### Q14. Most modern microprocessors have split I/D caches. Why?

A. To avoid structural hazards in the pipeline
B. To get a higher cache hit rate
C. To increase reliability
D. To increase the cache access bandwidth

**Answer:** 1,4 = A — To avoid structural hazards in the pipeline; D — To increase the cache access bandwidth

### Q15. Compared to a pipelined data path, a single-cycle data path typically has:

A. Higher throughput
B. Faster clock rate
C. Simple control logic
D. A longer instruction latency
E. A lower CPI

**Answer:** 3,5 = C — Simple control logic; E — A lower CPI

### Q16. Function A calls function B. In function A, three registers live across the call to B: $s1, $t0, and $a1. What registers must be saved/restored across the call?

A. $s1
B. $t0
C. $a1
D. None of them

**Answer:** 2,3 = B — $t0; C — $a1

### Q17. What are the essential principles of designing a pipelined datapath?

A. Multi-stage partitioning
B. Overlapped execution
C. Increased throughput
D. Lowered instruction latency
E. Improved resource utilization

**Answer:** 1,2,3,5 = A — Multi-stage partitioning; B — Overlapped execution; C — Increased throughput; E — Improved resource utilization

### Q18. Which of the following are techniques used to reduce the penalty caused by control hazards?

A. Pipeline stalls
B. BTB (Branch Target Buffer)
C. BHT (Branch History Table)
D. Data Bypassing
E. Data forwarding

**Answer:** 2,3 = B — BTB (Branch Target Buffer); C — BHT (Branch History Table)

### Q19. What (HW/SW) strategies can reduce pipeline stalls caused by data hazards?

A. Deeper pipeline
B. Data forwarding
C. Out-of-Order instruction execution
D. Compiler instruction scheduling
E. Branch prediction

**Answer:** 2,3,4 = B — Data forwarding; C — Out-of-Order instruction execution; D — Compiler instruction scheduling

### Q20. Which of the following are considered “Microarchitecture states”?

A. BHT
B. BTB
C. Floating-point registers
D. PC
E. Pipelined registers

**Answer:** 1,2,5 = A — BHT; B — BTB; E — Pipelined registers

### Q21. In practice, what might occur if we increase the number of pipeline stages from 5 to 20?

A. The clock rate becomes 4X faster
B. The branch misprediction penalty would increase
C. The data hazard penalty would increase
D. The CPI would increase
E. More pipelined registers will be required

**Answer:** 2,3,4,5 = B — The branch misprediction penalty would increase; C — The data hazard penalty would increase; D — The CPI would increase; E — More pipelined registers will be required

### Q22. What information is used to index a branch prediction table in correlated branch prediction (also known as 2-level adaptive branch prediction)?

A. Current PC
B. Branch instruction address
C. PC+4
D. Global branch history

**Answer:** 1,4 = A — Current PC; D — Global branch history

### Q23. Which of the following could be effective for static branch predictions?

A. Predict a backward branch taken
B. Predict a forward “beq  rs1, x0” not taken
C. Predict the “beq  rs1, rs2” not taken
D. Predict the blt instructions taken
E. Predict the JALR instruction not taken

**Answer:** 1,2 = A — Predict a backward branch taken; B — Predict a forward “beq  rs1, x0” not taken

### Q24. Why is a BHT (Branch History Table) usually untagged?

A. Simple
B. Fast access
C. Consume less energy
D. Good for high-performance microprocessors
E. Cost-effective

**Answer:** 1,2,3,5 = A — Simple; B — Fast access; C — Consume less energy; E — Cost-effective

### Q25. Which of the following control signals must be propagated through the pipelined registers to the WB stage?

A. Rd (target register)
B. WRen (write-enable)
C. WBsel (Write back selection)
D. ALUctl (ALU control)

**Answer:** 1,2,3 = A — Rd (target register); B — WRen (write-enable); C — WBsel (Write back selection)

### Q26. Which of the following statements about single-cycle data path implementation is true?

A. CPI is 1, every instruction must finish in one cycle
B. The clock cycle must accommodate the slowest instruction
C. The resources in the data path cannot be reused in the same cycle
D. The result is written back to the register file in the same clock cycle.

**Answer:** 1,2,3 = A — CPI is 1, every instruction must finish in one cycle; B — The clock cycle must accommodate the slowest instruction; C — The resources in the data path cannot be reused in the same cycle

### Q27. A basic block has 50 instructions; how many legal schedules are possible?

A. In the best case, there is only one schedule
B. In the best case, there are 50 legal schedules
C. In the worst case, there are 50! possible schedules
D. It is quadratic; the worst case has 50² schedules

**Answer:** 1,3 = A — In the best case, there is only one schedule; C — In the worst case, there are 50! possible schedules

### Q28. A compiler can reorder instructions to avoid data hazards. However, what limitations does it often encounter?

A. Code scheduling is error-prone
B. Memory dependencies may not be known due to possible memory aliasing
C. Structural hazards are hard to deal with
D. Memory operation latencies are unknown and non-deterministic

**Answer:** 2,4 = B — Memory dependencies may not be known due to possible memory aliasing; D — Memory operation latencies are unknown and non-deterministic

### Q29. In our RV32I pipelined data path, which stage requires two adders?

A. IF
B. ID
C. EXE
D. MEM
E. WB

**Answer:** 3 = C — EXE

### Q30. When running a binary tree search on a pipelined data path, what hazards are likely to occur?

A. Dependence hazards
B. Structure hazards
C. Data hazards
D. Control hazards
E. Branch hazards

**Answer:** 3,4 = C — Data hazards; D — Control hazards

### Q31. Why do some RV pipelined data path designs utilize a comparison unit to execute the compare-and-branch instructions instead of using the standard ALU?

A. To avoid structural hazards
B. Avoid setting the wrong ‘taken/not-taken’ due to integer subtraction overflows.
C. The ALU at the EXE stage is needed for R-type instructions and Load/Store instructions
D. Comparison operation does not trap

**Answer:** 2 = B — Avoid setting the wrong ‘taken/not-taken’ due to integer subtraction overflows.

### Q32. Intel Pentium 4 has 31 pipeline stages. A branch instruction is resolved pretty late, near the 31st stage.  If the branch misprediction rate is 2%, what would be the performance impact? (Assuming 20% of instructions are branches, and the average CPI is 1).

A. 2%
B. 6%
C. 20%
D. 12%
E. 60%

**Answer:** 4 = D — 12%

### Q33. What information is stored in the pipelined registers?

A. Control signals
B. Data (ALU results, Register values, Immediates)
C. Addresses (PC, PC+4, memory address)
D. Register designators

**Answer:** 1,2,3,4 = A — Control signals; B — Data (ALU results, Register values, Immediates); C — Addresses (PC, PC+4, memory address); D — Register designators

### Q34. Which RV32I branch/jump instructions are most difficult to predict?

A. Conditional branches such as BLT/BEQ/BNE
B. Unconditional jumps such as JAL, X0, target
C. Function calls such as JAL X1, function_name
D. Indirect branch for switches, such as JALR, 4(X1)
E. Return branch, such as JALR, X0, 0($ra)

**Answer:** 4 = D — Indirect branch for switches, such as JALR, 4(X1)

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

### Q2. Which of the following pieces of information is not stored as part of a data cache line?

A. Data of the cache block
B. Set number
C. The valid bit
D. The address tag
E. The dirty bit

**Answer:** 2 = B — Set number

### Q3. In a memory hierarchy, which layer is managed by the compiler or the programmers?

A. The local memory
B. The L1 cache
C. The L2 cache
D. The write buffer

**Answer:** 1 = A — The local memory

### Q4. We have a 64 KB, 4-way set-associative cache with a 32-byte block (line) size. When the CPU issues a 32-bit memory address, how many bits are allocated to the Tag, the Set Index, and the Block Offset, respectively?

A. 16, 11, 5
B. 18, 8, 6
C. 18, 9, 5
D. 17, 9, 6

**Answer:** 3 = C — 18, 9, 5

### Q5. Which of the following data structures is used in a non-blocking cache?

A. A prefetch buffer
B. AMAT counter
C. MSHR
D. Interlock table

**Answer:** 3 = C — MSHR

### Q6. Which of the following cache organizations does not make sense?

A. L3 is write-through
B. L1 is direct-mapped plus a victim cache
C. L2 write-back with write allocate
D. Split L1I / L1D

**Answer:** 1 = A — L3 is write-through

### Q7. In a typical modern multi-core processor, which level of cache is usually shared among all the CPU cores?

A. L1
B. L2
C. L3
D. L4

**Answer:** 3 = C — L3

### Q8. For a single-cycle data path design, if the D-cache miss rate is 5%, 40% of instructions are load/stores, and the memory latency is 100 cycles. What would be the average CPI?

A. 2.0
B. 1.4
C. 1.6
D. 3.0

**Answer:** 4 = D — 3.0

### Q9. The instruction cache is usually easier to manage than the data cache. Why?

A. It does not need to handle write operations
B. It does not need the valid bit
C. It does not need to handle cache line replacements
D. It does not need the tag bits

**Answer:** 1 = A — It does not need to handle write operations

### Q10. In modern processors, what is the likely L1D cache hit latency?

A. 1 cycle
B. 3-4 cycles
C. 5-6 cycles
D. 10+ cycles

**Answer:** 2 = B — 3-4 cycles

### Section II
*(multiple answers)*

### Q11. What is the most likely cache organization for L1D in modern processors?

A. 4-way set-associative, write-through, write-allocate,
B. Fully-associative, write-through, write-noallocate,
C. Direct-mapped, write-back, write-allocate,
D. 4-way set-associative, write-back, write-allocate,
E. Direct-mapped, write-back, write-noallocate,

**Answer:** 4 = D — 4-way set-associative, write-back, write-allocate,

### Q12. If minimizing the tag space is the primary goal, which cache features should be used?

A. Set associative caches
B. Direct-mapped caches
C. Write no-allocate policy
D. Large cache blocks (lines)
E. Inclusive caches

**Answer:** 2, 4 = B — Direct-mapped caches; D — Large cache blocks (lines)

### Q13. Modern processors typically include on-chip L1, L2, and L3 caches. Which statement is TRUE?

A. The primary goal of L3 cache is to reduce the memory traffic to the memory
B. The primary goal of the L1 cache is to have a fast hit time
C. The L3 cache is often shared by multiple cores
D. The L2’s goal is to balance the speed and the capacity

**Answer:** 1,2,3,4 = A — The primary goal of L3 cache is to reduce the memory traffic to the memory; B — The primary goal of the L1 cache is to have a fast hit time; C — The L3 cache is often shared by multiple cores; D — The L2’s goal is to balance the speed and the capacity

### Q14. What are the four types of cache misses (4C’s) ?

A. Compulsory misses, Conflict misses, Capacity misses, Coherence misses
B. Cold misses, Collision misses, Capacity misses, Coherence misses
C. Cascaded misses, Controlled misses, Contiguous misses, Conditional misses
D. Cool misses, Cold misses, Capacity misses, Coherence misses

**Answer:** 1,2 = A — Compulsory misses, Conflict misses, Capacity misses, Coherence misses; B — Cold misses, Collision misses, Capacity misses, Coherence misses

### Q15. Among the 4C’s, which cache misses are the most difficult to remove?

A. Compulsory
B. Collision
C. Capacity
D. Coherence

**Answer:** 4 = D — Coherence

### Q16. For the compulsory misses, how may we reduce them?

A. Hardware prefetching
B. Having a larger cache line size
C. Increase the cache size
D. Add a victim cache

**Answer:** 1,2 = A — Hardware prefetching; B — Having a larger cache line size

### Q17. Compare the L2 to the L1 cache, the L2 cache is usually

A. Larger
B. Slower
C. Unified
D. Shared

**Answer:** 1,2,3 = A — Larger; B — Slower; C — Unified

### Q18. Four processors are connected to the main memory via a global bus. What are the possible solutions to maintain cache coherence?

A. Use a shared cache; no private cache allowed
B. If caches are private, use the Snoopy protocol
C. Build an inclusive multi-level cache
D. Split the instruction and the data cache

**Answer:** 1,2 = A — Use a shared cache; no private cache allowed; B — If caches are private, use the Snoopy protocol

### Q19. Assume the same cache size and the same line size. Which of the following statements are always true?

A. A direct-mapped cache is faster than set associative caches
B. A fully associative cache has the lowest cache miss rate
C. A direct-mapped cache has the lowest tag overhead
D. Replacement policy in a direct-mapped cache is the simplest

**Answer:** 3,4 = C — A direct-mapped cache has the lowest tag overhead; D — Replacement policy in a direct-mapped cache is the simplest

### Q20. What are the advantages of using a large cache line size?

A. It exploits more spatial locality
B. It exploits more temporal locality
C. It saves tag space
D. It could reduce compulsory misses

**Answer:** 1,3,4 = A — It exploits more spatial locality; C — It saves tag space; D — It could reduce compulsory misses

### Q21. My computer has a two-way set associative cache with 4KB and 32B line size, which of the following memory reference sequences would run into conflict misses?

A. 0x01ABC000, 0x01ABC004, 0x01ABC010, 0x01ABC002,
B. 0x01ABC000, 0x01ABC020, 0x01ABC030, 0x01ABC040,
C. 0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010,
D. 0x01ABC020, 0x01ABC030, 0x01ABC02A, 0x01ABC03A,

**Answer:** 3 = C — 0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010,

### Q22. What is the multi-level cache implemented in your project #4?

A. Inclusive cache
B. Exclusive cache
C. NINE cache
D. Shared cache

**Answer:** 3 = C — NINE cache

### Q23. What replacement algorithm is implemented in the typical set-associative caches today?

A. LRU
B. FIFO
C. Approximate LRU
D. Random
E. Belady’s algorithm

**Answer:** 3 = C — Approximate LRU

### Q24. If you would like to implement a TRUE LRU replacement algorithm, what data structure should be used?

A. A queue
B. A stack
C. A tree
D. A heap

**Answer:** 2 = B — A stack

### Q25. You developed a new cache replacement algorithm that effectively balances procedure calls and looping behaviors. Now, what is the upper bound you need to evaluate against?

A. Against LRU
B. Against Random
C. Against Belady’s algorithm
D. Against a perfect cache

**Answer:** 3 = C — Against Belady’s algorithm

### Q26. My cache supports both write-allocate and write-no-allocate policies; it is controlled by a bit in the store instruction. Under what condition should the store instruction turn on “write-no-allocate”?

A. In the memcpy(a,b,n) lib call when n is large
B. When storing local variables in a procedure
C. When storing a struct member (e.g., st.a or st->a)
D. In the memset(a,b,n) lib call when n is large.
E. When writing database logs

**Answer:** 1,4,5 = A — In the memcpy(a,b,n) lib call when n is large; D — In the memset(a,b,n) lib call when n is large.; E — When writing database logs

### Q27. Which cache features require greater bus and memory bandwidth?

A. Large cache lines
B. Cache prefetching
C. Non-blocking caches
D. Exclusive, multi-level, write-back caches
E. Write-through caches

**Answer:** 1,2,3,5 = A — Large cache lines; B — Cache prefetching; C — Non-blocking caches; E — Write-through caches

### Q28. Which of the following statements about the “snoopy” cache are true?

A. It works as a watchdog for preventing illegal cache references
B. It is designed to maintain cache coherence for bus-connected multi-processor systems
C. It is designed for data security enforcement
D. It will generate significant snooping bus traffic

**Answer:** 2,4 = B — It is designed to maintain cache coherence for bus-connected multi-processor systems; D — It will generate significant snooping bus traffic

### Q29. Which of the following could reduce conflict misses incurred in a direct-mapped L1D cache?

A. Increase the cache sizes
B. Increase the cache block (line) sizes
C. Add a victim cache
D. Change to set associative cache
E. Use the best replacement algorithm

**Answer:** 1,3,4 = A — Increase the cache sizes; C — Add a victim cache; D — Change to set associative cache

### Q30. Which of the following are often useful in reducing cache capacity misses?

A. Increase the cache sizes
B. Increase the cache block (line) sizes
C. Add one victim cache
D. Change to set associative cache
E. Cache prefetching

**Answer:** 1,5 = A — Increase the cache sizes; E — Cache prefetching

### Q31. MSHR (Miss Status Handling Registers) are used to track multiple outstanding cache misses. Each level of cache has its own MSHR. On a multicore chip, the number of entries in the L3 MSHR would likely be influenced by

A. The memory latency
B. The memory bus width
C. The size of the L2 cache
D. The number of cores sharing the L3

**Answer:** 1,2 = A — The memory latency; B — The memory bus width

### Q32. I-cache does not take stores from the processor. However, modern applications use “instruction patching” or “JIT” code generation to either modify instructions or generate a new code section for subsequent execution.  Which of the following solutions are required for evicting stale instructions in the I-cache?

A. Flush the I-cache to purge all old instructions
B. Invalidate the I-cache lines containing the instructions
C. Flush the data caches
D. Maintain coherence between I- and D-cache: any updates to the D-cache will also write into the respective lines in I-cache.

**Answer:** 1,2,4 = A — Flush the I-cache to purge all old instructions; B — Invalidate the I-cache lines containing the instructions; D — Maintain coherence between I- and D-cache: any updates to the D-cache will also write into the respective lines in I-cache.

### Q33. Which of the following multi-level cache organizations does not make sense?

A. L1I copy back and L1D write-through
B. L1/L2 exclusive, L2/L3 inclusive
C. L1D 4-way set associative, L2 direct mapped
D. L1/L2 inclusive, L2/L3 exclusive

**Answer:** 1,2,3 = A — L1I copy back and L1D write-through; B — L1/L2 exclusive, L2/L3 inclusive; C — L1D 4-way set associative, L2 direct mapped

### Q34. In contemporary processors, the vast majority of chip space is dedicated to what?

A. Branch prediction
B. Register files
C. Pipelined registers
D. Floating-point functional units
E. Caches

**Answer:** 5 = E — Caches

### Q35. Which of the following sorting algorithms is known to have high data locality?

A. Quicksort
B. Insertion sort
C. Heapsort
D. Radix sort
E. Bubble sort

**Answer:** 1,2,5 = A — Quicksort; B — Insertion sort; E — Bubble sort

### Q36. What is the difference between a hardware cache and a software cache (such as a disk file cache)?

A. Software caches are managed by system software or applications, whereas hardware caches are managed by the hardware
B. Hardware caches support associative search, while software caches utilize lookup data structures such as hash tables.
C. Hardware caches must implement simple and fast replacement algorithms; software caches can use more complex algorithms.
D. Hardware caches are flexible in size, but software caches are not.

**Answer:** 1,2,3 = A — Software caches are managed by system software or applications, whereas hardware caches are managed by the hardware; B — Hardware caches support associative search, while software caches utilize lookup data structures such as hash tables.; C — Hardware caches must implement simple and fast replacement algorithms; software caches can use more complex algorithms.

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

### Q2. How do you read the detailed information of an ELF file?

A. objdump
B. gdb
C. ldd
D. readelf
E. nm

**Answer:** 4 = D — readelf

### Q3. Which of the following is NOT a job for the linker?

A. Symbol resolution
B. Handling libraries
C. Loading into the memory
D. Section merging
E. Relocation

**Answer:** 3 = C — Loading into the memory

### Q4. If you want to enable cross-module procedure inlining optimization, which of the following flags are required?

A. -O
B. -O5
C. -O3 -flto
D. -O3 -ffast

**Answer:** 3 = C — -O3 -flto

### Q5. Which of the following optimizations have no primary attempt to improve locality?

A. Loop unrolling
B. Loop interchange
C. Loop fusion
D. Loop tiling

**Answer:** 1 = A — Loop unrolling

### Q6. Which of the following compiler optimizations may lead to 1000x speedup?

A. Procedure inlining
B. Cascading DCE
C. Loop unrolling
D. Register allocation
E. Code scheduling

**Answer:** 2 = B — Cascading DCE

### Q7. Which of the following compiler optimizations have been discussed in class?

A. Multi-threading on multi-cores
B. SIMT using CUDA
C. Vectorization using a compiler auto-vectorization
D. Loop transformations to improve data locality

**Answer:** 4 = D — Loop transformations to improve data locality

### Q8. To build executables for embedded systems where the memory size is severely limited, which optimization flags should be used?

A. -O0
B. -Os
C. -O3 -flto
D. -O3

**Answer:** 2 = B — -Os

### Section II
*(multiple answers) / Open to everyone*

### Q9. What are the benefits of linking?

A. Modularity
B. Fast compilation/recompilation
C. Code reuse via libraries
D. Easier to maintain
E. Simpler to build an executable

**Answer:** 1,2,3,4 = A — Modularity; B — Fast compilation/recompilation; C — Code reuse via libraries; D — Easier to maintain

### Q10. What can a linker do?

A. Can enable Link Time Optimization
B. Can resolve symbol definition/reference
C. Can tune a program’s performance via page sizes and alignments
D. Can relocate global variable references and function calls

**Answer:** 1,2,3,4 = A — Can enable Link Time Optimization; B — Can resolve symbol definition/reference; C — Can tune a program’s performance via page sizes and alignments; D — Can relocate global variable references and function calls

### Q11. What are the three different object files?

A. Relocatable object file
B. Static object file
C. Executable object file
D. Shared object file
E. Dynamic object file

**Answer:** 1,3,4 = A — Relocatable object file; C — Executable object file; D — Shared object file

### Q12. What are the data structures to support dynamic linking?

A. GOT (Global Offset Table)
B. JT (Jump Table)
C. PLT (Procedure Linkage Table)
D. SHT (Section Header Table)

**Answer:** 1,3 = A — GOT (Global Offset Table); C — PLT (Procedure Linkage Table)

### Q13. What are the major advantages of dynamic linking?

A. Faster execution
B. Significant Memory (RAM) Savings
C. Centralized Security Updates and Bug Fixes
D. Fast build time linking

**Answer:** 2,3,4 = B — Significant Memory (RAM) Savings; C — Centralized Security Updates and Bug Fixes; D — Fast build time linking

### Q14. Where do we keep the PLT, GOT and GOT.plt?

A. PLT is in the .text section
B. GOT is in the .data section
C. GOT.plt is in the .data section
D. GOT is in the .text section

**Answer:** 1,2,3 = A — PLT is in the .text section; B — GOT is in the .data section; C — GOT.plt is in the .data section

### Q15. What are the symbols in the .symtab section?

A. Global variables
B. Local variables
C. External functions
D. Static local symbols

**Answer:** 1,3,4 = A — Global variables; C — External functions; D — Static local symbols

### Q16. Which of the following symbol resolution rules is incorrect?

A. Two weak symbols are not allowed
B. Two strong symbols are not allowed
C. One strong symbol and multiple weak symbol are allowed
D. Two weak symbols with different data types are allowed

**Answer:** 1 = A — Two weak symbols are not allowed

### Q17. Which of the following descriptions are incorrect?

A. .so is for a shared object file
B. .a is for an archived library
C. .o is for relocatable object file
D. .a is a collection of .o files with an index

**Answer:** NONE

### Q18. How do we know which instructions and which data references require relocation?

A. The compiler or assembler leaves that information in the
   .rel.text and .rel.data sections.
B. The linker leaves the information in the .rel.text and .rel.data sections.
C. The loader leaves the information in the .rel.text and .rel.data sections.
D. The dynamic linker leaves the information in GOT and PLT

**Answer:** 1 = A — The compiler or assembler leaves that information in the .rel.text and .rel.data sections.

### Q19. Which of the following procedures are good candidates for inlining?

A. Small procedures
B. Procedures with multiple constant arguments
C. Recursive procedures
D. Procedures with many call sites
E. Procedures that are called only once in a loop

**Answer:** 1,2,5 = A — Small procedures; B — Procedures with multiple constant arguments; E — Procedures that are called only once in a loop

### Q20. Two parameters *a and *b are used frequently, and they are not pointing to the same object. The compiler did not allocate them to registers. What can you do?

A. Turn on –O3
B. Change from gcc to clang
C. Use restricted pointers
D. Allocate *a and *b to local variables manually

**Answer:** 3,4 = C — Use restricted pointers; D — Allocate *a and *b to local variables manually

### Q21. For the expressions (a+b+c+d) and (a+d+b+c), we may consider them as a CSE (Common Sub-Expression) if the data type is

A. Long long
B. Float
C. Double
D. char

**Answer:** 1,4 = A — Long long; D — char
