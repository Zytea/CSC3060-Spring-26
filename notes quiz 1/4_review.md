# Lec 4: Calling Convention & Caller/Callee Save Registers

## Exam Facts

- ==**Calling convention**==: ABI rules for args, returns, stack, frame pointer, saved regs.
- **Call/return**: `jal ra,func`; return = `jalr x0,ra,0` (`ret`).
- **Args/returns**: `a0-a7` = first 8 args; `a0/a1` = returns; all are caller-saved.
- ==**Caller-saved**==: `ra`, `t0-t6`, `a0-a7`; caller saves if value is live across a call.
- ==**Callee-saved**==: `sp`, `s0-s11`; callee restores if it modifies.
- **Leaf routine**: calls no function; often no stack frame.
- **Register choice**: values live across many calls -> `s` regs; short temps -> caller-saved.
- **Stack rule**: RISC-V Unix ABI stack is **16B aligned** at call boundaries; stack grows downward.

## 1. Procedure Call Steps

1. Caller puts args in `a0-a7`; extra args on stack.
2. Caller saves live caller-saved regs if needed after call.
3. Caller executes `jal ra,callee`.
4. Callee allocates frame; saves `ra` if non-leaf; saves modified `s` regs.
5. Callee computes; returns value in `a0/a1`.
6. Callee restores frame/regs and `ret`.
7. Caller restores its saved caller-saved regs.

## 2. Stack Allocation Before/During/After Call

Stack frame may contain:

- saved `ra`, old `s0/fp`, saved `s` regs.
- local arrays/spills.
- outgoing/incoming stack args.
- alignment padding.

Call lifetime:

| Time | Stack responsibility |
|---|---|
| before call | caller saves live caller-saved regs and places extra args |
| during callee | callee saves modified `s` regs/`ra`, allocates locals |
| after return | callee restored its frame; caller restores its own saved temps |

> [!IMPORTANT]
> **Stack security**: stack frame stores local data plus control data (`ra`, old `fp/s0`, saved regs). An unchecked stack-buffer write can overwrite saved `ra` and hijack control flow.

```text
high addr
caller frame
extra args / saved caller regs
callee saved ra/s0/s-regs
locals/spills
low addr  <- sp after allocation
```

## 3. Frame Allocation

`sp` moves; `fp`/`s0` gives stable base for debugging/dynamic stack offsets.

Typical non-leaf prologue:

```asm
addi sp,sp,-16
sw   ra,12(sp)
sw   s0,8(sp)
addi s0,sp,16
...
lw   s0,8(sp)
lw   ra,12(sp)
addi sp,sp,16
ret
```

## 4. RISC-V Procedure Support

RISC-V supplies:

- `jal/jalr` for link/return.
- `sp` for stack frames.
- ABI register roles.
- loads/stores for saved regs and stack args.

Self-contained assembly may ignore ABI internally, but any boundary with C/libraries must obey it.

## 5. RISC-V Register Convention

| x-reg | ABI | Role | Saved by |
|---|---|---|---|
| x0 | `zero` | constant 0 | fixed |
| x1 | `ra` | return address | caller |
| x2 | `sp` | stack pointer | callee |
| x3 | `gp` | global pointer | platform |
| x4 | `tp` | thread pointer | platform |
| x5-x7 | `t0-t2` | temps | caller |
| x8 | `s0/fp` | saved/frame ptr | callee |
| x9 | `s1` | saved | callee |
| x10-x17 | `a0-a7` | args/returns | caller |
| x18-x27 | `s2-s11` | saved | callee |
| x28-x31 | `t3-t6` | temps | caller |

## 6. Caller-Saved Registers

==**Caller-saved**==: callee may clobber; caller saves old value if it needs it after call.

Good for:

- leaf routine temps.
- expression temporaries.
- values not live across calls.
- values live only across rare/cold calls.

Example: `t0` and `a1` live across `B`:

```asm
addi sp,sp,-8
sw   t0,4(sp)
sw   a1,0(sp)
jal  ra,B
lw   a1,0(sp)
lw   t0,4(sp)
addi sp,sp,8
```

## 7. Callee-Saved Registers

==**Callee-saved**==: if callee modifies it, callee restores original before return.

Good for:

- local scalar live most of function.
- value live across many calls.
- CSE/reused value spanning calls.

Example callee using `s1`:

```asm
addi sp,sp,-16
sw   s1,12(sp)
...
lw   s1,12(sp)
addi sp,sp,16
ret
```

## 8. Ideal World vs Real World

| Role | Tempting choice | Real rule |
|---|---|---|
| caller wants values preserved | `s` regs | good if long-lived |
| callee wants no save/restore | `t/a` regs | good if temporary |
| both caller and callee | cost model | depends on live range + call frequency |

## 9. Caller or Callee Save? Cost Analysis

If value `v` is live across `m` calls:

| Strategy | Memory ops |
|---|---:|
| caller-saved | `2m` |
| callee-saved | `2` if modified |

> [!IMPORTANT]
> A function `A` calling `B`: if `s1`, `t0`, `a1` are live across the call, `A` saves `t0,a1`; `B` is responsible for preserving `s1`.

## 10. General Register Allocation Rules

| Situation | Prefer |
|---|---|
| args/returns | `a0-a7` |
| short expression temps | `t` / caller-saved |
| leaf routine temps | caller-saved |
| local scalar live across function | `s` |
| value live across many calls | `s` |
| value live across one cold call | caller save in cold path |

## 11. Worked Patterns

| Pattern | Save/alloc answer |
|---|---|
| no values live across call | save none |
| leaf routine | prefer caller-saved `t/a`; often no frame |
| non-leaf using `ra` later | save `ra` |
| long-lived local/CSE across many calls | use `s` register |
| value live across rare/cold call | caller-save in cold path |

Quiz allocation anchors:

| Ask | Answer |
|---|---|
| caller-saved considered | leaf routines; expression temps |
| callee-saved considered | temp heavily live across multiple calls; local variables |
| `A` calls `B`, live regs `s1,t0,a1` | `A` saves/restores `t0,a1`; `B` preserves `s1` |

### 11.1 Leaf Routine

No nested calls -> can often use `t`/`a` regs and return without stack frame, unless it needs local spills or modifies `s` regs.

### 11.2 Non-Leaf

If a function calls another function and needs its own return address later, it must save `ra`.

### 11.3 Nothing Live Across Call

No caller-saved register needs saving if its value is dead at the call or intentionally overwritten by return value.

## 12. Summary

- **Correctness**: obey ABI at module/function boundaries.
- **Performance**: choose saved class by live range and call frequency.
- Stack stores saved regs, return address, locals, spills, and extra args.
