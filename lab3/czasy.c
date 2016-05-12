#include <stdio.h>
#include <time.h>
#include "rdtsc.c"
void printInt(int i);
void printFloat(float f);
void printChar(char c);
void mojScanf(char* wsk);

//Wartosci wypisywane przez funkcje
const int mojInt = 999;
const int mojFloat = 17.97;
const char mojChar = 'K';
char bufor[64];

const int dzielnik = 10;

//zmienne do funkcji rdtsc
long long int start,end;

void fun1(){
    start = rdtsc();
    printInt(mojInt);
    end=rdtsc();
    return;
}

void fun2(){
    start = rdtsc();
    printFloat(mojFloat);
    end=rdtsc();
    return;
}

void fun3(){
    start = rdtsc();
    printChar(mojChar);
    end=rdtsc();
    return;
}

void fun4(){
    start = rdtsc();
    mojScanf(bufor);
    end=rdtsc();
    return;
}

void (*wsk[4])(void) = {fun1,fun2,fun3,fun4};

int main(){

double time;
double wyniki[4];

int i;
for(i=0;i<4;i++){
    wsk[i]();
    time = ((double)(end-start))/CLOCKS_PER_SEC;
    wyniki[i]=time/dzielnik;
    printf("\n");
}


printf("Czasy:\nprintInt  printFloat  printChar  mojScanf\n");

for(i =0; i<4; i++){
    printf("%f ",*(wyniki+i));
}

printf("\n");
return 0;
}
