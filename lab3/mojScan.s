.data
    format:
        .string "%c %d %lf"
.bss

.text
    .globl mojScan
    .type mojScan, @function

mojScan:
    
    pushq %rbp
    movq %rsp,%rbp

    subq $32,%rsp  # Rezerwuję pamięć na 3 zmienne w funkcji

    movq %rdi,-8(%rbp)
    movq %rsi,-16(%rbp)
    movq %rdx,-24(%rbp)
    
    movq -8(%rbp),%rsi
    movq -16(%rbp),%rdx
    movq -24(%rbp),%rcx

    movq $format, %rdi
    movq $0, %rax

    call scanf
    

    movq %rbp,%rsp
    popq %rbp

    ret
