# Lec 2: Data Representation

## Exam Facts

- Byte = 8 bits; memory is byte-addressed. Pointer value = virtual address of first byte; pointer type controls interpretation.
- Word size is nominal pointer/GPR size. 32b address space -> `2^32` bytes = 4 GiB.
- LP64: `int` 4B, `long` 8B, pointer 8B. ILP64 lost partly because 8B `int` doubles storage and hurts data compatibility.
- Most current x86/ARM/RISC-V systems are little-endian or bi-endian.
- Endianness matters when viewing bytes, binary files, network data, casts/aliasing, and assembly/debug output.
- C string `"12345"` bytes = `31 32 33 34 35 00`; text is more portable than binary.
- If either C integer operand is unsigned, the other is converted to unsigned.
- Two's-complement range: `TMin=-2^{w-1}`, `TMax=2^{w-1}-1`, `UMax=2^w-1`.
- `-TMin == TMin` in fixed-width two's complement.
- RISC-V does **not** trap on integer overflow; software/compiler must check if needed.
- Signed right shift is usually arithmetic; unsigned right shift is logical.
- IEEE fp32: 1 sign, 8 exp, 23 frac, bias 127. fp64: 1, 11, 52, bias 1023.
- FP addition/multiplication are commutative but **not associative**.
- FMA: one fused multiply-add, one final rounding, latency about 5-6 cycles.
- bfloat16: 1 sign + **8 exp** + 7 frac; same exponent range as fp32, less precision.

## 1. Information Storage

### 1.1 Bits, Bytes, Addresses

| Term | Meaning |
|---|---|
| bit | 0/1 value |
| byte | 8 bits, smallest addressable memory unit |
| address | numeric identifier of a byte in memory |
| virtual address space | set of possible addresses visible to a process |
| physical address | address in DRAM frame, reached through MMU/page table |
| pointer in C | virtual address of first byte of an object |
| pointer type | tells compiler how many bytes and how to interpret them |

Bits can represent integers, FP numbers, addresses, instrs, chars, media data, or aggregate fields depending on context.

### 1.2 Decimal, Binary, Hex

Hex is compact for binary because 1 hex digit = 4 bits.

| Binary | Hex |
|---|---|
| `0000` | `0` |
| `1001` | `9` |
| `1010` | `a` |
| `1111` | `f` |

Useful powers: `2^10=1024`, `2^20=1 MiB`, `2^30=1 GiB`, `2^32=4 GiB`.

### 1.3 Data Sizes and Pointer Sizes

| C type | 32b bytes | 64b LP64 bytes |
|---|---:|---:|
| `char` | 1 | 1 |
| `short` | 2 | 2 |
| `int` | 4 | 4 |
| `long` | 4 | **8** |
| `long long` / `int64_t` | 8 | 8 |
| pointer | 4 | **8** |
| `float` | 4 | 4 |
| `double` | 8 | 8 |

| Type | Range |
|---|---|
| `int32_t` | `[-2^31, 2^31-1]` = `[0x80000000, 0x7fffffff]` |
| `uint32_t` | `[0,2^32-1]` |

> Use `long long`, `uint64_t`, `double`, or explicit overflow checks if a computation can exceed 4 billion but stays below 32 billion.

## 2. Addressing and Byte Ordering

### 2.1 Big vs Little Endian

A multi-byte object occupies contiguous bytes; the object address is the smallest byte address.

For integer `0x12345678` stored at address `p`:

| Endian | `p` | `p+1` | `p+2` | `p+3` |
|---|---|---|---|---|
| big | `12` | `34` | `56` | `78` |
| little | `78` | `56` | `34` | `12` |

Search pattern: `0xAABBCCDD` -> big endian bytes `AA BB CC DD`; little endian bytes `DD CC BB AA`.

Endian matters for:

- network/binary-file portability.
- pointer casts like `(unsigned char *)&x`.
- assembly/debug byte dumps.
- bit fields and low-level ABI formats.

