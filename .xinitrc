### For Vnc:
if test "$VNCDESKTOP" = "X"
then
	xterm &
	# fluxbox &
	wmaker &
	## To speed up the volume control scripts when invoked from bbkeys:
	## (should it go in a bbkeys.sh wrapper?)
	. importshfn volumeup volumedown after before
	bbkeys -i &
	# sleep 10
	# wmmixer -w &
	# asmix -withdrawn &
	# `jwhich panel` &
	## Unlike X, and despite the exit 1, Xvnc keeps running when this script exits!
	exit 1
	# vncserver -kill $DISPLAY
fi

### Configuration

export GNOME_PANEL=true;
## Lets get some kind of window manager starting!
# gnome-session
# WinMan=`echo "wmaker sawmill" | tr " " "\n" | chooserandomline`
# WinMan="sawmill"
# WinMan="fvwm"
# WinMan="twm"
# WinMan="fvwm2"
# WinMan="ratpoison"
# WinMan="blackbox" ## KDE-compliant
## My favourites:
# WinMan="startkde"; export GNOME_PANEL=; export QT_TT=true;
# WinMan="icewm" ## Gnome-compliant
# WinMan="ion"
# WinMan="pwm"
WinMan="fluxbox" ## can be "Gnome-compliant", can be KDE-compliant
# WinMan="wmaker"
# WinMan="sawfish"

### For all instances except first:
echo "DISPLAY = $DISPLAY"
if test ! "$DISPLAY" = ":0" && test ! "$DISPLAY" = ":0.0"
then
	bbkeys -i &
	GNOME_PANEL=
	WinMan=startkde
fi





### Start all the stuff I like in the background

## From fluxbox's xinitrc howto:
# turn off screen blanking and turn on energy star features
xset s off
xset dpms 3600 3600 3600

# Got problems with []s
# xset fp- unix/:7100

[ -f /usr/lib/libgdkxft.so ] && export LD_PRELOAD=$LD_PRELOAD:/usr/lib/libgdkxft.so

(
	## Keyboard
	# xmodmap /stuff/portablelinux/etc/X11/Xmodmap.hwiDeb &

	xterm -geometry 80x24+570+680 &

	## This file likes to cause me problems:
	del .gnome/session

	## Start Gnome panel
	if [ $GNOME_PANEL ]
	then
		## Increased from 5 to 10 because gnomeICU and xmms-applet were failing to show their visuals.
		( sleep 10s && panel ) &
	fi

	## Allow connections to X display from anywhere
	# xhost +

	## Disable bell
	xset -b
	## Increase keyboard rate
	# xset r rate 400 50
	xset r rate 270 65
	# xset r rate 280 90

	browse $JPATH/org/jumpgate.html
	# evolution &
	# kfmclient openProfile startbrowsing &
	# netscape -messenger &

	xscreensaver &

	sleep 4
	## Background
	# xsetroot -grey -bg darkgreen -fg black
	for X in `seq -w 0 1 80`
	do
		Y=`expr 80 - $X`
		xsetroot -mod 16 16 -fg "#$Y"80"$Y" -bg "#"$Y$Y$Y
	done
	# randomwallpaper &
	# xv -root -rmode 5 -maxpect -quit /stuff/wallpapers/abstract/mosaic.jpg
	xv -root -rmode 5 -maxpect -quit /stuff/wallpapers/abstract/mindflow.jpg
	# ( 
		# sleep 480
		# jxplanet makeicon /stuff/portablelinux/images/xplanet.gif
		# nice -n 10 jxplanet render
	# ) &

) &



### Start window manager in the foreground.

date
echo "Starting window manager."

# NEXTWMFILE=`jgettmp nextwinman`
# CURRENTWMFILE=`jgettmp currentwinman`
NEXTWMFILE=$JPATH/data/nextwinman.dat
CURRENTWMFILE=$JPATH/data/currentwinman.dat
echo "$WinMan" > $NEXTWMFILE

while test -f $NEXTWMFILE; do

	WinMan=`cat $NEXTWMFILE`
	mv -f $NEXTWMFILE $CURRENTWMFILE

	$WinMan ||
		`jwhich xterm` -bg darkred -fg white -title "--- [master] wm $WinMan died ---"

done

echo "X session ended."

