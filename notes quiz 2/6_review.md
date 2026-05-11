# Lec 6: Memory Hierarchy

## Exam Facts

- ==**Memory hierarchy**==: small/fast/expensive near CPU → large/slow/cheap far → illusion of **fast + large + inexpensive**.
  - L0 **registers** ← compiler / programmer.
  - L1/L2/L3 **caches** ← HW.
  - **Local memory** (scratch-pad / NVIDIA shared mem) ← compiler / programmer.
  - L4 **DRAM / VM** ← OS + MMU + HW. L5/L6 disk / files ← OS + apps.
  - ==**Locality**==: temporal (reused soon), spatial (neighbors soon).
- **SRAM vs DRAM**: SRAM 6-8 T/bit, fast, no refresh, ~100× cost → caches. DRAM 1T+1C/bit, dense/cheap, slower, **needs refresh** → main memory.
  - **DRAM read**: **RAS** (row → row buffer) → **CAS** (col → data lines); refresh writes the row back (read is destructive).
  - **GPU global memory**: ==**HBM**==.
  - DDR SDRAM dominates. All higher-bw DRAM has similar latency.
- ==**Memory wall**==: gap between CPU speed and DRAM lat / bw.
  - **Latency**: caches / local mem, prefetch, multi-thread, MLP.
  - **Bandwidth**: HBM, multi-banks, wider bus, blocking, compression.
- ==**Terminology**==: ==**Block (line)**== = transfer unit between levels; ==**Hit**== = upper-level satisfies; ==**Miss**== = fetch from lower; **Hit ratio** = hits / access; **Miss ratio** = 1 − Hit ratio; **Miss penalty** = extra time on miss. ==**Hit time ≪ Miss penalty**==.

