[bits 16]
[org 0x7e00]
 
start:
    mov [driveId], dl
 
    mov ah, 0x00
    mov al, 0x02            ; 80x25 text mode
    int 0x10                ; reset the screen
 
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb notSupport
 
    mov eax, 0x80000001
    cpuid
    test edx, (1<<29)
    jz notSupport
    test edx, (1<<26)
    jz notSupport
 
checkA20Line:
    mov ax, 0xffff
    mov es, ax
    mov word[ds:0x7c00], 0xa200
    cmp word[es:0x7c00], 0xa200
    jne setA20LineDone
 
    mov word[0x7c00], 0xb200
    cmp word[es:0x7c10], 0xb200
    je exit
 
setA20LineDone:
    mov ah, 0x00
    mov al, 0x02
    int 0x10
 
getMemInfoStart:
    xor ebx, ebx
    xor ax, ax
    mov dword[0x9000], 0
    mov es, ax
    mov di, 0x9008
    .loop:
        mov eax, 0xe820
        mov ecx, 20
        mov edx, 0x534d4150
        int 0x15
        jc notSupport
        inc dword[0x9000]
        add di, 20
 
        cmp edx, 0x534d4150
        jne notSupport
       
        test ebx, ebx
        jnz .loop
 
switchToGraphicsMode:
    ; setup vbe info structure
    xor ax, ax
    mov es, ax
    mov ah, 0x4f
    mov di, vbe_info_block
    int 0x10
 
    cmp al, 0x4f
    jne vbeError
 
    mov ax, word [vbe_info_block.video_mode_pointer]
    mov [offset], ax
    mov ax, word [vbe_info_block.video_mode_pointer+2]
    mov [t_segment], ax
 
    mov fs, ax
    mov si, [offset]
 
    .find_mode:
        mov dx, [fs:si]
        add si, 2
        mov [offset], si
        mov [mode], dx
 
        cmp dx, word 0xffff
        je .end_of_modes
 
        mov ax, 0x4f01
        mov cx, [mode]
        mov di, mode_info_block
        int 0x10
 
        cmp ax, 0x4f
        jne vbeError
 
        ; mov dx, [mode]
        ; call print_hex
        ; mov si, divider
        ; call print_string
 
        ; mov dx, [mode_info_block.x_resolution]
        ; call print_hex
        ; mov si, divider
        ; call print_string
 
        ; mov dx, [mode_info_block.y_resolution]
        ; call print_hex
        ; mov si, divider
        ; call print_string
 
        ; xor dh, dh
        ; mov dl, [mode_info_block.bits_per_pixel]
        ; call print_hex    ; Print bpp
        ; mov ax, 0E0Ah ; Print a newline
        ; int 10h
        ; mov al, 0Dh
        ; int 10h
 
        ;; Compare values with desired values
        mov ax, [width]
        cmp ax, [mode_info_block.x_resolution]
        jne .next_mode
 
        mov ax, [height]                    
        cmp ax, [mode_info_block.y_resolution]
        jne .next_mode
 
        mov ax, [bpp]
        cmp al, [mode_info_block.bits_per_pixel]
        jne .next_mode
 
        ; mov ax, 4F02h ; Set VBE mode
        ; mov bx, [mode]
        ; or bx, 4000h  ; Enable linear frame buffer, bit 14
        ; xor di, di
        ; int 10h
 
        ; cmp ax, 4Fh
        ; jne vbeError
 
        jmp .done
    .next_mode:
        mov ax, [t_segment]
        mov fs, ax
        mov si, [offset]
        jmp .find_mode
 
    .end_of_modes:
        jmp vbeError
    .done:
 
loadKernel:
    mov si, readPacket
    mov word[si],      0x10
    mov word[si+2],    100
    mov word[si+4],    0
    mov word[si+6],    0x1000
    mov dword[si+8],   5
    mov dword[si+0xc], 0
 
 
    mov dl, [driveId]
    mov ah, 0x42
    int 0x13
    jc  notSupport
setupGDT:
 
    cli
    lgdt [gdt32Ptr]
    lidt [idt32Ptr]
 
    mov eax, cr0
    or eax, 1
    mov cr0, eax
 
    jmp 0x08:PMEntry
 
 
vbeError:
    mov si, vbeErrorMsg
    call print_string
    jmp exit
notSupport:
    mov si, notSp
    call print_string
    jmp exit
 
print_string:
    pusha
    mov ah, 0x0e
    .loop:
        lodsb
        cmp al, 0
        je  .done
        int 0x10
        jmp .loop
    .done:
        popa
    ret
 
print_new_line:
    pusha
    mov ah, 0x0e
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    popa
    ret
clear:
    pusha
    mov ah, 0x00
    mov al, 0x02            ; 80x25 text mode
    int 0x10                ; reset the screen
    popa
    ret
 
