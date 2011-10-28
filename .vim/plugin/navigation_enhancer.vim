" Navigation Enhancer v1.2 by joey.neuralyte.org
"
" When moving the cursor between windows, given a choice of target windows,
" Vim uses the *cursor position* to choose the destination window.
"
" However I think a better approach when there may be more than one potential
" target window is to pick the one which was *used most recently*.
"
" So now if I casually move between windows in one direction, and then in the
" opposite direction, I should always return to the window I started from!
"
" ISSUES: The side-effects of windo are undesirable.  To avoid windo, we could
" lazily maintain a script-global data structure representing which windows
" may be reached from which others.  Since we are mainly interesting in
" following recent paths in reverse, we need not store every combination, but
" only the most recent path out of a window in each direction.  When choosing
" a path we should check that it still exists, and also seriously consider the
" default which Vim suggested if it is new!
" In other words, we will simply store in each window the window we were on
" before we came here, for each of the 4 directions.  And we will re-use that
" window when leaving in that direction, if it is still valid.  (Hmm it is
" valid if EITHER going that way takes us to it (in which case the plugin is
" redundant), OR if we can come back from it the opposite way.)
"
" BUG: localtime() is only accurate to the second, which is occasionally too
" coarse.

" Set up event listener to store lastUsed time when leaving a window
" But do not update window visits when traversing windows for app purposes!
let g:updateTimes = 1   " This was a s: but g: is better for development
auto BufLeave * if g:updateTimes | let w:lastUsed = localtime() | endif
" NOTE: Other scripts who traverse windows, (with or without windo, e.g.
" toggle_maximize.vim) may freshen these times when we don't want them to!
" To work around this, perhaps we could update only when we detect movement
" through a keybind.

"" Override Vim's default keymaps for window navigation:
" noremap  <silent> <C-W><Up>      :call SeekBestWindow("k","j")<Enter>
" inoremap <silent> <C-W><Up>      <Esc>:call SeekBestWindow("k","j")<Enter>a
" noremap  <silent> <C-W><Down>    :call SeekBestWindow("j","k")<Enter>
" inoremap <silent> <C-W><Down>    <Esc>:call SeekBestWindow("j","k")<Enter>a
" noremap  <silent> <C-W><C-Left>  :call SeekBestWindow("h","l")<Enter>
" inoremap <silent> <C-W><C-Left>  <Esc>:call SeekBestWindow("h","l")<Enter>a
" noremap  <silent> <C-W><C-Right> :call SeekBestWindow("l","h")<Enter>
" inoremap <silent> <C-W><C-Right> <Esc>:call SeekBestWindow("l","h")<Enter>a

"" Or leave them unchanged, and use my preferred shortcuts:
noremap  <silent> <C-Up>         :call <SID>SeekBestWindow("k","j")<Enter>
inoremap <silent> <C-Up>    <Esc>:call <SID>SeekBestWindow("k","j")<Enter>a
noremap  <silent> <C-Down>       :call <SID>SeekBestWindow("j","k")<Enter>
inoremap <silent> <C-Down>  <Esc>:call <SID>SeekBestWindow("j","k")<Enter>a
noremap  <silent> <C-Left>       :call <SID>SeekBestWindow("h","l")<Enter>
inoremap <silent> <C-Left>  <Esc>:call <SID>SeekBestWindow("h","l")<Enter>a
noremap  <silent> <C-Right>      :call <SID>SeekBestWindow("l","h")<Enter>
inoremap <silent> <C-Right> <Esc>:call <SID>SeekBestWindow("l","h")<Enter>a

function! s:SeekBestWindow(realDirection,reverseDirection)
  " User has requested travel in realDirection, and reverseDirection should be
  " the opposite of that.
  " We want to find all candidate windows in that direction, and select the
  " most recently used.
  " We will search all windows for any which can reach the current window by
  " travelling in reverseDirection.
  let g:updateTimes = 0
  try
    let s:startWin = winnr()
    let s:bestScore = 0
    let s:bestWin = -1
    " Had trouble passing a: to windo, so we make it a script global:
    let s:direction = a:reverseDirection
    " We provide Vim's default suggestion as the fallback solution:
    exec "wincmd" a:realDirection
    let s:bestWin = winnr()
    " echo "Seeking windows which are ".a:realDirection." of ".s:startWin
    windo call s:CheckBestWindow()
    " Return to start window, so we can properly fire its leave event
    exec s:startWin."wincmd w"
  finally
    let g:updateTimes = 1
  endtry
  " echo "Best window was ".s:bestWin." with score ".s:bestScore
  exec s:bestWin."wincmd w"
endfunction

function! s:CheckBestWindow()
  let l:curWin = winnr()
  if l:curWin == s:startWin
    return
  endif
  exec "wincmd ".s:direction
  let l:nowWin = winnr()
  " Go straight back (windo needs this, and we can see w:lastUsed)
  exec l:curWin."wincmd w"
  if l:nowWin == s:startWin
    " Then curWin is a candidate!
    if !exists("w:lastUsed")
      let w:lastUsed = 1   " Beats fallback 0
    endif
    " echo "Window ".l:curWin." (".bufname('%').") goes to ".l:nowWin." (which has lastUsed=".w:lastUsed.")"
    if w:lastUsed > s:bestScore
      let s:bestScore = w:lastUsed
      let s:bestWin = l:curWin
    endif
  endif
endfunction

