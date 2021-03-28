#!/bin/bash
bazel run -c opt //tests:dfmt_echo -- 2> /dev/null
