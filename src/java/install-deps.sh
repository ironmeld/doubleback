#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

# Ubuntu 14.04, 16.04, 18.04, 20.04
if cat /etc/*-release | grep -i "ubuntu"; then
    apt-get update -y
    apt-get upgrade -y

    curl -sSL "https://bazel.build/bazel-release.pub.gpg" | sudo -E apt-key add -
    echo "deb https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee -a /etc/apt/sources.list
    apt-get update -y
    apt-get install -y make bazel gnuplot tmux sysvbanner

    if cat /etc/*-release | grep "14.04"; then
        apt-get install -y git make
        add-apt-repository -y ppa:openjdk-r/ppa
        apt-get update
        apt-get install -y openjdk-8-jdk
    elif cat /etc/*-release | grep -e "16.04" -e "18.04" -e "20.04"; then
        apt-get install -y openjdk-8-jdk-headless
    else 
        printf "ERROR: Unsupported Ubuntu Version.\n"
        exit 1
    fi
    
    exit 0
fi

# Centos 8
if cat /etc/*-release | grep -i "centos"; then
    if cat /etc/*-release | grep -e 'VERSION="8'; then
        dnf update -y
        dnf install -y git make gnuplot
        curl -O https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-8/vbatts-bazel-epel-8.repo
        mv vbatts-bazel-epel-8.repo /etc/yum.repos.d/
        dnf install -y bazel
        exit 0
    fi
fi

# Fedora 33+
if cat /etc/*-release | grep -i "fedora"; then
    dnf update -y
    dnf install -y git make gnuplot banner
    dnf install -y dnf-plugins-core
    dnf copr enable -y vbatts/bazel
    dnf install -y bazel
    exit 0
fi

printf "Could not detect distribution.\n"
exit 1


if [ -n "$(which banner)" ] && [ "$(uname -s)" != "Darwin" ]; then
    BANNER=banner
elif [ -n "$(which figlet)" ]; then
    BANNER=figlet
fi

for subdir in ./*; do
  # support sparse checkouts by only building what is present
  if [ -d "$subdir" ]; then
      lang="${subdir/\.\//}"
      printf "%s starting install dependencies for language %s\n" "$(date)" "$lang"
      if [ -n "$BANNER" ]; then
          "$BANNER" "Install" "deps" "$lang"
      fi
      make -C "$subdir" install-deps
      printf "%s finished install dependencies for language %s\n" "$(date)" "$lang"
  fi
done
