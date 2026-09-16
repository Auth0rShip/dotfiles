#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_FILE="$DIR/packages.txt"

if command -v paru >/dev/null 2>&1; then
    manager="paru"
elif command -v apt >/dev/null 2>&1; then
    manager="apt"
else
    echo "No supported package manager found."
    exit 1
fi

echo "Package manager: $manager"

while read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue

    case "$manager" in
        paru)
            if paru -Si "$package" >/dev/null 2>&1; then
                paru -Syu --needed --noconfirm "$package"
            else
                echo "Not found: $package"
            fi
            ;;

        apt)
            if apt-cache show "$package" >/dev/null 2>&1; then
                sudo apt install -y "$package"
            else
                echo "Not found: $package"
            fi
            ;;
    esac
done < "$PACKAGE_FILE"
