#!/bin/bash

# TODO: This needs to be split into two files:
#   - One of which is the universal WM chooser (unfinished).  (It has two goals: to allow user to choose WM when WM crashes/closes, and also to prevent X from closing, with all its apps, just because WM closed!)
#   - The other, joey's personal X bootup requirements.

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

## Why didn't I put startlxde first?  It gives me a load of horizontal desktops instead of a set.  It doesn't put kicker on all desktops.  It ignored Alt-Shift-Direction-Alt-X if I don't let go of Alt!
## I run fluxbox to start with, but if stuff gets heavy, I will switch to LXDE.
## Fluxbox sets 3x4 desktops and makes kicker sticky.
## Note: Since startlxde changes mouse+keyboard settings, I have to run xinitrc again afterwards!

## Put your favourite WMs at the top.  The first one present will be chosen.
## kdelight runs the KDE3 panel 'kicker' but currently with fluxbox instead of kwin.
WindowManagers="
/usr/local/fluxbox.git/bin/startfluxbox
fluxbox
startlxde
compiz
kdelight
startkde
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
openbox
"

# If you want second desktops to run a different manager on other desktops created (e.g. :2 or
# vnc servers), set this variable:
WindowManagerForSecondDesktops=fluxbox

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

## Use a minimal window manager on second/third/... X sessions.
if [ ! -z "$WindowManagerForSecondDesktops" ] && [ ! "$DISPLAY" = ":0" ] && [ ! "$DISPLAY" = ":0.0" ]
then WindowManagers="${WindowManagerForSecondDesktops}${NEWLINE}${WindowManagers}"
fi

## Or alter config based on display number in other ways.
START_A_PANEL=true
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

## For some reason when I upgraded my nvidia whatnots, it changed my DPI (or at least, all the text sizes changed!):
## % xdpyinfo | grep dots
##   resolution:    130x131 dots per inch
## So before we start a window manager, I need to fix my broken DPI.

## I have set a larger virtual size in xorg.conf but I don't really want it!

# xrandr -s 1024x768
# xrandr --dpi 80x75
# xrandr --dpi 74x75

# xrandr -s 1280x1024
# xrandr --dpi 92x100   # Starts gvim in smaller font, so not what I had before!
# xrandr --dpi 100x100  # I *think* this made konq font smaller than expected?
# xrandr --dpi 96x100
# xrandr --dpi 96x96
# xrandr --dpi 100x96     # Causes GVim font sizes to appear how they used to.  (100xanything works too)
# xrandr --dpi 120x100  # Nice square GVim
# xrandr --dpi 100x80   # Nice square GVim
# xrandr --dpi 120x100
## None of the above change the aspect ratio of Lucida in gvim, although large
## values can affect the overall font size.
## The following reading never changes:
##     % xdpyinfo | grep -C2 "dots per inch"

## NOTE: If you don't have xrandr, but need to set DPI, a workaround is:
# echo "Xft.dpi: 96" >> ~/.Xdefaults or ~/.Xresources
# xrdb -merge ~/.Xdefaults
## OR:
# echo "Xft.dpi: 96" | xrdb -merge

## I think you can disable auto-DPI config in xorg.conf Device section with:
# Option "NoDDC"
## (Then I think it gets derived from the ModeLine.)

## TESTING: may work faster from bbkeys or fluxkeys if pre-loaded
##          this technique might only work if we . fluxbox, and probably not even then :P
## The actual issue is that using put_current_xwindow from a keybind is sometimes very slow (I hear swap humming) but that could be part of X, rather than loading the script itself?
## So alternatively, we could move the scripts to /dev/shm/ and put it on the PATH?!
# . importshfn "$JPATH"/tools/put_current_xwindow
## These days I have a sylink in ~/bin/put_current_xwindow.  I think this works fast because it avoids having to search $JPATH/tools

## Disabled
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
## Animated intro, and/or set background:
(


	animatedIntro=1
	if [ -n "$animatedIntro" ]
	then

		xsetroot -mod 16 16 -fg "#808080" -bg "#808080"
		## Give the wm a chance to start first!  Otherwise it makes our animation jitter.
		sleep 2
		## Fade from mid-grey to a green-on-black grid
		animDelay=0.01
		for HI in `seq 7 -1 0`
		do
			# for LO in f e d c b a `seq 9 -1 0`
			for LO in e c a `seq 8 -2 0`
			do
				X="$HI$LO"
				xsetroot -mod 16 16 -fg "#$X"80"$X" -bg "#$X$X$X"
				sleep $animDelay
			done
		done

		## then from green-on-black grid down to black
		for HI in `seq 7 -1 0`
		do
			for LO in e c a `seq 8 -2 0`
			do
				X="$HI$LO"
				xsetroot -mod 16 16 -fg "#00"$X"00" -bg "#000000"
				sleep $animDelay
			done
		done
		xsetroot -solid black
		jshinfo "[.xinitrc] Finished background grid animation."

	else
		xsetroot -solid black
	fi

	## Delay because without animation randomwallpaper is heavy and delays wm startup.
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
## This is fun for scrolling:
# xset r rate 270 99
## But to actually stop in the right place, we need something smaller:
xset r rate 270 65

## Mouse acceleration
## <acceleration> (scalar) <threshold> (pixels per update)
## For more action, increase the former, or reduce the latter
# xset m 2/3
# xset m 2/3 3
# xset m 4/5 3
# Save wrists with fast acceleration
# xset m 12/5 10
# Even faster:
xset m 20/5 5

## Got problems with characters displaying as squares [] ?
xset fp- unix/:7100     ## xfstt on ubuntu
# xset fp+ unix/:7101   ## xfstt

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

	# if [ ! "$WinMan" = fluxbox ] && [ -x /usr/bin/bbkeys ]
	# then bbkeys &
	# fi
	## Yes it's overkill for Fluxbox, but I tend to switch out of Fluxbox these days!
	bbkeys&

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
		# kicker &
		/opt/trinity/bin/kicker &
	fi

	# More of Joey's preferences:

	# gnome-settings-daemon &

	if [ "$HOSTNAME" = hwi ]
	then
		# xgamma -rgamma 0.7 -ggamma 1.0 -bgamma 1.0 ## for Tim's red-ish monitor
		# xgamma -rgamma 0.8 -ggamma 1.2 -bgamma 1.2 ## for Tim's red-ish monitor
		## OK so first I adjust the monitor's settings to get pure white, then I apply xgamma to fix greys.
		# xgamma -rgamma 1.0 -ggamma 1.4 -bgamma 1.4 ## Brighter so I can read my greys!
		# xgamma -rgamma 1.1 -ggamma 1.4 -bgamma 1.3 ## When the bloody thing goes darker and bluer!
		## Are they accumulating?!
		# xgamma -rgamma 1.8 -ggamma 2.0 -bgamma 2.0   dark
		# xgamma -rgamma 2 -ggamma 2.5 -bgamma 2.5   bright
		# xgamma -rgamma 2 -ggamma 2.2 -bgamma 2.2   ok/light
		xgamma -rgamma 1.2 -ggamma 1.6 -bgamma 1.6
	fi

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

	sleep 6
	gkrellm &

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