### 2.2 `show_bytes`

```c
typedef unsigned char *byte_pointer;
void show_bytes(byte_pointer start, size_t len) {
    for (size_t i=0; i<len; i++) printf(" %.2x", start[i]);
    printf("\n");
}
```

For `int val=12345 = 0x00003039`:

| Machine | `int` bytes |
|---|---|
| little endian | `39 30 00 00` |
| big endian | `00 00 30 39` |

For `"12345"` with length 6: `31 32 33 34 35 00`.

> Results for integers/floats may match except for byte order; pointer byte values are machine-dependent.

### 2.3 Program Bytes and ABI

The same C function compiles to different machine-code bytes across ISA/OS/ABI.

==**ABI**==: Application Binary Interface = ISA + OS interface + calling convention + binary object conventions. Example: x86/Windows binary does not run directly on ARM/Linux.

## 3. Boolean, Bit-Level, Logical, and Shift Ops

### 3.1 Boolean Algebra

For bit vectors `0110` and `1100`:

| Op | Result |
|---|---|
| `0110 & 1100` | `0100` |
| `0110 | 1100` | `1110` |
| `0110 ^ 1100` | `1010` |
| `~1100` for 4b | `0011` |

### 3.2 Bitwise vs Logical C Ops

| C op | Meaning |
|---|---|
| `& | ^ ~` | bitwise on each bit |
| `&& || !` | logical; any nonzero = true |
| `&& ||` | short-circuit |

Common bug:

```c
A = 2; B = 1;
A && B   // true
A & B    // 0, because 10b & 01b = 00b
```

`if (p && p->next)` is safe because `p->next` is not evaluated when `p==NULL`.

### 3.3 Shift Ops

| Operation | Fill |
|---|---|
| `x << k` | low bits with 0 |
| unsigned `x >> k` | high bits with 0, logical shift |
| signed `x >> k` | usually high bits with sign bit, arithmetic shift |

Example 8b `10010101 >> 4`:

| Interpretation | Result |
|---|---|
| unsigned/logical | `00001001` |
| signed/arithmetic | `11111001` |

## 4. Integer Representation

### 4.1 Unsigned

For w-bit vector `x`:

$$
B2U_w(x)=\sum_{i=0}^{w-1}x_i2^i
$$

Range: `0 ... 2^w-1`.

### 4.2 Signed Encodings

| Encoding | Formula / rule | Problem |
|---|---|---|
| sign-magnitude | sign bit + magnitude | two zeros |
| one's complement | negative = bitwise inverse | two zeros, end carry |
| two's complement | high bit has weight `-2^{w-1}` | one extra negative |

$$
B2T_w(x)=-x_{w-1}2^{w-1}+\sum_{i=0}^{w-2}x_i2^i
$$

| 8b value | unsigned | two's complement |
|---|---:|---:|
| `00000000` | 0 | 0 |
| `01111111` | 127 | 127 |
| `10000000` | 128 | -128 |
| `11111111` | 255 | -1 |

### 4.3 Signed <-> Unsigned Conversion

Bit pattern is unchanged; interpretation changes.

$$
U =
\begin{cases}
S, & S \ge 0 \\
S+2^w, & S < 0
\end{cases}
\quad\text{equiv}\quad U=S\bmod 2^w
$$

> [!IMPORTANT]
> In C, if one operand is unsigned, the other is converted to unsigned. Example: `-1 < 0U` is false because `-1` becomes `UMax`.

### 4.4 Extension and Truncation

| Operation | Rule |
|---|---|
| zero extension | add 0 high bits |
| sign extension | replicate sign bit |
| unsigned truncation to k bits | `value mod 2^k` |
| signed truncation to k bits | first keep low k bits, then interpret as two's complement |

Examples:

| Source | Operation | Result |
|---|---|---|
| 8b `11110000` unsigned | extend to 16b | `0000000011110000` |
| 8b `11110000` signed | extend to 16b | `1111111111110000` |
| `0x12345678` -> 16b | truncate | `0x5678` |

