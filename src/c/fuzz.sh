#!/bin/bash
# shellcheck disable=SC2129
set -e

export CC=afl-clang-fast
FUZZPROG=dfmt_fuzz
WORKERS=48
FUZZ_TIME=10
FUZZ_MEM_MB=50

if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    WORKERS=0
fi

# end of config

ALT_LANG="$1"
FUZZARGS=()
if [ -n "$ALT_LANG" ]; then
    FUZZARGS=("SPACE" "$ALT_LANG")
    if [ ! -d "../$ALT_LANG" ]; then
        printf "Directory %s does not exist!\n" "../$ALT_LANG"
        exit 1
    fi
else
    FUZZARGS=()
fi

if [ "$ALT_LANG" = "java" ]; then
    FUZZ_MEM_MB=48000 # needed due to jvm allocation bug
fi

# afl requires this
if [ ! grep core < /proc/sys/kernel/core_pattern ]; then
    echo core | sudo tee /proc/sys/kernel/core_pattern
fi

# create a workspace directory
rm -rf fuzz
mkdir fuzz && cd fuzz || exit 1

# Compile the fuzzer test proghram with afl
"$CC" -Wall -I .. -c ../doubleback/dfmt.c -o dfmt.o
"$CC" -Wall -I .. -c ../doubleback/dparse.c -o dparse.o
"$CC" -Wall -I .. dfmt.o dparse.o "../tests/${FUZZPROG}.c" -o "${FUZZPROG}"

# Create fuzzer seed inputs
mkdir fuzz_in
for i in $(seq "$(wc -l ../../test-input.csv | cut -f1 -d' ')"); do
   # take line # i from the input file and create a separate input file
   sed "${i}q;d"  < ../../test-input.csv > fuzz_in/"$i"
done

# Create fuzzer vocabulary
rm -f vocab
for i in $(seq 0 9); do
    printf "\"%s\"\n" "$i" >> vocab
done
printf "\"%s\"\n" "+" >> vocab
printf "\"%s\"\n" "-" >> vocab
printf "\"%s\"\n" "324" >> vocab
printf "\"%s\"\n" "325" >> vocab
printf "\"%s\"\n" "." >> vocab
printf "\"%s\"\n" "Infinity" >> vocab
printf "\"%s\"\n" "NaN" >> vocab
printf "\"%s\"\n" "e" >> vocab
printf "\"%s\"\n" "E" >> vocab
printf "\"%s\"\n" "0.0" >> vocab
printf "\"%s\"\n" "000" >> vocab
printf "\"%s\"\n" "000000" >> vocab
printf "\"%s\"\n" "99999999999999999" >> vocab
printf "\"%s\"\n" "x" >> vocab # invalid char


printf "\n%s Starting fuzzer(s)...\n" "$(date)"
mkdir fuzz_out
tmux new -d -s fuzz-master
tmux send-keys -t fuzz-master.0 afl-fuzz SPACE -i SPACE fuzz_in SPACE -x SPACE vocab SPACE -o SPACE fuzz_out SPACE -M SPACE master SPACE -m SPACE "$FUZZ_MEM_MB" SPACE -t SPACE 8000 SPACE -- SPACE ./${FUZZPROG} "${FUZZARGS[@]}" ENTER

for worker in $(seq "$WORKERS"); do
    tmux new -d -s fuzz-worker-"$worker"
    tmux send-keys -t fuzz-worker-"$worker".0 afl-fuzz SPACE -i SPACE fuzz_in SPACE -x SPACE vocab SPACE -o SPACE fuzz_out SPACE -M SPACE worker"$worker" SPACE -m SPACE "$FUZZ_MEM_MB" SPACE -t SPACE 8000 -- SPACE ./${FUZZPROG} "${FUZZARGS[@]}" ENTER
done

printf "%s Fuzzers started.\n" "$(date)"
printf "To see progress, attached to tmux window \"fuzz-master\" or use afl-whatsup.\n"
printf "Fuzzing for %d seconds. Press return to end early: " "$FUZZ_TIME"
set +e
read -t "$FUZZ_TIME" -r _
set -e

afl-whatsup -s fuzz_out
printf "Fuzzers are being terminated. Please wait ...\n"
tmux kill-window -t fuzz-master
for worker in $(seq "$WORKERS"); do
    tmux kill-window -t fuzz-worker-"$worker"
done
cd ..

crashcount="$(find fuzz/fuzz_out/master/crashes -name "id*" 2> /dev/null | wc -l)"

if [ "$crashcount" = "0" ]; then
    printf "There are no crashes!\n"
    exit 0
fi

printf "There are %d crashes\n" "$crashcount"

# The fuzzer test program produces a crash when a difference
# is detected between implementations.
# This loop goes through each crash a displays the difference in behavior.
for crash_file in ./fuzz/fuzz_out/master/crashes/id*
do
    printf "\nCrash File: %s\n" "$crash_file"
    printf "Input:\n"
    cat "$crash_file"

    # What did c do?
    printf "\nThis is the output from %s:\n" "c"
    ./dfmt-echo.sh < "$crash_file"

    # What did $ALT_LANG do?
    printf "\nThis is the output from %s:\n" "$ALT_LANG"
    (cd "../$ALT_LANG";./dfmt-echo.sh ) < "$crash_file"
done

exit 1
