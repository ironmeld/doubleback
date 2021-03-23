all:
	./build-all.sh

test:
	@if [ "$$TRAVIS_OS_NAME" != "windows" ]; then \
		cat ../test-input.csv | bazel run -c opt //test/java/info/adams/ryu:dfmtecho -- > test.out; \
		diff ../test-expected.csv test.out; \
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
