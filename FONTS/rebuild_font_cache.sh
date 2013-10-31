# What I have done here may be overkill, but something in here works!
# See: http://www.proggyfonts.com/XWindowsFontInstall.txt

# After running all of these, Ubuntu crashes if I do:
#   xfontsel -scaled
# which is not good.

# However, when I restarted X, xfontsel no longer caused a crash, BUT the
# 'Lucida Console' offered by GVim was magically now as I wanted it!
# This *might* be related to lucon.ttf which I dropped in
# /usr/share/fonts/truetype ?
# On the down-side, the font now used for Gnome and Chromium GUI sucks a
# little!  (It too is a screen font, but I prefer AA font for that!)

# OK forget the above.  It seems I need to start X separately from lightdm,
# i.e. do startx from a console login.  I am not sure if running this rehash
# and whatnot beforehand is really needed.
#
# Then I get it looking nice in my new X, but still naff in :0
# xdpyinfo and xset q and xrand --verbose show no major differences!
# So I have no idea what is causing this to work!  :P
#
# FWIW this is what vim needs:
#    :set guifont=Lucida\ Console\ Semi-Condensed\ 8
# If I (re)move lucon.ttf then it will fail in both (after restarting gvim).
# The strange thing is that it works in both, but has a different size in :0
# Not the size I want.
#
# Worth noting on :2 where it works, other things don't work, e.g. jmanpopup
# chooses a naff font.  I thought that was lucidatypewriter failing to load,
# but it works OK when I try by hand.  It seems more than .Xresources is being
# ignored.  Hmmm...  Loading it manually with xrdb fixes the font, although not
# the colours...

xset fp- unix/:7101
xset fp rehash

sudo fc-cache -fv
fc-cache -fv

sudo /etc/init.d/xfstt force-reload
sleep 3

xset fp+ unix/:7101
xset fp rehash

echo
FCLISTCOUNT=`fc-list | wc -l`
XFSCOUNT=`fslsfonts -server unix/:7101 | wc -l`
# This one crashes Ubuntu:
#XLSCOUNT=`xlsfonts | wc -l`
echo "fc-list reports $FCLISTCOUNT fonts, xlsfonts reports $XLSCOUNT, fslsfonts (xfs) reports $XFSCOUNT."

