# Lec 2: Data Representation

## Exam Facts

- **Byte-addressed memory**: pointer = virtual address of first byte; pointer type controls interpretation.
- ==**Word size**==: nominal pointer/GPR size; `w`-bit machine has addresses `0..2^w-1`.
- **32b address space**: $2^{32}$ bytes = **4 GiB**.
- **LP64 sizes**: `char 1`, `short 2`, `int 4`, `long 8`, pointer 8, `float 4`, `double 8`.
- ==**ABI**==: ISA + OS + calling convention; binary code is not portable across incompatible ABIs.
- **Little endian**: least significant byte at lowest address.
- **Unsigned conversion trap**: if either C integer operand is `unsigned`, the other becomes `unsigned`.
- ==**Two's complement**==: `TMin=-2^{w-1}`, `TMax=2^{w-1}-1`, `UMax=2^w-1`; `-TMin == TMin`.
- **RISC-V integer overflow**: does **not** trap; software checks if needed.
- **Right shift**: signed usually arithmetic; unsigned logical.
- **IEEE fp32/fp64**: `s|exp8|frac23`, bias 127; `s|exp11|frac52`, bias 1023.
- **Exact binary decimal**: after reducing fraction, denominator must be a power of 2.
- **Strict FP**: `+,-,*` are not associative; compiler cannot freely reassociate without fast-math.
- ==**FMA**==: `a*b+c` with one final rounding; about `5-6` cycles, not multiply+add latency.
- **`bfloat16`**: `s|exp8|frac7`; fp32 exponent range, less precision.
- **Latency facts**: int multiply `3-5`, int divide `~32`, SP FP add `4`, SP FP multiply `5`, FP->int `3-5`.

## 1. Information Storage

### 1.1 Bits, Bytes, Addresses

| Term | Meaning |
|---|---|
| bit | 0/1 |
| byte | 8 bits, smallest addressable unit |
| address | byte index in virtual/physical memory |
| pointer | address + type-directed interpretation |
| word size | nominal pointer/GPR size; controls address-space size |

Useful powers: `2^10=1 KiB`, `2^20=1 MiB`, `2^30=1 GiB`, `2^32=4 GiB`.

If an unsigned `int` computation can exceed $2^{32}-1$ but stays below $2^{64}$, use `uint64_t` / `unsigned long long`.

### 1.2 Decimal, Binary, Hex

1 hex digit = 4 bits.

| Binary | Hex | Decimal |
|---|---|---:|
| `1111` | `f` | 15 |
| `1000 0000` | `0x80` | 128 unsigned / -128 int8 |
| `1111 1111` | `0xff` | 255 unsigned / -1 int8 |

### 1.3 C Data Sizes

| C type | RV32/ILP32 | RV64/LP64 |
|---|---:|---:|
| `char` | 1 | 1 |
| `short` | 2 | 2 |
| `int` | 4 | 4 |
| `long` | 4 | 8 |
| `long long` | 8 | 8 |
| pointer | 4 | 8 |
| `float` | 4 | 4 |
| `double` | 8 | 8 |

LP64 won over ILP64 in mainstream 64b systems: `int` stays 4B for data compatibility; `long`/pointers become 8B.

## 2. Byte Ordering and Pointer Casts

### 2.1 Big vs Little Endian

For `int x = 0x12345678` stored at address `p`:

| Endian | `p` | `p+1` | `p+2` | `p+3` |
|---|---|---|---|---|
| big | `12` | `34` | `56` | `78` |
| little | `78` | `56` | `34` | `12` |

Endian matters when reading bytes of a multi-byte object, binary files, network data, debugger dumps.

### 2.2 `show_bytes` / Cast Traps

```c
typedef unsigned char *byte_pointer;
show_bytes((byte_pointer)&x, sizeof x);
```

For `int x=12345=0x00003039`:

| Machine | Bytes |
|---|---|
| little | `39 30 00 00` |
| big | `00 00 30 39` |

`"12345"` bytes are always `31 32 33 34 35 00`.

> [!IMPORTANT]
> `*((char*)p + k)` reads byte `k`. `((T*)p)[k]` advances by `k*sizeof(T)`.

==**C string**==: byte array terminated by `0`; common encoding is ASCII, e.g. `'0'` = `0x30`.

Text strings are usually more portable than binary data. Binary code depends on the ABI: ISA + OS + calling convention.

