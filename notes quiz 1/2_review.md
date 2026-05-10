# Lec 2: Data Representation

## Exam Facts

- ==**Byte**==: 8 bits; smallest normal addressable unit.
- Word size mostly means **pointer/register address width**. RV32: 32b addresses/GPRs; RV64: 64b addresses/GPRs.
- LP64 won: `int` 4B, `long`/pointer 8B on most 64b Unix/RISC-V.
- Endianness matters only when bytes are reinterpreted across object sizes/types (e.g., int as chars, chars as int).
- C string `"12345"` bytes: `31 32 33 34 35 00`.
- ==If either operand is unsigned, the other is converted to unsigned==.
- Systems with both `+0` and `-0`: signed magnitude, one's complement, IEEE FP. **Not two's complement**.
- Exact binary fractions have denominator $2^k$: e.g., `1.625 = 1 + 5/8` exact; `1.405` not exact.
- FP addition is **commutative but not associative**; integer addition/subtraction bit behavior is modulo $2^w$.
- CSE/reassociation is safe for integer types like `long long`/`char`; not generally safe for `float`/`double`.
- Integer multiply latency ~3-5 cyc; divide ~32; FADD 4; FMUL 5; FMA 5-6; FP->int 3-5.
- bfloat16: 1 sign + **8 exp** + 7 frac -> same range as fp32, less precision than fp16.

## 1. Information Storage

### 1.1 Word Size + Data Sizes

| Type | RV32/ILP32 | RV64/LP64 |
|---|---:|---:|
| `char` | 1 | 1 |
| `short` | 2 | 2 |
| `int` | 4 | 4 |
| `long` | 4 | **8** |
| pointer | 4 | **8** |
| `float` | 4 | 4 |
| `double` | 8 | 8 |

For w-bit word size, byte address range is `0 ... 2^w-1`. RV32 can address **4 GiB**.

### 1.2 Byte Ordering

For integer `0x12345678` at lowest address `p`:

| Endian | `p` | `p+1` | `p+2` | `p+3` |
|---|---|---|---|---|
| Big | `12` | `34` | `56` | `78` |
| Little | `78` | `56` | `34` | `12` |

Search pattern: `0xAABBCCDD` -> big endian bytes `AA BB CC DD`; little endian bytes `DD CC BB AA`.

> [!IMPORTANT]
> Endian differs only if you **observe/rebuild bytes**: `int -> char[]`, `char[] -> int`, binary files/network without conversion. Same typed load/store (`int` as `int`) gives same value.

### 1.3 Bitwise, Logical, Shift

| C op | Meaning |
|---|---|
| `& | ^ ~` | bitwise |
| `&& || !` | logical; nonzero=true; short-circuit |
| `<<` | left shift, fill 0 |
| `>>` unsigned | logical right shift, fill 0 |
| `>>` signed | usually arithmetic right shift, fill sign bit |

> Trap: `A && B` != `A & B`. Example: `2 && 1` true, `2 & 1` = 0.

## 2. Integer Representation

### 2.1 Unsigned and Two's Complement

$$
B2U_w(x)=\sum_{i=0}^{w-1}x_i2^i,\quad
B2T_w(x)=-x_{w-1}2^{w-1}+\sum_{i=0}^{w-2}x_i2^i
$$

| w-bit type | Min | Max |
|---|---:|---:|
| unsigned | 0 | $2^w-1$ |
| two's complement | $-2^{w-1}$ | $2^{w-1}-1$ |

`TMin = 1000...0`, `TMax = 0111...1`, `-TMin == TMin` under wraparound.

### 2.2 Signed <-> Unsigned Conversion

Same bits, different interpretation:

$$
U =
\begin{cases}
T, & T \ge 0\\
T+2^w, & T<0
\end{cases}
\qquad
T =
\begin{cases}
U, & U<2^{w-1}\\
U-2^w, & U\ge 2^{w-1}
\end{cases}
$$

> [!IMPORTANT]
> In C comparison/arithmetic, if one operand is unsigned, signed operand is converted to unsigned. Negative signed values become huge.

### 2.3 Sign Extend / Truncate

- Sign extension: replicate sign bit to the left.
- Unsigned truncation: value mod $2^k$.
- Signed truncation: truncate bits, then reinterpret as k-bit two's complement.

## 3. Integer Arithmetic

Addition/subtraction use the same bit-level adder for signed and unsigned; interpretation differs.

| Operation | Overflow test |
|---|---|
| unsigned add | sum < either addend |
| unsigned subtract | result > minuend |
| signed add | same signs, result different sign |
| signed subtract | signs differ, result sign differs from minuend |

Project/data-lab pattern:

```c
sum_no_carry = a ^ b;
carry        = (a & b) << 1;
subtract     = add(a, add(~b, 1));
```

### 3.1 ALU Mini-Facts

- `AND/OR/XOR/NOT`: O(1) bitwise gates.
- Ripple-carry add/sub: O(n) carry chain.
- Carry-lookahead: use generate/propagate to shorten carry delay.
- `SLT`: compute `A-B`; result bit 0 = corrected sign (`sign xor overflow`), upper bits 0.

