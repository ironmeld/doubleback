# Installing Dependencies

This document contains instructions for installing the dependencies for building Doubleback.
* Ubuntu Recent [#ubuntu-recent]
* Ubuntu 14.04 [#ubuntu-14.04]


# Ubuntu Recent

These instructions apply to Ubuntu from version 16.04 to the most recent version.

## make, gcc, java 8, cmake, gnuplot

```
sudo apt-get update
sudo apt-get install make gcc openjdk-8-jdk-headless cmake gnuplot
```

## bazel

```
curl -sSL "https://bazel.build/bazel-release.pub.gpg" | sudo -E apt-key add -
sudo echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install bazel
```

# Ubuntu 14.04

## git make gcc cmake gnuplot

```
sudo apt-get update
sudo apt-get install git make gcc cmake gnuplot
```

## java 8

```
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install openjdk-8-jdk
```

## bazel

```
curl -sSL "https://bazel.build/bazel-release.pub.gpg" | sudo -E apt-key add -
sudo echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install bazel
```
