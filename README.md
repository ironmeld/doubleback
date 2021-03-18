# Doubleback

Doubleback provides round-trip parsing and printing of 64-bit double-precision floating-point numbers using the Ryu algorithm implemented in multiple programming languages. Doubleback is biased towards "human-friendly" output which round-trips consistently between binary and decimal.

The Doubleback project unifies code forked from various github projects. See Acknowledgements.

glibc:
```
printf("%.17g", 0.3);
0.29999999999999999
```

Ryu shortest:
```
char buf[32];
d2s_buffered(0.3, buf);
printf("%s", buf);
3E-1
```

Doubleback dfmt - `Ryu shortest` reformatted to be like `printf("%.17g")`:
```
char buf[32];
printf("%s", dfmt(0.3, buf));
0.3
```

Ryu is an algorithm along with reference code developed by Ulf Adams, Google Germany in 2018 [1][2]. Ryu supports consistent round-trip parsing and "shortest" printing of 64-bit floating-point numbers. To be clear, Ryu is the breakthrough technology that makes Doubleback possible.

There are many older and established algorithms for printing floats. However, Ryu is in a new class of recently developed algorithms that claim substantial improvements over previous efforts.

These algorithms:
* Produce a consistent round-trip representation for all 64-bit doubles
* Produce the shortest length string from equivalent choices in all cases
* Execute in a fraction of the time of previous efforts

Doubleback merges forks of existing Ryu projects and modifies and enhances them to expose a consistent API. Doubleback tests APIs against each other for consistency.

Doubleback implements printf %g equivalency which was not implemented previously by the reference Ryu project [3]

[1] https://dl.acm.org/doi/10.1145/3296979.3192369
[2] https://dl.acm.org/doi/pdf/10.1145/3360595
[3] https://github.com/ulfjack/ryu  (There is a wealth of information about Ryu in the README here.)

# Status

Doubleback is in development and is not ready for use or contributions.

# Roadmap for first release

* dfmt tests
* Setup github actions
* Java dfmt

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


# Charts that show Doubleback/Ryu is Fast with Short Output

![Doubleback/Ryu ranges from 10 to 20 times faster than standard printf](results/shortest-native-c-double-time.png "Time to Output")

![Doubleback/Ryu output is 30% to 96% out the output length](results/shortest-native-c-double-length.png "Output Length")

