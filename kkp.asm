SECTION .data
msg db "KKP!!!",0ah;0ah(ASCII码：换行符)，odh(ASCII码：回车符)
msglen equ ($ - msg)
subOverflow db 0x
zero db "0"

SECTION .bss
input1  resb    44;Q:res部分是初始化为0？
input2  resb    44
inputBuf    resb    44
op1 resb    44
op2 resb    44
addResult   resb    44
mulResult   resb    44
byteBuf resb    1
zeroLongInt resb    44

SECTION .text
global _start


_start:
    ;局部变量
    ;sub esp, 44
    ;debug


    ;打印kkp，作为程序的开始
    ;call printKKP

    ;分别获取两个input,存在input1和input2
    ;lea ecx, input1
    mov ecx, input1
    call getLongInt
    mov ecx, input2
    call getLongInt


    ;debug, 打印两个longInt
    ;mov ecx, input1
    ;call printLongInt
    ;mov ecx, input2
    ;call printLongInt

    ;计算和
    push eax
    push ebx
    push ecx
    mov eax, input1
    mov ebx, input2
    mov ecx, addResult
    call addLongInt
    mov ecx, addResult
    call printLongInt
    pop ecx
    pop ebx
    pop eax

    ;计算积.debug 乘2试一下 mulResult *= 2
    push eax
    push ebx
    push ecx
    mov eax, input1
    mov ebx, input2
    mov ecx, mulResult
    call mulLongInt
    mov ecx, mulResult
    call printLongInt
    pop ecx
    pop ebx
    pop eax
  

    mov ebx, 0d
    mov eax, 1d
    int 80h


printKKP:
    ;准备阶段
    push ebp
    mov ebp, esp
    push eax
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
    pop eax 
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
    push 43d ;remain剩余可读的位数，存于ebp - 20。43是因为，最后一位在ptr + 43的位置。

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
    mov ebx, dword[ebp - 16];ebx = ptr
    mov byte[ebx], 1d;[ptr] = 1
    ;remain减去1（不需要？）
    ;mov eax, [ebp - 20];eax = remain
    ;dec eax;eax--
    ;mov [ebp - 20], eax;remain = eax。
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
    ;ecx为计数器，从43 - remain 到 1。每次ptr[remain + ecx] = inputBuf[44 - ecx]
    mov ecx, 43d
    mov ebx, [ebp - 20]
    sub ecx, ebx;ecx = 43 - remain
    ;循环
getLongIntInvertBuffLoop:
    je getLongIntEnd;ecx等于0时完事


    ;ptr[remain + ecx] = inputBuf[44 - ecx]
    ;dl = inputBuf[44 - ecx]
    mov eax, 44
    sub eax, ecx;eax = 44 - ecx
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
    ;消除函数副作用，把inputBuff置为0
    push eax
    push ebx
    mov eax, zeroLongInt
    mov ebx, inputBuf
    call cpLongInt
    pop ebx
    pop eax

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
    ;循环指向第一个非0字符，或者ecx == 44. 地址为ebx + ecx，循环结束为ecx == 43
    inc ecx;    ecx++
    cmp ecx, 44
    je printLongIntZero
    mov eax, [ebx + ecx]
    cmp al, 0
    je printLongIntStartLoop
;此时ebx + ecx指向最高位。（ecx最大是43）
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
    ;如果ecx到达43，退出。不然继续ecx++循环
    cmp ecx, 43d
    je printLongIntEnd
    inc ecx
    jmp printLongIntPrintLoop
printLongIntZero:
    mov eax, 4
    mov ebx, 1d
    mov ecx, zero
    mov edx, 1d
    int 80h
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


cpLongInt:
    ;准备阶段
    push ebp
    mov ebp, esp
    push ecx
    push edx

    ;过程体
    mov ecx, 10;ecx计数，ecx从0到10。每次dest[ecx * 4] = src[ecx * 4]
cpLongIntLoop:
    mov edx, dword[eax + ecx * 4]
    mov dword[ebx + ecx * 4], edx;dest[ecx * 4] = src[ecx * 4]
    dec ecx
    js cpLongIntEnd;小于0就结束
    jmp cpLongIntLoop

    ;结束阶段
