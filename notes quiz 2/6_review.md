# Lec 6: Memory Hierarchy & Caches

## Exam Facts

- ==**Memory hierarchy**== exploits locality: small/fast/expensive near CPU; large/slow/cheap far away.
- Management: registers by compiler, caches by hardware, main memory/VM by OS+HW, files by OS/programmer.
- SRAM: fast, expensive, no refresh, used for caches. DRAM: dense, cheap, needs refresh, used for main memory.
- Cache line contains **valid bit, tag, data block**, and dirty bit for write-back caches.
- Address split: `tag | set index | block offset`.
- For cache size `C`, block size `B`, associativity `E`: sets `S=C/(B*E)`, offset bits `b=log2(B)`, index bits `s=log2(S)`.
- Direct mapped: `E=1`. Fully associative: `S=1`. Set associative: `E>1`.
- Modern L1D quiz answer: set-associative + write-back + write-allocate.
- I-cache has no CPU stores, so no write-hit/write-miss policy.
- AMAT:

$$
AMAT = HitTime + MissRate \times MissPenalty
$$

- Multi-level AMAT:

$$
AMAT = HT_{L1}+MR_{L1}(HT_{L2}+MR_{L2}(HT_{L3}+MR_{L3}MP_{mem}))
$$

- 4C misses: compulsory, capacity, conflict, coherence.
- Non-blocking cache uses **MSHR** to track outstanding misses.
- `BTB/BHT/TLB` are cache-like structures. TLB caches `VPN -> PPN` translations.
- Larger pages reduce TLB misses/PTE count but increase internal fragmentation and page-fault transfer size.

## 1. Memory Hierarchy

| Level | Example | Managed by | Main idea |
|---|---|---|---|
| L0 | CPU registers | compiler | fastest, explicit allocation |
| L1/L2/L3 | SRAM caches | hardware | cache lines from lower level |
| L4 | DRAM main memory | OS + MMU | cache for disk/VM pages |
| L5 | SSD/HDD | OS/filesystem | persistent local storage |
| L6 | remote storage | distributed systems | largest and slowest |

Locality:

| Type | Meaning | Example |
|---|---|---|
| temporal | recently used item likely reused | loop variable, instruction loop |
| spatial | nearby address likely used | array scan, sequential instr fetch |

## 2. RAM and Memory Wall

### 2.1 SRAM vs DRAM

| | SRAM | DRAM |
|---|---|---|
| Cell | 6T latch | 1T + capacitor |
| Refresh | no | yes |
| Speed | faster | slower |
| Density | lower | higher |
| Cost/bit | higher | lower |
| Use | CPU caches | main memory |

DRAM read can be destructive: charge is sensed and restored. Rows are activated into a row buffer; columns select bytes/words.

Enhanced DRAM: SDRAM/DDR/GDDR/HBM improve bandwidth through banks, burst transfers, wider interfaces, and stacking.

### 2.2 CPU-Memory Gap

CPU speed improved faster than DRAM latency. Memory wall means performance is often limited by data movement rather than computation.

Mitigation:

- cache hierarchy.
- prefetching.
- non-blocking caches.
- memory-level parallelism.
- wider memory buses / HBM.
- locality-conscious software.

## 3. Main Memory Transactions

### 3.1 Read Transaction

1. CPU sends address to memory controller/cache hierarchy.
2. If cache miss reaches DRAM, memory activates row/reads data.
3. Data returns on bus and fills cache line.
4. CPU gets requested word.

### 3.2 Write Transaction

1. CPU sends address + data.
2. Cache handles write hit/miss according to policy.
3. Lower-level write may happen immediately (write-through) or on eviction (write-back).

Bandwidth matters for streaming; latency matters for pointer chasing.

## 4. Cache Basics

### 4.1 Cache Line / Block

==**Cache line**==: unit of transfer between cache levels.

Line metadata:

