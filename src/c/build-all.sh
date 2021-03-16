#!/bin/bash
bazel test //ryu/...
if [ "$TRAVIS_OS_NAME" = "osx" ]; then bazel test --run_under="leaks --atExit -- " //ryu/...; fi
bazel run -c opt //ryu/benchmark:ryu_benchmark --
bazel run -c opt //ryu/benchmark:ryu_printf_benchmark -- -samples=200
bazel test --copt=-DRYU_ONLY_64_BIT_OPS //ryu/...
bazel run -c opt --copt=-DRYU_ONLY_64_BIT_OPS //ryu/benchmark:ryu_benchmark --
bazel run -c opt --copt=-DRYU_ONLY_64_BIT_OPS //ryu/benchmark:ryu_printf_benchmark -- -samples=200

bazel test --copt=-DRYU_OPTIMIZE_SIZE //ryu/...
bazel run -c opt --copt=-DRYU_OPTIMIZE_SIZE //ryu/benchmark:ryu_benchmark --
bazel run -c opt --copt=-DRYU_OPTIMIZE_SIZE //ryu/benchmark:ryu_printf_benchmark -- -samples=200
bazel test --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //ryu/...
bazel run -c opt --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //ryu/benchmark:ryu_benchmark
bazel run -c opt --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //ryu/benchmark:ryu_printf_benchmark -- -samples=200

bazel test -c opt --copt=-DRYU_FLOAT_FULL_TABLE //ryu/...
bazel test -c opt --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //ryu/...

# osx works but installing gnuplot takes a very long time
if [ "$TRAVIS_OS_NAME" != "windows" -a "$TRAVIS_OS_NAME" != "osx" ]; then
    bazel build -c opt --jobs=1 //scripts:shortest-c-{float,double}.pdf
    bazel build -c opt --jobs=1 //scripts:{f,e}-c-double-{1,10,100,1000}.pdf
fi
