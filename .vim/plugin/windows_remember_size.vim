" When you set the size of a window (presently using keymaps) it remembers its
" size, and restores to that size the next time you enter it.

" Ideally instead of keymaps would could intercept user-originated calls to
" :resize, e.g. from the mouse or from user or default mappings.
" (There is no WinResized event to attach to.)

" Alternatively, we could try *always* storing the size:
" autocmd WinLeave * call <SID>RememberHeight() | call <SID>RememberWidth()

" BUG: Occasionally I press the restore button and it goes mad.  This might be
" related to me maximizing the window in X.

" I might deprecate this script in favour of:
" Allow setting of layout "strategy", one of which could be:
"   - Divide height 1/3 last window, 2/3rds this window, shrink rest.
"   (Perhaps 3rd last give 1 line, others 0, or 3 and 1.)
"   - Perhaps I even want my windows to cycle for me, so if I am focused on
"   say the bottom one, the 3 above keep getting updated to display the
"   previous 3 buffers I entered.

" CONSIDER TODO: Sometimes the resize rules we set get confused when we create
" a new window (window numbers change).  Perhaps it would feel nicer to
" associate remembered height/width with the buffer, not the window?

" Intercept the normal resize keys:
nnoremap <silent> <C-W>+ <C-W>+:call <SID>RememberHeight()<Enter>
nnoremap <silent> <C-W>- <C-W>-:call <SID>RememberHeight()<Enter>
nnoremap <silent> <C-W>> <C-W>>:call <SID>RememberWidth()<Enter>
nnoremap <silent> <C-W>< <C-W><:call <SID>RememberWidth()<Enter>
" Make <C-W>= also clear all remembered sizes (optional)
nnoremap <silent> <C-W>= :call ForgetWindowSizes()<Enter><C-W>=

" Current keybinds are: Ctrl-NumPadMultiply/Divide/Add/Subtract
"nnoremap <silent> Om :resize -2<Enter>:call <SID>RememberHeight()<Enter>
"nnoremap <silent> Ok :resize +2<Enter>:call <SID>RememberHeight()<Enter>
"nnoremap <silent> Oo :vert resize -6<Enter>:call <SID>RememberWidth()<Enter>
"nnoremap <silent> Oj :vert resize +6<Enter>:call <SID>RememberWidth()<Enter>

" Alternative, map them through the defaults (allows for 7<C-kPlus>)
nmap <silent> Om <C-W>-
nmap <silent> Ok <C-W>+
nmap <silent> Oo <C-W><
nmap <silent> Oj <C-W>>

" ISSUE: Two of these are overwritten in the GUI by zoom.vim!
" Sometimes gVim does not respond to these keys, so I must do the following.
" However we don't want to do it by default because it ... breaks something in non-GUI vim.
nnoremap <silent> <C-kMinus> :resize -2<Enter>:call <SID>RememberHeight()<Enter>
nnoremap <silent> <C-kPlus> :resize +2<Enter>:call <SID>RememberHeight()<Enter>
nnoremap <silent> <C-kDivide> :vert resize -6<Enter>:call <SID>RememberWidth()<Enter>
nnoremap <silent> <C-kMultiply> :vert resize +6<Enter>:call <SID>RememberWidth()<Enter>

" If you are having trouble sending numberpad key codes at all:
"nnoremap <silent> - :resize -2<Enter>:call <SID>RememberHeight()<Enter>
"nnoremap <silent> + :resize +2<Enter>:call <SID>RememberHeight()<Enter>

function! s:RememberHeight()
  let w:rememberedHeight = winheight(0)
endfunction

function! s:RememberWidth()
  let w:rememberedWidth = winwidth(0)
endfunction

autocmd WinEnter * call <SID>RestoreSize()

function! s:RestoreSize()
  if exists('w:rememberedWidth')
    exec "vert resize ".w:rememberedWidth
  endif
  if exists('w:rememberedHeight')
    exec "resize ".w:rememberedHeight
  endif
endfunction

" Exposed to user
function! ForgetWindowSizes()
  let l:winnr = winnr()
  windo unlet! w:rememberedHeight
  windo unlet! w:rememberedWidth
  exec l:winnr." wincmd w"
endfunction

" BUG: ForgetWindowSizes() sometimes changes the current window layout!
" CONSIDER: Could be better to store sizes in a global, so they can be
" forgotten easily (without visiting the windows!).
" OTOH: Using window-local rather than windowid-indexed vars means they
" disappear tidily when windows are closed or opened.
" Or we could just disable our WinEnter event handler during the windo calls.
" Or we can accept that ForgetWindowSizes might change the current window sizes!
