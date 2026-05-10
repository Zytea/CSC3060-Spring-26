# Lec 6: Memory Hierarchy & Caches

## Exam Facts

- ==**Memory wall**==: growing gap between CPU speed and DRAM speed; includes **latency wall** and **bandwidth wall**.
- Latency fixes: caches/local memory, NUMA/PIM, multithreading/SMT/warp interleaving. Bandwidth fixes: **HBM**, banks/interleaving, wider bus, non-blocking caches.
- Hierarchy management: registers/local memory by compiler/programmer; caches by **hardware**; VM memory-disk by **HW+OS**; files by programmer.
- Cache line stores **data + tag + valid bit** (+ dirty bit if write-back). **Set number is not stored**.
- Address split for A-bit addr, capacity C, block B, ways E:
$$
S=\frac{C}{B E};\quad b=\log_2B;\quad s=\log_2S;\quad t=A-s-b
$$
- Modern L1D likely: **4-way set-assoc, write-back, write-allocate**, hit latency about **3-4 cycles**.
- L3 usually shared by cores; most chip area is caches; `L3 write-through` does not make sense.
- Non-blocking cache uses **MSHR**; L3 MSHR count depends on memory latency and memory bus width.
- 4C misses: **compulsory/cold, conflict/collision, capacity, coherence**. Coherence is hardest to remove.
- High-end GPU global memory: **HBM**.
- I-cache easier than D-cache because it takes no CPU stores.
- Linked-list loop `while(A) A=A->next`: instruction temporal/spatial locality only; data locality poor; latency-bound.
- High-locality sorts: **quicksort, insertion, bubble**. Poorer locality: heapsort, large radix.

## 1. RAM and Memory Wall

| Tech | Cell | Refresh | Density/cost | Speed | Use |
|---|---|---|---|---|---|
| **SRAM** | 6-8 transistors | no | low density, expensive | fast | caches, regfile |
| **DRAM** | 1T1C | yes | high density, cheap | slow | main memory |
| **HBM** | stacked DRAM | yes | high BW | high bandwidth | GPUs/AI |

==**Memory wall**==:

| Wall | Meaning | Mitigation |
|---|---|---|
| latency | single access takes too many CPU cycles | cache, local memory, NUMA, PIM, SMT/warp interleave |
| bandwidth | not enough bytes/cycle for many cores/SIMD/GPU | HBM, multi-bank, interleaving, wider bus, non-blocking cache |

## 2. Memory Hierarchy

Registers -> L1 -> L2 -> L3 -> DRAM -> SSD/HDD -> remote.

Up: small/fast/expensive. Down: large/slow/cheap.

> Memory hierarchy gives the illusion of memory that is **fast, large, and cheap**.

### 2.1 Who Manages What

| Boundary | Manager |
|---|---|
| registers <-> memory | compiler/programmer |
| cache <-> memory | hardware |
| local/scratchpad <-> memory | compiler/programmer |
| memory <-> disk for VM | hardware + OS |
| memory <-> disk files | programmer |

### 2.2 Terms

- ==**Block/line**==: unit moved between memory levels.
- Hit: found in upper level. Miss: not found; fetch from lower level.
- Hit time is much smaller than miss penalty.
- Miss rate = misses/accesses; hit rate = 1 - miss rate.

## 3. Cache Basics and Address Breakdown

### 3.1 Cache Line Contents

Cache line metadata:

```text
valid | tag | data bytes | dirty (only for write-back)
```

Set index is implied by where the line sits; it is **not stored**.

### 3.2 Address Split

For A-bit addresses:

```text
[ tag t bits | set index s bits | block offset b bits ]
```

$$
b=\log_2B,\quad S=C/(B E),\quad s=\log_2S,\quad t=A-s-b
$$

> Index bits are middle bits. High bits are tag; low bits are byte offset. Using high bits as index would map adjacent blocks badly and destroy spatial locality.

### 3.3 Quiz Examples

