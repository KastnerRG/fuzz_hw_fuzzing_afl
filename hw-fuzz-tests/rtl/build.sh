#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
prefix=${HWFUZZ_PREFIX:-/opt/hw_fuzzing_afl}
afl=$(cd ../.. && pwd)
export PATH="$prefix/llvm/bin:$PATH"
export HWFUZZ_COVERAGE=Taint
unset HWFUZZ_NO_DFSAN
cppflags="-fsanitize=memory -fno-pie -nostdinc++ -isystem $prefix/libcxx/include/c++/v1"
ldflags="-fsanitize=memory -no-pie -nostdlib++ -L$prefix/libcxx/lib -Wl,-rpath,$prefix/libcxx/lib -lc++ -lc++abi -fuse-ld=lld"
${VERILATOR:-/opt/verilator/bin/verilator} --cc --exe --build -j "${BUILD_JOBS:-8}" \
    --top-module taint_chain --Mdir build -Wno-fatal \
    -CFLAGS "$cppflags" -LDFLAGS "$ldflags" \
    -MAKEFLAGS "CXX=$afl/afl-clang-fast++ LINK=$afl/afl-clang-fast++" \
    taint_chain.sv "$PWD/main.cpp" -o taint-chain
