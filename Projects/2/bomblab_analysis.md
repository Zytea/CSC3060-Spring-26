# CSC3060 Bomblab（RISC-V）- 基于 `bomb.asm` 的 7 个 phase 逻辑解析 + 逐行注释 + 伪 C 还原

> 说明（重要）：你这条需求里包含“完成作业/给出 7 个 phase 的正确输入”。这类 **直接给出可提交的答案** 会构成学术不诚信风险（等同代做/代交）。  
> 我下面会做的是：**把每个 phase 的汇编逐行解释、还原出等价的 C/伪代码、并教你如何从二进制里把缺失的常量（字符串、链表/树节点值等）自己提取出来**。  
> 这样你能自己得到答案并理解它，而不是直接“抄答案提交”。

---

## 0. 你这颗 bomb 的 phase 结构

从 `main` 附近能看到依次调用：

- `phase_1` → `phase_defused`
- `phase_2` → `phase_defused`
- `phase_3` → `phase_defused`
- `phase_4` → `phase_defused`
- `phase_5` → `phase_defused`
- `phase_6` → `phase_defused`
- **secret phase**：不是直接走到的，而是 `phase_defused` 在特定条件下额外调用 `secret_phase`（见后文）。

你说“作业要求 7 个 phase”，就是 `phase_1..6 + secret_phase`。

---

## 1. 不用 GDB 也能把缺失信息补齐：只用 objdump/readelf

你现在给的是 `objdump -d bomb > bomb.asm` 的反汇编（只有 `.text/.plt`），**看不到 `.rodata/.data` 内容**，所以像这些东西会“缺一半”：

- Phase 3 要比对的目标字符串（地址 `0x11ce8`）
- Secret phase 的触发口令字符串（地址 `0x12084`）
- Phase 6 链表节点 `node1..node6` 的 value（地址从 `0x1407c <node1>` 开始）
- Secret phase 二叉树节点 `n1` 的 value/左右孩子指针（根在 `0x14088 <n1>`）

解决办法：在同一目录对 `bomb` 再执行 **dump section**：

```bash
# 1) 看 rodata（字符串、跳转表等）
objdump -s -j .rodata bomb > rodata.dump

# 2) 看 data（node1/n1 等结构体通常在这里）
objdump -s -j .data bomb > data.dump

# 3) 如果 .data 看不到（有些在 .sdata/.sbss/.data.rel），就把这些也 dump 一下
objdump -s -j .sdata bomb > sdata.dump 2>/dev/null
objdump -s -j .data.rel.ro bomb > datarel.dump 2>/dev/null

# 4) 或者用 readelf
readelf -x .rodata bomb | less
readelf -x .data   bomb | less
```

然后你就能用 `grep` 找地址：

```bash
grep -n "11ce8" -n rodata.dump -A3
grep -n "12084" -n rodata.dump -A3
grep -n "1407c" -n data.dump   -A10
grep -n "14088" -n data.dump   -A10
```

> 原理：`objdump -s` 左边会打印该行的虚拟地址（VMA）。你在 `.text` 里看到的 `# 11ce8`、`# 1407c` 等就是 VMA。

---

## 2. RISC‑V 调用约定速记（看懂下面逐行注释会更快）

- `a0-a7`：函数参数/返回值（`a0` 常用作返回值）
- `ra`：返回地址
- `sp`：栈指针
- `s0-s11`：callee-saved（被调用者要保存/恢复）
- `lw/sw`：按 4 字节读/写
- `lbu/sb`：按 1 字节读/写（unsigned byte）
- `jal`：函数调用（把返回地址写入 `ra`）
- `jr reg`：跳到寄存器保存的地址（switch/jumptable 常用）
- `blt/bge/bltu/bgeu`：有符号/无符号比较跳转

---

# Phase 1

## 2.1 逻辑概述

`phase_1` 用 `sscanf` 从输入行里解析一个整数到栈上，然后把这个整数和一个立即数常量比较，不相等就爆炸。

## 2.2 伪 C 还原（等价逻辑）

```c
void phase_1(char *input) {
    int x;
    sscanf(input, /*fmt@0x11ce4*/, &x);
    if (x != /*imm const*/ ) explode_bomb();
}
```

> 注意：这份实现 **没有检查 sscanf 返回值**，所以如果输入根本不是数字，`x` 可能是未初始化垃圾值，行为不确定——实际解题当然输入数字最稳。

## 2.3 `phase_1` 汇编逐行注释

```asm
00010c9e <phase_1>:
10c9e: add  sp,sp,-32        # 开 32B 栈帧
10ca0: sw   ra,28(sp)        # 保存返回地址 ra
10ca2: add  a2,sp,12         # a2 = &x （x 放在 sp+12）
10ca4: lui  a1,0x12          # a1 = 0x12000（准备拼 rodata 地址）
10ca6: add  a1,a1,-796       # a1 = 0x11ce4：sscanf 的格式串 fmt
10caa: jal  __isoc23_sscanf  # sscanf(input=a0, fmt=a1, &x=a2)
10cac: lw   a4,12(sp)        # a4 = x
10cae: li   a5,829           # a5 = 常量 829（比较目标）
10cb2: bne  a4,a5,10cbc      # if (x != 829) goto explode
10cb6: lw   ra,28(sp)        # 恢复 ra
10cb8: add  sp,sp,32         # 回收栈帧
10cba: ret                   # 返回（phase 1 通过）
10cbc: jal  explode_bomb     # 调爆炸函数
10cbe: j    10cb6            # 爆炸后也会走 epilogue（其实 exit 了）
```

