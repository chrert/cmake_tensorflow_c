cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
project(tensorflow_c VERSION 1.0)

include(ExternalProject)
include(CMakePackageConfigHelpers)

ExternalProject_Add(
  "external_mkl_dnn"
  URL "https://github.com/01org/mkl-dnn/releases/download/v0.12/mklml_lnx_2018.0.1.20171227.tgz"
  SOURCE_DIR "mkl_dnn"
  BUILD_IN_SOURCE 1
  CMAKE_COMMAND ""
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)

ExternalProject_Add(
  "external_tensorflow_c"
  DEPENDS "external_mkl_dnn"
  URL "https://github.com/tensorflow/tensorflow/archive/v1.4.1.tar.gz"
  TMP_DIR "/tmp"
  DOWNLOAD_DIR "tensorflow"
  SOURCE_DIR "tensorflow"
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND ""
  BUILD_COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/build_tensorflow.sh" .
        COMMAND ./build_tensorflow.sh
  INSTALL_COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package
          COMMAND tar --directory ${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package -xvzf bazel-bin/tensorflow/tools/lib_package/libtensorflow.tar.gz
          # COMMAND chrpath -r ${CMAKE_CURRENT_BINARY_DIR}/mkl_dnn/lib:${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package/lib ${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package/lib/libtensorflow.so
          # COMMAND chrpath -r ${CMAKE_CURRENT_BINARY_DIR}/mkl_dnn/lib:${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package/lib ${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package/lib/libtensorflow_framework.so
)

set(MKL_DNN_INCLUDE ${CMAKE_CURRENT_BINARY_DIR}/mkl_dnn/include)
list(APPEND MKL_DNN_LIBS ${CMAKE_CURRENT_BINARY_DIR}/mkl_dnn/lib/libiomp5.so
                         ${CMAKE_CURRENT_BINARY_DIR}/mkl_dnn/lib/libmklml_gnu.so
                         ${CMAKE_CURRENT_BINARY_DIR}/mkl_dnn/lib/libmklml_intel.so)

set(TFC_INCLUDE ${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package/include)
list(APPEND TFC_LIBS ${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package/lib/libtensorflow.so
                    ${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package/lib/libtensorflow_framework.so)

add_library(mkl_dnn INTERFACE)
add_dependencies(mkl_dnn external_mkl_dnn)
target_compile_options(mkl_dnn INTERFACE "-std=c++11")
target_include_directories(mkl_dnn INTERFACE ${MKL_DNN_INCLUDE})
target_link_libraries(mkl_dnn INTERFACE ${MKL_DNN_LIBS})

add_library(tensorflow_c INTERFACE)
add_dependencies(tensorflow_c external_tensorflow_c)
target_compile_options(tensorflow_c INTERFACE "-std=c++11")
target_include_directories(tensorflow_c INTERFACE ${TFC_INCLUDE})
target_link_libraries(tensorflow_c INTERFACE ${TFC_LIBS} ${MKL_DNN_LIBS})

# copy libs to build folder
add_custom_command(TARGET external_tensorflow_c POST_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/mkl_dnn/lib ${CMAKE_CURRENT_BINARY_DIR}/tf_lib_package/lib)

# install headers
install(DIRECTORY ${MKL_DNN_INCLUDE}
        DESTINATION include/mkl_dnn
        FILES_MATCHING PATTERN "*")
install(DIRECTORY ${TFC_INCLUDE}
        DESTINATION include)

# install shared libs
install(FILES ${TFC_LIBS}
        DESTINATION lib)
install(FILES ${MKL_DNN_LIBS}
        DESTINATION lib)
