即使这是开卷考试，我已经把ppt要点总结成各个md,但考出来还是一坨屎

现在我要你审查各个我考场上查阅用的md，看看我md的内容和quiz和cmu15-213（注意我们csc3060和他们教的不同（我们是riscv而不是x86,而且一共从1-into学到7-linking），但大量题目都是同一个源头,所以应当查看`exams\raw`和`Quiz`来辅助审查看看我总结的和考试考的区别在哪，以及我的md该增删哪些（毕竟资料页数越少越好））

一切的目的尽可能提高我这次csc3060 final的考试成绩

# Note Convention

- notes md should be english

- notes should be readable and concise for quick reference during the exam, so 

1. use text styles like ==**marked**== for key concepts (e.g., definition of a term),  **bold** for important points (which is highly likely to be included in the exam, like `/Quiz` and `exams\raw`), and `type`, > for side points or simple examples, >[!IMPORTANT], etc. whenever appropriate

for example, 
```
==**Computer system**==: **hardware + system software** that work together to run application programs.

> [!IMPORTANT] 
> ...

> Example:
> ...
```

2. latex formulas, tables, diagrams, pics (you can use pics in \assets of the corresponding note or screenshot it from the .pptx if you think it's necessary), bullet points, etc. whenever appropriate

3. be concise, no bullshit

4. follow the organization structure, if you are unsure, use the one for my notes like those in `1.md`, ..., `4.md`, `CA3060-4-1-ProcessorArchitecture.md`, etc.

For example, 
```
# Lec 1: Introduction
## Exam Facts
...

## 1.1 Information is bits + context
...

### 1.1.1 ... (Though you can use subsections like this, try to keep it concise and avoid nesting too much)

...

## 1.2 Program Compilation：4 Phases 

...

...

```

5. do not use ---, as these occupy an exatra line, and you should always keep in mind that the longer the notes, porportionally the harder it is to search during the exam. ==Every word counts!!!==, be cautious, but always be efficiently informative (i.e, you should not miss on any point that may be tested).

e.g., 0 is more efficient than zero, $\alpha$ better than `\alpha`,

$$
\text{formula}
$$

can only be used when it is important, that is,
bad example:
```
If fraction `\alpha` of old time is improved by factor `k`:

$$
T_{new} = (1-\alpha)T_{old} + \frac{\alpha T_{old}}{k}
$$

$$
\text{Speedup} = \frac{1}{(1-\alpha)+\frac{\alpha}{k}}
$$

If serial/unimproved fraction is `\beta`:

$$
\text{Max Speedup} = \frac{1}{\beta}
$$

High-yield examples:

- 80% parallelizable, infinite processors: **max speedup `= 1/0.2 = 5x`**.
- 80% parallelizable, 1000 processors:

$$
\text{Speedup}=\frac{1}{0.2+0.8/1000}\approx 5
$$

- 90% improvable, target speedup `4x`:

$$
4=\frac{1}{0.1+0.9/k}\Rightarrow k=6
$$

> 
```

Good example (Keep in mind that the notes will be printed in A4, so there is a limit on the length of latex lines, be cautious):
```
If $\alpha$ of old time is improved by factor $k$:

$$
T_{new} = (1-\alpha)T_{old} + \frac{\alpha T_{old}}{k}; \quad \text{Speedup} = \frac{1}{(1-\alpha)+\frac{\alpha}{k}} \leq  \frac{1}{1-\alpha}
$$

> Example:
>
> 90% improvable, target speedup `4x`: $4=\frac{1}{0.1+0.9/k}\Rightarrow k=6$
>
>  (this is just for demonstration, as I don't need a example for such a simple knowledge point, as you can see that in quizzes the instructor don’t test anything beyond this formula and I haven’t see any traps in applying this for problem solving, so raise your Occam's Razor; **this is the major criterion for whether to include an example or not!!!**)
```

Another Bad example (inefficient in height and for look up):
```
- A bit pattern may represent:
  - an integer,
  - a floating-point number,
  - an instruction,
  - an address,
  - characters,
  - media data,
  - array/struct fields.

> [!IMPORTANT]
> Do not identify a bit pattern without its interpretation context.

Examples:

| Bit Pattern                  | Possible Meaning                                    |
| ---------------------------- | --------------------------------------------------- |
| `0000...0000`                | integer `0`                                         |
| `0000...0000` as IEEE single | `+0.0`                                              |
| `0000...0000` as instruction | may be a legal/illegal instruction depending on ISA |
| `0x30`                       | ASCII character `'0'`, not numeric zero             |

**Quiz-style trap**

- 128 all-zero bits can be **four single-precision `+0.0`** values.
- Character string `"0000"` is made of ASCII bytes `0x30`, not zero bytes.
- For wider FP formats, do not assume all-zero bits mean an arbitrary valid object unless the format says so.
```

Good example (efficient!):
```
- A bit pattern may represent (e.g., 32 bit `0x0...0`):
    - variables: `int 0`, `float 0.0`, arrays/structs, addresses, etc.
    - instructions ISA
> [!NOTE]
- $\forall$ FP format, Do not assume all-0 bits mean valid.
```


6. If you have gone though the quizz and exams files. If you see that in quizzes the instructor don’t test anything beyond this formula and I haven’t see any traps in applying this for problem solving, so raise your Occam's Razor; otherwise, include it or use [!NOTE] or [!IMPORTANT] whenever appropriate; **this is the major criterion for whether to include an example or not!!!**

# Harness
当你生成完毕后，读一遍exams\raw（注意可能部分题目不在考纲内,那些题就不用管了（但如果是x86的题能转换成riscv的题在考纲内来考的话，那么这题依然很重要），在不在考纲内的话你在Quiz文件夹或pptx或我总结的md有没有来判断）和Quiz文件夹下的所有文件来审计一下，如果有题目无法从你生成的一堆_review.md快速推断出答案，那么你是失败的，据此在相应md的相应知识点处做相应修正，做完一遍后再去读一遍exams\raw重复迭代，如此harness，直到100%的train set acr

注意，你做完agent的运行时间无上限，一切以考试为目的