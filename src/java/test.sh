#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

printf "%s\n" "Starting java tests"
bazel test //main/... //test/...

set +u # allow undefined vars
DFMT_TEST_INPUT="${DFMT_TEST_INPUT:-../test-input.csv}" 
DFMT_TEST_EXPECTED="${DFMT_TEST_EXPECTED:-../test-expected.csv}" 

printf "%s\n" "Checking for windows..."
if [ "$TRAVIS_OS_NAME" != "windows" ]; then
    printf "%s\n" "Running dfmt echo test..."
    set -u
    < "$DFMT_TEST_INPUT" bazel run -c opt //test/java/info/adams/ryu:dfmtecho -- > test.out
    diff "$DFMT_TEST_EXPECTED" test.out
    rm -f test.out
fi
printf "%s\n" "Exiting tests successfully"
exit 0
