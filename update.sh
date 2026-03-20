#!/bin/bash
# update.sh - Pull the latest dotfiles and apply only missing/changed links
# Unlike install.sh, this is intended for day-to-day use after editing dotfiles
# on another machine.  Already correct symlinks are skipped, so untracked files
# inside linked directories (e.g. ~/.config cache) are never disturbed.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Pulling latest changes"
git -C "$DOTFILES_DIR" pull --rebase

echo ""
echo "==> Applying new or changed links"
"$DOTFILES_DIR/install.sh"
