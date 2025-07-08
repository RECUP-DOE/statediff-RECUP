#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$1"
VENV_DIR="$2"
SPACK_ENV_NAME="statediff-env"

. "$PROJECT_ROOT/external/spack/share/spack/setup-env.sh"

if ! spack env list | grep -q "$SPACK_ENV_NAME"; then
    spack env create "$SPACK_ENV_NAME" "$PROJECT_ROOT/spack.yaml"
fi

spack env activate "$SPACK_ENV_NAME"
spack concretize --force
spack install

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel pybind11