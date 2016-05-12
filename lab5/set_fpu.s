.data
.bss
.comm control,2
.text
.globl 		set_fpu
	.type	set_fpu, @function

set_fpu:
    
	pushq %rbp	
	movq %rsp,%rbp	
	
    # Inicjalizacja FPU
      finit
    
    #Pobranie słowa kontrolnego FPU i zapisanie do %ax
    fstcw control
    movw control, %bx

    # Sprawdzam, który tryb zaokrąglania został wybrany
    # Jeśli argument jest niepoprawny to będzie ustawiony
    # tryb domyślny, czyli do najblizszej. Jego kod to 00
    # na bitach 10 i 11 CW, dlatego wystarczy użyć operacji
    # OR aby zmienić na inny tryb.
    cmpq $0,%rdi
    je _nearest
    
    cmpq $1,%rdi
    je _minInf
    
    cmpq $2,%rdi
    je _plsInf

    cmpq $3,%rdi
    je _trunc

    # Bity 10 i 11 odpowiadają za tryb zaokrąglania:
    # 00 - do najbliżej
    # 01 - do minus nieskończoności
    # 10 - do plus nieskończoności
    # 11 - obcięcie

   _nearest:
         OR $0b0000000000000000,%bx 
       jmp _dalej
   
    _minInf:
         OR $0b0000010000000000,%bx 
       jmp _dalej
   
    _plsInf:
         OR $0b0000100000000000,%bx 
       jmp _dalej

    _trunc:
         OR $0b0000110000000000,%bx 
       jmp _dalej
    
    # Jeśli drugi argument (%rsi) to 0 to double extended (ust. domyślne),
    # jeśli 1 to single bity 8 i 9 = 11B. Jeśli jakakolwiek inna wartość
    # to ustawienie domyślne.
    _dalej:
         cmp $0,%rsi
         je _cwreturn
         
         cmp $1,%rsi
         je _double

         cmp $2,%rsi
         je _single

         _double:
            AND $0b1111111011111111,%bx
            jmp _cwreturn

        _single:
            AND $0b1111110011111111,%bx

   # Załadowanie słowa kontrolnego z powrotem do FPU
   _cwreturn:
         movw %bx,control
         fldcw control
    
    movq $0,%rax

    # Porządkowanie stosu po wykonaniu funkcji.
    movq %rbp,%rsp
    popq %rbp
    
    ret
