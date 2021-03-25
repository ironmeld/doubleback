#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

INPUT_FILE=input.csv
OUTPUT_FILE=output.csv
EXPECTED_FILE=expected.csv

rm -f "$INPUT_FILE"

printf "Generating 1 million random doubles...\n"
./gendoubles > "$INPUT_FILE"

rm -f "$EXPECTED_FILE"
for subdir in ./*; do
  # support sparse checkouts by only testing what is present
  if [ -d "$subdir" ]; then
    set +u   # allow undefined travis var
    if [ "$TRAVIS_OS_NAME" = "windows" ] && [ "$subdir" = "./java" ]; then
      printf "%s\n" "INFO: Skipping java on windows"
      continue
    fi
    set -u

    if [ ! -f "$EXPECTED_FILE" ]; then
        printf "Generating expected output using %s\n" "$subdir"
        < "$INPUT_FILE" make -C "$subdir" run-echo | grep -v "directory" > "$EXPECTED_FILE" 2> /dev/null
    else
        printf "Verifying that %s produces the same output...\n" "$subdir"
        < "$INPUT_FILE" make -C "$subdir" run-echo | grep -v "directory" > "$OUTPUT_FILE" 2> /dev/null
        diff "$EXPECTED_FILE" "$OUTPUT_FILE"
    fi
  fi
done
rm -f "$INPUT_FILE" "$OUTPUT_FILE" "$EXPECTED_FILE"