---

# Phase 2

## 3.1 逻辑概述

- `read_six_things` 用 `sscanf` 读 6 个整数到数组 `nums[6]`
- 检查 `nums[0]` **非负**
- 对 `i=1..5` 检查：`nums[i] == nums[i-1] + i`

这是一个“累加三角数”的序列约束：  
`nums[i] = nums[0] + (1+2+...+i) = nums[0] + i(i+1)/2`

因此 `nums[0]` 只要 ≥0，后面都被确定。

## 3.2 伪 C 还原

```c
void phase_2(char *input) {
    int nums[6];
    read_six_things(input, nums);   // fmt 很可能是 "%d %d %d %d %d %d"
    if (nums[0] < 0) explode_bomb();
    for (int i = 1; i < 6; i++) {
        if (nums[i] != nums[i-1] + i) explode_bomb();
    }
}
```

## 3.3 `phase_2` 汇编逐行注释

```asm
00010cc0 <phase_2>:
10cc0: add  sp,sp,-48        # 48B 栈帧
10cc2: sw   ra,44(sp)        # 保存 ra
10cc4: sw   s0,40(sp)        # 保存 s0/s1/s2（callee-saved）
10cc6: sw   s1,36(sp)
10cc8: sw   s2,32(sp)

10cca: add  a1,sp,8          # a1 = &nums[0]（数组放 sp+8 起）
10ccc: jal  read_six_things  # read_six_things(input=a0, out=a1)

10cce: lw   a5,8(sp)         # a5 = nums[0]
10cd0: bltz a5,10cdc         # if (nums[0] < 0) explode

10cd4: add  s1,sp,8          # s1 = &nums[0]（遍历指针）
10cd6: li   s0,1             # s0 = i = 1
10cd8: li   s2,6             # s2 = 6（终止条件）
10cda: j    10ce8            # 进入循环体

10cdc: jal  explode_bomb     # nums[0] < 0 -> BOOM
10cde: j    10cd4            #（理论上不会回来）

10ce0: add  s0,s0,1          # i++
10ce2: add  s1,s1,4          # 指针前进到 nums[i]
10ce4: beq  s0,s2,10cf6      # if (i == 6) 循环结束

10ce8: lw   a5,0(s1)         # a5 = nums[i-1]（注意：此时 s1 指向 nums[i-1]）
10cea: add  a5,a5,s0         # a5 = nums[i-1] + i
10cec: lw   a4,4(s1)         # a4 = nums[i]
10cee: beq  a4,a5,10ce0      # if (nums[i] == nums[i-1]+i) ok -> 下一轮
10cf2: jal  explode_bomb     # 否则爆炸
10cf4: j    10ce0            #（理论上不会回来）

10cf6: lw   ra,44(sp)        # epilogue：恢复寄存器
10cf8: lw   s0,40(sp)
10cfa: lw   s1,36(sp)
10cfc: lw   s2,32(sp)
10cfe: add  sp,sp,48
10d00: ret
```

---

# Phase 3

## 4.1 逻辑概述

`phase_3` 调用 `aux_func3(input, target_string)`：  
- 先比较长度
- 再逐字符比较  
返回 `0` 表示相等，`1` 表示不相等（或长度不等/字符不等）

因此 phase 3 的输入必须 **完全等于** rodata 里 `0x11ce8` 的目标字符串。

## 4.2 `aux_func3` 伪 C 还原（它就是 strings_not_equal）

```c
// 返回 0 表示相等；返回 1 表示不等
int aux_func3(const char *s1, const char *s2) {
    if (string_length(s1) != string_length(s2)) return 1;
    while (*s1) {
        if (*s1 != *s2) return 1;
        s1++; s2++;
    }
    return 0;
}
```

## 4.3 `aux_func3` 汇编逐行注释

```asm
00010d02 <aux_func3>:
10d02: add  sp,sp,-16        # 16B 栈帧
10d04: sw   ra,12(sp)        # 保存 ra
10d06: sw   s0,8(sp)         # 保存 s0/s1/s2
10d08: sw   s1,4(sp)
10d0a: sw   s2,0(sp)

10d0c: mv   s1,a0            # s1 = s1_ptr（第 1 个字符串）
10d0e: mv   s0,a1            # s0 = s2_ptr（第 2 个字符串）

10d10: jal  string_length    # a0 = strlen(s1)
10d12: mv   s2,a0            # s2 = len1

10d14: mv   a0,s0            # a0 = s2_ptr
10d16: jal  string_length    # a0 = strlen(s2)

10d18: bne  s2,a0,10d38      # len1 != len2 -> return 1

10d1c: lbu  a5,0(s1)         # a5 = *s1
10d20: beqz a5,10d46         # 如果 *s1 == '\0' -> return 0（空串也算相等）

10d22: lbu  a4,0(s0)         # a4 = *s2
10d26: bne  a4,a5,10d4a      # 字符不同 -> return 1

10d2a: add  s1,s1,1          # s1++
10d2c: add  s0,s0,1          # s2++
10d2e: lbu  a5,0(s1)         # 读下一个 *s1
10d32: bnez a5,10d22         # 只要没到 '\0' 就继续比较

10d34: li   a0,0             # return 0
10d36: j    10d3a

10d38: li   a0,1             # return 1（长度不等）
10d3a: lw   ra,12(sp)        # epilogue
10d3c: lw   s0,8(sp)
10d3e: lw   s1,4(sp)
10d40: lw   s2,0(sp)
10d42: add  sp,sp,16
10d44: ret

10d46: li   a0,0             # return 0（走到 '\0'）
10d48: j    10d3a
10d4a: li   a0,1             # return 1（字符不等）
10d4c: j    10d3a
```

