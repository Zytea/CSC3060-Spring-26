# Lec 6: Memory Hierarchy & Caches

## Exam Facts

- ==**Memory wall**==: gap between **CPU speed** and **DRAM** speed (latency + bandwidth).
  - **Latency wall** fix: caches/local memory, NUMA, PIM, **multi-threading/SMT**.
  - **Bandwidth wall** fix: ==**HBM**==, multi-banks, wider bus, non-blocking caches.
- **Hierarchy management**: registers/local mem by **compiler/programmer**; ==**cache by HW**==; mem↔disk by **HW+OS** (VM) / programmer (files).
- ==Cache line stores: **data + tag + valid (+ dirty if write-back)**==. **NOT** the set number.
- Address breakdown: ==**offset = log2(block); #sets = C/(B·E); index = log2(sets); tag = addr − index − offset**==.
- ==**Modern L1D**==: typically **set-associative, write-back, write-allocate**; hit ≈ **3-4 cyc**.
- L3 usually **shared by cores**; L3 write-through doesn't make sense.
- ==**Most chip area = caches**==.
- ==**Non-blocking cache**==: uses **MSHR**; supports **MLP**. L3 MSHR count depends on **memory latency + bus width**.
- **4 C's**: ==**Compulsory (cold), Conflict (collision), Capacity, Coherence**==. Hardest to remove: ==**coherence**==.
- **DRAM for high-end GPU**: ==**HBM**==.
- I-cache easier than D-cache: **I-cache takes no stores**.
- Linked-list `while(A) A=A->next`: only **I-temporal+I-spatial** locality; NO data spatial/temporal; latency-bound.
- High-locality sorts: **Quicksort, Insertion, Bubble**. Low-locality: heapsort, large radix.
- Set index uses ==**middle bits**== (high bits would kill spatial locality).

## 1. RAM and Memory Wall

| | Trans/bit | Refresh | Density | Speed | Use |
|---|---|---|---|---|---|
| **SRAM** | 6-8 | NO | low | 0.5-2.5 ns | caches, regfile |
| **DRAM** | 1 (1T1C) | YES | high | 50-70 ns | main memory |
| **HBM** | DRAM stacked | yes | very dense | high BW | GPU memory |

> SRAM: cross-coupled inverters → no refresh. DRAM: capacitor charge → refresh. Read: RAS (row→buffer), CAS (column→cell).

==**Memory wall**==: latency wall (longer access vs CPU clock) + bandwidth wall (insufficient throughput).

| Wall | Mitigation |
|---|---|
| Latency | caches, local mem, NUMA, PIM, multi-threading, WARP interleave |
| Bandwidth | ==HBM==, multi-banks, interleaved memory, wider bus, non-blocking caches |

## 2. Memory Hierarchy

| Level | Storage | Trend |
|---|---|---|
| L0 | Registers | small/fast/expensive |
| L1 | SRAM (split I/D) | ↓ |
| L2 | SRAM (unified) | ↓ |
| L3 | SRAM (shared by cores) | ↓ |
| L4 | DRAM | ↓ |
| L5 | SSD/HDD | ↓ |
| L6 | Remote | large/slow/cheap |

> Each level **caches** the next. "Fast+Large+Cheap" memory does not exist — hierarchy gives only the *illusion*.

### 2.1 Who Manages What

| Boundary | Manager |
|---|---|
| Registers ↔ Memory | **compiler/programmer** |
| ==**Cache ↔ Memory**== | ==**HW**== |
| Local/Scratchpad | compiler/programmer |
| Memory ↔ Disk (VM, paging) | **HW + OS** |
| Memory ↔ Disk (files) | programmer |

### 2.2 Terminology

- ==**Block / line**==: unit of transfer (32-64 B).
- **Hit / Miss**: in upper level / not. **Miss penalty**, **Miss rate** = 1 − hit rate.
- **Hit time << Miss penalty**.

## 3. Cache Basics & Address Breakdown

### 3.1 Cache Line Contents

==**[ Valid bit | Tag | Data ]**== (+ **Dirty bit** for write-back).

> Quiz trap: **"Set number" is NOT stored** — it's implied by the index.

### 3.2 Address Breakdown (capacity C, block B, ways E)

$$S = \frac{C}{B \cdot E}\quad b = \log_2 B\quad s = \log_2 S\quad t = A - b - s$$

Layout: `[ Tag (t) | Index (s) | Offset (b) ]`.

> [!IMPORTANT] Why index uses **MIDDLE bits**: adjacent blocks share high bits → if index used high bits, all map to the same set, killing spatial locality.

### 3.3 Examples

| Cache | Calc | Tag/Index/Offset |
|---|---|---|
| 64KB, 4-way, 32B line, 32b addr | S = 65536/(4·32)=512 | **18 / 9 / 5** |
| 16KB, DM, 64B line, 32b | S = 16384/64 = 256 | 18 / 8 / 6 |
| 4KB, 2-way, 32B line | S = 4096/(2·32) = 64 | 21 / 6 / 5 |

