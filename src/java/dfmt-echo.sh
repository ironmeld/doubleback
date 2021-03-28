#!/bin/bash
bazel run -c opt //testsrc/com/ironmeld/doubleback:dfmtecho -- 2> /dev/null
