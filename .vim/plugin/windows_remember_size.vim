" == New version: tries to automatically keep up without whatever layout changes
" you make, by storing an unfocused and focused size for each window. ==
"
" Explanation: Whenever you leave a window, it remembers what size it was, and
" whenever you enter a window, it remembers what size it was before entering.
" Thus it records "focused" and "unfocused" sizes for each window, and it will
" try to grow/shrink windows on entering/leaving, to match the recorded value.
"
" Warning: This system is not perfect, specifically when opening a new window
" (changing the layout) it has no strategy and will often shrink the new
" window when it is unfocused.
"
" Solution: The best approach appears to be, as soon as your layout breaks in
" some way, fix it immediately with 20<C-W>+ or whatever, to minimize the
" damage (before the new broken values get recorded).  This is a small work
" overhead for the user, which he must exchange for the beneficial features of
" this script!

autocmd WinLeave * call <SID>Leaving()
autocmd WinEnter * call <SID>Entering()

function! s:Debug(msg)
  if exists('g:wrsDebug') && g:wrsDebug > 0
    echo a:msg
  endif
endfunction

function! s:Leaving()
  let w:heightWhenFocused = winheight(0)
  let w:widthWhenFocused = winwidth(0)
  call s:Debug( "[exit] ".bufname('%')." saved foc ".w:widthWhenFocused.",".w:heightWhenFocused )
  if exists('w:heightWhenUnfocused') && w:heightWhenUnfocused < winheight(0)
    call s:Debug( "[exit] ".bufname('%')." setting ".w:widthWhenUnfocused."x".w:heightWhenUnfocused )
    exec "resize ".w:heightWhenUnfocused
  endif
  if exists('w:widthWhenUnfocused') && w:widthWhenUnfocused < winwidth(0)
    exec "vert resize ".w:widthWhenUnfocused
  endif
endfunction

function! s:Entering()
  let w:heightWhenUnfocused = winheight(0)
  let w:widthWhenUnfocused = winwidth(0)
  call s:Debug( "[enter] ".bufname('%')." saved unf ".w:widthWhenUnfocused.",".w:heightWhenUnfocused )
  if exists('w:heightWhenFocused') && w:heightWhenFocused > winheight(0)
    call s:Debug( "[enter] ".bufname('%')." restoring ".w:widthWhenFocused."x".w:heightWhenFocused )
    exec "resize ".w:heightWhenFocused
  endif
  if exists('w:widthWhenFocused') && w:widthWhenFocused > winwidth(0)
    exec "vert resize ".w:widthWhenFocused
  endif
endfunction

" BUGS:
" When we add a new window to the list, e.g. TagList, when switching to it, the old unfocused size of the previous window from the *old* layout is applied.
" I think we need to forget some things when layout changes?  Forget all unfocused sizes?
" Or perhaps when a new window enters the layout, we should quickly grab its dimensions and set those as its focused and unfocused size?

" OK I like this version a lot now.  With the exception of the major bugs, which is when new windows are made, sometimes a window will end up 0 height or 0 width.
" When we are thinking of restoring or saving values, we could check the number of windows (or even their names) to see if any change has occured.
" New windows should be encouraged to take 50% of the space I guess, as per Vim's default.

" Perhaps what we should do is have window remember their relative size rather than their actual size.  Would this be a percentage, or a ratio?
" Then what do we do when a new window is created?  Shrink them all by 10%?  Shrink them intelligently?

" NOTE: copied from older version below
nmap <silent> Om <C-W>-
nmap <silent> Ok <C-W>+
nmap <silent> Oo <C-W><
nmap <silent> Oj <C-W>>
nnoremap <silent> <C-kMinus> <C-W>-
nnoremap <silent> <C-kPlus> <C-W>+
nnoremap <silent> <C-kDivide> <C-W><
nnoremap <silent> <C-kMultiply> <C-W>>



finish

"" == Old version: only stores when use changes size with common mapping. ==

" Posterity: This version went through so many refactors, it almost visited
" all possible approaches!  See hwi.ath.cx CVS for those alternative
" strategies/attempts.  But note this final version was the one I thought
" worked best.

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
