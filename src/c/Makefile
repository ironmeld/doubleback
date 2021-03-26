all:
	./build.sh

test:
	./test.sh

benchmark:
	./benchmark.sh

# this parses doubles, one per line, and prints them using dfmt
run-echo:
	@bazel run -c opt //tests:dfmt_echo --

# WARNING: deletes bazel cache which may affect other projects
clean:
	rm -rf bazel-*
	rm -rf ~/.cache/bazel

.PHONY: all test benchmark run-echo clean
