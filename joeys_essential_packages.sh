#!/bin/bash
#set -e

# For automated installation, pass -yq

# Options {{{
do_apt_install_even_if_packages_are_missing=
install_python_packages=
install_latest_mongodb=
install_yarn=
install_node_packages=
# }}}

# Functions {{{

packages_to_install=""

install_package() {
  packages_to_install="$packages_to_install $*"
}

add_repository() {
  local ppa_repo="$1"
  echo "Not adding PPA $ppa_repo"
  return 1
  . /etc/lsb-release
  local apt_sources_file="$(echo "${ppa_repo}" | tr '/.' '-_')-${DISTRIB_CODENAME}.list"
  local apt_sources_path="/etc/apt/sources.list.d/${apt_sources_file}"
  if [ -f "$apt_sources_path" ]
  then
    echo "### We already have ppa:$ppa_repo"
  else
    echo "### Adding PPA $ppa_repo to $apt_sources_path"
    sudo add-apt-repository ppa:"$ppa_repo"
    added_repo=1
  fi
}

has_exe() {
  command -v "$@" >/dev/null
}

# pip2 on Ubuntu 14.01 did not need this.  It automatically checks if a package is installed, and simply reports "Requirement already satisfied" if it is.
# But that was not the case on my Linux Mint's pip3
python_package_is_installed() {
  pip3 list | grep -v "^Package *Version$" | grep -v "^-*$" | cut -d ' ' -f 1 | grep -xF "$1" >/dev/null
}
pip_install() {
  if [ -z "$install_python_packages" ]
  then
    echo "Skipping python package $1"
    return
  fi
  if python_package_is_installed "$1"
  then echo "Python package $1 is already installed"
  else pip3 install --user "$1"
  fi
}

# }}}


# Python is needed for some of the below to work
if has_exe python3 && has_exe pip3
then : # ok
else sudo apt-get install python3 python3-pip python3-setuptools
fi


# Desktop {{{

install_package xterm
install_package fluxbox
install_package wmctrl xdotool xosd-bin
install_package xfonts-75dpi xfonts-100dpi
install_package xscreensaver xscreensaver-data-extra xscreensaver-screensaver-bsod xscreensaver-gl # xscreensaver-gl-extra
# Used by randomwallpaper/jxsetbg
install_package imagemagick
# Provides xsetbg, used by randomwallpaper/jxsetbg.  (They can fall back to fbsetbg, but that crops-to-fit rather than shrink-to-fit.)
install_package xloadimage
install_package gkrellm gkrellweather gkrelltop gkrellm-cpufreq

# To get LucidaConsole in GVim!  (See ~/FONTS folder)
# No longer required
#packages_winman="xfstt"

# Core desktop apps
install_package zsh

# Editors
install_package vim-gtk exuberant-ctags

# Remote access (client)
install_package xtightvncviewer

# Remote access (server)
install_package openssh-server screen tmux xtightvncviewer x11vnc tightvncserver

# More desktop apps

# Copy between shell and clipboard
install_package xclip

install_package dict-wn
install_package dict-moby-thesaurus

install_package okular
install_package libreoffice

install_package geeqie
install_package gimp inkscape
#install_package krita

# MPlayer which can play h265
#add_repository mc3man/mplayer-test
install_package mplayer

install_package smplayer

# Audio tools (for randommp3)
install_package vorbisgain normalize-audio
# TOFIND: mp3gain

# Ubuntu recommends installing mailtools in order to get the 'mail' command.
# It installs postfix.
#install_package mailtools
# But I prefer exim!
# Both postfix and exim open a dpkg config dialog.
install_package exim4

install_package wine-stable

install_package compton
# An advanced panel, like Mac OS X's
#add_repository cairo-dock-team/ppa
#install_package cairo-dock
# A simple panel, like Mac OS X's
#install_package wbar
# An window selector like "expo"
# It works with any WM, but only shows thumbnails for current workspace
# And it doesn't work so well with Fluxbox groups: all windows in the group get the thumbnail of the visible window!
#add_repository landronimirc/skippy-xd-daily
#install_package skippy-xd

# Dashes / launchers
#install_package kupfer
#sudo add-apt-repository ppa:synapse-core/ppa
#install_package synapse
#install_package launchy
#install_package gnome-do
install_package xfce4-appfinder

