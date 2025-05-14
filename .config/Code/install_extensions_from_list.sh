#!/usr/bin/env bash
set -e

# Installs extensions which are not commented out
# Removes extensions which are prefixed by #-
# Leaves extensions which are prefixed by # as they are (they will not be installed or uninstalled, so they are optional)

cat ~/.config/Code/EXTENSIONS.list | grep -v '^#' | grep -v '^$' | xargs -L 1 echo code --install-extension
cat ~/.config/Code/EXTENSIONS.list | grep '^#-' | sed 's/^#-//' | xargs -L 1 echo code --uninstall-extension
echo "# To install extensions, rerun with |sh"
