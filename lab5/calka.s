.data

beg:
	.float 0.001
end:
	.float 1000
dwa:
	.float 2
jeden:
    .float 1

.bss
.comm wynik,8 

.text
.globl 		calka
	.type	calka, @function

calka:
    
	pushq %rbp	
	movq %rsp,%rbp	
    
    # Wywołanie funkcji ustawiającej tryb zaokrąglania oraz precyzję.
    # parametry do funkcji już w %rdi oraz %rsi
    call set_fpu

##########  OBLICZANIE CAŁKI W FPU  ############
 
    # Wrzucenie trzeciego parametru funkcji na stos
    # oraz załadowanie go ze stosu programu na stos FPU
    pushq %rdx
    fildq (%rsp)
    
    # Ładuję górną granicę całkowania na stos FPU, a następnie
    # odejmuję od niej dolną, aby uzyskać dł. przedziału całk.
    flds end  
    fsubs beg

    # Dzielę obliczoną dł. przedziału przez N wczytane na początku,
    # później dzielę przez 2 i dodaję wartość dolnej granicy całkowania,
    # aby otrzymać środek pierwszego przedziału.
    fdiv %st(1),%st(0)
    fst %st(1) # Zapisuje długość przedziału na później
    fdivs dwa
    fadds beg

    # Ładuję 0 na szczyt stosu - tu będą sumowane wys. prostokątów
    fldz 

    movq $0,%r8
	_petla:
        # Stos w trakcie wykonywania obliczeń:
        # delta - dł. przedziału; mid - aktualny punkt pośredni;
        # SUM - suma wartości funkcji w punktach pośrednich
        # (+) - oznacza, że wartość się zwiększyła
        #
        # delta --> delta --> delta --> delta --> delta --> delta
        # mid       mid       mid       mid       mid       mid(+)
        # SUM       SUM       SUM       SUM(+)    SUM(+)    SUM(+)
        #  -         1        1/mid      -        delta      -
	
        cmpq %rdx,%r8
		je _koniec
		
        # Wrzucam jedynkę na szczyt stosu i obliczam wartość
        # funkcji 1/x w danym punkcie pośrednim. Aktualny punkt
        # pośredni w rejestrze %st(2). Następnie dodaję wynik
        # do sumy wysokości prostokątów w %st(1) oraz usuwam
        # wartość ze szczytu stosu.
		flds jeden 
    	fdiv %st(2),%st(0)
        faddp %st(0),%st(1)

        # Wrzucam na szczyt stosu długość przedziału, 
        # dodaję ją do wartości aktualnego punktu pośredniego i na koniec
        # usuwam wartość ze szczytu stosu
        fld %st(2)
        faddp %st(0),%st(2) 

        incq %r8 
      jmp _petla
        
		
		
_koniec:
    # Mnożę wyliczoną wyżej sumę prostokątów przez długość przedziału
    fmul %st(2),%st(0) 
    
    # Zapisuję wyliczoną wartość jako float do pamięci. 
    # (32 bit - single; Jako double (fstl) wychodziły złe wyniki)
    # Następnie kopiuję ten wynik do rejestru %xmm0,
    # przez który funkcja będzie go zwracała. Na koniec 0 do %rax
    # jako kod poprawnego zakończenia funkcji.
    fstl wynik
    movsd wynik,%xmm0
    movq $0,%rax
    
    # Porządkowanie stosu po wykonaniu funkcji.
    movq %rbp,%rsp
    popq %rbp
    
    ret
