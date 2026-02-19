org 0x7C00

boot:
    push cs
    pop ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ax, 3
    int 0x10

    mov ah, 6
    xor al, al
    mov bh, 0xF4
    mov cx, 0
    mov dx, 0x184F
    int 0x10

    mov bh, 0
    mov dl, 0
    mov dh, 0
    mov ah, 2
    int 0x10

    mov si, logo_line1
    call print_string
    call print_newline

    mov si, logo_line2
    call print_string
    call print_newline

    mov si, logo_line3
    call print_string
    call print_newline

    call print_newline

    hlt
    jmp $

print_string:
    lodsb
    or al, al
    jz .e
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x04
    int 0x10
    jmp print_string
.e:
    ret

print_newline:
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

logo_line1 db 'M   M  IIIII   OOO    SSS ', 0
logo_line2 db 'MM MM    I    O   O  S   S', 0
logo_line3 db 'M M M    I    O   O   SSS ', 0

times 510-($-$$) db 0
dw 0xAA55
