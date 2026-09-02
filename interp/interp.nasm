default rel
global _start



%macro print 1
    mov     rax,    1
    mov     rdi,    1
    mov     rsi,    %1
    mov     rdx,    %1 %+ _len
    syscall                             ; write(stdout, %1, ...)
%endmacro

%macro exit 1
    mov     rax,    60
    mov     rdi,    %1
    syscall                             ; exit(%1)
%endmacro



section .text
_start:
    mov     r13,    [rsp]               ; argc
    cmp     r13,    3                   ; check if it's at least (argv0, esf path, esf argv0)
    jl     .not_enough_args             ; otherwise, log error


    mov     r12,    [rsp+16]            ; esf path

    mov     rax,    2
    mov     rdi,    r12
    mov     rsi,    0
    mov     rdx,    0
    syscall                             ; open(r12, O_RDONLY, 0)

    test    rax,    rax
    js      .cannot_load_esf            ; print error if open fails
    mov     rbx,    rax                 ; esf fd


    sub     r13,    2
    mov     [rsp],  r13                 ; fix argc (remove ./interp and ESF path)
    mov     rcx,    r13                 ; number of args to move
    inc     rcx                         ; move NULL too
    lea     rsi,    [rsp+24]            ; src (&argv[2])
    lea     rdi,    [rsp+8]             ; dst (&argv[0])
    rep     movsq                       ; memcpy(dst, src, count*8) but 8 bytes at the time


    lea     rdi,    [rsp+r13*8+32]      ; start of envp
    xor     rax,    rax                 ; stop at NULL 
    mov     rcx,    -1                  ; init at BIG unsigned number 
    repne   scasq                       ; increment RDI until qword [RDI] == RAX, each time decrement RCX
    not     rcx                         ; obtain the length of envp + 1 (NULL itself)
    lea     rsi,    [rsp+r13*8+32]      ; copy from start of envp (r13 is fake argc which is 2 less than real argc)
    lea     rdi,    [rsp+r13*8+16]      ; start from after the new argv NULL
    rep     movsq


    mov     rcx,    0                   ; offset of auxv entry from array start
.auxv_count_loop:
    mov     rax,    [rsi+rcx*8]         ; load the tag type of the entry at offset rcx
    test    rax,    rax
    jz      .found_auxv_null            ; if it's NULL we're at the end!
    add     rcx,    2                   ; otherwise check the next tag
    jmp     .auxv_count_loop
.found_auxv_null:
    add     rcx,    2                   ; +2 to include auxv_null
    rep     movsq                       ; rsi, rdi are untouched so they are still correct


    mov     rax,    8
    mov     rdi,    rbx
    xor     rsi,    rsi
    mov     rdx,    2                   ; SEEK_END
    syscall                             ; lseek(rbx, 0, SEEK_END), seek end of file

    test    rax,    rax
    js      .seek_failed
    mov     r12,    rax


    mov     rsi,    rax                 ; length of mapping
    mov     rax,    9                   ; mmap
    mov     rdi,    0
    mov     rdx,    6                   ; PROT_READ | PROT_WRITE | PROT_EXECUTE
    mov     r10,    0x22                ; MAP_PRIVATE | MAP_ANONYMOUS
    mov     r8,     -1                  ; file descriptior
    xor     r9,     r9                  ; offset into the file
    syscall

    test    rax,    rax
    js      .mmap_failed
    mov     r13,    rax                 ; RWX memory mapping


    mov     rax,    8
    mov     rdi,    rbx
    xor     rsi,    rsi
    xor     rdx,    rdx                 ; SEEK_SET
    syscall                             ; lseek(rbx, 0, SEEK_SET), seek start of file

    test    rax,    rax
    js      .seek_failed


    mov     r11,    r13
.read_loop:
    xor     rax,    rax                 ; read
    mov     rdi,    rbx                 ; fd
    mov     rsi,    r11                 ; *buf
    mov     rdx,    r12                 ; count
    syscall                            

    test    rax,    rax
    jle     .read_failed
    add     r11,    rax
    sub     r12,    rax
    jnz     .read_loop


    jmp     r13


.not_enough_args:
    print   not_enough_args
    exit    1

.cannot_load_esf:
    print   cannot_load_esf
    exit    1

.seek_failed:
    print   seek_failed
    exit    1

.mmap_failed:
    print   mmap_failed
    exit    1

.read_failed:
    print   read_failed
    exit    1



section .rodata
no_execfd: db "No AT_EXECFD entry could be found in auxv", 10, 0
no_execfd_len equ $ - no_execfd

not_enough_args: db "Usage: <interp> <path to ESF file> <argv[0] for ESF 'process'>", 10, 0
not_enough_args_len equ $ - not_enough_args

cannot_load_esf: db "open() on esf binary failed", 10, 0
cannot_load_esf_len equ $ - cannot_load_esf

seek_failed: db "lseek(SEEK_END) on esf binary failed (???)", 10, 0
seek_failed_len equ $ - seek_failed

mmap_failed: db "mmap() failed. Are RWX mappings blocked?", 10, 0
mmap_failed_len equ $ - mmap_failed

read_failed: db "failed to read() the esf binary", 10, 0
read_failed_len equ $ - read_failed

