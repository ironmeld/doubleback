#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

bazel test //main/... //test/...

set +u # allow undefined vars
DFMT_TEST_INPUT="${DFMT_TEST_INPUT:-../test-input.csv}" 
DFMT_TEST_EXPECTED="${DFMT_TEST_EXPECTED:-../test-expected.csv}" 

if [ "$TRAVIS_OS_NAME" != "windows" ]; then
    set -u
    < "$DFMT_TEST_INPUT" bazel run -c opt //test/java/info/adams/ryu:dfmtecho -- > test.out
    diff "$DFMT_TEST_EXPECTED" test.out
    rm -f test.out
fi
