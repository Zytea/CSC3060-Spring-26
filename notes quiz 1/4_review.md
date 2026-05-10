# Lec 4: Calling Convention (Caller / Callee Save)

## Exam Facts

- ==**Calling convention**== = rules for **arg passing, return value, stack frame, save/restore, frame pointer**.
- Args/returns: **a0–a7** (x10–x17). Return value in **a0** (a1 too on RV32 for 64b).
- ==**Caller-saved**==: `ra (x1), t0–t6 (x5–x7,x28–x31), a0–a7 (x10–x17)` — caller saves before call **if value live across call**; callee may freely clobber.
- ==**Callee-saved**==: `s0–s11 (x8–x9, x18–x27), sp (x2)` — callee must save/restore if it uses them.
- `sp` must be restored before return; **RV-Linux stack alignment = 16B** at calls.
- **Leaf routine** (no calls inside) → prefer `a/t` regs, often no stack frame needed.
- **Non-leaf with values live across calls** → prefer `s` regs (1 save + 1 restore vs N save+restore around N calls).
- **Quiz rule**: A calls B; in A, regs `s1, t0, a1` live across the call. **A must save/restore `t0` and `a1`** (caller-saved). `s1` is B's responsibility if B clobbers it.
- **Use cases**:
  - **Caller-saved** good for: leaf routines, expression-evaluation temporaries.
  - **Callee-saved** good for: **temp values heavily used across multiple calls**, **local (scalar) variables** that survive call(s), CSEs reused across calls.
  - **NOT for**: arrays/strings (live in memory, not regs).
- Frame pointer (`fp = s0`) is **optional** but useful for stable frame references when frame size grows dynamically.

## 4.1 Procedure Call Steps

1. **Caller** places arguments in `a0–a7` (extras spill to stack).
2. **Caller** saves any live caller-saved regs needed after call.
3. `jal ra, callee` → saves PC+4 to `ra`, jumps.
4. **Callee** prologue: allocates frame (`addi sp, sp, -k`), saves `ra` (if it itself calls), saves any `s` regs it modifies.
5. Callee computes; result in `a0`.
6. **Callee** epilogue: restores `s` regs and `ra`, deallocates frame, `ret` (= `jalr x0, ra, 0`).
7. Caller restores any saved caller-saved regs.

## 4.2 Stack Layout

- Stack grows **downward**; `sp` points to current top.
- **Frame** typically contains:
  - saved `ra` (if non-leaf),
  - saved `s` regs the callee uses,
  - local variables / spilled temporaries,
  - outgoing stack args (when args > 8 or large structs),
  - dynamic arrays (`alloca`).
- `fp` (s0) — optional; if used, points to a stable anchor in the frame so locals can be `imm(fp)`.

```
high addr
+----------------+   <- caller's frame
| caller's stuff |
+----------------+   <- old sp on entry
| outgoing args  |
| saved ra       |
| saved s regs   |
| local vars     |
| spills         |
+----------------+   <- new sp (current top)
low addr
```

## 4.4 RISC-V Procedure Support

- `jal ra, target`: save PC+4 to ra, jump to target.
- `ret` = `jalr x0, ra, 0`.
- For interop with libraries / OS / external code, **must follow ABI**.
- Self-contained code may diverge from convention but loses interop.

## 4.6 Register Convention Table

| ABI | x-reg | Role | Save Rule |
|---|---|---|---|
| `zero` | x0 | constant 0 | — |
| `ra` | x1 | return address | **caller-saved** |
| `sp` | x2 | stack pointer | preserved (callee restores) |
| `gp` | x3 | global pointer | preserved |
| `tp` | x4 | thread pointer | preserved |
| `t0–t2` | x5–x7 | temporaries | **caller-saved** |
| `s0/fp` | x8 | saved / frame pointer | **callee-saved** |
| `s1` | x9 | saved | **callee-saved** |
| `a0–a1` | x10–x11 | args / **return value** | **caller-saved** |
| `a2–a7` | x12–x17 | args | **caller-saved** |
| `s2–s11` | x18–x27 | saved | **callee-saved** |
| `t3–t6` | x28–x31 | temporaries | **caller-saved** |

## 4.7 Caller-Saved (volatile)

