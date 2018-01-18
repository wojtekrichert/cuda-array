#include <stdio.h>
#include <math.h>
#include <ctime>
#include <stdlib.h>
using namespace std;
const int BLOCK_SIZE = 128;
const long int size = 134217728;


double  dodawanie(double *array){
  double suma =0;
  for(int i =0; i <size; i++){
    suma = suma + array[i];
  }
  return suma;
}

__global__  void total(double * input, double * output, long int len)
{
    __shared__ double suma_czesciowa[2*BLOCK_SIZE];
    int globalThreadId = blockIdx.x*blockDim.x + threadIdx.x;
    unsigned int t = threadIdx.x;
    unsigned int start = 2*blockIdx.x*blockDim.x;

    if ((start + t) < len)
    {
        suma_czesciowa[t] = input[start + t];
    }
    else
    {
        suma_czesciowa[t] = 0.0;
    }
    if ((start + blockDim.x + t) < len)
    {
        suma_czesciowa[blockDim.x + t] = input[start + blockDim.x + t];
    }
    else
    {
        suma_czesciowa[blockDim.x + t] = 0.0;
    }

    for (unsigned long long q = blockDim.x; q > 0; q /= 2)
    {
      __syncthreads();
        if (t < q)
            suma_czesciowa[t] += suma_czesciowa[t + q];
    }
    __syncthreads();

    if (t == 0 && (globalThreadId*2) < len)
    {
        output[blockIdx.x] = suma_czesciowa[t];
    }
}


int main(void){
  double *array= new double[size];
  for(int i =0; i<size;i++){
    array[i]=(rand() % 100 + 1)*(rand() % 100 + 1);
  }
  //Kod na CPU:--------------------------------------------
  clock_t begin = clock();
  double suma =dodawanie(array);
  printf("%f ", suma);
  clock_t end = clock();
  double elapsed_secs = (double(end - begin) / CLOCKS_PER_SEC);
  printf("czas CPU: %f \n", elapsed_secs);
  //-------------------------------------------------------
  double * d_array;
  cudaMalloc(&d_array, size*sizeof(double));


  double * arrayOUT;
  double * d_arrayOUT;
  double numOutputElements;
  numOutputElements = size / (BLOCK_SIZE<<1);
  if (size % (BLOCK_SIZE<<1))
  {
      numOutputElements++;
  }
  arrayOUT = (double*) malloc(numOutputElements * sizeof(double));

  cudaMalloc((void **)&d_arrayOUT, numOutputElements * sizeof(double));
  cudaMemcpy(d_array, array, size * sizeof(double), cudaMemcpyHostToDevice);

  dim3 DimGrid( numOutputElements, 1, 1);
  dim3 DimBlock(BLOCK_SIZE, 1, 1);

  clock_t begin1 = clock();
  total<<<DimGrid, DimBlock>>>(d_array, d_arrayOUT, size);
  cudaMemcpy(arrayOUT, d_arrayOUT, numOutputElements * sizeof(double), cudaMemcpyDeviceToHost);
  for (int ii = 1; ii < numOutputElements; ii++)
  {
      arrayOUT[0] += arrayOUT[ii];
  }
  clock_t end1 = clock();
  printf("%f ", arrayOUT[0]);
  double elapsed_secs1 = (double(end1 - begin1) / CLOCKS_PER_SEC);
  printf("czas CPU: %f \n", elapsed_secs1);
  printf("przyspieszenie: %f razy\n", (elapsed_secs/elapsed_secs1));

  // Free the GPU memory here
  cudaFree(d_array);
  cudaFree(d_arrayOUT);
  free(arrayOUT);



free(array);
}
