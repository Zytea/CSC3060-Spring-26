# Chapter 6: The Memory Hierarchy

## Memory Hierarchy

So far, we view the memory as a linear array of bytes, and the CPU can access each memory location in one cycle.

In practice, a memory system is a hierarchy of storage devices with different capacities, costs, and access times.

==CPU registers== hold the most frequently used data. Small, fast memory ( ==cache== ) acts as a staging area for main memory, and ==main memory== acts as a staging area for ==disks== or network devices.

The higher-level hierarchy is much more active than the lower-level hierarchy. So this hierarchy gives you the illusion: memory is fast, large, and inexpensive.

## PC Memory/Storage Size and Latency

| Year | Typical RAM Size (Main Memory) | Typical Disk Size (HDD/SSD) | Typical Memory Access Latency |
| :-: | :-: | :-: | :-: |
| 1985 | 640 KB – 1 MB | 10 MB – 20 MB  (HDD) | ~200 ns |
| 1995 | 8 MB – 16 MB | 500 MB – 1.2 GB  (HDD) | ~100 ns |
| 2005 | 512 MB – 1 GB | 80 GB – 160 GB  (HDD) | ~60 ns |
| 2015 | 8 GB – 16 GB | 1 TB ( HDD ) / 256 GB ( SSD ) | ~50 ns |
| 2025 | 32 GB – 64 GB | 2 TB – 4 TB  (NVMe SSD) | ~60 ns * |

AI workload creates a Memory bottleneck

AI workload requires both “size” and “bandwidth”

## 6.1 Random Access Memory (RAM)

* Random access memory
  * Access time is the same for all locations
  * ==SRAM== (Static Random Access Memory)
    * Low density, high power, expensive, fast
    * Static: content will last forever until it loses power
    * Address not divided
    * Use for caches, local memory
  * ==DRAM== (Dynamic Random Access Memory)
    * High density, low power, cheap, slow
    * Dynamic: need to be ==refreshed== regularly
    * Addresses in 2 halves (memory as a 2D matrix)
      * RAS/CAS (Row/Column Access Strobe)
    * Use for main memory

    **SRAM cell:** Typically 4–8 transistors + 2 resistors; switch state of transistor represents a bit; **no refresh needed**; expensive due to transistor count.

    **DRAM cell:** 1 transistor + 1 capacitor; charge of capacitor represents a bit; must be periodically refreshed; much denser and cheaper.

## RAM Technologies

<img src="img%5CCA3060-6-MemHierarchy_2.png" style="zoom:25%;" />

<img src="img%5CCA3060-6-MemHierarchy_3.png" style="zoom:50%;" />

## SRAM vs DRAM Summary

| | Trans/bit | Access | Refresh? | EDC? | Cost | Applications |
|---|---|---|---|---|---|---|
| **SRAM** | 6 or 8 | 1× | No | Maybe | 100× | Cache memories |
| **DRAM** | 1 | 10× | Yes | Yes | 1× | Main memories, frame buffers |

*EDC: Error Detection and Correction*

* Trends
  * SRAM scales with semiconductor technology
    * Reaching its limits
  * DRAM scaling is limited by the need for minimum capacitance
    * Aspect ratio limits how deep a capacitor can be made
    * Also reaching its limits

> **SRAM 的局限性**：虽然 SRAM 随半导体工艺（尺寸缩小）而扩展，但目前已逐渐**接近物理极限** 。
>
> **DRAM 的局限性**：DRAM 的缩放受限于**最小电容需求** 。为了保持足够的电荷，电容器必须做得非常“深”，但**展宽比（Aspect Ratio）**限制了电容器的深度加工能力，因此也正面临扩展瓶颈 。

## Conventional DRAM Organization

* d x w DRAM:
  * d⋅ w total bits organized as d ==supercells== of size w bits

  <img src="img%5CCA3060-6-MemHierarchy_0.png" style="zoom:50%;" />

## Reading DRAM Supercell (2,1)

Step 1(a): Row access strobe ( ==RAS== ) selects row 2.

Step 1(b): Row 2 copied from DRAM array to row buffer.

<img src="img%5CCA3060-6-MemHierarchy_1.png" style="zoom:50%;" />

Step 2(a): Column access strobe ( ==CAS== ) selects column 1.

Step 2(b): Supercell (2,1) copied from buffer to data lines, and eventually back to the CPU.

Step 3: All data written back to row to provide refresh

<img src="img%5CCA3060-6-MemHierarchy_1-1.png" style="zoom:50%;" />

> **第一步：行访问 (Row Access)**
>
> - **发送 RAS**：内存控制器将行地址 2 发送到地址线，并触发**行访问选通脉冲 (RAS)** 。
> - **复制到缓冲**：整行（行 2）的所有数据会被一次性从 DRAM 阵列复制到一个**内部行缓冲区 (Internal Row Buffer)** 中 。
>
> **第二步：列访问 (Column Access)**
>
> - **发送 CAS**：内存控制器发送列地址 1，并触发**列访问选通脉冲 (CAS)** 。
> - **提取数据**：从行缓冲区中取出指定的超级单元 (2,1)，通过数据线发送回 CPU 。
>
> **第三步：刷新 (Refresh)**
>
> - **写回数据**：由于 DRAM 读取是破坏性的且电荷会流失，所有缓冲区中的数据最后会被写回原始行，以完成**刷新** 。

## Conventional DRAM Organization

由于单个 DRAM 芯片的宽度有限（例如只有 8 位），为了满足 CPU 一次读取 64 位（一个 Word）的需求，多个芯片会被组合在一起：

- **并行工作**：在一个 64MB 的内存模块中，可能包含 8 个 8Mx8 的 DRAM 芯片 。
- **地址共享**：内存控制器向所有芯片发送相同的行/列地址，每个芯片贡献 8 位数据，最终拼凑成一个 **64 位的字 (Word)** 返回给 CPU 

## Memory Modules

<img src="img%5CCA3060-6-MemHierarchy_2-1.png" style="zoom:50%;" />

## Enhanced DRAMs, NV, and Disks

DDR SDRAM dominates Computer

Memory market today

* Fast Page Mode DRAM ==(FPM DRAM)==
* Extended Data out DRAM ==(EDO DRAM)==
* Synchronous DRAM ( ==SDRAM== )
* Dual Data Rate SDRAM ( ==DDR SDRAM)==
* Rambus DRAM ==(RDRAM)==
* Video RAM ==(VRAM)==
* Embedded DRAM ( ==eDRAM== )
* Flash Memory ( ==NV memory== )
  * Will not lose data when the power is cut
  * electrically erasable programmable read-only memory (EEPROM)
  * Flash memory card, USB device, etc
* Magnetic Disk and Tape
  * For long-term storage

  **All unconventional DRAM chips offer much higher bandwidth, but the latency remains the same.**

## Comparisons of Speed and Cost

| Technology | Typical Access Time | Cost per GB |
|-----------|--------------------|-----------|
| **SRAM** | 0.5–2.5 ns | $1,000–$5,000 |
| **DRAM** | 50–70 ns | $2–$20 |
| **HDD** | 5,000,000–20,000,000 ns | $0.02–$0.05 |
| **SSD** | — | $0.06–$0.20 |

