#!/bin/bash
set -eu  # stop on error, undefined vars

CC=gcc

"$CC" -O3 -Wall -Wextra -Werror -I .. -c ../doubleback/dfmt.c
"$CC" -O3 -Wall -Wextra -Werror -I .. -c ../doubleback/dparse.c
"$CC" -O3 -Wall -Wextra -Werror -I .. -o example dfmt.o dparse.o example.c 
