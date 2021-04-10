all:
	make -C src

test:
	make -C src test

benchmark:
	make -C src benchmark

fuzztest:
	make -C src fuzztest

clean:
	make -C src clean

install-deps:
	make -C src install-deps

.PHONY: all test benchmark fuzztest clean install-deps