# Albert is the nicest launcher I found so far.  QT based.
add_repository nilarimogard/webupd8
add_repository flexiondotorg/albert &&
# Or from the official author: https://software.opensuse.org/download.html?project=home:manuelschneid3r&package=albert
install_package albert

# Cardapio, a launcher like Ubuntu Unity's Dash or Mac OS X's Spotlight
# Appears to be out-of-date.
#add_repository cardapio-team/cardapio-ppa
#add_repository nilarimogard/webupd8
#install_package cardapio

# Communication
install_package mutt
# Hexchat IRC client
add_repository gwendal-lebihan-dev/hexchat-stable
install_package hexchat
# Facebook Messenger
#sudo apt-key adv --keyserver pool.sks-keyservers.net --recv 6DDA23616E3FE905FFDA152AE61DA9241537994D
#echo "deb https://dl.bintray.com/aluxian/deb/ stable main" | sudo tee -a /etc/apt/sources.list.d/aluxian.list
#install_package messengerfordesktop

# }}}


# Mathematics {{{

#install_package gnuplot
#install_package wxmaxima
#install_package octave

# }}}


# Audio/video reencoding {{{

# Extended audio
install_package mpg123   # In case mplayer is not available
install_package lame mp3info   # For reencoding to mp3
# bladeenc 
install_package vorbis-tools   # For reencoding to ogg
install_package audacious      # For editing/clipping audio

# For reencode_video_to_x264
install_package faac gpac x264 mencoder

#install_package ffmpeg
# In Ubuntu 14.04, avconv from libav-tools replaces ffmpeg (it is a fork)
#install_package libav-tools
# However ffmpeg is back in 15.04!

# Download videos/playlists from YouTube and other sites
#add_repository nilarimogard/webupd8
#install_package youtube-dl
# More up-to-date
pip_install youtube-dl

# }}}


# System {{{

# Automatic packages updates
install_package unattended-upgrades
install_package apt-listchanges

# Logging
#install_package bootlogd

# Control
install_package lm-sensors
install_package cpufrequtils

# TODO: This may be worth configuring.  It can save battery by stopping the disk from spinning when off AC power.
# It is mentioned here: https://help.ubuntu.com/community/PowerManagement/ReducedPower
# Although with all the stuff I have running (e.g. Chrome browser) I think my disk will be hit every couple of minutes at least, so it may keep waking up again.
#install_package laptop-power-mode

# Debugging
install_package iotop atop
install_package inotify-tools
install_package mesa-utils

# Network debugging
install_package nmap wireshark tcpdump
install_package traceroute
# Shows network usage by process.  'm' to toggle between rate and total, and select units.  'r' and 's' to sort by received/sent.
# Usage: nethogs [device]
install_package nethogs
# Shows network usage by remote host and local/remote ports.
install_package jnettop
# tcptrack is similar but with a simplified display.  It shows duration but no totals.
#install_package tcptrack
# Shows a graph, in a terminal, but no process separation: slurm
# But in fact this does a better job: speedometer
# Nerdy, shows TCP flags and UDP packets.  Quite a good overview.
#install_package iptraf

# Provides an easy way to flood the CPU, for testing purposes.  Supposedly optimized for different hardware, but I couldn't find a way to flood both my Celeron cores at once!
#install_package cpuburn
# Alternative.  E.g.: stress --cpu 2 --timeout 120s
#install_package stress

# Packaging
install_package aptitude dpkg-repack alien fakeroot
# Alternative to make install which generates a deb, for easy clean removal
install_package checkinstall
install_package equivs
# For building Debian packages
install_package devscripts build-essential
# Pbuilder will build deb packages in a chroot, so you don't need to install dependencies on your main system
#install_package pbuilder

# }}}


# Development {{{

install_package git ccache sshfs encfs unison lftp
# 'git-core' is transitioning to 'git'
# 20th century revision control
install_package rcs

install_package nginx

install_package hugs
# ghc is also nice, but 290meg!
#install_package ghc
#install_package cabal-install

# Shell development
install_package shellcheck
# For portability testing
install_package posh ksh
# dash ash

# Install Java Development Kit
install_package default-jdk

# Installing packages for a project without installing them onto the system
#add_repository antono/nix
#install_package nix

