#!/bin/bash

# makes windows work with bazel's prefix for targets
export MSYS2_ARG_CONV_EXCL="//"

bazel build //src/...
