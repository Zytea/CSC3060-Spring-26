# Lec 4: Calling Convention & Caller/Callee Save Registers

## Exam Facts

- ==**Calling convention**==: ABI rules for **arg passing, return values, stack setup/teardown, frame layout, save/restore reg classification**.
- **CC defines**: arg/return regs, caller/callee-saved split, stack alignment, frame layout, save/restore responsibility.
- **CC does NOT define**: variable names, legal C data types (those are language rules).
- **If self-contained code (no external calls)**: CC adherence optional. **Any boundary with C/library**: must obey ABI.
- **Call/return**: `jal ra, func`; `ret = jalr x0, ra, 0`.
- **Args/returns**: ==**`a0-a7`** = first 8 args==; **`a0/a1` = return values**; all are caller-saved.
- ==**Caller-saved**== (`ra`, `t0-t6`, `a0-a7`): callee may clobber; caller saves before call if value needed after.
- ==**Callee-saved**== (`sp`, `s0-s11`): callee restores original value before return if it modifies.
- **`gp`, `tp`**: platform-managed (treat as preserved).
- **`x0`**: hardwired 0 (not part of save analysis).
- **Cost model** (value `v` live across `m` calls): caller-save = `2m` mem ops; callee-save = `2` mem ops if modified, else 0.
- **Leaf routine**: calls no function; prefer ==caller-saved (`a0-a7`, `t0-t6` = `x5-x7, x28-x31`)==; often no stack frame; **NOT** `s0-s11`.
- **Non-leaf**: must save `ra` if needs return after inner call; must save modified `s` regs.
- ==**`A` calls `B`, regs `s1, t0, a1` live across call**==: **`A` saves `t0, a1`** (caller-saved); **`B` preserves `s1`** (callee-saved). Quiz answer: **B, C** (= `t0, a1`).
- **Stack rule**: ==RISC-V Linux ABI stack is **16-byte aligned**== at call boundaries; stack grows downward.
- **Frame layout**: saved `ra`, old `s0/fp`, saved `s` regs, locals/spills, outgoing/incoming stack args, alignment pad.
- ==**Stack security**==: stack stores **local data + control info** (`ra`, old `fp`, saved regs); buffer overflow can overwrite `ra` → **control-flow hijack**.
- **Locals on stack**: usually at **negative offsets from `fp/s0`**.
- **Result must come back in `a0`** (not in `s2` or anywhere else) per ABI.
- ==**Caller-saved alloc anchors**==: leaf-routine temps; expression temps; values not live across calls; values live only across rare/cold calls.
- ==**Callee-saved alloc anchors**==: local scalar live most of function; CSE/reused values across many calls; values live across multiple calls.

## 1. Procedure Call Steps

```text
caller (A)                              callee (B)
─────────────                           ─────────────
1. put args in a0-a7
   (extras on stack)
2. save live caller-saved regs
   if needed across call
3. jal ra, B  ─────────────────────►   4. allocate frame (sp -= N, 16B aligned)
                                       5. save ra (if non-leaf) + modified s regs
                                       6. compute body
                                       7. result → a0/a1
                                       8. restore frame + regs
                                       9. ret  ◄────── jalr x0, ra, 0
10. restore saved caller-saved regs
11. consume a0/a1
```

## 2. Stack Allocation Before / During / After Call

Stack frame may contain:

- saved `ra`, old `s0/fp`, saved `s` regs.
- local arrays / register spills.
- outgoing stack args (when args > 8).
- alignment padding (so that `sp` stays 16B aligned).

| Time | Stack responsibility |
|---|---|
| before call | **caller** saves live caller-saved regs; places extra args on stack |
| during callee | **callee** saves modified `s` regs + `ra` (if non-leaf); allocates locals |
| after return | callee restored its frame; **caller** restores its own saved temps |

> [!IMPORTANT]
> ==**Stack security**==: stack stores both **data** (locals, args) and **control info** (`ra`, old `fp`, saved regs). Unchecked buffer write can overwrite `ra` → **return-address hijacking** (stack smashing).

==**Frame visualization**== (high addr at top, sp at bottom; stack grows down):

