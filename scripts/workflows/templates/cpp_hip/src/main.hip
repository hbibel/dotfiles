#include <hip/hip_runtime.h>
#include <iostream>
#include <vector>

#define CHECK(cmd) \
    { \
        hipError_t error = cmd; \
        if (error != hipSuccess) { \
            fprintf(stderr, "error: '%s'(%d) at %s:%d\n", \
                    hipGetErrorString(error), error, __FILE__, __LINE__); \
            exit(EXIT_FAILURE); \
        } \
    }

__global__ void vector_add(const float* A, const float* B, float* C, int N) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < N) {
        C[i] = A[i] + B[i];
    }
}

int main() {
    int N = 1024 * 1024;
    size_t bytes = N * sizeof(float);

    // Host memory
    std::vector<float> h_A(N, 1.0f);
    std::vector<float> h_B(N, 2.0f);
    std::vector<float> h_C(N);

    // Device memory
    float *d_A, *d_B, *d_C;
    CHECK(hipMalloc(&d_A, bytes));
    CHECK(hipMalloc(&d_B, bytes));
    CHECK(hipMalloc(&d_C, bytes));

    CHECK(hipMemcpy(d_A, h_A.data(), bytes, hipMemcpyHostToDevice));
    CHECK(hipMemcpy(d_B, h_B.data(), bytes, hipMemcpyHostToDevice));

    int blockSize = 256;
    int gridSize = (N + blockSize - 1) / blockSize;

    // Kernel launch
    vector_add<<<gridSize, blockSize>>>(d_A, d_B, d_C, N);
    
    CHECK(hipDeviceSynchronize());
    CHECK(hipMemcpy(h_C.data(), d_C, bytes, hipMemcpyDeviceToHost));

    std::cout << "HIP Test: 1.0 + 2.0 = " << h_C[0] << std::endl;
    std::cout << "Success!" << std::endl;

    hipFree(d_A);
    hipFree(d_B);
    hipFree(d_C);

    return 0;
}
