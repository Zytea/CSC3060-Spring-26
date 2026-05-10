# Lec 6: Memory Hierarchy & Caches

## Exam Facts

- ==**Memory hierarchy**==: small/fast/expensive near CPU; large/slow/cheap far away.
- **Management**: regs/local memory by compiler/programmer; caches by hardware; VM/main memory by OS+MMU; files by OS/apps.
- **SRAM vs DRAM**: SRAM fast/no refresh/cache; DRAM dense/cheap/refresh/main memory.
- ==**Memory wall**==: CPU speed vs DRAM latency/bandwidth gap.
- **Cache line metadata**: **valid bit + tag + data**, plus dirty bit for write-back and coherence state in multicore.
- **Not stored in a cache line**: set number / byte offset; those come from the address bits.
- **Address split**: `tag | set index | block offset`.
- **Cache parameters**: `S=C/(B*E)`, `b=log2(B)`, `s=log2(S)`, `t=m-s-b`.
- **Modern L1D**: set-associative, write-back, write-allocate; hit latency about **3-4 cycles**.
- **I-cache easier**: no CPU stores; JIT/self-modifying code needs I-cache flush/invalidate/coherence.
- ==**MSHR**==: non-blocking cache tracks outstanding misses; L3 MSHR count depends on memory latency + bus width/bandwidth.
- **AMAT**: $HT+MR\times MP$; multi-level AMAT uses local miss rates and fails when misses overlap.
- **4C misses**: compulsory/cold, conflict/collision, capacity, coherence.
- **Large line helps**: spatial locality, tag overhead, compulsory misses; hurts miss penalty/bandwidth/fewer lines.
- **TLB side point**: **TLB miss may trigger a page fault**; VIPT cache can overlap address translation.

## 1. Memory Hierarchy

| Level | Example | Managed by |
|---|---|---|
| L0 | regs | compiler |
| L1/L2/L3 | SRAM caches | hardware |
| L4 | DRAM / VM pages | OS + MMU |
| L5/L6 | disk/remote | OS/filesystem/apps |

Locality:

| Type | Meaning | Example |
|---|---|---|
| temporal | reuse soon | loop variable/instrs |
| spatial | nearby soon | array scan, sequential fetch |

## 2. RAM and Memory Wall

### 2.1 SRAM vs DRAM

| | SRAM | DRAM |
|---|---|---|
| cell | latch | capacitor |
| refresh | no | yes |
| speed | faster | slower |
| density | lower | higher |
| use | cache | main memory |

GPU global memory: high-end NVIDIA uses **HBM**.

SRAM is expensive because it uses many transistors per bit, has lower density, and is more complex/low-volume than DRAM.

### 2.2 Memory Wall

==**Memory wall**==: processor improves faster than main-memory latency/bandwidth.

Mitigation:

| Wall | Mitigation |
|---|---|
| latency | caches/local memory, prefetch, multithreading, MLP |
| bandwidth | HBM, banks, wider bus, blocking, compression, fewer bytes |

## 3. Cache Basics

### 3.1 Cache Line / Set / Lookup

==**Cache line/block**==: fixed-size copy of contiguous lower-level bytes. Hit = requested block present; miss = fetch from lower level and pay miss penalty.

```text
addr = [ tag ][ set index ][ block offset ]
```

Lookup:

1. `set = index bits`.
2. compare tag with each valid way.
3. hit if any tag matches.
4. offset selects byte/word.
5. miss: choose victim; if dirty under write-back, write back; fill line.

### 3.2 Parameter Formula

For `m` address bits:

$$
S=\frac{C}{B\times E},\quad b=\log_2B,\quad s=\log_2S,\quad t=m-s-b
$$

Example: `64 KiB`, 4-way, `32B` line, 32b address:

```text
S = 65536/(4*32)=512
b = 5, s = 9, t = 32-9-5 = 18
```

Quiz4 #4 answer: **tag 18, set index 9, block offset 5**.

Total cache bits:

$$
DataBits=C\times8,\quad Lines=S\times E,\quad MetadataBits\approx Lines\times(1+t+d)
$$

`d=1` if a dirty bit is used; add coherence-state bits for multicore caches.

Set number and byte offset are address fields, not stored per line.

### 3.3 Address Decomposition