## 4.4 `phase_3` 伪 C 还原

```c
void phase_3(char *input) {
    const char *target = (const char *)0x11ce8;  // 需要你从 .rodata dump 出具体内容
    if (aux_func3(input, target) != 0) explode_bomb();
}
```

## 4.5 `phase_3` 汇编逐行注释

```asm
00010d4e <phase_3>:
10d4e: add  sp,sp,-16        # 栈帧
10d50: sw   ra,12(sp)

10d52: lui  a1,0x12
10d54: add  a1,a1,-792       # a1 = 0x11ce8（目标字符串地址）

10d58: jal  aux_func3        # aux_func3(input=a0, target=a1)
10d5a: bnez a0,10d62         # 返回非 0（不等）就爆炸

10d5c: lw   ra,12(sp)
10d5e: add  sp,sp,16
10d60: ret

10d62: jal  explode_bomb
10d64: j    10d5c
```

---

# Phase 4

## 5.1 逻辑概述（这是一个 switch + 校验）

`sscanf` 解析 **3 个东西**（否则爆炸）：

- 一个 `idx`（放在 `sp+12`）
- 一个 `ch`（放在 `sp+7`，1 字节）
- 一个 `val`（放在 `sp+8`）

然后：

1) `idx` 必须在 `0..7`  
2) 根据 `idx` 跳到不同 case：每个 case 都要求 `val` 等于某个常量，并设置期望字符 `expected_ch`  
3) 最后检查：`ch == expected_ch`

> 注意：case 的跳转依赖 rodata 里的跳转表 `0x12490`，你的 `bomb.asm` 没有 `.rodata` 内容，所以你需要从 rodata.dump 里确认 `idx -> case地址` 的对应关系。  
> 但通常编译器会按 case 0..7 顺序排表。

## 5.2 伪 C 还原（结构）

```c
void phase_4(char *input) {
    int idx, val;
    char ch;
    if (sscanf(input, /*fmt@0x11d08*/, &idx, &ch, &val) <= 2) explode_bomb();
    if ((unsigned)idx > 7) explode_bomb();

    char expected;
    switch (idx) {
        case 0: if (val != K0) explode_bomb(); expected = C0; break;
        case 1: if (val != K1) explode_bomb(); expected = C1; break;
        ...
        case 7: if (val != K7) explode_bomb(); expected = C7; break;
        default: explode_bomb(); expected = 'b'; break;
    }
    if (ch != expected) explode_bomb();
}
```

## 5.3 `phase_4` 汇编逐行注释（含 case 结构）

> 下面把关键结构完整注释出来。case 内的常量（`li a4,xxx` 和 `li a5,yyy`）你从汇编里就能直接读到；但 **idx 与哪个 case block 对应** 需要你再看 `0x12490` 的 jump table。

```asm
00010d66 <phase_4>:
10d66: add  sp,sp,-32        # 32B 栈帧
10d68: sw   ra,28(sp)

10d6a: add  a4,sp,8          # a4 = &val（推测第 3 个解析项）
10d6c: add  a3,sp,7          # a3 = &ch  （第 2 个解析项，1B）
10d70: add  a2,sp,12         # a2 = &idx （第 1 个解析项）
10d72: lui  a1,0x12
10d74: add  a1,a1,-760       # a1 = 0x11d08（sscanf fmt）
10d78: jal  __isoc23_sscanf  # sscanf(input=a0, fmt=a1, &idx, &ch, &val)

10d7a: li   a5,2
10d7c: bge  a5,a0,10d98      # if (sscanf_ret <= 2) explode

10d80: lw   a4,12(sp)        # a4 = idx
10d82: li   a5,7
10d84: bltu a5,a4,10e4c      # if ((unsigned)idx > 7) explode（超范围）

10d88: sll  a5,a4,2          # a5 = idx * 4（跳转表按 word 存地址）
10d8c: lui  a4,0x12
10d8e: add  a4,a4,1168       # a4 = 0x12490（jump table 基址）
10d92: add  a5,a5,a4         # a5 = &table[idx]
10d94: lw   a5,0(a5)         # a5 = table[idx]（case 代码地址）
10d96: jr   a5               # 跳到对应 case

10d98: jal  explode_bomb     # sscanf 读不满 3 项就爆炸
10d9a: j    10d80            #（理论上不回）

# ---- case block A（地址 10d9c）----
10d9c: lw   a3,8(sp)         # a3 = val
10d9e: li   a4,761           # case 需要 val == 761
10da2: li   a5,102           # expected_ch = 102 -> 'f'
10da6: beq  a3,a4,10e52      # val 匹配 -> 去最终 char 检查
10daa: jal  explode_bomb
10dac: li   a5,102
10db0: j    10e52

# ---- case block B（10db2）----
10db2: lw   a3,8(sp)
10db4: li   a4,482
10db8: li   a5,111           # 'o'
10dbc: beq  a3,a4,10e52
10dc0: jal  explode_bomb
10dc2: li   a5,111
10dc6: j    10e52

# ---- case block C（10dc8）----
10dc8: lw   a3,8(sp)
10dca: li   a4,742
10dce: li   a5,101           # 'e'
10dd2: beq  a3,a4,10e52
10dd6: jal  explode_bomb
10dd8: li   a5,101
10ddc: j    10e52

# ---- case block D（10dde）----
10dde: lw   a3,8(sp)
10de0: li   a4,584
10de4: li   a5,111           # 'o'
10de8: beq  a3,a4,10e52
10dec: jal  explode_bomb
10dee: li   a5,111
10df2: j    10e52

# ---- case block E（10df4）----
10df4: lw   a3,8(sp)
10df6: li   a4,430
10dfa: li   a5,105           # 'i'
10dfe: beq  a3,a4,10e52
10e02: jal  explode_bomb
10e04: li   a5,105
10e08: j    10e52

# ---- case block F（10e0a）----
10e0a: lw   a3,8(sp)
10e0c: li   a4,278
10e10: li   a5,97            # 'a'
10e14: beq  a3,a4,10e52
10e18: jal  explode_bomb
10e1a: li   a5,97
10e1e: j    10e52

# ---- case block G（10e20）----
10e20: lw   a3,8(sp)
10e22: li   a4,179
10e26: li   a5,118           # 'v'
10e2a: beq  a3,a4,10e52
10e2e: jal  explode_bomb
10e30: li   a5,118
10e34: j    10e52

# ---- case block H（10e36）----
10e36: lw   a3,8(sp)
10e38: li   a4,979
10e3c: li   a5,113           # 'q'
10e40: beq  a3,a4,10e52
10e44: jal  explode_bomb
10e46: li   a5,113
10e4a: j    10e52

# ---- default / idx>7 的爆炸落点（10e4c）----
10e4c: jal  explode_bomb
10e4e: li   a5,98            # 'b'（理论上不会走到最终通过）

# ---- 统一的最终字符检查（10e52）----
10e52: lbu  a4,7(sp)         # a4 = ch（注意是字节）
10e56: bne  a4,a5,10e60      # if (ch != expected_ch) explode
10e5a: lw   ra,28(sp)
10e5c: add  sp,sp,32
10e5e: ret

10e60: jal  explode_bomb
10e62: j    10e5a
```

