
.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60 
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0

.bss
.comm bufor,1024
.comm wartosc,8
.text

.global _start
_start:
main:
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $bufor, %rsi
movq $1024, %rdx
syscall

movb bufor, %al
movb %al, wartosc

sub $48, %al
cmp $9, %al
jg _wieksza
_dalej:
movb %al, %ax
movb $2, %bx
div bx

movb %ax, wartosc


movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $znak, %rsi
movq $8, %rdx
syscall

_wieksza:
sub $7, %al
jmp _dalej

movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall
