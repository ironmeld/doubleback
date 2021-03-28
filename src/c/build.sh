#!/bin/bash
# shellcheck disable=SC2059

# makes windows work with bazel's prefix for targets
export MSYS2_ARG_CONV_EXCL="//"

fmt="\nBuilding with %s\n"

printf "$fmt" "Uncompressed tables and 128-bit types allowed"
bazel build //doubleback/...

printf "$fmt" "64-bit only, 128-bit types not allowed"
bazel build --copt=-DRYU_ONLY_64_BIT_OPS //doubleback/...

printf "$fmt" "Compressed tables"
bazel build --copt=-DRYU_OPTIMIZE_SIZE //doubleback/...

printf "$fmt" "Compressed tables, 64-bit only, 128-bit types not allowed"
bazel build --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //doubleback/...

printf "$fmt" "64-bit only (no 128-bit) and optimize for 32-bit platform"
bazel build --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //doubleback/...
