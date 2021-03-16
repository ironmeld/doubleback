#!/bin/bash
bazel test //main/... //test/...
bazel run //main/java/info/adams/ryu/benchmark
if [ "$TRAVIS_OS_NAME" != "windows" -a $TRAVIS_OS_NAME != "osx" ]; then
    bazel build -c opt --jobs=1 //scripts:shortest-java-{float,double}.pdf
fi
