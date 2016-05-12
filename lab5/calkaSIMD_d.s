.data

beg:
	.double 0.001
end:
	.double 1000
dwa:
	.double 2
jeden:
    .double 1, 1
zero:
    .double 0, 0
dwadwa:
    .double 2, 2
.bss
.comm tab, 16
.comm delta, 16

.text
.globl 		calkaSIMD_d
	.type	calkaSIMD_d, @function

calkaSIMD_d:
    
	pushq %rbp	
	movq %rsp,%rbp	
    
##########  OBLICZANIE CAŁKI W SSE - równoległe wykonywanie instrukcji  ############
    
    # Załadowanie parametru N do %xmm0 (konwersja z int na double)
    cvtsi2sd %rdi, %xmm0
    
    #Granice całkowania do kolejnych rejestrów.
    movsd end, %xmm1  
    movsd beg, %xmm2
    
    #Liczę długość przedziału całkowania i zapisuję w %xmm1
    subsd %xmm2,%xmm1

    # Dzielę obliczoną długość przedziału całkowania przez N wczytane na początku, aby uzyskać szerokość każdego paska.
    # Zapisuję wynik do %xmm3, ponieważ będzie potrzebny później w obliczeniach.
    # Teraz dzielę przez 2 i dodaję wartość dolnej granicy całkowania,
    # aby otrzymać środek pierwszego paska.
    
    divsd %xmm0,%xmm1 # delta = szer. paska / N - > %xmm1
    movsd %xmm1,%xmm3 
    divsd dwa, %xmm1 # mid = delta/2
    addsd beg, %xmm1 # mid = mid + beg
    
    #Pętla zapisująca punkty pośrednie oraz szerokość paska do tablic w pamięci
    movq $0, %rdx
    movq $2, %rcx
    _wczytywanie:
        cmpq %rdx, %rcx
        je _wczytane
        
        #Zapisuję punkt pośredni do tablicy
        movsd %xmm1,tab(,%rdx,8)
        
        #Zapisuję szerokość 
        movsd %xmm3,delta(,%rdx,8)
        
        #Obliczam drugi punkt pośredni przez dodanie
        #do pierwszego szerokości paska.
        addsd %xmm3,%xmm1
        
        incq %rdx
        jmp _wczytywanie
   
    _wczytane:
   
   #Wczytuję szerokość paska
    movapd delta,%xmm3
   
   #Mnożę szerokość paska x2, ponieważ pętla będzie przeskakiwać co dwa paski.
    movapd dwadwa, %xmm4
    mulpd %xmm3,%xmm4
   
   #Wczytuję wyżej wyliczone wartości pierwszych 2 punktów pośrednich.
    movapd tab,%xmm1
   
   #W %xmm0 beda sumowane wysokosci prostokatow, więc inicjuje rejestr zerami.
    movapd zero,%xmm0

    #Dzielę %rdi na dwa, używając przesunięcia bitowego w prawo, ponieważ będzie 2x mniej iteracji
    shrq $1, %rdi
    movq $0,%r8
	_petla:
   
        #Zawartość rejestrów przy obliczeniach:
        #  %xmm0 - suma wartości funkcji w kolejnych punktach pośrednich
        #  %xmm1 - kolejne punkty pośrednie
        #  %xmm2 - jedynka do 1/x
        #  %xmm3 - szerokość jednego przedziału
        #  %xmm4 - podwojona szerokść jednego przedziału potrzebna do iteracji po punktach pośrednich

        cmpq %rdi,%r8
		je _koniec
		
    #Ładuje jedynkkę i liczę 1/x
    	movapd jeden, %xmm2 
    	divpd %xmm1,%xmm2
	#Dodaję wyliczoną wartość funkcji do sumy
        addpd %xmm2,%xmm0
	#Wyliczam następny punkt pośredni (x + dł. przedziału)
        addpd %xmm4,%xmm1

        incq %r8 
      jmp _petla
        
		
		
_koniec:
    # Mnożę wyliczoną wyżej sumę prostokątów przez długość przedziału
    mulpd %xmm3,%xmm0  
    
    #Sprowadzenie do ostatecznego wyniku
    movq $0, %rdx
    
    #Kopiuję niską część %xmm0 do pamięci,
    #następnie z pamięci do %xmm1 
    movlpd %xmm0, tab(,%rdx,8)
    movsd tab(,%rdx,8),%xmm1
    
    incq %rdx
    
    #Kopiuję wysoką część %xmm0 do pamięci,
    #następnie z pamięci z powrotem już jako 
    #pojedynczą liczbę (scalar double)
    movhpd %xmm0, tab(,%rdx,8)
    movsd tab(,%rdx,8),%xmm0
    
    #Sumuję dwie części wyniku obliczone równolegle
    addsd %xmm1,%xmm0

    movq $0,%rax
    
    # Porządkowanie stosu po wykonaniu funkcji.
    movq %rbp,%rsp
    popq %rbp
    
    ret
