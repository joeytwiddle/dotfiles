" ToggleMaximize v1.2.2 by joey.neuralyte.org
"
" Vim can support complex window layouts, but they can put users off because
" they reduce the size of the main editing window.  ToggleMaximize addresses
" this issue, by allowing the user to switch between a large editor window,
" and his own complex window layout.
"
" Press Ctrl-F or Ctrl-\ to maximize the size of the current window, press
" again to restore the original window layout.
"
" Ctrl-V and Ctrl-H toggle maximize in horizontal/vertical direction only.
"
" Maximization is forced to respect winminwidth and winminheight, so if you
" have these set, other windows will not fully shrink to the edges.
"
" Extra feature: If you mess up your layout and want to restore it to what you
" had the last time you maximized, you can :call RestoreLayout()
"
" Extra feature/bug: If the user changes the size of any windows after
" maximizing, the script still thinks the toggle is ON, so next time it is
" used it will restore your old layout, rather than re-maximize.  (To force
" your new layout to be adopted, you could :call StoreLayout() and then reset
" the toggle.)

" IMPLEMENTATION: Maximizing a window is easy.  We can use :resize and :vert
" resize, or we can set winheight/width.  But restoring the original layout is
" harder!  To do this, we visit all windows before maximizing, and store their
" dimensions.  Then when restoring we visit all windows again, this time using
" the stored data to restore their dimensions.

" TODO: Arguably a better solution would be for "maximization" to simply open
" a new tab with the current buffer, and for "restoration" to close it and
" return to the previous tab.  Unfortunately if MiniBufExplorer is present, he
" may decide to add himself to the maximized tab.  Also this approach cannot
" support independent vertical and horizontal maximizing.

" ISSUES: We had problems accurately restoring the window layout, because
" windows would interfere with each other while we were restoring their sizes.
" (perhaps due to winfixwidth).  It seems WinDoBothWays() has overcome this.

" BUG: Frequently restores windows which were height 0 with height &winheight,
" (and likewise for width) due to the fact that they are visited by windo, and
" resize 0 does nothing on the window you occupy!
" Presumably most earlier versions also had this issue.
" Any workarounds for this?  If we could record which windows which were
" height 0, we could simply skip visiting them when restoring.  Oh look
" winheight() can accept a window number, so we can collect window size data
" without ever visiting them!

" TOTEST: Can large values of winwidth/height cause problems restoring layout?

" DONE: (Option ToggleMaximizeStayMaximized) Temporarily set high values for
" winheight/width during maximization, so that the focused window stays
" maximized if the user switch between windows, but settings will be normal
" when they restore to preferred layout.  (This is actually how the script
" originally worked before :resize)  Note this does not work on windows which
" have set winfixwidth/height.

if !exists("g:ToggleMaximizeStayMaximized")
  let g:ToggleMaximizeStayMaximized = 1
endif

let s:isToggledVertically = 0
let s:isToggledHorizontally = 0

let s:oldwinwidth  = -1
let s:oldwinheight = -1

let g:winheights = []
let g:winwidths = []

function! ToggleMaximize()
  " We can't just call the toggle functions for each axis in turn, because
  " they both use windo to collect data.  The second one may re-expand windows
  " which the first one shrank!
  "call ToggleMaximizeHorizontally()
  "call ToggleMaximizeVertically()
  " The following implementation avoids this by collecting data before
  " resizing.

  if s:isToggledVertically == 1 && s:isToggledHorizontally == 1
    " If both axes are maximized, we restore layout
    if g:ToggleMaximizeStayMaximized
      exec "set winwidth=".s:oldwinwidth
      exec "set winheight=".s:oldwinheight
    endif
    " call s:WinDoBothWays("call WinRestoreHeight()")
    call RestoreHeights()
    " call s:WinDoBothWays("call WinRestoreWidth()")
    call RestoreWidths()
    let s:isToggledVertically = 0
    let s:isToggledHorizontally = 0
  else
    " Otherwise we maximize one or both axes

    " Get data before re-arranging windows
    if s:isToggledVertically == 0
      call StoreHeights()
    endif
    if s:isToggledHorizontally == 0
      call StoreWidths()
    endif

    " Maximize
    if s:isToggledVertically == 0
      let s:oldwinheight = &winheight
      if g:ToggleMaximizeStayMaximized
        set winheight=9999
      endif
      let s:isToggledVertically = 1
      resize 9999
    endif
    if s:isToggledHorizontally == 0
      let s:oldwinwidth = &winwidth
      if g:ToggleMaximizeStayMaximized
        set winwidth=9999
      endif
      let s:isToggledHorizontally = 1
      vertical resize 9999
    endif

  endif
endfunction

function! ToggleMaximizeVertically()
  if s:isToggledVertically == 0
    " call s:WinDo("call WinStoreHeight()")
    call StoreHeights()
    let s:isToggledVertically = 1
    let s:oldwinheight = &winheight
    if g:ToggleMaximizeStayMaximized
      set winheight=9999
    endif
    resize 9999
  else
    if g:ToggleMaximizeStayMaximized
      exec "set winheight=".s:oldwinheight
    endif
    " call s:WinDoBothWays("call WinRestoreHeight()")
    call RestoreHeights()
    let s:isToggledVertically = 0
  endif
endfunction

function! ToggleMaximizeHorizontally()
  if s:isToggledHorizontally == 0
    " call s:WinDo("call WinStoreWidth()")
    call StoreWidths()
    let s:isToggledHorizontally = 1
    let s:oldwinwidth = &winwidth
    if g:ToggleMaximizeStayMaximized
      set winwidth=9999
    endif
    vertical resize 9999
  else
    if g:ToggleMaximizeStayMaximized
      exec "set winwidth=".s:oldwinwidth
    endif
    " call s:WinDoBothWays("call WinRestoreWidth()")
    call RestoreWidths()
    let s:isToggledHorizontally = 0
  endif
