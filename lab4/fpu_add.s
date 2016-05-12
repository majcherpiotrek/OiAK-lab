.data

.bss
.comm wynik,8

.text
    .globl fpu_add
    .type fpu_add,@function

fpu_add:
    
    pushq %rbp
    movq %rsp,%rbp

    subq $24,%rsp 

    movsd %xmm0,-8(%rbp)
    movsd %xmm1,-16(%rbp)
    
    call set_fpu

    fldl -8(%rbp)
    fldl -16(%rbp)

    faddp

    fstpl wynik

    movsd wynik,%xmm0
    movq $0,%rax

    movq %rbp,%rsp
    popq %rbp

    ret