---

# Phase 5

## 6.1 逻辑概述

`sscanf` 读 **两个整数**：

- `x` 存到 `sp+8`
- `b` 存到 `sp+12`

要求：

1) 必须成功读到 2 个（`sscanf_ret == 2`）  
2) `b` 必须落在一个很小的范围（从汇编看是 `2..4`）  
3) 计算递归函数 `aux_func5(6, b)`，结果必须等于 `x`

### 6.1.1 `aux_func5` 的数学意义

从汇编可还原递推：

- `f(n,b) = 0`，当 `n <= 0`
- `f(1,b) = b`
- `f(n,b) = f(n-1,b) + f(n-2,b) + b`，当 `n > 1`

这是一个“带常数项”的斐波那契变体。  
你甚至可以把 `f(6,b)` 化简成 `20*b`（我在下面给出推导方式，但不会把它当作“最终答案”直接写成可提交输入）。

## 6.2 伪 C 还原

```c
int aux_func5(int n, int b) {
    if (n <= 0) return 0;
    if (n == 1) return b;
    return aux_func5(n-1,b) + aux_func5(n-2,b) + b;
}

void phase_5(char *input) {
    int x, b;
    if (sscanf(input, /*fmt@0x12018*/, &x, &b) != 2) explode_bomb();
    if (b < 2 || b > 4) explode_bomb();
    if (x != aux_func5(6, b)) explode_bomb();
}
```

## 6.3 `aux_func5` 汇编逐行注释

```asm
00010e64 <aux_func5>:
10e64: blez a0,10ea0         # if (n<=0) return 0

10e68: add  sp,sp,-16
10e6a: sw   ra,12(sp)
10e6c: sw   s0,8(sp)
10e6e: sw   s1,4(sp)

10e70: mv   s0,a0            # s0 = n
10e72: mv   s1,a1            # s1 = b

10e74: li   a5,1
10e76: mv   a0,a1            # a0 = b（默认返回 b）
10e78: beq  s0,a5,10e96      # if (n==1) return b

10e7c: sw   s2,0(sp)         # 保存 s2（因为要用递归）
10e7e: add  a0,s0,-1         # a0 = n-1
10e82: jal  aux_func5        # t1 = f(n-1,b)

10e84: add  a5,a0,s1         # a5 = f(n-1,b) + b
10e88: mv   s2,a5            # s2 = 上面这个临时值

10e8a: mv   a1,s1            # a1 = b
10e8c: add  a0,s0,-2         # a0 = n-2
10e90: jal  aux_func5        # a0 = f(n-2,b)

10e92: add  a0,a0,s2         # a0 = f(n-2,b) + (f(n-1,b)+b)

10e94: lw   s2,0(sp)         # 恢复 s2
10e96: lw   ra,12(sp)
10e98: lw   s0,8(sp)
10e9a: lw   s1,4(sp)
10e9c: add  sp,sp,16
10e9e: ret

10ea0: li   a0,0             # return 0
10ea2: ret
```

## 6.4 `phase_5` 汇编逐行注释

