# Program wczytujacy czterocyfrowa liczbe szesnastkowa i zamieniajacy
# ja na postac binarna.
.data
 SYSREAD = 0
 SYSWRITE  = 1
 STDOUT = 1
 STDIN = 0
 SYSEXIT = 60
 EXIT_SUCCESS = 0
 buflen = 4
 outlen = 17 #długość wyjścia 17, ponieważ jedno miesce więcej na \n
 zero = 48
 one = 49
 prompt: .ascii "Podaj czterocyfrowa liczbe szesnastkowa:\n"
 promptlen = .-prompt

.bss
.comm input,buflen
.comm values,buflen
.comm output,outlen

.text
.globl _start
_start:

movq $SYSWRITE,%rax
movq $STDOUT,%rdi
movq $prompt,%rsi
movq $promptlen,%rdx
syscall

movq $SYSREAD,%rax
movq $STDIN,%rdi
movq $input,%rsi
movq $buflen,%rdx
syscall

movq $0,%rdi # %rdi do iteracji w petli

# Pętla zamieniająca kody ascii kolejnych znaków wczytanego
# łańcucha na wartości liczbowe w kodzie szesnastkowym. 
# cyfry 0-9 - odejmujemy 48
# litery A-F - odejmujemy 48+7
# litery a-f - odejmujemy 48+7+32
 _petla:
    # Warunek wyjścia z pętli
    cmpq $buflen,%rdi
    je _wartosci
        # Czyszczę %rax, wypełniając go zerami
         movq $0,%rax
        # Kopiuję z łańcucha wejściowego jeden bajt do najmniej znaczącego
        # bajtu rejestru %rax, czyli #al i następnie odejmuję 48
        # od kodu ascii cyfry, aby uzyskać jej wartość.
         movb input(,%rdi,1),%al 
         subq $48,%rax
   
         # Jeśli po odejmowaniu wynik jest większy od 9 oznacza to,
         # że dana cyfra była literą a-f lub A-F. Odejmuję wtedy 7,
         # jeśli wynik będzie <= 15 oznacza to, że dana cyfra to
         # litera A-F, jeśli nie to należy odjąć jeszcze 32, ponieważ
         # była to litera a-f o większym kodzie ascii.
         cmpq $9,%rax
         jle _liczba # Jeśli <= 9 to mamy już wartość
                 subq $7,%rax 
             cmpq $15,%rax # Jeśli <= 15 to mamy już wartość
             jle _liczba
                 subq $32,%rax
   
        # Obliczoną wartość cyfry przenoszę do zmiennej "values",
        # pamiętającej wartość. Wartość rejestru %rdi oznacza indeks.
         _liczba:
         movb %al,values(,%rdi,1)
         incq %rdi # Zwiększam indeks o 1
         jmp _petla # Skaczę do początku pętli

# Teraz mamy wartości wprowadzonych cyfr i należy
# zamienić je na system binarny. Biorę po kolei
# każdą wartość i konwertuję ją na system binarny
# za pomocą przesunięcia binarnego w prawo i sprawdzania
# flagi cf. Przesunięcie odpowiada dzieleniu przez 2.
# Wartości muszą być wpisywane od końca, aby na ekranie
# pojawił się poprawny wynik. Inaczej mielibyścmy lustrzane
# odbicie, ponieważ element zerowy wypisywanego ciągu znaków
# jest po lewej stronie, natomiast najmniej znaczący bit
# liczby po prawej stronie.
_wartosci:
movq $3,%rdi #do indeksowania zmiennej z wartościami od 3 do 0
movq $0,%r10 #do iteracji zewnętrznej pętli idącej po wartościach.
movq $15,%r8 #do indeksowania wyjścia od 15 do 0
_zamiana:
    cmpq $buflen,%r10
    je _koniec #jesli przekonwertowalismy 4 cyfry to koniec
        # Czyszczę %rax i następnie kopiuję wartość danej
        # cyfry ze zmiennej values do najmniej znaczęcego bajtu %rax
        movq $0,%rax
        movb values(,%rdi,1),%al
        movq $0,%r9 #do iteracji przesunięć bitowych od 0 do 4
        _bity:
            cmpq $4,%r9 
            je _kolejnacyfra
            # Wykonuję przesunięcie bitowe o jeden w prawo
            # rejestru %rax, w wyniku czego flaga cf mówi
            # mi o reszcie z dzielenia przez 2.
            shrq $1,%rax
            jc _jedynka #jeśli flaga podniesiona to reszta = 1
            jmp _zero # w przeciwnym wypadku reszta = 0

            _jedynka:
                movb $one,output(,%r8,1)
                incq %r9
                decq %r8
                jmp _bity
            _zero:
                movb $zero,output(,%r8,1)
                incq %r9
                decq %r8
                jmp _bity
            _kolejnacyfra:
                decq %rdi
                incq %r10
                jmp _zamiana


            
    
    
_koniec:
movq $16,%rdi
movb $'\n',output(,%rdi,1)
movq $SYSWRITE,%rax
movq $STDOUT,%rdi
movq $output,%rsi
movq $outlen,%rdx
syscall

movq $EXIT_SUCCESS,%rbx
movq $SYSEXIT,%rax
syscall

