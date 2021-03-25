#!/bin/bash

# shellcheck disable=SC2059
fmt="\nBENCHMARKING with %s\n"

printf "$fmt" "Uncompressed tables and 128-bit types allowed"
bazel run -c opt //ryu/benchmark:ryu_benchmark_shortest -- -samples=250
bazel run -c opt //ryu/benchmark:ryu_benchmark_shortest -- -data -samples=250

printf "$fmt" "64-bit only, 128-bit types not allowed"
bazel run -c opt --copt=-DRYU_ONLY_64_BIT_OPS //ryu/benchmark:ryu_benchmark_shortest -- -data -samples=100

printf "$fmt" "Compressed tables"
bazel run -c opt --copt=-DRYU_OPTIMIZE_SIZE //ryu/benchmark:ryu_benchmark_shortest -- -data -samples=100

printf "$fmt" "Compressed tables, 64-bit only, 128-bit types not allowed"
bazel run -c opt --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //ryu/benchmark:ryu_benchmark_shortest -- -data -samples=100

printf "$fmt" "64-bit only (no 128-bit) and optimize for 32-bit platform"
bazel run -c opt --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //ryu/benchmark:ryu_benchmark_shortest -- -data -samples=100

# osx works but installing gnuplot takes a very long time
if [ "$TRAVIS_OS_NAME" != "windows" ] && [ "$TRAVIS_OS_NAME" != "osx" ]; then
    bazel build -c opt --jobs=1 //scripts:c-double-shortest-64bit-data.pdf
    bazel build -c opt --jobs=1 //scripts:c-double-shortest-bydigits-{time,length,parse}.{pdf,png}
fi
