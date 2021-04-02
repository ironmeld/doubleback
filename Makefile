all:
	make -C src

test:
	make -C src test

benchmark:
	make -C src benchmark

clean:
	make -C src clean

install-deps:
	make -C src install-deps

.PHONY: all test benchmark clean install-deps