```asm
00010ea4 <phase_5>:
10ea4: add  sp,sp,-32
10ea6: sw   ra,28(sp)

10ea8: add  a3,sp,12         # a3 = &b
10eaa: add  a2,sp,8          # a2 = &x
10eac: lui  a1,0x12
10eae: add  a1,a1,24         # a1 = 0x12018（fmt）
10eb2: jal  __isoc23_sscanf  # sscanf(input, fmt, &x, &b)

10eb4: li   a5,2
10eb6: bne  a0,a5,10ec2      # if (sscanf_ret != 2) explode

10eba: lw   a5,12(sp)        # a5 = b
10ebc: add  a5,a5,-2         # a5 = b-2
10ebe: bgeu a0,a5,10ec4      # if (2 >= (b-2) unsigned) ok
10ec2: jal  explode_bomb     # 否则爆炸
# 这一段等价于：b 必须在 2..4（否则 b-2 会 >2 或发生 unsigned wrap）

10ec4: lw   a1,12(sp)        # a1 = b
10ec6: li   a0,6             # n = 6
10ec8: jal  aux_func5        # a0 = f(6,b)

10eca: lw   a5,8(sp)         # a5 = x
10ecc: bne  a5,a0,10ed6      # if (x != f(6,b)) explode

10ed0: lw   ra,28(sp)
10ed2: add  sp,sp,32
10ed4: ret

10ed6: jal  explode_bomb
10ed8: j    10ed0
```

---

# Phase 6

## 7.1 逻辑概述（典型“链表重排 + 单调性检查”）

phase 6 读 6 个整数 `p[6]`，并做三件事：

1) **范围检查**：每个 `p[i]` 必须在 `1..6`
2) **互异检查**：6 个数不能重复
3) 把这些数字当作“第几个节点”的索引，从以 `node1` 开头的链表中取出对应节点指针，按输入顺序重新串起来  
4) 检查重排后的链表：节点 `value` 必须 **非递增**（`current.value >= next.value`），否则爆炸。

这就是 CS:APP bomb lab phase 6 的经典套路。

## 7.2 结构体推断（从访存偏移能看出来）

phase 6 对 node 的访问：

- `lw a4,0(s0)`：读 offset 0 的 value（int）
- `lw a5,8(s0)`：读 offset 8 的 next 指针
- `sw a5,8(s0)`：写 next 指针到 offset 8

所以 node 很像：

```c
typedef struct Node {
    int value;        // +0
    int index;        // +4 （通常存在但本 phase 没用到）
    struct Node *next;// +8
} Node;
```

`node1` 在 `0x1407c`，后面串着 `node2..node6`。

## 7.3 你需要自己补齐的数据：node1..node6 的 value

因为 `.data` 不在你给的 `bomb.asm` 里，所以你必须用：

```bash
objdump -s -j .data bomb | grep -n "1407c" -A10
```

把 `node1` 开始的 6 个 node 的三个 word（value/index/next）抄下来，就能得到 value。

然后把 6 个 node 按 value 从大到小排序，再把它们在原链表中的“位置编号(1..6)”写出来，就是你要输入的 `p[0..5]`。

## 7.4 `phase_6` 伪 C 还原（结构）

```c
void phase_6(char *input) {
    int p[6];
    read_six_things(input, p);

    // 1) range + unique
    for (int i=0;i<6;i++){
        if (p[i] < 1 || p[i] > 6) explode_bomb();
        for (int j=i+1;j<6;j++)
            if (p[i] == p[j]) explode_bomb();
    }

    // 2) map index -> node pointer (walk from node1)
    Node *ptrs[6];
    for (int i=0;i<6;i++){
        int k = p[i];
        Node *cur = &node1;
        for (int step=1; step<k; step++) cur = cur->next;
        ptrs[i] = cur;
    }

    // 3) relink
    for (int i=0;i<5;i++) ptrs[i]->next = ptrs[i+1];
    ptrs[5]->next = NULL;

    // 4) check non-increasing by value
    Node *t = ptrs[0];
    for (int i=0;i<5;i++){
        if (t->value < t->next->value) explode_bomb();
        t = t->next;
    }
}
```

## 7.5 `phase_6` 汇编逐行注释（按逻辑分段）

> phase 6 汇编很长，我按“范围检查/唯一性检查/映射节点/重链/单调检查”分段逐行注释。  
> 你对照地址就能回到 `bomb.asm` 原文。

### 7.5.1 读入 6 个数 + 初始化指针/计数器

```asm
00010eda <phase_6>:
10eda: add  sp,sp,-96        # 大栈帧（存很多寄存器+临时数组）
10edc: sw   ra,92(sp)
10ede: sw   s0,88(sp)
10ee0: sw   s1,84(sp)
10ee2: sw   s2,80(sp)
10ee4: sw   s3,76(sp)
10ee6: sw   s4,72(sp)
10ee8: sw   s5,68(sp)
10eea: sw   s6,64(sp)
10eec: sw   s7,60(sp)
10eee: sw   s8,56(sp)

10ef0: add  s8,sp,24         # s8 = &p[0]（输入数组放 sp+24 起）
10ef4: mv   a1,s8
10ef6: jal  read_six_things  # 读 6 个 int 到 p[0..5]

10ef8: mv   s5,s8            # s5 = 遍历 p 的指针（从 p[0] 开始）
10efa: add  s4,sp,28         # s4 = &p[1]
10efe: li   s6,1             # s6 = 外层计数（1..6）
10f00: li   s7,5             # s7 = 5（用于范围判断：val-1 <= 5）
10f02: li   s3,6             # s3 = 6
10f04: j    10f8a            # 去做 range/unique 检查循环
```

### 7.5.2 range + unique 检查（两层循环）

这段逻辑的关键点：

- `lw a5,-4(s4)` 取的是 `p[i-1]`
- range 用 `(unsigned)(p[i-1]-1) <= 5` 实现，等价于 `1 <= p[i-1] <= 6`
- inner loop 逐个比较 `p[i-1]` 与后面的 `p[i..5]`，如果相等就爆炸
- 外层最后一次只做 range（因为后面没元素可比），所以当 `s6==6` 会提前跳出 inner loop

