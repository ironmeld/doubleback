all:
	./build-all.sh

DFMT_TEST_INPUT ?= ../test-input.csv
DFMT_TEST_EXPECTED ?= ../test-expected.csv

test:
	@cat $(DFMT_TEST_INPUT) | bazel run -c opt //ryu/tests:dfmt_echo -- > test.out
	@diff $(DFMT_TEST_EXPECTED) test.out
	@rm -f test.out

# for manual testing
run-echo:
	@bazel run -c opt //ryu/tests:dfmt_echo --

# WARNING: deletes bazel cache which may affect other projects
clean:
	rm -rf bazel-*
	rm -rf ~/.cache/bazel

.PHONY: all
