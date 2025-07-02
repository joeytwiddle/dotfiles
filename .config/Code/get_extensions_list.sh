#!/usr/bin/env bash
set -e

#echo "This script will list both enabled AND disabled extensions"
#echo
#echo "So please uninstall any extensions you are not using"
#echo
#sleep 2

code --list-extensions > ~/.config/Code/EXTENSIONS.list.CURRENT

# We mark as disabled any extensions which were marked as disabled in the current EXTENSIONS.list
# Although they might not be disabled locally, this just makes it easier to compare the files for any new or removed extensions
if [ -f ~/.config/Code/EXTENSIONS.list ]
then
    cat ~/.config/Code/EXTENSIONS.list.CURRENT |
    while read line
    do
        if grep -F "#${line}" ~/.config/Code/EXTENSIONS.list >/dev/null
        then echo "#${line}"
        elif grep -F "#-${line}" ~/.config/Code/EXTENSIONS.list >/dev/null
        then echo "#-${line}"
        else echo "$line"
        fi
    done |
    cat > ~/.config/Code/EXTENSIONS.list.ALIGNED
fi