| Field | Purpose |
|---|---|
| valid | line contains meaningful data |
| tag | high address bits identifying memory block |
| data block | bytes from memory |
| dirty | write-back line modified vs lower level |
| coherence state | MESI-like state in multicore caches |

### 4.2 Cache Sets

Cache parameters:

| Symbol | Meaning |
|---|---|
| `C` | data capacity in bytes |
| `B` | block size in bytes |
| `E` | associativity, lines per set |
| `S` | number of sets = `C/(B*E)` |
| `m` | address bits |
| `b` | block offset bits = `log2(B)` |
| `s` | set index bits = `log2(S)` |
| `t` | tag bits = `m-s-b` |

Address layout:

```text
[ tag: t bits ][ set index: s bits ][ block offset: b bits ]
```

### 4.3 Cache Lookup

1. Use set index bits to select a set.
2. Compare tag against each valid line in the set.
3. Hit if any valid tag matches.
4. Offset chooses byte/word inside block.
5. Miss: fetch block from lower level, choose victim if set full.

### 4.4 Quiz Examples

Example 1: 32b address, `C=1024B`, `B=16B`, direct mapped.

```text
E=1
S = 1024/(16*1)=64 sets
b = log2(16)=4
s = log2(64)=6
t = 32-6-4=22
```

Example 2: 64 KiB cache, 4-way, 64B blocks.

```text
C=65536, E=4, B=64
S=65536/(4*64)=256
b=6, s=8
tag bits for 32b address = 18
```

Example 3: 256B cache, 32B blocks, 2-way.

```text
S=256/(32*2)=4
b=5, s=2
```

## 5. Placement / Associativity

| Organization | `E` / `S` | Placement | Pros/cons |
|---|---|---|---|
| direct mapped | `E=1` | one possible line | fastest/simple, many conflict misses |
| set associative | `E>1` | any line in indexed set | balance hit time/miss rate |
| fully associative | `S=1` | anywhere | few conflict misses, expensive search |

Increasing associativity usually reduces conflict misses but increases hit time, tag comparators, power, and complexity.

### 5.1 Conflict Miss Example

Direct mapped cache can thrash if addresses map to the same set:

```text
access A, B, A, B ...
set(A) == set(B), tag(A) != tag(B)
```

Fixes:

- higher associativity.
- victim cache.
- padding/array layout changes.
- loop blocking/tiling.
- change stride to avoid power-of-two conflicts.

## 6. Block Size Tradeoffs

| Larger block helps | Larger block hurts |
|---|---|
| spatial locality | miss penalty/bandwidth |
| fewer compulsory misses | fewer total lines |
| amortizes tag overhead | more conflict/capacity misses |
| sequential accesses | useless bytes for poor locality |

Critical-word-first / early-restart lets CPU use requested word before entire block arrives.

## 7. Write Policies

### 7.1 Write Hit

| Policy | Behavior | Notes |
|---|---|---|
| write-through | update cache and next level immediately | simple, more bandwidth, needs write buffer |
| write-back | update cache only, set dirty bit | common in L1D, writes back on eviction |

### 7.2 Write Miss

| Policy | Behavior | Best for |
|---|---|---|
| write-allocate | fetch line, then write into cache | likely reuse: locals, struct fields |
| no-write-allocate | write around/bypass cache | streaming writes, large `memset`, logs |

Search terms: **write allocate** = fetch-on-write-miss; **no write allocate** = bypass cache on write miss.

Modern L1D quiz answer: **set-associative + write-back + write-allocate**.

### 7.3 I-Cache

I-cache has no CPU stores, so no write-hit/write-miss policy. I-cache miss handling fetches instruction blocks from lower level.

## 8. Cache Read, Non-Blocking Cache, MSHR

### 8.1 Cache Read

On hit: data returned after tag check/data array access.

On miss:

1. allocate miss tracking entry.
2. send request to lower cache/memory.
3. when line returns, fill cache.
4. restart/wake waiting load.

