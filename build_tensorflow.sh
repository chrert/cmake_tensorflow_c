#!/bin/bash

set -e

(
#bazel clean

export CC_OPT_FLAGS="-march=native"
export TF_NEED_S3=${TF_NEED_S3-0}
export TF_NEED_GDR=${TF_NEED_GDR-0}
export TF_NEED_GCP=${TF_NEED_GCP-0}
export TF_NEED_HDFS=${TF_NEED_HDFS-0}
export TF_NEED_OPENCL=${TF_NEED_OPENCL-0}
export TF_NEED_JEMALLOC=${TF_NEED_JEMALLOC-1}
export TF_NEED_VERBS=${TF_NEED_VERBS-0}
export TF_NEED_MPI=${TF_NEED_MPI-0}
export TF_ENABLE_XLA=${TF_ENABLE_XLA-0}
export TF_CUDA_CLANG=${TF_CUDA_LANG-0}
export TF_NEED_CUDA=${TF_NEED_CUDA-0}

export TF_NEED_MKL=1
export TF_DOWNLOAD_MKL=0
export TF_MKL_ROOT="$(readlink -e ../mkl_dnn)"

export PYTHON_BIN_PATH="$(which python)"
export PYTHON_LIB_PATH="$(${PYTHON_BIN_PATH} -c 'import site; print(site.getsitepackages()[0])')"

./configure

CONFIG="-c opt"
if [ "${TF_NEED_MKL}" == "1" ]
then
  CONFIG="--config=mkl ${CONFIG} --copt=-DEIGEN_USE_VML"
fi

ADDITIONAL_BAZEL_OPTS="--incompatible_load_argument_is_label=false"

bazel build ${ADDITIONAL_BAZEL_OPTS} --verbose_failures ${CONFIG} tensorflow:libtensorflow.so
bazel build ${ADDITIONAL_BAZEL_OPTS} --verbose_failures ${CONFIG} //tensorflow/tools/lib_package:libtensorflow
)
