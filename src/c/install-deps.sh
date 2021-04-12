#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

# Ubuntu 14.04, 16.04, 18.04, 20.04
if cat /etc/*-release | grep -i "ubuntu"; then
    apt-get install -y gcc cmake gnuplot tmux

    if ! which bazel; then
        if [ "$(arch)" = x86_64 ]; then
            curl -sSL "https://bazel.build/bazel-release.pub.gpg" | sudo -E apt-key add -
            echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee -a /etc/apt/sources.list
            apt-get update -y
            apt-get install -y bazel
        elif [ "$(arch)" = aarch64 ]; then
            # build bazel from scratch
            apt-get install -y build-essential openjdk-11-jdk python zip unzip
            mkdir ~/build-bazel
            cd ~/build-bazel
            # -O preserves filename -L follows links
            curl -OL https://github.com/bazelbuild/bazel/releases/download/4.0.0/bazel-4.0.0-dist.zip
            unzip bazel-4.0.0-dist.zip
            # takes upwards of 15 minutes
            env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
            cp ~/build-bazel/output/bazel /usr/local/bin/
        else
            printf "ERROR: Unsupported architecture: %s\n" "$(arch)"
            exit 1
        fi
    fi

    if cat /etc/*-release | grep "14.04"; then
        apt-get install -y clang
    elif cat /etc/*-release | grep -e "16.04" -e "18.04" -e "20.04" -e "20.10"; then
        # fuzzing is only supported on ubuntu 20.04 because it takes too much
        # effort to get it working properly on other versions and distros.
        if cat /etc/*-release | grep -e "20.04" -e "20.10"; then
            apt-get install -y afl++-clang clang-tools
            printf "INFO: echo core | sudo tee /proc/sys/kernel/core_pattern\n"
            echo core | sudo tee /proc/sys/kernel/core_pattern
        fi
    else 
        printf "ERROR: Unsupported Ubuntu Version.\n"
        exit 1
    fi
    exit 0
fi

if cat /etc/*-release | grep -i "debian"; then
    apt-get install -y clang gcc cmake gnuplot tmux

    if ! which bazel; then
        apt-get install -y gnupg
        curl -sSL "https://bazel.build/bazel-release.pub.gpg" | sudo -E apt-key add -
        echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee -a /etc/apt/sources.list
        apt-get update -y
        apt-get install -y bazel
    fi
    exit 0
fi

# Centos 8
if cat /etc/*-release | grep -i "centos"; then
    if cat /etc/*-release | grep -e 'VERSION="8'; then
        dnf install -y gcc gcc-c++ cmake gnuplot
        if ! which bazel; then
            curl -O https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-8/vbatts-bazel-epel-8.repo
            mv vbatts-bazel-epel-8.repo /etc/yum.repos.d/
            dnf install -y bazel
        fi
        exit 0
    fi
fi

# Red Hat 8
if cat /etc/*-release | grep -i "red hat"; then
    if cat /etc/*-release | grep -e 'VERSION="8'; then
        dnf install -y gcc gcc-c++ cmake gnuplot
        if ! which bazel; then
            curl -O https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-8/vbatts-bazel-epel-8.repo
            mv vbatts-bazel-epel-8.repo /etc/yum.repos.d/
            dnf install -y bazel
        fi
        exit 0
    fi
elif cat /etc/*-release | grep -i "fedora"; then
    # Fedora 33+
    dnf install -y gcc gcc-c++ cmake gnuplot
    dnf install -y dnf-plugins-core
    if ! which bazel; then
        dnf copr enable -y vbatts/bazel
        dnf install -y bazel
    fi
    exit 0
fi

# OpenSUSE Tumbleweed
if cat /etc/*-release | grep -i "opensuse-tumbleweed"; then
    zypper install -y  gcc gcc-c++ cmake gnuplot bazel
    exit 0
fi

printf "Could not detect supported operating system.\n"
exit 1
