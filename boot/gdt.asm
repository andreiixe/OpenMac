gdt_start: ; Don't remove the labels, they're needed to compute sizes and jumps
    ; The GDT starts with a null 8-byte
    dd 0x0 ; 4 bytes
    dd 0x0 ; 4 bytes

gdt_code:
    dw 0xffff    ; Segment length, bits 0-15
    dw 0x0       ; Segment base, bits 0-15
    db 0x0       ; Segment base, bits 16-23
    db 10011010b ; Flags (8 bits)
    db 11001111b ; Flags (4 bits) + Segment length, bits 16-19
    db 0x0       ; Segment base, bits 24-31

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0


gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; Size (16 bits), always one less than its true size
    dd gdt_start ; Address (32 bits)

; Define some constants for later use
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Error handling and validity checking
check_gdt:
    mov eax, gdt_end
    sub eax, gdt_start
    mov ebx, eax ; Size of the GDT in bytes

    ; Check if GDT size is within limits
    cmp ebx, MAX_GDT_SIZE
    ja gdt_size_error ; Jump if size exceeds maximum allowed

    ret

gdt_size_error:
    ; Handle GDT size error
    ; Print error message
    mov ebx, GDT_SIZE_ERROR_MSG
    call print_string
    jmp $

; Constants
MAX_GDT_SIZE equ 1024 ; Maximum allowed size for the GDT in bytes
GDT_SIZE_ERROR_MSG db "Error: GDT size exceeds maximum allowed limit!", 0

; Helper subroutine to print a null-terminated string
print_string:
    mov eax, 0x0E ; AH = 0x0E (Teletype output), AL = character to print
    mov ebx, 0x0007 ; BL = 0 (Page number), BH = 0x0007 (Text attribute)
    mov edx, ebx ; DL = BH (Text attribute)
    mov ecx, ebx ; CH = BL (Page number)
    int 0x10 ; Video Services interrupt
    ret
