cmake_minimum_required(VERSION 3.16)
project(state-diff-RECUP LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Kokkos REQUIRED)
find_package(OpenMP REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(pybind11 REQUIRED)
find_package(Python REQUIRED COMPONENTS Interpreter Development)


include(ExternalProject)
ExternalProject_Add(
  state-diff
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/external/state-diff
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/state-diff-install
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
    -DCMAKE_PREFIX_PATH=$ENV{CMAKE_PREFIX_PATH}
  BUILD_ALWAYS OFF
  INSTALL_DIR ${CMAKE_BINARY_DIR}/state-diff-install
  BUILD_BYPRODUCTS ${CMAKE_BINARY_DIR}/state-diff-install/lib/libstatediff.so
)

add_library(statediff-RECUP INTERFACE)
add_dependencies(statediff-RECUP state-diff)

target_include_directories(statediff-RECUP INTERFACE
  ${CMAKE_BINARY_DIR}/state-diff-install/include
)

target_link_libraries(statediff-RECUP INTERFACE
  ${CMAKE_BINARY_DIR}/state-diff-install/lib/libstatediff.so  # or .so
)

add_subdirectory(python)

enable_testing()
add_subdirectory(tests/statediff)