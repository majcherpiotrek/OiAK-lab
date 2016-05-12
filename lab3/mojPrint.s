.data
    format:
        .string "\n\tchar: %c\n\tint: %d\n\tdouble: %f\n"

.text
    .globl mojPrint
    .type mojPrint, @function

mojPrint:
    
    pushq %rbp
    movq %rsp,%rbp

# Jeśli rezerwowałem tylko na dwie zmienne (subl $24,%rsp) to
# przy uruchomieniu wyskakiwało core dumped, dlaczego? Przecież
# double jest w xmm0 i nie potrzebuje miejsca na stosie. Czy to kompilator
# automatycznie przerzuca argumenty z rejestrów przez stos i z powrotem
# do rejestrów? W funkcjach wygenerowanych przez gcc tak było.

    subq $32,%rsp # Rezerwowanie pamięci na trzy zmienne
    
    movq %rdi,-8(%rbp) # Pierwszy argument
    movq %rsi,-16(%rbp) # Drugi argument

    movq -8(%rbp),%rsi
    movq -16(%rbp),%rdx
    
    movq $format, %rdi
    movq $1, %rax

    call printf
    
    movq %rbp,%rsp
    popq %rbp
    
    ret
