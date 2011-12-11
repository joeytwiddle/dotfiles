#!/bin/bash

### Start jsh if possible {{{
## This is only actually needed for jshinfo and kdelight below.
## But I like to have jsh loaded in the environment before my window manager
## spawns new shells
if ! [ "$JPATH" ]
then
	for JPATH in $HOME/j $HOME/jsh /usr/local/jsh /home/joey/j /home/joey/jsh NOT_FOUND
	do
		if [ -e $JPATH/startj ]
		then
			echo "[.xinitrc] Loading jsh ..." >&2
			export JPATH
			. $JPATH/startj
			break
		fi
	done
	if [ "$JPATH" = NOT_FOUND ]
	then
		echo "[.xinitrc] Could not load jsh =(" >&2
		## NOTE BUG: This is not valid sh - bash run as sh will reject it!
		function jshinfo () {
			echo "$@" >&2
		}
		## Would which even pick up the function?
		## Better to leave it non-existent so another wm will be chosen.
		# function kdelight () {
			# startkde
		# }
	fi
fi
### }}}



## Log our output by calling self back
## There is a better way than this probably on BashFAQ :P
logFile="$HOME/.xinitrc-$DISPLAY.log"
if [ "$1" = -fg ]
then shift
else
	echo "Calling $0 loopback and logging to $logFile"
	bash "$0" -fg "$@" > "$logFile" 2>&1
	exit
fi




### Popup execution of this script in an xterm (so user can see its output) {{{

## For some reason this breaks when we are called from xdm/gdm.
# Oh it's when fluxbox crashes, this doesn't leave an xterm running, it quits and doesn't give me the chance to start a new one.  We should loop.
# Or perhaps it was just xterm backgrounding - we should use /usr/bin/xterm..
# XINIT_POPUP_LOG=true

if [ "$XINIT_POPUP_LOG" ]
then

	if ! [ "$1" = -1 ] && ! [ "$1" = -2 ]
	then

		jshinfo "Calling: xterm -sl 1000 -bg black -fg green -e sh \"$0\" -1"
		if which gnome-terminal >/dev/null 2>&1
		then
			gnome-terminal
		else
			xterm -sl 1000 -bg black -fg green -e sh "$0" -1
		fi	
		cat /tmp/xinitrc-popup-log.out
		exit

	fi

	if [ "$1" = -1 ]
	then

		jshinfo "Calling: \"$0\" -2 | tee /tmp/xinitrc-popup-log.out 2>&1"
		"$0" -2 | tee /tmp/xinitrc-popup-log.out 2>&1
		exit

	fi

fi

## For set -x logging:
PS4="[.xinitrc] # $PS4"

### }}}



### Config: {{{

## Put your favourite WMs at the top.  The first one present will be chosen.
## TESTING kdelight again
WindowManagers="
kdelight
compiz
startkde
fluxbox
enlightenment
WindowMaker
wmaker
icewm
gnome-session
sawfish
sawmill
blackbox
metacity
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
	else export RUNNING_GENTOO=
	fi
fi

# if [ "$RUNNING_GENTOO" ] && ( [ "$DISPLAY" = :0 ] || [ "$DISPLAY" = :0.0 ] )
# then
# WindowManagers="kdelight
# startkde
# fluxbox
# $WindowManagers"
# fi

NEWLINE="
"
## Alter config based on display number:
# if [ "$DISPLAY" = ":0" ] || [ "$DISPLAY" = :0.0 ]
# then START_A_PANEL=true
# elif [ "$DISPLAY" = ":1" ]
# then : # WindowManagers="compiz""$NEWLINE""$WindowManagers"
# elif [ "$DISPLAY" = ":1" ] || [ "$DISPLAY" = ":2" ] || [ "$DISPLAY" = :1.0 ] || [ "$DISPLAY" = :2.0 ]
# then WindowManagers="fluxbox""$NEWLINE""WindowMaker""$NEWLINE""$WindowManagers"
# elif [ "$DISPLAY" = ":3" ]
# then WindowManagers="startkde""$NEWLINE""$WindowManagers"
# fi

## Find the first existing WM:
for WinMan in $WindowManagers
do
	[ "$WinMan" = compiz ] && [ "$RUNNING_GENTOO" = 1 ] && WinMan="compiz-manager" ## For Gentoo.  Actually it may be Debian that is the odd one using "compiz".  :P
	if which "$WinMan"
	then
		echo "Found ok: $WinMan"
		break
	fi
done

## Disable panel for WM's which have their own / conflict with Gnome's:
if [ "$WinMan" = startkde ]
then
	export START_A_PANEL=
	# export QT_TT=true;
fi



### Config X, and start all my favourite apps:

# Xnest -install -depth 8 :5 &

jshinfo "[.xinitrc] Initialising with DISPLAY=$DISPLAY"

cat $HOME/.my_x_settings | grep -v "^#" | xrdb -merge

## Fix my broken keymap:
setxkbmap -print gb | xkbcomp - "$DISPLAY"