cpLongIntEnd:
    pop edx
    pop ecx
    leave
    ret

addLongInt:
;准备阶段
    push ebp
    mov ebp, esp
    push edx

;局部变量
    push eax;ptr1 [ebp - 8]
    push ebx;ptr2 [ebp - 12]
    push ecx;ptrResult [ebp - 16]
    

    ;过程体
    ;判断如果第一个是负数,
    mov al, byte[eax]
    ;mov指令不改变eflags
    add al, 0
    jz addLongIntIsFirstPos;第一个正
    jmp addLongIntIsFirstNeg;第一个负
addLongIntIsFirstPos:
    mov al, byte[ebx]
    add al, 0
    jz addLongIntAllPos;正的时候是全正
    jmp addLongIntPosNeg;正负，调用减法
addLongIntIsFirstNeg:
    mov al, byte[ebx]
    add al, 0
    jz addLongIntNegPos;负正
    jmp addLongIntAllNeg;全负数
addLongIntPosNeg:
    push eax
    push ebx
    push ecx
    mov eax, dword[ebp - 8]
    mov ebx, dword[ebp - 12]
    mov ecx, dword[ebp - 16]
    call subLongIntPos
    push ecx
    pop ebx
    pop eax
    jmp addLongIntEnd
addLongIntNegPos:
    push eax
    push ebx
    push ecx
    mov eax, dword[ebp - 12]
    mov ebx, dword[ebp - 8]
    mov ecx, dword[ebp - 16]
    call subLongIntPos
    push ecx
    pop ebx
    pop eax
    jmp addLongIntEnd
addLongIntAllNeg:
    push eax
    push ebx
    push ecx
    mov eax, dword[ebp - 8]
    mov ebx, dword[ebp - 12]
    mov ecx, dword[ebp - 16]
    call addLongIntPos
    push ecx
    pop ebx
    pop eax
    ;结果取负
    mov al, 1
    mov ebx, [ebp - 16];j结果取负
    mov byte[ebx], al
    jmp addLongIntEnd

addLongIntAllPos:
    push eax
    push ebx
    push ecx
    mov eax, dword[ebp - 8]
    mov ebx, dword[ebp - 12]
    mov ecx, dword[ebp - 16]
    call addLongIntPos
    push ecx
    pop ebx
    pop eax
    jmp addLongIntEnd



    ;结束阶段
addLongIntEnd:
    add esp, 12d;局部变量退栈
    pop edx
    leave
    ret

addLongIntPos:;两个LontInt相加，默认认为两个数是正（最高位是0），结果设置为正数
    ;准备阶段
    push ebp
    mov ebp, esp
    push edx
    ;局部变量
    push eax;ptr1,[ebp - 8]
    push ebx;ptr2, [ebp - 12]
    push ecx; resultPtr, [ebp - 16]

    ;过程体
    ;循环，ecx从43到1。计算[ebp - 16] = [[ebp - 8] + ecx] + [[ebp - 12] + ecx]
    ;edx 保存上一次的进位。
    mov ecx, 43
    mov edx, 0
addLongIntPosAddLoop:
    mov eax, 0
    mov ebx, dword[ebp - 8];ebx = ptr1
    mov bl, byte[ebx + ecx];bl = [ptr1 + ecx]
    and ebx, 0xFF;取b的最后一个byte
    add eax, ebx;eax += ebx
    mov ebx, dword[ebp - 12];ebx = ptr2
    mov bl, byte[ebx + ecx];bl = [ptr2 + ecx]
    and ebx, 0xFF
    add eax, ebx;eax += ebx
    add eax, edx;eax += edx, 加上上次的进位
    ;设置进位
    cmp eax, 10d
    jae addLongIntPosAddLoopJinWei;大于等于10，需要进位
    mov edx, 0
addLongIntPosAddLoopEnd:
    ;保存到resultPtr对应位置。
    mov ebx, dword[ebp - 16];ebx = resultPtr
    mov byte[ebx + ecx], al;
    dec ecx
    jz addLongIntPosEnd;ecx == 0的时候结束
    jmp addLongIntPosAddLoop
