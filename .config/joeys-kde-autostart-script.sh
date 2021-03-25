#!/bin/bash

# Sets up PATH
# Also loads run_if_window_matches and other scripts used by sxhkd
. "$HOME"/j/startj-simple

sxhkd > /tmp/sxhkd.$USER.out 2>&1 &

# Disable shadow on KDE/Plasma panel
(
    sleep 15
    for WID in `xwininfo -root -tree | sed '/"Plasma": ("plasmashell" "plasmashell")/!d; s/^  *\([^ ]*\) .*/\1/g'`
    do xprop -id $WID -remove _KDE_NET_WM_SHADOW
    done
) &

# Applications I always want to have running

# This is one of the apps that KDE restored automatically, so we don't need to start it here
# Same for Firefox, all the terminals, etc.
#gkrellm &

# But for some reason these apps are not automatically restored, so we do need to start them explicitly
#
# Note: You may need to add Special Application Settings, so that these start on the desired desktop
(
    sleep 30

    #google-chrome &
    #sleep 60

    code &
    sleep 20
) &

