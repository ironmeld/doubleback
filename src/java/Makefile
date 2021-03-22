all:
	./build-all.sh

run-echo:
	@bazel run -c opt //test/java/info/adams/ryu:dfmtecho --

test:
	@cat ../test-input.csv | bazel run -c opt //test/java/info/adams/ryu:dfmtecho -- > test.out
	@diff ../test-expected.csv test.out
	@rm -f test.out

.PHONY: all test
