#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$1"
BUILD_DIR="$2"
VENV_DIR="$3"

MPI_PREFIX=$(spack location -i openmpi || true)
KOKKOS_PREFIX=$(spack location -i kokkos || true)
LIBURING_PREFIX=$(spack location -i liburing || true)
PYBIND11_PREFIX=$(spack location -i py-pybind11 || true)

export CMAKE_PREFIX_PATH="$MPI_PREFIX:$KOKKOS_PREFIX:$LIBURING_PREFIX:$PYBIND11_PREFIX"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake "$PROJECT_ROOT" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-fPIC" \
    -DPython_EXECUTABLE="$VENV_DIR/bin/python"

cmake --build . --parallel
cmake --install .
