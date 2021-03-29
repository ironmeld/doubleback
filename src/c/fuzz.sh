#!/bin/bash
# shellcheck disable=SC2129

export CC=afl-clang-fast
WORKERS=40

rm -rf fuzz
mkdir fuzz && cd fuzz || exit 1
"$CC" -I .. -c ../doubleback/dfmt.c -o dfmt.o
"$CC" -I .. -c ../doubleback/dparse.c -o dparse.o
"$CC" -I .. dfmt.o dparse.o ../tests/dfmt_echo.c -o dfmt_echo

mkdir fuzz_in
for i in $(seq "$(wc -l ../../test-input.csv | cut -f1 -d' ')"); do
   # take line # i from the input file and create a separate input file
   sed "${i}q;d"  < ../../test-input.csv > fuzz_in/"$i"
done

rm -f vocab
for i in $(seq 0 9); do
    printf "\"%s\"\n" "$i" >> vocab
done
printf "\"%s\"\n" "+" >> vocab
printf "\"%s\"\n" "-" >> vocab
printf "\"%s\"\n" "324" >> vocab
printf "\"%s\"\n" "325" >> vocab
printf "\"%s\"\n" "." >> vocab
printf "\"%s\"\n" "e" >> vocab
printf "\"%s\"\n" "E" >> vocab
printf "\"%s\"\n" "000" >> vocab
printf "\"%s\"\n" "000000" >> vocab
printf "\"%s\"\n" "99999999999999999" >> vocab

mkdir fuzz_out

tmux new -d -s fuzz-master
tmux send-keys -t fuzz-master.0 afl-fuzz SPACE -i SPACE fuzz_in SPACE -x SPACE vocab SPACE -o SPACE fuzz_out SPACE -M SPACE master SPACE -- SPACE ./dfmt_echo ENTER

printf "%s\n" "Fuzzing is being started. Please wait for a few seconds..."
for worker in $(seq "$WORKERS"); do
    tmux new -d -s fuzz-worker-"$worker"
    tmux send-keys -t fuzz-worker-"$worker".0 afl-fuzz SPACE -i SPACE fuzz_in SPACE -x SPACE vocab SPACE -o SPACE fuzz_out SPACE -M SPACE worker"$worker" SPACE -- SPACE ./dfmt_echo ENTER
done

date
printf "%s\n" "To see progress, attached to tmux window \"fuzz-master\"."
printf "%s" "Press return to end fuzzing: "
read -r _

printf "%s\n" "Fuzzing is being terminated. Please wait for a few seconds..."
for worker in $(seq "$WORKERS"); do
    tmux kill-window -t fuzz-worker-"$worker"
done
tmux kill-window -t fuzz-master
cd ..