> "**Caller, save it if you need it after the call.**"

- Callee may clobber freely.
- Caller saves *only* the live ones it needs after the call.

```asm
# A calls B; A needs t1 across the call
addi sp, sp, -4
sw   t1, 0(sp)
jal  ra, B
lw   t1, 0(sp)
addi sp, sp,  4
```

**Best for**:
- short-lived temps (expression evaluation),
- leaf routines (often no save needed at all),
- if calls are rare / on a cold path.

## 4.8 Callee-Saved (non-volatile)

> "**Callee, restore them if you touched them.**"

- Callee saves at entry (only ones it uses), restores before return.
- One save + one restore total, regardless of how many calls happen inside.

```asm
# A uses s1 across multiple inner calls
addi sp, sp, -8
sw   ra, 4(sp)
sw   s1, 0(sp)
mul  s1, a0, a1
jal  ra, B
jal  ra, C
jal  ra, D
add  a0, s1, s1
lw   s1, 0(sp)
lw   ra, 4(sp)
addi sp, sp, 8
ret
```

**Best for**:
- values **live across multiple calls**,
- **local scalar variables** with long lifetime,
- common subexpressions reused across calls.

## 4.9 Ideal vs Real

- *Ideal world*: caller uses only callee-saved → caller never saves. Callee uses only caller-saved → callee never saves. Reality: every function is **both** caller and callee.
- ⇒ allocator must decide register class per value based on **lifetime + call frequency**.

## 4.10 Cost Analysis

For a value used **before, between, and after N calls**:

| Class | Save/restore cost |
|---|---|
| Caller-saved (`t`/`a`) | 2N (save+restore around each call) |
| Callee-saved (`s`) | 2 (one save at entry, one restore at exit) |

⇒ Use **callee-saved** when N ≥ 2 with calls in the hot path.

But: if calls are in a **rare/cold path** (e.g., else-branch of an `if`), caller-saved can be cheaper because saves are *only paid* on the rare path.

## 4.11 Allocation Rules

| Rule | Pick |
|---|---|
| Short-lived expression temporary | `t` / `a` |
| Local scalar var, long-lived inside function | `s` |
| Value live across multiple calls | `s` |
| CSE used across calls | `s` |
| Leaf routine (no inner calls) | `t` / `a`, no save |
| Calls inside cold path only | caller-saved (saves paid only on cold path) |
| Arrays / strings / aggregates | **memory**, not registers |

## Worked Examples

### Ex 1: No values live across call

```asm
A:
    lw   t0, -4(fp)
    lw   t1, -8(fp)
    add  t2, t0, t1
    sw   t2, -12(fp)
    jal  ra, B          # nothing live across this call
    add  a0, a0, a0
    ret
```

> No save/restore needed (no value live across `B`).

### Ex 2: Leaf routine

> Use caller-saved (`t`/`a`) liberally; **no save/restore needed at all**. Often no stack frame.

### Ex 3: Quiz pattern (A calls B; `s1, t0, a1` live across)

| Reg | Class | Action |
|---|---|---|
| `s1` | callee-saved | **B** saves/restores if it modifies; A doesn't need to |
| `t0` | caller-saved | **A must save/restore** around the call |
| `a1` | caller-saved | **A must save/restore** around the call |

**Answer**: A saves/restores `t0` and `a1` only.

### Ex 4: Calls in cold path only

```c
A():
    if (hot_path) { /* no calls */ }
    else { B(); C(); D(); }   // rare
```

Use **caller-saved** in A — saves are only executed on the rare else-branch.

## Summary Cheat Sheet

| Question | Answer |
|---|---|
| Args | a0–a7 |
| Return | a0 (a1) |
| Return addr | ra (caller-saved) |
| Stack ptr | sp |
| Temps | t0–t6 (caller-saved) |
| Saved | s0–s11 (callee-saved) |
| Stack align (RV-Linux) | **16B** |
| `ret` | `jalr x0, ra, 0` |
| Result reg | **a0** |

> [!IMPORTANT] Quiz mantra:
> - **Caller** saves caller-saved regs before a call (only ones live after).
> - **Callee** saves callee-saved regs at entry (only ones it modifies) and restores at exit.
