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



" DONE: This might be made to work better with windows_remember_size.vim and
" maybe other plugin, if it only restores its own remembered height or width
" when un-toggling, without affecting the others.  But then it won't restore
" my full layout on un-toggle, and windows_remember_size might still end up
" remembering things we don't want.  Could turn out to be a wasted trek.
"
" Alternatively we could force toggle_maximize to un-maximize the window when
" we move to a different one.
"
" Alternatively windows_remember_size could opt to ignore window sizes (not
" remember anything) if it detects that maximization is in effect.

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



" Options:
" When set, un-maximizes whenever you move away from a maximized window.
if !exists('g:ToggleMaximize_RestoreWhenSwitchingWindow')
  let g:ToggleMaximize_RestoreWhenSwitchingWindow = 0
endif
" This is recommended when using the windows_remember_size plugin.  That
" plugin can detect maximization by this plugin when switching windows, but
" not when splitting windows!



"" These used to be script-wide but now exposed to global so that other
"" plugins can read them (e.g. windows_remember_size.vim)
let g:isToggledVertically = 0
let g:isToggledHorizontally = 0

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
  if !empty(g:winrestcmd)
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
  if g:isToggledVertically
    set winheight=9999
  endif
  if g:isToggledHorizontally
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

  if g:isToggledVertically || g:isToggledHorizontally
    call s:RestoreLayout()
  endif

  if g:isToggledVertically == 1 && g:isToggledHorizontally == 1
    let g:isToggledVertically = 0
    let g:isToggledHorizontally = 0
  else
    " Otherwise we maximize one or both axes
    if g:isToggledVertically == 0
      let g:isToggledVertically = 1
    endif
    if g:isToggledHorizontally == 0
      let g:isToggledHorizontally = 1
    endif
  endif

  if g:isToggledVertically || g:isToggledHorizontally
    call s:DoMaximization()
  endif

endfunction

function! s:ToggleMaximizeVertically()
  call s:RestoreLayout()
  let g:isToggledVertically = 1 - g:isToggledVertically
  call s:DoMaximization()
endfunction

function! s:ToggleMaximizeHorizontally()
  call s:RestoreLayout()
  let g:isToggledHorizontally = 1 - g:isToggledHorizontally
  call s:DoMaximization()
endfunction

" Convenience function exposed for user:
" (They could just memorize "exec g:winrestcmd" instead!)
function! RestoreLayout()
  call s:RestoreLayout()
endfunction



" Avoid conflicts with other plugins by temporarily un-maximising then
" re-maximising when we switch windows.
"
" Unfortunately there is a flaw with this plan:  For it to work, our WinLeave
" autocmd should trigger before all (relevant) autcmds from other plugins, but
" our WinEnter autocmd should trigger after all the others!
"
" For this reason, CheckWinEnter has been changed to do nothing, and for the
" moment this feature has become just
" g:ToggleMaximize_RestoreWhenSwitchingWindow
"
" But none of this is really needed!  Now windows_remember_size.vim just
" doesn't do any remembering when g:ToggleMaximizeVertically/Horizontally is
" set.

let s:wasToggledVertically = 0
let s:wasToggledHorizontally = 0

augroup ToggleMaximizeCheck
  autocmd!
  autocmd WinLeave * call s:CheckWinLeave()
  autocmd WinEnter * call s:CheckWinEnter()
augroup END

function! s:CheckWinLeave()
  if g:ToggleMaximize_RestoreWhenSwitchingWindow
    if g:isToggledVertically
      let s:wasToggledVertically = 1
    endif
    if g:isToggledHorizontally
      let s:wasToggledHorizontally = 1
    endif
    if g:isToggledVertically && g:isToggledHorizontally
      call s:ToggleMaximize()
    endif
    if g:isToggledVertically
      call s:ToggleMaximizeVertically()
    endif
    if g:isToggledHorizontally
      call s:ToggleMaximizeHorizontally()
    endif
  endif
endfunction

function! s:CheckWinEnter()
  return
  if s:wasToggledVertically
    call s:ToggleMaximizeVertically()
  endif
  if s:wasToggledHorizontally
    call s:ToggleMaximizeHorizontally()
  endif
  " Just for safety
  let s:wasToggledVertically = 0
  let s:wasToggledHorizontally = 0
endfunction



" == Keymaps ==

nnoremap  <silent> <C-F> :call <SID>ToggleMaximize()<Enter>
" I have disabled this Insert mode binding, because <C-F> was sometimes conflicting with <C-X><C-F> file expansion (since installing CoC?)
"inoremap <silent> <C-F> <Esc>:call <SID>ToggleMaximize()<Enter>a
nnoremap  <silent> <C-\> :call <SID>ToggleMaximize()<Enter>
inoremap <silent> <C-\> <Esc>:call <SID>ToggleMaximize()<Enter>a
"nnoremap  <silent> <C-G> :call <SID>ToggleMaximize()<Enter>
"inoremap <silent> <C-G> <Esc>:call <SID>ToggleMaximize()<Enter>a
"nnoremap  <silent> <C-Z> :call <SID>ToggleMaximize()<Enter>
"inoremap <silent> <C-Z> <Esc>:call <SID>ToggleMaximize()<Enter>a

nnoremap  <silent> <C-V> :call <SID>ToggleMaximizeVertically()<Enter>
if "$_system_name" == 'OSX' && "$TERM" == 'xterm'
  " In XQuartz on Mac, Backspace sends <C-H> so we shouldn't remap it!
  " We may be able to retain this keybind in future if we can pass <BS> differently.
  " An alternative check might be to examine t_kb.
  " On Linux terminal t_kb=^?  In GVim it does not exist.
  " What is it on Mac?
else
  nnoremap  <silent> <C-H> :call <SID>ToggleMaximizeHorizontally()<Enter>
endif
" We will not override Ctrl-V or Ctrl-H in Insert mode; Ctrl-V is too useful,
" and Ctrl-H might be what some systems see when the user presses Backspace.
"inoremap <silent> <C-V> <Esc>:call <SID>ToggleMaximizeVertically()<Enter>a
"inoremap <silent> <C-H> <Esc>:call <SID>ToggleMaximizeHorizontally()<Enter>a
" Oh dear, I finally found the value of blockwise visual mode, but now I can't
" access it!  Even 0<C-V> still invokes our mapping.  One workaround is simply to
" `nunmap <C-V>`!
" Let's expose some alternative keybinds so <C-V> it can be reached again:
nnoremap <Leader><C-V> <C-V>

"" Does not work:
"nnoremap <silent> <C-Enter> :call <SID>ToggleMaximize()<Enter>

