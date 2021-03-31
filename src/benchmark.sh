#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

for subdir in ./*; do
  # support sparse checkouts by only building what is present
  if [ -d "$subdir" ]; then
      if [ -n "$(which banner)" ]; then
          banner "Benchmark" "${subdir/\.\//}"
      fi
      make -C "$subdir" benchmark
  fi
done