addLongIntPosAddLoopJinWei:
    mov edx, 1;进位为1
    sub eax, 10;把10去掉
    jmp addLongIntPosAddLoopEnd



    ;结束阶段
addLongIntPosEnd:
    sub esp, 12;局部变量退栈
    pop edx
    leave
    ret


subLongIntPos:;两个LontInt相减，默认认为两个数是正（最高位是0）
    ;准备阶段
    push ebp
    mov ebp, esp
    push edx
    ;局部变量
    push eax;ptr1,[ebp - 8]
    push ebx;ptr2, [ebp - 12]
    push ecx; resultPtr, [ebp - 16]

    ;过程体
    ;循环，ecx从43到1。计算[ebp - 16] = [[ebp - 8] + ecx] - [[ebp - 12] + ecx]
    ;edx 保存上一次的进位。
    mov ecx, 43
    mov edx, 0
subLongIntPosAddLoop:
    mov eax, 0
    mov ebx, dword[ebp - 8];ebx = ptr1
    mov bl, byte[ebx + ecx];bl = [ptr1 + ecx]
    and ebx, 0xFF;取b的最后一个byte
    add eax, ebx;eax += ebx
    mov ebx, dword[ebp - 12];ebx = ptr2
    mov bl, byte[ebx + ecx];bl = [ptr2 + ecx]
    and ebx, 0xFF
    sub eax, ebx;eax -= ebx
    sub eax, edx;eax -= edx, 减去上次的进位
    ;设置进位
    js subLongIntPosAddLoopJieWei;小于0，需要借位
    mov edx, 0
subLongIntPosAddLoopEnd:
    ;保存到resultPtr对应位置。
    mov ebx, dword[ebp - 16];ebx = resultPtr
    mov byte[ebx + ecx], al;
    dec ecx
    jz subLongIntPosLoopEnd;ecx == 0的时候结束
    jmp subLongIntPosAddLoop
subLongIntPosAddLoopJieWei:
    mov edx, 1;借位为1
    add eax, 10;加上10
    jmp subLongIntPosAddLoopEnd


    ;结束阶段
subLongIntPosLoopEnd:
    ;如果在最后的时候，借位为1，说明结果是负数，发生了溢出。这时候把最高位设置为0，用1000……0减去它。
    sub edx, 1
    jnz subLongIntPosEnd
    ;做溢出处理
    ;缓冲inputBuf设置为0
    mov eax, zeroLongInt
    mov ebx, inputBuf
    call cpLongInt
    ;把inputBuf的最高位设置为1
    mov al, 1d
    mov byte[ebx + 1], al
    ;[resultptr + 1] = 0, [resultPtr] = 1,把结果的最高位设置为负，次高位减去1。
    mov ebx, [ebp - 16]
    mov al, 0d
    mov byte[ebx + 1], al
    mov al, 1d
    mov byte[ebx], al

    ;100……0 - result
    push eax
    push ebx
    push ecx
    mov eax, inputBuf
    mov ebx, [ebp - 16]
    mov ecx, [ebp - 16]
    call subLongIntPos
    pop ecx
    pop ebx
    pop eax
    ;buf清零
    mov eax, zeroLongInt
    mov ebx, inputBuf
    call cpLongInt
subLongIntPosEnd:
    sub esp, 12;局部变量退栈
    pop edx
    leave
    ret
mulByte:
    ;准备阶段
    push ebp
    mov ebp, esp
    push ecx
    push edx
    
    ;局部变量
    push eax;ptrLongInt, [ebp - 12]
    push ebx;Byte, [ebp - 16]，这里要考虑ebx的前3个byte非零的情况，只需要取bl

    ;过程体
    ;循环，ecx从43到1。计算[[ebp - 12] + ecx] = byte[[ebp - 12] + ecx] * Byte + JinWei
    ;edx 保存上一次的进位。
    mov ecx, 43
    mov edx, 0
