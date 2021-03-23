all:
	./build-all.sh

test:
	@cat ../test-input.csv | bazel run -c opt //ryu/tests:dfmt_echo -- > test.out
	@diff ../test-expected.csv test.out
	@rm -f test.out

# for manual testing
run-echo:
	@bazel run -c opt //ryu/tests:dfmt_echo --

# WARNING: deletes bazel cache which may affect other projects
clean:
	rm -rf bazel-*
	rm -rf ~/.cache/bazel

.PHONY: all
