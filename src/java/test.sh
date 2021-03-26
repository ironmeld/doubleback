#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    printf "%s\n" "Skipping java on windows!"
	exit 0
fi

printf "%s\n" "Running bazel tests..."
bazel test //src/... //testsrc/...

printf "%s\n" "Running dfmt echo test..."
DFMT_TEST_INPUT="${DFMT_TEST_INPUT:-../test-input.csv}" 
DFMT_TEST_EXPECTED="${DFMT_TEST_EXPECTED:-../test-expected.csv}" 
< "$DFMT_TEST_INPUT" bazel run -c opt //testsrc/com/ironmeld/doubleback:dfmtecho -- > test.out
diff "$DFMT_TEST_EXPECTED" test.out
rm -f test.out
