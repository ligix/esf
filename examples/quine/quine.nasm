BITS 64
default rel

section .text:
_start:
    mov     rax,    1
    mov     rdi,    1
    lea     rsi,    [magic_number]
    mov     rdx,    magic_number_len
    syscall                             ; write(stdout, magic_number, len(magic_number))

    mov     rax,    1
    mov     rdi,    1
    lea     rsi,    [_start]
    mov     rdx,    code_len
    syscall                             ; write(stdout, _start, len(_start))

    mov     rax,    60 
    mov     rdi,    0
    syscall                             ; exit(0)

magic_number: db 0x7F, "ESF"
magic_number_len equ $ - magic_number

code_len equ $ - _start