endfunction

function! WinStoreHeight()
  let w:oldHeight = winheight(0)
endfunction

function! WinStoreWidth()
  let w:oldWidth = winwidth(0)
endfunction

function! WinRestoreHeight()
  if exists("w:oldHeight")
    " exec "resize ".w:oldHeight
    let i = winnr()-1
    exec "resize ".g:winheights[i]
  endif
endfunction

function! WinRestoreWidth()
  if exists("w:oldWidth")
    " exec "vertical resize ".w:oldWidth
    let i = winnr()
    exec "vertical resize ".g:winwidths[i]
  endif
endfunction

" No longer needed
function! StoreLayout()
  call s:WinDo("call WinStoreHeight()")
  call s:WinDo("call WinStoreWidth()")
endfunction

" No longer needed
function! RestoreLayout()
  if s:oldwinheight > 0   " Just in case the user calls us before toggling!
    exec "set winheight=".s:oldwinheight
  endif
  if s:oldwinwidth > 0
    exec "set winwidth=".s:oldwinwidth
  endif
  " When we resize one window, We do not have much control over which side
  " moves, and what other windows expand or shrink as a result.  So sometimes
  " the above will leave a window crushed by others.  Running it a second
  " time in reverse can often fix the layout if the first attempt failed.
  " call s:WinDoBothWays("call WinRestoreHeight()")
  call RestoreHeights()
  " call s:WinDoBothWays("call WinRestoreWidth()")
  call RestoreWidths()
  "" The focus window is the most important window, so let's give him a final check:
  " call WinRestoreWidth()
  " call WinRestoreHeight()
endfunction

function! StoreHeights()
  let g:winheights = []
  let l:count = winnr('$')
  " echo "count=".l:count
  let i=0
  while i < l:count
    call add( g:winheights , winheight(i) )
    " echo "Storing: [".i."] = ".g:winheights[i]
    let i+=1
  endwhile
endfunction

function! StoreWidths()
  let g:winwidths = []
  let l:count = winnr('$')
  let i=0
  while i < l:count
    call add( g:winwidths , winwidth(i) )
    let i+=1
  endwhile
endfunction

function! RestoreHeightsOK()
  call s:WinDoBothWays("call WinRestoreHeight()")
endfunction

function! RestoreHeights()
  let startwin = winnr()
  let l:count = winnr('$')
  let i=0
  while i < l:count
    if g:winheights[i] > 0
      exec (i+1)."wincmd w"
      exec "resize ". g:winheights[i]
    endif
    let i+=1
  endwhile
  exec startwin."wincmd w"
endfunction

function! RestoreWidthsOK()
  call s:WinDoBothWays("call WinRestoreWidth()")
endfunction

function! RestoreWidths()
  let startwin = winnr()
  let l:count = winnr('$')
  let i=0
  while i < l:count
    if g:winwidths[i] > 0
      exec (i+1)."wincmd w"
      exec "vertical resize ". g:winwidths[i]
    endif
    let i+=1
  endwhile
  exec startwin."wincmd w"
endfunction

" Like :windo but returns to start window when finished.
function! s:WinDo(expr)
  let l:winnr = winnr()
  windo exec a:expr
  exec l:winnr." wincmd w"
endfunction

" Like WinDo but traverses windows in reverse order.
function! s:WinDoReverse(expr)
  let l:winnr = winnr()
  wincmd b   " Move to last window
  let l:firstwinnr = winnr()
  let l:safety = 0
  while l:safety < 99
    let l:safety += 1
    let l:lastwinnr = winnr()   " Do not move this down one line!
    windo exec a:expr
    wincmd W   " Move to next window
    " Check if we have stalled or looped back to start
    if winnr() == l:lastwinnr || winnr() == l:firstwinnr
      break
    endif
  endwhile
  exec l:winnr." wincmd w"
endfunction

" Calls WinDo then WinDoReverse, to help deal with windows that are not
" re-assuming their correct positions!
function! s:WinDoBothWays(expr)
  call s:WinDo(a:expr)
  call s:WinDoReverse(a:expr)
endfunction

" == Keymaps ==

noremap  <silent> <C-F> :call ToggleMaximize()<Enter>
inoremap <silent> <C-F> <Esc>:call ToggleMaximize()<Enter>a
noremap  <silent> <C-\> :call ToggleMaximize()<Enter>
inoremap <silent> <C-\> <Esc>:call ToggleMaximize()<Enter>a
"noremap  <silent> <C-G> :call ToggleMaximize()<Enter>
"inoremap <silent> <C-G> <Esc>:call ToggleMaximize()<Enter>a
"noremap  <silent> <C-Z> :call ToggleMaximize()<Enter>
"inoremap <silent> <C-Z> <Esc>:call ToggleMaximize()<Enter>a

noremap  <silent> <C-V> :call ToggleMaximizeVertically()<Enter>
noremap  <silent> <C-H> :call ToggleMaximizeHorizontally()<Enter>
" We will not override Ctrl-V or Ctrl-H in Insert mode; Ctrl-V is too useful,
" and Ctrl-H might be what some systems see when the user presses Backspace.
"inoremap <silent> <C-V> <Esc>:call ToggleMaximizeVertically()<Enter>a
"inoremap <silent> <C-H> <Esc>:call ToggleMaximizeHorizontally()<Enter>a

"" Does not work:
"noremap <silent> <C-Enter> :call ToggleMaximize()<Enter>

