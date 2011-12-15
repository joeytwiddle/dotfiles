" ToggleMaximize v1.4.0 by joey.neuralyte.org
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

" 2011/12/15  Version 1.4 uses winrestcmd() and is a bit faster.  (Old methods
" of restoration via WinDo() tended to trigger WinEnter events in other
" plugins, e.g. MBE/Taglist.)

" CONSIDER: An alternative solution would be for "maximization" to simply open
" a new tab with the current buffer, and for "restoration" to close it and
" return to the previous tab.


"" OLD DOCS:

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

let s:isToggledVertically = 0
let s:isToggledHorizontally = 0

let s:oldwinwidth  = -1
let s:oldwinheight = -1

let s:winHeights = []
let s:winWidths = []

let g:winrestcmd = ''
let g:lastwinrestcmd = ''

" SUCKS: After all that refactoring, I note that windowid-indexed values apply
" to different windows when windows are closed or created, whereas
" window-local variables clean themselves up more tidily.

function! s:StoreLayout()
  let g:winrestcmd = winrestcmd()
  "echo "Saving layout: ".g:winrestcmd
endfunction

function! s:RestoreLayout()
  if g:winrestcmd
    exec "set winwidth=".s:oldwinwidth
    exec "set winheight=".s:oldwinheight
    "echo "Restoring layout: ".g:winrestcmd
    exec g:winrestcmd
    let g:lastwinrestcmd = g:winrestcmd
    let g:winrestcmd=''
  endif
endfunction

function! s:DoMaximization()
  call s:StoreLayout()
  if s:isToggledVertically
    let s:oldwinheight = &winheight
    set winheight=9999
  endif
  if s:isToggledHorizontally
    let s:oldwinwidth = &winwidth
    set winwidth=9999
  endif
endfunction

function! s:ToggleMaximize()
  "call ToggleMaximizeHorizontally()
  "call ToggleMaximizeVertically()
  " We can't just call the toggle functions for each axis in turn, because
  " they both use windo to restore size.  The second one may re-expand windows
  " which the first one shrank, due to winwidth/winheight.
  " The following implementation avoids this by restoring winwidth/height
  " before resizing.

  if s:isToggledVertically || s:isToggledHorizontally
    call s:RestoreLayout()
  endif

  if s:isToggledVertically == 1 && s:isToggledHorizontally == 1
    let s:isToggledVertically = 0
    let s:isToggledHorizontally = 0
  else
    " Otherwise we maximize one or both axes
    if s:isToggledVertically == 0
      let s:isToggledVertically = 1
    endif
    if s:isToggledHorizontally == 0
      let s:isToggledHorizontally = 1
    endif
  endif

  if s:isToggledVertically || s:isToggledHorizontally
    call s:DoMaximization()
  endif

endfunction

function! s:ToggleMaximizeVertically()
  call s:RestoreLayout()
  let s:isToggledVertically = 1 - s:isToggledVertically
  call s:DoMaximization()
endfunction

function! s:ToggleMaximizeHorizontally()
  call s:RestoreLayout()
  let s:isToggledHorizontally = 1 - s:isToggledHorizontally
  call s:DoMaximization()
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

