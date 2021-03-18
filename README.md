# Doubleback

Doubleback provides round-trip parsing and printing of 64-bit double-precision floating-point numbers using the Ryu algorithm implemented in multiple programming languages. Doubleback is biased towards "human-friendly" output which round-trips consistently between binary and decimal.

The Doubleback project unifies code forked from various github projects. See Acknowledgements.

# Status

Doubleback is in development and is not ready for use or contributions.

# Roadmap for first release

* Makefile test target
* Setup github actions
* Standard interfaces

# Getting Started

There are a number of dependencies for building Doubleback. See the [build document](docs/Build.md).

```
$ git clone https://github.com/ironmeld/doubleback
$ cd doubleback
$ make
```

# Acknowledgements

Doubleback is derived from upstream projects.

| Language | Upstream Project |
|----------|------------------|
| C        | https://github.com/ulfjack/ryu |
| Java     | https://github.com/ulfjack/ryu |


# Charts that show Ryu is Fast with Short Output

![Ryu ranges from 10 to 20 times faster than standard printf](results/shortest-native-c-double-time.png "Time to Output")

![Ryu output is 30% to 96% out the output length](results/shortest-native-c-double-length.png "Output Length")

