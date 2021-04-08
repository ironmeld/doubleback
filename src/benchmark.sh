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

for subdir in ./*; do
  # support sparse checkouts by only building what is present
  if [ -d "$subdir" ]; then
      lang="${subdir/\.\//}"
      printf "%s starting benchmark for language %s\n" "$(date)" "$lang"
      if [ -n "$BANNER" ]; then
          "$BANNER" "Benchmark" "$lang"
      fi
      make -C "$subdir" benchmark
      printf "%s finished benchmark for language %s\n" "$(date)" "$lang"
  fi
done
