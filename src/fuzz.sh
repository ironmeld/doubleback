#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

for subdir in ./*; do
  # support sparse checkouts by only testing what is present
  if [ -d "$subdir" ]; then
      # strip leading ./
      subdir=$(echo "$subdir" | sed 's/^.\///')

      # if the implementation has a fuzz script then run it
      if [ -f "$subdir/fuzz.sh" ]; then
          if [ -n "$(which banner)" ]; then
              banner "Fuzzing" "${subdir/\.\//}"
          fi
          (cd "$subdir";./fuzz.sh)
      fi

      # if the c implementation is present, fuzz this implementation against it
      if [ "$subdir" != "c" ] && [ -d "c" ]; then
          if [ -n "$(which banner)" ]; then
              banner "Fuzzing" "C versus" "${subdir/\.\//}"
          fi
          (cd c; ./fuzz.sh "$subdir")
      fi
  fi
done
