#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPACK_DIR="$PROJECT_ROOT/external/spack"
BUILD_DIR="$PROJECT_ROOT/build"
VENV_DIR="$PROJECT_ROOT/venv"

./scripts/setup_spack.sh "$SPACK_DIR"
./scripts/setup_env.sh "$PROJECT_ROOT" "$VENV_DIR"
./scripts/build.sh "$PROJECT_ROOT" "$BUILD_DIR" "$VENV_DIR"

cd "$PROJECT_ROOT"
export KOKKOS_PREFIX=$(spack location -i kokkos)
pip install .