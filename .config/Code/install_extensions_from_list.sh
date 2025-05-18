#!/usr/bin/env bash
set -e

# Installs extensions which are not commented out
# Removes extensions which are prefixed by #-
# Leaves extensions which are prefixed by # as they are (they will not be installed or uninstalled, so they are optional)

cat ~/.config/Code/EXTENSIONS.list |
    grep -v '^#' |
    grep -v '^$' |
    # Skip any extensions which are already installed
    grep -v -F -x -f EXTENSIONS.list.CURRENT |
    xargs -L 1 echo code --install-extension

cat ~/.config/Code/EXTENSIONS.list |
    grep '^#-' |
    sed 's/^#-//' |
    # Select only extensions which are currently installed
    grep -F -x -f EXTENSIONS.list.CURRENT |
    xargs -L 1 echo code --uninstall-extension

echo "# To install extensions, rerun with |sh"
