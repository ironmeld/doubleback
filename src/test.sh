#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DFMT_TEST_INPUT="$(pwd)/test-input.csv"
export DFMT_TEST_INPUT
DFMT_TEST_EXPECTED="$(pwd)/test-expected.csv"
export DFMT_TEST_EXPECTED

# run tests in each subdir
for subdir in ./*; do
  # support sparse checkouts by only testing what is present
  if [ -d "$subdir" ]; then
      make -C "$subdir" test
  fi
done

# test output of each subdir against each other
./test-doubles.sh

