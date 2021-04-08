#!/usr/bin/env bash
# shellcheck disable=SC2230

set -euo pipefail
IFS=$'\n\t'

BANNER=""
if [ -n "$(which banner)" ] && [ "$(uname -s)" != "Darwin" ]; then
    BANNER=banner
elif [ -n "$(which figlet)" ]; then
    BANNER=figlet
fi

DFMT_TEST_INPUT="$(pwd)/test-input.csv"
export DFMT_TEST_INPUT
DFMT_TEST_EXPECTED="$(pwd)/test-expected.csv"
export DFMT_TEST_EXPECTED

# run tests in each subdir
for subdir in ./*; do
  # support sparse checkouts by only testing what is present
  if [ -d "$subdir" ]; then
      lang="${subdir/\.\//}"

      printf "%s starting test of language %s\n" "$(date)" "$lang"
      if [ -n "$BANNER" ]; then
          "$BANNER" "Testing" "$lang"
      fi
      make -C "$subdir" test
      printf "%s finished test of language %s\n" "$(date)" "$lang"
  fi
done

if [ -n "$BANNER" ]; then
    "$BANNER" "Random" "Doubles" "Test - all" "Languages"
fi
# test output of each subdir against each other
./test-doubles.sh

set +u
if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    printf "Skip fuzzing on windows\n"
    exit 0
fi
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
    printf "Skip fuzzing on osx\n"
    exit 0
fi
./fuzz.sh
