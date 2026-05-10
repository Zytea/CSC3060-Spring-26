# Lec 4: Calling Convention & Caller/Callee Save Registers

## Exam Facts

- ==**Calling convention**==: rules for args, returns, stack, frame pointer, and caller/callee-saved regs so separately compiled code can interoperate.
- RISC-V call: `jal ra,func`; return: `jalr x0,ra,0` (`ret`).
- `a0-a7`: first 8 args; `a0/a1`: return values; all are caller-saved.
- `ra`, `t0-t6`, `a0-a7` are **caller-saved**: caller saves them if live across a call.
- `sp`, `s0-s11` are **callee-saved**: callee restores if it modifies them.
- Leaf routine calls no other function; usually uses caller-saved/temp regs and may avoid stack frame.
- Values live across many calls: prefer callee-saved regs. Short temporaries or values live only across rare calls: caller-saved may be cheaper.
- Stack grows downward; RISC-V Unix ABI stack is 16B aligned at call boundaries.

## 1. Procedure Call Steps

Typical function call:

1. Caller places args in `a0-a7`; extra args go on stack.
2. Caller saves live caller-saved regs if their values are needed after the call.
3. Caller executes `jal ra,callee`.
4. Callee allocates frame, saves `ra` if it will call another function, saves callee-saved regs it will modify.
5. Callee executes body.
6. Callee writes return value to `a0/a1`.
7. Callee restores saved regs/frame and returns with `ret`.
8. Caller restores caller-saved regs and consumes return value.

## 2. Stack Allocation Before/During/After Call

Stack frame may contain:

- outgoing/incoming stack arguments.
- return address `ra` if saved.
- old frame pointer `s0/fp`.
- saved callee-saved regs.
- local scalar spills.
- local arrays/dynamic allocation.

Before call: caller frame active. During callee: `sp` moves down to allocate callee frame. After return: `sp` is restored to pre-call value.

## 3. Frame Allocation

Frame pointer `fp`/`s0` is optional but useful when stack offsets are not fixed or debugging needs a stable base. `sp` points to current stack top and may move for dynamic allocation.

Common prologue/epilogue shape:

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

Stack accesses during procedure calls support:

- parameter passing beyond `a0-a7`.
- return address storage.
- save/restore of regs.
- local variables and spills.
- return value handling.

If code calls external libraries/APIs, it must obey ABI. Self-contained assembly can ignore convention internally, but any boundary with other code must follow it.

## 5. RISC-V Register Convention

| x-reg | ABI | Role | Saved by |
|---|---|---|---|
| x0 | `zero` | constant 0 | fixed |
| x1 | `ra` | return address | caller |
| x2 | `sp` | stack pointer | callee |
| x3 | `gp` | global pointer | platform |
| x4 | `tp` | thread pointer | platform |
| x5-x7 | `t0-t2` | temporaries | caller |
| x8 | `s0/fp` | saved/frame ptr | callee |
| x9 | `s1` | saved | callee |
| x10-x17 | `a0-a7` | args/return | caller |
| x18-x27 | `s2-s11` | saved | callee |
| x28-x31 | `t3-t6` | temporaries | caller |

## 6. Caller-Saved Registers

==**Caller-saved**== means: callee may clobber the register. If caller needs its old value after a call, caller must save it before the call and restore it after.

Caller-saved regs:

- `ra`
- `t0-t6`
- `a0-a7`

Good for:

- short-lived temporaries.
- expression evaluation.
- leaf routines.
- values not live across calls.
- values live only across rare/cold calls.

Example: `t0` and `a1` are live across call to `B`.

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

==**Callee-saved**== means: if callee modifies the register, callee must restore its original value before returning.

Callee-saved regs:

- `sp`
- `s0-s11`

Good for:

- local scalar variables live for most of a function.
- values live across many calls.
- common subexpressions reused across calls.
- non-leaf functions with long-lived state.

Example: function uses `s1`.

```asm
addi sp,sp,-16
sw   s1,12(sp)
...
lw   s1,12(sp)
addi sp,sp,16
ret
```

## 8. Ideal World vs Real World

Idealized:

- caller would use callee-saved regs so callees preserve its values.
- callee would use caller-saved regs so it does not need a prologue/epilogue save.

Real code is often both caller and callee. Register choice is a cost decision based on live ranges and call frequency.

## 9. Caller or Callee Save? Cost Analysis

If value `v` is live across `m` calls:

| Strategy | Memory operations |
|---|---:|
| caller-saved | `2m`: save+restore around each call |
| callee-saved | `2`: save once in prologue, restore once in epilogue if modified |

If calls are frequent and `v` is long-lived, callee-saved is cheaper. If call is rare/cold, caller-saved can be cheaper because save/restore executes only on that path.

Example:

```c
Function A():
    v = a*b;
    B(1,2,3);
    C(4,a);
    D(x,y);
    use(v);
```

If `v` in a caller-saved `t` register: 3 calls -> 3 saves + 3 restores = 6 memory ops.

If `v` in a callee-saved `s` register: save once at entry, restore once at exit = 2 memory ops.

## 10. General Register Allocation Rules

| Situation | Preferred regs | Reason |
|---|---|---|
| leaf routine temps | `t`, `a` caller-saved | no nested call clobbers them |
| short expression temps | caller-saved | cheap, short live range |
| args/return | `a0-a7` | ABI |
| local scalar live whole function | `s` callee-saved | one save/restore |
| value live across many calls | `s` callee-saved | avoids repeated caller spills |
| value live across one rare call | caller-saved around cold path | avoid prologue cost on hot path |
| common subexpression reused across calls | `s` callee-saved | long live range |

## 11. Worked Examples

### 11.1 Nothing Live Across Call

```asm
lw  t0,-4(fp)
lw  t1,-8(fp)
add t2,t0,t1
sw  t2,-12(fp)
jal ra,B
add a0,a0,a0
ret
```

No pre-call save is needed if no caller-saved value is needed after `B`. `a0` is overwritten by return value intentionally.

### 11.2 Leaf Routine

A leaf function calls nobody. It can use `t` and `a` regs freely unless it must preserve ABI-visible callee-saved regs it chooses to modify.

### 11.3 A Calls B; `s1`, `t0`, `a1` Live Across

- `t0`: caller-saved -> A saves/restores if A needs it after B.
- `a1`: caller-saved -> A saves/restores if A needs it after B.
- `s1`: callee-saved -> A does not save solely because of B; B must restore if B modifies `s1`.

### 11.4 Calls in Cold Path

```c
if (likely) {
    // no calls
} else {
    B();
    C();
    D();
}
```

Use caller-saved regs for values live across the cold calls if it avoids a prologue/epilogue cost on every invocation.

## 12. Summary

- Correctness: preserve ABI promises across function boundaries.
- Performance: choose caller/callee-saved based on live range and call frequency.
- Stack is used for spills, saved regs, return addresses, old frame pointer, locals, and extra args.
- Leaf functions often need no stack frame; non-leaf functions usually save `ra`.
