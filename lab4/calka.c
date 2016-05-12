#include <stdio.h>
const float beg = 0.001;
const float end = 1000;

float calka(int N){

	float delta = (end-beg) / N;
	float mid = beg +  delta/2;
	float pole = 0;


	int i;
	float h = 0;
	for(i = 0; i < N; i++){

		h += 1/mid;
		mid = mid + delta;

	}
	pole = h*delta;
	return pole;
}

int main(){

	float wynik = calka(10);
	printf("\n %f \n",wynik);
	return 0;
}
