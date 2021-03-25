#!/bin/bash
if [ "$TRAVIS_OS_NAME" != "windows" ] && [ "$TRAVIS_OS_NAME" != "osx" ]; then
    bazel build -c opt --jobs=1 //scripts:java-double-shortest-64bit-data.pdf
    bazel build -c opt --jobs=1 //scripts:java-double-shortest-bydigits-{time,length,parse}.{pdf,png}
fi
