# Chapter 2: Data Representation

## Exam Facts

- ==**Word size**==: nominal pointer/register size; RV32 pointers/GPRs are **32b**, RV64 are **64b**.
- ==**Byte ordering**==: multi-byte object address = **smallest byte address**; endian only matters when viewing same bytes with different types/byte orders.
- ==**ABI**==: **ISA + OS + calling convention**; binary portability depends on it.
- C integer promotions: if one operand is **unsigned**, the signed operand is converted to unsigned.
- ==**Two's complement**==: range $[-2^{w-1},2^{w-1}-1]$; **`-INT_MIN == INT_MIN`**.
- RISC-V integer overflow: **no hardware trap**; compiler/software must check if needed.
- ==**IEEE FP**==: sign, biased exponent, fraction; normal has hidden 1, denormal has no hidden 1.
- FP addition/multiplication are **commutative but not associative**.
- FP -> int rounds **toward 0** in C; int -> float may round but cannot overflow.
- ==**FMA**==: computes `a*b+c` with **one rounding**, usually 5-6 cycles, improves precision and throughput.
- ==**bfloat16**==: 1 sign + **8 exp** + 7 frac; same exponent range as fp32, less precision than fp16.

## 2.1 Information Storage

- Common sizes: `char` 1B, `short` 2B, `int` 4B, `long` 4B on ILP32 / 8B on LP64, pointer 4B on RV32 / 8B on RV64.
- `INT_MAX = 2^31-1`, `INT_MIN = -2^31`.
- ==**Little endian**== stores least-significant byte at lowest address; ==**big endian**== stores most-significant byte at lowest address.
- Endian mismatch: bytes for `0x12345678` may be read as `0x78563412`.
- Strings are byte sequences ending with `'\0'`; ASCII `'0' = 0x30`.

## 2.1.6-2.1.9 Boolean, Bitwise, Shift

- Bitwise ops: `& | ^ ~`; logical ops: `&& || !` convert operands to truth values.
- Logical right shift fills with 0; arithmetic right shift replicates sign bit.
- In C, unsigned right shift is logical; signed negative right shift is implementation-defined but usually arithmetic.
- `x << k` shifts low bits out, fills low bits with 0; overflow bits are discarded.

## 2.2 Integer Representation

==**Unsigned**==: $B2U_w(\vec{x})=\sum x_i2^i$, range $[0,2^w-1]$.

==**Two's complement**==: $B2T_w(\vec{x})=-x_{w-1}2^{w-1}+\sum_{i=0}^{w-2}x_i2^i$.

Key traps:
- signed and unsigned use same bits but different interpretation;
- `-1` as unsigned is $2^w-1$;
- `TMin` has no positive counterpart;
- comparing signed with unsigned converts signed to unsigned.
- C rule: **unsigned overflow wraps mod $2^w$; signed overflow is undefined behavior**, so compiler may optimize assuming it never happens.

Sign extension: copy sign bit into new high bits. Truncation: drop high bits; reinterpret remaining bits.

## 2.3 Integer Arithmetic

- Unsigned addition wraps mod $2^w$; overflow if `sum < x` or `sum < y`.
- Two's-complement addition uses same hardware; signed overflow if same-sign operands produce different-sign result.
- Subtraction: `x-y = x + (~y+1)`.
- Carry bits for iterative add: `sum = a ^ b`, `carry = (a & b) << 1`; repeat until carry = 0.
- Signed multiply/divide overflow checks must be explicit; RISC-V core does not trap integer overflow.

> [!IMPORTANT]
> RV arithmetic exceptions are mostly software/compiler responsibility; precise exceptions are easier if architectural state updates in order.

## 2.4 Floating-Point Representation

IEEE single: 1 sign, 8 exponent, 23 fraction, bias 127.

| Exp | Frac | Class |
|---|---|---|
| 0 | 0 | +/-0 |
| 0 | nonzero | denormal, value $(-1)^s M2^{1-bias}$ |
| 1..254 | any | normalized, hidden 1, $E=e-bias$ |
| 255 | 0 | +/-inf |
| 255 | nonzero | NaN |

- For k exponent bits, **bias = $2^{k-1}-1$** unless the problem defines otherwise.
- Normal: $M=1.f$, $E=e-bias$; denormal: $M=0.f$, $E=1-bias$.
- With fixed total bits, more exponent bits -> larger range but fewer fraction bits -> lower precision.
- Denormals fill gap near 0; no hidden 1.
- Round-to-even: if exactly halfway, choose representable value with LSB 0.
- Rounding modes: to-even, toward 0, down, up.
- `1/+0 = +inf`, `1/-0 = -inf`, `sqrt(-1)=NaN`.
- FP ops are not associative/distributive; compiler cannot freely reassociate unless allowed by fast-math flags.

## 2.4.5 FP Conversions

- `int -> float`: may round, cannot overflow.
- `int -> double`: exact for 32b int.
- `float -> double`: exact.
- `double -> float`: may round/overflow to inf.
- `float/double -> int`: rounds toward 0; overflow result not portable by C standard.

## 2.5 FP Units, FMA, bfloat16

- FADD: align exponents -> add significands -> normalize -> round.
- FMUL: multiply significands and add exponents in parallel; normalize/round.
- ==**FMA/FMADD**==: `a*b+c`; one instruction, one final rounding; dot products/matrix multiply.
- FMA is not 9 cycles because multiply reduction and add alignment overlap; no intermediate normalize/round.
- GPUs use FP16/bfloat16 for **higher bandwidth + more operations per cycle**.
- bfloat16 is popular in AI because **8-bit exponent gives fp32-like range**; precision loss is acceptable for approximate ML.

## 2.6 Quiz Traps

- Number systems with +0/-0: sign-magnitude, one's complement, IEEE FP; **two's complement has only one 0**.
- Exact decimal FP: finite binary fraction iff denominator after reduction is power of 2.
- `A == (int)(double)A` is true for 32b int because double has 53-bit precision.
- `(X+Y)+Z == X+(Y+Z)` is not always true for FP.
