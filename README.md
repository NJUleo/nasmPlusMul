## OS hw1: nasm

#### 工具使用方式

##### 编译

nasm -felf64 -g kkp.asm

-g 增加调试信息，供gdb调试

##### 链接

ld kkp.o

##### makefile

```shell
install:
        nasm -g -felf32 kkp.asm
        ld  -m elf_i386 -o kkp kkp.o
clean:
        rm kkp kkp.o                 
```

##### readelf

读取符号表，可以读可重定向目标文件和可执行文件.

实际上一般可执行文件都是没有符号表的，符号都被对应的地址所代替，事实上这就是链接器做的事情。

```shell
readelf -s kkp.o
Symbol table '.symtab' contains 7 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS kkp.asm
     2: 0000000000000000     0 SECTION LOCAL  DEFAULT    1 
     3: 0000000000000000     0 SECTION LOCAL  DEFAULT    2 
     4: 0000000000000000     1 OBJECT  LOCAL  DEFAULT    1 msg
     5: 0000000000000007     0 NOTYPE  LOCAL  DEFAULT  ABS msglen
     6: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT    2 _start

readelf -s a.out
Symbol table '.symtab' contains 12 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 00000000004000b0     0 SECTION LOCAL  DEFAULT    1 
     2: 00000000006000d4     0 SECTION LOCAL  DEFAULT    2 
     3: 0000000000000000     0 SECTION LOCAL  DEFAULT    3 
     4: 0000000000000000     0 SECTION LOCAL  DEFAULT    4 
     5: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS kkp.asm
     6: 00000000006000d4     1 OBJECT  LOCAL  DEFAULT    2 msg
     7: 0000000000000007     0 NOTYPE  LOCAL  DEFAULT  ABS msglen
     8: 00000000004000b0     0 NOTYPE  GLOBAL DEFAULT    1 _start
     9: 00000000006000db     0 NOTYPE  GLOBAL DEFAULT    2 __bss_start
    10: 00000000006000db     0 NOTYPE  GLOBAL DEFAULT    2 _edata
    11: 00000000006000e0     0 NOTYPE  GLOBAL DEFAULT    2 _end
```

由此可以发现链接程序进行了一些重定向。

##### gdb调试

gdb -tui a.out

###### layout regs

显示寄存器状态和汇编源码信息（pc位置、断点等）

###### 断点设置

b 函数名/行号/地址。。。

info break 查看断点状况

delete <断点id> 删除断点

break sun if value==9 条件断点

###### 查看变量/寄存器

info reg查看寄存器

p $pc 查看pc，其他寄存器同理，前面加美元号

p/x 16进制

>    ​    d 按十进制格式显示变量。
>    ​    u 按十六进制格式显示无符号整型。
>    ​    o 按八进制格式显示变量。
>    ​    t 按二进制格式显示变量。
>    ​    a 按十六进制格式显示变量。
>    ​    c 按字符格式显示变量。
>    ​    f 按浮点数格式显示变量



###### 执行

countinue 继续

next 等于step over，不进入函数内部

step 等于step in, 进入函数

后面加 i 调试汇编

```shell
ni
si
si 10 # step 10 步汇编指令
```

#### 汇编语言语法

$ 当前指令地址

$$ 当前段地址

RESx	reserve

Dx	declare

![1571099589224](/home/leo/.config/Typora/typora-user-images/1571099589224.png)

##### 系统调用

stdout	1

stdin	0

##### 寄存器

###### General Registers

EAX	累加器

EBX	基址寄存器

ECX	计数器

EDX	数据寄存器

ESP	栈指针（栈顶）stack pointer

EBP	帧指针（栈底）stack-frame base pointer

ESI	

EDI

##### .bss 节



>SECTION .bss 
>
>variableName1:      RESB    1       ; 为一个字节保留(reserve)的空间 
>
>variableName2:      RESW    1       ; 为一个字保留(reserve)的空间 
>
>variableName3:      RESD    1       ; 为一个双字保留(reserve)的空间 
>
>variableName4:      RESQ    1       ; 为一个双精度浮点值保留(reserve)的空间 
>
>variableName5:      REST    1       ; 为一个拓展精度浮点值保留(reserve)的空间



##### 寄存器职责

##### 系统调用

| name      | eax(调用号) | ebx        | ecx      | edc             |
| --------- | ----------- | ---------- | -------- | --------------- |
| sys_read  | 3           | 文件描述符 | 文件地址 | 文件长度        |
| sys_write | 4           | 文件描述符 | 文件地址 | 文件长度/缓冲区 |
| sys_exit  | 1           | 错误码     |          |                 |



##### 数组

###### 存储

###### 访问

##### 控制结构

1. if-else
2. for
3. while
4. switch-case

##### 函数调用

* 调用者

###### 调用者保存

必要时保存对应寄存器。比如需要用来传参的寄存器，返回值eax。

###### 参数压栈

所有参数依次从右到左压栈。

###### call指令

自动保存返回地址

* 被调用者准备阶段

###### 保存EBP旧值，并更新EBP指向它

第一个参数地址是[EBP] + 8，以及更高地址（栈从高向低增长）

###### 被调用者保存

过程使用到的寄存器需要保存

* 被调用者过程体
* 被调用者结束阶段

###### 被调用者恢复

###### leave指令

恢复ebp旧值

###### ret指令

ret返回返回地址

#### 指令

一条指令的两个操作数必须有一个可以说明其类型即寻址的大小

#### 程序设计

##### 存储

| byte数组格式（BCD？） |      | “长int”格式（小端补码） | |
| ------------ | ---- | ---- | :--: |
| 优点 | 缺点 | 优点 | 缺点 |
| String转换方便（输入输出，两次） | | 加法计算时，以4B为单位（寄存器长度）计算 | String与此格式相互转换似乎比较麻烦？（等于在做10进制转2进制） |
|  | | 加减法统一，负数不必单独考虑 | |
|  | | | |
|  | | | |
|  | | | |

byte数组 + 长度 + 符号

小端存储，高位放高地址。

其实就是8421BCD码。

定长，长度为45byte。最高位byte为符号位，1负0正。

##### 全局变量

input1	输入数（不变）。

input2

op1	两个下面计算函数用的操作地址。

op2	

addResult

mulResult

##### 函数调用

###### getLongInt（char *  ecx)

读取一个字符串，将其转换为BCD码格式，存储在ecx位置。

循环获取字符，直到以/0结尾。

###### printLongInt(char * eax)

打印在ptr位置的longInt，到stdout。

###### addLongInt(longInt * eax, longInt * ebx, longInt * ecx)

计算两个long int的加和，结果放在[ecx]。

如果是一正一负就把

###### ecx addByte(char * eax, char * ebx, ecx)

两个byte加和，ecx为进位。结果存储在[eax]

###### subLongInt(longInt * eax, longInt * ebx, longInt * ecx)

计算两个long int的差，结果放在[ecx]。

###### ecx subByte(chat * eax, char * ebx, ecx)

计算两个Byte的差，自动借位。ecx表示借位，是1的时候表示被借了，返回表示下一位是否被借。

###### mulLongInt(longInt * eax, longInt * ebx, longInt * ecx)

计算两个longInt的积，结果放在[ecx]。

###### mulByte(longInt * eax, byte * ebx)

对longInt乘一个byte（一位的十进制数），结果放在[eax]。













