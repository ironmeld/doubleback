#!/bin/bash
bazel test //main/... //test/...
bazel run //main/java/info/adams/ryu/benchmark
#bazel build -c opt --jobs=1 //scripts:shortest-java-{float,double}.pdf
