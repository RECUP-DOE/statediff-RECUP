pybind11_add_module(statediff_py MODULE bindings.cpp)

set(STATEDIFF_LIB_DIR "${CMAKE_BINARY_DIR}/state-diff-install/lib")

target_link_libraries(statediff_py PRIVATE
   "${STATEDIFF_LIB_DIR}/libstatediff.so"
   Kokkos::kokkos OpenSSL::SSL OpenMP::OpenMP_CXX)

target_link_libraries(statediff_py PRIVATE
    statediff-RECUP
    Kokkos::kokkos OpenSSL::SSL OpenMP::OpenMP_CXX)

target_include_directories(statediff_py PRIVATE
    ${PROJECT_SOURCE_DIR}/external/state-diff/include
    ${PROJECT_SOURCE_DIR}/external/state-diff/src
    ${PROJECT_SOURCE_DIR}/external/state-diff/src/readers
    ${PROJECT_SOURCE_DIR}/external/state-diff/extern/cereal/include
)
