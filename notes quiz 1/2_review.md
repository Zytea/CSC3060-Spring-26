# Lec 2: Data Representation

## Exam Facts

- **Byte-addressed memory**: pointer = virtual address of first byte; pointer **type** decides interpretation/stride.
- ==**Word size**==: nominal pointer/GPR size; `w`-bit machine has addresses `0..2^w-1`.
- **32b address space**: $2^{32}$ bytes = **4 GiB**. **64b**: $2^{64}$ B = 16 EiB.
- **LP64 sizes** (64b Linux/RV64): `char 1`, `short 2`, `int 4`, `long 8`, ptr 8, `float 4`, `double 8`. ILP32 (RV32): `long 4`, ptr 4.
- ==**LP64 won over ILP64**==: keeps `int=4B` for **data portability** with old binary files (storage doubles otherwise).
- **`INT_MAX = 2^31-1 = 0x7FFFFFFF`**, **`INT_MIN = -2^31 = 0x80000000`**.
- **Avoid wrap when may exceed `2^32`**: use `long`/`long long`; or `double`; or explicit overflow check.
- ==**ABI**==: **ISA + OS + calling convention**. Determines binary compatibility.
- **Endianness matters when**: byte-level accessed (cast `int*`→`char*`), binary file moved between machines, network protocol, debugger byte dump, bit-fields. **Doesn't matter** when storing & reading same type same machine.
- **Little endian**: LSB at lowest address. RV/x86/ARM (most) are LE.
- **Unsigned conversion trap**: any `unsigned` operand in C makes the other `unsigned` too.
- ==**Two's complement**==: `TMin=-2^{w-1}`, `TMax=2^{w-1}-1`, `UMax=2^w-1`; **`-TMin == TMin`** (overflow on negate).
- **Why 2's complement wins**: one zero, simple add HW, no end-around carry.
- **RISC-V integer overflow**: does **NOT trap**; SW must check. Reasons: rare event, traps expensive, hurts OoO/precise exceptions, unsigned wrap useful (hashing/crypto).
- **FP overflow**: HW sets a flag; SW must poll if it cares.
- **Right shift**: signed → arithmetic (replicates sign); unsigned → logical (zero-fill).
- **Signed `>>k` rounds toward `−∞`**: e.g. `(-3)>>1 = -2`, while C `-3/2 == -1`. To round toward 0: `x<0 ? (x+(1<<k)-1)>>k : x>>k`.
- **Bitwise vs logical**: `2 & 1 = 0`, `2 && 1 = 1`. `&&`/`||` short-circuit (`a && n/a` safe when `a==0`).
- **IEEE 754-1985**: fp32 + fp64. **IEEE 754-2008**: adds fp16 + quad. **bfloat16/FP8/FP4 are AI formats, not core IEEE**.
- **fp32**: `s|exp8|frac23`, bias `127`. **fp64**: `s|exp11|frac52`, bias `1023`. **fp16**: `s|exp5|frac10`, bias `15`.
- **bfloat16**: `s|exp8|frac7` (fp32 exp range, less precision; ML-friendly).
- **fp32 exact int range**: 0 to $2^{24}=16{,}777{,}216$; above that, gaps grow ≥1.
- **Exact binary decimal**: reduce → denominator must be $2^k$. **`0.5, 0.0625, 1.625` ✓**; **`0.1, 0.2, 0.3, 1.405, 1.35, 1.245, 1.11` ✗**.
- **Strict FP**: `+,-,*` are **NOT associative**; commutativity OK for finite normals.
- **Round-to-nearest-even** (default IEEE): `12.5→12`, `13.5→14`. 4 modes total: even/0/+∞/−∞.
- ==**FMA**==: `a*b+c` with **one final rounding**, ~5–6 cycles. More precise + faster than `FMUL;FADD` (which rounds twice).
- **`+0.0` and `-0.0` exist** in IEEE FP (and 1's complement / sign-mag), **not** in 2's complement.
- **`1/+0=+∞`, `1/-0=-∞`, `sqrt(-1)=NaN`**.
- **Saturation arithmetic**: clip overflow at bounds (`120+20→127` for int8); used in audio/video/quantized AI, **not** standard FP.
- **Latencies**: int mul 3–5, int div ~32, FP add 4, FP mul 5, FMA 5–6, FP→int 3–5.

## 1. Information Storage

### 1.1 Bits, Bytes, Addresses

| Term | Meaning |
|---|---|
| bit | 0/1 |
| byte | 8 bits, smallest **addressable** unit |
| word | nominal CPU/pointer size (32b or 64b) |
| address | byte index in virtual/physical memory |
| pointer | address + type-directed interpretation |
| VA / PA | process-visible / DRAM physical address (after MMU translation) |

Useful powers: $2^{10}=1\,\text{KiB}$, $2^{20}=1\,\text{MiB}$, $2^{30}=1\,\text{GiB}$, $2^{32}=4\,\text{GiB}$, $2^{40}=1\,\text{TiB}$.

> Quiz: int can exceed $2^{32}-1$ but $<2^{64}$ → use `long`/`long long`/`uint64_t`; or `double`; or explicit overflow check.

### 1.2 Decimal / Binary / Hex

1 hex digit = 4 bits.

| Binary | Hex | Decimal |
|---|---|---:|
| `1111` | `0xf` | 15 |
| `1000 0000` | `0x80` | 128 unsigned / `-128` int8 |
| `1111 1111` | `0xff` | 255 unsigned / `-1` int8 |

> $4141_{10}$ in 16b → `0b 0001 0000 0010 1101 = 0x102D`.

### 1.3 C Data Sizes

| C type | RV32/ILP32 | RV64/LP64 |
|---|---:|---:|
| `char` | 1 | 1 |
| `short` | 2 | 2 |
| `int` | 4 | 4 |
| `long` | 4 | **8** |
| `long long` | 8 | 8 |
| pointer | 4 | **8** |
| `float` | 4 | 4 |
| `double` | 8 | 8 |
| `int32_t` / `uint32_t` | 4 | 4 |
| `int64_t` / `uint64_t` | 8 | 8 |

==**Why LP64 won over ILP64**==: storage compatibility — many old binary data files used 4B `int`s; **doubling `int` to 8B** doubles storage and breaks portability. Pointers/longs grow to 8B; `int` stays 4B.

## 2. Byte Ordering and Pointer Casts

### 2.1 Big vs Little Endian

For `int x = 0x12345678` at address `p`:

| Endian | `p` | `p+1` | `p+2` | `p+3` |
|---|---|---|---|---|
| **big** | `12` | `34` | `56` | `78` |
| **little** | `78` | `56` | `34` | `12` |

==**Endianness matters when**==:

- read multi-byte object byte-by-byte (cast `int*`→`char*`).
- binary file/network data crosses machines.
- bit-fields, debugger byte dump, mixed-size pointer aliasing.

> Quiz: store as `long` and read as `long` on the **same machine** → same answer regardless of endian. Store as `char[]`, read as `int` → endian-dependent.

Today: x86, RV, most ARM = **little endian**. (Mainframes/CRAY/SPARC/old MIPS were big.)

### 2.2 `show_bytes` Output

```c
typedef unsigned char *byte_pointer;
show_bytes((byte_pointer)&x, sizeof x);
```

For `int x=12345=0x00003039`:

| Machine | Bytes |
|---|---|
| Linux32 / Win / Linux64 (LE) | `39 30 00 00` |
| Sun (BE) | `00 00 30 39` |

`"12345"` C-string bytes are **always** `31 32 33 34 35 00` (ASCII; endian-independent).

For `float 12345.0`:

| LE | `00 e4 40 46` |
| BE | `46 40 e4 00` |

> [!IMPORTANT]
> `*((char*)p + k)` reads byte `k`. `((T*)p)[k]` advances by `k*sizeof(T)`.

==**C string**==: byte array terminated by `\0`. Common encoding: ASCII (`'0'=0x30`, `'A'=0x41`, `'a'=0x61`, … `'9'-'0'=0x09`). Text strings are platform-independent; binary code depends on **ABI = ISA + OS + calling convention**.

## 3. Boolean / Bitwise / Logical / Shift

### 3.1 Bitwise vs Logical

| C op | Meaning |
|---|---|
| `& \| ^ ~` | bitwise on every bit |
| `&& \|\| !` | logical, treat nonzero=true; **short-circuit** |

```c
2 && 1 == 1
2 &  1 == 0
```

**Short-circuit examples**: `a && n/a` (no DIV0 when `a==0`), `p && p->next` (no NULL deref).

> [!IMPORTANT]
> Common bug: `if (A && B)` typed as `if (A & B)`. With `A=2` (`10`), `B=1` (`01`): `&&` is true, `&` is `0` false.

### 3.2 Shifts

| Op | Behavior |
|---|---|
| `x << k` | low bits 0; discard high bits |
| **unsigned** `x >> k` | logical: high bits 0 |
| **signed** `x >> k` | arithmetic: replicate sign bit |

Arithmetic right shift rounds toward $-\infty$, **not** toward 0:

```c
(-3)>>1 == -2     // class model
-3/2    == -1     // C division (toward 0)
```

For signed division by $2^k$ rounding toward 0:

```c
x / (1<<k) == ((x < 0 ? x + (1<<k)-1 : x) >> k)
```

`x<0 ⇔ (x>>31) & 1` for 32b int.

## 4. Integer Representation

### 4.1 Unsigned and Two's Complement

$$
B2U_w(x)=\sum_{i=0}^{w-1}x_i 2^i; \quad
B2T_w(x)=-x_{w-1} 2^{w-1}+\sum_{i=0}^{w-2}x_i 2^i
$$

| 8b bits | unsigned | signed |
|---|---:|---:|
| `00000000` | 0 | 0 |
| `01111111` | 127 | 127 (`TMax`) |
| `10000000` | 128 | -128 (`TMin`) |
| `11111111` | 255 | -1 |

==**Encodings with both `+0` and `-0`**==:

| Encoding | +0 ≠ -0? |
|---|---|
| sign-magnitude | yes |
| 1's complement | yes |
| **2's complement** | **NO** (single zero) |
| IEEE FP | yes |

==**Why 2's complement won**==: single zero, simple uniform add HW, no end-around carry.

### 4.2 Signed ↔ Unsigned

Bit pattern unchanged; interpretation changes.

$$
U = S \bmod 2^w =
\begin{cases}
S, & S\ge 0 \\
S+2^w, & S<0
\end{cases}
$$

> [!IMPORTANT]
> C comparison trap: `-1 < 0U` is **false** because mixed sign forces unsigned: `-1` becomes `UMax`.

```c
signed char c = -1;
unsigned int u = c;     // c → int -1 (sign-extend) → unsigned 0xffffffff
```

==**`char` sign-extension trap**==:

```c
char c = 0xff;          // signed char: c = -1 on most compilers
unsigned int s = c;     // c promoted to int first → sign-extends to 0xFFFFFFFF
                        // → then converted to unsigned = 0xFFFFFFFF
if (s > 0x100)          // 0xFFFFFFFF > 0x100 → TRUE
```

> Fix: use `unsigned char c = 0xff;` → no sign extension → `s = 0x000000FF`.

### 4.3 Extension and Truncation

| Op | Rule |
|---|---|
| zero-extend | prepend `0`s |
| sign-extend | replicate sign bit |
| truncate to k bits | keep low k bits → `mod 2^k`, then reinterpret |

## 5. Integer Arithmetic

### 5.1 Add/Sub & Overflow

Fixed-width arithmetic = modulo $2^w$. **Real C**: signed overflow is **UB**; unsigned wraps mod $2^w$.

> [!IMPORTANT]
> Do **NOT** detect signed overflow by `if (a+b < 0)` — already UB. Pre-check, use unsigned, or widen first.

==**Unsigned overflow tests**==:

| Op | Test |
|---|---|
| `s = x+y` | `s < x` (or `s < y`) |
| `d = x-y` | `d > x` |

==**Signed add overflow**==:

```text
both operands same sign && result different sign
overflow = !(sa ⊕ sb) && (sa ⊕ ss)
```

Sub: `a-b = a + (~b+1)`.

Negation: `-x = ~x + 1`. `-TMin = TMin` (only int with this property).

### 5.2 RISC-V Overflow Policy

- ALU ops **wrap silently**; no condition-code register.
- SW must check if overflow matters.
- **Why no HW trap**: rare, traps expensive, breaks OoO/precise exceptions, unsigned wrap useful (hashing, crypto).
- FP HW may set flags; SW polls.

> Alt approaches: Python (dynamic int size), Rust (checked arith), Fortran/Ada (HW exception), MMX/SSE (saturation).

### 5.3 Adders / SLT

One-bit full adder:

```text
sum  = a ⊕ b ⊕ cin
cout = a·b + a·cin + b·cin
```

==**Carry-Lookahead Adder (CLA)**==: parallelize carry to `O(log n)`.

$$
g_i=A_i B_i \text{ (generate)};\quad p_i=A_i\oplus B_i \text{ (propagate)};\quad C_{i+1}=g_i+p_i C_i
$$

==**SLT from subtraction**==:

```text
signed:   set = sign(A-B) ⊕ overflow      // overflow correction needed
unsigned: set = ~cout(A-B)                 // borrow detection
```

ALU 4 ops: `AND`, `OR`, `ADD`, `SLT/LESS`. `Bnegate=1, CarryIn0=1` → subtraction.

### 5.4 Multiply / Divide

| Op | Cost |
|---|---:|
| add/logic | 1 cycle |
| shift | 1 |
| int multiply | 3–5 cycles |
| **int divide** | **~32 cycles**, hard to pipeline |

**Faster mul**: tree of adders → delay `O(log n)` instead of `O(n)`. **Divider**: iterative, control-heavy, hardest to pipeline.

==**Quick divide by power-of-2**==:

```c
unsigned: x / N == x >> log2(N)
signed:   x / N == ((x<0) ? x + N-1 : x) >> log2(N)
ceil:     ceil(x/N) == (x + N - 1) >> log2(N)
```

==**Project add/sub (no `+/-` allowed)**==:

```c
sum_no_carry = a ^ b
carry        = (a & b) << 1   // values to add in next iter
sub(a,b)     = add(a, add(~b, 1))
```

> Quiz: `(a & b) << 1` represents the **carry bits to add in next iteration**.

### 5.5 Integer Expression Quiz Traps

Assume 32b 2's-complement wrap (real C signed overflow is UB).

| Expr | ∀? | Counter / Reason |
|---|---|---|
| `(x>0) \|\| ((x-1)<0)` | no | `x=TMin`, `x-1` wraps to `TMax` |
| `(x & 7) != 7 \|\| (x<<29 < 0)` | yes | low 3 bits all-1 → bit2=1 → after `<<29` becomes sign |
| `(x*x) >= 0` | no | `x=0xFFFF`: `x*x = 0xFFFE0001 < 0` |
| `x < 0 \|\| -x <= 0` | yes | nonneg negates to ≤0; `TMin` covered by first |
| `x > 0 \|\| -x >= 0` | no | `x=TMin`, `-x=TMin` (both <0) |
| `x+y == uy+ux` | yes (bitwise) | same modulo bit pattern |
| `x*~y + uy*ux == -x` | yes (bitwise) | `~y=-y-1` ⇒ `x(-y-1)+xy = -x` |
| `(x<y) == (-x>-y)` | no | `x=TMin,y=0`: `-x=TMin`, both negate UB-ish |
| `((x+y)<<4)+y-x == 15*x+17*y` | yes (bitwise) | mod-arith distributes over `+,*,<<` |
| `((x+y)<<4)+y-x == 17*y+15*x` | yes (bitwise) | same |
| `~x+~y+1 == ~(x+y)` | yes | `(-x-1)+(-y-1)+1 = -(x+y)-1 = ~(x+y)` |
| `((x>>1)<<1) <= x` | yes (class) | arith `>>` rounds down then clear low bit |
| `(double)x+(double)y == (double)(x+y)` | no | `x+y` may overflow before cast |
| `x<0 ⇒ x*3<0` | no | `x=TMin` overflow on `*3` |
| `(x-y)>0 ⇒ -x < -y` | no | `x=-1,y=TMin`: `x-y` overflows |
| `((y-x)<<3)+x-2*y == 6*y-7*x` | yes (bitwise) | distribute mod |
| `ux-x == 0` | yes (bitwise) | `ux + ~x + 1 == 0` |
| `ux-uy == -(y-x)` | yes (bitwise) | wraps to same bits |
| `x>0 ⇒ !(x>>31 \| !x)` | yes | sign-bit 0 AND nonzero |
| `((ux>>1)<<1) == ux` | no | any odd `ux` loses low bit |
| `(x>=0) \|\| (x<ux)` | no | `x=-1`: mixed forces `ux<ux` false |
| `dx/3.0 == x/3` | no | int div truncates (C toward 0) |
| `x-(int)dx == 0` | yes | 32b int exactly fits in 53-bit double |
| `(int)(double)x == x` (int x) | yes | double exact for 32b int |
| `(double)(float)x == (double)x` (32b int x) | no | float has 24-bit precision |
| `dx+dy+dz == dz+dy+dx` (int-derived) | yes | each fits exactly in double |
| `dx*dy*dz == dz*dy*dx` | no | large products round differently |
| `dx + dy == (double)(x+y)` | no | `x=y=TMin`: `x+y` overflows in int |

## 6. Floating-Point Representation

### 6.1 Binary Fractions and Exactness

A decimal is exactly representable iff after reduction **denominator is $2^k$**.

| Decimal | Exact? | Reason |
|---|---|---|
| `0.5` | ✓ | 1/2 |
| `0.0625` | ✓ | 1/16 |
| `1.625` | ✓ | 13/8 |
| `0.1`, `0.2`, `0.3` | ✗ | denom has factor 5 |
| `1.405`, `1.35`, `1.245`, `1.11` | ✗ | denom has factor 5 |

> Useful: `0.11111₂ = 31/32`, `1.000001₂ = 1+1/64`.

### 6.2 IEEE Layout & Value

| Format | Layout | Bias | Use |
|---|---|---:|---|
| **fp32** | `s\|exp8\|frac23` | 127 | scientific |
| **fp64** | `s\|exp11\|frac52` | 1023 | default `double` |
| **fp16** | `s\|exp5\|frac10` | 15 | ML, IEEE 754-2008 |
| **bfloat16** | `s\|exp8\|frac7` | 127 | ML; same range as fp32, less precision |
| **fp8** (`s\|exp4\|frac3`) | — | 7 | AI throughput (Hopper H100, 2022) |
| **fp4** (`s\|exp2\|frac1`) | — | 1 | AI (Blackwell B100/B200, 2025) |
| quad-precision | `s\|exp15\|frac112` | 16383 | IEEE 754-1985 |

> Quiz: IEEE 754-2008 added **fp16 + quad**; bfloat16/FP8/FP4 are **AI custom**, not IEEE core.

==**Normalized**==:

$$V=(-1)^s \cdot (1.f)_2 \cdot 2^{e-Bias}$$

==**Subnormal / Denormalized**== (numbers **too small to fit normal format**; `exp==0`, **no hidden 1**, effective exponent `1-Bias`):

$$V=(-1)^s \cdot (0.f)_2 \cdot 2^{1-Bias}$$

> [!NOTE]
> Subnormal exp is `1-Bias`, **not** `0-Bias`, so values are **continuous at the normal/subnormal boundary**. Also: denorm extends representable range toward 0 (gradual underflow).

==**Quiz definition**== (CSC3050 Q4): "Denormalized numbers" = (1) FP numbers **too small to fit standard normalized format**; (4) **exponent = 0, hidden 1 excluded**. NOT "too large", NOT "not yet normalized".

`float` exactly represents all integers from `0` through $2^{24}=16{,}777{,}216$. Above: `2^26=67M`, gap `ULP=2^{e-23}`; e.g., `123456789` rounds to `123456792`.

### 6.3 FP Classes (single-precision)

| Exp | Frac | Class |
|---|---|---|
| all 0 | 0 | `±0` |
| all 0 | nonzero | subnormal |
| `1..max-1` | any | normalized |
| all 1 | 0 | `±∞` |
| all 1 | nonzero | NaN |

==**fp32 hex anchors**==:

| Hex | Value |
|---|---|
| `0x00000000` | `+0.0` |
| `0x80000000` | `-0.0` |
| `0x3f800000` | `+1.0` |
| `0x40800000` | `+4.0` |
| `0xc0800000` | `-4.0` |
| `0x7f800000` | `+∞` |
| `0xff800000` | `-∞` |
| `0x7fc00000` | quiet NaN |
| `0xffffffff` | NaN (exp all 1, frac nonzero) |

> Quiz: `F1=0x40800000=4.0`, `F2=0x3f800000=1.0`, `F3=0xc0800000=-4.0`. Then `F3+F1=0` ✓, `F3<F2<F1` ✓, `F3=-(F1*F2)=-4` ✓; only `F2=F1/F3=-1` is wrong.

### 6.4 Custom Minifloat Worked Template

For `s|k exp|n frac`, **bias** $B=2^{k-1}-1$ (default, e.g. fp32: k=8 → B=127; minifloat k=4 → B=7).

==**Key formulas**==:

| Quantity | Formula | k=4,n=3 example |
|---|---|---|
| **bias** $B$ | $2^{k-1}-1$ | $7$ |
| smallest +subnormal | $2^{-n} \cdot 2^{1-B}$ | $2^{-3}\cdot 2^{-6}=1/512$ |
| largest subnormal | $(1-2^{-n}) \cdot 2^{1-B}$ | $7/8 \cdot 1/64=7/512$ |
| smallest +normal | $1.0 \cdot 2^{1-B}$ | $1/64$ |
| largest normal | $(2-2^{-n}) \cdot 2^{(2^k-2)-B}$ | $15/8 \cdot 128 = 240$ |
| largest finite | same as largest normal | $240$ |

==**Worked: `s\|eeee\|fff`, k=4, n=3, B=7**==:

| Bits | Class | E | M | V |
|---|---|---:|---:|---|
| `0 0000 000` | +0 | — | 0 | 0.0 |
| `0 0000 001` | smallest +denorm | -6 | 1/8 | 1/512 |
| `0 0000 111` | largest denorm | -6 | 7/8 | 7/512 |
| `0 0001 000` | smallest +normal | -6 | 1 | 1/64 |
| `0 0111 000` | normal `1.0` | 0 | 1 | 1.0 |
| `0 1110 111` | largest normal | 7 | 15/8 | 240 |
| `0 1111 000` | +∞ | — | — | +∞ |
| `0 1111 yyy` (y≠0) | NaN | — | — | NaN |

> Same template applies to other `(k, n)` minifloat sizes — substitute `B = 2^{k-1}-1` and recompute.

==**FP halve / double bit-level**== (Quiz CMU f04):

| Case | **Halve** (÷2) | **Double** (×2) |
|---|---|---|
| `exp == max` (all 1) | unchanged (NaN / ±∞) | unchanged |
| normalized, `exp > 1` | **decrement exp** | **increment exp**; if exp becomes max-1 → exp = max, frac = 0 (→ ±∞) |
| normalized, `exp == 1` | becomes subnormal: shift `1.frac` right by 1 | increment exp (normal) |
| subnormal (`exp == 0`) | shift `frac` right (apply rounding mode) | shift `frac` left; if hidden 1 appears in frac, becomes normal: `frac = frac & (2^n - 1); exp = 1` |
| ±0 | unchanged | unchanged |


## 7. FP Rounding, Ops, Casts

### 7.1 Rounding

Default = ==**round-to-nearest-even**== (ties to even):

| Value | Rounded int |
|---|---:|
| `12.5` | 12 (even) |
| `13.5` | 14 (even) |
| `2.5` | 2 |
| `3.5` | 4 |

4 IEEE modes: nearest-even, toward 0, toward $+\infty$, toward $-\infty$.

### 7.2 FP Operation Traps

==**Assume FP `x, y, z` (float) and `d, e` (double); all finite normal (no NaN/inf)**==:

| Claim | ∀? | Counter / Reason |
|---|---|---|
| `(X+Y)+Z == X+(Y+Z)` | no | `x=1, y=2^127, z=-2^127`: assoc broken near top |
| `X+Y == Y+X` | yes | commutative for finite normal |
| `X*Y == Y*X` | yes | commutative |
| `(X+Y)*Z == X*Z + Y*Z` | no | `x=2^127, y=-2^127, z=2^127`: distributivity breaks |
| `if X > 0 then X/2 > 0` | **no** | `x = 2^-149` (smallest subnormal) → `x/2` underflows to 0 |
| `if X >= Y and Z <= 0 then X*Z <= Y*Z` | yes | non-positive flip preserves order for finite normal |
| `if X > Y then (double)X > (double)Y` | yes | float→double is exact |
| `if D > E then (float)D > (float)E` | **no** | `d=2^129, e=2^128`: both overflow to `+∞` (float max ≈ 2^128) → `+∞ > +∞` false |
| `X + 1 > X` | **no** | `x = 2^127`: `x+1` rounds to `x` |
| `1/+0` | — | `+∞` |
| `1/-0` | — | `-∞` |
| `sqrt(-1)` | — | NaN |
| `0.0 == -0.0` | — | **true** (signed zeros compare equal) |
| `NaN == NaN` | — | **false** (NaN never equals anything, even itself) |
| `NaN != NaN` | — | **true** |

> Demo: `(3.14 + 1e10) - 1e10 = 0.0` (3.14 lost to rounding); `3.14 + (1e10 - 1e10) = 3.14`.

==**Compiler implications**==: cannot freely reassociate FP `+,-,*` unless `-Ofast` / `-ffast-math` / `-ffp-contract=fast`. So `(B+C)` is NOT a CSE in `(A+B+C)` vs `(A+(B+C))`.

### 7.3 Casts

| Cast | Rule |
|---|---|
| `int → float` | may round (24-bit precision) |
| `int (32b) → double` | **exact** (53-bit precision) |
| `float → double` | exact |
| `double → float` | may round / overflow / underflow to `±∞` |
| `float/double → int` | **rounds toward 0**; overflow undefined |

Intel pattern on overflow `float→int`: result = `0x80000000` (=`TMin`, "integer indefinite"). E.g., `(int)+1e10 = -2147483648`. Formula: `result = (int)(value mod 2^32)`.

==**High-yield cast traps (`A` int, `dx=(double)x`)**==:

| Expr | ∀? | Reason |
|---|---|---|
| `A == (int)(double)A` | yes | double has 53-bit precision |
| `(double)(float)x == (double)x` (32b int) | no | float only 24-bit |
| `dx+dy+dz == dz+dy+dx` (ints fit) | yes | all exact in double |
| `dx*dy*dz == dz*dy*dx` | no | products can overflow/round |
| `dx + dy == (double)(x+y)` | no | `x+y` overflows int |
| `x - (int)dx == 0` | yes | 32b int exact in double |

### 7.4 FP Adder / Multiplier / FMA Pipeline

==**FADD pipeline (3–4 cycles)**==: align exponents → add mantissas → normalize → round.

==**FMUL pipeline (4–5 cycles)**==: skip alignment → multiply (partial products + reduce) → add exponents → normalize → round. (One cycle longer than FADD due to partial-product reduction.)

==**FMA / FMAC pipeline (5–6 cycles, ~not 9!)**==: `a*b+c` with **single final rounding**.

Stages:
1. Partial Product Generation (mul) **‖ exponent alignment of `c`** (parallel)
2. Partial Product Reduction (mul)
3. Final add (combined with last reduction step) — saves vs separate FADD
4. Normalize + Round (one shot, not twice)

> Quiz: why FMA is **5–6 not 9 cycles**? FMUL needs partial-product reduction (multi-cycle); during reduction, FADD's exp alignment runs **in parallel**. After reduction, we add directly, skipping intermediate normalize/round. Saves ~3 cycles.

==**FMA Benefits**==: 2 FLOPs/cycle, lower latency, **higher precision** (one round vs two), smaller code, less power.

```bash
gcc -O3 -march=native -mfma -ffp-contract=fast
```

### 7.5 bfloat16 vs fp16 (Why GPUs Use Low Precision)

==**Why low precision on GPUs**==:
- More values per load/register/SIMD lane → higher memory + compute bandwidth.
- One AVX-512 instr can do 32 bfloat16 ops/cycle.
- AI is approximate (predictions); precision loss tolerable.

==**Why bfloat16 beats fp16 for ML**==:
- **8-bit exp** (vs fp16's 5-bit) → **same range as fp32** → fewer overflow/underflow problems on gradients.
- Fewer mantissa bits OK because AI is approximate.
- Easier conversion to/from fp32.

==**FP4 benefits**== (Nvidia Blackwell, 2025; Quiz CSC3050 #8):

| Claim | True? |
|---|---|
| **2× computational throughput vs FP8** | ✓ (half the bits → twice as many per SIMD slot) |
| **improved power efficiency** | ✓ (smaller datapath, less mem traffic) |
| **reduced memory bandwidth for params/activations** | ✓ |
| more accurate predictions | ✗ (less precision; only works because AI is robust) |

### 7.6 Saturation Arithmetic

Clip overflow at bounds (no wrap):

```text
int8:    120 + 20  →  -116   // wrap
sat int8: 120 + 20 →   127    // clip
```

Used: audio samples, video pixels, quantized AI (`int4`/`int8`); MMX/SSE multimedia instructions. **NOT** for normal int/FP.