**Q:** Why is SRAM disproportionately more expensive than DRAM?

**A:** Yields, density, volume, design complexity, …

## Accessing Main Memory

Memory Controller

A **bus** is a collection of parallel wires that carry address, data, and control signals.

Buses are typically shared by multiple devices.

<img src="img%5CCA3060-6-MemHierarchy_4.png" style="zoom: 50%;" />

## 1. Memory Read Transaction

1. CPU places address A on the memory bus (→).

<img src="img%5CCA3060-6-MemHierarchy_23.png" style="zoom: 50%;" />

2. Main memory reads A from the memory bus, retrieves word x, and places it on the bus (←).
3. CPU reads word x from the bus and copies it into register X1 (↑).

## 2. Memory Write Transaction

1. CPU places address A on bus. 

<img src="img%5CCA3060-6-MemHierarchy_24.png" style="zoom: 50%;" />

2. Main memory reads it and waits for the corresponding data word to arrive.

## 1. The CPU-Memory Gap

The gap *widens* between DRAM, disk, and CPU speeds.

<img src="img%5CCA3060-6-MemHierarchy_25.png" style="zoom: 50%;" />

## **2. Processor/Memory Latency Gap**

**Impact from the Power Wall** 

<img src="img%5CCA3060-6-MemHierarchy_26.png" style="zoom: 33%;" />



## Clock Frequency Stays Flat, But …

* Processors are still getting more powerful: Super-scalar, Out-of-order, SIMD/Vector, Multi-core, GPU
* **Memory Wall** remains a challenge:
  * Memory is far away
  * Memory bandwidth is insufficient
## Memory Wall

* In computer architecture, the "memory wall" refers to the growing gap between the speed of processors and the speed of main memory (DRAM).
  * **Latency：获取单个数据所需的时间越来越长（相对于 CPU 周期而言）。**
    * Reduction: Local Memory, NUMA, PIM
    * Hiding: Multi-threading/Hyper-threading, WARP interleaving, chip-multithreading
  * **Bandwidth**：**内存单位时间内能提供的数据总量不足以支撑现代强大的处理器 。**
    * Memory bandwidth: Multi-banks and interleaved memory, SDRAM, HBM
    * Communication bandwidth: wider bus, interconnection network
* In HPC (High-Performance Computing), including ML/LLM, memory performance is often the primary bottleneck.
* GPUs excel at parallel processing, and HBM gives the needed high memory bandwidth. But due to its limited HBM size, data transfers still pose a challenge.

## Levels of Memory Hierarchy

<img src="img%5CCA3060-6-MemHierarchy_27.png" style="zoom: 50%;" />

### Why Memory Hierarchy Works

- **Upper levels** (Registers, Cache): fast but small — majority of references are here
- **Lower levels** (Memory, Disk, Tape): slow but large and cheap — your program and data stored here

→ This gives you ==Large==, ==Cheap== memory with ==Fast== access (the illusion).

## Levels of Memory Hierarchy - Terminology

* ==Block== (aka ==line== ): unit of copying
  * May be multiple words
* If accessed data is present in the upper-level
  * ==Hit== : access satisfied by upper level
  * ==Hit ratio== : hits/accesses
* If accessed data is absent
  * ==Miss== : block copied from lower level
  * ==Miss penalty== : extra time taken
  * ==Miss ratio== : misses/accesses = (1 – hit ratio)
* Then accessed data supplied from the upper-level
* ==Hit time << Miss penalty==

<img src="img%5CCA3060-6-MemHierarchy_5.png" style="zoom: 25%;" />

## How Is the Memory Hierarchy Managed

* Registers <-> Memory
  * By compiler (programmer?)
  * **机制**：编译器通过指令（如 Load/Store）决定哪些变量应该放在有限的寄存器中以实现最快访问 。在某些底层编程中，**程序员**也可以通过特定代码干预这一过程 。
* ==Cache <-> Memory== / **Local memory <-> Memory**
  * ==By the hardware== / **by the compiler/programmer**
  * **机制**：硬件缓存控制器（Cache Controller）负责处理命中的读取和缺失时的块替换，这一过程对程序员通常是“透明”的 。
  * **特殊情况**：对于**局部存储/刮擦板内存**（Local memory / Scratch-pad memory，如 NVIDIA GPU 的共享内存），则需要由**编译器或程序员**显式管理 。
* *Memory <-> Disks*
  * *By the hardware and operating system (virtual memory)*
  * By the programmer (files)
  * **自动管理（虚拟内存）**：由**硬件和操作系统**（Operating System）共同协作 。当发生你提到的“缺页中断”（Page Fault）时，操作系统会将数据从磁盘调入内存 。
  * **手动管理（文件系统）**：由**程序员**（Programmer）通过文件读写指令（Files）来显式控制数据的搬运 。
* Disks <-> Tapes
  * By the hardware
  * By the operator/programmer
---

注意通常数据的访问不会跨太多级别，比如cache不会直接访问disk上的data。But a TLB miss may trigger a page fault…

> ### 1. 数据的正常流动：逐级访问（Inclusive/Strict Hierarchy）
>
> 在正常的指令执行过程中（如 `load` 指令），存储系统的确遵循“不跨级”的原则。正如你在 PPT 中看到的：
>
> - **CPU** 寻找数据时，先看 **L1 Cache**。
> - 如果 L1 Miss，硬件会自动去 **L2 Cache** 找。
> - 如果所有 Cache 都 Miss，硬件会访问 **主存 (DRAM)**。
> - **关键点**：Cache 硬件层级通常不知道“磁盘”的存在。如果数据不在内存中，硬件层级的访问就会戛然而止，抛给异常处理机制。
>
> ------
>
> ### 2. 为什么说 "A TLB miss may trigger a page fault"？
>
> 这句话描述的是**虚拟地址到物理地址转换**失败时的连锁反应，它是存储层次结构中唯一一个可能直接导致从“极快”跳跃到“极慢”的场景。
>
> #### 什么是 TLB？
>
> TLB (Translation Lookaside Buffer) 是放置在 CPU 内部的一个 **SRAM 缓存**，它存储的是最近用过的**页表项（PTE）**，即“虚拟地址 $\rightarrow$ 物理地址”的翻译结果。
>
> #### 连锁反应的逻辑：
>
> 1. **TLB Miss**：CPU 想要访问一个地址，但在 TLB 里没找到翻译结果。
> 2. **查询页表 (Page Table Walk)**：硬件或操作系统必须去主存（DRAM）中查找完整的页表。
> 3. **发现缺失 (Invalid PTE)**：在查页表时，发现该虚拟页对应的“有效位（Valid Bit）”为 0。这意味着该数据**根本不在内存中**，而是在磁盘上。
> 4. **触发缺页中断 (Page Fault)**：这是一个软件异常。操作系统接管 CPU，停止当前程序。
> 5. **访问磁盘 (Disk Access)**：操作系统启动磁盘 I/O，将数据从磁盘加载到内存。

## Summary of Memory Hierarchy 

* Memory wall
  * Latency: getting longer
  * Bandwidth: insufficient
