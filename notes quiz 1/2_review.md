# Lec 2: Data Representation

## Exam Facts

- ==**Word size**==: nominal pointer/register size. RV32 = **32b** GPR/addr (max 4GB); RV64 = **64b** (max 16EB).
- ==**Byte ordering**==: address of multi-byte object = **smallest** byte address.
  - **Little-endian** (Intel/AMD/ARM/RISC-V default): LSB at lowest addr; **Big-endian** (IBM, MIPS, SPARC): MSB at lowest addr.
- ==**ABI**== = **ISA + OS syscalls + calling convention** → binary portability.
- C int promotion: **if any operand is unsigned, signed operand is converted to unsigned** (silent trap).
- ==**Two's complement**==: range $[-2^{w-1},\,2^{w-1}-1]$. **`-INT_MIN == INT_MIN`** (no positive counterpart).
- RV core does **NOT trap** integer overflow; checking is compiler/software responsibility (RV omits trap variants for OoO/perf reasons).
- IEEE FP: sign | biased exp | fraction. **Normal has hidden 1**, **denormal has no hidden 1**.
- For $k$-bit exponent, **bias = $2^{k-1}-1$** unless explicitly redefined.
- FP `+`,`*` are **commutative** but **NOT associative** — compiler can't reassoc without `-ffast-math`.
- FP→int rounds **toward 0** (C standard); int→float can round but cannot overflow; int→double exact for 32b.
- ==**FMA**==: `a*b+c` with **ONE final rounding**, **5–6 cycles** (NOT 9), uses parallel reduction overlapping FADD's exponent alignment.
- ==**bfloat16**==: 1+**8**+7 = 16b; same exponent range as fp32, less precision than fp16; AI-friendly.
- Number systems with **+0/-0**: signed-magnitude, 1's complement, **IEEE FP**. **2's complement has only ONE 0**.
- Decimal $d$ exact in binary FP iff $d=p/q$ with $q$ a power of 2. Examples: 1.625 ✓, 1.5 ✓, 0.1 ✗, 1.405 ✗.
- `A == (int)(double)A` true for 32b int (double has 53b precision); not true for 64b `long`.

## 2.1 Information Storage

### 2.1.2 Word size + Data sizes

| C type | 32b | 64b LP64 |
|---|---|---|
| `char` | 1 | 1 |
| `short` | 2 | 2 |
| `int` | 4 | 4 |
| `long` | **4** | **8** |
| `long long` | 8 | 8 |
| `float` | 4 | 4 |
| `double` | 8 | 8 |
| `pointer` (`char *`) | **4** | **8** |
| `int32_t/uint32_t` | 4 | 4 |
| `int64_t/uint64_t` | 8 | 8 |

Constants: $\text{INT\_MAX}=2^{31}-1=$`0x7FFFFFFF`, $\text{INT\_MIN}=-2^{31}=$`0x80000000`.

> [!IMPORTANT] **LP64 vs ILP64**: LP64 (Linux/macOS) won — `int=4`, `long=ptr=8`. ILP64 doubles `int` storage and breaks data-file portability.

`gcc -m32` builds 32b code; `gcc -m64` requires 64b host.

### 2.1.3 Byte Ordering

> ==Multi-byte object's address = address of its **lowest** byte.==

- ==**Little-endian**==: LSB at lowest addr (Intel, AMD, ARM, RISC-V).
- ==**Big-endian**==: MSB at lowest addr (legacy: IBM, MIPS, SPARC, Motorola, network byte order).

> Example: `int x=0x12345678` stored on LE → bytes `78 56 34 12`. If sent raw to BE machine, read as `0x78563412`.

**Endian matters when**:
- network/file portability,
- type casting / pointer aliasing (read int as bytes),
- assembly reading,
- bit fields.

**Endian does NOT matter** if you store and read with the **same type on the same machine**.

### 2.1.4 Strings

- C string = char array terminated by **`'\0'`**. ASCII `'0' = 0x30`, so `"12345"` = `31 32 33 34 35 00`.
- Text data is **platform-independent**; binary code is not (different ABI).

### 2.1.6 Boolean Algebra

| Op | C | Example (4b) |
|---|---|---|
| AND | `&` | `0110 & 1100 = 0100` |
| OR | `\|` | `0110 \| 1100 = 1110` |
| XOR | `^` | `0110 ^ 1100 = 1010` |
| NOT | `~` | `~1100 = 0011` |

### 2.1.7–2.1.8 Bitwise vs Logical

