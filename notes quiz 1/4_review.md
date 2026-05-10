# Lec 4: Calling Convention (Caller / Callee Save)

## Exam Facts

- ==**Calling convention**==: rules for args, returns, stack, register save/restore, frame setup/cleanup.
- RISC-V args: `a0-a7`; returns: `a0`/`a1`; call: `jal ra,func`; return: `jalr x0,ra,0`.
- ==Caller-saved==: `ra`, `t0-t6`, `a0-a7`. Callee may clobber them.
- ==Callee-saved==: `sp`, `s0-s11`. Callee must restore if modified.
- Stack grows down; RISC-V Unix ABI stack alignment at calls: **16B**.
- Leaf routine: prefer caller-saved/temp regs; no call means no caller-save spill needed for call preservation.
- Long-lived values across many calls: prefer callee-saved regs. Short temporaries: caller-saved.
- If function A calls B and `t0/a1` are live across the call, A must save/restore them. If `s1` is live, B must preserve it only if B changes it; A need not save it just because of call.

## 1. Procedure Call Steps

![](assets/4.1.png)

Typical call flow:

1. Caller places args in `a0-a7` and/or stack.
2. Caller saves live caller-saved regs if needed.
3. Caller executes `jal ra,callee`.
4. Callee allocates frame and saves callee-saved regs it will modify.
5. Callee computes return value in `a0`/`a1`.
6. Callee restores frame/registers and returns with `ret`.
7. Caller reads return value and restores saved caller-saved regs.

## 2. Stack Layout

![](assets/4.2.png)

Stack grows toward lower addresses. A frame may contain:

- outgoing/incoming stack args beyond `a0-a7`.
- saved `ra` and old `fp/s0`.
- local variables/spills.
- saved callee-saved registers.
- dynamic arrays (`alloca`/VLA).

> [!IMPORTANT]
> `sp` must be restored before return; `s0/fp` is optional but useful for stable offsets.

## 3. RISC-V Procedure Support

| Mechanism | Instr/reg |
|---|---|
| Call | `jal ra, target` |
| Return | `ret` = `jalr x0, ra, 0` |
| Stack pointer | `sp` (`x2`) |
| Frame pointer | `s0/fp` (`x8`) |
| Return address | `ra` (`x1`) |

Example prologue/epilogue:

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

## 4. Register Convention

| ABI | x-reg | Meaning | Save rule |
|---|---|---|---|
| `zero` | x0 | 0 | fixed |
| `ra` | x1 | return address | caller |
| `sp` | x2 | stack pointer | callee |
| `gp` | x3 | global pointer | platform |
| `tp` | x4 | thread pointer | platform |
| `t0-t2` | x5-x7 | temporaries | caller |
| `s0/fp` | x8 | saved/frame pointer | callee |
| `s1` | x9 | saved | callee |
| `a0-a7` | x10-x17 | args/returns | caller |
| `s2-s11` | x18-x27 | saved | callee |
| `t3-t6` | x28-x31 | temporaries | caller |

## 5. Caller-Saved (Volatile)

==Caller-saved== means: if caller needs the value after a call, caller saves it before the call and restores after.

Includes: `ra`, `t0-t6`, `a0-a7`.

Good for:

- short-lived temporaries.
- expression evaluation.
- leaf routines.
- values not live across calls.
- values live only across rare/cold calls if saving in cold path is cheaper.

Example:

```asm
; t0 and a1 are live across call to B
addi sp,sp,-8
sw   t0,4(sp)
sw   a1,0(sp)
jal  ra,B
lw   a1,0(sp)
lw   t0,4(sp)
addi sp,sp,8
```

## 6. Callee-Saved (Non-Volatile)

==Callee-saved== means: callee must restore original value if it modifies the register.

Includes: `sp`, `s0-s11`.

Good for:

- local scalar variables that live through most of a function.
- CSE/common values reused across multiple calls.
- loop variables/live values in non-leaf routines.

Example:

```asm
# function uses s1
addi sp,sp,-16
sw   s1,12(sp)
...
lw   s1,12(sp)
addi sp,sp,16
ret
```

## 7. Cost Analysis

If value `v` is live across `m` calls:

| Register choice | Save/restore cost |
|---|---|
| caller-saved | `2m` memory ops if saved around each call |
| callee-saved | 2 memory ops in function prologue/epilogue if modified |

> Use callee-saved when `v` survives many calls; use caller-saved when `v` is temporary or calls are rare.

## 8. Allocation Rules

| Case | Prefer |
|---|---|
| leaf routine temporaries | caller-saved (`t`, `a`) |
| expression temps | caller-saved |
| value live across one rare call | caller-saved around cold path |
| local scalar live across whole function | callee-saved (`s`) |
| value live across many calls | callee-saved |

## 9. Worked Examples

### 9.1 Nothing Live Across Call

```asm
lw  t0,-4(fp)
lw  t1,-8(fp)
add t2,t0,t1
sw  t2,-12(fp)
jal ra,B
add a0,a0,a0
```

No pre-call save is needed if no caller-saved value is needed after `B`.

### 9.2 Leaf Routine

A leaf function calls nobody. It can use caller-saved regs freely unless it must preserve values for its own caller by convention.

### 9.3 A Calls B; `s1`, `t0`, `a1` Live Across

- `t0`: caller-saved -> A saves/restores if needed after B.
- `a1`: caller-saved -> A saves/restores if needed after B.
- `s1`: callee-saved -> A does not save solely because of B; B must restore if B modifies `s1`.

Quiz answer: save/restore ==**`t0` and `a1`**== across the call.

### 9.4 Calls in Cold Path

If calls happen only in a rare `else`, caller-saved may be cheaper: save only on the cold path instead of every invocation.