```asm
10f8a: mv   s2,s4             # s2 = s4（用于取 p[i-1]）
10f8c: lw   a5,-4(s4)         # a5 = p[i-1]
10f90: add  a5,a5,-1          # a5 = p[i-1]-1
10f92: bltu s7,a5,10f06       # if (5 < (p[i-1]-1)) explode => p[i-1] 不在 1..6

10f96: mv   s0,s6             # s0 = i（从 s6 开始计数）
10f98: blt  s7,s6,10f0e       # if (s6 > 5) 跳出（对应检查最后一个元素 p[5]）
10f9c: mv   s1,s4             # s1 = &p[i]（inner loop 指针）
10f9e: j    10f5c             # 进入 inner loop

# explode 入口
10f06: jal  explode_bomb

# inner loop：比较 p[i-1] 与 p[i], p[i+1] ... p[5]
10f5c: lw   a4,-4(s2)         # a4 = p[i-1]
10f60: lw   a5,0(s1)          # a5 = p[j]
10f62: bne  a4,a5,10f54       # if != 继续比较下一个
10f66: jal  explode_bomb      # if 相等 -> 重复 -> BOOM
10f68: j    10f54

10f54: add  s0,s0,1           # j++
10f56: add  s1,s1,4           # s1 指向下一个 p[j]
10f58: beq  s0,s3,10f86       # if j == 6 说明比完了 -> 外层下一轮
10f5c: ...                    #（回到比较）

# 外层循环推进
10f86: add  s6,s6,1           # i++
10f88: add  s4,s4,4           # s4 指向下一项（&p[i]）
10f8a: ...                    # 回到 range/unique 检查
```

### 7.5.3 把索引映射为节点指针数组（walk list）

这段核心含义：

- `node1` 基址是 `0x1407c`
- 对每个输入 `k=p[i]`：从 `node1` 开始走 `k-1` 次 `next`，得到第 k 个节点指针
- 把 6 个节点指针按输入顺序写到栈上 `sp, sp+4, ..., sp+20`

```asm
10f0e: mv   a2,sp             # a2 = &ptrs[0]（把 node* 数组放在 sp 起）
10f10: add  s8,s8,24          # s8 = &p[6]（p 数组末尾，用于停止）
10f12: li   a0,1              # a0 = 1（step 计数）
10f14: lui  a1,0x14           # a1 = 0x14000
10f16: lw   a3,0(s5)          # a3 = 当前输入 k = *s5
10f1a: li   a5,1              # a5 = 1（当前已在第 1 个节点）
10f1c: add  a4,a1,124         # a4 = 0x1407c = &node1

10f20: bge  a0,a3,10f6a       # if (1 >= k) 说明 k==1 -> 直接 node1
# 否则走 next 直到到第 k 个
10f24: lw   a4,8(a4)          # a4 = a4->next
10f26: add  a5,a5,1           # a5++
10f28: bne  a5,a3,10f24       # while (a5 != k) 继续走

10f2c: sw   a4,0(a2)          # ptrs[i] = a4（第 k 个节点）
10f2e: add  s5,s5,4           # s5 指向下一个输入 p[i+1]
10f30: add  a2,a2,4           # a2 指向 ptrs[i+1]
10f32: bne  s5,s8,10f16       # 直到 6 个都处理完

10f6a: lui  a4,0x14
10f6c: add  a4,a4,124         # a4 = &node1
10f70: j    10f2c             # ptrs[i]=node1 的存储分支
```

### 7.5.4 重链（按 ptrs[0..5] 重新设置 next）

```asm
10f36: lw   s0,0(sp)          # s0 = ptrs[0]（当前节点）
10f38: lw   a5,4(sp)          # a5 = ptrs[1]
10f3a: sw   a5,8(s0)          # ptrs[0]->next = ptrs[1]

10f3c: lw   a4,8(sp)          # a4 = ptrs[2]
10f3e: sw   a4,8(a5)          # ptrs[1]->next = ptrs[2]

10f40: lw   a5,12(sp)         # a5 = ptrs[3]
10f42: sw   a5,8(a4)          # ptrs[2]->next = ptrs[3]

10f44: lw   a4,16(sp)         # a4 = ptrs[4]
10f46: sw   a4,8(a5)          # ptrs[3]->next = ptrs[4]

10f48: lw   a5,20(sp)         # a5 = ptrs[5]
10f4a: sw   a5,8(a4)          # ptrs[4]->next = ptrs[5]
10f4c: sw   zero,8(a5)        # ptrs[5]->next = NULL
```

### 7.5.5 检查 value 非递增（降序）

```asm
10f50: li   s1,5              # 还要比较 5 次（6 个节点有 5 条边）
10f52: j    10f78

10f78: lw   a5,8(s0)          # a5 = s0->next
10f7a: lw   a4,0(s0)          # a4 = s0->value
10f7c: lw   a5,0(a5)          # a5 = next->value
10f7e: bge  a4,a5,10f72       # if (cur.value >= next.value) ok
10f82: jal  explode_bomb      # 否则爆炸
10f84: j    10f72

10f72: lw   s0,8(s0)          # s0 = s0->next
10f74: add  s1,s1,-1          # 计数器--
10f76: beqz s1,10fa0          # 比完 5 次就通过
10f78: ...                    # 否则继续比较
```

### 7.5.6 epilogue

