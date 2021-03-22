all:
	make -C src

test:
	make -C src test

.PHONY: all test