# Include certutil
install_package libnss3-tools

# Include pip, python package manager
#install_package python-dev
#install_package python-pip
# We can then upgrade to the latest pip
# But this way IS NOT RECOMMENDED if you don't have permission to write to /usr/local
# If you try that, you might end up with the error: cannot import module 'name'
# That can be fixed by doing: python -m pip uninstall pip
#                         or: sudo python3 -m pip uninstall pip
#pip3 install --upgrade pip

# Includes things needed for development
#install_package golang
# Just the executable
install_package golang-go

# Linter for HTML
pip_install proselint

# }}}


# Not crucial but desirable {{{

# Vim uses links to open/dump web pages
install_package links

# Needed by scdl (soundcloud download)
install_package curl

install_package rar p7zip-full
install_package festival festvox-rablpc16k
# Firefox needs espeak to do SpeechSynthesis (actually I think that might not be true!)
install_package espeak
install_package compizconfig-settings-manager

# You never know when you might need this
install_package dosbox

# Color pickers, to conveniently pick colors from off the screen.
install_package gpick gcolor2

#packages_demodev="ocaml-nox liblz4-tool menhir ocamldsort"

# Mount Android device over USB
install_package mtpfs
# Download photos from iPod/iPhone, from command-line
install_package gphoto2
# Download photos from iPod/iPhone, using a GUI
install_package shotwell

# Tweak fonts
install_package fontforge

# }}}



# === Less crucial ===

#install_package msttcorefonts
# texlive-fonts-recommended

# xbacklight
# sudo add-apt-repository ppa:indicator-brightness/ppa
# indicator-brightness
# sudo add-apt-repository ppa:kamalmostafa/linux-kamal-mjgbacklight



# Things I have to install manually {{{

## Now using the PPA above
# curl -L https://atom.io/download/deb -o atom-dunno.deb

# - skype
# - nvm
# - rvm

## Things I like to have installed in ~/src/
# joeytwiddle/git-aware-prompt
## https://github.com/tj/git-extras/blob/master/Commands.md
# tj/git-extras
# gitbits/git-shift
# joeytwiddle/git-mv-changes

# }}}



# From PPAs {{{

# Atom editor
add_repository webupd8team/atom
#install_package atom

# Unetbootin
add_repository gezakovacs/ppa
install_package unetbootin

# Install NodeJS 0.10
# Alternative methods can be found here: https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
# To install io.js, look here: https://nodesource.com/blog/nodejs-v012-iojs-and-the-nodesource-linux-repositories
#add_repository chris-lea/node.js
#install_package nodejs

# But you probably want NVM so you can get the latest version of Node, or switch versions for different projects.
# To install it using `curl|sh` check the README: https://github.com/creationix/nvm/
# When I last installed it, the command was:
#     curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.30.1/install.sh | bash

# If you are on Ubuntu, and you want tmux 2 or greater, see https://gist.github.com/P7h/91e14096374075f5316e

# Want Heroku?
# wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh

#add_repository saltstack/salt
#install_package salt-master python-software-properties

# The latest version of wine:
add_repository ubuntu-wine/ppa
# But then the wine package upgraded without pulling in the latest version.
# I had to specify the version I needed.
install_package wine1.8
# Doing that kicked out: wine1.6 wine1.6-amd64 wine1.6-i386
# And at the same time installed:
#   libpcap0.8:i386
#   wine-gecko2.34
#   wine-gecko2.34:i386
#   wine-mono4.5.4
#   wine1.8-amd64
#   wine1.8-i386:i386

# Mount Google Drive as filesystem
add_repository alessandro-strada/ppa
install_package google-drive-ocamlfuse

if [ -n "$install_latest_mongodb" ]
then
  # Derived from here: http://docs.mongodb.org/master/tutorial/install-mongodb-on-ubuntu/
  . /etc/lsb-release
  apt_sources_path="/etc/apt/sources.list.d/mongodb-org-3.0.list"
  if [ ! -f "$apt_sources_path" ]
  then
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
    echo "deb http://repo.mongodb.org/apt/ubuntu ${DISTRIB_CODENAME}/mongodb-org/3.0 multiverse" |
      sudo tee "$apt_sources_path"
    added_repo=1
  fi
  install_package mongodb-org
  # Note that the mongo package in Ubuntu's repository is called 'mongodb' not 'mongodb-org'
  # On Ubuntu I had these installed: mongodb mongodb-clients mongodb-dev mongodb-server
  # Not sure what brought them in!  ;)
  # After removing them, they left behind /var/lib/mongodb and /var/log/mongodb
  # The mongo repo installs: mongodb-org mongodb-org-mongos mongodb-org-server mongodb-org-shell mongodb-org-tools
  # Last time I installed, they gave me version 3.0.6
