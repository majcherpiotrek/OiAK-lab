.data

beg:
	.double 0.001
end:
	.double 1000
dwa:
	.double 2
jeden:
    .double 1
zero:
    .double 0

.text
.globl 		calkaSSd
	.type	calkaSSd, @function

calkaSSd:
    
	pushq %rbp	
	movq %rsp,%rbp	
    
##########  OBLICZANIE CAŁKI W SSE  ############
 
    # Załadowanie parametru N do %xmm0 (konwersja z int na single)
    cvtsi2sd %rdi, %xmm0
    
    #Granice całkowania do kolejnych rejestrów.
    movsd end, %xmm1  
    movsd beg, %xmm2
    
    #Liczę długość przedziału
    subsd %xmm2,%xmm1

    # Dzielę obliczoną dł. przedziału przez N wczytane na początku,
    # później dzielę przez 2 i dodaję wartość dolnej granicy całkowania,
    # aby otrzymać środek pierwszego przedziału.
    divsd %xmm0,%xmm1
    movsd %xmm1,%xmm3 #Zapamiętuję długość przedziału na później w %xmm3
    divsd dwa, %xmm1
    addsd beg, %xmm1

    #W %xmm0 beda sumowane wysokosci prostokatow  
    movsd zero,%xmm0

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
	
        cmpq %rdi,%r8
		je _koniec
		
        #Ładuje jedynkkę i liczę 1/x
	movsd jeden, %xmm2 
    	divsd %xmm1,%xmm2
	#Dodaję wyliczoną wartość funkcji do sumy
        addsd %xmm2,%xmm0
	#Wyliczam następny punkit pośredni (x + dł. przedziału)
        addsd %xmm3,%xmm1

        incq %r8 
      jmp _petla
        
		
		
_koniec:
    # Mnożę wyliczoną wyżej sumę prostokątów przez długość przedziału
    mulsd %xmm3,%xmm0  
    
    movq $0,%rax
    
    # Porządkowanie stosu po wykonaniu funkcji.
    movq %rbp,%rsp
    popq %rbp
    
    ret
