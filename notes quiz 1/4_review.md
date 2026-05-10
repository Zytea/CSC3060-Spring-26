# Lec 4: Calling Convention (Caller / Callee Save)

## Exam Facts

- ==**Calling convention**==: rules for **arg passing, return val, frame, save/restore, fp**.
- Args/returns: **a0-a7**; return val ==**a0**== (a1 too on RV32 for 64b).
- ==**Caller-saved**==: `ra, t0-t6, a0-a7`. Caller saves before call **only if value live across call**.
- ==**Callee-saved**==: `s0-s11, sp`. Callee saves at entry **only if it modifies them**.
- `sp` restored before return; ==RV-Linux stack alignment **16B**==.
- **Leaf** routine (no calls inside) → use `a/t`, often no frame.
- **Non-leaf with values live across calls** → use `s` (1 save+1 restore vs 2N around N calls).
- ==**Use cases**==:
  - **Caller-saved good for**: leaf routines, expression-eval temps.
  - **Callee-saved good for**: temps heavily used **across multiple calls**, ==**local scalar variables**==, CSEs reused across calls.
  - NOT for: arrays/strings (they live in memory).
- ==**Quiz**==: A calls B; `s1, t0, a1` live across B. **A saves/restores `t0` and `a1`** (caller-saved); `s1` is B's job.

## 1. Procedure Call Steps

1. Caller places args in `a0-a7`.
2. Caller saves any caller-saved regs needed after call.
3. `jal ra, callee` → `ra=PC+4`, jump.
4. Callee prologue: `addi sp,sp,-k`, save `ra` (if non-leaf), save `s` regs it modifies.
5. Callee computes; result in `a0`.
6. Callee epilogue: restore `s`/`ra`, deallocate frame, `ret`.
7. Caller restores any saved caller-saved regs.

## 2. Stack Layout

Stack grows **down**; `sp` = current top. Frame: saved `ra`, saved `s` regs, locals, spills, outgoing args, dynamic arrays.

`fp` (s0) optional; if used, stable anchor → locals via `imm(fp)`.

```
high
| caller frame  |
| outgoing args |
| saved ra      |
| saved s regs  |
| local vars    |
| spills        |  ← sp
low
```

## 3. RISC-V Procedure Support

- `jal ra, target`: save PC+4 to ra, jump.
- `ret = jalr x0, ra, 0`.
- Interop with libs/OS/external code requires **ABI compliance**.

## 4. Register Convention

| ABI | x-reg | Save |
|---|---|---|
| `zero` x0 | const 0 | — |
| `ra` x1 | return addr | **caller** |
| `sp` x2 | stack ptr | preserved |
| `gp/tp` x3/x4 | global/thread | preserved |
| `t0-t6` x5-7,28-31 | temps | **caller** |
| `s0(fp)/s1` x8-9 + `s2-s11` x18-27 | saved | **callee** |
| `a0-a7` x10-17 | args/ret | **caller** |

## 5. Caller-Saved (volatile)

> "Caller, save it if you need it after the call."

- Callee may clobber freely.
- Caller saves **only the live-across-call ones**.

```
addi sp,sp,-4
sw   t1,0(sp)
jal  ra, B
lw   t1,0(sp)
addi sp,sp, 4
```

## 6. Callee-Saved (non-volatile)

> "Callee, restore them if you touched them."

- Saved at entry, restored before return.
- 1 save + 1 restore total, regardless of inner-call count.

```
addi sp,sp,-8
sw   ra,4(sp)
sw   s1,0(sp)
mul  s1,a0,a1
jal  ra, B
jal  ra, C
add  a0,s1,s1
lw   s1,0(sp)
lw   ra,4(sp)
addi sp,sp, 8
ret
```

## 7. Cost Analysis

Value used before/between/after N calls:

| Class | Save/restore cost |
|---|---|
| Caller-saved | 2N (around each call) |
| Callee-saved | 2 (1 entry + 1 exit) |

⇒ Use **callee** when N≥2 in **hot path**.
> Calls in **cold path** (else of `if`) → **caller** is cheaper (saves only on cold path).

## 8. Allocation Rules

| Value type | Pick |
|---|---|
| Short-lived expr temp | `t`/`a` |
| Local scalar, long-lived | `s` |
| Live across multiple calls | `s` |
| CSE used across calls | `s` |
| Leaf routine | `t`/`a`, no save |
| Calls only in cold path | caller-saved |
| Arrays/strings/aggregates | **memory** |

## 9. Worked Examples

### 9.1 Nothing Live across Call

```
A:
    lw   t0,-4(fp)
    lw   t1,-8(fp)
    add  t2,t0,t1
    jal  ra, B          # nothing live across
    add  a0,a0,a0
    ret
```
> No save/restore needed.

### 9.2 Leaf Routine

> Use caller-saved liberally; no save/restore; often no frame.

### 9.3 A calls B; `s1, t0, a1` live across

| Reg | Class | Action |
|---|---|---|
| `s1` | callee | **B**'s job (if B modifies) |
| `t0`, `a1` | caller | **A** saves+restores around call |

==Answer: A saves/restores **`t0` and `a1`** only.==

### 9.4 Calls in Cold Path

```c
A():
  if (hot) { /* no calls */ }
  else { B(); C(); D(); }
```
Use **caller-saved** in A — saves only paid on else branch.
