[bits 16]
[org 0x7c00]
 
start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
 
testDiskExt:
    mov [driveId], dl
 
    mov ah, 0x41  ; Set EDD check
    mov bx, 0x55aa  ; Crash may happen
    int 0x13
    jc  notSupport
    cmp bx, 0xaa55
    jne notSupport
 
startLoader:
    mov si, readPacket
    mov word[si],      0x10
    mov word[si+2],    4
    mov word[si+4],    0x7e00
    mov word[si+6],    0
    mov dword[si+8],   1
    mov dword[si+0xc], 0
 
    mov dl, [driveId]
    mov ah, 0x42
    int 0x13
    jc  readError
 
    mov dl, [driveId]
    jmp 0x7e00
 
readError:
notSupport:
    mov ah, 0x13
    mov al, 1
    mov bx, 0xc
    xor dx, dx
    mov bp, message
    mov cx, messageLen
    int 0x10
 
end:
    hlt
    jmp end
 
driveId:    db 0
message:    db "Error occured in boot process!"
messageLen: equ $-message
readPacket: times 16 db 0
 
times (0x1be-($-$$)) db 0
 
    db 80h
    db 0, 2, 0
    db 0xf0
    db 0xff, 0xff, 0xff
    dd 1
    dd (20*16*63 - 1)
 
    times (16*3) db 0
 
    db 0x55
    db 0xaa