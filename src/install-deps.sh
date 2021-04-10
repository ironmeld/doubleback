#!/usr/bin/env bash
# shellcheck disable=SC2230
set -euo pipefail
IFS=$'\n\t'

DETECTED_OS=""
# Ubuntu 14.04, 16.04, 18.04, 20.04
if cat /etc/*-release | grep -i "ubuntu"; then
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y git make sysvbanner
    DETECTED_OS="ubuntu"
fi

# Debian 10
if cat /etc/*-release | grep -i "debian"; then
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y git make sysvbanner
    DETECTED_OS="debian"
fi

# Centos 8
if cat /etc/*-release | grep -i "centos"; then
    if cat /etc/*-release | grep -e 'VERSION="8'; then
        dnf update -y
        dnf install -y epel-release
        dnf install -y git make banner
    fi
    DETECTED_OS="centos8"
fi

# Red Hat 8
if cat /etc/*-release | grep -i "red hat"; then
    if cat /etc/*-release | grep -e 'VERSION="8'; then
        dnf update -y
        dnf install -y git make
    fi
    DETECTED_OS="redhat8"
elif cat /etc/*-release | grep -i "fedora"; then
    # Fedora 33+
    dnf update -y
    dnf install -y git make banner
    DETECTED_OS="fedora"
fi

# OpenSUSE Tumbleweed
if cat /etc/*-release | grep -i "opensuse-tumbleweed"; then
    zypper update -y
    zypper install -y make figlet
    DETECTED_OS="opensuse"
fi

if [ -z "$DETECTED_OS" ]; then
    printf "Could not detect supported operating system.\n"
    exit 1
fi

BANNER=""
if which banner && [ "$(uname -s)" != "Darwin" ]; then
    BANNER=banner
elif which figlet; then
    BANNER=figlet
fi

for subdir in ./*; do
  # support sparse checkouts by only building what is present
  if [ -d "$subdir" ]; then
      lang="${subdir/\.\//}"
      printf "%s starting install dependencies for language %s\n" "$(date)" "$lang"
      [ -n "$BANNER" ] && "$BANNER" "Install" "deps" "$lang"
      make -C "$subdir" install-deps
      printf "%s finished install dependencies for language %s\n" "$(date)" "$lang"
  fi
done
