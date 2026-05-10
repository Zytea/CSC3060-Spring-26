# Chapter 4: Calling Convention

## Exam Facts

- ==**Calling convention**==: rules for **args, returns, stack frame, register save/restore, frame pointer**.
- Args/returns: `a0-a7`; return value in `a0`.
- ==**Caller-saved**==: `ra`, `t0-t6`, `a0-a7`; caller saves if live across call.
- ==**Callee-saved**==: `s0-s11`; callee saves/restores if it modifies them.
- `sp` must be restored before return; RISC-V Linux stack alignment is **16B** at calls.
- Leaf routine: prefer `a/t` regs, often no stack frame.
- Non-leaf with long-lived values across many calls: prefer `s` regs.
- In function A calling B, values in `t`/`a` live across B must be saved by **A**.

## 4.1 Procedure Call Steps

Call sequence:
1. place args in `a0-a7` or stack;
2. execute `jal ra, callee`;
3. callee allocates stack frame and saves needed `s` regs/`ra`;
4. callee computes result in `a0`;
5. callee restores regs/frame and returns with `jalr x0, ra, 0`.

## 4.2-4.4 Stack / Frame / RISC-V Support

- Stack grows downward; `sp` points to current stack top.
- Frame may contain saved `ra`, saved `s` regs, local variables, spilled temporaries, outgoing stack args.
- `fp`/`s0` is optional but useful for stable frame references.
- `jal` saves `PC+4` to `ra`; `ret` = `jalr x0, ra, 0`.

## 4.5-4.8 Register Convention

| ABI | x-reg | Role | Save Rule |
|---|---|---|---|
| `zero` | x0 | constant 0 | n/a |
| `ra` | x1 | return address | caller-saved |
| `sp` | x2 | stack pointer | preserved |
| `a0-a7` | x10-x17 | args/returns | caller-saved |
| `t0-t6` | x5-x7,x28-x31 | temporaries | caller-saved |
| `s0-s11` | x8-x9,x18-x27 | saved/local values | callee-saved |

Caller-saved:
- callee may freely clobber;
- caller saves before call if value is needed after call;
- good for short-lived temps and leaf routines.

Callee-saved:
- callee must restore before return if modified;
- good for values live across multiple calls.

## 4.9-4.11 Allocation Rules

- Short-lived temporary: use `t`/`a`, no save if not live across call.
- Long-lived local across calls: use `s`, one save at entry + one restore at exit.
- CSE value used across many calls: use `s`.
- If calls are rare/inside cold path, caller-saved may be cheaper.

Exam example:
- A calls B and `s1,t0,a1` are live across B: save/restore **`t0,a1`** in A; `s1` is B's responsibility if B modifies it.
- Leaf routine with only temps: use caller-saved regs; usually no save/restore.

## Summary

Pattern: if caller needs a caller-saved reg after call, caller saves it; if callee modifies an `s` reg, callee restores it.