- Bitwise `& | ^ ~` operate per bit on integral types.
- Logical `&& || !` treat any nonzero as true; **short-circuit** (if first decides answer, second not evaluated).
  - Safe: `if(p && p->next)` won't NULL-deref; `A && n/A` won't div-by-0.

> [!IMPORTANT] **Trap**: `A && B` ≠ `A & B`. With A=2 (`10`), B=1 (`01`): `&&`→true, but `&`→0 (false).

### 2.1.9 Shifts

- ==**Logical right shift**== fills 0 (used for unsigned `>>`).
- ==**Arithmetic right shift**== replicates sign bit (used for signed `>>`).
- C unsigned `>>` is logical; signed `>>` is implementation-defined (usually arithmetic on x86/RISC-V).
- `x << k`: low-k bits set to 0; bits shifted past MSB are discarded.

| X | X >> 4 logical | X >> 4 arithmetic |
|---|---|---|
| `01100011` | `00000110` | `00000110` |
| `10010101` | `00001001` | `11111001` |

## 2.2 Integer Representation

### Unsigned

$$B2U_w(\vec{x})=\sum_{i=0}^{w-1}x_i 2^i,\quad \text{range}=[0,\,2^w-1]$$

### Signed encodings

| Encoding | Formula | -2 (8b) |
|---|---|---|
| Sign-magnitude | $(1-2x_{w-1})\sum x_i 2^i$ | `1000 0010` |
| 1's complement | $-x_{w-1}(2^{w-1}-1)+\sum x_i 2^i$ | `1111 1101` |
| **2's complement** | $-x_{w-1}2^{w-1}+\sum_{i<w-1}x_i 2^i$ | `1111 1110` |

> Why 2's comp wins: **only one 0**, no end-around carry, same hardware for signed/unsigned add.

> [!IMPORTANT] **`-INT_MIN == INT_MIN`** (TMin has no positive twin). UB in C; never assume `-x > 0` if `x < 0`.

### Signed↔Unsigned

$$U=\begin{cases}S, & S\ge 0\\ S+2^w, & S<0\end{cases}=S\bmod 2^w$$

> [!IMPORTANT] **🚨 If one operand is unsigned, the other is converted to unsigned.**
> So `-1 < 0u` is **false** (`-1` becomes $2^w-1$).

### Sign extension / Truncation

- **Sign-extend** (smaller→larger): replicate sign bit into new high bits.
- **Truncate** (larger→smaller): drop high bits, then reinterpret. For signed: $T_k(x)=U2T_k(x\bmod 2^k)$.

## 2.3 Integer Arithmetic

### Addition

