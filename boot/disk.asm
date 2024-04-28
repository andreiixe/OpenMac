; Load 'dh' sectors from drive 'dl' into ES:BX
disk_load:
    pusha
    ; Save DX register to the stack for later use
    push dx

    ; Set up registers for disk read operation
    mov ah, 0x02   ; AH <- Int 0x13 function. 0x02 = 'read'
    mov al, dh     ; AL <- Number of sectors to read (0x01 .. 0x80)
    mov cl, 0x02   ; CL <- Sector (0x01 .. 0x11)
                   ; 0x01 is our boot sector, 0x02 is the first 'available' sector
    mov ch, 0x00   ; CH <- Cylinder (0x0 .. 0x3FF, upper 2 bits in 'cl')
    mov dh, 0x00   ; DH <- Head number (0x0 .. 0xF)
    
    ; DL <- Drive number. Our caller sets it as a parameter and gets it from BIOS
    ; (0 = floppy, 1 = floppy2, 0x80 = HDD, 0x81 = HDD2)

    ; [ES:BX] <- Pointer to buffer where the data will be stored
    ; Caller sets it up for us, and it is actually the standard location for INT 13h
    int 0x13       ; BIOS interrupt
    jc disk_error  ; Jump if carry flag is set (error occurred)

    ; Check if the number of sectors read matches the expected count
    pop dx
    cmp al, dh     ; BIOS also sets 'AL' to the # of sectors read. Compare it.
    jne sectors_error

    popa
    ret

disk_error:
    ; Handle disk read error
    mov bx, DISK_ERROR
    call print16
    call print16_nl
    mov dh, ah     ; AH = Error code, DL = Disk drive that triggered the error
    call print16_hex
    ; Add disk retry mechanism or other error handling strategies here
    jmp disk_loop  ; Jump to disk loop to retry or handle further

sectors_error:
    ; Handle incorrect number of sectors read
    mov bx, SECTORS_ERROR
    call print16

disk_loop:
    ; Add any necessary disk loop logic here for retry or termination
    jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0
