SECTION .data
msg db "KKP!!!",0ah;0ah(ASCII码：换行符)，odh(ASCII码：回车符)
msglen equ ($ - msg)

SECTION .bss
input1  resb    45;Q:res部分是初始化为0？
input2  resb    45
inputBuf    resb    45
op1 resb    45
op2 resb    45
addResult   resb    45
mulResult   resb    45
byteBuf resb    1

SECTION .text
global _start


_start:

    ;打印kkp，作为程序的开始
    push eax
    call printKKP
    pop eax

    ;分别获取两个input
    ;lea ecx, input1
    mov ecx, input1
    call getLongInt
    mov ecx, input2
    call getLongInt

    ;debug, 打印两个longInt
    mov ecx, input1
    call printLongInt
    

    mov ebx, 0d
    mov eax, 1d
    int 80h


printKKP:
    ;准备阶段
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx

    ;过程体
    mov eax, 4d
    mov ebx, 1d
    mov ecx, msg
    mov edx, msglen
    int 80h

    ;结束阶段
    pop edx
    pop ecx
    pop ebx 
    leave
    ret


getLongInt:
;准备阶段
    push ebp
    mov ebp, esp
    push eax;pusha就可以
    push ebx
    push edx

;局部变量
    push ecx    ;ptr 地址，存于ebp - 16
    push 44d ;remain剩余可读的位数，存于ebp - 20。44是因为，最后一位在ptr + 44的位置。

;过程体
getLongIntReadByte:;读取一个byte到buf
    mov eax, 3d
    mov ebx, 0d;stdin
    mov ecx, byteBuf
    mov edx, 1d;读一个byte
    int 80h

    ;如果是负号，就把ptr位置设置为1（负数）
    ;如是空格或者换行就把inputBuf按正确顺序放到ptr中并结束。
    mov eax, [byteBuf];取出这个地址的值而不是这个符号的地址
    cmp eax, 32d;空格
    je getLongIntInvertBuff
    cmp eax, 10d;换行
    je getLongIntInvertBuff
    cmp eax, 45d;负号
    jne getLongIntReadByteNotNeg
    mov ebx, dword[ebp - 16]
    mov byte[ebx], 1d
    ;remain减去1
    mov eax, [ebp - 20];eax = remain
    dec eax;eax--
    mov [ebp - 20], eax;remain = eax。
    jmp getLongIntReadByte

getLongIntReadByteNotNeg:
    ;将读到的字符放在 [inputBuf + 剩余位数]
    mov eax, [ebp - 20];eax = remain
    mov ebx, inputBuf;ebx = inputBuf
    mov cl, byte[byteBuf]
    mov byte[eax + ebx], cl;从这两个地址传送一个byte
    ;remain减去1
    mov eax, [ebp - 20];eax = remain
    dec eax;eax--
    mov [ebp - 20], eax;remain = eax。此时，ptr + remain指向最高空字符位置

    
    jmp getLongIntReadByte

getLongIntInvertBuff:    
    ;ecx为计数器，从44 - remain 到 1。每次ptr[remain + ecx] = inputBuf[45 - ecx]
    mov ecx, 44d
    mov ebx, [ebp - 20]
    sub ecx, ebx;ecx = 44 - remain
    ;循环
getLongIntInvertBuffLoop:
    je getLongIntEnd;ecx等于0时完事


    ;ptr[remain + ecx] = inputBuf[45 - ecx]
    ;dl = inputBuf[45 - ecx]
    mov eax, 45
    sub eax, ecx;eax = 45 - ecx
    mov ebx, inputBuf
    mov dl, byte[ebx + eax]
    sub edx, 30h;减去0 的ascii码
    ;ptr[remain + ecx] = dl
    mov eax, [ebp - 20];eax = remain
    add eax, ecx; eax += ecx
    mov ebx, [ebp - 16];ebx = ptr
    mov byte[ebx + eax], dl

    dec ecx
    jmp getLongIntInvertBuffLoop


;结束阶段
getLongIntEnd:
    add esp, 8;栈指针指向被调用者保存的第一个寄存器。
    pop edx
    pop ebx
    pop eax 
    leave
    ret


printLongInt:
    ;准备阶段
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push edx
    ;局部变量
    push ecx;ptr,起始位置，ebp - 16

    ;过程体
    ;第一个byte是1则打印负号。用ebx指向ptr，ecx变址（计数器）,eax作为比较.
    mov ebx, [ebp - 16];ebx = ptr
    mov ecx, 0
    mov eax, [ebx + ecx];eax = [ptr + 1]

    cmp eax, 1;
    jne printLongIntStartLoop;如果不是1就不用打印符号
    ;打印负号
    push ebx;保存两个寄存器，然后使用系统调用
    push eax
    push ecx
    mov byte[byteBuf], 45d;将负号放到缓冲区
    mov eax, 4d
    mov ebx, 1d
    mov ecx, byteBuf;ecx = bytebuf
    mov edx, 1d
    int 80h
    pop ecx
    pop eax
    pop ebx
printLongIntStartLoop:
    ;循环指向第一个非0字符. 地址为ebx + ecx，循环结束为ecx == 44
    inc ecx;    ecx++
    mov eax, [ebx + ecx]
    cmp al, 0
    je printLongIntStartLoop;此时ebx + ecx指向最高位。（ecx最大是44）
printLongIntPrintLoop:
    ;打印一个字符
    mov al, byte[ebx + ecx]
    add eax, 30h;数值转ascii 加30h
    mov byte[byteBuf], al;byteBuf = [ebx + ecx]
    push ebx
    push ecx
    mov eax, 4d
    mov ebx, 1d
    mov ecx, byteBuf
    mov edx, 1d
    int 80h
    pop ecx
    pop ebx
    ;如果ecx到达44，退出。不然继续ecx++循环
    cmp ecx, 44d
    je printLongIntEnd
    inc ecx
    jmp printLongIntPrintLoop

    ;结束阶段
printLongIntEnd:
    ;先打印一个换行
    mov al, 10d
    mov byte[byteBuf], al
    mov eax, 4d
    mov ebx, 1d
    mov ecx, byteBuf
    mov edx, 1d
    int 80h
    add esp, 4;栈指针指向被调用者保存的第一个寄存器
    pop edx
    pop ecx
    pop ebx 
    leave
    ret