### 3.4 Simulation

```
block# = addr / B
set    = block# mod S
tag    = block# / S
hit iff (valid line in set, tag matches)
```

> Quiz pattern: 4 addresses `0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010` in 4KB 2-way 32B all map to **same set** with different tags ⇒ **conflict miss**.

## 4. Placement / Associativity

| Type | Ways | Sets | Pros | Cons |
|---|---|---|---|---|
| **Direct-mapped (DM)** | 1 | many | fast, **lowest tag overhead, simplest replacement** | many conflicts |
| **N-way set-assoc** | N | C/B/N | fewer conflicts | slower, more tag |
| **Fully assoc** | all | 1 | lowest miss rate (often) | slow, expensive |

> [!IMPORTANT] Quiz "always true": DM has **lowest tag overhead** ✓ + **simplest replacement** ✓. NOT "DM is faster" / "FA has lowest miss rate" (counterexample: 5-line loop in 4-block FA-LRU = 0% hit; in 4-block DM with lines 1/2/3 distinct sets = 60% hit).

### 4.1 Reduce Conflict Misses

| Method | Note |
|---|---|
| Larger cache | helps capacity + conflict |
| Higher associativity | helps conflict |
| ==**Victim cache**== (small FA after DM L1) | catches recently-evicted lines |
| Algorithm redesign | most powerful |

> DM + victim cache combines DM speed/cost with FA-like backup against burst conflict.

### 4.2 Associativity Diminishing Returns

(SPEC2000, 64KB, 16-word blocks): 1-way 10.3%, 2-way 8.6%, 4-way 8.3%, 8-way 8.1%.

## 5. Block Size Tradeoffs

| Larger block | Pro | Con |
|---|---|---|
| | **better spatial locality, less tag overhead, fewer compulsory misses** | larger miss penalty, more bandwidth, **fewer blocks → temporal-locality loss + more conflict** |

> ==**Critical-word-first / early-restart**== reduces miss penalty for big lines.
> Branches make huge lines wasteful — prefetch is more flexible.

## 6. Write Policies

### 6.1 On Write Hit

| Policy | Behavior |
|---|---|
| ==**Write-through**== | write cache + memory; consistent, simple |
| ==**Write-back**== | write cache only; write back on eviction; needs **dirty bit** |

> Write-through saturates memory BW → mitigate with **write buffer** (FIFO ~4 entries; coalesces).

### 6.2 On Write Miss

| Policy | Behavior | Best for |
|---|---|---|
| ==**Write-allocate**== | fetch block then write | reuse-likely (locals, struct fields) |
| ==**No-write-allocate**== | write straight to memory | ==**streaming writes** — `memset/memcpy` large, DB logs== |

> [!IMPORTANT] Modern L1D = ==**write-back + write-allocate**==. Streaming writes flag `no-allocate` per-instruction.

### 6.3 I-cache simpler

I-cache **takes no CPU stores** ⇒ no write policy. JIT/code-patching must:
- **Flush I-cache lines** (invalidate stale instr), OR
- maintain I/D coherence.

## 7. Cache Performance

### 7.1 CPU Stall Cycles

```
mem stall cyc = #access × miss_rate × miss_penalty
              = IC × %mem_inst × miss_rate × miss_penalty
```

### 7.2 Worked Example

I-miss=2%, D-miss=4%, penalty=100, base CPI=2, mem-inst=36%:
- I-stall/inst = 0.02 × 100 = 2
- D-stall/inst = 0.36 × 0.04 × 100 = 1.44
- ==**CPI = 2 + 2 + 1.44 = 5.44**==
- Speedup with perfect cache = 5.44/2 = **2.72×**.

> Single-cycle quiz: base CPI=1, D-miss=5%, mem-inst=40%, penalty=100: CPI = 1 + 0.4×0.05×100 = **3.0**.

### 7.3 AMAT

==**AMAT = hit time + miss rate × miss penalty**==.

Multilevel: $\text{AMAT} = T_{L1} + m_{L1}(T_{L2} + m_{L2}(T_{L3} + m_{L3} T_{mem}))$.

> AMAT was accurate in blocking-cache + in-order era. Now **OoO + non-blocking + prefetching** can hide miss latency → AMAT often pessimistic.

## 8. Reduce Misses (4 C's)

| Type | Cause | Fix |
|---|---|---|
| ==**Compulsory (cold)**== | first access | **prefetch, larger line** |
| ==**Conflict (collision)**== | bucket overflow | **larger cache, higher assoc., victim cache, algo** |
| ==**Capacity**== | working set > cache | **larger cache, blocking/tiling, prefetch** |
| ==**Coherence**== | invalidations from other procs | hardest — fundamental for shared writable data |