| Cache | Calculation | Tag/index/offset |
|---|---|---|
| 64KB, 4-way, 32B line, 32b addr | `S=65536/(4*32)=512` | `18 / 9 / 5` |
| 16KB, direct-mapped, 64B line, 32b addr | `S=16384/64=256` | `18 / 8 / 6` |
| 4KB, 2-way, 32B line, 32b addr | `S=4096/(2*32)=64` | `21 / 6 / 5` |

### 3.4 Cache Simulation

```text
block_addr = addr / B
set        = block_addr mod S
tag        = block_addr / S
hit iff some valid line in set has same tag
```

For powers of two, use bit fields: offset low `b`, index next `s`, tag rest.

Quiz4 conflict example: 4KB 2-way 32B line -> 64 sets. Addresses `0x01ABC000, 0x01ABB004, 0x01ABD000, 0x01ABA010` have same index with different tags -> conflict misses.

## 4. Placement / Associativity

| Cache type | Sets | Ways | Pros | Cons |
|---|---:|---:|---|---|
| direct-mapped | many | 1 | lowest tag overhead, simplest replacement | conflict-prone |
| N-way set-assoc | `C/(B*N)` | N | fewer conflicts | more comparators, slower |
| fully associative | 1 | all lines | flexible placement | expensive/slow |

Quiz "always true" for same C/B:

- Direct-mapped has **lowest tag overhead**.
- Direct-mapped replacement is simplest.
- Do not automatically choose "direct-mapped fastest" or "fully associative lowest miss rate"; replacement/pathological sequences can break simplistic claims.

### 4.1 Reducing Conflict Misses

- Increase cache size.
- Increase associativity.
- Add victim cache after direct-mapped L1.
- Change data/code layout; pad arrays to avoid power-of-two stride conflicts.
- Redesign algorithm/data structure.

## 5. Block Size Tradeoffs

Larger block:

| Pros | Cons |
|---|---|
| exploits spatial locality | higher miss penalty |
| lower tag overhead | more bandwidth traffic |
| fewer compulsory misses | fewer total lines -> more conflict/capacity pressure |

Critical-word-first / early-restart reduces perceived miss penalty.

## 6. Write Policies

### 6.1 Write Hit

| Policy | Behavior | Notes |
|---|---|---|
| write-through | write cache and memory/L2 | simple, high bandwidth; use write buffer |
| write-back | write cache only, mark dirty; write on eviction | needs dirty bit, common in L1D |

### 6.2 Write Miss

| Policy | Behavior | Best for |
|---|---|---|
| write-allocate | fetch line, then write | likely reuse: locals, struct fields |
| no-write-allocate | write to lower level only | streaming writes: large `memcpy`, large `memset`, DB logs |

Search terms: **write allocate** = fetch-on-write-miss; **no write allocate** = bypass cache on write miss.

Modern L1D quiz answer: **set-assoc + write-back + write-allocate**.

### 6.3 I-Cache

I-cache has no CPU stores, so no write-hit/write-miss policy.

JIT/code patching stale instruction fixes:

- flush/invalidate I-cache lines containing old instrs.
- or maintain I/D cache coherence for code writes.

## 7. Cache Performance

### 7.1 Stall Cycles

```text
memory stall cycles = accesses * miss_rate * miss_penalty
                    = IC * mem_refs_per_instr * miss_rate * miss_penalty
```

Quiz single-cycle example:

```text
base CPI=1, D-cache miss=5%, load/store instr=40%, miss penalty=100
CPI = 1 + 0.40*0.05*100 = 3.0
```

### 7.2 AMAT

$$
AMAT = hit\ time + miss\ rate \times miss\ penalty
$$

Multi-level:

$$
AMAT=T_{L1}+m_{L1}(T_{L2}+m_{L2}(T_{L3}+m_{L3}T_{mem}))
$$

> AMAT is less accurate on OoO/non-blocking/prefetching systems because miss latency can overlap with other work.

## 8. Reduce Misses: 4C

| Miss | Cause | Fix |
|---|---|---|
| compulsory/cold | first touch | prefetch, larger line |
| conflict/collision | too many blocks map to same set | bigger cache, more associativity, victim cache, layout |
| capacity | working set exceeds cache | larger cache, blocking/tiling, algorithm |
| coherence | invalidation from other cores | hardest; reduce shared writable data |

