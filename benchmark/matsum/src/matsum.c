
#include "dataset3.h"
#include <stddef.h>


void matsum(int N, int M, const data_t A[], const data_t B[], data_t C[])
{
  int i, j;

  for (i = 0; i < N; i++) {
    for (j = 0; j < M; j++) {
      C[i*N + j] = A[i*N + j] + B[i*N + j];
    }
  }
}

void main()
{
	static data_t results_data[ARRAY_SIZE];
	matsum(DIM_SIZE, DIM_SIZE, input1_data, input2_data, results_data);
}
