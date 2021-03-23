#!/bin/bash

# Uncompressed tables and 128-bit types allowed
bazel test //ryu/...
if [ "$TRAVIS_OS_NAME" = "osx" ]; then bazel test --run_under="leaks --atExit -- " //ryu/...; fi
bazel run -c opt //ryu/benchmark:ryu_benchmark_shortest -- -samples=250
bazel run -c opt //ryu/benchmark:ryu_benchmark_shortest -- -data -samples=250

# 64-bit only, 128-bit types not allowed
bazel test --copt=-DRYU_ONLY_64_BIT_OPS //ryu/...
bazel run -c opt --copt=-DRYU_ONLY_64_BIT_OPS //ryu/benchmark:ryu_benchmark_shortest -- -data -samples=100

# Compressed tables
bazel test --copt=-DRYU_OPTIMIZE_SIZE //ryu/...
bazel run -c opt --copt=-DRYU_OPTIMIZE_SIZE //ryu/benchmark:ryu_benchmark_shortest -- -data -samples=100

# Compressed tables, 64-bit only, 128-bit types not allowed
bazel test --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //ryu/...
bazel run -c opt --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //ryu/benchmark:ryu_benchmark_shortest -data -samples=100

# 64-bit only (no 128-bit) and optimize for 32-bit platform
bazel test --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //ryu/...
bazel run -c opt --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //ryu/benchmark:ryu_benchmark_shortest -data -samples=100

# osx works but installing gnuplot takes a very long time
if [ "$TRAVIS_OS_NAME" != "windows" -a "$TRAVIS_OS_NAME" != "osx" ]; then
    bazel build -c opt --jobs=1 //scripts:c-double-shortest-64bit-data.pdf
    bazel build -c opt --jobs=1 //scripts:c-double-shortest-bydigits-{time,length,parse}.{pdf,png}
fi