## 3. Boolean, Bitwise, Logical, Shift

### 3.1 Bitwise vs Logical

| C op | Meaning |
|---|---|
| `& | ^ ~` | bitwise on every bit |
| `&& || !` | logical, nonzero = true, `&&/||` short-circuit |

```c
2 && 1 == 1
2 & 1  == 0
```

**Short-circuit** examples: `a && n/a` avoids divide-by-0 when `a==0`; `p && p->next` avoids null dereference.

### 3.2 Shifts

| Operation | Fill |
|---|---|
| `x << k` | low bits 0; overflow/discard high bits |
| unsigned `x >> k` | high bits 0 |
| signed `x >> k` | usually sign bit |

Arithmetic right shift rounds toward $-\infty$, not toward 0. Thus `(-3)>>1 == -2` on the class model, while `-3/2 == -1` in C.

For signed division by $2^k$ rounding toward 0:

```c
x / (1<<k) == (x < 0 ? x + (1<<k)-1 : x) >> k
```

## 4. Integer Representation

### 4.1 Unsigned and Two's Complement

$$
B2U_w(x)=\sum_{i=0}^{w-1}x_i2^i
$$

$$
B2T_w(x)=-x_{w-1}2^{w-1}+\sum_{i=0}^{w-2}x_i2^i
$$

| 8b bits | unsigned | signed |
|---|---:|---:|
| `00000000` | 0 | 0 |
| `01111111` | 127 | 127 |
| `10000000` | 128 | -128 |
| `11111111` | 255 | -1 |

Other signed encodings:

| Encoding | Has +0 and -0? |
|---|---|
| sign-magnitude | yes |
| one's complement | yes |
| two's complement | no |
| IEEE FP | yes |

### 4.2 Signed <-> Unsigned

Bit pattern unchanged; interpretation changes.

$$
U = S \bmod 2^w =
\begin{cases}
S,&S\ge0\\
S+2^w,&S<0
\end{cases}
$$

> [!IMPORTANT]
> C comparison trap: `-1 < 0U` is false because `-1` becomes `UMax`.

Integer promotions:

```c
signed char c = -1;
unsigned int u = c;     // c -> int -1 -> unsigned 0xffffffff
```

### 4.3 Extension and Truncation

| Operation | Rule |
|---|---|
| zero extend | add high 0 bits |
| sign extend | replicate sign bit |
| truncate to k bits | keep low k bits; value mod $2^k$ then reinterpret |

## 5. Integer Arithmetic

### 5.1 Add/Sub/Overflow

Fixed-width arithmetic is modulo $2^w$.

Real C: signed overflow is undefined; unsigned overflow is defined mod $2^w$.

Unsigned addition:

$$
x +^u_w y = (x+y)\bmod 2^w
$$

Unsigned overflow tests:

| Op | Overflow/underflow test |
|---|---|
| `s = x+y` | `s < x` or `s < y` |
| `d = x-y` | `d > x` |

Signed add overflow:

```text
same sign operands && different sign result
overflow = !(sa ^ sb) && (sa ^ ss)
```

Subtraction: `a-b = a + (~b+1)`.

Two's-complement negation:

```text
-x = ~x + 1
-TMin = TMin
```

### 5.2 RISC-V Overflow Policy

- Integer ALU ops wrap silently; no condition-code register.
- Software must check if overflow matters.
- **Reason**: cheaper pipeline/precise-exception logic; unsigned wrap is useful.

### 5.3 Adders / SLT

One-bit full adder:

```text
sum = a ^ b ^ cin
cout = (a&b) | (a&cin) | (b&cin)
```

Carry-lookahead:

$$
g_i=A_iB_i,\quad p_i=A_i\oplus B_i,\quad C_{i+1}=g_i+p_iC_i
$$

Signed `SLT` from subtraction:

```text
set = sign(A-B) ^ overflow
```

### 5.4 Multiply / Divide

| Op | Cost idea |
|---|---:|
| add/logic | 1 cycle |
| int multiply | 3-5 cycles |
| int divide | ~32 cycles, hard to pipeline |

Project add/sub:

```c
sum_no_carry = a ^ b;
carry = (a & b) << 1;
sub(a,b) = add(a, add(~b,1));
```

## 6. Floating-Point Representation

### 6.1 Binary Fractions and Exactness

