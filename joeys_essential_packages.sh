packages_editor="vim-gtk exuberant-ctags"
packages_winman="xfonts-75dpi xfonts-100dpi fluxbox xdotool wmctrl xscreensaver imagemagick"
packages_ui="geeqie gkrellm"
#zsh
packages_remote="openssh-server screen xtightvncviewer x11vnc tightvncserver"

#packages_debugging="iotop nmap"
#packages_debugging="$packages_debugging wireshark"
packages_useful="dict-wn"
packages_winman="xfstt"   # To get LucidaConsole in GVim!

sudo aptitude install $packages_editor $packages_winman $packages_ui $packages_remote $packages_debugging $packages_useful
