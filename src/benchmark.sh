#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

if [ -n "$(which banner)" ]; then
    BANNER=banner
elif [ -n "$(which figlet)" ]; then
    BANNER=figlet
elif [ -n "$(which figlet-go)" ]; then
    BANNER=figlet-go
fi
printf "BANNER is %s\n" "$BANNER"

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
