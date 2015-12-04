# For automated installation, pass -yq

packages_editor="vim-gtk exuberant-ctags"
packages_winman="xfonts-75dpi xfonts-100dpi fluxbox xscreensaver xscreensaver-data-extra imagemagick"
# xloadimage - used to provide xsetbg for randomwallpaper/jxsetbg but now it can use fbsetbg
packages_ui="geeqie gkrellm"
packages_remote="openssh-server screen xtightvncviewer x11vnc tightvncserver tmux"

#packages_winman="xfstt"   # To get LucidaConsole in GVim!  (See ~/FONTS folder)
packages_debugging="iotop atop nmap wireshark mesa-utils lm-sensors"
packages_desktop_extended="mplayer gimp inkscape dict-wn zsh wmctrl xdotool xosd-bin"
# Ubuntu recommends installing mailtools in order to get the 'mail' command.
# It installs postfix.
#packages_desktop_extended="$packages_desktop_extended mailtools"
# But I prefer exim!
# Both postfix and exim open a dpkg config dialog.
packages_desktop_extended="$packages_desktop_extended exim4"
# Extended audio
packages_to_install="$packages_to_install mp3gain vorbisgain" # For randommp3
packages_to_install="$packages_to_install mpg123" # In case mplayer is not available
packages_to_install="$packages_to_install lame mp3info" # For reencoding to mp3
# bladeenc 
# For reencode_video_to_x264:
packages_to_install="$packages_to_install faac gpac x264 mencoder"
# libreoffice compizconfig-settings-manager 
packages_yummy="hugs"   # ghc is also nice, but 290meg!

packages_system="cpufrequtils"

packages_development="git-core ccache sshfs encfs unison lftp" # 'git-core' is transitioning to 'git'

packages_packaging="aptitude dpkg-repack alien fakeroot"

# You never know when you might need this
#packages_to_install="$packages_to_install dosbox"

# Color pickers, to conveniently pick colors from off the screen.
#packages_to_install="$packages_to_install gpick gcolor2"

#packages_demodev="ocaml-nox liblz4-tool menhir ocamldsort"

# festival festvox-rablpc16k


# Favourites but not essentials

packages_deps="curl" # Needed by scdl (soundcloud download)

packages_io="mtpfs" # Mount Android device over USB

packages_av_creation="mencoder"



add_repository() {
	local ppa_repo="$1"
	. /etc/lsb-release
	local apt_sources_file="$(echo "${ppa_repo}" | tr '/.' '-_')-${DISTRIB_CODENAME}.list"
	local apt_sources_path="/etc/apt/sources.list.d/${apt_sources_file}"
	if [ -f "$apt_sources_path" ]
	then
		echo "### We already have ppa:$ppa_repo"
	else
		echo "### Installing $ppa_repo to $apt_sources_path"
		sudo add-apt-repository ppa:"$ppa_repo"
		added_repo=1
	fi
}

add_repository gwendal-lebihan-dev/hexchat-stable
packages_to_install="$packages_to_install hexchat"

# Install NodeJS 0.10
# Alternative methods can be found here: https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
# To install io.js, look here: https://nodesource.com/blog/nodejs-v012-iojs-and-the-nodesource-linux-repositories
add_repository chris-lea/node.js
packages_development="$packages_development nodejs"

#install_scala_build_tool=true
if [ -n "$install_scala_build_tool" ]
then
	if [ ! -f "/etc/apt/sources.list.d/sbt.list" ]
	then
		echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
		added_repo=1
	fi
	packages_development="$packages_development sbt"
fi

#add_repository saltstack/salt
#packages_deployment="salt-master python-software-properties"

install_latest_mongodb=true
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
	packages_to_install="$packages_to_install mongodb-org"
	# Note that the mongo package in Ubuntu's repository is called 'mongodb' not 'mongodb-org'
	# On Ubuntu I had these installed: mongodb mongodb-clients mongodb-dev mongodb-server
	# Not sure what brought them in!  ;)
	# After removing them, they left behind /var/lib/mongodb and /var/log/mongodb
	# The mongo repo installs: mongodb-org mongodb-org-mongos mongodb-org-server mongodb-org-shell mongodb-org-tools
	# Last time I installed, they gave me version 3.0.6
fi



# === Less crucial ===

# shellcheck
# msttcorefonts
# texlive-fonts-recommended

# xbacklight
# sudo add-apt-repository ppa:indicator-brightness/ppa
# indicator-brightness
# sudo add-apt-repository ppa:kamalmostafa/linux-kamal-mjgbacklight



[ -n "$added_repo" ] && sudo apt-get update

sudo apt-get -V install $packages_to_install $packages_editor $packages_winman $packages_ui $packages_remote $packages_debugging $packages_desktop_extended $packages_yummy $packages_system $packages_development $packages_deployment $packages_deps $packages_io $packages_av_creation $packages_packaging "$@"

#grep --line-buffered -v "is already the newest version.$"

# Unfortunately if we use grep, the "Do you want to continue [Y/n]?" will not be displayed, because no newline is sent!