A decimal is exactly representable in binary iff, after reduction, denominator is $2^k$.

| Decimal | Exact? | Reason |
|---|---|---|
| `1.625` | yes | `13/8` |
| `1.405` | no | denominator has factor 5 |

### 6.2 IEEE Layout and Value

| Format | Layout | Bias |
|---|---|---:|
| fp32 | `s|exp8|frac23` | 127 |
| fp64 | `s|exp11|frac52` | 1023 |
| fp16 | `s|exp5|frac10` | 15 |
| bfloat16 | `s|exp8|frac7` | 127 |

`float` exactly represents all integers from `0` through $2^{24}$; above that, spacing exceeds 1.

Normalized:

$$
V=(-1)^s(1.f)_2 2^{e-Bias}
$$

Subnormal:

$$
V=(-1)^s(0.f)_2 2^{1-Bias}
$$

> [!NOTE]
> Subnormal/denormal uses exponent $1-Bias$, not $0-Bias$, so values are continuous at the normal/subnormal boundary.

### 6.3 FP Classes

| Exp | Frac | Class |
|---|---|---|
| all 0 | 0 | `+0` / `-0` |
| all 0 | nonzero | subnormal |
| 1..max-1 | any | normalized |
| all 1 | 0 | `+inf` / `-inf` |
| all 1 | nonzero | NaN |

fp32 constants:

| Hex | Value |
|---|---|
| `0x3f800000` | `1.0` |
| `0x40800000` | `4.0` |
| `0xc0800000` | `-4.0` |
| `0x7f800000` | `+inf` |

### 6.4 Custom Minifloat Template

For `s|k exp bits|n frac bits`, bias $B=2^{k-1}-1$ unless specified.

| Value asked | Formula |
|---|---|
| smallest positive subnormal | $2^{-n}2^{1-B}$ |
| largest subnormal | $(1-2^{-n})2^{1-B}$ |
| smallest normal | $1.0\cdot2^{1-B}$ |
| largest normal | $(2-2^{-n})2^{(2^k-2)-B}$ |

Example `s|eeee|fff`, bias 7:

| Bits | Value |
|---|---|
| `0 0000 001` | $1/8\cdot2^{-6}=1/512$ |
| `0 0001 000` | $1\cdot2^{-6}=1/64$ |
| `0 1110 111` | $(1+7/8)2^7=240$ |

FP halve/double bit-level pattern:

| Case | Divide by 2 |
|---|---|
| exp all 1 | unchanged NaN/inf |
| normalized exp > 1 | decrement exp |
| exp == 1 | becomes subnormal: shift hidden `1.frac` right |
| subnormal/zero | shift frac right; apply specified rounding |

For multiply by 2, increment exp for normals; subnormal may normalize when hidden bit appears.

## 7. FP Rounding, Ops, Casts

### 7.1 Rounding

Default: round to nearest, ties to even.

| Value | Rounded integer |
|---|---:|
| `12.5` | 12 |
| `13.5` | 14 |

IEEE rounding modes: nearest-even, toward 0, toward $+\infty$, toward $-\infty$.

### 7.2 FP Operation Traps

| Claim | Truth |
|---|---|
| `(X+Y)+Z == X+(Y+Z)` | not always |
| `X+Y == Y+X` | usually yes for finite normal add |
| `1/+0` / `1/-0` | `+inf` / `-inf` |
| `sqrt(-1)` | NaN |

`(3.14+1e10)-1e10` may be `0`, but `3.14+(1e10-1e10)=3.14`.

### 7.3 Casts

| Cast | Rule |
|---|---|
| `int -> float` | may round |
| `int -> double` | exact for 32b int |
| `float -> double` | exact |
| `double -> float` | may round/overflow/underflow |
| `float/double -> int` | rounds toward 0; overflow undefined/implementation-specific |

High-yield true statement: `A == (int)(double)A` for 32b `int A`.

### 7.4 FMA / bfloat16

FMA computes `a*b+c` with one final rounding. It is ~5-6 cycles because addend alignment overlaps product reduction and no intermediate normalize/round is needed.

Low precision on GPUs:

- more values per load/register/vector lane.
- higher compute and memory bandwidth.
- acceptable for approximate ML.

`bfloat16` beats fp16 for many ML uses because it keeps fp32's 8-bit exponent range.
