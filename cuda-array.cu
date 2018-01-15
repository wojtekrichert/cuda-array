#include <stdio.h>
#include <math.h>
#include <ctime>
#include <stdlib.h>
using namespace std;
const unsigned long long int size = 2147483648;

unsigned long long int  dodawanie(unsigned long long int *array){
  unsigned long long int suma =0;
  for(unsigned long long int i =0; i <size; i++){
    suma = suma + array[i];
  }
  printf("%llu ", suma);
  return suma;
}

int main(void){
  unsigned long long int *array= new unsigned long long int[size];
  for(unsigned long long int i =0; i<size;i++){
    array[i]=rand() % 100 + 1;
  }
  //Kod na CPU:--------------------------------------------
  clock_t begin = clock();
  unsigned long long int suma =dodawanie(array);
  printf("%llu ", suma);
  clock_t end = clock();
  double elapsed_secs = (double(end - begin) / CLOCKS_PER_SEC);
  printf("czas CPU: %f \n", elapsed_secs);
  //-------------------------------------------------------



free(array);
}
