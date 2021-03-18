# Installing Dependencies

This document contains instructions for installing the dependencies for building Doubleback.

# Ubuntu 16.04 Instructions

## make and gcc

```
sudo apt-get install gcc make
```

## bazel

```
curl -sSL "https://bazel.build/bazel-release.pub.gpg" | sudo -E apt-key add -
sudo echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install bazel
```

## cmake

```
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main'
sudo apt-get update
sudo apt-get install cmake
```

## gnuplot

```
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install gnuplot
```
