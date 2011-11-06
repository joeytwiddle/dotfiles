" When you set the size of a window (presently using keymaps) it remembers its
" size, and restores to that size the next time you enter it.

function! s:RememberHeight()
  let w:rememberedHeight = winheight(0)
endfunction

function! s:RememberWidth()
  let w:rememberedWidth = winwidth(0)
endfunction

function! s:RestoreSize()
  if exists('w:rememberedWidth')
    exec "vert resize ".w:rememberedWidth
  endif
  if exists('w:rememberedHeight')
    exec "resize ".w:rememberedHeight
  endif
endfunction

autocmd WinEnter * call <SID>RestoreSize()

" Current keybinds are: Ctrl-NumPadMultiply/Divide/Add/Subtract
nnoremap <silent> Om :resize -2<Enter>:call <SID>RememberHeight()<Enter>
nnoremap <silent> Ok :resize +2<Enter>:call <SID>RememberHeight()<Enter>
nnoremap <silent> Oo :vert resize -6<Enter>:call <SID>RememberWidth()<Enter>
nnoremap <silent> Oj :vert resize +6<Enter>:call <SID>RememberWidth()<Enter>

