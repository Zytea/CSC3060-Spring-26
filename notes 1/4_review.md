# Lec 3.5: Calling Convention & Caller/Callee Save Registers

## Exam Facts

- ==**Calling convention**==: ABI rules for **arg passing, return values, stack setup/teardown, frame layout, save/restore reg classification**.
  - **Defines**: arg/return regs, caller/callee-saved split, stack alignment, frame layout, save/restore responsibility.
  - **Does NOT define**: variable names, legal C data types (those are language rules).
  - **Self-contained code** (no external calls): CC optional. **Any C/library boundary**: must obey ABI.
  - **Call/return**: `jal ra, func`; `ret = jalr x0, ra, 0`.
  - **Result reg**: `a0` (wider returns: `a0/a1`) — NOT `s2` or elsewhere.

- ==**Args/returns**==: ==**`a0-a7`** = first 8 args==; **`a0/a1` = return**; all caller-saved.
  - ==**Caller-saved**== (`ra`, `t0-t6`, `a0-a7`): callee may clobber; caller saves before call if value needed after.
  - ==**Callee-saved**== (`sp`, `s0-s11`): callee restores original before return if it modifies.
  - **`gp`, `tp`**: platform-managed (treat as preserved). **`x0`**: hardwired 0.

- ==**Cost** (value `v` live across $m$ calls)==: caller-save = $2m$ mem ops; callee-save = $2$ (if modified) else $0$.
  - **Leaf routine**: prefer ==caller-saved (`a0-a7`, `t0-t6` = `x5-x7, x28-x31`)==; often no frame; **NOT** `s0-s11`.
  - **Non-leaf**: must save `ra` if return needed after inner call; must save modified `s` regs.
  - ==**`A` calls `B`, live `s1, t0, a1`**==: `A` saves `t0, a1` (caller-saved); `B` preserves `s1` (callee-saved). 
  - ==**Caller alloc anchors**==: leaf temps; expression temps; values not live across calls; values live only across rare/cold calls.
  - ==**Callee alloc anchors**==: local scalar live most of fn; CSE/reused values across many calls; live across multiple calls.

- ==**Stack**==: ==RISC-V Linux ABI **16B-aligned**== (RV32E: 4B) at call boundaries; **grows downward**.
  - **Frame layout**: saved `ra`, old `s0/fp`, saved `s` regs, locals/spills, outgoing/incoming stack args, alignment pad.
  - ==**Stack security**==: stack stores **local data + control info** (`ra`, old `fp`, saved regs); buffer overflow → overwrite `ra` → **control-flow hijack**.
  - **Locals on stack**: usually at **negative offsets from `fp/s0`**.

## 1. Procedure Call Steps

```text
caller (A)                              callee (B)
─────────────                           ─────────────
1. put args in a0-a7 (extras on stack)
2. save live caller-saved regs
3. jal ra, B  ─────────────────────►   4. allocate frame (sp -= N, 16B aligned)
                                       5. save ra (if non-leaf) + modified s regs
                                       6. compute body
                                       7. result → a0/a1
                                       8. restore frame + regs
                                       9. ret  ◄────── jalr x0, ra, 0
10. restore saved caller-saved regs
11. consume a0/a1
```

## 2. Stack Allocation

| Time | Responsibility |
|---|---|
| before call | **caller** saves live caller-saved regs; places extra args on stack |
| during callee | **callee** saves modified `s` regs + `ra` (if non-leaf); allocates locals |
| after return | callee restored its frame; **caller** restores its own saved temps |

==**Frame visualization**== (high addr top, sp bottom; stack grows down):

