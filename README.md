即使这是开卷考试，我已经把ppt要点总结成各个md,但考出来还是一坨屎

现在我要你审查各个我考场上查阅用的md，看看我md的内容和quiz和cmu15-213（注意我们csc3060和他们教的不同（我们是riscv而不是x86,而且一共从1-into学到7-linking），但大量题目都是同一个源头,所以应当查看`exams\raw`和`Quiz`来辅助审查看看我总结的和考试考的区别在哪，以及我的md该增删哪些（毕竟资料页数越少越好））

一切的目的尽可能提高我这次csc3060 final的考试成绩

- Note Convention

- notes md should be english

- notes should be readable and concise for quick reference during the exam, so 

1. use text styles like ==**marked**== for key concepts (e.g., definition of a term),  **bold** for important points (which is highly likely to be included in the exam, like `/Quiz` and `exams\raw`), and `type`, > for side points or simple examples, >[!IMPORTANT], etc. whenever appropriate

for example, 
```
==**A computer system**==: ==hardware & system software== that work together to run application programs.
```

2. latex formulas, tables, diagrams, pics, bullet points, etc. whenever appropriate

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