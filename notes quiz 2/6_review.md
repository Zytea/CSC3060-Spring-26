# Lec 6: Memory Hierarchy & Caches

## Exam Facts

- ==**Memory hierarchy**==: small/fast/expensive near CPU; large/slow/cheap far away → illusion of **fast + large + inexpensive**.
- ==**Layers + management**==:
  - L0 **registers** ← **compiler / programmer**.
  - L1/L2/L3 **caches** ← **hardware**.
  - **Local memory (scratch-pad / NVIDIA shared mem)** ← **compiler / programmer**.
  - L4 **DRAM / VM** ← **OS + MMU + HW**.
  - L5/L6 disk/files ← OS + apps.
- ==**SRAM vs DRAM**==: SRAM = 6-8T/bit, fast, no refresh, expensive (~100×) → caches. DRAM = 1T+1C/bit, dense/cheap, slower, **needs refresh** → main memory.
- **GPU global memory**: ==**HBM**== (NVIDIA H100/H200, AMD MI300, etc.). Quiz 2 #10 → answer B.
- **DRAM read**: ==**RAS** selects row → row buffer; **CAS** selects column → data lines==; refresh writes row back.
- ==**Memory wall**==: gap between CPU speed and DRAM latency/bandwidth.
- **Memory wall fixes**:
  - **Latency**: caches/local mem, prefetch, multi-threading, MLP.
  - **Bandwidth**: HBM, multiple banks, wider bus, blocking, compression.
