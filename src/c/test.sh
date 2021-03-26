#!/bin/bash

< "$DFMT_TEST_INPUT" bazel run -c opt //tests:dfmt_echo -- > test.out
diff "$DFMT_TEST_EXPECTED" test.out
rm -f test.out

printf "\nTesting with %s\n" "Uncompressed tables and 128-bit types allowed"
bazel test //tests/...
if [ "$TRAVIS_OS_NAME" = "osx" ]; then bazel test --run_under="leaks --atExit -- " //tests/...; fi

printf "\nTesting with %s\n" "64-bit only, 128-bit types not allowed"
bazel test --copt=-DRYU_ONLY_64_BIT_OPS //tests/...

printf "\nTesting with %s\n" "Compressed tables"
bazel test --copt=-DRYU_OPTIMIZE_SIZE //tests/...

printf "\nTesting with %s\n" "Compressed tables, 64-bit only, 128-bit types not allowed"
bazel test --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //tests/...

printf "\nTesting with %s\n" "64-bit only (no 128-bit) and optimize for 32-bit platform"
bazel test --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //tests/...