fi

install_scala_build_tool=true
if [ -n "$install_scala_build_tool" ]
then
  apt_sources_path="/etc/apt/sources.list.d/sbt.list"
  if [ ! -f "/etc/apt/sources.list.d/sbt.list" ]
  then
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
    echo "deb https://dl.bintray.com/sbt/debian /" |
      sudo tee -a "$apt_sources_path"
    added_repo=1
  fi
  install_package sbt
fi

# I used to use focaltech-dkms as a touchpad driver, but that is now bundled with kernels.

# Installing docker...
# Install docker-compose
#     curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose >/dev/null
#     sudo chmod +x /usr/local/bin/docker-compose

# }}}



#sudo gem install git-background


#
#          https://github.com/jwiegley/git-scripts
#

# Run Android apps on Linux (provided they have x86 binaries): http://www.shashlik.io/download/
# shashlik also needs: lib32z1


[ -n "$added_repo" ] && sudo apt-get update

if [ -n "$do_apt_install_even_if_packages_are_missing" ]
then
  for package in $packages_to_install
  do sudo apt-get -V -y install $package "$@"
  done
else
  sudo apt-get -V install $packages_to_install "$@"
fi

#grep --line-buffered -v "is already the newest version.$"

# Unfortunately if we use grep, the "Do you want to continue [Y/n]?" will not be displayed, because no newline is sent!



# Other package managers
if which pip3 >/dev/null
then
  #sudo pip install vim-vint
  pip_install vim-vint
fi

# TODO: We might want to change this to install just yarn, and then install all the globals via yarn.
install_global_npm_packages_lazily() {
  # Alternatives: https://stackoverflow.com/questions/30667239/is-it-possible-to-install-npm-package-only-if-it-has-not-been-already-installed
  local node_root="$(npm root -g)"
  local to_install=""
  for package_name
  do
    if [ -d "$node_root/$package_name" ]
    then echo "Already installed: $package_name"
    else to_install="$to_install $package_name"
    fi
  done
  if [ -n "$to_install" ]
  then npm install -g ${to_install}
  fi
}

# Install yarn (requires Node >= 4.0)
if [ -n "$install_yarn" ]
then
  #install_global_npm_packages_lazily yarn
  curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
fi

install_node_packages() {
  if [ -z "$install_node_packages" ]
  then
    echo "Skipping node packages $*"
    return
  fi
  if which node >/dev/null
  then
    # With npm
    install_global_npm_packages_lazily "$@"

    # With yarn
    # (Not recommended if you are often switching node version with npm)
    #if ! which yarn >/dev/null
    #then
    #  echo "[WARNING] Could not find yarn, so could not install: $*" >&2
    #  return
    #fi
    #yarn global add "$@"
  fi
}

install_node_packages nodemon js-beautify tldr coffee-script json-fix nativefier
# The following should really be installed into the project they are used by
#install_global_npm_packages_lazily eslint standard babel-cli mocha browserify

# bro has a bit more detail than tldr, and uses colours, albeit horrible ones
#gem install bropages

if which go >/dev/null
then
  :
  # Display wiki pages on the terminal.  I wanted just a short summary but this presents the entire first section.
  #if ! which wiki >/dev/null
  #then
  #  echo "Installing go package: github.com/walle/wiki/cmd/wiki"
  #  go get github.com/walle/wiki/cmd/wiki
  #fi
fi



#pip_install coala-bears
# When I last installed coala-quickstart, it needed libxslt1-dev (it probably didn't need libxml2-dev)
# Dependencies: apt-get install libxml2-dev libxslt1-dev
#pip_install coala-quickstart


# vim: foldmethod=marker foldlevel=0 fdc=2 number relativenumber
