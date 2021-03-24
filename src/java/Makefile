all:
	./build-all.sh

DFMT_TEST_INPUT ?= ../test-input.csv
DFMT_TEST_EXPECTED ?= ../test-expected.csv

test:
	@if [ "$$TRAVIS_OS_NAME" != "windows" ]; then \
		cat $(DFMT_TEST_INPUT) | bazel run -c opt //test/java/info/adams/ryu:dfmtecho -- > test.out; \
		diff $(DFMT_TEST_EXPECTED) test.out; \
		rm -f test.out; \
	fi

# for manual testing
run-echo:
	@bazel run -c opt //test/java/info/adams/ryu:dfmtecho --

# WARNING: deletes bazel cache which may affect other projects
clean:
	rm -rf bazel-*
	rm -rf ~/.cache/bazel

.PHONY: all test
