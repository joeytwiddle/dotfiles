" ToggleMaximize v1.4.2 by joey.neuralyte.org
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
"
" If the user changes the size of any windows after maximizing, the script
" still thinks the toggle is ON, so next time it is used it will restore your
" old layout, rather than re-maximize (unlike some window managers).



" WARNING BUG TODO: If we create a new window while maximized (e.g. split the
" current window), restoring with winrestcmd completely fails!  I tend to
" notice this because in my usual layout the current window becomes very tiny!
"
" WORKAROUND: *DO NOT* create or split windows while maximized!  Just
" un-maximize to do that operation, until we fix this.  In emergencies: <C-W>=
"
" SOLUTION: We should continue to use the winrestcmd style of restoring sizes
" without visiting windows, but we must track old window sizes better than it
" does, e.g.  by buffer name, not by volatile window numbers.  I think one of
" our older revisions implemented a global dictionary of sizes, although
" perhaps indexed window number, not bufname.  The result of this would be
" that newly created windows would be squished on restoration.
"
" ALTERNATIVE: We could try to workaround this problem by restoring normal
" layout before any new windows are created, and re-maximizing afterwards.

" NOTE: There are a couple of other things that occasionally go wrong, namely:
" winrestcmd is still set but windows look restored.  winrestcmd is ignored.
" winheight=9999 before and after toggle!  These may only occur when
" re-sourcing the script during development (hopefully!).
"
" OK the problem here seems to be when I only toggle vertically, it doesn't
" clear the winrestcmd.  I've just forgotten I'm horizontally toggled too?
" Well if I don't have any horizontal splits then no I don't notice!

" SUCKS: Resizing Vim in your window manager does not cause winheight to be
"        re-enforced (until you change window).
" Hehe actually I tend to survive this because I have put MBE on cursorhold,
" so the winheight=9999 gets reinforced often.



" CONSIDER: An entirely alternative approach would be for "maximization" to
" simply open a new tab with the current buffer, and for "restoration" to
" close it and return to the previous tab.  This would even hide the
" StatusLines of other windows which we currently still display.



" CHANGELOG:
"
" 2011/12/15  Version 1.4 uses winrestcmd() and is a bit faster.  (Old methods
" of restoration via WinDo() tended to fight with winwidth/height settings,
" and also trigger WinEnter events in other plugins, e.g. MBE/Taglist.)



" NOTES ON OLD APPROACHES:
" Old versions used to visit the windows to resize them.  Large values of
" winwidth/height could cause problems restoring layout.  It was left to the
" user to set winwidth/height low or live with the bug!

" SUCKS: After all that refactoring, I note that windowid-indexed values apply
" to different windows when windows are closed or created, whereas
" window-local variables clean themselves up more tidily.  But window-local
" variables can only be accessed by visiting the window.



let s:isToggledVertically = 0
let s:isToggledHorizontally = 0

let s:oldwinwidth  = 1
let s:oldwinheight = 1

let g:winrestcmd = ''
let g:lastwinrestcmd = ''

function! s:StoreLayout()
  let s:oldwinheight = &winheight
  let s:oldwinwidth = &winwidth
  let g:winrestcmd = winrestcmd()
  "echo "Saved layout: ".g:winrestcmd
endfunction

function! s:RestoreLayout()
  if g:winrestcmd
    exec "set winwidth=".s:oldwinwidth
    exec "set winheight=".s:oldwinheight
    "echo "Restoring layout: ".g:winrestcmd
    exec g:winrestcmd
    exec g:winrestcmd
    let g:lastwinrestcmd = g:winrestcmd
    let g:winrestcmd=''
  endif
endfunction

function! s:DoMaximization()
  call s:StoreLayout()
  if s:isToggledVertically
    set winheight=9999
  endif
  if s:isToggledHorizontally
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

" Convenience function exposed for user:
" (They could just memorize "exec g:winrestcmd" instead!)
function! RestoreLayout()
  call s:RestoreLayout()
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

