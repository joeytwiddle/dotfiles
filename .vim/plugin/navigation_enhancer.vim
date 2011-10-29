" Navigation Enhancer v2.0 by joey.neuralyte.org
"
" aka Retrace Your Steps
"
" When moving the cursor between windows, given a choice of target windows,
" Vim uses the *cursor position* to choose the destination window.
"
" However I think a more intuitive approach when there may be more than one
" potential target window is to pick the one which was *used most recently*.
"
" So now if I casually move between windows in one direction, and then in the
" opposite direction, I should always return to the window I started from!

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

  let l:startWin = winnr()
  let l:moveDone = 0

  if exists("w:lastWinInDir_".a:realDirection)
    let l:targetWin = eval("w:lastWinInDir_".a:realDirection)
    exec l:targetWin."wincmd w"
    " But we should check that this movement is still valid
    " We do that by moving back again, and seeing if we get back where we
    " started from.
    exec "wincmd ".a:reverseDirection
    if winnr() == l:startWin
      " Yes this move is fine
      exec l:targetWin."wincmd w"
      let l:moveDone = 1
    else
      " No this move might not be valid!
      " echo "We may no longer reach ".l:targetWin." from here!"
      exec l:startWin."wincmd w"
    endif
  endif

  if !l:moveDone
    " echo "Doing normal move"
    exec "wincmd ".a:realDirection
  endif

  " Record the route back (but not if we didn't actually move!)
  if winnr() != l:startWin
    exec "let w:lastWinInDir_".a:reverseDirection." = ".l:startWin
  endif

endfunction