```text
block_offset = addr & (B-1)
set_index    = (addr >> b) & (S-1)
tag          = addr >> (b+s)
block_addr   = addr >> b
```

For trace simulation, two addresses hit same line iff same `tag` and same `set`.

Equivalent fast form:

```text
block = addr / B
set   = block mod S
tag   = block / S
```

## 4. Cache Simulation / Trace Pattern

### 4.1 Direct-Mapped Trace

Each set has one line:

```text
if valid[set] && tag[set]==tag -> hit
else miss; tag[set]=tag; valid[set]=1
```

Conflict miss pattern:

```text
access A,B,A,B,... where set(A)==set(B), tag(A)!=tag(B)
```

In a direct-mapped cache, addresses separated by a multiple of cache size map to the same set.

### 4.2 Set-Associative Trace

On access:

1. select set.
2. hit if any valid matching tag.
3. miss if empty way -> fill.
4. miss if full -> evict by LRU/pseudo-LRU/random as specified.

### 4.3 Matrix / Array Miss Rate

For element size `e` and line size `B`, one cache line holds `B/e` contiguous elements.

```text
row-major row scan miss rate ~= 1/(B/e) if no conflict/capacity issue
column scan with large stride often ~= 100% miss
```

Streaming pattern: one stream of `e`-byte elements has miss rate about `e/B`; `k` independent streams work similarly only if associativity can hold the `k` live lines and their sets do not conflict.

Trace assumptions often say locals are in registers and instruction fetches are ignored.

> [!IMPORTANT]
> Always check base address block offset. If `arr[0][0]` starts near end of a line, the first few elements may cross a line earlier than expected.

If the whole working set fits in cache and mapping does not conflict, misses are only compulsory.

### 4.4 C Row-Major

Good:

```c
for (i=0;i<R;i++)
  for (j=0;j<C;j++)
    use(A[i][j]);
```

Bad:

```c
for (j=0;j<C;j++)
  for (i=0;i<R;i++)
    use(A[i][j]);   // stride = C*sizeof(A[0][0])
```

## 5. Placement / Associativity / Block Size

The 4 cache-design questions:

| Question | Mechanism |
|---|---|
| where can a block go? | placement / associativity |
| how is a block found? | index + tag compare |
| which block is evicted? | replacement policy |
| what happens on writes? | write policy |

| Org | Meaning | Pros/cons |
|---|---|---|
| direct mapped | `E=1` | fastest, many conflicts |
| set associative | `E>1` | balance |
| fully associative | `S=1` | least conflicts, costly search |

To minimize tag storage: direct-mapped and larger block reduce tag overhead.

For same `C,B`, direct-mapped has simplest replacement and low tag overhead; fully associative does not automatically have lowest miss rate unless replacement is good/optimal.

Always-true organization facts for same `C,B`:

- **direct-mapped**: lowest tag overhead + simplest replacement.
- **fully associative**: not guaranteed lowest miss rate under finite replacement policy.
- **larger line**: exploits spatial locality and saves tag space, but can increase conflict/capacity misses.

Larger block:

| Helps | Hurts |
|---|---|
| spatial locality, compulsory misses, tag overhead | miss penalty, bandwidth, fewer lines, conflict/capacity misses |

## 6. Write Policies

### 6.1 Write Hit

| Policy | Behavior |
|---|---|
| write-through | update cache + next level now; needs write buffer |
| write-back | update cache, set dirty; write on eviction |

### 6.2 Write Miss

| Policy | Behavior | Use |
|---|---|---|
| write-allocate | fetch line then write | likely reuse |
| no-write-allocate / write-no-allocate | bypass cache | streaming writes, large `memset`, large logs |

Use no-write-allocate / write-no-allocate for large `memcpy` destination, large `memset`, database logs.

Trace implication: under no-write-allocate, a write miss does **not** install the line; a later read to that address can still miss.

### 6.3 I-Cache

- no CPU stores -> no write policy.
- **JIT/instruction patching**: flush I-cache, invalidate affected I-lines, or maintain I/D coherence.

## 7. Cache Performance

### 7.1 Stall Cycles

$$
Memory\ Stall\ Cycles = IC\times MemAccesses/Instr\times MissRate\times MissPenalty
$$