## 5. Integer Arithmetic

### 5.1 Addition, Negation, Overflow

Fixed-width arithmetic is modulo `2^w`.

Unsigned addition:

$$
x +^u_w y = (x+y)\bmod 2^w
$$

Unsigned overflow detection: sum `< x` or sum `< y`.

Signed addition overflow:

| Operation | Overflow if |
|---|---|
| `a+b` | same sign operands, result has different sign |
| `a-b` | operands have different signs, result sign differs from `a` |

Boolean rule for addition:

```text
overflow = !(sign_a ^ sign_b) && (sign_a ^ sign_sum)
```

Two's-complement negation:

```text
-x = ~x + 1
-TMin = TMin
```

### 5.2 RISC-V Integer Overflow Policy

RISC-V integer ALU ops do not trap on overflow.

Why:

- traps are expensive and overflows are rare.
- unsigned wrap-around is useful in hashing/crypto/modular arithmetic.
- precise exceptions complicate pipelines/OoO.
- software can check explicitly when required.

> FP operations set flags; software polls them if needed.

### 5.3 ALU Adder and SLT

One-bit full adder:

```text
sum = a ^ b ^ cin
cout = (a&b) | (a&cin) | (b&cin)
```

Ripple-carry adder (RCA): carry propagates through bits, delay `O(w)`.

Carry-lookahead adder (CLA):

$$
g_i=A_iB_i;\quad p_i=A_i\oplus B_i;\quad C_{i+1}=g_i+p_iC_i
$$

ALU control idea:

| Operation | Control idea |
|---|---|
| AND/OR | direct bitwise path, no carry chain |
| ADD | `Bnegate=0`, `Cin0=0` |
| SUB | `Bnegate=1`, `Cin0=1`, compute `A + ~B + 1` |
| SLT | compute `A-B`; result bit 0 = `set`, other bits 0 |

For signed SLT:

```text
set = sign(sum_of_A_minus_B) ^ overflow
```

### 5.4 Multiply and Divide

| Operation | Typical latency / cost |
|---|---|
| integer add/logic | 1 cycle |
| integer multiply | about 3-5 cycles |
| integer divide | about 32 cycles, iterative, hardest to pipeline |

Faster multiply uses a tree of adders: delay improves from roughly `O(n)` to `O(log n)`.

Signed division:

1. remember signs.
2. divide magnitudes as unsigned.
3. negate quotient if signs differ.

Signed division by power of 2:

```c
x / (1<<k) == (x < 0 ? x + (1<<k) - 1 : x) >> k
```

`x >> 31 & 1` extracts sign bit for 32b int.

Overflow checks:

```c
x && x*y / x != y          // multiplication overflow
y != 0 && x / y * y != x   // division overflow
```

## 6. Floating-Point Representation

### 6.1 Binary Fractions

Binary fraction bits have weights `1/2, 1/4, 1/8, ...`.

| Decimal | Binary | Exact? |
|---|---|---|
| `1.625` | `1.101_2` | yes, `13/8` |
| `0.7` | repeating binary | no |
| `1.405` | denominator 200 | no, not denominator `2^k` |

### 6.2 IEEE Layout

| Format | Sign | Exp | Frac | Bias |
|---|---:|---:|---:|---:|
| fp32 | 1 | 8 | 23 | 127 |
| fp64 | 1 | 11 | 52 | 1023 |
| fp16 | 1 | 5 | 10 | 15 |
| bfloat16 | 1 | 8 | 7 | 127 |
| fp8 example | 1 | 4 | 3 | 7 |

Normalized value:

$$
V=(-1)^s(1.f)_2 2^{e-Bias}
$$

Denormalized/subnormal value:

$$
V=(-1)^s(0.f)_2 2^{1-Bias}
$$

### 6.3 fp32 Classes

