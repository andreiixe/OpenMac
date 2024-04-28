[bits 32]

section .text
global _start  ; Entry point for the bootloader

_start:
    ; Set up stack
    mov esp, stack_top  ; Initialize stack pointer to the top of the stack

    ; Initialize data segments (TODO)

    ; Call main C function
    call main         ; Calls the C function. The linker will know where it is placed in memory

    ; Error handling for main function call
    cmp eax, 0        ; Check return value in EAX
    jnz main_error    ; Jump to error handling if main returns a non-zero value

    ; Exit gracefully
    mov eax, 0x1      ; Exit system call number
    xor ebx, ebx      ; Exit code 0
    int 0x80          ; Invoke kernel interrupt

main_error:
    ; TO DO
    jmp $

section .data
    ; TO DO

section .bss
    ; TO DO

section .stack
    ; 
    stack_bottom equ 0x8000  ; Adjust memory address for your system
    stack_top equ stack_bottom - 1
