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
" Or perhaps more accurately, we want the window that we *last entered from, in
" that direction*.
"
" So now if I casually move between windows in one direction, and then in the
" opposite direction, I should always return to the window I started from!

" BUG: When you split a window, it may cause the numbers of other windows to
" change!

"" Override Vim's default keymaps for window navigation:
noremap  <silent> <C-W>k         :call <SID>SeekBestWindow("k","j")<Enter>
noremap  <silent> <C-W>j         :call <SID>SeekBestWindow("j","k")<Enter>
noremap  <silent> <C-W>h         :call <SID>SeekBestWindow("h","l")<Enter>
noremap  <silent> <C-W>l         :call <SID>SeekBestWindow("l","h")<Enter>
"" I also like them to work in Insert mode!
inoremap <silent> <C-W>k         <Esc>:call <SID>SeekBestWindow("k","j")<Enter>a
inoremap <silent> <C-W>j         <Esc>:call <SID>SeekBestWindow("j","k")<Enter>a
inoremap <silent> <C-W>h         <Esc>:call <SID>SeekBestWindow("h","l")<Enter>a
inoremap <silent> <C-W>l         <Esc>:call <SID>SeekBestWindow("l","h")<Enter>a
"" You may also use <C-W><Up>/<Down>/<Left>/<Right>
"" Warning: these may conflict with other plugins, e.g. windows_remember_size.vim
map  <silent> <C-W><Up>    <C-W>k
map  <silent> <C-W><Down>  <C-W>j
map  <silent> <C-W><Left>  <C-W>h
map  <silent> <C-W><Right> <C-W>l
imap <silent> <C-W><Up>    <C-W>k
imap <silent> <C-W><Down>  <C-W>j
imap <silent> <C-W><Left>  <C-W>h
imap <silent> <C-W><Right> <C-W>l
"" Also in GVim, we need to re-load joeykeymap.vim to get <C-Up> etc. calling
"" the script binds above.

"" Or leave the defaults unchanged, and instead override my preferred shortcuts:
"" This became a pain when my compatibility mappings were intercepting these,
"" so I tried to unmap all my shortcuts.
" silent! unmap <C-Up>
" silent! unmap <C-Down>
" silent! unmap <C-Left>
" silent! unmap <C-Right>
" silent! iunmap <C-Up>
" silent! iunmap <C-Down>
" silent! iunmap <C-Left>
" silent! iunmap <C-Right>
"" Problem: We must unmap these or C-Up mapping fails in xterms.
"" But then we should re-map them for terms which recognise them only!
" silent! unmap [1;5A
" silent! unmap [1;5B
" silent! unmap [1;5D
" silent! unmap [1;5C
" noremap  <silent> <C-Up>         :call <SID>SeekBestWindow("k","j")<Enter>
" inoremap <silent> <C-Up>    <Esc>:call <SID>SeekBestWindow("k","j")<Enter>a
" noremap  <silent> <C-Down>       :call <SID>SeekBestWindow("j","k")<Enter>
" inoremap <silent> <C-Down>  <Esc>:call <SID>SeekBestWindow("j","k")<Enter>a
" noremap  <silent> <C-Left>       :call <SID>SeekBestWindow("h","l")<Enter>
" inoremap <silent> <C-Left>  <Esc>:call <SID>SeekBestWindow("h","l")<Enter>a
" noremap  <silent> <C-Right>      :call <SID>SeekBestWindow("l","h")<Enter>
" inoremap <silent> <C-Right> <Esc>:call <SID>SeekBestWindow("l","h")<Enter>a

function! s:SeekBestWindow(realDirection,reverseDirection)
  " User has requested travel in realDirection, and reverseDirection should be
  " the opposite of that.

  let l:startWin = winnr()
  let l:moveDone = 0

  if exists("w:lastWinInDir_".a:realDirection)
    let l:targetWin = eval("w:lastWinInDir_".a:realDirection)
    " echo "Last window from that direction was ".l:targetWin
    if l:targetWin == l:startWin
      " Window numbers have become confused.  This move is no use!
    else
      " Go to the recommended target window
      noautocmd exec l:targetWin."wincmd w"
      " Check that this movement is still valid
      " We do that by moving back again, and seeing if we get back where we
      " started from.
      noautocmd exec "wincmd ".a:reverseDirection
      if winnr() == l:startWin
        " Yes this move is fine
        exec l:targetWin."wincmd w"
        let l:moveDone = 1
      else
        " No this move might not be valid!
        " (This could be caused by window layout having changed.)
        " Or it might be a valid move, but on the way back Vim would naturally
        " pick a different route.  In that case, travelling *this way* is
        " probably trivial, and we can let Vim do it normally.
        " echo "We may no longer reach ".l:targetWin." from here!"
        noautocmd exec l:startWin."wincmd w"
      endif
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

