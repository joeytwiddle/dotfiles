packages_editor="vim-gtk exuberant-ctags"
packages_winman="xfonts-75dpi xfonts-100dpi fluxbox xdotool wmctrl xscreensaver imagemagick"
packages_ui="geeqie gkrellm"
packages_remote="openssh-server screen xtightvncviewer x11vnc tightvncserver"

#packages_winman="xfstt"   # To get LucidaConsole in GVim!  (See ~/FONTS folder)
#packages_debugging="iotop atop nmap wireshark"
#packages_desktop_extended="mplayer gimp inkscape libreoffice dict-wn zsh"
#packages_yummy="hugs"   # ghc is also nice, but 290meg!

sudo aptitude install $packages_editor $packages_winman $packages_ui $packages_remote $packages_debugging $packages_desktop_extended $packages_yummy
