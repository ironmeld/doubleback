#!/bin/bash

# shellcheck disable=SC2059
fmt="Building with %s\n"

printf "$fmt" "Uncompressed tables and 128-bit types allowed"
bazel build //ryu/...

printf "$fmt" "64-bit only, 128-bit types not allowed"
bazel build --copt=-DRYU_ONLY_64_BIT_OPS //ryu/...

printf "$fmt" "Compressed tables"
bazel build --copt=-DRYU_OPTIMIZE_SIZE //ryu/...

printf "$fmt" "Compressed tables, 64-bit only, 128-bit types not allowed"
bazel build --copt=-DRYU_OPTIMIZE_SIZE --copt=-DRYU_ONLY_64_BIT_OPS //ryu/...

printf "$fmt" "64-bit only (no 128-bit) and optimize for 32-bit platform"
bazel build --copt=-DRYU_ONLY_64_BIT_OPS --copt=-DRYU_32_BIT_PLATFORM //ryu/...