* Solution:
  * Memory Hierarchy
  * A small, fast memory close to the CPU
    * low latency
    * high bandwidth (not limited by refresh cycles, pin-bandwidth)
  * Transparent solution
    * ==Caches==
  * Explicit management
    * ==Local memory (e.g. ARM scratch-pad memory or NVIDIA’s shared memory)==

    Story about

    IBM 360/91 and 360/85

---

Example: IBM 360/91 vs 360/85

* DRAM is slow but cheap and dense
  * Good for presenting users with a ==BIG== memory system
* SRAM is fast but expensive, not very dense
  * Good choice for on-chip memory
  * Good for providing ==FAST== access and high bandwidth
* Two different types of locality
  * Temporal Locality (Locality in Time)
  * Spatial Locality (Locality in Space)
* Use the principle of locality
  * Present the user with as much memory as is available in the cheapest technology (keep the cost low)
  * Provide access at the speed offered by the fastest technology

## Inside the Processor

AMD Barcelona: 4 processor cores

<img src="img%5CCA3060-6-MemHierarchy_6.png" style="zoom:50%;" />

## Four Questions for Memory Hierarchy Design

Q1: Where can a block be placed in the upper level?=> ==Block placement==

Q2: How is a block found if it is in the upper level?=> ==Block finding==

Q3: Which block should be replaced on a miss?=> ==Block replacement==

Q4: What happens on a write?=> ==Write strategy==

---

Same questions we ask for accessing a table structure
Difference: this is cache: temporary space, data come and goes. It is a fix, small space. If no room for a new one, replace the old one.

## Two Simple Caches

<img src="img%5CCA3060-6-MemHierarchy_28.png" style="zoom: 67%;" />

Each block is a cache line with 64Bytes

These are cache line (aka block) address

## Tags and Valid Bits - Block Finding

* How do we know which particular block is stored in a cache location
  * Store the ==block address== as well as the data
  * Actually, only need the high-order bits
  * Called the ==tag==
* What if there is no data in a location
  * ==Valid bit== : 1 = present, cache line valid
  * Valid bit = 0
    * When a cache line of data has not come back from memory yet
    * Cache line is currently being replaced
    * Cache is flushed
---

tag用来标识地址信息，valid表示用来标识当前的数据是否有效

### 1. Cache Line (行 / 块)

**Line** 是缓存与主存之间进行数据交换的**最小单位** 。

- **组成**：一个 Cache Line 通常包含三部分：
  - **Valid Bit（有效位）**：标记该行是否包含有效数据 。
  - **Tag（标签）**：用于标识该行对应主存的哪个地址 。
  - **Data（数据）**：实际存储的内存副本，通常由多个字（Words）组成（例如 64 字节） 。
- **特性**：当发生缺失（Miss）时，硬件会从内存中拷贝一整行数据到缓存中 。

### 2. Cache Set (组)

**Set** 是由一个或多个 Cache Line 组成的集合 。

- **作用**：主存中的一个地址通过其索引（Index）位，会被映射到缓存中一个**特定的 Set** 。
- **关联性 (Associativity)**：一个 Set 中包含的 Line 数量决定了缓存的类型 ：
  - **直接映射 (Direct-mapped)**：每个 Set 只有 **1 条** Line 。
  - **N路组相联 (N-way Set-associative)**：每个 Set 包含 **N 条** Line 。
  - **全相联 (Fully Associative)**：整个缓存只有 **1 个** Set，包含所有的 Line 。

## Cache Example 

- 8-blocks, 1 word/block, direct mapped

- 8 set is a group of lines that can hold memory blocks

<img src="img%5CCA3060-6-MemHierarchy_29.png" style="zoom: 67%;" />

**Step 1**: 根据 **Index** 找到缓存中的特定行。

**Step 2**: 检查该行的 **Valid Bit** 是否为 1。

**Step 3**: 比较该行的 **Tag** 是否与地址中的 Tag 一致。

**Result**: 只有当 `Valid == 1` 且 `Tag Match` 时，才算 Hit。

## Set Associative Caches

* Cache Structure: Sets and Ways
  * A cache is divided into a fixed number of Sets.
  * Each Set contains a fixed number of cache lines (i.e. blocks). This number is known as the associativity or the number of Ways.
  * So, a cache described as "N-way set-associative" means there are N cache lines within each set.
  * Example: A 4-way set-associative cache has 4 cache lines in every set.
  * A ==direct-mapped== cache is a ==one-way== cache: each set has only one line
  * A ==fully associative== cache is a ==one-set== cache. All lines are kept in one set
## Associativity Structures

![CA3060-6-MemHierarchy_30](C:\Users\Zytea\Desktop\CSC 3060\img\CA3060-6-MemHierarchy_30.png)

## Address Subdivision for Set Associative Caches (1)

<img src="C:\Users\Zytea\Desktop\CSC 3060\img\CA3060-6-MemHierarchy_31.png" alt="CA3060-6-MemHierarchy_30" style="zoom: 50%;" />

## Exercise 1

We have a 16KB ==direct mapped== cache, the line (block) size is 64B, indicate how each part of the address bits are used in reading the cache.

**<img src="C:\Users\Zytea\Desktop\CSC 3060\img\CA3060-6-MemHierarchy_31.png" alt="CA3060-6-MemHierarchy_32" style="zoom: 50%;" />**

#### **A. 字节偏移量 (Byte Offset)**

- **原理**：偏移量决定了在一个块（64 字节）内部访问哪一个具体的字节。
- **计算**：因为 $64 = 2^6$，所以需要 **6 位** 来表示偏移量（即地址的第 0 到 5 位）。

#### **B. 组索引 (Set Index)**

- **原理**：索引决定了内存地址映射到缓存中的哪一个“组”。在直接映射中，组的数量等于块的总数 。
- **计算**：
  1. 首先计算组数：$16\text{ KB} / 64\text{ B} = 16384 / 64 = 256$ 个组 。
  2. 因为 $256 = 2^8$，所以需要 **8 位** 来表示索引（即地址的第 6 到 13 位）。

#### **C. 标签 (Tag)**

- **原理**：地址中剩余的高位部分作为标签，用于区分映射到同一个组的不同内存块 。
- **计算**：$32\text{ 位总长} - 8\text{ 位索引} - 6\text{ 位偏移} = 18\text{ 位}$（即地址的第 14 到 31 位）。

## Exercise 2

How many total bits are required for a direct-mapped cache with 16 KB of data and 16-word blocks?

<img src="C:\Users\Zytea\Desktop\CSC 3060\img\CA3060-6-MemHierarchy_31.png" alt="CA3060-6-MemHierarchy_33" style="zoom: 50%;" />

## Exercise 3: A Case for Direct Mapped Cache

Assuming 32b addresses, how many ==a) tag bits== and ==b) number of sets== are used for the following direct-mapped caches?

<img src="C:\Users\Zytea\Desktop\CSC 3060\img\CA3060-6-MemHierarchy_31.png" alt="CA3060-6-MemHierarchy_34" style="zoom: 50%;" />

**Tag 位数**：$32 - \text{Index 位数} - \text{Offset 位数} = 32 - \text{缓存位数}$

**Offset 位数**：$\log_2(\text{块大小})$ ，**Index 位数**：$\log_2(\text{组数}) = \log_2(\text{缓存大小} / \text{块大小})$ 

