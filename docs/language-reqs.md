# Doubleback Language Implementation Requirements

## Implement Makefile

* The implementation must have a Makefile that supports make, make test, and make benchmark
* The implementation must build, test, and benchmark under these environments:
    * Every Ubuntu LTS version from 14.04 to current
    * Fedora 33+
    * Centos 8
    * OSX
    * Windows
* There must be instructions for installing any needed build dependencies for each environment

## Implement dfmt

* dfmt converts a double to a string.
* Implementation must implement the same functional tests as the c language dfmt tests.

## Implement dparse

* dparse converts a string to a double.
* Implementation must implement the same functional tests as the c language dparse tests.

## Implement dfmt-echo.sh and pass tests

* Implement a test "echo" program which "dparses" every line in stdin and outputs the resulting double with dfmt
* Implement a script called dfmt-echo.sh that launches the echo program
* Pass the test-doubles.sh comparison and round-trip test
* Pass the fuzz.sh fuzzing test

## Implement benchmarks against native implementation

* Implementation must compare dparse and dfmt to equivalent language primitives or standard libary routines
* Implementation must output csv, pdf, and png files in same style as the C language benchmarks.

## Document API

* The implementation must provide documentation in markdown format for:
    * The dfmt and dparse APIs
    * Minimal instructions for incorporating doubleback into a project

## Organized and Minimalized

* Test and benchmark code must be separated from the core source code.
* The implementation must remove excess files and code that do not support the requirements.
