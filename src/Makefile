all:
	./build-subdirs.sh all


gendoubles: gendoubles.c
	gcc gendoubles.c -o gendoubles

test: gendoubles
	# run tests in each subdir
	./build-subdirs.sh test
	# test output of each subdir against each other
	./test-doubles.sh

clean:
	rm -f gendoubles
	./build-subdirs.sh clean

.PHONY: all test clean
