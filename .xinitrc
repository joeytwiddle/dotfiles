### Config:

unset COLUMNS

if ! [ "$JPATH" ]
then
	export JPATH=/home/joey/j
	. $JPATH/startj
fi

if [ -d $HOME/X11_big_cursor ]
then
	xset fp+ $HOME/X11_big_cursor
	xset fp rehash
	xsetroot -cursor_name X_cursor
fi

## Put your favourite WMs at the top.  The first one present will be chosen.
WindowManagers="
startkde
enlightenment
fluxbox
wmaker
WindowMaker
blackbox
icewm
gnome-session
metacity
sawfish
sawmill
pwm
ion
ratpoison
fvwm2
twm
fvwm
"

if [ ! "$RUNNING_GENTOO" ]
then
	if uname -r | grep "gentoo" >/dev/null 2>&1
	then export RUNNING_GENTOO=1
	else export RUNNING_GENTOO=0
	fi
fi

if [ "$RUNNING_GENTOO" ] && [ "$DISPLAY" = :0 ]
then WindowManagers="startkde
$WindowManagers"
fi

Xnest -install -depth 8 :5 &

## Find the first working WM:
for WinMan in $WindowManagers
do
	if which "$WinMan"
	then
		echo "Found ok: $WinMan"
		break
	fi
done

## Alter config if we are running Vnc:
## But isn't this usually ~/.vnc/xstartup?
if [ "$VNCDESKTOP" = "X" ]
then
	# xsetroot -grey -bg darkgreen -fg black
	## Guaranteed to not be dithered:!
	xsetroot -grey -bg black -fg black
	xterm &
	# fluxbox &
	wmaker &
	bbkeys -i &
	## Unlike X, and despite the exit 1, Xvnc keeps running when this script exits!
	exit 1
	# vncserver -kill $DISPLAY
fi

## Alter config based on display number:
if [ "$DISPLAY" = ":0" ]
then START_A_PANEL=true
elif [ "$DISPLAY" = ":1" ] || [ "$DISPLAY" = ":2" ]
then WinMan=WindowMaker
elif [ "$DISPLAY" = ":3" ]
then WinMan=startkde
fi

## Disable panel for WM's which have their own / conflict with Gnome's:
if [ "$WinMan" = startkde ]
then
	export START_A_PANEL=
	export QT_TT=true;
fi



### Config X, and start all my favourite apps:

## Give the user something to play with:
xterm -geometry 80x24+570+680 &

## Animated intro, and set background:
(
	# xsetroot -grey -bg darkgreen -fg black
	for X in `seq -w 0 1 80`
	do
		Y=`expr 80 - $X`
		xsetroot -mod 16 16 -fg "#$Y"80"$Y" -bg "#"$Y$Y$Y
	done
	# randomwallpaper &
	# xv -root -rmode 5 -maxpect -quit /stuff/wallpapers/abstract/mosaic.jpg
	xv -root -rmode 5 -maxpect -quit /stuff/wallpapers/abstract/mindflow.jpg
	# jxplanet makeicon /stuff/portablelinux/images/xplanet.gif
	# nice -n 10 jxplanet render
	# ) &
) &

## From fluxbox's xinitrc howto:
# turn off screen blanking
xset s off
## Turn on energy star features (monitor still goes blank but wakes up for mplayer =) except under kde :-(
if echo "$WinMan" | grep kde
then xset -dpms
else xset dpms 3600 3600 3600
fi
## Disable bell
xset -b
## Increase keyboard rate
# xset r rate 400 50
xset r rate 270 65
# xset r rate 280 90

## Got problems with []s
# xset fp- unix/:7100

## Allow connections to X display from anywhere
# xhost +

# [ -f /usr/lib/libgdkxft.so ] && export LD_PRELOAD=$LD_PRELOAD:/usr/lib/libgdkxft.so

## Keyboard
# xmodmap /stuff/portablelinux/etc/X11/Xmodmap.hwiDeb &

## Loading of other apps is forked so that we can get down and start the WM.
## It is gives 5 seconds before the apps start loading.

(

	sleep 5

	if [ ! "$WinMan" = fluxbox ]
	then bbkeys -i &
	fi

	if [ -x $HOME/bin/imwheel ]
	then xterm -e $HOME/bin/imwheel -d &
	fi

	## Start Gnome panel?
	if [ "$START_A_PANEL" ]
	then
		## This file likes to cause me problems:
		# del .gnome/session
		## Increased from 5 to 10 because gnomeICU and xmms-applet were failing to show their visuals.
		## Needs to wait for window manager to start (enlightenment):
		# panel &
		kicker &
	fi

	if [ "$DISPLAY" = ":0" ]
	then

		## Start other things slowly, because the Gnome2 panel takes so long!
			## This appears to be hanging my machine again, and I don't think it's even running any GL!
			## If you dare to test it again, don't test in both Gentoo and Debian chroot at the same time!
			# sleep 10
			# xscreensaver &
			sleep 10
			/opt/ymessenger/bin/ymessenger & # Yahoo! Messenger
			gnomeicu &
			sleep 10
			HOMEPAGE="$JPATH/org/jumpgate.html"
			if [ -f "$HOMEPAGE" ]
			then HOMEPAGE="file://$HOMEPAGE"
			else HOMEPAGE="http://neuralyte.org/~joey/jumpgate.html"
			fi
			browse "$HOMEPAGE" &
			# evolution &
			# netscape -messenger &
			# wmmixer -w & # 1214x487
			# asmix -withdrawn & # 1230x568
			wmmixer &
			asmix &

	fi

) &



### Start window manager in the foreground.

date
echo "Starting window manager: $WinMan"

if [ ! "$JPATH" ]
then export JPATH=/tmp/
fi
mkdir -p "$JPATH/data"
# NEXTWMFILE=`jgettmp nextwinman`
# CURRENTWMFILE=`jgettmp currentwinman`
NEXTWMFILE=$HOME/.nextwinman.$DISPLAY.dat
CURRENTWMFILE=$HOME/.currentwinman.$DISPLAY.dat
echo "$WinMan" > $NEXTWMFILE

while [ -f $NEXTWMFILE ]
do

	WinMan=`cat $NEXTWMFILE`
	mv -f $NEXTWMFILE $CURRENTWMFILE

	$WinMan ||
		`jwhich xterm` -bg darkred -fg white -title "--- [master] wm $WinMan died ---"

done

echo "X session ended."

