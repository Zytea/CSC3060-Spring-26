# Lec 2: Data Representation

## Exam Facts

- ==**Word size**==: nominal pointer/reg size; RV32 = 32b (max 4GB), RV64 = 64b (max 16EB).
- ==**Byte ordering**==: addr of multi-byte object = **smallest** byte addr. LE (Intel/AMD/ARM/RV) vs BE (IBM/MIPS/SPARC, network).
- C int promotion: any unsigned ⇒ signed converted to unsigned.
- ==**2's comp**== range $[-2^{w-1},2^{w-1}-1]$; ==**`-INT_MIN == INT_MIN`**==.
- RV ==does NOT trap integer overflow==; SW/compiler must check; FP only sets a flag (poll).
- IEEE FP: sign | biased exp | frac. ==Normal hidden 1==, ==denormal NO hidden 1==.
- $k$-bit exp: ==**bias = $2^{k-1}-1$**==.
- FP `+`,`*` commutative but ==**NOT associative**==; compiler can't reassoc without `-ffast-math`.
- FP→int rounds **toward 0**; int→float may round but can't overflow; int(32b)→double exact.
- ==**FMA**==: `a*b+c`, ==**1 final rounding, 5-6 cyc**== (NOT 9; reduction overlaps FADD's exp align).
- ==**bfloat16**==: 1+**8**+7; same exp range as fp32; AI-friendly.
- **+0/-0 systems**: sign-magnitude, 1's comp, IEEE FP. **2's comp has only 1 zero**.
- Decimal $d$ exact in binary FP iff $d=p/q$ with $q$ power of 2 (1.625 ✓; 1.405/1.35/1.245/1.11 ✗).

## 1. Information Storage

### 1.1 Word size + Data sizes (LP64 won)

| Type | 32b | LP64 |
|---|---|---|
| `char/short/int` | 1/2/4 | 1/2/4 |
| `long` | **4** | **8** |
| `long long`, `int64_t` | 8 | 8 |
| `float/double` | 4/8 | 4/8 |
| `pointer` | **4** | **8** |

> `INT_MAX=0x7FFFFFFF=2^31-1`; `INT_MIN=0x80000000=-2^31`.

`gcc -m32` 32b code; `gcc -m64` requires 64b host.

### 1.2 Byte Ordering

- ==**Little-endian**== (Intel/AMD/ARM/RV): LSB at lowest addr.
- ==**Big-endian**== (IBM/MIPS/SPARC, network): MSB at lowest addr.

> Endian matters only when storing+reading with **different types/orders** (cross-machine, type-cast bytes, bit fields, asm reading).
> `int x=0x12345678` LE bytes `78 56 34 12`; raw to BE machine reads as `0x78563412`.

### 1.3 Strings

C string = char array + `'\0'`. ASCII `'0'=0x30`. `"12345"` = `31 32 33 34 35 00`. Text portable; binary not (different ABI).

### 1.4 Bitwise / Logical / Shift

- Bitwise `& | ^ ~` per-bit; logical `&& || !` truth-value, **short-circuit** (`if(p && p->next)` safe).
> [!IMPORTANT] `A && B` ≠ `A & B`. With A=2, B=1: `&&`→true, `&`→0.
- ==Logical `>>`== fills 0 (unsigned); ==arithmetic `>>`== replicates sign (signed).
- C unsigned `>>` logical; signed `>>` impl-defined (typically arithmetic on x86/RV).
- `x << k`: low-k bits 0; high overflow discarded.

## 2. Integer Representation

==Unsigned==: $B2U_w(\vec{x})=\sum x_i 2^i$, range $[0,2^w-1]$.
==**2's comp**==: $B2T_w(\vec{x})=-x_{w-1}2^{w-1}+\sum_{i<w-1}x_i 2^i$.

> Why 2's comp: 1 zero, no end-around carry, same HW for signed/unsigned add.

### 2.1 Signed↔Unsigned Conversion

$$U=S\bmod 2^w,\quad U=\begin{cases}S, & S\ge 0\\ S+2^w, & S<0\end{cases}$$

> [!IMPORTANT] If any operand is unsigned, the other converts to unsigned. So `-1 < 0u` is **false**.

> ==**`-INT_MIN == INT_MIN`**== (no positive twin); signed overflow is UB in C ⇒ compiler may optimize assuming impossible; unsigned wrap is well-defined.

### 2.2 Sign Extend / Truncate

- **Sign-extend**: replicate sign bit into new high bits.
- **Truncate**: drop high bits, then reinterpret. Signed: $T_k(x)=U2T_k(x\bmod 2^k)$.

## 3. Integer Arithmetic

- Unsigned add wraps mod $2^w$; overflow iff `sum < x`.
- Signed add: same HW; overflow iff **same-sign operands → opposite-sign result**.
- `x - y = x + (~y + 1)`.
- Carry-add (no `+`): `sum=a^b`, `carry=(a&b)<<1`; loop until carry=0.
> Quiz: `(a&b)<<1` = carry-bits-next-iter; `sub(a,b)=add(a, add(~b,1))`.

```c
x && (x*y)/x != y          // mul ovf
y != 0 && (x/y)*y != x     // div ovf (e.g., INT_MIN/-1)
```

> [!NOTE] Why RV omits HW overflow trap: traps expensive, overflow rare, OoO complexity, unsigned wrap intentional. ==**Precise exception**==: cleanly stoppable+restartable; easier when arch state updates **in-order**.

### 3.1 ALU mini-facts

- 1-bit full adder: $S=A\oplus B\oplus C_{in}$.
- ==**RCA**==: O(n) carry chain; ==**CLA**==: $g_i=A_iB_i$, $p_i=A_i\oplus B_i$ → O(log n).
- ALU `AND/OR/ADD/SLT` via `Ainvert/Bnegate/CarryIn`. SLT MSB: `Sum_{31}⊕Overflow`.
- Faster multiplier = **adder tree, O(log n)**.
- Power-of-2 div (signed): bias before shift: $x/2^k = (x<0\,?\,x+(1\ll k)-1:x) \gg k$.

## 4. Floating-Point Representation

$$x=(-1)^s\cdot M\cdot 2^E$$

| Format | s | exp | frac | bias |
|---|---|---|---|---|
| Quad | 1 | 15 | 112 | 16383 |
| Double (fp64) | 1 | 11 | 52 | 1023 |
| Single (fp32) | 1 | 8 | 23 | 127 |
| fp16 (Half) | 1 | 5 | 10 | 15 |
| ==**bfloat16**== | 1 | **8** | 7 | 127 |
| fp8 / fp4 | 1 | 4/2 | 3/1 | 7/1 |

==**bias = $2^{k-1}-1$**==.

### 4.1 Class table (fp32)

| exp `e` | frac `f` | Class | Value |
|---|---|---|---|
| 0 | 0 | ±0 | 0 |
| 0 | nz | ==**denorm**== (no hidden 1) | $(-1)^s(0.f)2^{1-bias}$ |
| 1..2^k-2 | any | ==**normal**== (hidden 1) | $(-1)^s(1.f)2^{e-bias}$ |
| all-1 | 0 | ±∞ | |
| all-1 | nz | NaN | |

> Denorm $E=1-\text{bias}$ (NOT $-\text{bias}$). More exp → larger range; fewer frac → less precision.

### 4.2 fp32 hex decode

> Quiz1 #4: `F1=0x40800000` → `0|10000001|0…` E=2,M=1.0 → **+4.0**; `F2=0x3F800000`=+1.0; `F3=0xC0800000`=−4.0. `F1+F3=0`✓; `F3<F2<F1`✓; `F2=F1/F3=-1≠1`✗; `F3=-(F1*F2)=-4`✓ → **A,B,D**.

### 4.3 Custom 8b FP (4exp+3frac, bias=7)

| | bits | E | M | value |
|---|---|---|---|---|
| smallest +denorm | `0 0000 001` | -6 | 1/8 | $1/512$ |
| largest denorm | `0 0000 111` | -6 | 7/8 | $7/512$ |
| smallest normal | `0 0001 000` | -6 | 1 | $1/64$ |
| one | `0 0111 000` | 0 | 1 | 1.0 |
| largest normal | `0 1110 111` | 7 | 15/8 | 240 |

> ULP for normals = $2^{E-(p-1)}$. fp32 exact integers in $[0, 2^{24}]$; beyond loses precision (`123456789` → `123456792`).

### 4.4 Rounding

4 IEEE modes: ==**round-to-even (default), toward 0, down, up**==. Tie → pick value with **LSB=0**.

> 12.5 → 12; 13.5 → 14; 1.875 in 2-frac → 10.00 (=2.0).

### 4.5 FP Operations

- `1/+0=+∞`, `1/-0=-∞`, `sqrt(-1)=NaN`.
- Commutative ✓; **NOT associative**: `(3.14+1e10)-1e10=0`; `3.14+(1e10-1e10)=3.14`.
> [!IMPORTANT] CSE on `(a+b+c+d)` and `(a+d+b+c)` legal for ==**integer (`long long`, `char`, `int`)**==, NOT float/double.

### 4.6 Type Casts

- int→float: may round, can't overflow.
- int(32b)→double: exact.
- float→double: exact.
- double→float: round / overflow→±∞.
- float/double→int: ==**rounds toward 0**==; overflow result not portable (Intel: `0x80000000`).

### 4.7 FP Add Steps

1. **Align** exp (shift smaller mantissa right).
2. **Add** significands.
3. **Normalize**.
4. **Round** (round-to-even).

## 5. FP Units

| Op | Latency (cyc) |
|---|---|
| FADD | 3-4 |
| FMUL | 4-5 |
| ==**FMA**== | **5-6** |
| FP→int | 3-5 |
| int mul | 3-5 |
| int div | ~32 (hard to pipeline) |

==**FMA (R4-type)**== `a*b+c`: 1 instr, ==**1 final rounding**==.

> Why FMA 5-6 not 9: FMUL's reduction stage runs **in parallel with FADD's exp align**; product needs no normalize/round before final add. Saves ~3 cyc.

> R4 = 3src+1dst. 3-operand alt `rd=rs1*rs2+rd` works for dot-product but rd is both src+dst → ==breaks regularity== (extra read port for rd).

### 5.1 Why GPUs use bf16 / fp16

- Higher BW + throughput (1 double-load = 4 bf16; AVX-512 = 32 bf16/cyc).
- AI is approximate ⇒ precision loss tolerable.
- ==**bf16 > fp16**== because 8-bit exp = fp32 range; fp16 only 5-bit exp → narrow range, easy overflow; bf16 also more compatible with fp32.

## 6. Quiz Trap Cheat-Notes

- 128 all-0 bits: 4× fp32 +0.0, 2× DP zeros — **NOT necessarily 1 quad-FP** without format.
- `"0000"` = `0x30 0x30 0x30 0x30`, NOT all-zero.
- Exact decimal in FP ↔ denominator (reduced) is power of 2.
- `(X+Y)+Z == X+(Y+Z)` not always true for FP.
- `(A<0) ⇒ -A>0` **false** when A=`INT_MIN`.
- `(x*x) >= 0` **false** if overflow (e.g., `0xFFFF * 0xFFFF` as int).
- `x+y == ux+uy` **true** (same bit-level behavior).
- `A == (int)(double)A` true for 32b int (53b precision); not for 64b long.
