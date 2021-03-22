#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

for subdir in ./*; do
  # support sparse checkouts by only building what is present
  if [ -d "$subdir" ]; then
    make -C "$subdir" test
  fi
done
