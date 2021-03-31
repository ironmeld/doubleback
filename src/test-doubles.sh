#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

INPUT_FILE=input.csv
OUTPUT_FILE=output.csv
OUTPUT_FILE2=output2.csv
EXPECTED_FILE=expected.csv

rm -f "$INPUT_FILE"

printf "Generating 1 million random doubles...\n"
./gendoubles > "$INPUT_FILE"

rm -f "$EXPECTED_FILE"
for subdir in ./*; do
  # support sparse checkouts by only testing what is present
  if [ -d "$subdir" ]; then
    lang="${subdir/\.\//}"

    set +u   # allow undefined travis var
    if [ "$TRAVIS_OS_NAME" = "windows" ] && [ "$lang" = "java" ]; then
      printf "%s INFO: Skipping %s on windows\n" "$(date)" "$lang"
      continue
    fi
    set -u

    if [ ! -f "$EXPECTED_FILE" ]; then
        printf "%s Generating expected output using %s\n" "$(date)" "$lang"
        (cd "$subdir";./dfmt-echo.sh) < "$INPUT_FILE" > "$EXPECTED_FILE"

        printf "%s Verify round trip of expected output\n" "$(date)"
        (cd "$subdir";./dfmt-echo.sh) < "$EXPECTED_FILE" > "$OUTPUT_FILE2"
        echo diff "$EXPECTED_FILE" "$OUTPUT_FILE2"
        diff "$EXPECTED_FILE" "$OUTPUT_FILE2"
    else
        printf "%s Verifying that %s produces the same output...\n" "$(date)" "$lang"
        (cd "$subdir";./dfmt-echo.sh) < "$INPUT_FILE" > "$OUTPUT_FILE"
        echo diff "$EXPECTED_FILE" "$OUTPUT_FILE"
        diff "$EXPECTED_FILE" "$OUTPUT_FILE"
        
        printf "%s Verify round trip of expected output\n" "$(date)"
        (cd "$subdir";./dfmt-echo.sh) < "$OUTPUT_FILE" > "$OUTPUT_FILE2"
        echo diff "$OUTPUT_FILE" "$OUTPUT_FILE2"
        diff "$OUTPUT_FILE" "$OUTPUT_FILE2"
    fi
  fi
done
rm -f "$INPUT_FILE" "$OUTPUT_FILE" "$OUTPUT_FILE2" "$EXPECTED_FILE"
