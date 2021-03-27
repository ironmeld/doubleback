#!/bin/bash

set -e

DFMT_TEST_INPUT="${DFMT_TEST_INPUT:-../test-input.csv}"
DFMT_TEST_EXPECTED="${DFMT_TEST_EXPECTED:-../test-expected.csv}"

< "$DFMT_TEST_INPUT" bazel run -c opt //tests:dfmt_echo -- > test.out
pwd
echo diff "$DFMT_TEST_EXPECTED" test.out
diff "$DFMT_TEST_EXPECTED" test.out
rm -f test.out

printf "\nTesting with %s\n" "$(date) Uncompressed tables and 128-bit types allowed"
bazel test //tests/...
if [ "$TRAVIS_OS_NAME" = "osx" ]; then bazel test --run_under="leaks --atExit -- " //tests/...; fi

printf "\nTesting with %s\n" "$(date) 64-bit only, 128-bit types not allowed"
bazel test --copt=-DRYU_ONLY_64_BIT_OPS //tests/...

printf "\nTesting with %s\n" "$(date) Compressed tables"
bazel test --copt=-DRYU_OPTIMIZE_SIZE //tests/...

printf "\nTesting with %s\n" "$(date) Compressed tables, 64-bit only, 128-bit types not allowed"
bazel test --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //tests/...

printf "\nTesting with %s\n" "$(date) 64-bit only (no 128-bit) and optimize for 32-bit platform"
bazel test --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //tests/...
