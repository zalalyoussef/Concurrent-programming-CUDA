# Concurrent Student Data Processing with CUDA

This project demonstrates the use of **CUDA** for concurrent processing of student data. The data is divided across GPU threads, where each thread processes a student's information and applies specific conditions to determine whether the student meets certain criteria. The processed results are then stored in a shared memory array and written to an output file.

## Project Overview

The project involves reading a JSON file containing student data (name, year, grade), applying a filter (students whose names start after "P"), transforming the name to uppercase, concatenating the year, and determining a letter grade based on the student's grade. The results are then written to an output file.

### Example Input:
```json
{
  "students": [
    {"name": "Antanas", "year": 1, "grade": 6.95},
    {"name": "Kazys", "year": 2, "grade": 8.65},
    {"name": "Petras", "year": 2, "grade": 7.01},
    {"name": "Sonata", "year": 3, "grade": 9.13},
    {"name": "Jonas", "year": 1, "grade": 6.95},
    // more students...
  ]
}
```

### Example Output:
```
SONATA-3A
VACYS-2B
ROBERTAS-3D
VIKTORAS-2B
VYTAS-3C
ZIGMAS-3A
SIMAS-3D
```

## Requirements

- **NVIDIA GPU** with **CUDA** support
- **CUDA 11.6** (or compatible version)
- **Nlohmann JSON** library for parsing JSON data
- **Linux or Windows Subsystem for Linux (WSL)** with access to CUDA server (if using remote server)

### Software Dependencies:
- `nvcc` (CUDA compiler)
- `nlohmann-json` (JSON library for C++)

## Installation Instructions

### 1. Clone the repository:
```bash
git clone https://github.com/yourusername/concurrent-student-data-processing.git
cd concurrent-student-data-processing
```

### 2. Install Dependencies:
- On Linux, install the required libraries:
  ```bash
  sudo apt install nlohmann-json-dev
  ```
- For Windows, you can follow the steps to set up **CUDA** and the **Nlohmann JSON** library in your development environment.

### 3. Set up CUDA:
- Ensure you have **CUDA 11.6** or a compatible version installed. If you don’t have CUDA installed, follow the [installation guide](https://developer.nvidia.com/cuda-downloads).
- On the **CUDA server** (if using), ensure you have access via SSH.

### 4. Compile the Program:
- If you are using **NVCC** (CUDA Compiler), compile the program with:
  ```bash
  nvcc program.cu -o studentProcessor
  ```

- If you're compiling on a server, use the following (to specify the correct C++ version):
  ```bash
  nvcc -ccbin=/usr/bin/g++-10 --std=c++17 program.cu -o studentProcessor
  ```

### 5. Run the Program:
- After compiling, run the program:
  ```bash
  ./studentProcessor
  ```

## Usage

1. **Input File**: 
   - The input file should be in **JSON** format (see the example above) and should contain an array of student objects with the `name`, `year`, and `grade`.

2. **Output File**: 
   - The program will generate an output file with the processed student data, formatted as:
     ```
     NAME-YEARGRADE
     ```
     Only students whose names start alphabetically after "P" will be processed.

3. **Processing**:
   - The program uses **CUDA** to distribute data across multiple GPU threads, where each thread computes whether the student should be included in the output based on the specified conditions.

## CUDA Implementation Details

- **CUDA Kernels**: Each thread processes a portion of the student data, checks if the student's name starts with a letter after "P", converts the name to uppercase, and computes a grade letter.
- **Memory Management**: 
  - **Global Memory** is used for storing the student data and the results.
  - **Atomic Operations** are used to safely write the results to the result array, ensuring no race conditions occur between threads.
  - **Shared Memory** can be used within blocks for efficient intermediate result storage.

## Troubleshooting

- Ensure your system has an **NVIDIA GPU** with **CUDA** support.
- If using the **CUDA server**, ensure you have access credentials.
- If you encounter memory issues, try reducing the number of students or GPU threads.

## Example Output

Assuming the input data meets the required conditions, the output might look like this:

```
SONATA-3A
VACYS-2B
ROBERTAS-3D
VIKTORAS-2B
VYTAS-3C
ZIGMAS-3A
SIMAS-3D
```

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, feel free to fork this repository and submit a pull request.

## License

This project is licensed under the MIT License
