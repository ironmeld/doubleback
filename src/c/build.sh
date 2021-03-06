#!/bin/bash
# shellcheck disable=SC2059,SC2230

# makes windows work with bazel's prefix for targets
export MSYS2_ARG_CONV_EXCL="//"

fmt="\nBuilding with %s\n"

if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    CCWARN=('--copt=-Wall')
else
    CCWARN=('--copt=-Wall' '--copt=-Wextra' '--copt=-Werror')
fi

set -e

printf "$fmt" "Uncompressed tables and 128-bit types allowed"
bazel build "${CCWARN[@]}" //doubleback/...

printf "$fmt" "64-bit only, 128-bit types not allowed"
bazel build "${CCWARN[@]}" --copt=-DRYU_ONLY_64_BIT_OPS //doubleback/...

printf "$fmt" "Compressed tables"
bazel build "${CCWARN[@]}" --copt=-DRYU_OPTIMIZE_SIZE //doubleback/...

printf "$fmt" "Compressed tables, 64-bit only, 128-bit types not allowed"
bazel build "${CCWARN[@]}" --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //doubleback/...

printf "$fmt" "64-bit only (no 128-bit) and optimize for 32-bit platform"
bazel build "${CCWARN[@]}" --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //doubleback/...

if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    printf "Skipping static analysis on windows.\n"
    exit 0
fi
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
    # note: if you want to enable osx, add llvm to the homebrew package list in .travis.yml
    # and add /usr/local/opt/llvm/bin to PATH.
    printf "Skipping static analysis on osx.\n"
    exit 0
fi

CC=gcc
CCOPTS=('-Wall' '-Wextra' '-Werror' '-std=c99')
CHECK="scan-build"

if [ -n "$(which $CHECK)" ]; then
    "$CHECK" "$CC" "${CCOPTS[@]}" -I . -c doubleback/dfmt.c -o dfmt.o
    "$CHECK" "$CC" "${CCOPTS[@]}" -I . -c doubleback/dparse.c -o dparse.o
    rm dfmt.o dparse.o
else
    printf "Skipping static analysis, %s not installed.\n" "$CHECK"
fi
printf "Finished build.\n"
