cmake_minimum_required(VERSION 3.14)
project(statediff-RECUP LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Kokkos CONFIG REQUIRED) 
find_package(OpenMP REQUIRED)
find_package(OpenSSL REQUIRED)

include(ExternalProject)

set(STATE_DIFF_INSTALL "${CMAKE_BINARY_DIR}/state-diff-install" CACHE PATH "state-diff install dir")

# Considering that state-diff is using "FetchContent_Declare" to clone the argparse package, we need to
# pre-stage it in to avoid the following error:
# "fatal: destination path 'argparse-src' already exists and is not an empty directory."
set(ARGPARSE_LOCAL "${CMAKE_SOURCE_DIR}/.deps/argparse" CACHE PATH "Local argparse source dir")
if(NOT EXISTS "${ARGPARSE_LOCAL}/include/argparse/argparse.hpp")
  message(FATAL_ERROR
    "ARGPARSE_LOCAL is missing argparse.hpp.\n"
    "Expected: ${ARGPARSE_LOCAL}/include/argparse/argparse.hpp")
endif()

ExternalProject_Add(
  state-diff
  SOURCE_DIR ${CMAKE_SOURCE_DIR}/external/state-diff
  BINARY_DIR  ${CMAKE_BINARY_DIR}/state-diff-build 
  INSTALL_DIR ${STATE_DIFF_INSTALL}
  CMAKE_GENERATOR "${CMAKE_GENERATOR}"
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=${STATE_DIFF_INSTALL}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
    -DCMAKE_PREFIX_PATH=$ENV{CMAKE_PREFIX_PATH}
    -DKokkos_DIR=${Kokkos_DIR}
    -DBUILD_SHARED_LIBS=ON
    -DCMAKE_CXX_STANDARD=17
  CMAKE_CACHE_ARGS
    -DFETCHCONTENT_SOURCE_DIR_ARGPARSE:PATH=${ARGPARSE_LOCAL}
    -DFETCHCONTENT_FULLY_DISCONNECTED:BOOL=ON
    -DFETCHCONTENT_UPDATES_DISCONNECTED:BOOL=ON
  BUILD_ALWAYS OFF
  BUILD_BYPRODUCTS ${STATE_DIFF_INSTALL}/lib/libstatediff.so
)

add_library(statediff_external SHARED IMPORTED GLOBAL)
set_target_properties(statediff_external PROPERTIES
  IMPORTED_LOCATION             "${STATE_DIFF_INSTALL}/lib/libstatediff.so"
)
ExternalProject_Add_StepTargets(state-diff install)
add_dependencies(statediff_external state-diff-install)

add_subdirectory(python)

enable_testing()
add_subdirectory(tests/statediff)