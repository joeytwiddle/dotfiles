" ToggleMaximize v1.3.4 by joey.neuralyte.org
"
" Vim can support complex window layouts, but they can put users off because
" they reduce the size of the main editing window.  ToggleMaximize addresses
" this issue, by allowing the user to switch between a large editor window,
" and his own complex window layout.
"
" Press Ctrl-F or Ctrl-\ to maximize the size of the current window, press
" again to restore the original window layout.
"
" Ctrl-V and Ctrl-H toggle maximize in vertical/horizontal direction only.
"
" Maximization is forced to respect winminwidth and winminheight, so if you
" have these set, other windows will not fully shrink to the edges.
" Restoration is forced to respect winheight.
"
" If the user changes the size of any windows after maximizing, the script
" still thinks the toggle is ON, so next time it is used it will restore your
" old layout, rather than re-maximize.

" CONSIDER: Arguably a better solution would be for "maximization" to simply
" open a new tab with the current buffer, and for "restoration" to close it
" and return to the previous tab.

" TODO: Large values of winwidth/height can cause problems restoring layout.
" Width is ok because we do that last, but when we visit windows to restore
" width, winheight may alter previously correct heights!
" SOLUTION: restore width+height at the same time.
" SOLUTION: temporarily set winwidth/height to 1 while we are restoring.
" Although we cannot do that if winminwidth/height are > 1.  Grrr!
" So we might need to temporarily alter winminwidth/height too!
" CURRENTLY: Left to the user to set winwidth/height low or live with the bug!

" SUCKS: Resizing Vim in your window manager does not cause winheight to be
"        re-enforced (until you change window).

" NOTE: Oh look there is winrestcmd()!  Could have saved us some work,
" although it won't work on axes independently.

let s:isToggledVertically = 0
let s:isToggledHorizontally = 0

let s:oldwinwidth  = -1
let s:oldwinheight = -1

let s:winHeights = []
let s:winWidths = []

" SUCKS: After all that refactoring, I note that windowid-indexed values apply
" to different windows when windows are closed or created, whereas
" window-local variables clean themselves up more tidily.

function! s:ToggleMaximize()
  "call ToggleMaximizeHorizontally()
  "call ToggleMaximizeVertically()
  " We can't just call the toggle functions for each axis in turn, because
  " they both use windo to restore size.  The second one may re-expand windows
  " which the first one shrank, due to winwidth/winheight.
  " The following implementation avoids this by restoring winwidth/height
  " before resizing.

  if s:isToggledVertically == 1 && s:isToggledHorizontally == 1
    " If both axes are maximized, we restore layout
    exec "set winwidth=".s:oldwinwidth
    exec "set winheight=".s:oldwinheight
    call s:RestoreHeights()
    call s:RestoreWidths()
    let s:isToggledVertically = 0
    let s:isToggledHorizontally = 0
  else
    " Otherwise we maximize one or both axes
    if s:isToggledVertically == 0
      call s:ToggleMaximizeVertically()
    endif
    if s:isToggledHorizontally == 0
      call s:ToggleMaximizeHorizontally()
    endif
  endif
endfunction

function! s:ToggleMaximizeVertically()
  if s:isToggledVertically == 0
    call s:StoreHeights()
    let s:oldwinheight = &winheight
    set winheight=9999
    " resize 9999
    let s:isToggledVertically = 1
  else
    exec "set winheight=".s:oldwinheight
    call s:RestoreHeights()
    let s:isToggledVertically = 0
  endif
endfunction

function! s:ToggleMaximizeHorizontally()
  if s:isToggledHorizontally == 0
    call s:StoreWidths()
    let s:oldwinwidth = &winwidth
    set winwidth=9999
    " vertical resize 9999
    let s:isToggledHorizontally = 1
  else
    exec "set winwidth=".s:oldwinwidth
    call s:RestoreWidths()
    let s:isToggledHorizontally = 0
  endif
endfunction

" Window numbering is 1-based, but we store heights 0-based in the array.
function! s:StoreHeights()
  let s:winHeights = []
  call s:IterateWindows("call s:WinStoreHeight(i)")
endfunction

function! s:StoreWidths()
  let s:winWidths = []
  call s:IterateWindows("call s:WinStoreWidth(i)")
endfunction

function! s:WinStoreHeight(i)
  call add( s:winHeights , winheight(a:i) )
endfunction

function! s:WinStoreWidth(i)
  call add( s:winWidths , winwidth(a:i) )
endfunction

function! s:RestoreHeights()
  call s:WinDo("call s:WinRestoreHeight()")
endfunction

function! s:RestoreWidths()
  call s:WinDo("call s:WinRestoreWidth()")
endfunction

function! s:WinRestoreHeight()
  if winnr() < len(s:winHeights)
    exec "resize ". s:winHeights[winnr()-1]
  endif
endfunction

function! s:WinRestoreWidth()
  if winnr() < len(s:winHeights)
    exec "vert resize ". s:winWidths[winnr()-1]
  endif
endfunction

" Like :windo but returns to start window when finished.
function! s:WinDo(expr)
  let l:winnr = winnr()
  windo exec a:expr
  exec l:winnr." wincmd w"
endfunction

" Iterates through windows with i=1..n, does not visit them.
function! s:IterateWindows(expr)
  let l:count = winnr('$')
  let i=1
  while i <= l:count
    exec a:expr
    let i+=1
  endwhile
endfunction

" == Keymaps ==

nnoremap  <silent> <C-F> :call <SID>ToggleMaximize()<Enter>
inoremap <silent> <C-F> <Esc>:call <SID>ToggleMaximize()<Enter>a
nnoremap  <silent> <C-\> :call <SID>ToggleMaximize()<Enter>
inoremap <silent> <C-\> <Esc>:call <SID>ToggleMaximize()<Enter>a
"nnoremap  <silent> <C-G> :call <SID>ToggleMaximize()<Enter>
"inoremap <silent> <C-G> <Esc>:call <SID>ToggleMaximize()<Enter>a
"nnoremap  <silent> <C-Z> :call <SID>ToggleMaximize()<Enter>
"inoremap <silent> <C-Z> <Esc>:call <SID>ToggleMaximize()<Enter>a

nnoremap  <silent> <C-V> :call <SID>ToggleMaximizeVertically()<Enter>
nnoremap  <silent> <C-H> :call <SID>ToggleMaximizeHorizontally()<Enter>
" We will not override Ctrl-V or Ctrl-H in Insert mode; Ctrl-V is too useful,
" and Ctrl-H might be what some systems see when the user presses Backspace.
"inoremap <silent> <C-V> <Esc>:call <SID>ToggleMaximizeVertically()<Enter>a
"inoremap <silent> <C-H> <Esc>:call <SID>ToggleMaximizeHorizontally()<Enter>a

"" Does not work:
"nnoremap <silent> <C-Enter> :call <SID>ToggleMaximize()<Enter>

