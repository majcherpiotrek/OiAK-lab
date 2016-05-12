#include <stdio.h>
#include "rdtsc.c"

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

/*Funkcja licząca całkę w SSE na floatach (nie równolegle)*/
float calkaSSf(int N);
/*Funkcja licząca całkę w SSE na double (nie równolegle)*/
double calkaSSd(int N);
/*Funkcja licząca całkę w SSE na floatach w sposób zoptymalizowany - obliczenia wykonywane równolegle.*/
float calkaSIMD_f(int N);
/*Funkcja licząca całkę w SSE na double w sposób zoptymalizowany - obliczenia wykonywane równolegle.*/
double calkaSIMD_d(int N);

/* -> unsigned short (2B)
 * function get_fpu reads the FPU control word and returns it's value
 */
unsigned short get_fpu();

/*
 *
 * PC - precyzja
 *
 * 1 - double
 * 2 - single
 * inne - domyślne double extended precision
 */
void set_fpu(unsigned int RC,unsigned int PC);

const int opcjePC = 2;

const int N = 1000000;
const int iloscPomiarow = 100;

char* trybyPC[2] = {"DOUBLE","SINGLE"};
char* sposob[2] = {"(obliczenia po kolei)","(obliczenia rownolegle)"};
int main()
{
    long long int start,stop;

    printf("\nCalka z 1/x liczona na przedziale od 0,001 do 1000 metodą\nprostokatow dla 10^6 podzialow. Porownanie wynikow otrzymanych\nprzez funkcje dzialajace na FPU oraz SSE.\n\n");
    int i;
    for(i = 0; i < opcjePC; i++){

            printf("Precyzja: %s\n\n", trybyPC[i]);

            int pc = i+1;
	    double wynikFPU = 0, czasFPU = 0;
		int j;
		for(j = 0; j<iloscPomiarow; j++){
			start = rdtsc();
			wynikFPU = calka(0,pc,N);
			stop = rdtsc();
			czasFPU += (double)(stop-start);
	    	}

	    czasFPU = czasFPU/iloscPomiarow;

	    printf("FPU: %lf cykle: %lf\n",wynikFPU,czasFPU);
         }

    float (*flt[2])(int) ={calkaSSf, calkaSIMD_f};
    double (*dub[2])(int) ={calkaSSd, calkaSIMD_d};
   /*SSE SINGLE*/
    printf("\nPrecyzja: %s\n\n", trybyPC[1]);
    int j;
    for(i=0; i<2; i++){
        float wynik;
        double czas = 0;
        for(j = 0; j<iloscPomiarow; j++){
            start = rdtsc();
            wynik = flt[i](N);
            stop = rdtsc();
            czas += (double)(stop-start);
        }

        czas = czas/iloscPomiarow;
        printf("SSE %s: %f cykle: %lf\n",sposob[i], wynik, czas);
    }

    printf("\nPrecyzja: %s\n\n", trybyPC[0]);

    for(i=0; i<2; i++){
        double wynik;
        double czas = 0;
        for(j = 0; j<iloscPomiarow; j++){
            start = rdtsc();
            wynik = dub[i](N);
            stop = rdtsc();
            czas += (double)(stop-start);
        }

        czas = czas/iloscPomiarow;
        printf("SSE %s: %lf cykle: %lf\n",sposob[i], wynik, czas);
    }

    printf("\n");

    return 0;
}
