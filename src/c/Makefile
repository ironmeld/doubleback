all:
	./build-all.sh

test:
	@cat ../test-input.csv | bazel run -c opt //ryu/tests:dfmt_echo -- > test.out
	@diff ../test-expected.csv test.out
	@rm -f test.out

# for manual testing
run-echo:
	@bazel run -c opt //ryu/tests:dfmt_echo --

.PHONY: all
