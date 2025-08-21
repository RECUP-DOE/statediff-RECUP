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
OPENSSL_PREFIX="$(spack location -i openssl)"

CMAKE_BIN="$(spack location -i cmake)/bin/cmake"
NINJA_BIN="$(spack location -i ninja)/bin/ninja"

CMAKE_PREFIX_PATH_LIST="$MPI_PREFIX;$KOKKOS_PREFIX;${LIBURING_PREFIX:-};$PYBIND11_PREFIX;${OPENSSL_PREFIX:-}"

# Site-packages of the venv where we'll install the module
SITE="$("$VENV_DIR/bin/python" -c 'import sysconfig; print(sysconfig.get_paths()["platlib"])')"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
ARGPARSE_DIR="$PROJECT_ROOT/.deps/argparse"
rm -rf "$ARGPARSE_DIR"
git clone --depth 1 https://github.com/p-ranav/argparse.git "$ARGPARSE_DIR"

"$CMAKE_BIN" -S "$PROJECT_ROOT" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_MAKE_PROGRAM="$NINJA_BIN" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_CXX_COMPILER="${CXX:-$(command -v c++)}" \
  -DKokkos_DIR="$KOKKOS_PREFIX/lib/cmake/Kokkos" \
  -DCMAKE_INSTALL_PREFIX="$SITE" \
  -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH_LIST" \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
  -DCMAKE_INSTALL_RPATH="${KOKKOS_PREFIX}/lib;${SITE}/statediff/lib"

"$CMAKE_BIN" --build "$BUILD_DIR" -j
"$CMAKE_BIN" --install "$BUILD_DIR"

# Sanity check
source "$VENV_DIR/bin/activate"
python - <<'PY'
import importlib.util, sysconfig, subprocess
p = sysconfig.get_paths()["platlib"]
print("platlib:", p)
spec = importlib.util.find_spec("statediff")
print("module:", spec.origin)
subprocess.run(["ldd", spec.origin])
PY
echo "Python module of Statediff successfully installed. (*_*)"
echo "First source the virtual environment: source venv/bin/activate"

# ========= if you desire to build through pip instead of Cmake ============
# The commands below use the setup.py file to direct the installation of the 
# python package through pip

# cd "$PROJECT_ROOT"
# export KOKKOS_PREFIX="$(spack location -i kokkos)"
# export LIBURING_PREFIX="$(spack location -i liburing)"
# export STATEDIFF_PREFIX="$PROJECT_ROOT/build/state-diff-install"
# pip install -U pip build
# pip install .