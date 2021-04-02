all:
	./build.sh

gendoubles: gendoubles.c
	gcc -std=c99 gendoubles.c -o gendoubles

test: gendoubles
	./test.sh

benchmark:
	./benchmark.sh

clean:
	rm -f gendoubles
	./clean.sh

install-deps:
	./install-deps.sh

.PHONY: all test benchmark clean install-deps