> ==Coherence misses are the hardest to remove==.

### 8.1 Reduce Miss Penalty

==**Critical-word-first / early-restart**==, **non-blocking cache**, **prefetching**, **write buffer**, cache-aware code scheduling.

### 8.2 Bandwidth-Heavy Features

> ==**Large lines, prefetching, non-blocking caches, write-through**== need more bus/memory bandwidth.

## 9. Replacement Policies

- **DM**: no choice (simplest).
- **Set-assoc**: typically ==**Approximate LRU**== (true LRU expensive).
- **True LRU** uses a ==**stack**== of access order; expensive.
- **FIFO**: replace oldest.
- **Random**: cheap, surprisingly competitive.
- ==**Belady (optimal)**==: replace block referenced **furthest in future**. Not implementable; **upper bound for evaluating new algos**.

## 10. Multi-Level Caches

| Level | Goal | Properties |
|---|---|---|
| **L1** | minimal hit time (~3-4 cyc) | small, **split I/D**, write-back, write-allocate |
| **L2** | low miss rate, balance | larger, **slower, unified**, write-back |
| **L3** | reduce memory traffic | ==**shared by cores**==, biggest, slowest on chip |

| | Inclusive | Exclusive | NINE |
|---|---|---|---|
| Property | L1 ⊂ L2 | L1 ∩ L2 = ∅ | neither |
| Coherence | easier | harder | flexible |
| Capacity | wastes (duplicates) | maximum | medium |
| Common | L1/L2 | (AMD) L2/L3 | many CPUs L2/L3 |
| ==**Project #4**== | | | ==**NINE**== |

> [!IMPORTANT] Nonsense traps (configs that don't make sense):
> - **L1I write-back/copy-back** (I-cache has no stores).
> - **L3 write-through** (would saturate memory bus).
> - **L1D 4-way + L2 direct-mapped** (DM L2 below assoc L1 → bad inclusion).
> - **L1/L2 exclusive + L2/L3 inclusive** (chain conflict).

## 11. Cache Coherence (Multi-Processor)

- Private caches with shared writable data → must synchronize.
- ==**Snoopy protocol**==: all caches watch the bus; on writes, invalidate or share.
  - generates **significant snooping bus traffic**.
- ==**MESI**== states: Modified / Exclusive / Shared / Invalid.

> Quiz: "4 procs on a bus, how to maintain coherence?" → **shared cache (no private)** OR **snoopy** with private caches.

## 12. TLB / Virtual Memory + Locality

- ==**TLB**== caches **VPN→PPN** translations.
- VA = `[VPN | VPO]`, PA = `[PPN | PPO]`, with ==**VPO = PPO**==.
- For page size $2^p$: **offset = p bits**.
- TLB layout: ==**TLBI = low bits of VPN; TLBT = remaining VPN bits**==.
- TLB miss → page-table walk → if PTE valid=0 → **page fault** → OS loads from disk → fill TLB.

### 12.1 Worked TLB Example (CMU final-f12)

```
20-bit VA, 1024B pages → VPN [19:10], VPO [9:0]
TLB 8 sets → TLBI = 3b → TLBT = 7b
```

VA `0x078E6 = 0000 0111 1000 1110 0110`:
- VPO = `00 0110 0110` (low 10b)
- VPN = `0000011110` = `0x01E`
- TLBI = `110` = **6**, TLBT = `0000011` = **3**

### 12.2 Page-Table Size

- Single-level PT entries = ==**VA size / page size**==.
- Larger pages: fewer PTEs/TLB misses; worse internal fragmentation + bigger transfer cost on page fault.

## 13. Locality / Applications

### 13.1 Linked List `while(A) A=A->next`

- ==Only **I-temporal + I-spatial** locality (loop body)==; **NO data spatial/temporal**; latency-bound.

### 13.2 Row-Major C Arrays

- `A[i][j]` with `j` increasing → contiguous → good spatial.
- Transpose: row-read + column-write → poor write spatial → use **blocking/tiling**.

### 13.3 Sorting Locality

| Sort | Locality |
|---|---|
| ==**Quicksort, Insertion, Bubble**== | high ✓ |
| Heapsort | low (random tree access) |
| Radix (large) | low (multi-pass) |

### 13.4 HW vs SW Cache

| | HW cache | SW cache (file cache) |
|---|---|---|
| Manager | hardware | system SW / app |
| Search | **associative** | hash table |
| Replacement | simple+fast | complex policy |
| Size | fixed | can grow |

## 14. Examples

- **Akamai (CDN)**: caches at edge stations.
- **GPU (Nvidia 4090)**: 144 SMs × 64K regs — too big for 1-cyc access ⇒ register-file cache.
- **Project #4**: ==**NINE**== multi-level.