unset COLUMNS

## I have set a larger virtual size in xorg.conf but I don't want it!
# xrandr -s 1024x768
xrandr -s 1280x1024

## TESTING: may work faster from bbkeys or fluxkeys if pre-loaded
##          this technique might only work if we . fluxbox, and probably not even then :P
## The actual issue is that using put_current_xwindow from a keybind is sometimes very slow (I hear swap humming) but that could be part of X, rather than loading the script itself?
## So alternatively, we could move the scripts to /dev/shm/ and put it on the PATH?!
. importshfn "$JPATH"/tools/put_current_xwindow

if [ -d $HOME/X11_big_cursor ] && false
then
	jshinfo "Initialising big cursor."
	xset fp+ $HOME/X11_big_cursor
	xset fp rehash
	xsetroot -cursor_name X_cursor
fi

## Alter config if we are running Vnc:
## But isn't this usually ~/.vnc/xstartup?
if [ "$VNCDESKTOP" = "X" ]
then
	# xsetroot -grey -bg darkgreen -fg black
	## Guaranteed to not be dithered:!
	xsetroot -grey -bg black -fg black
	xterm &
	# fluxbox &
	# wmaker &
	# twm &
	# ion &
	fluxbox &
	bbkeys &
	## Unlike X, and despite the exit 1, Xvnc keeps running when this script exits!
	exit 1
	# vncserver -kill $DISPLAY
fi

## Give the user something to play with:
xterm -geometry 80x24+570+680 &

# set +x
## Animated intro, and set background:
(

	xsetroot -solid black
	# xsetroot -grey -bg darkgreen -fg black
	# for X in `seq -w 0 1 80`
	# do
		# Y=`expr 80 - $X`
		# xsetroot -mod 16 16 -fg "#$Y"80"$Y" -bg "#"$Y$Y$Y
	# done
	# for X in `seq -w 0 1 8`
	# do
		# Y=`expr 8 - $X`
		# xsetroot -mod 16 16 -fg "#$Y$Y"88"$Y$Y" -bg "#"$Y$Y$Y$Y$Y$Y
		# sleep 1
	# done
	## Still appears to flicker, but I blame that on 16bpp!
	# xsetroot -mod 16 16 -fg "#888888" -bg "#888888"
	# for HI in `seq 7 -1 0`
	# do
		# # for LO in f e d c b a `seq 9 -1 0`
		# for LO in c `seq 8 -4 0`
		# do
			# X="$HI$LO"
			# xsetroot -mod 16 16 -fg "#$X"88"$X" -bg "#$X$X$X"
			# sleep 0.01
		# done
	# done
	# jshinfo "[.xinitrc] Finished background grid animation."

	( sleep 2 ; nice -n 15 randomwallpaper ) &
	# xv -root -rmode 5 -maxpect -quit /stuff/wallpapers/abstract/mosaic.jpg
	# xv -root -rmode 5 -maxpect -quit /stuff/wallpapers/abstract/mindflow.jpg
	# jxsetbg /stuff/wallpapers/abstract/mindflow.jpg
	# jxplanet makeicon /stuff/portablelinux/images/xplanet.gif
	# nice -n 10 jxplanet render
	## I sleep because something (probably kdelight) sets a boring default bg.  [Maybe not kdelight because the behaviour was different from startkde: it didn't refresh the bg/root on desktop switches)
	# sleep 20
	## I sleep some more to let kwin + konqueror to start, before building the image db
	## I've diabled it now; only run by hand.
	# sleep 60
	# randomwallpaper

) &

# set -x

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
# xset r rate 280 90
# xset r rate 270 65
xset r rate 270 99
## For my over-sensitive mouse:
# xset m 2/3
# xset m 2/3 3
xset m 4/5 3

## Got problems with characters displaying as squares [] ?
# xset fp- unix/:7100
xset fp+ unix/:7101   ## xfstt

## Allow connections to X display from anywhere
# xhost +

# [ -f /usr/lib/libgdkxft.so ] && export LD_PRELOAD=$LD_PRELOAD:/usr/lib/libgdkxft.so

## Keyboard
# xmodmap /stuff/portablelinux/etc/X11/Xmodmap.hwiDeb &

## Loading of other apps is forked so that we can get down and start the WM.
## The wm is given 5 seconds before the apps start loading.

