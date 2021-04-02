#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

if [ -n "$(which banner)" ] && [ "$(uname -s)" != "Darwin" ]; then
    BANNER=banner
elif [ -n "$(which figlet)" ]; then
    BANNER=figlet
fi

for subdir in ./*; do
  # support sparse checkouts by only testing what is present
  if [ -d "$subdir" ]; then
      # strip leading ./
      lang="${subdir/\.\//}"

      # if the implementation has a fuzz script then run it
      if [ -f "$subdir/fuzz.sh" ]; then
          printf "%s starting fuzz test for language %s\n" "$(date)" "$lang"
          if [ -n "$BANNER" ]; then
              "$BANNER" "Fuzzing" "${subdir/\.\//}"
          fi
          (cd "$subdir";./fuzz.sh)
          printf "%s finished fuzz test for language %s\n" "$(date)" "$lang"
      fi

      # if the c implementation is present, fuzz this implementation against it
      if [ "$lang" != "c" ] && [ -d "c" ]; then
          printf "%s starting differential fuzz test for language %s\n" "$(date)" "$lang"
          if [ -n "$(which banner)" ]; then
              banner "Fuzzing" "C versus" "$lang"
          fi
          (cd c; ./fuzz.sh "$lang")
          printf "%s finished differential fuzz test for language %s\n" "$(date)" "$lang"
      fi
  fi
done
