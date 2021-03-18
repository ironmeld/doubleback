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

```
$ git clone https://github.com/ironmeld/doubleback
$ cd doubleback
```

If you do not have these packages installed, then you will need to install them:
* bazel
    * On Ubuntu:
```
curl -sSL "https://bazel.build/bazel-release.pub.gpg" | sudo -E apt-key add -
sudo echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install bazel
```
*  cmake
    * On Ubuntu:
```
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
# Replace xenial with DISTRIB_CODENAME from /etc/lsb-release:
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main'
sudo apt-get update
sudo apt-get install cmake
```
*  make
*  gcc
*  gnuplot

Build in all languages:
```
$ make
```

# Acknowledgements

| Language | Upstream Project |
|----------|------------------|
| C        | https://github.com/ulfjack/ryu |
| Java     | https://github.com/ulfjack/ryu |


# Charts that show Ryu is Fast with Short Output

![Ryu ranges from 10 to 20 times faster than standard printf](results/shortest-native-c-double-time.png "Time to Output")

![Ryu output is 30% to 96% out the output length](results/shortest-native-c-double-length.png "Output Length")

