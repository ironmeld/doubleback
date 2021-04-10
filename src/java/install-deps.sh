#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

# Ubuntu 14.04, 16.04, 18.04, 20.04
if cat /etc/*-release | grep -i "ubuntu"; then
    apt-get install -y gnuplot

    if ! which bazel; then
        curl -sSL "https://bazel.build/bazel-release.pub.gpg" | apt-key add -
        echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee -a /etc/apt/sources.list
        apt-get update -y
        apt-get install -y bazel
    fi

    if cat /etc/*-release | grep "14.04"; then
        if ! which java; then
            add-apt-repository -y ppa:openjdk-r/ppa
            apt-get update -y
            apt-get install -y openjdk-8-jdk
        fi
    elif cat /etc/*-release | grep -e "16.04" -e "18.04" -e "20.04" -e "20.10"; then
        if ! which java; then
            apt-get install -y openjdk-8-jdk-headless
        fi
    else 
        printf "ERROR: Unsupported Ubuntu Version.\n"
        exit 1
    fi
    
    exit 0
fi

# Debian 10
if cat /etc/*-release | grep -i "debian"; then
    # bazel
    if ! which bazel; then
        apt-get install -y gnupg
        curl -sSL "https://bazel.build/bazel-release.pub.gpg" | apt-key add -
        echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee -a /etc/apt/sources.list
        apt-get update -y
        apt-get install -y bazel
    fi

    # java
    if ! which java; then
        apt-get install -y software-properties-common
        wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add -
        add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
        apt-get update -y && apt-get install -y adoptopenjdk-8-hotspot
    fi
    exit 0
fi

# Centos 8
if cat /etc/*-release | grep -i "centos"; then
    if cat /etc/*-release | grep -e 'VERSION="8'; then
        dnf install -y gnuplot
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
        dnf install -y gnuplot
        if ! which bazel; then
            curl -O https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-8/vbatts-bazel-epel-8.repo
            mv vbatts-bazel-epel-8.repo /etc/yum.repos.d/
            dnf install -y bazel
        fi
        exit 0
    fi
elif cat /etc/*-release | grep -i "fedora"; then
    # Fedora 33+
    dnf install -y gnuplot
    dnf install -y dnf-plugins-core
    if ! which bazel; then
        dnf copr enable -y vbatts/bazel
        dnf install -y bazel
    fi
    exit 0
fi

# OpenSUSE Tumbleweed
if cat /etc/*-release | grep -i "opensuse-tumbleweed"; then
    zypper install -y gnuplot bazel
    exit 0
fi

printf "Could not detect supported operating system.\n"
exit 1