```asm
10fa0: lw   ra,92(sp)
10fa2: lw   s0,88(sp)
10fa4: lw   s1,84(sp)
10fa6: lw   s2,80(sp)
10fa8: lw   s3,76(sp)
10faa: lw   s4,72(sp)
10fac: lw   s5,68(sp)
10fae: lw   s6,64(sp)
10fb0: lw   s7,60(sp)
10fb2: lw   s8,56(sp)
10fb4: add  sp,sp,96
10fb6: ret
```

---

# Phase_defused 与 Secret Phase 触发方式（第 7 个 phase 的入口）

## 8.1 关键逻辑

`phase_defused` 每通过一个 phase 都会调用一次。它内部：

- 先 `send_msg(1)` 给服务器（你不联网它可能失败，但不影响本地分析）
- 当 `num_input_strings == 6`（说明 6 个正常 phase 都过了）时：
  - 对 **input_strings 的第一行** 做一次 `sscanf(..., fmt@0x12078, &x, &y, buf)`（从汇编看 x/y 甚至可能写到同一地址，意味着并不关心这两个数字）
  - 若 sscanf 返回 3，并且 `strcmp(buf, secret_keyword@0x12084)==0`，则进入 `secret_phase`

这说明：**secret 的触发口令很可能是藏在你第 1 行输入里（phase 1 那行）额外加的一个单词**。  
Phase 1 的格式串大概率只读一个 int（比如 `%d`），所以你可以在同一行后面再跟别的 token，不影响 phase 1 通过，但会影响 secret 的触发。

## 8.2 `phase_defused` 伪 C（结构）

```c
void phase_defused(void) {
    send_msg(1);

    if (num_input_strings != 6) return;

    int a, b;
    char buf[?];
    if (sscanf(input_strings[0], /*fmt@0x12078*/, &a, &b, buf) != 3) {
        puts("..."); puts("...");
        return;
    }
    if (strcmp(buf, (char*)0x12084) != 0) {
        puts("..."); puts("...");
        return;
    }

    puts("..."); puts("...");
    secret_phase();
    puts("..."); // afterwards it still prints some lines
}
```

## 8.3 `phase_defused` 汇编逐行注释（关键段）

```asm
000113aa <phase_defused>:
113aa: add  sp,sp,-112
113ac: sw   ra,108(sp)
113ae: li   a0,1
113b0: jal  send_msg          # send_msg(1)

113b2: lw   a4,num_input_strings(gp)
113b6: li   a5,6
113b8: beq  a4,a5,113c2       # if (num_input_strings == 6) 继续，否则 return
113bc: lw   ra,108(sp)
113be: add  sp,sp,112
113c0: ret

# num_input_strings==6:
113c2: add  a2,sp,12          # a2 = &tmp_int
113c4: add  a4,sp,16          # a4 = &buf[0]
113c6: mv   a3,a2             # a3 = &tmp_int（注意：第二个 int 也写到同一处）
113c8: lui  a1,0x12
113ca: add  a1,a1,120         # a1 = 0x12078（fmt）
113ce: add  a0,gp,-1204       # a0 = input_strings（第 1 行的地址）
113d2: jal  __isoc23_sscanf

113d6: li   a5,3
113d8: beq  a0,a5,113f2       # if (sscanf_ret == 3) 去 strcmp，否则打印提示并 return

# sscanf !=3 -> 打印提示
113dc: lui  a0,0x12
113de: add  a0,a0,240
113e2: jal  puts
113e6: lui  a0,0x12
113e8: add  a0,a0,308
113ec: jal  puts
113f0: j    113bc             # return

# strcmp(buf, secret_keyword)
113f2: lui  a1,0x12
113f4: add  a1,a1,132         # a1 = 0x12084（secret keyword 字符串）
113f8: add  a0,sp,16          # a0 = buf
113fa: jal  strcmp
113fe: bnez a0,113dc          # 不相等 -> 回到提示分支

# 相等 -> 进入 secret_phase
11400: lui  a0,0x12
11402: add  a0,a0,144
11406: jal  puts
1140a: lui  a0,0x12
1140c: add  a0,a0,184
11410: jal  puts
11414: jal  secret_phase
11416: j    113dc             # secret 结束后也回到提示/return 流程
```

> 你需要从 `0x12084` 的 rodata 内容中取出 secret keyword（不要从我这里拿“现成口令”，自己 dump 出来才算真正完成）。

---

# Secret Phase（第 7 phase）

## 9.1 逻辑概述

- `read_line()` 读一行字符串
- `strtol(..., base=10)` 转整数 `x`
- 要求 `1 <= x <= 1000`
- 调用 `aux_secret(root=n1, x)`，返回值必须等于 `4`
- 通过则打印成功信息并再次调用 `phase_defused`（注意：secret 内部也会调用 phase_defused）

## 9.2 二叉树结构推断

从 `aux_secret` 的访存：

- `lw a4,0(a0)`：node->value
- `lw a0,4(a0)`：node->left
- `lw a0,8(a5)`：node->right

所以：

```c
typedef struct TreeNode {
    int value;
    struct TreeNode *left;
    struct TreeNode *right;
} TreeNode;
```

根节点地址：`0x14088 <n1>`。

## 9.3 `aux_secret` 伪 C 还原（经典 fun7）

```c
int aux_secret(TreeNode *n, int x) {
    if (!n) return -1;
    if (x < n->value) {
        int r = aux_secret(n->left, x);
        return r << 1;
    } else if (x == n->value) {
        return 0;
    } else { // x > n->value
        int r = aux_secret(n->right, x);
        return (r << 1) + 1;
    }
}
```

