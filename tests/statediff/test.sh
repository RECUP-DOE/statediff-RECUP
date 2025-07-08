#!/bin/bash
set -e

echo "Activating Spack environment..."
. $HOME/spack/share/spack/setup-env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_CPP="$SCRIPT_DIR/test.cpp"

echo "Compiling test program from $TEST_CPP..."
g++ -o "$SCRIPT_DIR/test_statediff" "$TEST_CPP" \
    -I$GITHUB_WORKSPACE/external/state-diff/include \
    -L$GITHUB_WORKSPACE/build \
    -lstatediff

echo "Setting LD_LIBRARY_PATH..."
export LD_LIBRARY_PATH=$GITHUB_WORKSPACE/build:$LD_LIBRARY_PATH

echo "Running tests..."
"$SCRIPT_DIR/test_statediff"

echo "All tests passed!"