#include <cuda_runtime.h>
#include <iostream>
#include <fstream>
#include <cstring>
#include <vector>
#include <string>
#include <cuda.h>
#include "device_launch_parameters.h"
#include <sstream>


struct Employee {
    char name[256];
    int year;
    float salary;
};

struct Result {
    char data[256];
};

__device__ const char* salaryFromScore(float s) {
    if (s >= 50000) return "TOP";
    else if (s >= 25000) return "AVERAGE";
    else return "LEAST";
}

__device__ void toUpperString(char* str) {
    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] >= 'a' && str[i] <= 'z') {
            str[i] = str[i] - 'a' + 'A';
        }
    }
}

std::vector<Employee> read(const char* filename) {
    std::vector<Employee> employees;
    std::ifstream file(filename);
    std::string line;

    while (std::getline(file, line)) {
        Employee s;
        sscanf(line.c_str(), "%[^,],%d,%f", s.name, &s.year, &s.salary);
        employees.push_back(s);
    }

    file.close();
    return employees;
}

__global__ void process(Employee* employees, Result* results, int numEmployees, int* resultCounter) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    // the starting index of the current block in the grid adding the index of the thread
    if (idx < numEmployees) {
        Employee s = employees[idx];
        if (s.name[0] > 'O') {
            toUpperString(s.name);

            char computed[256];
            int indexing = 0;
            for (int i = 0; s.name[i] != '\0'; i++) {
                computed[indexing++] = s.name[i];
            }
            computed[indexing++] = '-';
            computed[indexing++] = '0'+ s.year;
            computed[indexing++] = '-';

            const char* ss = salaryFromScore(s.salary);
            int i;
            for (i = 0; ss[i] != '\0'; i++) {
                computed[indexing++] = ss[i];
            }
            computed[indexing] = '\0';  // Add a null terminator to the end of computed

            

            // Write to result array using atomic operation
            int jjj = atomicAdd(resultCounter, 1);
            for (int i = 0; computed[i] != '\0'; i++) {
                results[jjj].data[i] = computed[i];
            }
            results[jjj].data[indexing] = '\0'; // Null-terminate the result
        }
    }
}

int main() {
    
    std::vector<Employee> employeeVector = read("Employees.txt");
    int numEmployees = employeeVector.size();

    // Prepare arrays for CUDA

    Result* h_results = new Result[numEmployees];
    int h_resultCounter = 0;

    
    // Allocate memory on GPU
    Employee* d_employees;
    Result* d_results;
    int* d_resultCounter;
    cudaMalloc(&d_employees, numEmployees * sizeof(Employee));
    cudaMalloc(&d_results, numEmployees * sizeof(Result));
    cudaMalloc(&d_resultCounter, sizeof(int));

    // Copy data from host to device
    cudaMemcpy(d_employees, employeeVector.data(), numEmployees * sizeof(Employee), cudaMemcpyHostToDevice);
    cudaMemcpy(d_resultCounter, &h_resultCounter, sizeof(int), cudaMemcpyHostToDevice);

    int blockSize = 64; 
    int numBlocks = (numEmployees + blockSize - 1) / blockSize;
    process <<<numBlocks, blockSize >>> (d_employees, d_results, numEmployees, d_resultCounter);


    cudaMemcpy(h_results, d_results, numEmployees * sizeof(Result), cudaMemcpyDeviceToHost);
    cudaMemcpy(&h_resultCounter, d_resultCounter, sizeof(int), cudaMemcpyDeviceToHost);


    std::ofstream outFile("results.txt");
    for (int i = 0; i < h_resultCounter; i++) {
        outFile << h_results[i].data << std::endl;
    }
    outFile.close();


    cudaFree(d_employees);
    cudaFree(d_results);
    cudaFree(d_resultCounter);

    return 0;
}