- ==**Cache line metadata**==: ==**valid bit + tag + data**==, plus dirty bit for write-back, plus coherence state for multicore.
- ==**NOT stored per cache line**==: **set number** (it's an address field), byte offset.
- ==**Address split**==: `[ tag | set index | block offset ]`.
- ==**Cache parameters**==:
  $$S = \frac{C}{B \cdot E}, \quad b = \log_2 B, \quad s = \log_2 S, \quad t = m - s - b$$
- ==**Modern L1D org**==: **set-associative + write-back + write-allocate**; hit latency ≈ **3-4 cycles**.
- ==**I-cache easier than D-cache**==: no CPU stores → **no write policy + no dirty bit** (still has valid/tag/data). JIT/self-modifying code needs flush/invalidate/coherence.
- ==**MSHR**==: Miss Status Handling Register; tracks outstanding misses → enables non-blocking cache + MLP.
- **L3 MSHR count** depends on **memory latency + memory bus width**. (NOT L2 size, NOT cores sharing L3 directly.)
- **AMAT** = $HitTime + MissRate \times MissPenalty$. Multi-level uses **local miss rates**. **AMAT inaccurate** under OoO + non-blocking caches.
- ==**4 C's of misses**==: **Compulsory (cold), Conflict (collision), Capacity, Coherence**.
- ==**Most difficult to remove**==: **Coherence misses** (Quiz 4 #15).
- **Reduce by miss type**:
  - compulsory → larger lines, prefetch.
  - conflict → associativity, victim cache, padding.
  - capacity → bigger cache, blocking/tiling, reduce footprint.
  - coherence → less sharing, padding, partitioning.
- **Larger cache reduces** capacity + conflict misses. NOT compulsory or coherence (Quiz 5050 final #7).
- **Larger line helps**: spatial locality + tag overhead + compulsory miss; **hurts**: miss penalty + bandwidth + fewer lines + capacity/conflict.
- **VA / PA**: load/store generate **VA**; physically tagged caches use **PA**; TLB caches PTE; page table is in **main memory**.
- ==**TLB miss may trigger page fault**== (if PTE invalid → OS swap-in or kill).
- **VIPT** (virtually indexed, physically tagged) cache can **overlap address translation** with cache access.
- **Virtual-tagged cache**: complicated by **synonyms / aliasing** (2 VAs → 1 PA).
- ==**Set index uses middle bits**==: block-offset consumes low bits; middle bits spread nearby sequential blocks across sets. MSB indexing would map nearby addresses to same set too often → wastes spatial locality.
- **TLB and victim cache are usually fully associative**.
- **Direct-mapped vs set-assoc** (same C, B):
  - **DM has lowest tag overhead + simplest replacement** ✅
  - 2-way has **more sets** than 4-way ✅
  - Fully-assoc does **NOT** automatically have lowest miss rate (depends on replacement)
  - DM = "1-way" (NOT "1-set"); fully-assoc = "1-set".
- ==**Conflict miss trigger**==: addresses spaced by multiple of cache size map to same set. Fix: padding, alignment, code repositioning (but compiler may remove unused dummies — must actually use them).
- **Modern L1D config**: **4-way set-associative + write-back + write-allocate** (Quiz 4 #11).
- **L3 typically shared** by all cores; **L1 fast hit time**; **L2 unified, slower than L1, often private**.
- **Vast chip area** in modern CPUs = ==**caches**==.
- **JIT / instruction patching needs**: flush I-cache, invalidate I-lines, maintain I/D coherence (NOT flush D-cache alone).
- **Sorting locality**: **Quicksort, Insertion, Bubble = high locality**; **Heapsort, Radix sort = poor**.
- **HW vs SW cache**: HW associative-tag + simple/fast policies; SW manages via hash/tree/etc., flexible policies.

## 1. Memory Hierarchy

| Level | Example | Mgr | Notes |
|---|---|---|---|
| **L0** | registers | **compiler/programmer** | fastest, smallest, $$$ |
| **L1/L2/L3** | SRAM cache | **HW** | each level holds lines from below |
| **Local memory** (scratch-pad / GPU shared) | SRAM | **compiler/programmer** | explicitly managed |
| **L4** | DRAM (main mem) | **OS + MMU + HW (VM)** | per-process VA → PA |
| **L5** | local SSD/HDD | OS + apps | persistent |
| **L6** | remote / DFS | network | huge, slow |

==**Locality**==:

| Type | Meaning | Example |
|---|---|---|
| **temporal** | reused soon | loop body instr, hot var |
| **spatial** | neighbors used soon | array scan, sequential fetch |

> Quiz: `while (A) A = A->next;` → poor data spatial locality (random heap), but **good instruction spatial / temporal locality** (tight loop body).

## 2. RAM and Memory Wall

### 2.1 SRAM vs DRAM

| | **SRAM** | **DRAM** |
|---|---|---|
| cell | 6–8 transistors | 1T + 1C |
| refresh | **NO** | **YES** (every ~64 ms) |
| speed | fast (~1 cycle) | slow (50–70 ns) |
| density | low | high |
| cost | ~100× | 1× |
| use | **caches**, local mem | **main memory** |

> SRAM expensive because: many transistors/bit, lower density, more complex, lower volume.

==**DRAM read sequence**==:

```text
1. RAS (Row Access Strobe)
   - send row addr; entire row copied to internal Row Buffer.
2. CAS (Column Access Strobe)
   - send col addr; supercell copied from buffer to data lines → CPU.
3. Refresh
   - row buffer written back to DRAM array (read is destructive).
```

==**GPU global memory**==: **HBM** (high-bandwidth memory; stacked DRAM).

==**Other DRAM types**==: FPM, EDO, **SDRAM**, **DDR SDRAM** (dominates today), RDRAM, VRAM, eDRAM. **All offer higher bandwidth, but latency stays similar.**

### 2.2 Memory Wall

==**Memory wall**==: CPU speed grows faster than DRAM latency / bandwidth.

| Wall | Reduction | Hiding |
|---|---|---|
| **Latency** | caches, **local memory**, NUMA, PIM | multi-threading, hyper-threading, WARP interleaving, chip-multithreading |
| **Bandwidth** | HBM, multi-banks, interleaved memory, wider bus | compression, blocking, fewer bytes (low-precision FP) |

> Quiz 2 #3 (Q3a): **memory wall** = the growing gap between processor speed and main memory speed.

## 3. Cache Basics

### 3.1 Cache Line / Set / Lookup

==**Cache line / block**==: fixed-size copy of contiguous lower-level bytes (typically 64 B today; sometimes 32 or 128).

==**Address split**==:

```text
addr = [    tag    |  set index  |  block offset  ]
       \____ t ____/\____ s ____/\______ b _______/
```

==**Lookup steps**==:

1. extract `set` from index bits.
2. compare `tag` against each valid way in that set.
3. **hit** if any tag matches AND that line's valid bit = 1.
4. block offset selects byte/word.
5. **miss**: pick victim; if dirty under write-back, write back; fill new line; set valid+tag.

==**Why index = middle bits**==: block offset takes the LOW bits (intra-line); set index takes the **middle bits** so that **sequentially adjacent blocks land in different sets** → spatial scan spreads load across sets. Using high bits as index would pack a long contiguous run into one set → conflict-miss disaster.

==**Cache-like structures**==:

| Structure | What it caches | Tagged? |
|---|---|---|
| L1/L2/L3 | data/instruction lines | ✅ |
| **TLB** | recent PTE translations | ✅ (usually fully assoc) |
| **BTB** | branch target PCs | ✅ partially tagged |
| **BHT/PHT** | branch direction history | ❌ **untagged** |
| single-level page table | VPN-indexed PTE array | ❌ (VPN is index) |

> CSC3050 anchor: **BTB, TLB, L3 cache, branch prediction table** are all cache-like. **BHT/PHT may have no tag bits** because direction bits are tiny and IF needs fast/cheap access.

> Quiz 4 #2: NOT stored per cache line: ==**set number**== (it's part of the address). What IS stored: data, tag, valid bit, dirty bit (write-back).

### 3.2 Cache Parameter Formulas

For `m` address bits:

$$
\boxed{S = \frac{C}{B \cdot E}, \quad b = \log_2 B, \quad s = \log_2 S, \quad t = m - s - b}
$$

| Symbol | Meaning |
|---|---|
| `C` | cache size (bytes) |
| `B` | block size (bytes) |
| `E` | associativity (ways per set) |
| `S` | number of sets |
| `m` | address bit width (e.g. 32) |

==**Worked: 64 KB, 4-way, 32 B line, 32-bit address**== (Quiz 4 #4):

```text
S = 65536 / (4 * 32) = 512 sets
b = log2(32) = 5
s = log2(512) = 9
t = 32 - 9 - 5 = 18

Answer: tag 18 | set index 9 | block offset 5
```

==**Worked: 16 KB, 64 B line, direct-mapped, 32-bit**== (CA3060-6 Ex1):

```text
S = 16384 / (1 * 64) = 256 sets
b = 6, s = 8, t = 32 - 8 - 6 = 18
```

==**Worked: 16 KB, 64 B line**==:

| Org | # sets |
|---|---:|
| direct-mapped | 256 |
| 2-way | 128 |
| 4-way | 64 |
| 8-way | 32 |
| **fully associative** | **1** |

==**Total cache bits**==:

```text
DataBits     = C * 8
Lines        = S * E
MetadataBits ≈ Lines * (1 + t + d)         # d=1 if dirty bit
```

> Add coherence-state bits (e.g., 2 for MESI) for multicore caches.

### 3.3 Address Decomposition (Bit Math)

```text
block_offset = addr & (B - 1)
set_index    = (addr >> b) & (S - 1)
tag          = addr >> (b + s)
block_addr   = addr >> b              # uniquely identifies a block

Equivalent:
block = addr / B
set   = block mod S
tag   = block / S
```

> Two addresses hit the same line iff **same tag AND same set**.

> ==**Why middle bits for `set_index`?**== Low `b` bits are byte-in-line; using next `s` bits makes adjacent blocks cycle through sets. If MSBs indexed the cache, common sequential arrays would pound one/few sets before high bits change.

### 3.4 Direct-Mapped Trace Pattern

Each set has 1 line:

```text
if valid[set] && tag[set] == addr.tag:  HIT
else:                                    MISS; evict; tag[set]=addr.tag; valid[set]=1
```

==**Conflict miss pattern**==: access `A, B, A, B, ...` where `set(A) == set(B)` but `tag(A) != tag(B)`.

> In DM cache, addresses **spaced by multiples of cache size** map to the same set.

==**Worked**==: 4 KB DM, 32 B line: `S = 4096/32 = 128`. Set repeats every `128 * 32 = 4096 B = 0x1000`.

> Distance for conflict in DM = **`B * S` = cache size**.

==**Quiz 4 #21 conflict trace example**==: 4 KB, 2-way, 32 B line → `S = 4096/(2*32) = 64`. Set repeats every `64 * 32 = 2048 B = 0x800`. With > 2 live blocks mapping to same set, get conflicts.

### 3.5 Set-Associative Trace

```text
1. select set from index bits.
2. HIT if any valid matching tag.
3. MISS, empty way → fill it.
4. MISS, full → evict by replacement policy (LRU / pseudo-LRU / random / FIFO).
```

### 3.6 Matrix / Array Miss Rate

For elem size `e`, line `B` → one line holds `B/e` contig elements.

| Pattern | Miss rate |
|---|---|
| row-major row scan, no conflict/capacity issue | ≈ `e/B` (1 miss per line) |
| col scan with large stride | often **~100% miss** |

==**Worked**==: row-major `A[1024][1024]` of int (4B), 64 B line:
- Row scan: miss every 16 elements → ≈ 6.25% miss rate.
- Col scan: each access different row → 100% miss (line evicted before reuse).

> Quiz CSC3050 final #3: `for j: for i: C[j][i] = A[j][i] + B[j][i]` (column scan in row-major) on 4 KB L1D → miss every access, **NO data spatial locality** at L1D.

==**Mixed row+col scan**== (`int`, 32B line → 8 elems/line, large `N`, cache holds rows):

```c
// sum1: A row, B col — mixed
sum += A[i][k] + B[k][i];    // A: 1/8 miss, B: ~100% miss → avg = 9/16
// sum2: both row scans
sum += A[i][k] + B[i][k];    // both: 1/8 miss → avg = 1/8
```

> Rule: **average miss rate of mixed accesses** = `(MR_A + MR_B) / 2` for one access of each per loop iter.

==**4 KB DM, 32 B line, `double A[1024], B[1024]`**==: A and B both stride by 4 KB → if line size is 32B, addresses A[i] and B[i] differ by 8 KB which is 2× cache size → both map to same set! → **conflict misses every iter**.

==**Streaming**==: `k` independent streams work well only if associativity ≥ k AND sets don't collide.

> Trap: `arr[0][0]` may start near end of a cache line → first few accesses may cross to next line earlier than expected.

> If the entire working set fits in cache and no conflicts → **only compulsory misses**.

==**Mini cache trace** (illustrates the concept): 8-bit address, 64B DM cache, 8B blocks==:

```text
b = log2(8) = 3 (offset)
S = 64/8 = 8 → s = 3 (index)
t = 8 - 3 - 3 = 2 (tag)
addr = [ tag(2b) | set(3b) | offset(3b) ]
```

| Load | Addr | tag/set | Hit? | Why |
|---|---|---|---|---|
| `0x43` | `01\|000\|011` | t=1,s=0 | M | compulsory |
| `0x40` | `01\|000\|000` | t=1,s=0 | **H** | same line |
| `0xb2` | `10\|110\|010` | t=2,s=6 | M | compulsory |
| `0xb0` | `10\|110\|000` | t=2,s=6 | **H** | same line |
| `0x07` | `00\|000\|111` | t=0,s=0 | M | tag≠1, conflict miss with `0x43` |

### 3.7 C Row-Major Iteration

==**Good (row-major, contiguous)**==:

```c
for (i=0; i<R; i++)
  for (j=0; j<C; j++)
    use(A[i][j]);
```

==**Bad (column scan)**==:

```c
for (j=0; j<C; j++)
  for (i=0; i<R; i++)
    use(A[i][j]);   // stride = C * sizeof(elem)
```

## 4. The 4 Cache-Design Questions

| Question | Mechanism |
|---|---|
| Where can a block go? | **placement / associativity** |
| How is a block found? | **index + tag compare** |
| Which block is evicted? | **replacement policy** |
| What happens on writes? | **write policy** |

| Org | Meaning | Pros / Cons |
|---|---|---|
| ==**direct-mapped**== | E=1 | simplest hit path; many conflicts; lowest tag overhead |
| ==**set-associative**== | E>1 | balanced |
| ==**fully associative**== | S=1 | least conflicts but costly tag search |

==**Tag overhead minimization**== (Quiz 4 #12): use **direct-mapped + large blocks**.

==**True/false anchors (same C, B)**==:

| Claim | Truth |
|---|---|
| fully-assoc = 1-way | ❌ (it's **1-set**, all lines in one set) |
| DM = 1-set | ❌ (it's **1-way**, multiple sets) |
| 2-way has more sets than 4-way | ✅ |
| DM always faster hit than set-assoc | ❌ as "always"; usually simpler/faster, not guaranteed |
| **DM has lowest tag overhead** | ✅ |
| **DM has simplest replacement** | ✅ (no choice — only one line per set) |
| fully-assoc has more lines | ❌ (line count = C/B, same) |
| fully-assoc always has lowest miss rate | ❌ (depends on replacement; LRU can lose to DM in pathological cases) |

==**Larger block trade-offs**==:

| **Helps** | **Hurts** |
|---|---|
| spatial locality | miss penalty (transfer time) |
| **compulsory misses** ↓ | bandwidth |
| **tag overhead** ↓ | fewer lines → conflict / capacity misses ↑ |
| | pollution if not all of line used |

> Mitigation for big-line miss penalty: **early restart, critical-word-first**.

## 5. Write Policies

### 5.1 Write Hit

| Policy | Behavior | Pros | Cons |
|---|---|---|---|
| ==**write-through**== | update cache + next level NOW | data always fresh in lower level | every write goes to memory; high traffic |
| ==**write-back**== | update cache, set **dirty bit**; write only on eviction | low memory traffic; high write throughput | cache loss = data loss; coherence harder |

==**Write buffer**==: FIFO between write-through cache and memory; CPU continues without waiting (only stalls when buffer full). **Write-coalescing/combining** can reduce traffic.

> Effective CPI w/o buffer: base + (% stores × memory write latency). E.g., base=1, 10% stores, 100-cycle write → CPI = 11. With buffer → near base CPI.

### 5.2 Write Miss

| Policy | Behavior | Use case |
|---|---|---|
| ==**write-allocate**== | fetch line, then write | likely reuse (most data) |
| ==**no-write-allocate / write-no-allocate**== | bypass cache; write straight to memory | streaming writes |

==**no-write-allocate use cases**==:

- ==**`memcpy(a, b, n)` with large n**== ✅ (won't reread soon)
- ==**`memset(a, b, n)` with large n**== ✅ (initialization)
- ==**database logs**== ✅ (write-only)
- local var writes / struct member updates ❌ (need write-allocate)

> **Trace implication**: under no-write-allocate, write miss does **NOT** install line. Subsequent read can still miss.

### 5.3 I-Cache (No Stores from CPU)

==**I-cache simpler than D-cache**==:

- no CPU stores → **no write policy, no dirty bit** (still has valid + tag + data).
- can ignore write-back/write-through complexity.
- still has tag + valid bit (for finding lines).

==**JIT / instruction patching / self-modifying code**==: need to evict stale instrs. Solutions:

1. **Flush I-cache** (purge old) ✅
2. **Invalidate** affected I-lines ✅
3. **Maintain I/D coherence** (D-cache writes update I-cache copies) ✅
4. flush D-cache alone ❌ (insufficient)

## 6. Cache Performance

### 6.1 Stall Cycles

$$
Memory\ Stall\ Cycles = IC \times \frac{MemAccesses}{Instr} \times MissRate \times MissPenalty
$$

$$
CPI = CPI_{base} + \frac{Stalls}{Instr}
$$

==**Split I/D**==:

```text
stalls/instr = I_MR * I_MP   +   data_acc/instr * D_MR * D_MP
```

==**Worked: 5% D miss, 40% load/store, 100-cycle penalty, base CPI=1**== (Quiz 4 #8):

$$
CPI = 1 + 0.40 \times 0.05 \times 100 = \mathbf{3.0}
$$

==**Worked: 50% load/store**== (CSC3050 final #10):

$$
CPI = 1 + 0.50 \times 0.05 \times 100 = \mathbf{3.5}
$$

==**Worked: I-MR=2%, D-MR=4%, D-acc=36%, base CPI=2, MP=100**==:

```text
I-stall = 0.02 * 100 = 2
D-stall = 0.36 * 0.04 * 100 = 1.44
CPI    = 2 + 2 + 1.44 = 5.44
Speedup over perfect cache = 5.44 / 2 = 2.72×
```

### 6.2 AMAT

$$
AMAT = HitTime + MissRate \times MissPenalty
$$

==**Multi-level**==:

$$
AMAT = HT_1 + MR_1\,(HT_2 + MR_2\,(HT_3 + MR_3 \cdot MP_{mem}))
$$

> ==`MR_2`, `MR_3` are **local** miss rates== (fraction of accesses to that level that miss).

==**Overall AMAT**== (split I/D):

$$
AMAT_{overall} = \%instr \times AMAT_{I-cache} + \%data \times AMAT_{D-cache}
$$

==**Typical L1D hit latency**==: **3-4 cycles** (Skylake, Zen, ARM).

> Stages: VA→PA / index → tag compare → align/ECC → forwarding/RF.

==**AMAT no longer accurate**== (Quiz CSC3050 #19): under **OoO + non-blocking caches**, multiple misses overlap; AMAT doesn't account for this. Also: cache prefetching, split I/D.

==**Miss-penalty reducers**==:

- **critical-word-first / early restart**.
- **non-blocking cache (lockup-free)**: hit-under-miss, miss-under-miss.
- **prefetch** (HW or SW).
- **write/writeback buffer**.

## 7. 4 C's of Cache Misses

| Miss | Cause | Fix |
|---|---|---|
| **Compulsory (Cold)** | first access | **larger block, prefetch** (NOT bigger cache) |
| **Conflict (Collision)** | mapping collision in finite assoc | **higher associativity, victim cache, padding/alignment, code repositioning** |
| **Capacity** | working set > cache | **bigger cache, blocking/tiling, reduce footprint, prefetch (sometimes)** |
| **Coherence** | invalidation by other core | **reduce sharing, padding, partitioning** |

> Quiz 4 #15: ==**Coherence misses are the most difficult to remove**== (need program rewrite).

==**Increase cache size reduces**==: **capacity + conflict** misses. **NOT** compulsory or coherence (CSC3050 #7 → answer B, C).

==**Reduce conflict in DM L1D**== (Quiz 4 #29): **larger cache, victim cache, change to set-assoc, redesign algorithm**. (Bigger line doesn't directly help — may increase conflict.)

==**Reduce capacity**== (Quiz 4 #30): **larger cache, prefetching**. (Victim cache and assoc don't help capacity directly.)

==**Direct-mapped conflict trigger**==: objects spaced by multiple of cache size → same set. **Fix with padding/alignment/code repositioning**, BUT **dummy padding may be optimized away unless actually used**.

==**Common conflict scenarios**== (4 KB DM, 64 B line):

| Scenario | Cause |
|---|---|
| `proc A` and `proc B` both at addrs differing by mult of 4 KB → I-cache conflict | code layout |
| `float A[1024][1024]; b[i] = A[i][j] + A[i+1][j]` → row stride 4 KB → both A[i][j] and A[i+1][j] same set | array stride |
| `double A[1024], B[1024], C[1024]` → strides may align | back-to-back arrays |

==**Code repositioning fixes**==:

- layout `B` adjacent to `A`.
- `A[1024][1040]` (pad rows to break stride alignment).
- `A[1024], pad[8], B[1024]`. **But pads may be removed by compiler** unless used.

## 8. Replacement Policies

| Policy | Note |
|---|---|
| ==**LRU**== (Least Recently Used) | exact stack; expensive at high assoc |
| ==**Pseudo-LRU**== | typical in real caches; tree-based approximation |
| **Random** | cheap; surprisingly good |
| **FIFO** | simple |
| ==**Belady optimal**== | evict farthest future use; **theoretical upper bound** (not implementable) |

==**True LRU data structure**==: ==**stack**==.

==**Belady**== (Quiz 4 #25): the upper bound to evaluate any replacement against. Minimizes misses, **NOT necessarily traffic** (clean evict cheaper than dirty writeback).

==**LRU vs FIFO trap**==: set holds A, B, C; access A; miss D:

- **LRU evicts B** (least-recently used = B; A was just touched).
- **FIFO evicts A** (first in).

==**Modern caches**==: **approximate LRU / pseudo-LRU** (Quiz 4 #23 → answer C).

### 8.1 Victim Cache

==**Victim cache**==: small **fully-associative** buffer of recently-evicted lines.

- usually 4-8 lines.
- combined with DM L1D to reduce conflict misses.
- combines DM speed + FA flexibility.

==**Sequence**== `0, 4, 8, 12, 16, 4, 8, 0, 12, 4, 0, 5, 6, ...`: many addresses map to same DM set, but fit in tiny FA victim cache.

==**Victim cache vs 2-way set-assoc**==:

| | Victim cache | 2-way |
|---|---|---|
| good for | **clustered repetitive** conflict misses (high temporal locality on a few sets) | **evenly distributed** conflict misses across many sets |
| tag overhead | tiny (only 4-8 lines) | doubles the L1 tags |
| hit latency | DM-fast for L1; small extra check | slightly slower L1 (mux for ways) |

> General-purpose CPUs use **2-way+ set-assoc** more often. Victim caches show up in older/embedded designs.

### 8.2 Associativity & Miss Rates

Increasing associativity → diminishing returns:

| Assoc | Typical miss rate (general) |
|---|---|
| 1-way (DM) | 3% – 10% |
| 2-way | 2% – 7% |
| 4-way | 1.5% – 5% |
| 8-way | 1% – 4.5% |

> "Sweet spot" exists — modern L1D often 4-way or 8-way.

==**A case where DM > FA-LRU**==: 5-line working loop on 4-line FA-LRU cache → 0% hit (always evicting next-needed). Same 5 lines on DM → 60% hit (3 unique sets fit, 2 conflict).

## 9. Multi-Level Caches

| Level | Typical config | Goal |
|---|---|---|
| **L1I / L1D** | small (16–64 KB), private, **split I/D** | **fast hit time** |
| **L2** | larger (256 KB–1 MB), often private/unified, slower | balance speed + capacity |
| **L3 (LLC)** | large (multi-MB), **shared by all cores** | **reduce DRAM traffic** |

==**Hit-rate cascade**==:

| Cache | Typical hit rate (relative) |
|---|---|
| L1 | 80–95% |
| L2 | 50–80% (of L1 misses) |
| L3 | 20–40% (of L2 misses) |

==**Worked: 4 GHz, base CPI=1, miss/instr=2%, mem=100ns**==:

- No L2: mem penalty = 400 cy → CPI = $1 + 0.02 \times 400 = 9$.
- With L2 (5ns hit, 20% L2-miss to mem): CPI = $1 + 0.02 \times (20 + 0.2 \times 400) = 3$ → **3× speedup**.

==**Multi-level true facts**==: **L3 reduces memory traffic** ✅; **L1 → fast hit time** ✅; **L3 shared by cores** ✅; **L2 → balance speed + capacity** ✅.

==**L3 write-through**==: nonsensical (would create huge memory traffic at the wrong layer).

==**Split L1I/L1D**== (Quiz 4 / CSC3050): for **higher access bandwidth + different management policies** (I-cache no writes; D-cache write policy). NOT for hit rate alone, NOT for reliability.

==**L1 vs L2**== focuses:

| L1 | L2 |
|---|---|
| spatial locality more critical | temporal locality more critical |
| write-through (sometimes) | write-back common |
| fast hit time | low miss rate |

### 9.1 Inclusion Policies

| Policy | Meaning |
|---|---|
| ==**Inclusive**== | every L1 line also in L2 |
| ==**Exclusive**== | line in exactly **one** of L1, L2 |
| ==**NINE**== | non-inclusive, non-exclusive |

==**Inclusive ops**==: L2 evicts a line → **back-invalidate** in L1.
==**Exclusive ops**==: L1 evicts → moves to L2; L1 miss + L2 hit → **migrates** to L1.

==**Project 4 cache**== = **NINE** (Quiz 4 #22).

==**Quiz nonsensical organizations**== (Quiz 4 #33):

| Organization | Why bad |
|---|---|
| **L1I copy-back + L1D write-through** | I-cache has no CPU stores → copy-back meaningless |
| **L1/L2 exclusive + L2/L3 inclusive** | conflicting inclusion semantics |
| **L1D 4-way set-assoc + L2 direct-mapped** | lower level worse placement than upper |
| L1/L2 inclusive + L2/L3 exclusive | OK in principle (L2/L3 exclusive popular at AMD) |

==**Inclusive advantages**==: simpler coherence — invalidation check at L2 (not L1).
==**Exclusive advantages**==: no L1 lines duplicated in L2 → effectively bigger total cache.

## 10. Cache Coherence

==**Snoopy cache coherence**==: private caches **watch a shared bus**; each cache controller "snoops" coherence traffic and reacts.

> Quiz 4 #28: snoopy = (1) maintain coherence in **bus-connected multi-processor**, (2) generates significant snoop traffic. NOT a watchdog, NOT for security.

==**MESI protocol**==:

| State | Meaning |
|---|---|
| **M** (Modified) | dirty, only copy in this cache |
| **E** (Exclusive) | clean, only copy |
| **S** (Shared) | clean, may be in other caches |
| **I** (Invalid) | not present / stale |

==**False sharing**==: different vars in same line → invalidations even though semantically independent. Fix: **padding** or alignment.

==**Coherence solution choices**== (CSC3050 final-equiv): **shared cache (no privates)** OR **snoopy on private caches**.

## 11. Address Translation Side Points

> Scope note: CSC3060 only touches address translation as **side points** in lec 6; multi-level page tables, PDE/PTE walks, and TLB exam problems are CMU/CSAPP territory — **not core CSC3060 final material**. Keep this section brief.

==**TLB**==: small SRAM cache of recent **PTEs**; maps VPN → PPN.

```text
TLB hit  → use cached PPN
TLB miss → page-table walk in main memory
PTE valid=0 → PAGE FAULT → OS brings page from disk or kills process
```

> [!NOTE]
> **Normal cache miss** fetches from DRAM/lower cache. **Page fault** is the VM exception path **after translation fails**. ==**TLB miss may trigger page fault**== — chain effect.

==**Page table facts**== (CSC3050 final-level depth):

| Item | Answer |
|---|---|
| VM purpose | VA space > PA, demand paging, isolation/protection, sharing (`mmap`, shared libs) |
| page table location | **main memory**, pointed to by a CPU register (e.g., `satp`) |
| PTE contents | **physical page number + valid + permission + status bits** |
| invalid/not-present PTE | may point to disk/swap; reference → page fault |
| page replacement | like cache replacement, but OS can use more complex policies because disk fault cost ≫ cache miss |
| TLB purpose | avoid slow page-table walk on most accesses |
| reduce TLB miss | larger / more-assoc TLB, multi-level TLB, large pages, PTE prefetch |

==**Address splits**== (just the formula, not deep walks):

```text
VA  = [   VPN   |   VPO   ]
PA  = [   PPN   |   PPO   ]     (VPO == PPO)
TLBI = VPN mod #TLB_sets
TLBT = VPN >> log2(#TLB_sets)
Physical cache lookup: [ cache tag | set index | block offset ]
PA = (PPN << VPO_bits) | VPO
```

==**Virtual-address cache**== / **VIPT** (virtually indexed, physically tagged) can **avoid or overlap address-translation delay**.

==**Virtual-tagged caches**== are complicated by ==**synonyms/aliasing**==: two VAs → same PA (CSC3050 final #5).

==**No-tag mapping tables**== (CSC3050 final #6): ==**single-level page table**== — VPN is the index, no tag bits needed (BHT also untagged but for different reasons).

## 12. Locality / Application Patterns

==**Pointer chasing**== (`while (p) p = p->next`): poor spatial locality + load-use chain → latency-bound.

==**Fixes**== (Quiz 2 #5):

| From | To |
|---|---|
| linked list | **arrays / vectors** |
| binary tree | **B / B+ trees** |
| chained hash | **open addressing** |
| traverse 1 at a time | **batch independent traversals** (multiple in-flight) |
| many small allocs | **pool / arena allocator** |

==**Vector loads/stores vs cache**==: vector ISA exposes regular memory streams (good for bandwidth / latency hiding); data caches are better for unpredictable locality from pointer aliasing and irregular objects.

==**Sorting locality**== (Quiz 4 #35):

| Algorithm | Locality |
|---|---|
| **Quicksort** | high (recursive on adjacent halves) |
| **Insertion sort** | high (sequential) |
| **Bubble sort** | high (sequential pairs) |
| **Heapsort** | **poor** (random heap accesses) |
| **Radix sort** | poor (out-of-place buckets) |

> Quicksort wins despite `O(N log N)` over Radix's `O(N)` — locality matters more for moderate N.

==**HW vs SW cache**== (Quiz 4 #36):

| HW cache | SW cache (e.g., disk file cache) |
|---|---|
| transparent | managed by OS / app |
| **associative** tag compare | **hash / tree** lookup |
| **simple/fast** replacement | can use **complex** policies |
| fixed structure | flexible |

## 13. MSHR & Non-Blocking Cache

==**MSHR**== (Miss Status Handling Register): tracks outstanding misses; allows multiple in-flight → **MLP**.

==**Blocking vs non-blocking**==:

| | Blocking | **Non-blocking (lockup-free)** |
|---|---|---|
| on miss | stall pipeline | **continue** with independent instrs |
| stall | "stall-on-miss" | "stall-on-use" (only when result needed) |
| supports | — | **MLP** (multiple outstanding misses) |

==**Models**==: **hit-under-miss** (allow hit while miss pending), **miss-under-miss** (multiple misses pending).

==**MSHR functions**==:

- track each pending miss (address, requestor).
- **miss merging / coalescing** (multiple loads to same line wait on one fill).

==**L3 MSHR count**== depends on (Quiz 4 #31): **memory latency + memory bus width**. NOT L2 size, NOT cores sharing L3 directly.

> **Why bandwidth-heavy features need MSHRs**: large lines, prefetch, non-blocking, write-through. These all generate concurrent traffic.

## 14. Practical Examples

==**Intrinsity FastMATH**== (12-stage MIPS embedded):

- **Split I-cache + D-cache**, each 16 KB = 256 lines × 64 B/line.
- D-cache: write-through OR write-back.
- SPEC2000: I-MR 0.4%, D-MR 11.4%, weighted 3.2%.
- I-cache miss rates higher in DBMS / VM / interpreter / JIT / OO programs.

==**Modern processor**== (Quiz 4 #34): **vast chip area = caches**.

> Akamai CDN: distribution stations as content cache. Modern GPUs: register-file cache.

## 15. Quick Quiz Anchors

| Q | Answer |
|---|---|
| 32-bit all-0 → possible? | int 0 ✅; FP +0.0 ✅; chars NULx4 ✅; **denorm ❌** (nonzero frac) |
| memory wall | gap CPU vs DRAM |
| storage NOT in cache line | **set number** |
| layer managed by compiler/programmer | **registers + local memory** |
| L3 shared by all cores | ✅ |
| 5% D-MR, 50% load/store, MP=100, base=1 | **CPI = 3.5** |
| 5% D-MR, 40% load/store, MP=100, base=1 | **CPI = 3** |
| 64KB 4-way 32B line 32-bit | tag 18, set 9, offset 5 |
| L1D hit latency modern | **3-4 cycles** |
| modern L1D config | **4-way + write-back + write-allocate** |
| true LRU data structure | **stack** |
| upper bound on replacement | **Belady** |
| DM: lowest tag overhead | ✅ |
| coherence solution choices | shared cache OR snoopy on private |
| DRAM in modern GPU | **HBM** |
| caches occupy most chip area | ✅ |
| sorting w/ high data locality | Quicksort, Insertion, Bubble |
| TLB miss may → | **page fault** |
| page table location | **main memory** |
| cache-like structures | BTB, TLB, L3, branch pred table |
| no-tag mapping table | **single-level page table** |
| fully-assoc caches | **TLB, victim cache** |
| address aliasing complicates | **virtual-address-tagged cache** |
