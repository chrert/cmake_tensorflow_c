# cmake_tensorflow_c

CMake project to build the tensorflow C-API. It automatically downloads and builds tensorflow.

## Tensorflow compile-time flags

The script passes through all the `TF_*` flags to the tensorflow build configuration. Just export them before building or define them in a parent CMake project, respectively.

```bash
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=<FILL_IN> ..
make
make install
```

To build with MKL/CUDA support, simply set the corresponding variables before calling make:

```bash
# this will build with CUDA and MKL enabled
TF_NEED_CUDA=1 TF_NEED_MKL=1 make
```

Sometimes it's necessary to pass additional arguments to the bazel (for example to overcome version conflicts):
```bash
ADDITIONAL_BAZEL_OPTS='--incompatible_load_argument_is_label=false' make
```

## Example

For and example of usage within another CMake project see <https://github.com/chrert/tfdetect>.
