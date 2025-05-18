#!/usr/bin/env bash
set -e

echo "This script will list both enabled AND disabled extensions"
echo
echo "So please uninstall any extensions you are not using"
echo
sleep 2

code --list-extensions > ~/.config/Code/EXTENSIONS.list.CURRENT