- **Unsigned**: wraps mod $2^w$. Overflow iff `sum < x` (or `< y`).
- **Signed (2's comp)**: same hardware; overflow iff **operands same sign, result different sign**:
  | A sign | B sign | Result sign indicating ovf |
  |---|---|---|
  | ≥0 | ≥0 | <0 |
  | <0 | <0 | ≥0 |
- Subtraction: `x - y = x + (~y + 1)`.
- Iterative add (no `+`): `sum = a^b`, `carry = (a&b) << 1`; loop until `carry == 0`.
  - Quiz: `(a & b) << 1` = **carry bits to add next iteration**.
  - Quiz: subtract via `add(a, add(~b, 1))` (2's comp logic).

### Why RV doesn't HW-trap overflow

- Performance: traps are expensive, overflows rare.
- Pipeline complexity: precise traps cost OoO logic.
- Flexibility: unsigned wrap is intentional (hashing, crypto).
- ⇒ **Compiler/software inserts checks if needed**; FP only sets a flag (poll explicitly).
- MIPS/ARM/Power keep trapping versions; RV puts those in extensions.

==**Precise exception**==: stops at well-defined state; clean state, restartable, "as if exception never happened". Easier with **in-order architectural state updates**.

### Overflow detection patterns

```c
x && (x*y)/x != y          // multiply overflow
y != 0 && (x/y)*y != x     // divide overflow (e.g., INT_MIN/-1)
```

### ALU mini-facts

- 1-bit full adder: $S=A\oplus B\oplus C_{in}$, $C_{out}=AB+C_{in}(A\oplus B)$.
- **RCA** (Ripple-Carry): O(n) delay.
- **CLA** (Carry-Lookahead): generate $g_i=A_iB_i$, propagate $p_i=A_i\oplus B_i$ → carries computed in O(log n).
- ALU ops `AND/OR/ADD/SLT` controlled by `Ainvert/Bnegate` + carry-in.
- SLT: subtract A−B, only LSB outputs the sign-of-difference; MSB uses `Set = Sum_{31} ⊕ Overflow`.
- **Faster multiplier**: tree of adders, O(log n).
- Quick power-of-2 division (signed): bias before shift.
  $$x/2^k=\begin{cases}x\gg k, & x\ge 0\\ (x+(1\ll k)-1)\gg k, & x<0\end{cases}$$

## 2.4 Floating-Point Representation

### IEEE 754 layout

$$x=(-1)^s\cdot M\cdot 2^E$$

| Format | Sign | Exp | Frac | Bias | Notes |
|---|---|---|---|---|---|
| **Quad** | 1 | 15 | 112 | 16383 | IEEE-754 |
| **Double** (fp64) | 1 | 11 | 52 | 1023 | |
| **Single** (fp32) | 1 | 8 | 23 | 127 | |
| **Half** (fp16) | 1 | 5 | 10 | 15 | Tesla P100, 2016 |
| **bfloat16** | 1 | **8** | 7 | 127 | Google Brain, fp32-range |
| fp8 (mini) | 1 | 4 | 3 | 7 | H100 |
| fp4 | 1 | 2 | 1 | 1 | B100/B200 |

For **k-bit exponent**: ==**bias = $2^{k-1}-1$**==.

### Class table (single-precision example)

| Exp `e` | Frac `f` | Class | Value |
|---|---|---|---|
| `0` | `0` | ±0 | $\pm 0$ |
| `0` | nonzero | **Denormal** (no hidden 1) | $(-1)^s \cdot (0.f) \cdot 2^{1-bias}$ |
| `1..2^k-2` | any | **Normal** (hidden 1) | $(-1)^s \cdot (1.f) \cdot 2^{e-bias}$ |
| all-1 | `0` | ±∞ | $\pm\infty$ |
| all-1 | nonzero | NaN | NaN |

> [!IMPORTANT]
> - **Normal**: $M=1.f$, $E=e-\text{bias}$.
> - **Denormal**: $M=0.f$, $E=1-\text{bias}$ (NOT $-\text{bias}$).
> - Denormal fills the gap near 0; smaller, less precision.
> - More exp bits → larger range; fewer frac bits → less precision.

### Single-precision range/extremes (fp32, bias=127)

| | Bits | Value |
|---|---|---|
| Largest normal | `0 11111110 1...1` (`0x7F7FFFFF`) | $\approx 3.4\times 10^{38}$ |
| Smallest normal | `0 00000001 0...0` | $2^{-126}$ |
| Largest denormal | `0 00000000 1...1` | $(1-2^{-23})\cdot 2^{-126}$ |
| Smallest denormal | `0 00000000 0...01` | $2^{-149}$ |
| `+0.0` | `0x00000000` | 0 |
| `+1.0` | `0x3F800000` | exp=127, M=1.0 |
| `+2.0` | `0x40000000` | exp=128, M=1.0 |
| `+4.0` | `0x40800000` | exp=129, M=1.0 |
| `+∞` | `0x7F800000` | |

### Quick decode example (Quiz 1 #4)

`F1=0x40800000`: `0|10000001|0..0` → E=129−127=2, M=1.0 → **+4.0**.
`F2=0x3F800000`: `0|01111111|0..0` → E=0, M=1.0 → **+1.0**.
`F3=0xC0800000`: sign 1 → **−4.0**.
Then `F1+F3=0` ✓, `F3<F2<F1` ✓, `F2 = F1/F3 = -1.0 ≠ 1.0` ✗, `F3=-(F1*F2)` ✓.

### 2.4.3 Custom 8-bit FP example (4 exp + 3 frac, bias=7)

| Description | Bits | E | M | Value |
|---|---|---|---|---|
| Zero | `0 0000 000` | — | 0 | 0 |
| Smallest +denorm | `0 0000 001` | 1−7=−6 | 1/8 | $2^{-9}=1/512$ |
| Largest denorm | `0 0000 111` | −6 | 7/8 | $7/512$ |
| Smallest normal | `0 0001 000` | −6 | 1 | $1/64$ |
| One | `0 0111 000` | 0 | 1 | 1.0 |
| Largest normal | `0 1110 111` | 7 | 15/8 | 240 |
| ±∞ | `0 1111 000` | — | — | ∞ |

### Why float covers a huge range but loses integer precision

Floats are exact for integers in $[0, 2^{24}]$. Beyond that, **ULP = $2^{e-(p-1)}=2^{E-23}$** for normals.

| Value | Stored as |
|---|---|
| 123456784 | exact (multiple of 16) |
| 123456789 | rounded to 123456792 |
| 123456790 | rounded to 123456792 |
| 123456791 | rounded to 123456800 |

### 2.4.4 FP Rounding

4 IEEE modes: ==**round-to-even (default), toward 0, down, up**==.

==**Round-to-even (banker's rounding)**==: if exactly halfway, choose value with **LSB = 0**.

| Value | Halfway between | Rounded |
|---|---|---|
| 12.5 | 12 / 13 | 12 |
| 13.5 | 13 / 14 | 14 |
| 1.875 (5 bits) → 1.11_1 | 1.11 / 10.00 | 10.00 (LSB=0) |

### 2.4.5 FP Operations

- ==`1/+0=+∞`, `1/-0=-∞`, `sqrt(-1)=NaN`==
- Commutative: `a op b == b op a`.
- **NOT associative**: `(3.14+1e10)-1e10 = 0.0`; `3.14+(1e10-1e10) = 3.14`.

> [!IMPORTANT] Compiler may NOT do CSE/reassociation on FP without `-ffast-math`:
> - `(a+b+c+d)` ≠ `((a+b)+(c+d))` ✗ for float/double
> - Same expression with **integer (`long long`, `char`)**: CSE allowed ✓.

### FP/Int casting

| Conversion | Behavior |
|---|---|
| int → float | may **round**, cannot overflow |
| int → double | **exact** for 32b int |
| float → double | **exact** |
| double → float | may round / overflow to ±∞ |
| float/double → int | **rounds toward 0**; overflow result **not portable** |

> Intel: float→int overflow returns `0x80000000` ("integer indefinite").

### FP addition (manual)

1. **Align** exponents (shift smaller mantissa right).
2. **Add** significands (with sign).
3. **Normalize** (shift to put leading 1 back).
4. **Round** (default round-to-even).

Example: $1.000_2\cdot 2^{-1}+(-1.110_2\cdot 2^{-2})$ → align to $\cdot 2^{-1}$: $1.000-0.111=0.001\cdot 2^{-1}$ → normalize: $1.000\cdot 2^{-4}=0.0625$.

### 2.5 FP Units (latencies)

| Op | Latency | Pipelining |
|---|---|---|
| FADD | **3–4 cyc** | yes |
| FMUL | **4–5 cyc** | yes |
| FMA | **5–6 cyc** | yes |
| FP→Int | **3–5 cyc** | yes |
| Int multiply | 3–5 cyc | yes |
| Int divide | **~32 cyc** | hard to pipeline |

==**FMA (R4-type)**== `a*b+c`: 1 instr, **1 final rounding** (more accurate than separate mul+add).

> Why FMA is 5/6 not 9: FMUL has 5 cycles where most work is **partial-product reduction**. While reduction runs, FADD can do its **exponent alignment in parallel**. The product **doesn't need normalize/round** before the final add. Saves the 2 (norm+round) + 1 (alignment overlap) ≈ 3 cycles. Net: ~6 cycles.

> Why FMA in R4 (3 src + 1 dst): preserves dot products / matrix mul. 3-operand alternative `rd = rs1*rs2 + rd` works for dot-product but **breaks regularity** (rd is both src+dst → needs 2 read ports for rd).

### 2.6 Why GPUs use bfloat16/fp16

- **Higher memory bandwidth + computation throughput**: 1 double load = 4 bf16; 1 AVX-512 instr = 32 bf16 ops/cycle.
- AI is **approximate**; precision loss is acceptable.
- ==**bfloat16 wins over fp16**== because bf16 has **8 exp bits** (same as fp32) → much larger range; easier conversion to/from fp32. fp16 only has 5 exp bits → narrow range, easy to overflow.

## 2.6 Quiz Traps Cheat Sheet

- 128 all-0 bits: **could be 4× SP +0.0**, two long zeros, padding. **Cannot** be assumed to be a quad-precision value unless format is given.
- "Char string `0000`" is `0x30 0x30 0x30 0x30`, NOT all-zero bytes.
- Unsigned wrap is well-defined; signed overflow is **UB** (compiler may optimize assuming it can't happen).
- Number systems with both ±0: signed-magnitude, 1's-complement, IEEE FP.
- Exact decimal in FP iff denominator (reduced) is power of 2: 1.625 ✓, 1.5 ✓, others usually ✗.
- `(X+Y)+Z == X+(Y+Z)` is **not always true** for FP.
- `if (A<0) -A>0` is **false** when A=INT_MIN (since `-INT_MIN==INT_MIN<0`).
- `(x*x) >= 0`: **false** in 2's comp (e.g., `0xFFFF * 0xFFFF` overflows to negative as `int`).
- `x+y == ux+uy` (where ux=(unsigned)x, uy=(unsigned)y): **true** — same bit-level behavior.
