all:
	./build.sh

gendoubles: gendoubles.c
	gcc gendoubles.c -o gendoubles

test: gendoubles
	./test.sh

benchmark:
	./benchmark.sh

clean:
	rm -f gendoubles
	./clean.sh

.PHONY: all test benchmark clean
