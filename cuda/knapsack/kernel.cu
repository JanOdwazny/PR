#include <iostream>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <vector>
#include <algorithm>
#include <random>
#include <time.h>
#include <cuda.h>
#include <chrono>

int CAPACITY[] = { 10000, 20000, 30000,40000, 50000,60000 };
int NUM_ITEMS[] = { 5000, 10000, 15000, 30000, 40000, 50000 };

using namespace std::chrono;




__global__ void knapsackKernel(int* d_weights, int* d_values, int* d_dp, int num_items, int capacity) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i > capacity) return;

    for (int item = 1; item <= num_items; ++item) {
        if (i >= d_weights[item - 1]) {
            int included = d_values[item - 1] + d_dp[(item - 1) * (capacity + 1) + (i - d_weights[item - 1])];
            int excluded = d_dp[(item - 1) * (capacity + 1) + i];
            d_dp[item * (capacity + 1) + i] = fmax(included, excluded);
        }
        else {
            d_dp[item * (capacity + 1) + i] = d_dp[(item - 1) * (capacity + 1) + i];
        }
    }

}

int main() {
    srand(time(NULL));
    /*const int num_items = 10000;*/
    
    //int values[num_items] = { 0 };
    //int weights[num_items] = { 0 };
    int capacity = 10000;

    for (int i = 0; i < 6; i++) {
        //int capacity = CAPACITY[i];
        int num_items = NUM_ITEMS[i];
        int* values = new int[num_items];
        int* weights = new int[num_items];
        
        
        for (int j = 0; j < num_items; j++)
        {
            values[j] = rand() % 100 + 10;
            weights[j] = rand() % (capacity / 2) + 1;
        }
        

        int size = (num_items + 1) * (capacity + 1);
        std::vector<int> dp(size, 0);

        int* d_weights, * d_values, * d_dp;
        cudaMalloc((void**)&d_weights, num_items * sizeof(int));
        cudaMalloc((void**)&d_values, num_items * sizeof(int));
        cudaMalloc((void**)&d_dp, size * sizeof(int));

        cudaMemcpy(d_weights, weights, num_items * sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_values, values, num_items * sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_dp, dp.data(), size * sizeof(int), cudaMemcpyHostToDevice);

        int blockSize = 256;
        int numBlocks = (capacity + blockSize - 1) / blockSize;

       
        auto start = high_resolution_clock::now();
        
        
        knapsackKernel << <numBlocks, blockSize >> > (d_weights, d_values, d_dp, num_items, capacity);
       
        cudaDeviceSynchronize();

       
        auto stop = high_resolution_clock::now();
        auto duration = duration_cast<milliseconds>(stop - start);

        std::cout << capacity << ":" << num_items << ":" <<duration.count()<< std::endl;
        cudaMemcpy(dp.data(), d_dp, size * sizeof(int), cudaMemcpyDeviceToHost);

        

        cudaFree(d_weights);
        cudaFree(d_values);
        cudaFree(d_dp);

        delete[] values;
        delete[] weights;
    }

    return 0;
}
