# RISC-V GDB Environment for CSC3060 Bomblab

## Docker

In this tutorial, we will use a prebuilt Docker image to ensure a consistent, reproducible environment for doing the bomblab.

Before starting, make sure you have installed Docker and any other necessary packages. The easiest way to set up a Docker environment is to install Docker Desktop at the following link: https://www.docker.com/products/docker-desktop/

## Environment Setup

```bash
docker pull ghcr.io/lwh1/rvemu:latest
docker container run --name rvemu -p 2222:2222 -d ghcr.io/lwh1/rvemu
# When prompted for password, enter: csc3060

# 3. SSH into QEMU
scp -P 2222 "C:\Users\Zytea\Desktop\CSC 3060\Projects\2\bomb104\bomb" root@localhost:~
ssh root@localhost -p 2222

chmod +x bomb

gdb ./bomb
b explode_bomb
b phase_1
b phase_2
run

disas

x/s $a1



objdump -d bomb > bomb.asm
scp -P 2222 root@localhost:~/bomb.asm .
```

```bash
scp -P 2222 "C:\Users\Zytea\Desktop\CSC 3060\Projects\2\bomb104\solution.txt" root@localhost:~
ssh root@localhost -p 2222

gdb ./bomb
b explode_bomb
b phase_1
b phase_2
b phase_3
b phase_4
b phase_5
b phase_6
b secret_phase
run

829 0 DrLethal
0 1 3 6 10 15

(gdb) x/s 0x11ce8

Only a Sith deals in absolutes!

(gdb) x/8wx 0x12490
0x12490:        0x00010d9c      0x00010db2      0x00010dc8      0x00010dde
0x124a0:        0x00010df4      0x00010e0a      0x00010e20      0x00010e36

0 f 761

40 2

(gdb) x/3wx 0x1407c
0x1407c <node1>:        0x00000046      0x00000001      0x0001413c
(gdb) x/3wx 0x1413c
0x1413c <node2>:        0x00000272      0x00000002      0x00014148
(gdb) x/3wx 0x14148
0x14148 <node3>:        0x0000021f      0x00000003      0x00014154
(gdb) x/3wx 0x14154
0x14154 <node4>:        0x0000026f      0x00000004      0x00014160
(gdb) x/3wx 0x14160
0x14160 <node5>:        0x00000188      0x00000005      0x0001416c
(gdb) x/3wx 0x1416c
0x1416c <node6>:        0x0000024c      0x00000006      0x00000000

2 4 6 3 5 1

(gdb) x/s 0x12084
0x12084:        "DrLethal"

(gdb) x/3wx 0x14088
0x14088 <n1>:   0x00000024      0x00014094      0x000140a0
(gdb) x/3wx 0x14094
0x14094 <n21>:  0x00000008      0x000140c4      0x000140ac
(gdb) x/3wx 0x140c4
0x140c4 <n31>:  0x00000006      0x000140e8      0x0001410c
(gdb) x/3wx 0x1410c
0x1410c <n42>:  0x00000007      0x00000000      0x00000000

7

```

**626** (ID: 2)

**623** (ID: 4)

**588** (ID: 6)

**543** (ID: 3)

**392** (ID: 5)

**70** (ID: 1)

## 🛠️ GDB 常用命令速查手册

### 1. 断点与运行控制 (Breakpoints & Execution)

- **`break` (b)**: 设置断点。让程序在执行到特定位置时暂停，以便检查状态。
  - 用法：`break <行号>`、`break <函数名>` 或 `break *<地址>`。
- **`run` (r)**: 从头开始运行程序，直到遇到第一个断点。
- **`continue` (c)**: 继续执行程序，直到运行到下一个断点。
- **`step` / `stepi` (s)**: 执行下一行代码 / 下条指令。
  - **Step Into**: 如果当前行是函数调用，它会进入函数内部，适合逐行跟踪逻辑。

### 2. 函数与调用栈 (Functions)

- **`finish` (f)**: 执行完当前函数剩余的部分并返回，停在调用该函数后的位置。

### 3. 查看状态与变量 (Inspection)

- **`info registers` (i r)**: 显示所有寄存器（x1-x31 + pc）的当前数值。
  - *进阶：* `info locals`（查看局部变量）或 `info frame`（查看栈帧信息）。
- **`print $reg` (p)**: 打印指定寄存器的内容（默认十进制）。
  - **`print/x $reg`**: 以**十六进制**格式打印寄存器内容。

### 4. 内存查看 (Examine Memory)

- **`x / [长度][格式] [地址]`**: 查看（Examine）特定地址的内存内容。
  - **常见格式 (Format)**:
    - `x`: 十六进制 (Hex)
    - `s`: 字符串 (String)
    - `c`: 字符 (Char)
    - `a`: 地址 (Address)
    - `w`: 字 (Word, 32位)
    - `h`: 半字 (Halfword, 16位)
  - **示例**:
    - `x/32s 0x555555555eaa`: 从该地址开始查看 32 个字符串。
    - `x/32s $a0`: 查看寄存器 `$a0` 指向地址处的 32 个字符串。







### Starting and stopping your container

After the initial setup, you can start and stop with its assigned name

- **Start:** `docker container start rvemu`
- **Stop:** `docker container stop rvemu`

## Optional Setup

#### SSH key authentication

```
# Setup SSH key authentication
ssh-keygen
ssh-copy-id -p 2222 -f -i ~/.ssh/id_rsa.pub root@localhost
# When prompted for password, enter: csc3060
```

SSH key authentication is a quality of life feature that you can use to securely login to a remote server password-free. In this case, our *"remote server"* is our not so remote QEMU machine inside the container.

#### SSH config

Setting up a SSH config lets you login to a host without typing in the host IP address, port, and username. Using the config below, you can login by using `ssh debian-rv64`

```
# Setup SSH config
echo "
Host csc3060
   HostName 127.0.0.1
   User root
   Port 2222
" >> ~/.ssh/config
```

You can copy and paste the above into your bash shell to add the SSH config.