" Navigation Enhancer v1.0 by JoeyTwiddle
"
" When moving the cursor between windows, given a choice of target windows,
" Vim uses the *cursor position* to choose the destination window.
"
" However I think a better approach when there may be more than one potential
" target window is to pick the one which was *used most recently*.
"
" So now if I casually move between windows in one direction, and then in the
" opposite direction, I should always return to the window I started from!

" Set up event listener to store lastUsed time when leaving a window
" But do not update window visits when traversing windows for app purposes!
let s:updateTimes = 1
auto BufLeave * if s:updateTimes | let w:lastUsed = localtime() | endif
" NOTE: Other scripts who traverse windows, (with or without windo, e.g.
" toggle_maximize.vim) may freshen these times when we don't want them to!

"" Override Vim's keymaps for window navigation
noremap  <C-W><Up>      :call SeekBestWindow("k","j")<Enter>
inoremap <C-W><Up>      <Esc>:call SeekBestWindow("k","j")<Enter>a
noremap  <C-W><Down>    :call SeekBestWindow("j","k")<Enter>
inoremap <C-W><Down>    <Esc>:call SeekBestWindow("j","k")<Enter>a
noremap  <C-W><C-Left>  :call SeekBestWindow("h","l")<Enter>
inoremap <C-W><C-Left>  <Esc>:call SeekBestWindow("h","l")<Enter>a
noremap  <C-W><C-Right> :call SeekBestWindow("l","h")<Enter>
inoremap <C-W><C-Right> <Esc>:call SeekBestWindow("l","h")<Enter>a

"" Or use my preferred shortcuts:
noremap  <C-Up>    :call SeekBestWindow("k","j")<Enter>
inoremap <C-Up>    <Esc>:call SeekBestWindow("k","j")<Enter>a
noremap  <C-Down>  :call SeekBestWindow("j","k")<Enter>
inoremap <C-Down>  <Esc>:call SeekBestWindow("j","k")<Enter>a
noremap  <C-Left>  :call SeekBestWindow("h","l")<Enter>
inoremap <C-Left>  <Esc>:call SeekBestWindow("h","l")<Enter>a
noremap  <C-Right> :call SeekBestWindow("l","h")<Enter>
inoremap <C-Right> <Esc>:call SeekBestWindow("l","h")<Enter>a

function! SeekBestWindow(realDirection,reverseDirection)
  " User has requested travel in realDirection, and reverseDirection should be
  " the opposite of that.
  " We want to find all candidate windows in that direction, and select the
  " most recently used.
  " We will search all windows for any which can reach the current window by
  " travelling in reverseDirection.
  let s:updateTimes = 0
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
    let s:updateTimes = 1
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
  " Go straight back (so we can read lastUsed, may also help dumb traversal)
  exec l:curWin."wincmd w"
  if l:nowWin == s:startWin
    " Then curWin is a candidate
    " echo "Window ".l:curWin." (".bufname('%').") goes to ".l:nowWin." (which has lastUsed=".w:lastUsed.")"
    if s:bestScore==0 || (exists("w:lastUsed") && w:lastUsed > s:bestScore)
      if exists("w:lastUsed")
        let s:bestScore = w:lastUsed
      endif
      let s:bestWin = l:curWin
    endif
  endif
endfunction

