# `jwhich wine` /mnt/filfirin/joey/code/c/gfx/sdl/transtri/transtri.exe

# `jwhich xterm` -e testallfonts

# xvidtune&

# Keyboard
# xmodmap /stuff/portablelinux/etc/X11/Xmodmap.hwiDeb &

# `jwhich xterm`  +sb -sl 5000 -vb -si -sk -bg black -fg white -font '-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv' -geometry 80x25+0+500 $* &
xterm -geometry 80x24+583+700 &

# inwheel --wheel-fifo

# Grab xterm/vim colours before anything else does (for 256 color modes):
# xterm -e vim -R $JPATH/code/java/net/email/SMTPprotocol.java & # > ~/nedit.startup.txt &
# ( sleep 9 &&
#   killchild $$ "\"xterm -e vim\"" ) &
# asmix &
# ( sleep 20 &&
  # killchild $$ asmix ) &

# This file likes to cause me problems:
del .gnome/session

Panel=true;
# Lets get some kind of window manager starting!
# gnome-session
# WinMan=`echo "wmaker sawmill" | tr " " "\n" | chooserandomline`
# WinMan="sawmill"
# WinMan="fvwm"
# WinMan="twm"
# WinMan="fvwm2"
# WinMan="ratpoison"
# WinMan="blackbox" # KDE-compliant
# My favourites:
# WinMan="startkde"; Panel=;
# WinMan="icewm" # Gnome-compliant
# WinMan="ion"
# WinMan="pwm"
WinMan="fluxbox" # KDE-compliant
# WinMan="wmaker"
# WinMan="sawfish"

# Start all the stuff I like
(

	sleep 2
	# xsetroot -grey -bg darkgreen -fg black
	# xsetroot -mod 16 16 -fg darkgreen -bg black
	for X in `seq -w 0 1 80`; do Y=$((80-$X)); xsetroot -mod 16 16 -fg "#$Y"80"$Y" -bg "#"$Y$Y$Y; done

	# Background
	# randomwallpaper &
	# ( env DISPLAY= xplanet -output $JPATH/background.jpg -projection orthographic -body Earth -blend -geometry 1024x768 &&
	#   xv -root -rmode 5 -maxpect -quit $JPATH/background.jpg )
	( 
		sleep 4
		jxplanet makeicon /stuff/portablelinux/images/xplanet.gif
		nice -n 10 jxplanet render
	) &

	# xhost +

	# Disable bell
	# xset -b
	# ( sleep 10s; xset fp+ unix/:7101 ) &

	# Maybe this was only needed for 256 colour modes?
	# aumix -v 40



	browse $JPATH/org/jumpgate.html
	# kfmclient openProfile startbrowsing &

	# netscape -messenger &



	xscreensaver &

) &


if test $Panel; then

	# Start window manager in background.
	$WinMan ||
		`jwhich xterm` -title "--- wm $WinMan died ---" &

	# Start Gnome panel in the foreground.
	# On logout from the panel, the X session will quit.

	# Check if panel already running.
	SEEK=`findjob panel`
	# How strange: this test only works without spaces around the =
	if test ! "$SEEK"=""; then
		`jwhich xterm` -bg darkred -fg white -title "--- [master] panel already running ---"
	else
		# Start panel; present xterm if panel fails.
		panel ||
			`jwhich xterm` -bg darkred -fg white -title "--- [master] panel died ---"
	fi

else

	# Start window manager in the foreground.
	NEXTWMFILE="$JPATH/data/nextwinman.dat"
	CURRENTWMFILE="$JPATH/data/currentwinman.dat"
	echo "$WinMan" > "$NEXTWMFILE"

	while test -f "$NEXTWMFILE"; do

		WinMan=`cat "$NEXTWMFILE"`
		mv -f "$NEXTWMFILE" "$CURRENTWMFILE"

		$WinMan ||
			`jwhich xterm` -bg darkred -fg white -title "--- [master] wm $WinMan died ---"

	done

fi


# Even if the panel isn't started, this script will wait for window maker (or whatever else is running) before quitting.
# Nah this is naff cos it waits for xscreensaver and all other apps to close.
# wait

echo "X session ended."