| Exp | Frac | Value |
|---|---|---|
| `00000000` | 0 | `+0` or `-0` |
| `00000000` | nonzero | subnormal, no hidden 1 |
| `00000001` to `11111110` | any | normalized |
| `11111111` | 0 | `+inf` or `-inf` |
| `11111111` | nonzero | NaN |

fp32 exact integer range: all integers up to `2^24`; above that, spacing grows.

### 6.4 fp32 Hex Decode Pattern

For 32b pattern:

1. split sign, exp, frac.
2. if exp not all 0/1, `E=e-127`, `M=1+frac/2^23`.
3. value = `(-1)^s * M * 2^E`.

High-yield examples:

| Hex | Meaning |
|---|---|
| `0x3f800000` | `1.0` |
| `0xbf800000` | `-1.0` |
| `0x00000000` | `+0.0` |
| `0x80000000` | `-0.0` |
| `0x7f800000` | `+inf` |
| `0xff800000` | `-inf` |

### 6.5 Custom 8b FP: 1 Sign + 4 Exp + 3 Frac, Bias 7

| Bits | Class / value |
|---|---|
| `0 0000 000` | `+0` |
| `0 0000 001` | smallest positive subnormal = `1/8 * 2^{-6} = 1/512` |
| `0 0000 111` | largest subnormal = `7/512` |
| `0 0001 000` | smallest normal = `1 * 2^{-6} = 1/64` |
| `0 0111 000` | `1.0` |
| `0 1110 111` | largest normal = `(1+7/8)*2^7 = 240` |
| `0 1111 000` | `+inf` |
| `0 1111 nonzero` | NaN |

## 7. Floating-Point Rounding and Operations

### 7.1 Rounding Modes

IEEE rounding modes:

- round to nearest, ties to even (default).
- toward 0.
- toward `+inf`.
- toward `-inf`.

Ties-to-even: if exactly halfway, choose representable value whose least significant bit is 0.

| Value | Ties-to-even result |
|---|---|
| `12.5` | `12` |
| `13.5` | `14` |

### 7.2 FP Operation Rules

| Expression | Result / rule |
|---|---|
| `1/+0` | `+inf` |
| `1/-0` | `-inf` |
| `sqrt(-1)` | NaN |
| `a+b` | commutative for normal finite arithmetic |
| `(a+b)+c` vs `a+(b+c)` | not necessarily equal |

Classic non-associativity:

```text
(3.14 + 1e10) - 1e10 = 0.0
3.14 + (1e10 - 1e10) = 3.14
```

Compiler consequence: cannot freely reassociate FP expressions or treat reordered sums as the same CSE unless fast-math rules allow it.

### 7.3 FP / Int Casts

| Conversion | Behavior |
|---|---|
| `int -> float` | may round; no overflow for 32b int to fp32 range |
| `int/float -> double` | exact for 32b int and fp32 values |
| `double -> float` | may overflow to inf, underflow, or round |
| `float/double -> int` | rounds toward 0; overflow is not portable in C |

Intel-style indefinite integer on FP-to-int overflow may be `0x80000000` (`TMin`), e.g., `(int)+1e10` can become `-2147483648`.

### 7.4 FP Addition Steps

Example: `1.000_2 * 2^{-1} + (-1.110_2 * 2^{-2})`.

1. align exponents: `1.000*2^{-1} + (-0.111*2^{-1})`.
2. add significands: `0.001*2^{-1}`.
3. normalize: `1.000*2^{-4}`.
4. round: unchanged -> `0.0625`.

### 7.5 FP Units and FMA

| Unit | Latency idea | Notes |
|---|---|---|
| FADD | 3-4 cycles | align exponents, add, normalize, round |
| FMUL | 4-5 cycles | partial products + exponent add, normalize, round |
| FMA/FMADD | 5-6 cycles | multiply-add fused, one final rounding |

FMA is not `FMUL latency + FADD latency` because product reduction overlaps addend alignment/final addition and avoids intermediate normalization/rounding.

Benefits: higher throughput, smaller code, better precision, lower energy for dot products and matrix multiply.
