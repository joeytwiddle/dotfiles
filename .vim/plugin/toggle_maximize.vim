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

" ADDRESSED: Frequently restores windows which were height 0 with height
" &winheight, (and likewise for width) due to the fact that they are visited
" by windo, and resize 0 does nothing on the window you occupy!
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
  call ToggleMaximizeHorizontally()
  call ToggleMaximizeVertically()
endfunction

function! ToggleMaximizeVertically()
  if s:isToggledVertically == 0
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
    call RestoreHeights()
    let s:isToggledVertically = 0
  endif
endfunction

function! ToggleMaximizeHorizontally()
  if s:isToggledHorizontally == 0
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
    call RestoreWidths()
    let s:isToggledHorizontally = 0
  endif
endfunction

function! StoreHeights()
  let g:winheights = []
  let l:count = winnr('$')
  let i=0
  while i < l:count
    call add( g:winheights , winheight(i) )
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