Quiz: hardest to remove = **coherence**.

### 8.1 Bandwidth-Heavy Features

Need more bus/memory bandwidth:

- large cache lines.
- prefetching.
- non-blocking caches.
- write-through caches.

## 9. Replacement Policies

| Policy | Key point |
|---|---|
| direct-mapped | no choice |
| true LRU | stack of recency order; expensive |
| approximate LRU | typical practical set-assoc replacement |
| FIFO | evict oldest inserted |
| random | cheap, often okay |
| Belady optimal | evict line used farthest in future; not implementable; upper bound |

Quiz: true LRU data structure = **stack**. New replacement algorithm upper bound = **Belady**.

## 10. Multi-Level Caches

| Level | Goal | Typical |
|---|---|---|
| L1 | fastest hit | split I/D, small, 3-4 cycle D-hit |
| L2 | balance hit time/capacity | larger/slower, unified |
| L3 | reduce memory traffic | usually shared by cores |

### 10.1 Inclusive / Exclusive / NINE

| Organization | Meaning | Notes |
|---|---|---|
| inclusive | L1 contents also in L2/L3 | easier coherence, duplicate capacity |
| exclusive | a line in L1 not also in next level | more effective capacity, harder |
| NINE | non-inclusive, non-exclusive | project #4 answer |

Nonsense configurations from Quiz:

- L3 write-through.
- L1I copy-back/write-back.
- L1D 4-way with L2 direct-mapped.
- L1/L2 exclusive + L2/L3 inclusive chain.

## 11. Cache Coherence

Private caches + shared writable data can hold stale copies.

Solutions for bus-connected multiprocessors:

- use a shared cache only.
- or private caches with **snoopy protocol**.

==**Snoopy cache**==: cache controllers monitor bus transactions and invalidate/share lines as needed; causes significant bus traffic.

MESI states: Modified, Exclusive, Shared, Invalid.

## 12. TLB / Virtual Memory

==**TLB**== caches page-table translations `VPN -> PPN`.

For page size `2^p`:

```text
VA = [ VPN | VPO ], PA = [ PPN | PPO ], VPO = PPO = low p bits
TLBI = low bits of VPN used to index TLB set
TLBT = remaining high VPN bits
```

TLB miss:

1. hardware/OS walks page table in memory.
2. if PTE valid -> fill TLB.
3. if PTE invalid -> page fault; OS loads page from disk, updates PTE/TLB.

### 12.1 CMU-Style TLB Example

20-bit VA, 1024B pages:

```text
p=10, VPO=[9:0], VPN=[19:10]
8-set TLB -> TLBI=3 low VPN bits, TLBT=remaining 7 VPN bits
```

VA `0x078E6`:

```text
VPN = 0x01E
VPO = 0x0E6
TLBI = 0x6
TLBT = 0x03
```

### 12.2 Page Table Size

Single-level page table entries:

$$
\#PTE = \frac{\text{virtual address space size}}{\text{page size}}
$$

Larger pages reduce PTE count and TLB misses but increase internal fragmentation and page-fault transfer size.

## 13. Locality / Applications

### 13.1 Linked List

```c
while (A != NULL) A = A->next;
```

Locality:

- instruction temporal/spatial: yes (loop body).
- data spatial: poor.
- data temporal: poor unless revisiting nodes.
- performance: latency-bound pointer chasing.

### 13.2 C Row-Major Arrays

In C, `A[i][j]` row-major; increasing `j` is contiguous.

Transpose/matrix kernels: use blocking/tiling to turn repeated row/column accesses into cache-sized chunks.

### 13.3 Sorting Locality

High locality: quicksort, insertion sort, bubble sort.

Low locality: heapsort; large radix sort can suffer cache misses despite O(n).

### 13.4 Hardware vs Software Cache

| | Hardware cache | Software cache |
|---|---|---|
| manager | hardware | OS/app |
| lookup | associative search | hash/tree/data structure |
| replacement | simple/fast | can be complex |
| flexibility | fixed | flexible |
