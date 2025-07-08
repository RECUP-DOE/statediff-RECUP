#!/usr/bin/env bash
set -euo pipefail

SPACK_DIR="$1"

if [ ! -d "$SPACK_DIR" ]; then
    echo "Cloning Spack..."
    git clone --depth=1 https://github.com/spack/spack.git "$SPACK_DIR"
fi

. "$SPACK_DIR/share/spack/setup-env.sh"
