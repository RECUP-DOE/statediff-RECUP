#!/usr/bin/env bash
set -euo pipefail

SPACK_DIR="$1"
PROJECT_ROOT="$2"
VENV_DIR="$3"
SPACK_ENV_NAME="statediff-env"

if [ ! -d "$SPACK_DIR" ]; then
    echo "Cloning Spack..."
    git clone --depth=1 https://github.com/spack/spack.git "$SPACK_DIR"
fi
. "$SPACK_DIR/share/spack/setup-env.sh"

if ! spack env list | grep -q "$SPACK_ENV_NAME"; then
    spack env create "$SPACK_ENV_NAME" "$PROJECT_ROOT/spack.yaml"
fi
spack env activate "$SPACK_ENV_NAME"
spack external find cmake ninja openssl || true

spack mirror add E4S https://cache.e4s.io
spack buildcache keys --install --trust
spack concretize --force
spack install --use-buildcache auto

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel pybind11 numpy