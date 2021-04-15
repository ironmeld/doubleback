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
        ;;

    ubuntu)
        apt-get update -y
        apt-get upgrade -y
        apt-get install -y git make sysvbanner
        ;;

    debian)
        apt-get update -y
        apt-get upgrade -y
        apt-get install -y git make sysvbanner
        ;;

    centos8)
        dnf update -y
        dnf install -y epel-release
        dnf install -y git make banner
        ;;

    redhat8)
        dnf update -y
        dnf install -y git make
        ;;

    fedora)
        dnf update -y
        dnf install -y git make banner
        ;;

    opensuse)
        zypper update -y
        zypper install -y make figlet
        ;;
esac

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
