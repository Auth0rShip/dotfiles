#!/bin/bash
# install.sh - Create symlinks for dotfiles
#
# Rules:
#   - Already points to src   -> skip
#   - Symlink to wrong target -> remove and re-link
#   - Real file or directory  -> back up, then link
#   - Does not exist          -> link
#
# Correctly linked directories are left untouched so that untracked files
# inside them are preserved.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)_$$"

# Make unmatched globs expand to nothing instead of remaining literal.
shopt -s nullglob

_link() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        local current_target
        current_target="$(readlink "$dest")"

        if [[ "$current_target" == "$src" ]]; then
            echo "  skip     : $dest"
            return
        fi

        # Remove an incorrect symlink first.
        #
        # Using `ln -f` directly on a symlink-to-directory may create the
        # new symlink inside the target directory rather than replacing it.
        rm -v "$dest"

    elif [[ -e "$dest" ]]; then
        # Back up an existing real file or directory before replacing it.
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

# .[!.]* matches:
#   .a
#   .bashrc
#   .config
#
# ..?* additionally covers names beginning with two dots while excluding
# the special entries "." and "..".
for dotfile in "$DOTFILES_DIR"/.[!.]* "$DOTFILES_DIR"/..?*; do
    name="$(basename "$dotfile")"

    # Files/directories belonging to the dotfiles repository itself.
    case "$name" in
        .git|.travis|.DS_Store)
            continue
            ;;
    esac

    _link "$dotfile" "$HOME/$name"
done

echo ""
echo "==> Done"