[BITS 32]
PMEntry:
    ; mov byte [0xe0000000], 0xff
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7c00
 
    cld
    mov edi, 0x70000
    xor eax, eax
    mov ecx, 0x10000/4
    rep stosd
 
    mov dword[0x70000], 0x71003
    mov dword[0x71000], 10000011b

    mov eax, (0xffff800000000000>>39)
    and eax, 0x1ff
    mov dword[0x70000+eax*8], 0x72003
    mov dword[0x72000], 10000011b
 
    lgdt [gdt64Ptr]
 
    mov eax, cr4
    or eax, (1<<5)
    mov cr4, eax
 
    mov eax, 0x70000
    mov cr3, eax
 
    mov ecx, 0xc0000080
    rdmsr
    or eax, (1<<8)
    wrmsr
 
    mov eax, cr0
    or eax, (1<<31)
    mov cr0, eax
 
    jmp 8:LMEntry
[BITS 64]
LMEntry:
    mov rsp, 0x7c00

    ; mov byte[0xb8001], 0x0a
    ; mov byte[0xb8000], 'L'
 
    cld
    mov rdi, 0x200000
    mov rsi, 0x10000
    mov rcx, 51200/8
    rep movsq
    
    mov rax, 0xffff800000200000
    jmp rax

 
exit:
    hlt
    jmp exit
 
hex_to_ascii: db '0123456789abcdef'
hex_string:   db '0000'
driveId:      db 0
readPacket:   times 16 db 0
hexPrefix:    db '0x', 0
notSp:        db 'Not support!', 0
divider:      db ' | ', 0
vbeErrorMsg:  db 'Error occured in vbe setup phase!', 0
offset:       dw 0
t_segment:    dw 0
mode:         dw 0
key_buffer:   db 0
 
timeval:
    .tv_sec:  dd 0
    .tv_nsec: dd 0
 
bpp: db 32
width: dw 1280
height: dw 720
 
gdt32:
    dq 0
code32:
    dw 0xffff
    dw 0
    db 0
    db 0x9a
    db 0xcf
    db 0
data32:
    dw 0xffff
    dw 0
    db 0
    db 0x92
    db 0xcf
    db 0
gdt32Len: equ $-gdt32
 
gdt32Ptr: dw gdt32Len - 1
          dd gdt32
 
 
idt32Ptr: dw 0
          dd 0
 
gdt64:
    dq 0
    dq 0x0020980000000000
 
gdt64Len: equ $ - gdt64
gdt64Ptr: dw gdt64Len - 1
          dd gdt64
 
 
times 1024-($-$$) db 0
 
vbe_info_block:
    .vbe_signature:             db 'VESA'   ; 4
    .vbe_version:               dw 0x0300   ; 2
    .oem_string_pointer:        dd 0        ; 4
    .capabilities:              dd 0        ; 4
    .video_mode_pointer:        dd 0        ; 4
    .total_memory:              dw 0        ; 2
    .oem_software_version:      dw 0        ; 2
    .oem_vendor_name_pointer:   dd 0        ; 4
    .oem_product_name_pointer:  dd 0        ; 4
    .oem_product_rev_pointer:   dd 0        ; 4
    .reserved:        times 222 db 0        ; 222
    .oem_data:        times 256 db 0        ; 256
 
mode_info_block:
    ; Mandatory info for all VBE revisions
    .mode_attributes:           dw 0        ; 2
    .window_a_attributes:       db 0        ; 1
    .window_b_attributes:       db 0        ; 1
    .window_granularity:        dw 0        ; 2
    .window_size:               dw 0        ; 2
    .window_a_segment:          dw 0        ; 2
    .window_b_segment:          dw 0        ; 2
    .window_function_pointer:   dd 0        ; 4
    .bytes_per_scanline:        dw 0        ; 2
                                            ; 18
    ; Mandatory info for VBE 1.2 and above
    .x_resolution:              dw 0        ; 2
    .y_resolution:              dw 0        ; 2
    .x_charsize:                db 0        ; 1
    .y_charsize:                db 0        ; 1
    .number_of_planes:          db 0        ; 1
    .bits_per_pixel:            db 0        ; 1
    .number_of_banks:           db 0        ; 1
    .memory_model:              db 0        ; 1
    .bank_size:                 db 0        ; 1
    .number_of_image_pages:     db 0        ; 1
    .reserved1:                 db 0        ; 1
                                            ; 13
    ; Direct color fields (required for direct/6 and YUV/7 memory models)
    .red_mask_size:             db 0
    .red_field_position:        db 0
    .green_mask_size:           db 0
    .green_field_position:      db 0
    .blue_mask_size:            db 0
    .blue_field_position:       db 0
    .reserved_mask_size:        db 0
    .reserved_field_position:   db 0
    .direct_color_mode_info:    db 0
 
    ; Mandatory info for VBE 2.0 and above
    .physical_base_pointer:     dd 0        ; 4
    .reserved2:                 dd 0        ; 4
    .reserved3:                 dw 0        ; 2
 
    ; Mandatory info for VBE 3.0 and above
    .linear_bytes_per_scan_line:dw 0
    .bank_number_of_image_pages:db 0
    .linear_numberofimage_pages:db 0
    .linear_red_mask_size:      db 0
    .linear_red_field_position: db 0
    .linear_green_mask_size:    db 0
    .linear_greenfield_position:db 0
    .linear_blue_mask_size:     db 0
    .linear_blue_field_position:db 0
    .linear_reserved_mask_size: db 0
    .linear_res_field_position: db 0
    .max_pixel_clock:           dd 0
 
    .reserved4:       times 190 db 0        ; Remainder of mode info block
 
times 1024-($-vbe_info_block) db 0