all:
	./build-all.sh

run-echo:
	@bazel run -c opt //ryu/tests:dfmt_echo --

test:
	@cat ../test-input.csv | bazel run -c opt //ryu/tests:dfmt_echo -- > test.out
	@diff ../test-expected.csv test.out
	@rm -f test.out

.PHONY: all
