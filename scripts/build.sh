#!/usr/bin/env bash
set -euo pipefail

SPACK_DIR="$1"
PROJECT_ROOT="$2"
BUILD_DIR="$3"
VENV_DIR="$4"
SPACK_ENV_NAME="statediff-env"

. "$SPACK_DIR/share/spack/setup-env.sh"
spack env activate "$SPACK_ENV_NAME"

MPI_PREFIX="$(spack location -i openmpi)"
KOKKOS_PREFIX="$(spack location -i kokkos)"
LIBURING_PREFIX="$(spack location -i liburing)"
PYBIND11_PREFIX="$(spack location -i py-pybind11)"

export CMAKE_PREFIX_PATH="${MPI_PREFIX}:${KOKKOS_PREFIX}:${LIBURING_PREFIX}:${PYBIND11_PREFIX}"

SITE="$("$VENV_DIR/bin/python" -c 'import sysconfig; print(sysconfig.get_paths()["platlib"])')"

rm -rf "$BUILD_DIR"
rm -rf $PROJECT_ROOT/.deps/argparse
mkdir -p "$BUILD_DIR"
git clone https://github.com/p-ranav/argparse.git $PROJECT_ROOT/.deps/argparse

cmake -S "$PROJECT_ROOT" -B "$BUILD_DIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DKokkos_DIR="$KOKKOS_PREFIX/lib/cmake/Kokkos" \
  -DCMAKE_INSTALL_PREFIX="$SITE" \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
  -DCMAKE_INSTALL_RPATH="${KOKKOS_PREFIX}/lib;${SITE}/statediff/lib"

cmake --build "$BUILD_DIR" --parallel
cmake --install "$BUILD_DIR"

cd "$PROJECT_ROOT"
export KOKKOS_PREFIX="$(spack location -i kokkos)"
export LIBURING_PREFIX="$(spack location -i liburing)"
export STATEDIFF_PREFIX="$PROJECT_ROOT/build/state-diff-install"
source "$VENV_DIR/bin/activate"
pip install -U pip build
pip install .

# Sanity check
echo "Installed to: $SITE"
python - <<'PY'
import sys, sysconfig, importlib
print("platlib:", sysconfig.get_paths()["platlib"])
m = importlib.import_module("statediff")  # should import cleanly now
print("statediff imported OK from:", m.__file__)
PY
