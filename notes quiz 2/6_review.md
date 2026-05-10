# Lec 6: Memory Hierarchy & Caches

## Exam Facts

- ==**Memory wall**== = growing gap between **CPU speed** and **DRAM** speed (latency + bandwidth).
  - **Latency wall** mitigation: caches/local memory, NUMA, PIM, **multi-threading/SMT**, WARP interleaving.
  - **Bandwidth wall** mitigation: **HBM**, multiple banks, wider bus, non-blocking caches.
- **Hierarchy management**:
  - Registers ↔ Mem: **compiler / programmer**.
  - **Cache ↔ Mem: hardware**. (Local/scratchpad: compiler/programmer.)
  - Mem ↔ Disk: **HW + OS** (virtual memory) / programmer (files).
- ==Cache line stores: **data + tag + valid bit (+ dirty bit if write-back)**==. **NOT** the set number (it's implied by index).
- Address breakdown for cache: ==**offset = log2(block size)**, **#sets = cache size/(block size × ways)**, **index = log2(#sets)**, **tag = addr_bits − index − offset**==.
- ==**Modern L1D**==: typically **set-associative, write-back, write-allocate**, hit ≈ **3–4 cycles**.
- L3 is **usually shared** by all cores. L3 write-through doesn't make sense.
- **Most chip area is dedicated to caches.**
- ==**Non-blocking cache**==: uses **MSHR** (Miss Status Holding Register) to track in-flight misses; supports **MLP**. L3 MSHR count depends on **memory latency + bus width**.
- **4 C's of cache misses**: ==**Compulsory (cold), Conflict (collision), Capacity, Coherence**==. **Hardest to remove: coherence.**
- **DRAM tech for high-end GPU**: ==**HBM**==.
- I-cache easier than D-cache because **I-cache doesn't take stores**.
- Linked list traversal `while(A) A=A->next`: only **instruction temporal+spatial** locality; **no data spatial/temporal** locality; latency-bound.
- High-locality sorts: **Quicksort, Insertion sort, Bubble sort**. Low-locality: heapsort, radix (large data).
- Set index uses **middle bits** of address (not high bits — high bits would waste spatial locality).

## 6.1 RAM and Memory Wall

| | Trans/bit | Refresh? | Density | Speed | Use |
|---|---|---|---|---|---|
| **SRAM** | 6–8 | NO | low | fast (0.5–2.5 ns) | caches, regfile |
| **DRAM** | 1 (1T1C) | YES | high | slow (50–70 ns) | main memory |
| **HBM** | DRAM stacked | yes | very dense | high BW | GPU memory |

> SRAM: state held by transistor cross-couple → no refresh.
> DRAM: charge on capacitor → must refresh periodically. RAS (row) → row buffer; CAS (column) → cell.

**Memory wall = (CPU speed - DRAM speed) gap is widening:**
- **Latency wall**: longer access times relative to CPU clock.
- **Bandwidth wall**: insufficient throughput.

| Wall | Mitigation |
|---|---|
| Latency | caches, local memory, NUMA, PIM, multi-threading, WARP interleaving |
| Bandwidth | HBM, multi-banks, interleaved memory, wider bus, non-blocking caches |

## 6.2 Memory Hierarchy

| Level | Storage | Trend |
|---|---|---|
| L0 | Registers | small / fast / expensive |
| L1 | L1 SRAM (split I/D) | ↓ |
| L2 | L2 SRAM (unified) | ↓ |
| L3 | L3 SRAM (shared by cores) | ↓ |
| L4 | DRAM | ↓ |
| L5 | SSD/HDD | ↓ |
| L6 | Remote storage | large / slow / cheap |

> Each level **caches** the next-lower level. "Fast + Large + Cheap" memory does not exist — hierarchy gives the *illusion*.

### Who manages what

| Boundary | Manager |
|---|---|
| Registers ↔ Memory | **compiler/programmer** |
| **Cache ↔ Memory** | **hardware** |
| Local/Scratchpad ↔ Memory | compiler/programmer |
| Memory ↔ Disk (VM, paging) | **HW + OS** |
| Memory ↔ Disk (files) | programmer |

### Terminology

- ==**Block / line**==: unit of transfer (typically 32–64 B).
- **Hit / Miss**: in upper level / not.
- **Hit rate**, **Miss rate** = 1 − hit rate.
- **Hit time << Miss penalty**.

## 6.3 Cache Basics & Address Breakdown

### Cache line contents

==**[ Valid bit | Tag | Data ]**== (+ **Dirty bit** for write-back).

> Quiz trap: **"Set number" is NOT stored** — it's implied by the index of the line within the cache.

### Address breakdown (capacity C, block B, ways E)

$$
S = \frac{C}{B \cdot E}\quad
b = \log_2 B\quad
s = \log_2 S\quad
t = A - b - s
$$

| Bits | Layout |
|---|---|
| `[ Tag (t) | Index (s) | Offset (b) ]` | offset = low bits, **index = middle bits**, tag = high bits |

> [!IMPORTANT] **Why index uses MIDDLE bits, not HIGH bits**:
> - Adjacent blocks share high bits → if index used high bits, they'd all map to the same set, killing spatial locality.

### Examples

| Cache | Calc | Result |
|---|---|---|
| **64KB, 4-way, 32B line, 32b addr** | $S = 65536/(4·32)=512$ | offset 5 / index 9 / **tag 18** |
| **16KB, DM, 64B line, 32b addr** | $S = 16384/64 = 256$ | offset 6 / index 8 / **tag 18** |
| **4KB, 2-way, 32B line** | $S = 4096/(2·32) = 64$ | offset 5 / index 6 / tag 21 |

### Simulation algorithm (block-by-block)

```
block# = addr / B
set    = block# mod S
tag    = block# / S
hit iff (valid line in set, tag matches)
```

> Quiz pattern: 4 addresses `0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010` in 4KB 2-way 32B: all map to **same set** with different tags ⇒ **conflict miss**.

## 6.4 Placement / Associativity

| Type | Ways | Sets | Compare | Pros | Cons |
|---|---|---|---|---|---|
| **Direct-mapped (DM)** | 1 | many | 1 cmp | fast, low tag overhead, simplest replacement | lots of conflicts |
| **N-way set assoc.** | N | C/B/N | N cmps | fewer conflicts | slower, more tag |
| **Fully assoc.** | all | 1 | all cmps | lowest miss rate (often) | slow, expensive |

> [!IMPORTANT] Quiz "always true":
> - **DM has lowest tag overhead** ✓
> - **DM has simplest replacement** ✓
> - "DM is faster" — *not always* (associative can be small-fast).
> - "FA has lowest miss rate" — *not always* (LRU vs Belady; counterexample below).

### Counterexample: DM beats FA

5-line loop in 4-block FA-LRU: **0% hit**. In 4-block DM where lines 1,2,3 differ in set: **60% hit**.

### Increase associativity diminishing returns (SPEC2000, 64KB, 16-word blocks)

| Way | Miss rate |
|---|---|
| 1 | 10.3% |
| 2 | 8.6% |
| 4 | 8.3% |
| 8 | 8.1% |

### Reduce conflict misses

| Method | Note |
|---|---|
| Larger cache | helps capacity + conflict |
| Higher associativity | helps conflict (not necessarily capacity) |
| **Victim cache** (small FA after DM L1) | catches recently-evicted DM lines |
| Algorithm redesign | most powerful |

> Direct-mapped + victim cache = combines DM speed/cost with FA-like backup against burst conflict.

## 6.5 Block Size Tradeoffs

| Larger block | Pro | Con |
|---|---|---|
| | better spatial locality, less tag overhead, fewer compulsory misses | larger miss penalty, more bandwidth, **fewer blocks → temporal-locality loss + more conflict/pollution** |

> **Critical-word-first / early-restart** can hide miss-penalty for big lines.
> Branches make huge lines wasteful (only first block executed) — prefetch is more flexible.

## 6.6 Write Policies

### On write hit

| Policy | Behavior |
|---|---|
| ==**Write-through**== | write cache + memory simultaneously; consistent, simple |
| ==**Write-back**== | write cache only; memory updated on eviction; needs **dirty bit** |

> Write-through saturates memory bandwidth → mitigate with **write buffer** (FIFO, ~4 entries; coalesces).
> Modern caches mostly **write-back**.

### On write miss

| Policy | Behavior | Best for |
|---|---|---|
| ==**Write-allocate**== | fetch block into cache then write | reuse-likely (locals, struct fields) |
| ==**No-write-allocate / write-around**== | write straight to memory, bypass cache | **streaming writes** — `memset(a,0,n)`, `memcpy`, **database logs** |

> [!IMPORTANT] Modern L1D = **write-back + write-allocate**. Streaming writes flag `no-allocate` per-instruction.

### I-cache simpler

I-cache **takes no stores from CPU** ⇒ no write policy needed. JIT/code-patching modifies memory through D-cache and must:
- **Flush I-cache lines** (invalidate stale instructions),
- **OR** maintain I/D coherence so D-cache writes also update I-cache.

## 6.7 Cache Performance

### CPU stall cycles

```
Memory stall cycles = #accesses × miss rate × miss penalty
                   = IC × %mem-instr × miss rate × miss penalty
```

### Worked example

I-miss=2%, D-miss=4%, penalty=100, base CPI=2, mem-instr=36%:
- I-stall/inst = 0.02 × 100 = 2
- D-stall/inst = 0.36 × 0.04 × 100 = 1.44
- **Actual CPI = 2 + 2 + 1.44 = 5.44**
- Speedup with perfect cache = 5.44/2 = **2.72×**

### Single-cycle quiz

Base CPI = 1, D-miss = 5%, mem-instr = 40%, penalty = 100:
$\text{CPI} = 1 + 0.4 \times 0.05 \times 100 = 1 + 2 = 3.0$.

### AMAT

==**AMAT = hit time + miss rate × miss penalty**==

Multilevel: $\text{AMAT} = T_{L1} + m_{L1}(T_{L2} + m_{L2}(T_{L3} + m_{L3} T_{mem}))$

> [!IMPORTANT] AMAT was accurate in blocking-cache + in-order era. Now **OoO + non-blocking + prefetching** can hide miss latency → AMAT often pessimistic.

## 6.8 Reduce Misses (4 C's)

| Type | Cause | Fix |
|---|---|---|
| ==**Compulsory (cold)**== | first access | **prefetch, larger line** |
| ==**Conflict (collision)**== | bucket overflow | **larger cache, higher assoc., victim cache, algorithm** |
| ==**Capacity**== | working set > cache | **larger cache, blocking/tiling, prefetch** |
| ==**Coherence**== | invalidations from other procs | hardest — fundamental for shared writable data |

> [!IMPORTANT] **Coherence misses are the hardest to remove.**

### Reduce miss penalty

- **Critical-word-first / early restart**.
- **Non-blocking cache** (overlap multiple misses).
- **Cache prefetching**.
- **Write buffer** for write-back.
- **Cache-aware code scheduling**.

### Bandwidth-heavy features

> Quiz: "Which features need MORE bus/memory bandwidth?"
> ==**Large lines, prefetching, non-blocking caches, write-through**== ✓ (NOT exclusive multi-level write-back).

## 6.9 Replacement Policies

- **DM**: no choice (simplest).
- **Set-assoc.**: typically ==**Approximate LRU**== (true LRU expensive).
- **True LRU** uses a **stack** of access order; expensive.
- **FIFO**: replace oldest insertion.
- **Random**: cheap, surprisingly competitive.
- ==**Belady (optimal)**==: replace block referenced **furthest in future**. Not implementable; **upper bound for evaluating new algorithms**.

> Quiz: ML-balanced cache replacement → evaluate against **Belady's algorithm**.

## 6.10 Multi-Level Caches

| Level | Goal | Properties |
|---|---|---|
| **L1** | minimal hit time (~3–4 cyc) | small, often **split I/D**, write-back, write-allocate |
| **L2** | low miss rate, balance | larger, **slower, unified**, write-back |
| **L3** | reduce memory traffic | **shared by cores**, biggest, slowest on chip |

| | Inclusive | Exclusive | NINE |
|---|---|---|---|
| Property | L1 ⊂ L2 | L1 ∩ L2 = ∅ | neither |
| Coherence | easier (L2 invalidate ⇒ L1) | harder | flexible |
| Capacity | wastes (duplicates) | maximum | medium |
| Common | L1/L2 | (AMD) L2/L3 | L2/L3 in many CPUs |
| Project #4 | — | — | **NINE** ✓ |

> [!IMPORTANT] Nonsense traps (multi-level configs that DON'T make sense):
> - **L1I write-back / copy-back** (I-cache has no stores).
> - **L3 write-through** (would saturate memory bus).
> - **L1D 4-way + L2 direct-mapped** (DM L2 below assoc. L1 → bad inclusion).
> - **L1/L2 exclusive + L2/L3 inclusive** (chain conflict).

## 6.11 Cache Coherence (Multi-processor)

- Private caches with shared writable data → must synchronize.
- ==**Snoopy protocol**==: all caches watch the bus; on writes, invalidate or share.
  - generates **significant snooping bus traffic**.
- ==**MESI**== states: Modified / Exclusive / Shared / Invalid.

> Quiz: "4 procs on a bus, how to maintain coherence?" → **shared cache (no private)** OR **snoopy** with private caches.

## 6.12 TLB / Virtual Memory + Locality

- ==**TLB**== caches **VPN→PPN** translations (in MMU).
- VA = `[ VPN | VPO ]`, PA = `[ PPN | PPO ]`, with ==**VPO = PPO**== (page offset unchanged).
- For page size $2^p$: **offset = p bits**.
- TLB layout: ==**TLBI = low bits of VPN; TLBT = remaining VPN bits**==.
- TLB miss → page-table walk → if PTE valid=0 → **page fault** → OS loads page from disk → fill TLB.

### Worked TLB example

(Following CMU final-f12 #9)

```
20-bit VA, 1024B pages → VPN [19:10], VPO [9:0]
TLB has 8 sets → TLBI = 3 bits → TLBT = remaining 7 VPN bits
```

For VA `0x078E6 = 0000 0111 1000 1110 0110`:
- VPO = `00 0110 0110` (low 10b)
- VPN = `0000011110` (top 10b) = `0x01E`
- TLBI = `110` = **6**
- TLBT = `0000011` = **3**
- Look up TLB set 6, tag 3 → if hit, get PPN; build PA = PPN | VPO.

### Page-table size

- Single-level page table entries = **virtual address space / page size**.
- Larger pages: fewer PTEs, **fewer TLB misses**, but worse **internal fragmentation** and bigger transfer cost on page fault.

## 6.13 Locality / Applications

### Linked list `while(A) A=A->next`

- ==Only **instruction temporal + spatial** locality== (loop body reused).
- ==**No data spatial or temporal locality**==.
- Latency-bound (pointer chasing).
- Quiz answer: D, E (instruction temporal + spatial only).

### Row-major C arrays

- `A[i][j]` with `j` increasing → contiguous → good spatial.
- Transpose: read row of A, write column of B → write side has poor spatial → use **blocking/tiling**.

### Sorting locality

| Sort | Locality |
|---|---|
| **Quicksort** | high (partition stays in cache) ✓ |
| **Insertion sort** | high ✓ |
| **Bubble sort** | high ✓ |
| Heapsort | low (random tree access) |
| Radix (large data) | low (multi-pass over big array) |

### HW vs SW Cache

| | HW cache | SW cache (e.g., disk file cache) |
|---|---|---|
| Managed by | hardware | system SW / app |
| Search | **associative** | hash table / lookup |
| Replacement | simple+fast | can use complex policy |
| Size flexibility | fixed | can grow |

## 6.14 Examples & Applications

- **Akamai (CDN)**: caches at edge stations.
- **GPU (Nvidia 4090)**: 144 SMs × 64K registers — register file too large to access in 1 cycle ⇒ use **register-file cache**.
- **Project #4** uses **NINE** multi-level cache.
