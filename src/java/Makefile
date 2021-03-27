all:
	./build.sh

test:
	./test.sh

# This parses doubles, one per line, and prints them using dfmt.
run-echo:
	@bazel run -c opt //testsrc/com/ironmeld/doubleback:dfmtecho -- 2> /dev/null

benchmark:
	./benchmark.sh

# WARNING: deletes bazel cache which may affect other projects
clean:
	rm -rf bazel-*
	rm -rf ~/.cache/bazel

.PHONY: all test run-echo benchmark clean
