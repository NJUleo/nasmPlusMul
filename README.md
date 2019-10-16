# nasmPlusMul

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
