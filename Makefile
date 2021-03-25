all:
	make -C src

test:
	make -C src test

benchmark:
	make -C src benchmark

clean:
	make -C src clean

.PHONY: all test benchmark clean