### 8.2 Blocking vs Non-Blocking

| Cache | Behavior |
|---|---|
| blocking | one miss stalls later accesses until resolved |
| non-blocking | can continue serving hits and/or issue more misses |

==**MSHR**==: Miss Status Holding Register, tracks an outstanding miss: block address, waiting loads/stores, destination, state.

MSHR count depends on memory latency and memory bandwidth/bus width. More memory-level parallelism needs more MSHRs.

## 9. Cache Performance

### 9.1 Stall Cycles

$$
Memory\ Stall\ Cycles = IC \times MemAccesses/Instr \times MissRate \times MissPenalty
$$

$$
CPI = CPI_{base} + Memory\ Stalls/Instr
$$

If split I/D:

```text
stalls/instr =
I_miss_rate * I_miss_penalty
+ data_accesses_per_instr * D_miss_rate * D_miss_penalty
```

### 9.2 AMAT

$$
AMAT = HitTime + MissRate \times MissPenalty
$$

Example: hit time 1 cycle, miss rate 5%, miss penalty 100 cycles:

```text
AMAT = 1 + 0.05*100 = 6 cycles
```

### 9.3 Multi-Level AMAT

For local miss rates:

$$
AMAT = HT_{L1}+MR_{L1}(HT_{L2}+MR_{L2}(HT_{L3}+MR_{L3}MP_{mem}))
$$

Example:

```text
L1 hit 1, L1 MR .05
L2 hit 10, L2 local MR .20
memory penalty 100
AMAT = 1 + .05*(10 + .20*100) = 2.5
```

AMAT becomes incomplete for OoO/non-blocking CPUs because overlapped misses and MLP hide some latency.

## 10. Reducing Misses: 4C

| Miss type | Cause | Fix |
|---|---|---|
| compulsory | first access to block | larger block, prefetch |
| capacity | working set exceeds cache | bigger cache, blocking/tiling |
| conflict | mapping collisions | associativity, victim cache, padding |
| coherence | invalidations by other cores | reduce sharing, align/pad, better synchronization |

Some texts use 3C without coherence; multicore adds 4th C.

### 10.1 Bandwidth-Heavy Features

These can reduce misses/penalty but require bandwidth:

- larger blocks.
- prefetching.
- write-through.
- non-blocking caches.
- many MSHRs.
- wide issue/OoO cores generating many misses.

## 11. Replacement Policies

| Policy | Idea |
|---|---|
| random | cheap, sometimes effective |
| FIFO | evict oldest inserted |
| LRU | evict least recently used |
| pseudo-LRU | approximate LRU with less metadata |
| optimal/Belady | evict line used farthest in future; theoretical lower bound |

LRU is expensive for high associativity. Direct mapped has no replacement choice.

Belady anomaly examples can make direct mapped appear better than fully associative for a specific trace under a poor replacement policy, but fully associative with optimal replacement is the ideal comparison.

## 12. Victim Cache

==**Victim cache**==: small fully associative buffer holding recently evicted lines from a direct-mapped or low-assoc cache.

Helps conflict misses, especially ping-pong between two blocks mapping to same set.

DM + victim cache can sometimes beat 2-way set associative for conflict-heavy traces with low hit-latency cost.

## 13. Multi-Level Caches

Multi-level caches reduce miss penalty:

- L1: smallest/fastest, split I/D common.
- L2: larger/slower, unified or private.
- L3: larger shared last-level cache.
- DRAM beyond LLC.

Considerations:

- hit time.
- local/global miss rate.
- miss penalty.
- inclusion policy.
- coherence traffic.
- bandwidth and MSHRs.

### 13.1 Inclusive / Exclusive / NINE

| Policy | Meaning | Pros/cons |
|---|---|---|
| inclusive | L1 contents also in L2/L3 | easier coherence/snoop filtering, duplicate capacity |
| exclusive | line in L1 not also in next level | more effective capacity, more movement complexity |
| NINE | non-inclusive, non-exclusive | flexible; neither guarantee |

