#!/bin/bash

export CC=afl-clang-fast

rm -rf fuzz
mkdir fuzz && cd fuzz || exit 1
"$CC" -I .. -c ../doubleback/dfmt.c -o dfmt.o
"$CC" -I .. -c ../doubleback/dparse.c -o dparse.o
"$CC" -I .. dfmt.o dparse.o ../tests/dfmt_echo.c -o dfmt_echo

mkdir fuzz_in
for i in $(seq "$(wc -l ../../test-input.csv | cut -f1 -d' ')"); do
   echo "$i"
   sed "${i}q;d"  < ../../test-input.csv > fuzz_in/"$i"
done
mkdir fuzz_out

tmux new -d -s fuzz-master
tmux send-keys -t fuzz-master.0 afl-fuzz SPACE -i SPACE fuzz_in SPACE -o SPACE fuzz_out SPACE -M SPACE master SPACE -- SPACE ./dfmt_echo ENTER

for worker in $(seq 40); do
    tmux new -d -s fuzz-worker-"$worker"
    tmux send-keys -t fuzz-worker-"$worker".0 afl-fuzz SPACE -i SPACE fuzz_in SPACE -o SPACE fuzz_out SPACE -M SPACE worker"$worker" SPACE -- SPACE ./dfmt_echo ENTER
done

printf "%s\n" "To see progress, attached to tmux window \"fuzz-master\"."
date
printf "%s\n" "Fuzzing for 1 hour..."
sleep 3600

for worker in $(seq 40); do
    tmux kill-window -t fuzz-worker-"$worker"
done
tmux kill-window -t fuzz-master
cd ..
ls fuzz/fuzz_out/worker*/hangs
ls fuzz/fuzz_out/worker*/crashes
