#!/bin/bash
set -e

# makes windows work with bazel's prefix for targets
export MSYS2_ARG_CONV_EXCL="//"

bazel run -c opt //testsrc/com/ironmeld/doubleback/benchmark -- -bydigits -samples=25
bazel run -c opt //testsrc/com/ironmeld/doubleback/benchmark -- -samples=25

bazel build -c opt --jobs=1 //scripts:java-double-shortest-bydigits-summary.csv
bazel build -c opt --jobs=1 //scripts:java-double-shortest-64bit-data.csv

# cannot run gnuplot on windows on travis due to missing prntvpt.dll.
if [ "$TRAVIS_OS_NAME" = "windows" ]; then
  printf "Skipping java charts on windows. Cannot run gnuplot on windows on travis due to missing prntvpt.dll.\n"
  exit 0
fi
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
  # note: if you want to enable osx, add gnuplot to the homebrew package list in .travis.yml
  printf "Skipping java charts on osx to save time.\n"
  exit 0
fi

bazel build -c opt --jobs=1 //scripts:java-double-shortest-64bit-data.pdf
bazel build -c opt --jobs=1 //scripts:java-double-shortest-bydigits-{time,length,parse}.{pdf,png}