Quiz pattern:

- L1/L2 inclusive + L2/L3 inclusive -> L1/L3 inclusive.
- L1/L2 exclusive + L2/L3 exclusive does **not** imply L1/L3 inclusive.
- L1/L2 exclusive + L2/L3 inclusive chain has mixed guarantees.

## 14. Cache Coherence

Coherence problem: multiple cores cache same address; writes by one core must become visible consistently.

Snoopy coherence: caches watch bus/coherence messages and update/invalidate their lines.

MESI states:

| State | Meaning |
|---|---|
| M Modified | dirty, only this cache has latest copy |
| E Exclusive | clean, only this cache has copy |
| S Shared | clean, other caches may have copy |
| I Invalid | not valid |

False sharing: different variables on same cache line cause coherence traffic. Fix by padding/alignment or data partitioning.

## 15. TLB / Virtual Memory

==**TLB**==: Translation Lookaside Buffer, a cache for page-table translations `VPN -> PPN`.

Virtual address split:

```text
[ VPN ][ page offset ]
```

Physical address:

```text
[ PPN ][ same page offset ]
```

TLB set/index/tag:

```text
TLBI = low bits of VPN used to index TLB set
TLBT = remaining high VPN bits
```

TLB hit: get PPN quickly, combine with page offset, then access cache/memory.

TLB miss:

1. hardware or OS page-table walk.
2. if PTE valid -> fill TLB.
3. if PTE invalid/not resident -> page fault; OS loads page and updates PTE/TLB.

### 15.1 CMU-Style TLB Example

Assume:

```text
virtual address = 0x03d4
VA bits = 14
page size = 16B -> page offset = 4 bits
VPN bits = 10
8-set TLB -> TLBI = 3 low VPN bits
TLBT = remaining 7 VPN bits
```

Compute:

```text
VPN = 0x03d4 >> 4 = 0x03d
VPO = 0x4
TLBI = VPN & 0x7 = 0x5
TLBT = VPN >> 3 = 0x07
```

Always recompute from the exact address bits in the problem; do not memorize one answer blindly.

### 15.2 Page Table Size

PTE count = virtual address space / page size.

Example: 32b VA, 4 KiB pages:

```text
pages = 2^32 / 2^12 = 2^20 PTEs
```

Larger pages:

- fewer PTEs.
- fewer TLB misses / better TLB reach.
- larger page-fault transfer.
- more internal fragmentation.

## 16. Locality / Applications

### 16.1 Linked Lists and Pointer Chasing

```c
while (p) p = p->next;
```

Problems:

- poor spatial locality if nodes scattered.
- load-use dependency chain: next address unknown until current load completes.
- little memory-level parallelism.

Fixes:

- arrays/contiguous storage.
- B/B+ trees instead of pointer-heavy binary trees.
- open-addressing hash tables instead of linked collision chains.
- prefetch if next pointers predictable enough.

### 16.2 C Row-Major Arrays

C stores `int A[R][C]` row-major. Good traversal:

```c
for (i=0; i<R; i++)
  for (j=0; j<C; j++)
    sum += A[i][j];
```

Bad for locality: column traversal with large row stride.

### 16.3 Sorting Locality

| Algorithm | Locality idea |
|---|---|
| quicksort | partition scans arrays, decent cache locality but recursion/random pivots |
| radix/counting sort | often streaming and cache-friendly if buckets fit |
| linked-list sort | poor locality |

### 16.4 Hardware vs Software Cache

Hardware cache:

- transparent to program.
- exploits general locality.
- fixed policies and limited semantic knowledge.

Software locality optimization:

- loop interchange.
- blocking/tiling.
- data layout changes: AoS vs SoA.
- contiguous containers.
- padding to avoid conflicts/false sharing.
