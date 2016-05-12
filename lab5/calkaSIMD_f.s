.data

beg:
	.float 0.001
end:
	.float 1000
dwa:
	.float 2
jeden:
    .float 1, 1, 1, 1
zero:
    .float 0, 0, 0, 0
cztery:
    .float 4, 4, 4, 4
.bss
.comm tab, 16
.comm delta, 16

.text
.globl 		calkaSIMD_f
	.type	calkaSIMD_f, @function

calkaSIMD_f:
    
	pushq %rbp	
	movq %rsp,%rbp	
    
##########  OBLICZANIE CAŁKI W SSE - równoległe wykonywanie instrukcji  ############
    
    # Załadowanie parametru N do %xmm0 (konwersja z int na float)
    cvtsi2ss %rdi, %xmm0
    
    #Granice całkowania do kolejnych rejestrów.
    movss end, %xmm1  
    movss beg, %xmm2
    
    #Liczę długość przedziału całkowania i zapisuję w %xmm1
    subss %xmm2,%xmm1

    # Dzielę obliczoną długość przedziału całkowania przez N wczytane na początku, aby uzyskać szerokość każdego paska.
    # Zapisuję wynik do %xmm3, ponieważ będzie potrzebny później w obliczeniach.
    # Teraz dzielę przez 2 i dodaję wartość dolnej granicy całkowania,
    # aby otrzymać środek pierwszego paska.
    
    divss %xmm0,%xmm1 # delta = szer. paska / N - > %xmm1
    movss %xmm1,%xmm3 
    divss dwa, %xmm1 # mid = delta/2
    addss beg, %xmm1 # mid = mid + beg
    
    #Pętla zapisująca punkty pośrednie oraz szerokość paska do tablic w pamięci
    movq $0, %rdx
    movq $4, %rcx
    _wczytywanie:
        cmpq %rdx, %rcx
        je _wczytane
        
        #Zapisuję punkt pośredni do tablicy
        movss %xmm1,tab(,%rdx,4)
        
        #Zapisuję szerokość 
        movss %xmm3,delta(,%rdx,4)
        
        #Obliczam kolejny pośredni przez dodanie
        #do pierwszego szerokości paska.
        addss %xmm3,%xmm1
        
        incq %rdx
        jmp _wczytywanie
   
    _wczytane:
   
   #Wczytuję szerokość paska
    movaps delta,%xmm3
   
   #Mnożę szerokość paska x4, ponieważ pętla będzie przeskakiwać co cztery paski.
    movups cztery, %xmm4
    mulps %xmm3,%xmm4
   
   #Wczytuję wyżej wyliczone wartości pierwszych 4 punktów pośrednich.
    movaps tab,%xmm1
   
   #W %xmm0 beda sumowane wysokosci prostokatow, więc inicjuje rejestr zerami.
    movups zero,%xmm0

    #Dzielę %rdi na 4, używając przesunięcia bitowego w prawo o 2, ponieważ będzie 4x mniej iteracji
    shrq $2, %rdi
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
    	movups jeden, %xmm2 
    	divps %xmm1,%xmm2
	#Dodaję wyliczoną wartość funkcji do sumy
        addps %xmm2,%xmm0
	#Wyliczam następny punkt pośredni (x + dł. przedziału)
        addps %xmm4,%xmm1

        incq %r8 
      jmp _petla
        
		
		
_koniec:
    # Mnożę wyliczoną wyżej sumę prostokątów przez długość przedziału
    mulps %xmm3,%xmm0  
    
    #Sprowadzenie do ostatecznego wyniku
    movq $0,%rdx
    #Kopiuję wyliczone składowe wyniku do tablicy w pamięci
    movaps %xmm0, tab
    #Kopiuję do rejestrów i dodaję
    movss tab(,%rdx,4),%xmm0
    incq %rdx

    _sumuj:
        cmpq %rdx,%rcx #w %rxc wartość 4, używana wcześniej
        je _policzone
        addss tab(,%rdx,4),%xmm0
        incq %rdx
        jmp _sumuj

    _policzone:
    
    movq $0,%rax
    
    # Porządkowanie stosu po wykonaniu funkcji.
    movq %rbp,%rsp
    popq %rbp
    
    ret
