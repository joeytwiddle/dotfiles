packages_editor="vim-gtk exuberant-ctags"
packages_winman="xfonts-75dpi xfonts-100dpi fluxbox xscreensaver xscreensaver-data-extra imagemagick"
packages_ui="geeqie gkrellm"
packages_remote="openssh-server screen xtightvncviewer x11vnc tightvncserver tmux"

#packages_winman="xfstt"   # To get LucidaConsole in GVim!  (See ~/FONTS folder)
packages_debugging="iotop atop nmap wireshark mesa-utils lmsensors"
packages_desktop_extended="mplayer gimp inkscape dict-wn zsh wmctrl xdotool xosd-bin"
# libreoffice compizconfig-settings-manager 
packages_yummy="hugs"   # ghc is also nice, but 290meg!

packages_system="cpufrequtils"

packages_development="git-core ccache sshfs encfs unison lftp" # 'git-core' is transitioning to 'git'

sudo aptitude install $packages_editor $packages_winman $packages_ui $packages_remote $packages_debugging $packages_desktop_extended $packages_yummy $packages_system $packages_development
