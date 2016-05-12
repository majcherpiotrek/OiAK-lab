#include <stdio.h>
#include "rdtsc.c"

void mojScan(char* wskc, int* wski, double* wskf);

void mojPrint(char c, int i, double f);

const double freq = 2000000000; // Częstotliwość mojego procesora 2GHz
const short int size = 3;

int main(){

    long long int start,stop;
    double times[size];

    char c;
    int i;
    double f;

    printf("\nPodaj po kolei - znak, liczbe int, liczbe double:\n\n");

/*----Skanowanie----*/
    start = rdtsc();
    mojScan(&c, &i, &f);
    stop = rdtsc();

    times[0] = (double)(stop-start)/freq;

    printf("\nWprowadziłeś:\n\nmojPrint:");

/*----Wypisanie moim printem----*/
    start = rdtsc();
    mojPrint(c, i , f);
    stop = rdtsc();

    times[1] = (double)(stop - start)/freq;

/*----Wypisanie standardowym printf'em----*/
    start = rdtsc();
    printf("\nprintf:\n\tchar: %c\n\tint: %d\n\tdouble: %lf\n", c, i , f);
    stop = rdtsc();

    times[2] = (double)(stop - start)/freq;

    printf("\nCzasy wykonania funkcji:\n\n\tmojScan: %lf s\n\tmojPrint: %lf s\n\tprintf<stdio.h>: %lf s\n\n", times[0], times[1], times[2]);

    return 0;
}