## Fast Review

* Basic Information about a cache
  * Cache size
  * Line size
  * Number of Sets
    * Direct mapped
    * Full associative
    * Set associative
  * Tag bits
  * Valid bit

## Practical Example - Intrinsity FastMATH (1)

* Embedded MIPS processor (like a co-processor, but highly integrated with MIPS core.
  * 12-stage pipeline
  * Instruction and data access on each cycle
* Split cache: Separate I-cache and D-cache
  * Each cache: ==16KB: 256 blocks== ==×== ==64B/block==

## Example: Intrinsity FastMATH Caches

  * Cache size: **16KB**
  * Line size:    **64B**
  * Number of Sets
    * Direct mapped: **256**
    * *If Fully associative* : **1**
    * Set associative: 
  * Tag bits: **18**
  * Valid bit: **1**

**Question** : How to reduce the cost of the tag?

**Answer** : Increase the line size and the number of sets

## Example - Intrinsity FastMATH (2)

  * `Cache: 16KB`
  * `256 blocks` `×` `16 words/block`

![](img%5CCA3060-6-MemHierarchy_9.png)

## Block Size Considerations

* Larger blocks 
* **Pros:** reduce miss rate
  * Higher ==*spatial locality*==
  * Also reduce tag cost
* But in a fixed-sized cache
  * Larger blocks → fewer blocks
    * More competition → increased the miss rate
    * Lower ==*temporal locality*==
* **Cons**: Larger miss penalty
  * Larger blocks → pollution
  * Transfer overhead (multiple bus cycles)
  * Can override the benefit of reduced miss rate
  * Early restart and critical-word-first can help to reduce transfer latency.


<img src="assets/image-20260507135445218.png" alt="image-20260507135445218" style="zoom:50%;" />

## Cache Hit and Miss

* Cache read
  * Read hit
  * Read miss
* Cache write
  * Write hit
    * **Write-through**: every time the CPU writes data to the cache, the same data is also written to main memory or the next cache level.
    * **Write-back**: the CPU writes data only to the cache first. Main memory or the next cache level is updated only when the cache line is replaced.
  * Write miss
    * **Write-allocate**: if the data being written is not in the cache, the block containing that data is first loaded into cache, then the write is performed on the cached copy.
    * **No-write-allocate**: if the data being written is not already in the cache, it is written directly to memory and the cache is bypassed.

---

## Cache Hit and Miss

* Cache read
  * Read hit
  * Read miss
* Cache write
  * Write hit
    * Write-through
    * Write-back
  * Write miss
    * Write allocate
    * No-write allocate

**Question:** How do we know when to use write-allocate? When to use no-write-allocate?

For example:

* `strcpy()`, `memset()`, `memcpy()`, initialization of arrays, ... -> **no-allocate**
* Local variable updates, array element updates -> **write-allocate**

Most caches today use **write-back** and **write-allocation** policy.

---

## Write Allocate vs Write-no-allocate

On a write miss:

* **Write-Allocate**
  * Also called **fetch-on-write**.
  * The system first loads the missing data block from main memory into the cache, then writes the new data to the cache line.
  * Often works with copy-back / write-back caches.
  * Initial cost is high, but later reuse is fast.
* **Write-NoAllocate**
  * The system **bypasses the cache** and writes directly to main memory, without loading the block into the cache.
  * The write may be sent to a write buffer waiting for a write-combining opportunity, instead of being written to memory immediately.
  * Often works with write-through caches.
  * Initial action is fast, but later reuse is slow. A good case is writing logs.

---

## Cache Read

* **Read hit**
  * On a cache hit, CPU proceeds normally.
* **Read miss**
  * On a cache miss:
    * Stall the CPU pipeline for a **blocking** or **lockup** cache.
    * Fetch the block from the next level of the hierarchy.
    * Instruction cache miss: restart instruction fetch.
    * Data cache miss: complete data access.

---

## Non-Blocking Cache

* **Blocking cache**
  * A cache miss stalls the CPU pipeline.
  * Called **stall-on-miss**.
* **Non-blocking cache**
  * On a cache miss, the CPU does not stall the whole pipeline immediately. It can continue working on other instructions while data is being fetched.
  * A stall occurs only when the fetched data is required.
  * Uses the **Miss Status Holding Register (MSHR)** to track outstanding misses.
  * Called **stall-on-use**.
  * Two standard models: **hit-under-miss** and **miss-under-miss**.
  * Non-blocking caches, also called lockup-free caches, support **MLP (Memory Level Parallelism)**.

---

## Non-Blocking Cache

![](img/CA3060-6-MemHierarchy_11.png)

* **Blocking cache**: a miss stalls the CPU pipeline, so it is **stall-on-miss**.
* **Non-blocking cache**: the processor can continue executing independent work and stalls only when the missing value is used, so it is **stall-on-use**.
* MSHRs track outstanding misses.
* Hit-under-miss and miss-under-miss allow multiple memory operations to overlap.

---

## Instruction Cache Miss Handling

* On instruction cache miss:
  * Send the original PC value to memory.
  * Instruct main memory to perform a read and wait for memory to complete the access.
  * Write the cache entry: put the data from memory in the data portion, write the upper address bits into the tag field, and turn the valid bit on.
  * Restart instruction execution at the first step, which re-fetches the instruction and now finds it in cache.
* **Instruction cache prefetching** is a commonly used hardware optimization to reduce instruction cache misses.

Questions:

* Can you prefetch for instruction cache in software?
* If we prefetch on every miss, why not just use a larger cache line size?
* Why does the GPU prefetch the next 10-12 lines, but the CPU only prefetches 1-2 lines?

---

## Instruction Cache Miss Handling

* On instruction cache miss:
  * Send the original PC value to memory.
  * Read the missing instruction block.
  * Fill the cache entry, update tag and valid bit.
  * Restart fetching the instruction.
* Instruction cache prefetching is commonly done in hardware.

```c
Main() {
    .....
    for() {
        .....
        if () { f1(); ... f2(); }
        prefetch(&f3());
        ...
        f3(); // I$ miss
        ...
    }
}
```

Why not just use a large line?

* Large lines increase the cost of every miss.
* Branches make huge lines wasteful.
* Large lines reduce effective cache capacity and are more likely to cause conflict.
* Prefetch is more flexible.
* Large line and small line + prefetch are similar only for sequential execution, not for all cases.

---

## Write Hit - Write-Through Policy

* **Write-through**: also update data in memory.
* Advantage:
  * Fast retrieval while making sure the data is in the backing store.
  * Data is not lost if the cache is disrupted.
* Disadvantages:
  * Writing experiences latency because two places must be written every time.
  * Memory traffic increases.
  * Writes take longer.
  * If base CPI = 1, 10% of instructions are stores, and a memory write takes 100 cycles:
    * Effective CPI = `1 + 0.1 x 100 = 11`
* Solution: **write buffer**
  * Holds data waiting to be written to memory.
  * CPU continues immediately.
  * CPU stalls only if the write buffer is full.

---

## Avoid Waiting for Memory in Write Through

* Use a **write buffer (WB)**.
  * Processor writes data into cache and WB.
  * Memory controller writes WB data to memory.
* Write buffer is just a FIFO.
  * Typical number of entries: 4.
* Memory system designer's nightmare:
  * Store frequency > `1 / DRAM write cycle`.
  * Write buffer saturation => CPU stalled.
  * Write buffer allows write-coalescing / combining to reduce memory traffic.

Flow:

```text
Processor -> Cache -> Store Buffer -> DRAM
                         |
                  Memory controller
```

Yet another reason to go for **write-back cache**.

---

## Write Hit - Write-Back Policy

* Just update the block in cache.
  * Keep track of whether each block is **dirty**; one dirty bit is required.
* When a dirty block is replaced:
  * Write it back to memory.
  * Can use a write buffer to allow a replacing block to be read first.
* Data in cache and memory is inconsistent.
  * What if another processor wants to read the shared data?
* Advantage:
  * Low latency and high throughput for write-intensive applications.
  * Much lower memory traffic, which is significant for multi-processor systems.
* Disadvantage:
  * Data availability risk: the cache could fail before data is persisted to the backing store.
  * This is why caches are often enhanced with ECC for protection against errors.

---

## Writeback-buffer

* **Writeback buffer** sits between the copy-back data cache and the next lower-level memory.
* Dirty cache lines can be written to memory asynchronously, reducing stall time.
* Improves overall memory throughput: reads can proceed while writes sit in the buffer.

```text
Processor -> Copy-back Data Cache -> Writeback buffer -> Memory
```

---

## Example - Intrinsity FastMATH

* Embedded MIPS processor
  * 12-stage pipeline
  * Instruction and data access on each cycle
* Split cache: separate I-cache and D-cache
  * Each 16KB: `256 blocks x 16 words/block`
  * D-cache: write-through or write-back
* SPEC2000 miss rates
  * I-cache: 0.4%
  * D-cache: 11.4%
  * Weighted average: 3.2%

SPEC2000 benchmarks are desktop apps. Instruction locality is higher. DBMS apps, virtual machines, interpreters, JIT compilers, and object-oriented programs tend to have more I-cache misses.

---

## Review

* Cache organization
* Set associative cache
  * Where in the address are the index / set selection bits?
  * Where in the address are the tag bits?
* Cache hit
  * Write-through: use a write buffer.
  * Write-back: significantly cuts down memory traffic; extremely important for multi-core systems. Uses a writeback buffer.
* Cache miss
  * Write-noallocate: bypass the cache.
  * Write-allocate: presume data will be used later.
* Non-blocking cache: supports MLP (Memory Level Parallelism).

---

## Measuring Cache Performance

* Components of CPU time:
  * Program execution cycles
    * Includes cache hit time.
  * Memory stall cycles
    * Mainly from cache misses.
* With simplified assumptions, use equal penalty for read and write.

```text
CPU time = (program execution cycles + memory stall cycles) x clock cycle time
```

<img src="img/CA3060-6-MemHierarchy_35.png" style="zoom:50%;" />

<img src="img/CA3060-6-MemHierarchy_36.png" style="zoom:50%;" />

---

## Cache Performance Exercise

Given:

* I-cache miss rate = 2%
* D-cache miss rate = 4%
* Miss penalty = 100 cycles
* Base CPI with ideal cache = 2
* Loads and stores are 36% of instructions

Compute the actual CPI and how many times faster it would be with a perfect cache.

---

## Cache Performance Exercise

Given:

* I-cache miss rate = 2%
* D-cache miss rate = 4%
* Miss penalty = 100 cycles
* Base CPI with ideal cache = 2
* Loads and stores are 36% of instructions

Miss cycles per instruction:

* I-cache: `0.02 x 100 = 2`
* D-cache: `0.36 x 0.04 x 100 = 1.44`
* Actual CPI = `2 + 2 + 1.44 = 5.44`
* Speedup with perfect cache = `5.44 / 2 = 2.72x`

Typical CPI of a pipelined processor with perfect caches may be 1.1-1.5. If a benchmark reports a CPI of 10, what is the performance bottleneck?

---

## Average Memory Access Time (1)

* Hit time is also important for performance. A hit may take more than 1 cycle.
* Average memory access time (**AMAT**):
  * Data Cache AMAT = `Hit time + Miss rate x Miss penalty`
  * Overall AMAT = `%instr x Instruction cache AMAT + %data x Data cache AMAT`
* Example:
  * CPU with 1ns clock, hit time = 1 cycle, miss penalty = 20 cycles, cache miss rate = 5%.
  * AMAT = `1 + 0.05 x 20 = 2ns`
  * 2 cycles per instruction.

---

## Average Memory Access Time (1) - L1D Hit Latency

* Hit time is also important for performance. A hit may take more than 1 cycle.
* Data Cache AMAT = `Hit time + Miss rate x Miss penalty`
* Overall AMAT = `%instr x Instruction cache AMAT + %data x Data cache AMAT`

| Typical L1D hit latency today | Latency |
| :- | :-: |
| Intel Skylake / Ice Lake | 4-5 cycles |
| AMD Zen | 4-5 cycles |
| ARM | 3-4 cycles |

Main contributors: VA-to-PA translation / index, tag comparison, alignment, ECC, and forwarding/register path.

---

## AMAT (2)

* Hit time is also important for performance.
* Average memory access time (**AMAT**):
  * Data Cache AMAT = `Hit time + Miss rate x Miss penalty`
  * Overall AMAT = `%instr x Instruction cache AMAT + %data x Data cache AMAT`
* `%instr` is the percentage of instruction accesses among total memory accesses.
* `%data` is the percentage of data accesses among total memory accesses.
* Usually `%instr` is higher than `%data`, but I-cache hits better.
* With SIMD / vector loads and stores, `%data` could be higher than `%instr`.

---

## AMAT No Longer Accurate

* AMAT was a popular and accurate way to estimate memory performance during the 80s-90s.
* It fit systems with:
  * Blocking caches.
  * In-order execution processors.
* AMAT faded away as cache miss latency became hideable through:
  * Out-of-order execution processors.
  * Non-blocking caches with miss-under-miss.
  * Cache prefetching.
  * Split I/D cache.

---

## Low Hit Latency

* Small and simple.
  * Small is fast.
* Direct-map or low associativity.
* Prediction: predict which way to compare first.
* Virtual address cache or virtually indexed, physically tagged cache.
  * Avoid or overlap address translation delay.
* Cache layout closer to CPU to minimize signal delay.

More advanced techniques.

---

## Lower Misses: Associative Caches

* **Fully associative**
  * Allow a given block to go in any cache entry.
  * Requires all entries to be searched at once.
  * Comparator per entry: expensive and slow.
* **n-way set associative**
  * Each set contains `n` entries.
  * Block number determines which set:
    * `(Block number) modulo (#Sets in cache)`
  * Search all entries in a given set at once.
  * `n` comparators: less expensive and fast.

Address view:

```text
Address = [ Cache block / line number ][ Byte offset ]
Set number is selected from the cache block / line number.
```

---

## Pop Quiz

Which of the following statements are true?

1. A fully associative cache is a 1-way cache.
2. A direct-mapped cache is a 1-set cache.
3. A 2-way set associative cache has more sets than a 4-way one.
4. A direct mapped cache has the least tag overhead.
5. A fully associative cache has more cache lines than a direct mapped cache.

**Answer:** 3, 4

---

## Pop Quiz on Set Associative Caches

Which of the following statements are true?

1. A fully associative cache is a 1-way cache.
2. A direct-mapped cache is a 1-set cache.
3. A 2-way set associative cache has more sets than a 4-way one.
4. A direct mapped cache has the least tag overhead.
5. A fully associative cache has more cache lines than a direct mapped cache.

Notes:

* An **N-way cache** means `N` is the number of cache lines per set.
* A **1-way cache** has `N` sets if there are `N` total cache lines.
* One tag per cache line; direct mapped has the least number of tag bits.
* The number of cache lines is determined by cache size and line size.

---

## Associativity Example (1)

Compare **4-block caches**:

* Direct mapped (**1-way**)
* 2-way set associative
* Fully associative (**4-way**)
* Block access sequence: `0, 8, 0, 6, 8`

Direct mapped:

| Block address | Cache index | Hit/miss | Set 0 | Set 1 | Set 2 | Set 3 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| `0 (0000)` | 0 | miss | Mem[0] | | | |
| `8 (1000)` | 0 | miss | Mem[8] | | | |
| `0 (0000)` | 0 | miss | Mem[0] | | | |
| `6 (0110)` | 2 | miss | Mem[0] | | Mem[6] | |
| `8 (1000)` | 0 | miss | Mem[8] | | Mem[6] | |

First miss is compulsory; repeated misses from mapping to the same set are conflict misses.

---

## Associativity Example (2)

2-way set associative with access sequence `0, 8, 0, 6, 8`:

| Block address | Cache index | Hit/miss | Set 0 way 0 | Set 0 way 1 | Set 1 way 0 | Set 1 way 1 |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| `0 (0000)` | 0 | miss | Mem[0] | | | |
| `8 (1000)` | 0 | miss | Mem[0] | Mem[8] | | |
| `0 (0000)` | 0 | hit | Mem[0] | Mem[8] | | |
| `6 (0110)` | 0 | miss | Mem[0] | Mem[6] | | |
| `8 (1000)` | 0 | miss | Mem[8] | Mem[6] | | |

Fully associative with access sequence `0, 8, 0, 6, 8`:

| Block address | Hit/miss | Entry 0 | Entry 1 | Entry 2 | Entry 3 |
| :-: | :-: | :-: | :-: | :-: | :-: |
| 0 | miss | Mem[0] | | | |
| 8 | miss | Mem[0] | Mem[8] | | |
| 0 | hit | Mem[0] | Mem[8] | | |
| 6 | miss | Mem[0] | Mem[8] | Mem[6] | |
| 8 | hit | Mem[0] | Mem[8] | Mem[6] | |

---

## Conflicts in Set-Associative Caches

* In the above example, the cache has only 4 blocks.
* For a direct-mapped cache, the following **block address** sequences cause intensive conflict misses:
  * `0, 4, 8, 12, 16, 20, ...`
  * `1, 5, 9, 13, 17, 21, ...`
  * `2, 6, 10, 14, 18, ...`
* As long as the **distance is a multiple of the cache size**, conflict can happen.
* For set-associative caches, each set can accommodate more lines, so misses can reduce.

---

## Conflict Misses

* Conflict misses occur when multiple lines are mapped to the same set.
  * Their **set select bits / index bits** are identical.
* When the address distance between two lines is a multiple of the cache size, the set selection bits will be identical.
* Example: 4KB direct mapped cache, 64B cache line.
  * There are 64 sets.
  * Address bits:

```text
[31:12] Tag | [11:6] Set selection | [5:0] Byte offset
```

If the distance to another line address is `+4096`, the set selection bits are identical.

---

## Common Cases for Conflict Misses

Assuming direct-mapped caches, cache size 4KB, line size 64B.

* Scenario 1: I-cache
  * Procedure A calls Procedure B, and the distance between A and B is a multiple of 4K.
* Scenario 2: D-cache

```c
float A[1024][1024];
// loop on j
B[i] = A[i][j] + A[i+1][j];
```

* Scenario 3: D-cache

```c
double A[1024], B[1024], C[1024];
for (i) {
    C[i] = A[i] + B[i];
}
```

---

## Common Cases for Conflict Misses

Assuming direct-mapped caches, cache size 4KB, line size 64B.

* Scenario 1: I-cache
  * Procedure A calls Procedure B, and the distance between A and B is a multiple of 4K.
* Scenario 2: D-cache

```c
float A[1024][1024];
// loop
B[i] = A[i][j] + A[i+1][j];
```

* Scenario 3: D-cache

```c
double A[1024], B[1024], C[1024];
for (i) {
    C[i] = A[i] + B[i];
}
```

Code repositioning:

* Layout B next to A.
* `A[1024][1040]`
* `A[1024], Dummy0[8], B[1024], Dummy1[8], C[1024]`
* This may not always work because the compiler may remove unused dummy arrays.

---

## Cache Block Replacement

* Direct mapped: no choice; each set has only one line.
* Set associative or fully associative:
  * Random.
  * **LRU (Least Recently Used)**
    * Hardware keeps track of access history and replaces the block that has not been used for the longest time.
  * Pseudo-LRU example for a two-way set associative cache:
    * Use a pointer to point at each block in turn.
    * Whenever accessing the block that the pointer points at, move the pointer to the next block.
    * When replacement is needed, replace the block currently pointed at.
  * **FIFO (First-In First-Out)**
    * Replaces older data.

True LRU needs a stack, but stack operations are expensive.

Example: a set has 3 blocks. A calls B, B returns, A calls C, C calls D. The set now has A, B, C. When D is referenced, which block should be replaced? LRU -> B, FIFO -> A.

---

## Cache Block Replacement

General LRU strategy implementation:

* For a 4-block/set cache, use a `log2(4) = 2` bit counter for each block.
* Reset the counter to 0 whenever the block is accessed.
* Counters of other blocks in the same set should be incremented.
* On cache miss, replace / uncache a block with a counter reaching 3.

Optimal replacement:

* **Belady's algorithm**
  * Replace the block that will be referenced in the farthest future.
  * Or replace the item not needed for the longest time.
  * This gives the optimal hit rate, but not necessarily the least memory traffic because replacing a clean block is cheaper.
* Not implementable because we do not know the future.

---

## A Case that DM is Better than FA

If a loop has 5 cache lines: line 0, line 1, line 2, line 3, line 4.

* Direct-mapped cache with 4 blocks:
  * Line 0 and line 4 map to the same set.
  * Line 1, line 2, and line 3 each map to a different set.
  * Hit rate is 60%: line 1, line 2, and line 3 hit; line 0 and line 4 conflict all the time.
* Fully associative cache with LRU:
  * Hit rate is 0%.
  * Access pattern: `0,1,2,3,4`, then line 4 replaces 0; 0 misses and replaces 1; 1 misses and replaces 2; 2 misses and replaces 3; ...

Questions:

* Why not consider random replacement?
* What could be a better combination? Some adaptive approach?

---

## Classifying Cache Misses (3 C’s or 4 C’s)

* **Compulsory / cold miss**
  * When a piece of data is requested for the first time and needs to be brought into cache.
  * Example: `1, 4, 3, 5, 7`
* **Conflict / collision miss**
  * Multiple references map to the same set, and the set is not large enough to hold them.
  * Example: `3, 4, 8, 11, 12, 19, 4`
* **Capacity miss**
  * Cache is not large enough to hold the needed blocks.
  * Example: `1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9`
* **Coherency miss**
  * Occurs when invalidation requests are issued by other processors in a multiprocessor system to maintain coherence of cached data.

---

## Pop Quiz

My application experiences intensive conflict misses. After reviewing the computer configuration, I discovered that the L1 cache is direct-mapped. Which of the following may reduce the cache misses in my application?

1. Get a larger L1 cache.
2. Get a higher associative L1 cache.
3. Get a larger line size.
4. Get a larger tag size.
5. Redesign the algorithm of the application.

**Answer:** 1, 2, 5

---

## Pop Quiz

Assume the L1 cache is 4KB and the line size is 64B.

Array A and B are defined as `double int A[4096], B[4096];`

Which loops will encounter frequent conflict misses if the cache is direct-mapped?

```c
for (i = 0; i < n; i++) A[i] = B[i];

for (i = 0; i < n; i++) A[i] = A[i-1] + A[i+1];

for (i = 0; i < n; i++) A[i] = 0;

for (j = 0; j < m; j++)
    for (i = 0; i < 2048; i++) A[i] += A[i+1024] * 100;
```

**Answer:** 1, 4

---

## Victim Cache

![](img/CA3060-6-MemHierarchy_12.png)

* A small fully-associative backup cache, called a **victim cache**, can be added to a direct-mapped L1 cache to hold recently evicted cache lines.
* It defends against repeated access patterns with multiple power-of-two addresses that cause intensive conflict misses.
* The victim cache is small, usually 4-8 lines, so it can be accessed quickly.

Consider the sequence:

```text
0, 4, 8, 2, 3, 12, 4, 8, 0, 12, 4, 0, 5, 6, ...
```

`0, 4, 8, 12` may map to the same set, so the hit rate is low, but all of them could sit in the victim cache.

---

## Victim Cache

![](img/CA3060-6-MemHierarchy_13.png)

* A victim cache is a small fully-associative backup cache added to a direct-mapped L1 cache.
* It holds recently evicted cache lines.
* It helps when conflict misses occur within a small number of sets.
* It combines the advantage of a direct-mapped cache with the benefit of a fully associative cache.

---

## Associativity and Miss Rates

* In general, increased associativity decreases miss rate.
  * But with diminishing returns.
* Simulation of a system with 64KB D-cache, 16-word blocks, SPEC2000:
  * 1-way: 10.3%
  * 2-way: 8.6%
  * 4-way: 8.3%
  * 8-way: 8.1%

---

## Cache Sizes and Associativity

![](img/CA3060-6-MemHierarchy_14.png)

---

## DM+VC or Two-way Associative Cache?

Both direct-mapped cache enhanced with a victim cache and two-way set-associative cache can reduce conflict misses. Which one is better?

* **Victim cache**
  * Good at handling repetitive references to clustered conflict misses.
  * Higher temporal locality.
  * Example: `4,8,12,16,20,24,4,8,12,16,20,...`
* **Two-way set-associative cache**
  * Good at handling evenly distributed conflict misses from many sets.
  * Lower temporal locality.
  * Example: `4,8,4,7,11,15,8,6,10,8,6,7,8,11,10,15,...`

In general-purpose systems such as desktops, servers, and laptops, **two-way set associative caches** are far more common. Direct-mapped caches plus victim cache are more specialized and typically found in embedded systems, older designs, or cost-driven applications.

Assume the cache has 4 lines. Lines 4, 8, and 12 are block addresses. Line 4 and line 8 map to the same set. Lines 7, 11, 15 map to the same set. Lines 6 and 10 map to the same set.

---

## Improving Cache Performance

* Reduce the cache hit time.
* Decrease the cache miss ratio.
* Decrease the cache miss penalty.

```text
Average memory access time = hit time + miss-rate x miss-penalty
```

---

## Multilevel Caches

* Primary cache attached to the CPU:
  * Small, but fast.
* Level-2 cache services misses from the primary cache:
  * Larger, slower, but still faster than main memory.
* Main memory services L2 cache misses.
* High-end systems often include an L3 cache.
  * L3 cache is usually shared by multiple cores on the same chip.
* Still need to keep consistency between different cache levels.

---

## Multilevel Cache AMAT

* `AMAT = L1 hit time + L1 miss rate x L1 miss penalty`
* `L1 miss penalty = L2 hit time + L2 miss rate x L2 miss penalty`
* So in total:
  * `AMAT = L1 hit time + L1 miss rate x (L2 hit time + L2 miss rate x L2 miss penalty)`
* Beware: the L2 miss rate here is a **relative miss rate**, the ratio of L1 misses that also miss in L2.
* Typical hit rates, approximate:
  * L1 Cache: 80-95%
  * L2 Cache: 50-80%, because L2 accesses are L1 misses.
  * L3 Cache: 20-40%, because L3 accesses are L2 misses and are tough memory references.

---

## Multilevel Cache Example (1)

Given:

* CPU base CPI = 1, clock rate = 4GHz.
* Miss rate / instruction = 2%.
* Main memory access time = 100ns.

With just primary cache (L1):

* Miss penalty = `100ns / 0.25ns = 400 cycles`.
* Effective CPI = `1 + 0.02 x 400 = 9`.

---

## Multilevel Cache Example (2)

Now add L2 cache:

* L1 miss rate to L2 = 2%.
* L2 access time = 5ns, access to memory = 100ns.
* L2 miss rate to main memory = 50%.
* Primary miss with L2 hit:
  * Penalty to access L2 = `5ns / 0.25ns = 20 cycles`.
* Primary miss with L2 miss, assuming 80% hit in L2:
  * Penalty to access memory = 400 cycles.
* CPI = `1 + 0.02 x 20 + 0.02 x 0.2 x 400 = 1.4 + 1.6`.
* Performance ratio = `9 / 3 = 3`.

Once again, AMAT is only an approximation. It is not accurate when cache miss penalty can be overlapped with other instruction execution.

---

## Multilevel Cache Considerations

* **L1 cache**
  * Focus on minimal hit time; it must be fast.
  * Spatial locality is more important.
  * Write-through to L2 is one option.
* **L2 cache**
  * Focus on low miss rate to avoid going to main memory.
  * Reduces latency, memory traffic, and bus traffic.
  * Hit time has less overall impact.
  * Temporal locality is more important.
  * Write-back is more common.

---

## Alternatives to Reduce Cache Miss Penalty

* **Critical word first and early restart**
  * Fetch the requested critical word from memory before the rest of the cache line, and resume execution immediately after receiving the critical word.
* **Non-blocking caches**
  * Allow multiple misses to overlap.
* **Cache prefetching**
  * Trigger the miss earlier.
* **Write buffer for copy-back cache**
* **Cache-aware code scheduling**
  * Attempt to hide the miss penalty.

---

## Cache Coherence in Multiprocessors

With a **write-back cache policy**, multiple processors can have private cached copies of the same memory block.

```text
Processor + Cache    Processor + Cache    Processor + Cache    Processor + Cache
          \              |                  |                  /
                           Memory
```

The coherence problem starts when one cached copy changes but other cached copies or memory still contain old values.

---

## Cache Coherence in Multiprocessors

With a **write-back cache policy**:

1. Multiple processors cache `u:5`.
2. One processor updates its cached copy.
3. Other processors or memory may still hold the stale value.

This creates the need for a coherence protocol.

---

## Potential Problem (Data Coherence)

With a **write-back cache policy**:

* Processor P writes `u = 7` in its cache.
* Memory may still contain `u:5`.
* Other processors may have cached `u:5`.

Question shown in the PPT:

```text
u = ?
u = ?
u = 7
```

---

## Incoherent Data

**Write through doesn't help!**

Even if writes reach memory, other processors can still hold stale cache copies unless the coherence protocol invalidates or updates those copies.

```text
P writes u:7
Other cache copies may still contain u:5
Observed values can become incoherent without coherence handling.
```

---

## Snoopy Cache Coherence Schemes

![](img/CA3060-6-MemHierarchy_16.png)

* Basic idea:
  * All coherence-related activities are broadcast to all processors, for example on a **global bus**.
  * Each processor, or cache controller, monitors / **snoops** these actions and reacts to those relevant to its cache contents.
* Examples:
  * If one processor wants to write to a cache line, it must **invalidate** all copies in other caches.
  * If another processor wants to read a line for which this cache has a dirty copy, this cache must supply and share the copy.
* Example machines:
  * SGI Challenge, SUN Enterprise, multiprocessor PCs, etc.

---

## Implementing a Snoopy Protocol

* Cache controller receives inputs from both sides:
  * Requests from processor.
  * Bus requests / responses from snooper in cache controller.
* In either case, it takes zero or more actions:
  * Updates state.
  * Responds with data.
  * Generates new bus transactions.
* Protocol is a **distributed algorithm**: cooperating state machines.
  * Set of states.
  * State transition diagram.
  * Actions.
* Granularity of coherence is a **cache block**.
  * Similar to allocation in cache and transfer to/from cache.

MESI protocol states:

* M: Modified
* E: Exclusive
* S: Shared
* I: Invalid

---

## Directory Based Cache Coherency

* Snoopy cache protocol is not scalable.
  * It relies on a global bus.
* For larger systems with hundreds or thousands of processors:
  * A centralized or distributed directory tracks which processors have copies of each cache line.
  * When a processor wants to access a cache line, it consults the directory to determine the line's state and where other copies are.
* Advantages:
  * Scalability: more scalable than snoopy protocols for large systems.
  * Reduced traffic: avoids broadcasts and lowers network contention.
  * Flexibility: adaptable to different system architectures and memory organizations.
* Disadvantages:
  * Complexity.
  * Potentially longer latency.
  * Directory overhead, requiring more memory bits.

---

## Exclusive/Inclusive Caches

* **Inclusive caches**, assuming L1/L2:
  * Every line in L1 must be present in L2.
* **Exclusive caches**:
  * If a line `A` is in L1, it must **not** be present in L2.
  * L1 and L2 are exclusive.

---

## Advantages of Exclusive/Inclusive Caches

* **Inclusive caches**, assuming L1/L2:
  * In a multiprocessor architecture with private L1 caches, when a processor issues a write request to its L1, it must invalidate corresponding cache lines in other processors' L1 caches.
  * With an inclusive L2 cache, the invalidation check can be performed in L2, which usually has more cycles available to manage coherence traffic.
* **Exclusive caches**:
  * Inclusion duplicates lines: L1 lines must be duplicated in L2.
  * If L1 is 16KB and L2 is 64KB, then 25% of L2 cache space is wasted.
* More modern processors use inclusive caches than exclusive caches.

---

## Special Operations of Exclusive/Inclusive Caches

* **Inclusive caches**, assuming L1/L2:
  * If L2 evicts a line, it must invalidate the corresponding line in L1.
* **Exclusive caches**:
  * If L1 evicts a line, this line moves to L2.
  * If both L1 and L2 miss, the new line moves from main memory and is placed in L1 only.
  * If L1 misses but L2 hits, the L2 line **migrates** to L1.
* Inclusive caches allow lower-level caches to have larger line sizes.
* Exclusive caches usually have the same cache line size.

---

## Operations of Inclusive Caches

Cases in the PPT:

1. Initial state.
2. `X` miss in L1.
3. `Y` miss in L1.
4. `X` evicted from L1.
5. `Y` evicted from L2.

Key point: with inclusive caches, if L2 evicts a line that is also present in L1, L1 must be **back-invalidated**.

---

## Operations of Exclusive Caches

Cases in the PPT:

1. Initial state.
2. `X` miss in L1: `X` moves from memory to L1 directly.
3. `Y` miss in L1.
4. `X` evicted from L1: `X` must be placed in L2.

Key point: with exclusive caches, a line should live in either L1 or L2, not both.

---

## Interactions with Advanced CPUs

* Out-of-order (OOO) CPUs can execute instructions during a cache miss.
  * Independent instructions continue.
  * With non-blocking caches, OOO can trigger multiple cache misses to overlap.
* The effect of a cache miss depends on program data flow.
  * Much harder to analyze.
  * Use system simulations; this is why you need to know how to write `$`-simulator.
  * Collect cache miss profiles.
  * Cache misses are likely to be correlated. Imagine an AI-based cache prefetcher: is it possible to use ML to detect such correlations?

---

## Interactions with Software

* Figure **a** shows that when data size is large, Radix sort needs fewer operations than quicksort.
* Figure **b** shows that when data size is large, Radix sort is not faster in runtime.
* Figure **c** shows that when data size is large, Radix sort suffers from more cache misses.

<img src="img/CA3060-6-MemHierarchy_17.png" style="zoom:25%;" />

---

## Interactions with Software

* Figure **a**: Radix sort needs fewer operations than quicksort for large data.
* Figure **b**: Radix sort is not faster in runtime for large data.
* Figure **c**: Radix sort suffers from more cache misses for large data.

<img src="img/CA3060-6-MemHierarchy_20.png" style="zoom:25%;" />

**Locality matters!!**

---

## Application of Caches

**Akamai** is a global content delivery network (CDN) provider that delivers content quickly and reliably to users. Due to rapid growth, they encountered a scale-up problem in the late 90's: network traffic jams caused serious performance impact for customers. How did they solve it?

**Cache:** contents are cached at distribution stations.

**GPU** tends to have a very large register file. For example, Nvidia 4090 has 144 SMs; each SM has 4 SPs, and each SP has 16K registers. The 16K registers are shared by multiple warps, each warp is a group of 32 threads. If 8 warps interleave, then `16K / 32 / 8 = 64`, meaning each thread can have only 64 registers. If you want more warps to interleave and more threads per warp, you need even more registers. With such a large register file, register access time increases. What should you do if access time increases to 10 clock cycles?

**Cache:** use a cache to speed up register accesses.

The register number is the address of each cache reference.
