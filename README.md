# cmake_tensorflow_c

CMake project to build the tensorflow C-API. It automatically downloads tensorflow and builds the CPU-Version with MKL-DNN support.

## Tensorflow compile-time flags

The script passes through all the `TF_*` flags to the tensorflow build configuration. Just export them before building or define them in a parent CMake project, respectively.
