

.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60 
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0

.bss
.comm bufor,1024

.text
.global main

main:
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $bufor, %rsi
movq $1024, %rdx
syscall

movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $bufor, %rsi
movq $1024, %rdx
syscall

movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall
