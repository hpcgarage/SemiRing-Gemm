#pragma once

#include "Matrix.hpp"

#include <cuda.h>

namespace fwgpu {
auto cublas_sgemm(
    const float *A, const float *B, float *C, const int m, const int k, const int n)
    -> void;

auto cutlass_sgemm_nn(
    int M,
    int N,
    int K,
    float alpha,
    float const *A,
    int lda,
    float const *B,
    int ldb,
    float beta,
    float *C,
    int ldc,
    cudaStream_t stream = nullptr) -> cudaError_t;

template <typename T>
__global__ auto gpu_gemm_naive(
    int m,
    int n,
    int k,
    const T *__restrict__ left,
    const T *__restrict__ right,
    T *__restrict__ dest) -> void {
  size_t ty = blockIdx.y * blockDim.y + threadIdx.y;
  size_t tx = blockIdx.x * blockDim.x + threadIdx.x;

  size_t n_idx = ty;
  while (n_idx < n) {
    size_t m_idx = tx;
    while (m_idx < m) {
      T tmp = static_cast<T>(0);
      for (size_t k_idx = 0; k_idx < k; ++k_idx) {
        tmp += left[(k_idx * m) + m_idx] * right[(n_idx * k) + k_idx];
      }
      dest[(n_idx * m) + m_idx] = tmp;
      m_idx += gridDim.x * blockDim.x;
    }
    n_idx += gridDim.y * blockDim.y;
  }
}

} // namespace fwgpu
