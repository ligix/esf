BITS 64

section .text:
    mov     rax,    1
    mov     rdi,    1
    lea     rsi,    [rel message]
    mov     rdx,    message_len
    syscall                             ; write(stdout, message, message_len)

    mov     rax, 60
    xor     rdi, rdi
    syscall                             ; exit(0) 
    
message: db "Hello world!", 10, 0
message_len equ $ - message
