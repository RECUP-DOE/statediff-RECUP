#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPACK_DIR="$PROJECT_ROOT/external/spack"
BUILD_DIR="$PROJECT_ROOT/build"
VENV_DIR="$PROJECT_ROOT/venv"

./scripts/setup_env.sh "$SPACK_DIR" "$PROJECT_ROOT" "$VENV_DIR"
./scripts/build.sh "$SPACK_DIR" "$PROJECT_ROOT" "$BUILD_DIR" "$VENV_DIR"