### 3.2 Multiply / Divide

- Multiplication: partial products + adder tree; faster design reduces O(n) serial add to O(log n)-like tree depth.
- Division: iterative subtract/restore/shift; high latency (~32 cyc).
- Signed division: remember signs, divide absolute values, fix quotient sign.

For signed division by $2^k$ rounding toward 0:

$$
x/2^k = (x<0 ? x+(2^k-1):x) >> k
$$

> Quiz codegen: signed `b/8` needs bias `+7` before `srai 3` if `b<0`.

## 4. Floating-Point Representation

### 4.1 IEEE Layout

| Format | Sign | Exp | Frac | Bias |
|---|---:|---:|---:|---:|
| fp32 | 1 | 8 | 23 | 127 |
| fp64 | 1 | 11 | 52 | 1023 |
| fp16 | 1 | 5 | 10 | 15 |
| bfloat16 | 1 | **8** | 7 | 127 |

Normalized value:

$$
(-1)^s(1.f)_2 2^{E-bias}
$$

### 4.2 Class Table (fp32)

| Exp | Frac | Class | Value |
|---|---|---|---|
| all 0 | 0 | zero | `+0` or `-0` |
| all 0 | nonzero | denormal | no hidden 1 |
| 1..254 | any | normalized | hidden leading 1 |
| all 1 | 0 | infinity | `+inf`/`-inf` |
| all 1 | nonzero | NaN | invalid/unknown |

> [!NOTE]
> IEEE FP has `+0` and `-0`: `1/+0 = +inf`, `1/-0 = -inf`; `sqrt(-1)=NaN`.

### 4.3 fp32 Hex Decode

`0x40800000`:

1. sign `0`.
2. exponent `0x81=129`, actual `E=2`.
3. fraction `0x000000`, significand `1.0`.
4. value `4.0`.

Quiz values: `0x40800000=4.0`, `0x3F800000=1.0`, `0xC0800000=-4.0`.

### 4.4 Custom 8b FP (4 exp + 3 frac, bias=7)

| Bits | Meaning |
|---|---|
| `s 0000 000` | signed zero |
| `s 0000 fff` nonzero | denormal, $E=1-bias=-6$, $M=0.fff_2$ |
| `s eeee fff`, `1<=e<=14` | normalized, $E=e-7$, $M=1.fff_2$ |
| `s 1111 000` | infinity |
| `s 1111 fff` nonzero | NaN |

Smallest positive denorm: `0 0000 001` = $(1/8)2^{-6}=1/512$.

### 4.5 Rounding

Default IEEE mode: ==**round-to-nearest, ties-to-even**==.

- If exactly halfway, choose result with LSB 0.
- `12.5 -> 12`, `13.5 -> 14` in integer rounding examples.

Exact decimal criterion:

> A finite decimal is exactly representable in binary iff, after reducing the fraction, denominator is a power of 2.
> Example: `1.625 = 13/8` exact; `1.405 = 281/200` not exact.

### 4.6 FP Operations

- FP addition/multiplication are usually commutative.
- FP is **not associative**: `(x+y)+z` may differ from `x+(y+z)`.
- Because of non-associativity, compiler cannot freely reassociate FP expressions unless allowed by fast-math-like flags.

> Quiz trap: `A == (int)(double)A` is true for 32b `int` because double has enough precision for every int.

### 4.7 FP / Int Casts

| Cast | Behavior |
|---|---|
| `int -> float` | may round |
| `int -> double` | exact for 32b int |
| `float -> double` | exact |
| `double -> float` | may round or overflow to inf |
| `float/double -> int` | rounds toward 0; overflow not portable |

### 4.8 FP Add Steps

1. Align exponents.
2. Add significands.
3. Normalize.
4. Round.
5. Check special cases/overflow/underflow.

## 5. FP Units

| Unit | Typical latency | Note |
|---|---:|---|
| Integer multiply | 3-5 cyc | partial products |
| Integer divide | ~32 cyc | iterative, hardest to pipeline |
| FADD | 4 cyc | align/add/normalize/round |
| FMUL | 5 cyc | partial product reduction |
| FMA/FMADD | 5-6 cyc | multiply + add fused; one rounding |
| FP -> int | 3-5 cyc | conversion |

### 5.1 Why FMA Is Not 9 Cycles

FMA overlaps multiply partial-product reduction with addend exponent alignment; product is **not normalized/rounded before adding**. It saves intermediate rounding/normalization and does only one final rounding.

### 5.2 Why GPUs Use bf16 / fp16

- Lower precision -> more values per load/register/vector op -> higher memory + compute bandwidth.
- bfloat16 has fp32-sized exponent (8b) -> much larger range than IEEE fp16; easier fp32<->bf16 conversion for ML.

## 6. Quiz Trap Cheat-Notes

- `A^2 >= 0` can be false for signed int overflow.
- `(X+Y)+Z == X+(Y+Z)` not always true for FP.
- `if (A<0) -A>0` false for `A=TMin`.
- `A == (int)(double)A` true for 32b int.
- Big/little endian differs when reinterpreting bytes, not same typed arithmetic.