- ==**Cache line**== = **valid + tag + data** (+ dirty for WB; + coherence state for multicore). ==**NOT stored**==: **set number** (it's an address field).
- ==**Address split**==: `[ tag | set index | block offset ]`; $S = C/(B \cdot E)$, $b = \log_2 B$, $s = \log_2 S$, $t = m - s - b$.
  - ==**Why middle bits = set index**==: low `b` = byte-in-line; middle `s` = adjacent blocks cycle through sets → spatial scan spreads load. MSB indexing would pound one set.
  - **DM vs set-assoc** (same C, B): DM (E=1) has **lowest tag overhead + simplest replacement**; 2-way has **more sets** than 4-way; fully-assoc ≠ lowest miss (depends on replacement). DM = "1-way"; fully-assoc = "1-set".
- **Modern L1D** = **4-way set-assoc + write-back + write-allocate**; hit latency **3-4 cy**.
  - **I-cache** simpler: no CPU stores → no write policy / dirty bit. JIT needs flush / invalidate / I-D coherence.
  - **L3 shared** by all cores; **L1 fast hit**; **L2 unified, slower, often private**.
  - Vast chip area = caches.
- ==**MSHR**==: tracks outstanding misses → **non-blocking cache + MLP**. **L3 MSHR count** depends on **mem latency + bus width** (NOT L2 size, NOT cores sharing).
- **AMAT** $= HT + MR \times MP$. Multi-level uses **local** miss rates. AMAT inaccurate under OoO + non-blocking caches.
- ==**4 C's**==: **Compulsory, Conflict, Capacity, Coherence**. ==**Hardest to remove**== = **Coherence** (needs rewrite).
  - **Larger cache reduces**: capacity + conflict; NOT compulsory or coherence.
  - **Larger line helps**: spatial locality, tag overhead, compulsory; **hurts**: miss penalty, bandwidth, fewer lines.
- **Conflict miss trigger**: addresses spaced by **multiple of cache size** map to same set. Fix: padding (must be **used**), alignment, code repositioning.
- **Sorting locality**: Quicksort, Insertion, Bubble = **high**; Heapsort, Radix = **poor**.
- ==**TLB miss may → page fault**== — the one cross-layer jump (caches don't access disk; TLB miss + invalid PTE triggers an OS page fault that fetches from disk).
  - **Page table** lives in **main memory** (ptr in CPU reg, e.g., `satp`); PTE = PPN + valid + permission.
  - **No-tag mapping** = **single-level page table** (VPN is the index, no tag needed).
  - **Fully-assoc structures**: **TLB** + **victim cache** (small enough to do full tag search).
  - **Virtual-tagged cache** complicated by ==**synonyms / aliasing**== (2 VAs → 1 PA = same data appears under 2 tags). **VIPT** (virt-index, phys-tag) sidesteps by overlapping translation with cache access.

## 1. SRAM vs DRAM

| Metric   | cell            | refresh          | speed           | density | cost  | use                   |
| -------- | --------------- | ---------------- | --------------- | ------- | ----- | --------------------- |
| **SRAM** | 6–8 transistors | ❌                | fast (~1 cy)    | low     | ~100× | **caches**, local mem |
| **DRAM** | 1T + 1C         | ✅ (every ~64 ms) | slow (50–70 ns) | high    | 1×    | **main memory**       |

**DRAM read**: RAS (row → row buffer) → CAS (col → data lines) → Refresh (write back, read is destructive).

==**DRAM family**== (all higher-bw, **same latency**): **FPM, EDO, SDRAM, DDR SDRAM** (dominant), **RDRAM**, **VRAM**, **eDRAM**, **Flash / NV** (EEPROM, USB), **HBM** (GPU global mem).

**Memory wall** (CPU speed > DRAM):

| Wall          | Reduction                                    | Hiding                                                |
| ------------- | -------------------------------------------- | ----------------------------------------------------- |
| **Latency**   | caches, local mem, NUMA, PIM                 | multi-threading, hyper-threading                      |
| **Bandwidth** | HBM, multi-banks, interleaved mem, wider bus | compression, blocking, fewer bytes (low-precision FP) |

## 2. Cache Basics

**Address split**:

```text
addr = [    tag    |  set index  |  block offset  ]
       \____ t ____/\____ s ____/\______ b _______/
block_offset = addr & (B - 1)
set_index    = (addr >> b) & (S - 1)
tag          = addr >> (b + s)
```

**Lookup**: extract `s` → compare tag against valid ways → `hit = (tag match) ∧ (valid=1)` → block offset selects byte. Miss: pick victim; if dirty (WB), write back; fill new line; set valid + tag.

**Cache-like structures**:

| Structure | What it caches | Tagged? |
|---|---|---|
| L1 / L2 / L3 | data / instr lines | ✅ |
| **TLB** | recent PTE translations | ✅ (usually fully assoc) |
| **BTB** | branch target PCs | ✅ partially tagged |
| **BHT / PHT** | branch direction history | ❌ untagged |
| single-level page table | VPN-indexed PTE array | ❌ (VPN is index) |

### 2.1 Parameter Formulas

$$
S = \frac{C}{B \cdot E}, \quad b = \log_2 B, \quad s = \log_2 S, \quad t = m - s - b
$$

| Symbol      | `C`            | `B`            | `E`                  | `S`    | `m`              |
| ----------- | -------------- | -------------- | -------------------- | ------ | ---------------- |
| **Meaning** | cache size (B) | block size (B) | associativity (ways) | # sets | addr width (32)  |

> Example:
>
> **64 KB, 4-way, 32 B line, 32-bit**:
>
> ```text
> S = 65536 / (4*32) = 512 sets;  b = 5;  s = 9;  t = 32 - 9 - 5 = 18
> → tag 18 | set 9 | offset 5
> ```
>
> **16 KB, 64 B line, varying assoc**:
>
> | Org        | DM   | 2-way | 4-way | 8-way | **FA** |
> | ---------- | ---- | ----- | ----- | ----- | ------ |
> | **# sets** | 256  | 128   | 64    | 32    | **1**  |
>
> **Total cache bits**: `DataBits = C * 8`; `MetaBits ≈ S*E*(1 + t + d)` (`d=1` if dirty); add 2 bits MESI for multicore.

### 2.2 Direct-Mapped Conflict

**Conflict pattern**: access `A, B, A, B, …` where `set(A) == set(B)`, `tag(A) ≠ tag(B)`.

> [!NOTE]
> Distance for conflict in DM = `B * S` = **cache size**.

> **Worked**: 4 KB DM, 32 B line → `S = 128`. Set repeats every $128 \times 32 = 4096$ B.
>
> **Quiz example**: 4 KB, 2-way, 32 B → `S = 64`, set repeats every 2 KB. More than 2 live blocks → conflicts.

### 2.3 Matrix / Array Miss Rate

For elem size `e`, line `B` → one line holds `B/e` contig elements.

| Pattern                                | Miss rate                            |
| -------------------------------------- | ------------------------------------ |
| row-major row scan                     | ≈ `e/B` (1 miss per line)            |
| col scan, large stride                 | often **~100%** (line evicted)       |

> Example: row-major `A[1024][1024]` int (4 B), 64 B line → row scan ≈ 6.25%; col scan ≈ 100%.

**Mixed access** (`int`, 32 B line → 8 elems/line):

```c
sum += A[i][k] + B[k][i];    // A: 1/8 miss, B: ~100% → avg 9/16
sum += A[i][k] + B[i][k];    // both: 1/8 → avg 1/8
```

**Stride-conflict trap**: 4 KB DM, 32 B line, `double A[1024], B[1024]` → `A[i]` and `B[i]` differ by 8 KB = 2× cache size → same set → conflict every iter.

> If working set fits & no conflicts → **only compulsory misses**.

```c
// GOOD (stride-1 row-major)
for (i=0; i<R; i++) for (j=0; j<C; j++) use(A[i][j]);
// BAD (stride = C * sizeof(elem))
for (j=0; j<C; j++) for (i=0; i<R; i++) use(A[i][j]);
```

## 3. 4 Cache-Design Questions

| Question                  | Mechanism                           |
| ------------------------- | ----------------------------------- |
| Where can a block go?     | placement / associativity           |
| How is a block found?     | index + tag compare                 |
| Which block is evicted?   | replacement policy                  |
| What happens on writes?   | write policy                        |

| Org                       | Meaning | Pros / Cons                                          |
| ------------------------- | ------- | ---------------------------------------------------- |
| ==**direct-mapped**==     | E=1     | simplest hit; many conflicts; lowest tag overhead    |
| ==**set-associative**==   | E>1     | balanced                                             |
| ==**fully associative**== | S=1     | least conflicts but costly tag search                |

**True / false anchors** (same C, B):

| Claim                                | Truth |
|--------------------------------------|-------|
| 2-way has more sets than 4-way       | ✅ |
| DM always faster hit than set-assoc  | ❌ as "always" |
| **DM has lowest tag overhead**       | ✅ |
| **DM has simplest replacement**      | ✅ (only one line per set) |
| fully-assoc has more lines           | ❌ (line count = C/B, same) |
| fully-assoc always lowest miss rate  | ❌ (depends on replacement) |

**B↑ trade-offs**:

| **Helps**               | **Hurts**                           |
| ----------------------- | ----------------------------------- |
| spatial locality↑       | miss penalty (transfer time)↑       |
| **compulsory misses** ↓ | bandwidth                           |
| **tag overhead** ↓      | fewer lines → conflict / capacity ↑ |
|                         | pollution if not all of line used   |

> Mitigation for big-line penalty: **early restart (still sequential), critical-word-first**.

## 4. Cache Access: Read / Write × Hit / Miss

==**The full system**== — every access falls into one of 4 quadrants:

|             | **Read**                                          | **Write**                                                    |
| ----------- | ------------------------------------------------- | ------------------------------------------------------------ |
| **Hit**     | return data; no extra work                        | ==**write-through**== OR ==**write-back**==                  |
| **Miss**    | stall, fetch line, fill; restart (I) / complete (D) | ==**write-allocate**== OR ==**no-write-allocate**==          |

### 4.1 Read Miss Handling

| Miss type   | Action                                                       |
| ----------- | ------------------------------------------------------------ |
| **I-cache** | stall front-end, fetch block, fill line, **restart IF** at the missed instr |
| **D-cache** | stall (or **stall-on-use** / non-blocking), fetch block, **complete the load/store** |

> 4 explicit steps (I-cache): send PC → memory read & wait → fill cache (data + tag + valid=1) → restart fetch. HW prefetch commonly augments this.

### 4.2 Write Hit: WT vs WB

| Policy                | Behavior                                       | Pros                     | Cons                       |
| --------------------- | ---------------------------------------------- | ------------------------ | -------------------------- |
| ==**write-through**== | update cache + next level NOW                  | always fresh below       | high mem traffic           |
| ==**write-back**==    | update cache, **dirty bit**; write on evict    | low mem traffic          | cache loss = data loss     |

> ==**Write buffer**==: FIFO (typ. 4 entries) between WT cache and memory; CPU continues unless full. **Write-coalescing / combining** merges adjacent writes. Saturation when store-rate > 1 / DRAM-write-cycle.
>
> ==**Writeback buffer**==: between WB cache and lower level; lets a dirty evict drain asynchronously so the new line can fill first.

### 4.3 Write Miss: WA vs NWA

| Policy                    | Behavior                            | Pairs naturally with | Use case             |
| ------------------------- | ----------------------------------- | -------------------- | -------------------- |
| ==**write-allocate**==    | fetch line, then write              | write-back           | likely reuse (most data) |
| ==**no-write-allocate**== | bypass; write straight to memory    | write-through        | streaming writes     |

> **NWA good for**: `memcpy` / `memset` large `n`, DB logs. ❌ Local var / struct writes (need WA).

### 4.4 Common Pairings

> [!IMPORTANT]
> **WB + WA** = most common for modern L1D. **WT + NWA** common for L1I and write-streaming. L2 typically **WB + WA**.

### 4.5 I-cache Specifics

No CPU stores → no write policy / dirty bit; still **valid + tag + data**.

==**JIT / self-modifying code**== requires:

1. **Flush I-cache** ✅
2. **Invalidate** affected I-lines ✅
3. **Maintain I/D coherence** ✅
4. flush D-cache alone ❌

## 5. Cache Performance

**Stall cycles**:

$$
\text{Mem Stall} = IC \times \frac{\text{MemAcc}}{\text{Instr}} \times MR \times MP; \quad CPI = CPI_{base} + \frac{\text{Stalls}}{\text{Instr}}
$$

**Split I/D**: 
$$
\text{stalls/instr} = I_{MR} \cdot I_{MP} + \text{data\_acc/instr} \cdot D_{MR} \cdot D_{MP}
$$

> Example:
>
> **Worked CPI**:
>
> | Scenario                                    | Calc                                       | CPI                           |
> | ------------------------------------------- | ------------------------------------------ | ----------------------------- |
> | 5% D-MR, 40% load/store, MP=100, base=1     | $1 + 0.4 \times 0.05 \times 100$           | **3.0**                       |
> | I-MR=2%, D-MR=4%, D-acc=36%, base=2, MP=100 | $2 + 0.02\cdot100 + 0.36\cdot0.04\cdot100$ | **5.44** (2.72× over perfect) |

**AMAT**:
$$
AMAT = HT_1 + MR_1\,(HT_2 + MR_2\,(HT_3 + MR_3 \cdot MP_{mem}))
$$

> ==`MR_2, MR_3` are **local** miss rates== (fraction at that level). Split I/D:
> $$
> AMAT_{overall} = \%\text{instr} \cdot AMAT_I + \%\text{data} \cdot AMAT_D
> $$

**L1D hit latency**: **3-4 cy**. Stages: VA → PA → tag → align / ECC → fwd / RF.

> AMAT inaccurate under OoO + non-blocking caches (multiple misses overlap).

**Miss-penalty reducers**: critical-word-first / early restart (for a cache line); non-blocking cache (hit-under-miss, miss-under-miss); HW / SW prefetch; writethrough/ writeback buffer.

**Low hit-latency approaches**:

| Technique                       | How it helps                                            |
| ------------------------------- | ------------------------------------------------------- |
| **small + simple** cache        | small is fast                                           |
| **DM or low associativity**     | fewer tag comparisons; simpler hit path                 |
| **way prediction**              | predict which way to compare first → only 1 if right    |
| **VIPT** (virt-idx, phys-tag)   | overlap address translation with cache access           |
| **physical layout near CPU**    | minimize signal delay                                   |

## 6. 4 C's of Misses

| Miss            | Cause                       | Fix                                                           |
| --------------- | --------------------------- | ------------------------------------------------------------- |
| **Compulsory**  | first access                | larger block, prefetch (NOT bigger cache)                     |
| **Conflict**    | mapping collision           | assoc, victim cache, padding, code reposition                 |
| **Capacity**    | working set > cache         | bigger cache, blocking / tiling, reduce footprint             |
| **Coherence**   | invalidation by other core  | reduce sharing, padding, partitioning                         |

> **Coherence = hardest to remove** (program rewrite needed).
> **Larger cache reduces**: capacity + conflict ✅; compulsory ❌, coherence ❌.
> **Reduce conflict in DM L1D**: larger cache, victim cache, set-assoc↑, redesign algorithm. Bigger line ❌ (may increase conflict).
> **Reduce capacity**: larger cache, prefetching. Victim cache / assoc ❌ for capacity.

**Conflict scenarios** (4 KB DM, 64 B line):

| Scenario | Cause |
|---|---|
| `proc A`, `proc B` addrs differ by mult of 4 KB | I-cache code-layout conflict |
| `float A[1024][1024]; b[i] = A[i][j] + A[i+1][j]` | row stride 4 KB → same set |
| `double A[1024], B[1024], C[1024]` back-to-back | strides align |

> **Padding fix**: `A[1024][1040]`✅ `A; pad[8]; B`. ❌ Pads may be removed unless **actually used**.

## 7. Replacement Policies

| Policy                         | Note                                                              |
| ------------------------------ | ----------------------------------------------------------------- |
| ==**LRU**==                    | exact stack; expensive at high assoc                              |
| **Pseudo-LRU**                 | typical in real caches; tree-based approx                         |
| Random                         | cheap; surprisingly good                                          |
| FIFO                           | simple                                                            |
| ==**Belady optimal**==         | evict farthest future use; **upper bound** (not implementable)    |

> **True LRU data structure** = ==**stack**==.
>
> **Counter impl** (e.g., 4-way uses 2-bit counter per line): reset counter to 0 (youngest) on access; increment all others in set; evict the one reaching `assoc-1`.

**LRU vs FIFO trap**: set `A,B,C`; access `A`; miss `D` → LRU evicts **B**, FIFO evicts **A**.

> Belady minimizes **misses**, NOT traffic (clean evict ≠ dirty writeback).

### 7.1 Victim Cache

==**Victim cache**==: small **fully-assoc** buffer (4-8 lines) of recently-evicted lines; combined with DM L1D to reduce conflicts.

| Situation         | **Victim cache**                                        | **2-way**                                       |
| ----------------- | ------------------------------------------------------- | ----------------------------------------------- |
| **Good for**      | **clustered** conflict on few sets                      | **evenly distributed** conflict                 |
| **Tag overhead**  | tiny (4-8 lines)                                        | doubles L1 tags                                 |
| **Hit latency**   | DM-fast L1 + small extra check                          | slightly slower L1 (mux)                        |

> General-purpose CPUs use 2-way+ set-assoc. Victim caches in older / embedded designs.

### 7.2 Associativity Trade-off

| Assoc          | 1-way (DM) | 2-way | 4-way  | 8-way  |
| -------------- | ---------- | ----- | ------ | ------ |
| **Typical MR** | 3–10%      | 2–7%  | 1.5–5% | 1–4.5% |

> "Sweet spot": modern L1D = 4-way or 8-way.

> **DM > 4A-LRU pathological**: 5-line loop on 4-line FA-LRU → 0% hit (always evicting next-needed). Same 5 lines on DM → 60% hit.

## 8. Multi-Level Caches

| Level         | Config                                                    | Goal                     |
| ------------- | --------------------------------------------------------- | ------------------------ |
| **L1I / L1D** | 16–64 KB, private, **split I/D**                          | **fast hit time**        |
| **L2**        | 256 KB–1 MB, often private / unified (1 per core), slower | balance speed + capacity |
| **L3 (LLC)**  | multi-MB, **shared by all cores**                         | **reduce DRAM traffic**  |

**Hit-rate cascade**:

| Cache    | L1     | L2 (of L1 miss)  | L3 (of L2 miss)  |
| -------- | ------ | ---------------- | ---------------- |
| **Rate** | 80–95% | 50–80%           | 20–40%           |

> **Worked** (4 GHz, base=1, miss/instr=2%, mem=100 ns):
>
> - No L2: mem penalty = 400 cy → $CPI = 1 + 0.02 \times 400 = 9$.
> - With L2 (5 ns hit, 20% L2-miss): $CPI = 1 + 0.02 \times (20 + 0.2 \times 400) = 3$ → **3× speedup**.

**Split L1I / L1D**: higher bandwidth + different policies (I no writes; D has write policy). NOT for hit rate, NOT reliability.

**L1 vs L2**:

| L1                                 | L2                                  |
| ---------------------------------- | ----------------------------------- |
| spatial locality critical          | temporal locality critical          |
| write-through (sometimes)          | write-back common                   |
| fast hit time                      | low miss rate                       |

**Inclusion policies**:

| Policy             | Meaning                                    |
| ------------------ | ------------------------------------------ |
| ==**Inclusive**==  | every L1 line also in L2                   |
| ==**Exclusive**==  | line in exactly **one** of L1, L2          |
| ==**NINE**==       | non-inclusive, non-exclusive               |

> **Inclusive ops**: L2 evict → back-invalidate L1; simpler coherence (check at L2).
> **Exclusive ops**: L1 evict → moves to L2; L1 miss + L2 hit → migrates; effectively bigger total cache.

**Nonsensical orgs**:

| Org                               | Why bad                                            |
| --------------------------------- | -------------------------------------------------- |
| L1I write-back + L1D WT           | I-cache has no CPU stores → write-back meaningless |
| L1/L2 exclusive + L2/L3 inclusive | conflicting inclusion semantics                    |
| L1D 4-way + L2 DM                 | lower level worse placement than upper             |
| L1/L2 inclusive + L2/L3 exclusive | OK (popular at AMD)                                |

## 9. Cache Coherence

==**Snoopy**==: private caches watch a shared bus; each controller snoops + reacts.

> Quiz: snoopy = (1) coherence in **bus-connected multi-proc**, (2) significant snoop traffic.

==**MESI**==:

| State                  | Meaning                                |
| ---------------------- | -------------------------------------- |
| **M** (Modified)       | dirty, only copy in this cache         |
| **E** (Exclusive)      | clean, only copy                       |
| **S** (Shared)         | clean, may be in other caches          |
| **I** (Invalid)        | not present / stale                    |

==**False sharing**==: different vars in same line → cross-core invalidations. Fix: padding or alignment.

> **Coherence solutions**: shared cache (no privates) OR snoopy on private caches.

## 10. MSHR & Non-Blocking Cache

**MSHR**: tracks outstanding misses; allows multiple in-flight → **MLP**.

| Mode                | Blocking            | **Non-blocking (lockup-free)**     |
| ------------------- | ------------------- | ---------------------------------- |
| **on miss**         | stall pipeline      | continue with independent ops      |
| **stall when**      | "stall-on-miss"     | "stall-on-use" (only when needed)  |
| **supports MLP**    | ❌                  | ✅                                 |

> Models: hit-under-miss, miss-under-miss. MSHR also does **miss merging / coalescing** (multiple loads to same line → one fill).

**L3 MSHR count** depends on **mem latency + bus width**.  NOT L2 size, NOT cores sharing L3 ❌.

> Bandwidth-heavy features (large lines, prefetch, non-blocking, write-through) all need MSHRs.

## 11. Locality Application Patterns

**Pointer chasing** (`while (p) p = p->next`): poor spatial + load-use chain → **latency-bound**.

| Bad                          | Good                                |
| ---------------------------- | ----------------------------------- |
| linked list                  | arrays / vectors                    |
| binary tree                  | B / B+ trees                        |
| chained hash                 | open addressing                     |
| traverse 1 at a time         | batch independent traversals        |
| many small allocs            | pool / arena allocator              |

**Sorting locality**:

| Algorithm         | Locality                             |
| ----------------- | ------------------------------------ |
| **Quicksort**     | high (recursive on adjacent halves)  |
| **Insertion**     | high (sequential)                    |
| **Bubble**        | high (sequential pairs)              |
| **Heapsort**      | **poor** (random heap accesses)      |
| **Radix**         | poor (out-of-place buckets)          |

> Quicksort wins despite $O(N \log N) > O(N)$ — locality matters for moderate N.

**HW vs SW cache**:

| HW cache                     | SW cache (e.g., OS file cache)       |
| ---------------------------- | ------------------------------------ |
| transparent                  | managed by OS/app                    |
| associative tag compare      | hash / tree lookup                   |
| simple / fast replacement    | can use complex policies             |
| fixed structure              | flexible                             |

## 12. Practical Examples & Applications

**Intrinsity FastMATH** (12-stage MIPS embedded): split I + D each 16 KB = 256 lines × 64 B; 

D WT or WB; SPEC2000 I-MR 0.4%, D-MR 11.4%, weighted 3.2%. 

I-MR higher for DBMS / VM / interpreter / JIT / OO.

**Cache is everywhere**:

| Application                  | What's cached                                                                    |
| ---------------------------- | -------------------------------------------------------------------------------- |
| **Akamai CDN**               | web content cached at edge distribution stations (fixes 90s ISP traffic jams)    |
| **GPU register-file cache**  | huge regfile (e.g., NV 4090 = 144 SM × 64K regs) → cache hides reg access latency |
| **OS file cache**            | recently-read disk blocks in RAM                                                 |
| **TLB**                      | recent VA→PA translations                                                        |
