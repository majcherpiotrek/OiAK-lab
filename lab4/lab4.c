#include <stdio.h>

/*
 * Funkcja licząca całkę z funkcji 1/x na przedziale 0.001 do 1000.
 * Do ustawienia parametrów FPU wywołuje funkcje set_fpu.
 * Paremetry funkcji:
 *
 * RC - tryb zaokrąglania
 * 0 - do najbliższej
 * 1 - do minus nieskończoności
 * 2 - do plus nieskończoności
 * 3 - obcięcie
 *
 * PC - precyzja
 * 0 - double extended precision
 * 1 - single precision
 * inne - domyślne double extended precision
 *
 * N - ilość podziałów wykresu funkcji
 */

double calka(unsigned int PC, unsigned int RC, unsigned int N);

/* double, double -> double
 * function fpu_add adds 2 double FP numbers
 */
double fpu_add(unsigned int PC, unsigned int RC, double a, double b);

/* -> unsigned short (2B)
 * function get_fpu reads the FPU control word and returns it's value
 */
unsigned short get_fpu();

/*
 * Funkcja ustawia tryb zaokrąglania oraz prezyzję w FPU
 *
 * RC - tryb zaokrąglania
 * 0 - do najbliższej
 * 1 - do minus nieskończoności
 * 2 - do plus nieskończoności
 * 3 - obcięcie
 *
 * PC - precyzja
 * 0 - double extended precision
 * 1 - single precision
 * inne - domyślne double extended precision
 */
void set_fpu(unsigned int RC,unsigned int PC);

const int opcjeRC = 4;
const int opcjePC = 3;
#define size 5

char* trybyRC[4] = {"do najblizszej","do -niesk","do +niesk","obciecie"};
char* trybyPC[3] = {"double extended","double","single"};

int main(int argc, char * argv[])
{
    unsigned short int fpucw = 0x1234;
    double dbls[3] = {123.45, 0.123, 0.0};

    unsigned int N[size] = {100,1000,100000,1000000,1000000000};
    int i;
    for(i = 0; i < opcjePC; i++){

        int j;
        for(j = 0; j < opcjeRC; j++){

            dbls[2] = fpu_add(j, i, dbls[0], dbls[1]);

            printf("Precyzja: %s, tryb zaokraglania: %s\n", trybyPC[i], trybyRC[j]);
            printf("fpu_add: %lf + %lf = %lf\n", dbls[0], dbls[1], dbls[2]);

            int k;
            for(k = 0; k<size; k++){
                printf("calka z 1/x (%d): %lf\n",N[k], calka(j,i,N[k]));
            }
            /* print FPU control word */
            fpucw = get_fpu();
            printf("FPU CW: %04hx\n", fpucw);
         }
    }

    /* Return 0 if exiting normally.
     */
    return 0;
}
