#!/bin/bash
set -eu  # stop on error, undefined vars

CC=gcc

if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    CCWARN=('-Wall -Werror')
else
    CCWARN=('-Wall -Wextra -Werror')
fi

"$CC" -O3 "${CCWARN[@]}" -I .. -c ../doubleback/dfmt.c
"$CC" -O3 "${CCWARN[@]}" -I .. -c ../doubleback/dparse.c
"$CC" -O3 "${CCWARN[@]}" -I .. -o example dfmt.o dparse.o example.c 