$$
CPI = CPI_{base}+Stalls/Instr
$$

For split I/D:

```text
stalls/instr = I_MR*I_MP + data_accesses_per_instr*D_MR*D_MP
```

Quiz4 CPI: base 1, D miss rate 5%, 40% load/store, miss penalty 100:

```text
CPI = 1 + 0.40*0.05*100 = 3.0
```

### 7.2 AMAT

$$
AMAT = HitTime + MissRate\times MissPenalty
$$

Multi-level local miss rates:

$$
AMAT=HT_1+MR_1(HT_2+MR_2(HT_3+MR_3MP_{mem}))
$$

AMAT is incomplete for OoO/non-blocking caches because misses overlap.

## 8. Reducing Misses: 4C

| Miss | Cause | Fix |
|---|---|---|
| compulsory/cold | first access | larger block, prefetch |
| conflict/collision | set mapping collision | associativity, victim cache, padding |
| capacity | working set too big | bigger cache, blocking/tiling, reduce footprint |
| coherence | invalidation by other cores | reduce sharing, padding, partitioning |

**Coherence misses are the hardest 4C misses to remove.**

Bandwidth-heavy features: large lines, prefetch, non-blocking caches, many MSHRs, write-through.

## 9. Replacement / Victim Cache

| Policy | Note |
|---|---|
| LRU | exact stack; costly for high associativity |
| pseudo-LRU | typical in set-associative caches |
| random | cheap |
| FIFO | simple |
| Belady optimal | evict farthest future use; theoretical upper bound |

True LRU data structure: **stack**.

==**Victim cache**==: small fully-associative buffer of recently evicted lines; helps direct-mapped conflict misses.

LRU/FIFO trap: if set holds `A,B,C`, then access `A`, then miss on `D`; LRU evicts `B`, FIFO evicts `A`.

Belady optimal minimizes misses, not necessarily traffic if dirty writebacks have different cost from clean evictions.

Victim cache vs 2-way: victim cache is tiny/fully-associative behind direct-mapped L1; 2-way doubles choices in every set but costs more tag compare/replacement in L1.

## 10. Multi-Level Caches

| Level | Typical |
|---|---|
| L1I/L1D | fastest, private, split |
| L2 | larger/slower, often private/unified |
| L3 | shared last-level cache |

High-yield facts:

- L3 usually shared by cores.
- L3 write-through usually does not make sense.
- **L2 vs L1**: larger, slower, often unified.
- **Vast chip area in contemporary CPUs**: caches.

### 10.1 Inclusion Policies

| Policy | Meaning |
|---|---|
| inclusive | upper-level contents also in lower level |
| exclusive | line in one level, not duplicated in next |
| NINE | non-inclusive, non-exclusive |

NINE = non-inclusive, non-exclusive cache.

Operations:

- inclusive eviction from lower level may invalidate/back-invalidate upper-level copies.
- exclusive L1 eviction moves the line to L2; L1 miss/L2 hit migrates/swap-fills it back to L1.

Question pattern:

- L1/L2 inclusive and L2/L3 inclusive -> L1/L3 inclusive.
- Mixed exclusive/inclusive chains are not automatically sensible.

## 11. Cache Coherence

Snoopy coherence: private caches watch shared bus/coherence traffic.

MESI:

| State | Meaning |
|---|---|
| M | modified, dirty, only copy |
| E | clean, exclusive |
| S | clean, shared |
| I | invalid |

False sharing: different variables in same line cause invalidations; fix with padding/alignment.

## 12. Address Translation Side Points

- **TLB miss may trigger a page fault**.
- Virtual-address cache / virtually indexed, physically tagged cache can **avoid or overlap address-translation delay**.

## 13. Locality / Applications

Pointer chasing (`while (p) p=p->next`) has poor spatial locality and a load-use dependency chain.

Fixes:

- arrays/contiguous storage.
- B/B+ trees instead of pointer-heavy binary trees.
- open addressing instead of linked collision chains.
- batch multiple independent traversals.

Sorting locality: quicksort, insertion sort, bubble sort have high data locality; heapsort is poor.

Hardware vs software cache:

| Hardware cache | Software cache |
|---|---|
| transparent, associative tags, simple fast policies | managed by OS/app, hash/tree lookup, more flexible policies |
