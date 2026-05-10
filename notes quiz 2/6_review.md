# Chapter 6: Memory Hierarchy and Caches

## Exam Facts

- ==**Memory wall**==: growing gap between CPU speed and DRAM latency/bandwidth.
- Latency wall mitigation: **caches/local memory, prefetching, multithreading/MLP**.
- Bandwidth wall mitigation: **HBM, multiple banks, wider bus, non-blocking caches**.
- Management: registers/local memory by **compiler/programmer**; caches by **hardware**; VM/main memory by **HW + OS**.
- Cache line stores **data + tag + valid bit**; dirty bit if write-back; **not set number**.
- Cache address bits: **offset = log2(block size)**; **sets = cache size/(block size*ways)**; **index = log2(sets)**; **tag = addr bits - index - offset**.
- Modern L1D: usually **set-associative, write-back, write-allocate**, hit latency ~3-4 cycles.
- L3 is usually shared by cores; L3 write-through usually does not make sense; most CPU chip area is often **caches**.
- Non-blocking cache uses **MSHR**; L3 MSHR count depends on **memory latency, bus width, #cores**.
- 4C misses: **compulsory/cold, conflict/collision, capacity, coherence**.

## 6.1 RAM and Memory Wall

- SRAM: no refresh, fast, expensive; used for caches.
- DRAM: refresh needed, dense, slower; used for main memory.
- HBM: high-bandwidth DRAM used in high-end GPUs.
- Memory wall = CPU gets faster faster than DRAM; split into latency wall and bandwidth wall.

## Cache Basics

==**Cache**==: small fast store for blocks from lower level.
- block/line: unit copied between levels;
- hit: found in cache; miss: must fetch lower level;
- hit time << miss penalty.
- Valid bit indicates entry contains meaningful block; tag identifies which memory block.
- Set index uses **middle address bits** (above block offset, below tag); using high bits would waste spatial locality because nearby blocks share high bits.
- CMU wording: use **middle bits** for set index; high-bit indexing fails to exploit spatial locality.

Placement:
- direct-mapped = 1-way, fastest/simple, lowest tag overhead;
- set-associative = N ways per set, fewer conflicts;
- fully associative = 1 set, lowest conflict miss rate but slow/expensive.

## Address Breakdown

For A-bit address, cache size C bytes, block B bytes, E ways:
- sets $S=C/(B\cdot E)$, offset bits $b=\log_2B$, index bits $s=\log_2S$, tag bits $t=A-s-b$.
- Simulation: block# = `addr/B`; set = `block# mod S`; tag = `block#/S`; hit iff valid matching tag in set.
- Example: 64KB, 4-way, 32B line, 32b addr: $S=65536/(4*32)=512$, $b=5$, $s=9$, $t=18$.

> [!IMPORTANT]
> Set number is not stored in a cache line; it is implied by index.

## Write Policies

- ==**Write-through**==: write cache and next level on every store; simple, high bandwidth traffic.
- ==**Write-back**==: write cache only; write dirty line back on eviction; needs dirty bit.
- ==**Write-allocate**==: on write miss, fetch block then write; common with write-back.
- ==**Write-no-allocate / no-write-allocate**==: on write miss, bypass cache; good for streaming writes like large `memset`, `memcpy`, database logs.
- Write buffer lets CPU continue after a store; stalls only when full; can coalesce writes.

I-cache easier: no normal processor stores. JIT/patching stale-code fixes: **flush I-cache**, invalidate lines, or maintain I/D coherence.

## Miss Handling and Performance

- Blocking cache: miss stalls pipeline.
- Non-blocking cache: hit-under-miss / miss-under-miss; MSHR tracks outstanding misses and merging.
- AMAT = hit time + miss rate * miss penalty.
- With cache misses in CPI: extra CPI = memory-instruction fraction * miss rate * miss penalty.
- Single-cycle cache miss quiz: base CPI 1 + `0.4*0.05*100 = 3.0`.
- Line holds `block size / element size` elements; in a cold cache, first access to a line is a compulsory miss.
- Bandwidth-heavy features: **large lines, prefetching, non-blocking caches, write-through**.
- Miss-penalty reduction: **critical-word-first/early restart, non-blocking cache, prefetch, write buffer**.

## Reducing Misses

- Compulsory/cold: prefetching, larger line.
- Conflict/collision: larger cache, higher associativity, victim cache.
- Capacity: larger cache, better blocking/tiling, prefetch sometimes.
- Coherence: hardest; comes from sharing writes in multiprocessors.

Large line:
- pros: more spatial locality, fewer compulsory misses, less tag overhead;
- cons: larger miss penalty, more bandwidth, pollution/conflicts, less temporal locality in fixed-size cache.

## Replacement

- Direct-mapped: no replacement choice, simplest.
- Set-assoc: typical replacement = **approximate LRU**, not true LRU.
- True LRU uses stack/order; expensive.
- Belady optimal is unattainable online but is evaluation upper bound.
- Victim cache: small fully-assoc buffer for recently evicted DM lines; reduces conflict misses.
- Minimum tag space: **direct-mapped + large lines**.

## Multi-Level Caches

- L1: fastest hit time; often split I/D.
- L2: larger, slower, usually unified.
- L3: reduces memory traffic, shared by cores.
- Inclusive: lower level contains copies of upper; easier coherence, wastes capacity.
- Exclusive: levels avoid duplication; more effective capacity, more movement complexity.
- NINE = non-inclusive non-exclusive.
- Nonsense traps: L1I write-back/copy-back, L3 write-through, L1D 4-way backed by DM L2, contradictory inclusive/exclusive chains.

## Coherence

- Private caches need coherence for shared writable data.
- Bus-connected processors: **snoopy protocol** or no private cache/shared cache.
- Snoopy cache watches bus; causes snooping traffic.
- MESI states: Modified, Exclusive, Shared, Invalid.

## TLB / VM Locality

- TLB caches **VPN -> PPN** translations; page offset is unchanged.
- TLB index/tag come from VPN like cache index/tag.
- VM works well because programs show temporal/spatial locality at **page** granularity.
- VA = **VPN | VPO**, PA = **PPN | PPO**, and **VPO=PPO**.
- For page size $2^p$: offset has `p` bits; TLB sets = entries/ways; **TLBI = low bits of VPN**, **TLBT = remaining VPN bits**.
- TLB miss -> page table lookup; PTE valid=0 -> **page fault**, else use PPN and fill TLB.

## Locality / Applications

- Linked list `while(A) A=A->next`: poor data spatial locality + pointer latency; loop instructions still have I-cache locality.
- C row-major arrays: `A[i][j]` with increasing `j` is contiguous; transpose often reads rows but writes columns, so blocking helps.
- Good locality sorting: quicksort, insertion sort, bubble sort (vs heapsort poorer locality).
- Hardware cache: managed by hardware, associative search, simple fast replacement.
- Software cache: managed by OS/app, uses data structures like hash tables, can use complex policies.
