#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

if [ "$TRAVIS_OS_NAME" != "windows" ]; then
    printf "%s\n" "Running bazel tests..."
    bazel test //main/... //test/...

    printf "%s\n" "Running dfmt echo test..."
    DFMT_TEST_INPUT="${DFMT_TEST_INPUT:-../test-input.csv}" 
    DFMT_TEST_EXPECTED="${DFMT_TEST_EXPECTED:-../test-expected.csv}" 
    < "$DFMT_TEST_INPUT" bazel run -c opt //test/java/info/adams/ryu:dfmtecho -- > test.out
    diff "$DFMT_TEST_EXPECTED" test.out
    rm -f test.out
fi
