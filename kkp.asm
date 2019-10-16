SECTION .data
msg db "KKP!!!",0ah;0ah(ASCII码：换行符)，odh(ASCII码：回车符)
msglen equ ($ - msg)

SECTION .bss
input1  resb    45
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
    push 44d ;remain剩余可读的位数，存于ebp - 20。44是因为，最后一位在ptr + 44 * 4的位置。

;过程体
getLongIntReadByte:;读取一个byte到buf
    mov eax, 3d
    mov ebx, 0d;stdin
    mov ecx, byteBuf
    mov edx, 1d;读一个byte
    int 80h

    ;如是空格或者换行就把inputBuf按正确顺序放到ptr中并结束
    mov eax, [byteBuf];取出这个地址的值而不是这个符号的地址
    cmp eax, 32d;空格
    je getLongIntInvertBuff
    cmp eax, 10d;换行
    je getLongIntInvertBuff

    ;将读到的字符放在 [inputBuf + 剩余位数]
    mov eax, [ebp - 20];eax = remain
    mov ebx, inputBuf;ebx = inputBuf
    mov cl, byte[byteBuf]
    mov byte[eax + ebx], cl;从这两个地址传送一个byte
    ;remain减去1
    mov eax, [ebp - 20];eax = remain
    dec eax;eax--
    mov [ebp - 20], eax;remain = eax

    
    jmp getLongIntReadByte

getLongIntInvertBuff:    
    ;ecx为计数器，从44 - remain 到 0。每次ptr[remain + ecx + 1] = inputBuf[44 - ecx]
    mov ecx, 44d
    mov ebx, [ebp - 20]
    sub ecx, ebx
    ;循环
getLongIntInvertBuffLoop:
    js getLongIntEnd;ecx小于0时完事


    ;ptr[reamin + ecx] = inputBuf[44 - ecx]
    ;dl = inputBuf[44 - ecx]
    mov eax, 44
    sub eax, ecx
    mov ebx, inputBuf
    mov dl, byte[ebx + eax]
    sub edx, 30h
    ;ptr[remain + ecx + 1] = dl
    mov eax, [ebp - 20];eax = remain
    add eax, ecx; eax += evx
    inc eax;eax++
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