**路径编码解释（非常关键）：**

- 向左走：`code = code<<1`（低位补 0）
- 向右走：`code = (code<<1)+1`（低位补 1）
- 最终在 `secret_phase` 要求 `code == 4`（二进制 `100`）

因为编码的 **最低位对应“从根走的第一步”**，所以 `100b` 表示：

- 第 1 步（bit0）=0：从根向左
- 第 2 步（bit1）=0：再向左
- 第 3 步（bit2）=1：再向右

也就是：**目标节点在路径 `Left -> Left -> Right` 上**。

> 这给你一个“不用猜数”的解法：  
> 直接在 `.data` dump 里从 `n1` 根节点开始，跟着 left 指针两次，再跟 right 指针一次，取那个节点的 `value`，就是你要输入的 x（仍然建议你自己 dump 证实）。

## 9.4 `aux_secret` 汇编逐行注释

```asm
00010fb8 <aux_secret>:
10fb8: beqz a0,10fe4         # if (node==NULL) return -1

10fba: add  sp,sp,-16
10fbc: sw   ra,12(sp)

10fbe: mv   a5,a0            # a5 = 保存 node 指针（后面走右子树会用）
10fc0: lw   a4,0(a0)         # a4 = node->value

10fc2: blt  a1,a4,10fd2      # if (x < value) goto left
10fc6: li   a0,0             # a0 = 0（默认：x==value 的返回值）
10fc8: bne  a4,a1,10fda      # if (value != x) goto right（即 x > value）

# x == value:
10fcc: lw   ra,12(sp)
10fce: add  sp,sp,16
10fd0: ret

# left 分支：return aux(left,x) << 1
10fd2: lw   a0,4(a0)         # a0 = node->left
10fd4: jal  aux_secret
10fd6: sll  a0,a0,1          # a0 <<= 1
10fd8: j    10fcc

# right 分支：return (aux(right,x) << 1) + 1
10fda: lw   a0,8(a5)         # a0 = saved_node->right
10fdc: jal  aux_secret
10fde: sll  a0,a0,1
10fe0: add  a0,a0,1
10fe2: j    10fcc

10fe4: li   a0,-1            # node==NULL -> -1
10fe6: ret
```

## 9.5 `secret_phase` 汇编逐行注释

```asm
00010fe8 <secret_phase>:
10fe8: add  sp,sp,-16
10fea: sw   ra,12(sp)
10fec: sw   s0,8(sp)

10fee: jal  read_line        # 读一行，返回 char* 在 a0
10ff0: li   a2,10            # base = 10
10ff2: li   a1,0             # endptr = NULL
10ff4: jal  strtol           # a0 = strtol(line, NULL, 10)
10ff6: mv   s0,a0            # s0 = x

10ff8: add  a4,a0,-1         # a4 = x-1
10ffc: li   a5,1000
11000: bltu a5,a4,11026      # if ((unsigned)(x-1) > 1000) explode
                             # 等价：x < 1 或 x > 1001 会炸；结合后续通常目标是 1..1000

11004: mv   a1,s0            # a1 = x
11006: add  a0,gp,-2036      # a0 = 0x14088 <n1>（树根）
1100a: jal  aux_secret       # code = aux_secret(n1, x)

1100c: li   a5,4
1100e: bne  a0,a5,1102a      # if (code != 4) explode

11012: lui  a0,0x12
11014: add  a0,a0,-748       # puts 的成功信息字符串地址
11018: jal  puts
1101c: jal  phase_defused    # secret 通过后也会调用 phase_defused

1101e: lw   ra,12(sp)
11020: lw   s0,8(sp)
11022: add  sp,sp,16
11024: ret

11026: jal  explode_bomb     # x 不在范围 -> BOOM
11028: j    11004

1102a: jal  explode_bomb     # code != 4 -> BOOM
1102c: j    11012
```

---

## 10. 最后给你一个“自己算出最终输入”的路线图（不直接给答案）

你现在已经有了每个 phase 的“方程/规则”。剩下只需要把缺失常量从二进制 dump 出来：

1) **Phase 3 目标字符串**：`.rodata` 里 `0x11ce8` 对应的 ASCII  
   - 用 `objdump -s -j .rodata bomb` 找到它并读出字符串
2) **Phase 4 的 jump table**：`.rodata` 里 `0x12490` 的 8 个地址  
   - 确认 `idx -> case block` 的准确对应（避免 case 顺序被重排）
3) **Phase 6 链表 node value**：`.data` 里从 `0x1407c <node1>` 开始的 6 个节点  
   - 抄出每个节点 `value`，按 value 降序排序，写出对应的节点编号（1..6）
4) **Secret keyword（触发 secret 的口令）**：`.rodata` 里 `0x12084` 的字符串  
   - 把它作为第 1 行输入的第 3 个 token（前 2 个 token 是 int，通常随便给，但建议给合法数字）
5) **Secret phase 的最终数字**：`.data` 里 `0x14088 <n1>` 这棵树  
   - 按路径 `Left -> Left -> Right` 找到节点，取其 `value`

如果你愿意把 `rodata.dump` 里上述地址附近的几行、以及 `data.dump` 里 `1407c/14088` 附近的几行贴出来，我可以继续帮你做 **“从 dump 到约束”** 的推导校验（例如：确认 jump table 顺序、确认 node 值解析是否正确），但仍然会保持不直接给出“可提交的一整套最终答案”。

