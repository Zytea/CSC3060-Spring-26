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

**<img src="C:\Users\Zytea\Desktop\CSC 3060\img\CA3060-6-MemHierarchy_32.png" alt="CA3060-6-MemHierarchy_32" style="zoom: 50%;" />**

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

<img src="C:\Users\Zytea\Desktop\CSC 3060\img\CA3060-6-MemHierarchy_33.png" alt="" style="zoom: 50%;" />

## Exercise 3: A Case for Direct Mapped Cache

Assuming 32b addresses, how many ==a) tag bits== and ==b) number of sets== are used for the following direct-mapped caches?

<img src="C:\Users\Zytea\Desktop\CSC 3060\img\CA3060-6-MemHierarchy_34.png" alt="CA3060-6-MemHierarchy_34" style="zoom: 50%;" />

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
