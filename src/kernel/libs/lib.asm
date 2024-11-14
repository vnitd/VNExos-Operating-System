section .text
global memset
global memmov
global memcpy
global memcmp

memset:
    cld
    mov ecx, edx ; edx = size
    mov al, sil  ; rsi = value
    rep stosb    ; copy value in al to the memory addressed by rdi register
    ret

memcmp:
    cld
    xor eax, eax
    mov ecx, edx ; edx = size
    repe cmpsb
    setnz al
    ret

memcpy:
memmov:
    cld
    cmp rsi, rdi
    jae .copy
    mov r8, rsi
    add r8, rdx
    cmp r8, rdi
    jbe .copy
.overlap:
    std
    add rdi, rdx
    add rsi, rdx
    sub rdi, 1
    sub rsi, 1

.copy:
    mov ecx, edx
    rep movsb
    cld
    ret
