section .data
    gdt64:
        dq 0
        dq 0x0020980000000000
        dq 0x0020f80000000000
        dq 0x0000f20000000000
    tssDesc:
        dw tssLen - 1
        dw 0
        db 0
        db 0x89
        db 0
        db 0
        dq 0
    gdt64Len: equ $ - gdt64
    gdt64Ptr: dw gdt64Len - 1
            dq gdt64

    tss:
        dd 0
        dq 0xffff800000190000
        times 88 db 0
        dd tssLen
    tssLen: equ $-tss
section .text
    extern KMain
    global start

    start:
        mov rax, gdt64Ptr
        lgdt [rax]
    setTss:
        mov rax, tss
        mov rdi, tssDesc
        mov [rdi+2], ax
        shr rax, 16
        mov [rdi+4], al
        shr rax, 8
        mov [rdi+7], al
        shr rax, 8
        mov [rdi+8], eax

        mov ax, 0x20
        ltr ax

    initPIT:
        mov al, (1 << 2) | (3 << 4)
        out 0x43, al

        mov ax, 11931
        out 0x40, al
        mov al, ah
        out 0x40, al

    initPIC:
        mov al, 0x11
        out 0x20, al
        out 0xa0, al

        mov al, 32
        out 0x21, al
        mov al, 40
        out 0xa1, al

        mov al, 4
        out 0x21, al
        mov al, 2
        out 0xa1, al

        mov al, 1
        out 0x21, al
        out 0xa1, al

        mov al, 0b11111110
        out 0x21, al
        mov al, 0b11111111
        out 0xa1, al

        mov rax, KernelEntry
        push 8
        push rax
        db 0x48
        retf
    KernelEntry:
        mov rsp, 0xffff800000200000
        call KMain
        sti

    end:
        hlt
        jmp end