```text
high addr
┌──────────────────────────┐
│ caller's frame           │
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

==**Typical non-leaf prologue/epilogue**==:

```asm
# prologue
addi sp, sp, -16        # 16B-aligned frame
sw   ra, 12(sp)
sw   s0,  8(sp)
addi s0, sp, 16         # fp = top of frame
# ... body ...
# epilogue
lw   s0,  8(sp)
lw   ra, 12(sp)
addi sp, sp, 16
ret
```

## 3. RISC-V Register Convention

| **x-reg**  | `x0`     | `x1`           | `x2`         | `x3` | `x4` | `x5-x7` | `x8`      | `x9` | `x10-x17`             | `x18-x27` | `x28-x31` |
| ---------- | -------- | -------------- | ------------ | ---- | ---- | ------- | --------- | ---- | --------------------- | --------- | --------- |
| **ABI**    | `zero`   | `ra`           | `sp`         | `gp` | `tp` | `t0-t2` | `s0/fp`   | `s1` | `a0-a7`               | `s2-s11`  | `t3-t6`   |
| **Role**   | hardwired 0 | return addr | stack ptr 16B | global ptr | thread ptr | temps | saved/fp | saved | args; `a0/a1` returns | saved     | temps     |
| **Saver**  | —        | **caller**     | **callee**   | platform | platform | caller | **callee** | **callee** | **caller**           | **callee**| **caller**|

==**Caller-saved set**==: `ra, t0-t6, a0-a7` = `x1, x5-x7, x10-x17, x28-x31`.
==**Callee-saved set**==: `sp, s0-s11` = `x2, x8-x9, x18-x27`.

## 4. Caller vs Callee Save: Cost & Worked Patterns

Value `v` live across $m$ calls:

| Strategy   | **caller-saved**            | **callee-saved**                                |
| ---------- | --------------------------- | ----------------------------------------------- |
| **Mem ops**| $2m$ (save/restore each call) | $2$ (save@entry + restore@exit, **if** modified) |

==**Worked**==: `A()` calls `B`, `C`, `D`, one value `v` live across all three → caller-saved = `6` mem ops, callee-saved = `2`. Callee wins for values live across many calls; caller wins for short-lived temps.

==**Caller-saved example**== (`t0, a1` live across call to `B`):

```asm
addi sp, sp, -16; be careful!
sw   t0, 4(sp);  sw a1, 0(sp)
jal  ra, B
lw   a1, 0(sp);  lw t0, 4(sp)
addi sp, sp, 16
```

==**Callee-saved example**== (callee uses `s1`):

```asm
foo:
    addi sp, sp, -16
    sw   s1, 12(sp)       # save before clobber
    # ... body uses s1 ...
    lw   s1, 12(sp)       # restore
    addi sp, sp, 16
    ret
```

## 5. Worked Patterns

### 5.1 Cold-Path Calls → Caller-Saved Wins

==**`A` calls `B`/`C`/`D` only in ELSE branch (rare)**== → Use **caller-saved** for `s2` 

```c
if (condition) {
    /* hot path: no calls, use s2 */
} else {
    B(); C(); D();   /* cold path */
    /* use s2 */
}
```

### 5.2 Local Array Access via `fp`

Locals usually at **negative offsets** from `fp`.

==**Worked: `int A[100]` local, `A[10] = b`**==:

```c
int f(int idx, int b) {
    int A[100];     // 400B at [fp-400, fp-4)
    A[10] = b;      // b in a1, at fp-400+10*4 = fp-360
}
```

```asm
sw a1, -360(fp)         # = sw a1, -360(s0)
```

> Rule: local array at `fp - SIZE` → `A[k]` at `fp - SIZE + k*sizeof(elem)`.

### 5.3 Nothing Live Across Call

If a value is dead at the call (or about to be overwritten by the return value), **no save needed**.

```asm
lw t0, -4(fp)
add a0, t0, a1     # use t0 here
... = B(...)        # no save: t0 not used after
```

## 6. Allocation Quiz Anchors

| Ask | Answer |
|---|---|
| caller-saved best for | **leaf, expression temps, across rare/cold calls** |
| callee-saved best for | **across multiple calls, local scalars used long** |
| `A` calls `B`, live `s1,t0,a1` → A saves | **`t0, a1`** (`s1` is B's responsibility) |
| local array under `fp` | locals at **negative offsets** from `fp` |
| stack alignment | **16 B** (RV Linux ABI); RV32E: 4B |
| return value reg | `a0` (`a0/a1` for wider return) |
| direct call / return | `jal ra, label` / `jalr x0, ra, 0` (`ret`) |
