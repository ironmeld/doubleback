#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

function detect_os {
    if [ "$(uname -s)" = "Darwin" ]; then
        printf "osx"
        return 0
    fi

    # Ubuntu 14.04, 16.04, 18.04, 20.04
    if cat /etc/*-release | grep -q -i "ubuntu"; then
        printf "ubuntu"
        return 0
    fi

    # Debian 10
    if cat /etc/*-release | grep -q -i "debian"; then
        printf "debian"
        return 0
    fi

    # Centos 8
    if cat /etc/*-release | grep -q -i "centos"; then
        if cat /etc/*-release | grep -q -e 'VERSION="8'; then
            printf "centos8"
            return 0
        fi
    fi

    # Red Hat 8
    if cat /etc/*-release | grep -q -i "red hat"; then
        if cat /etc/*-release | grep -q -e 'VERSION="8'; then
            printf "redhat8"
            return 0
        fi
    elif cat /etc/*-release | grep -q -i "fedora"; then
        # Fedora 33+
        printf "fedora"
        return 0
    fi

    # OpenSUSE Tumbleweed
    if cat /etc/*-release | grep -q -i "opensuse-tumbleweed"; then
        printf "opensuse"
        return 0
    fi

    return 1
}

DETECTED_OS="$(detect_os)"
if [ -z "$DETECTED_OS" ]; then
    printf "Could not detect supported operating system.\n"
    exit 1
fi

case "$DETECTED_OS" in
    osx)
        if ! which bazel; then
            # build bazel from scratch
            mkdir ~/build-bazel
            cd ~/build-bazel
            # -O preserves filename -L follows links
            curl -OL https://github.com/bazelbuild/bazel/releases/download/4.0.0/bazel-4.0.0-dist.zip
            unzip bazel-4.0.0-dist.zip
            # Apply this patch manually until it is released:
            # https://github.com/bazelbuild/bazel/commit/0216ee54417fa1f2fef14f6eb14cbc1e8f595821
            sed -i '' -e 's/sourceJar, null/sourceJar, (ClassLoader) null/' ./src/java_tools/buildjar/java/com/google/devtools/build/buildjar/VanillaJavaBuilder.java
            # takes upwards of 15 minutes
            env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
            cp ~/build-bazel/output/bazel /usr/local/bin/
        fi
        ;;

    ubuntu)
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
        ;;

    debian)
        apt-get install -y clang gcc cmake gnuplot tmux

        if ! which bazel; then
            apt-get install -y gnupg
            curl -sSL "https://bazel.build/bazel-release.pub.gpg" | sudo -E apt-key add -
            echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee -a /etc/apt/sources.list
            apt-get update -y
            apt-get install -y bazel
        fi
        ;;

    centos8)
        dnf install -y gcc gcc-c++ cmake gnuplot
        if ! which bazel; then
            curl -O https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-8/vbatts-bazel-epel-8.repo
            mv vbatts-bazel-epel-8.repo /etc/yum.repos.d/
            dnf install -y bazel
        fi
        ;;

    redhat8)
        dnf install -y gcc gcc-c++ cmake gnuplot
        if ! which bazel; then
            curl -O https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-8/vbatts-bazel-epel-8.repo
            mv vbatts-bazel-epel-8.repo /etc/yum.repos.d/
            dnf install -y bazel
        fi
        ;;

    fedora)
        dnf install -y gcc gcc-c++ cmake gnuplot
        dnf install -y dnf-plugins-core
        if ! which bazel; then
            dnf copr enable -y vbatts/bazel
            dnf install -y bazel
        fi
        ;;

    opensuse)
        zypper install -y  gcc gcc-c++ cmake gnuplot bazel
        ;;

    *)  
        printf "invalid os /%s/\n" "$DETECTED_OS"
        exit 1
        ;;
esac