mulByteLoop:;计算结果放在ax，bl放Byte
    mov eax, dword[ebp -12]
    mov al, byte[eax + ecx]
    mov ebx, dword[ebp - 16]
    and eax, 0xFF
    and ebx, 0xFF
    mul bl;一个byte乘以一个byte，结果在ax中，8byte
    add eax, edx;加上进位
    ;设置进位
    cmp ax, 10d
    jae mulByteLoopJinWei;大于等于10，需要进位
    mov edx, 0;小于10，进位设置为0
mulByteLoopEnd:
    ;保存到resultPtr对应位置。
    mov ebx, dword[ebp - 12];ebx = ptrLongInt
    mov byte[ebx + ecx], al;这里取byte是因为所有大于等于10的被搞成一个十进制位了。
    dec ecx
    jz mulByteEnd;ecx == 0的时候结束
    jmp mulByteLoop
mulByteLoopJinWei:
;除法时候涉及到两个寄存器eax edx，做个保存，也许不需要，但是防御性编程嘛，可以接受
    mov dl, 10d
    and edx, 0xFF
    div dl;余数在ah，商在al,商是进位，余数是al
    mov dl, al
    mov al, ah
    and eax, 0xFF
    and edx, 0xFF

    jmp mulByteLoopEnd
mulByteEnd:
    ;结束阶段
    add esp, 8d;局部变量出栈
    pop edx
    pop ecx
    leave
    ret
mulLongIntPos:
    ;准备阶段
    push ebp
    mov ebp, esp
    push edx
;局部变量
    push eax;ptr1 [ebp - 8]
    push ebx;ptr2 [ebp - 12]
    push ecx;resultPtr [ebp - 16]

    ;过程体
    ;resultPtr = 0
    push eax
    push ebx
    mov eax, zeroLongInt
    mov ebx, dword[ebp - 16]
    call cpLongInt
    pop ebx
    pop eax
    ;ecx = 1
    mov ecx, 1d
mulLongIntPosLoop:
    ;循环，ecx从1到43，
    ;计算mulByte(resultPtr, 10d),
    push eax
    push ebx
    mov eax, dword[ebp - 16]
    mov bl, 10d
    and ebx, 0xFF
    call mulByte
    pop ebx
    pop eax
    ;[inputBuf] = [ptr1]
    push eax
    push ebx
    mov eax, [ebp - 8]
    mov ebx, inputBuf
    call cpLongInt
    pop ebx
    pop eax
    ;mulByte(inputBuf, [ptr2 + ecx])
    push eax
    push ebx
    mov eax, inputBuf
    mov ebx, [ebp - 12]
    mov bl, byte[ebx + ecx];ebx = [ptr2 + ecx]
    and ebx, 0xFF
    call mulByte
    pop ebx
    pop eax
    ;[resultPtr] += [inputBuf]
    push eax
    push ebx
    push ecx
    mov eax, [ebp - 16];eax = resultPtr
    mov ebx, inputBuf;ebx = inputBuf
    mov ecx, [ebp - 16];ecx = resultPtr
    call addLongIntPos
    pop ecx
    pop ebx
    pop eax
    ;ecx = 43时退出
    cmp ecx, 43d
    jz mulLongIntPosEnd
    ;ecx++
    inc ecx
    ;回到循环
    jmp mulLongIntPosLoop

mulLongIntPosEnd:
    ;结束阶段
    add esp, 12d;局部变量出栈
    pop edx
    leave
    ret

mulLongInt:
        ;准备阶段
    push ebp
    mov ebp, esp
    push edx

    ;局部变量
    push eax;ptr1 [ebp - 8]
    push ebx;ptr2 [ebp - 12]
    push ecx;resultptr [ebp -16]

    ;过程体
    ;计算
    push eax
    push ebx
    push ecx
    call mulLongIntPos
    pop ecx
    pop ebx
    pop eax
    ;符号为两个符号的异或
    mov eax, 0d
    mov ebx, dword[ebp - 8]
    mov al, byte[ebx]
    mov ebx, dword[ebp - 12]
    mov bl, byte[ebx]
    xor al, bl
    mov ebx, dword[ebp - 16]
    mov byte[ebx], al

    ;结束阶段
    add esp, 12d;局部变量出栈
    pop edx
    leave
    ret