(

	# set -x

	sleep 2

	if [ ! "$WinMan" = fluxbox ] && [ -x /usr/bin/bbkeys ]
	then bbkeys &
	fi

	WSI="$JPATH/code/workspace_indicator.py"
	if [ "$WinMan" = ion ] && [ -x "$WSI" ]
	then "$WSI" &
	fi

	# if [ -x $HOME/bin/imwheel ]
	# then xterm -e $HOME/bin/imwheel -d &
	# fi

	## Start Gnome panel?
	if [ "$START_A_PANEL" ] && [ ! "$WinMan" = kdelight ] ## kdelight includes/ed kicker
	then
		## This file likes to cause me problems:
		# del .gnome/session
		## Increased sleep from 5 to 10 because gnomeICU and xmms-applet were failing to show their visuals.
		## Needs to wait for window manager to start (enlightenment):
		# panel &
		kicker &
	fi

	# gnome-settings-daemon &

	# xgamma -rgamma 0.7 -ggamma 1.0 -bgamma 1.0 ## for Tim's red-ish monitor
	# xgamma -rgamma 0.8 -ggamma 1.2 -bgamma 1.2 ## for Tim's red-ish monitor
	## OK so first I adjust the monitor's settings to get pure white, then I apply xgamma to fix greys.
	xgamma -rgamma 1.0 -ggamma 1.4 -bgamma 1.4 ## Brighter so I can read my greys!
	# xgamma -rgamma 1.1 -ggamma 1.4 -bgamma 1.3 ## When the bloody thing goes darker and bluer!
	## Are they accumulating?!
	# xgamma -rgamma 1.8 -ggamma 2.0 -bgamma 2.0   dark
	# xgamma -rgamma 2 -ggamma 2.5 -bgamma 2.5   bright
	# xgamma -rgamma 2 -ggamma 2.2 -bgamma 2.2   ok/light

	jshinfo "DISPLAY = $DISPLAY"

	# if [ "$DISPLAY" = ":0" ] || [ "$DISPLAY" = ":0.0" ]
	# then

		# sleep 20
		# gnome-font-properties &
		# GNOMEFP_PID="$!"

		## Start other things slowly, because the Gnome2 panel takes so long!
			## I *need* xscreensaver to turn off my monitor when idle, in case the other dpms methods don't work!
			## This appears to be hanging my machine again, and I don't think it's even running any GL!
			## If you dare to test it again, don't test in both Gentoo and Debian chroot at the same time!
			# sleep 2
			## FAIL (sees itself!): if ps aux | grep xscreensaver >/dev/null
			if pgrep xscreensaver >/dev/null
			then : ## Even with multiple displays, we don't want more than one xscreensaver gobbling up CPU.
			else xscreensaver -nosplash &
			fi

			# sleep 2
			# /opt/ymessenger/bin/ymessenger & # Yahoo! Messenger
			# sleep 2
			# # gaim &
			# gnomeicu &

			## I realised I wasn't using these mixers any more:
			# sleep 5
			# wmmixer &
			# asmix &
			# HOMEPAGE="$JPATH/org/jumpgate.html"
			# if [ -f "$HOMEPAGE" ]
			# then HOMEPAGE="file://$HOMEPAGE"
			# else HOMEPAGE="http://neuralyte.org/~joey/jumpgate.html"
			# fi
			# sleep 70 ## Allows kdelight to start before konqueror is launched
			# sleep 30 ## Less time needed now randomwallpaper is gone :)
			# browse "$HOMEPAGE" &
			# evolution &
			# netscape -messenger &
			# wmmixer -w & # 1214x487
			# asmix -withdrawn & # 1230x568

		# sleep 1
		# kill "$GNOMEFP_PID"

	# fi

) &

## Re-enable Ctrl+Alt+Backspace to close X, since Gentoo removed it.
setxkbmap -option terminate:ctrl_alt_bksp

### End Config. }}}



### Start window manager in the foreground. {{{

date
echo "Starting window manager: $WinMan"

# if [ ! "$JPATH" ]
# then export JPATH=/tmp/
# fi
# mkdir -p "$JPATH/data"
# NEXTWMFILE=`jgettmp nextwinman`
# CURRENTWMFILE=`jgettmp currentwinman`

NEXTWMFILE=$HOME/.nextwinman.$DISPLAY.dat
CURRENTWMFILE=$HOME/.currentwinman.$DISPLAY.dat

# if [ "$WinMan" = "compiz" ]
# then WinMan="compiz ccp"
# fi

$WinMan

## I had problems with my keyboard so I wanted the WinMan to actually exit when i closed it.
# fluxbox ; WindowMaker ; exit


# echo "$WinMan" > $NEXTWMFILE
echo "xterm -bg black -fg white -title window_manager_died" > $NEXTWMFILE

while [ -f $NEXTWMFILE ]
do

	WinMan=`cat $NEXTWMFILE`
	[ "$WinMan" ] && mv -f $NEXTWMFILE $CURRENTWMFILE || WinMan=fluxbox

	jshinfo "[.xinitrc] Starting window manager $WinMan..."

	$WinMan ||
		`jwhich xterm` -bg darkred -fg white -title "--- [master] wm $WinMan died ---" &

	jshinfo "[.xinitrc] Window manager $WinMan has died."

	## Allows user time to start their own WinMan if desired.
	sleep 2

done | tee .xinitrc.log

jshinfo "[.xinitrc] No $NEXTWMFILE found."
jshinfo "[.xinitrc] X session ended."

`jwhich xterm` -bg darkred -fg white -title "--- X session eneded. Press Ctrl+D to exit. ---"

wait

fluxbox --replace

### }}}

