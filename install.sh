#!/bin/bash
# install.sh - Create symlinks for dotfiles
# Skips entries that are already correctly linked to avoid disrupting
# untracked files inside linked directories (e.g. ~/.config cache files).
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
IGNORE_PATTERN="^\.(git|travis|DS_Store)"

# Link src to dest with the following rules:
#   - Already points to src   -> skip (preserves untracked contents)
#   - Symlink to wrong target  -> re-link
#   - Real file or directory   -> back up, then link
#   - Does not exist           -> link
_link() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        local current_target
        current_target="$(readlink "$dest")"

        if [[ "$current_target" == "$src" ]]; then
            # Already points to the correct target; nothing to do.
            echo "  skip     : $dest"
            return
        fi

        # Points to a different target; re-link.
        # Explicitly remove first: `ln -f` on a symlink-to-directory would
        # create the new link *inside* the target dir instead of replacing it.
        rm -v "$dest"
    elif [[ -e "$dest" ]]; then
        # Back up an existing real file or directory before overwriting.
        mkdir -p "$BACKUP_DIR"
        mv -v "$dest" "$BACKUP_DIR/"
        echo "  backed up: $dest -> $BACKUP_DIR/"
    fi

    ln -sv "$src" "$dest"
}

echo "==> Creating dotfile links"
echo "    source : $DOTFILES_DIR"
echo "    backup : $BACKUP_DIR (created only if needed)"
echo ""

for dotfile in "$DOTFILES_DIR"/.??*; do
    # Skip if the glob produced no matches.
    [[ -e "$dotfile" ]] || continue

    name="$(basename "$dotfile")"

    # Skip ignored patterns (.git, .travis, etc.).
    [[ "$name" =~ $IGNORE_PATTERN ]] && continue

    _link "$dotfile" "$HOME/$name"
done

echo ""
echo "==> Done"
