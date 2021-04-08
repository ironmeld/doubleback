all:
	./build.sh

test:
	./test.sh

benchmark:
	./benchmark.sh

# WARNING: deletes bazel cache which may affect other projects
clean:
	rm -rf bazel-*
	rm -rf ~/.cache/bazel
	rm -rf fuzz

install-deps:
	./install-deps.sh

.PHONY: all test benchmark clean install-deps
