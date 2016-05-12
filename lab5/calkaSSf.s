.data

beg:
	.float 0.001
end:
	.float 1000
dwa:
	.float 2
jeden:
    .float 1
zero:
    .float 0

.text
.globl 		calkaSSf
	.type	calkaSSf, @function

calkaSSf:
    
	pushq %rbp	
	movq %rsp,%rbp	
    
##########  OBLICZANIE CAŁKI W SSE  ############
 
    # Załadowanie parametru N do %xmm0 (konwersja z int na single)
    cvtsi2ss %rdi, %xmm0
    
    #Granice całkowania do kolejnych rejestrów.
    movss end, %xmm1  
    movss beg, %xmm2
    
    #Liczę długość przedziału
    subss %xmm2,%xmm1

    # Dzielę obliczoną dł. przedziału przez N wczytane na początku,
    # później dzielę przez 2 i dodaję wartość dolnej granicy całkowania,
    # aby otrzymać środek pierwszego przedziału.
    divss %xmm0,%xmm1
    movss %xmm1,%xmm3 #Zapamiętuję długość przedziału na później w %xmm3
    divss dwa, %xmm1
    addss beg, %xmm1

    #W %xmm0 beda sumowane wysokosci prostokatow  
    movss zero,%xmm0

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
	movss jeden, %xmm2 
    	divss %xmm1,%xmm2
	#Dodaję wyliczoną wartość funkcji do sumy
        addss %xmm2,%xmm0
	#Wyliczam następny punkit pośredni (x + dł. przedziału)
        addss %xmm3,%xmm1

        incq %r8 
      jmp _petla
        
		
		
_koniec:
    # Mnożę wyliczoną wyżej sumę prostokątów przez długość przedziału
    mulss %xmm3,%xmm0  
    
    movq $0,%rax
    
    # Porządkowanie stosu po wykonaniu funkcji.
    movq %rbp,%rsp
    popq %rbp
    
    ret
