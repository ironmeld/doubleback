# Installing Dependencies

This document contains instructions for installing the dependencies for building Doubleback.
* Ubuntu Recent [#ubuntu-recent]
* Ubuntu 14.04 [#ubuntu-14.04]
* CentOS 8 [#centos-8]


# Ubuntu Recent

These instructions apply to Ubuntu from version 16.04 to the most recent version.

## common dev tools

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

## common dev tools

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

# CentOS 8

```
sudo dnf update
sudo dnf install git make gcc gcc-c++ cmake gnuplot
curl -O https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-8/vbatts-bazel-epel-8.repo
sudo mv vbatts-bazel-epel-8.repo /etc/yum.repos.d/
sudo dnf install bazel  # this installs java 11
```

# Fedora 33

```
sudo dnf update
sudo dnf install git make gcc gcc-c++ cmake gnuplot
sudo dnf install dnf-plugins-core
sudo dnf copr enable vbatts/bazel
sudo dnf install bazel
```