```text
high addr
┌──────────────────────────┐
│ caller's frame           │
│  ...                     │
│ extra args / saved       │  ← caller's responsibility
│   caller-saved regs      │
├──────────────────────────┤
│ saved ra                 │  ┐
│ saved old s0/fp          │  │
│ saved s1, s2, ...        │  │ callee's frame
│ locals / spills          │  │
│ alignment pad            │  ┘
└──────────────────────────┘  ← sp (16B aligned)
low addr
```

## 3. Frame Allocation

`sp` moves; `fp` (= `s0`) provides a stable base for debugging / dynamic-size locals (but RV ABI doesn't require fp).

==**Typical non-leaf prologue/epilogue**==:

```asm
# prologue
addi sp, sp, -16        # allocate 16B frame
sw   ra, 12(sp)         # save return addr
sw   s0,  8(sp)         # save old fp
addi s0, sp, 16         # set fp = top of frame

# ... function body ...

# epilogue
lw   s0,  8(sp)         # restore old fp
lw   ra, 12(sp)         # restore ra
addi sp, sp, 16         # deallocate
ret
```

> Why `sp -= 16` (not 8)? **16-byte alignment** rule of RISC-V Linux ABI.

## 4. RISC-V Procedure Support

RISC-V provides:

- `jal`/`jalr` for call/return.
- `sp` (`x2`) for stack frames.
- ABI register roles (a0-a7, s0-s11, t0-t6, ra).
- loads/stores for saved regs and stack args.

==**Self-contained vs ABI**==: pure assembly may ignore CC internally, but **any C/library boundary must obey ABI**.

## 5. RISC-V Register Convention (Full)

| x-reg | ABI | Role | Saver |
|---|---|---|---|
| `x0` | `zero` | hardwired 0 | — |
| `x1` | `ra` | return address | **caller** |
| `x2` | `sp` | stack pointer (16B align) | **callee** |
| `x3` | `gp` | global pointer | platform |
| `x4` | `tp` | thread pointer | platform |
| `x5-x7` | `t0-t2` | temps | **caller** |
| `x8` | `s0/fp` | saved / frame ptr | **callee** |
| `x9` | `s1` | saved | **callee** |
| `x10-x17` | `a0-a7` | args; `a0/a1` returns | **caller** |
| `x18-x27` | `s2-s11` | saved | **callee** |
| `x28-x31` | `t3-t6` | temps | **caller** |

==**Caller-saved set**==: `ra, t0-t6, a0-a7` = `x1, x5-x7, x10-x17, x28-x31`.
==**Callee-saved set**==: `sp, s0-s11` = `x2, x8-x9, x18-x27`.

## 6. Caller-Saved Registers

==**Caller-saved**==: callee may clobber; caller must save before call if value needed after.

==**Best for**==:

- leaf-routine temps.
- expression temporaries.
- values not live across any call.
- values live only across **rare / cold** calls (save in cold path).

==**Worked example**== (`t0, a1` live across call to `B`):

```asm
addi sp, sp, -8
sw   t0, 4(sp)
sw   a1, 0(sp)
jal  ra, B           # B may clobber t0, a1
lw   a1, 0(sp)
lw   t0, 4(sp)
addi sp, sp, 8
```

## 7. Callee-Saved Registers

==**Callee-saved**==: if callee modifies, it must restore the original before `ret`.

==**Best for**==:

- local scalar live through most of the function.
- CSE / reused values spanning calls.
- value live across **many** calls.

==**Worked example**== (callee uses `s1`):

```asm
foo:
    addi sp, sp, -16
    sw   s1, 12(sp)       # save before clobber
    # ... body uses s1 ...
    lw   s1, 12(sp)       # restore
    addi sp, sp, 16
    ret
```

## 8. Ideal vs Real World

| Role | Tempting | Reality |
|---|---|---|
| caller wants values preserved over call | use only `s` regs | OK when long-lived |
| callee wants no save/restore | use only `t/a` regs | OK when temporary |
| both caller + callee | **cost model** | depends on live range + call frequency |

## 9. Caller or Callee Save? Cost Analysis

Value `v` live across $m$ calls:

| Strategy   | **caller-saved**            | **callee-saved**                                |
| ---------- | --------------------------- | ----------------------------------------------- |
| **Mem ops**| $2m$ (save/restore each call) | $2$ (save@entry + restore@exit, **if** modified) |

==**Worked**==: `A()` calls `B`, `C`, `D`, one value `v` live across all three → caller-saved costs `6` mem ops (2 per call), callee-saved costs `2` (1 save@entry + 1 restore@exit). Callee-saved wins when value persists across multiple calls; caller-saved wins for short-lived temps.

> [!IMPORTANT]
> ==`A` calls `B`, regs `s1, t0, a1` all live across call==:
> - `A` saves/restores **`t0, a1`** (caller-saved class).
> - `B` is responsible for preserving **`s1`** (callee-saved class).
> - Quiz answer for "what must A save?" = **B, C only** (`t0, a1`).

## 10. General Register Allocation Rules

| Situation | Prefer |
|---|---|
| args / returns | `a0-a7`, `a0/a1` for return |
| short-lived expression temps | `t` regs (caller-saved) |
| **leaf-routine** temps | caller-saved (`a0-a7, t0-t6` = `x5-x7, x28-x31`) |
| local scalar live across function | `s` regs |
| value live across **many** calls | `s` regs |
| value live across **rare/cold** call | caller-save in the cold path |

> Rule of thumb: short-lived → caller; long-lived → callee.

## 11. Worked Patterns

### 11.1 Leaf Routine

==Calls **no** function==. Often no stack frame, no `ra` save.

> [!IMPORTANT]
> Leaf routines should prefer **caller-saved** (`a0-a7, t0-t6` = `x5-x7, x28-x31`) — saving callee-saved regs is wasted work since no caller depends on them being touched.

### 11.2 Non-Leaf

If a function calls another and needs its own return after, it **must save `ra`** (`ra` is caller-saved, will be clobbered by inner `jal`).

### 11.3 Nothing Live Across Call

If a value is dead at the call (or about to be overwritten by the return value), no save needed.

```asm
# A() calls B(), takes B's return as final result
lw t0, -4(fp)
add a0, t0, a1     # use t0 here
... = B(...)        # no save: t0 not used after
```

### 11.4 Worked Quiz Pattern

==**`A` calls `B`/`C`/`D` only in ELSE branch (rare)**==:

```c
if (condition) {
    // hot path: no calls
    ... use s2 ...
} else {
    B(); C(); D();   // cold path
    ... use s2 ...
}
```

→ Use **caller-saved** for `s2` value (save/restore in cold path only).

### 11.5 Local Array Access via `fp`

Locals usually at **negative offsets** from `fp`. Compute element-byte offset + frame layout.

==**Worked: `int A[100]` local var, A[10] = b**==:

```c
int f(int idx, int b) {
    int A[100];        // 400 B, allocated at [fp-400, fp-4)
    A[10] = b;          // store b (in a1) at A[0]+10*4 = fp-400+40 = fp-360
}
```

```asm
sw a1, -360(fp)         # = sw a1, -360(s0)
```

> Rule: local array at `fp - SIZE` → `A[k]` at `fp - SIZE + k*sizeof(elem)`.

## 12. Allocation Quiz Anchors

| Ask | Answer |
|---|---|
| caller-saved best for | **leaf routines, expression temps, values across rare/cold calls** |
| callee-saved best for | **values live across multiple calls, local scalars used long** |
| `A` calls `B`, live `s1,t0,a1` → A saves what? | **`t0, a1`** (`s1` is B's responsibility) |
| local array under `fp` | locals at **negative offsets** from `fp` |
| stack alignment | **16 B** (RV Linux ABI) |
| return value reg | `a0` (`a0/a1` for wider return) |
| direct call / return | `jal ra, label` / `jalr x0, ra, 0` (`ret`) |

## 13. Summary

==**Correctness**==: obey ABI at any module/function boundary.
==**Performance**==: pick saved class by **live range × call frequency**.
==**Stack**== stores: saved regs, return address, locals, spills, extra args, alignment.
==**Optimization strategy**==:
- Leaf → caller-saved (no overhead).
- Long-lived in non-leaf → callee-saved (save once at entry/exit).
- Short-lived in non-leaf → caller-saved (save only across the calls that need it).
