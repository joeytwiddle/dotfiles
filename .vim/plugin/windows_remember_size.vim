
" == New version: tries to automatically keep up without whatever layout changes
" you make, by storing an unfocused and focused size for each window. ==
"
" Explanation: Whenever you leave a window, it remembers what size it was, and
" whenever you enter a window, it remembers what size it was before entering.
" Thus it records "focused" and "unfocused" sizes for each window, and it will
" try to grow/shrink windows on entering/leaving, to match the recorded value.
"
" Warning: This system is not perfect, specifically when opening a new window
" (changing the layout) it has no strategy and will often squash the new
" window when it is unfocused (because other windows remember their old sizes,
" so don't leave any space for the new window).
"
" Solution: The best approach appears to be, as soon as your layout breaks in
" some way, fix it immediately with 20<C-W>+ or whatever, to minimize the
" damage (before the new broken values get recorded).  This is a small work
" overhead for the user, which he must exchange for the beneficial features of
" this script!

" TODO: We need :ForgetWidths and :ForgetHeights and :ForgetSizes to disable
" autocmds, so we really can visit every window and forget their w:settings.
" It would be pretty handy sometimes, when the display looks right on this
" window, but old settings are causing trouble on others.
"
" TODO: Do something useful on VimResized event, for example scale all
" remembered sizes proportional to size change, and scale all open windows
" too!  Actually NO to the last bit, and no to scaling TList/MBE/FileExplorer!
" Vim often does what I want to achieve when I enlarge the window, it makes
" the current window grow whilst others stay the same.  Actually TList always
" stays the same width whether it is current window or not.  The only issue is
" height - if the current window is below another then it grows, but if it is
" above another then it doesn't!

" Options:
"
" Experimental feature, set a default height for windows without any
" remembered size, as %age of screen height, or half %age of window we just
" split with.  (Otherwise Vim usually just gives us 50% of the height of the
" window we just split from.) This feature works ok, for the top of two split
" windows, but the bottom one remembers the height Vim gave it during the
" split (50%).
"
"let g:wrs_default_height_pct = 80
"
" OK this is now doing what it should, given the <C-w>s map.
" But that is not entirely what I want.
"
" What I really want is to have a focused height and an unfocused height that
" is the same for all windows, but which shrinks for all windows as I create
" more splits.
"
" NO!  What I really want is a fixed unfocused size (e.g. 5 lines) and for
" focused size to derive entirely from that!  TODO!
"
" What I have now, which is working reasonably well: When we create a
" horizontal split, we assume Vim just split our previous window into 2 even
" parts, so apply 2*wrs_default_height_pct to get the proportional relative to
" the size of the window before we performed the split.
"
" DONE: We "detect" splits by mapping a few split situations below.
" s:wrs_ScaleUpNextSizeWhenLeaving and do so.

"let g:wrsDebug = 1

function! s:InitEvents()
  augroup WindowsRememberSizes
    autocmd!
    autocmd WinLeave * call <SID>Leaving()
    autocmd WinEnter * call <SID>Entering()
  augroup END
endfunction

function! s:Debug(msg)
  if exists('g:wrsDebug') && g:wrsDebug > 0
    echo a:msg
  endif
endfunction

function! s:Leaving()

  " Avoid trashing remembered sizes when toggle_maximize.vim script is in use
  if (exists("g:isToggledVertically") && g:isToggledVertically) || (exists("g:isToggledHorizontally") && g:isToggledHorizontally)
    return
  endif

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

  if s:weAreAboutToSplit
    if exists("g:wrs_default_height_pct")
      let w:heightWhenFocused = w:heightWhenFocused * 2 * g:wrs_default_height_pct / 100
    endif
  endif

  let s:heightOfLastWindowWeLeft = winheight(0)

endfunction

function! s:Entering()

  " Avoid trashing remembered sizes when toggle_maximize.vim script is in use
  if (exists("g:isToggledVertically") && g:isToggledVertically) || (exists("g:isToggledHorizontally") && g:isToggledHorizontally)
    return
  endif

  let w:heightWhenUnfocused = winheight(0)
  let w:widthWhenUnfocused = winwidth(0)

  call s:Debug( "[enter] ".bufname('%')." saved unf ".w:widthWhenUnfocused.",".w:heightWhenUnfocused )

  if s:weAreAboutToSplit
    " We don't do this on things like MBE
    "if exists("g:wrs_default_height_pct") && (&buftype!="nofile" || &bufhidden=="")
    if exists("g:wrs_default_height_pct") && &buftype!="nofile"
      let w:heightWhenFocused = s:heightOfLastWindowWeLeft * 2 * g:wrs_default_height_pct / 100
      let w:widthWhenFocused = winwidth(0)   " Silly workaround to prevent the Debug call from breaking :P
    endif
    let s:weAreAboutToSplit = 0
  endif

  if exists('w:heightWhenFocused') && w:heightWhenFocused > winheight(0)
    call s:Debug( "[enter] ".bufname('%')." restoring ".w:widthWhenFocused."x".w:heightWhenFocused )
    exec "resize ".w:heightWhenFocused
  endif

  if exists('w:widthWhenFocused') && w:widthWhenFocused > winwidth(0)
    exec "vert resize ".w:widthWhenFocused
  endif

endfunction

call s:InitEvents()

" Detect when we are about to split window vertically

let s:weAreAboutToSplit = 0

function s:WeAreAboutToSplit()
  let s:weAreAboutToSplit = 1
endfunction

nnoremap <C-w>s :call <SID>WeAreAboutToSplit()<CR><C-w>s
"nnoremap <C-w>s :call <SID>WeAreAboutToSplit()<CR>:split<CR>
nnoremap :h<Space> :call <SID>WeAreAboutToSplit()<CR>:h<Space>
nnoremap :help<Space> :call <SID>WeAreAboutToSplit()<CR>:help<Space>

" BUGS:
" When we add a new window to the list, e.g. TagList, when switching to it, the old unfocused size of the previous window from the *old* layout is applied.
" I think we need to forget some things when layout changes?  Forget all unfocused sizes?
" Or perhaps when a new window enters the layout, we should quickly grab its dimensions and set those as its focused and unfocused size?

" OK I like this version a lot now.  With the exception of the major bugs, which is when new windows are made, sometimes a window will end up 0 height or 0 width.
" When we are thinking of restoring or saving values, we could check the number of windows (or even their names) to see if any change has occured.
" New windows should be encouraged to take 50% of the space I guess, as per Vim's default.

" Perhaps what we should do is have window remember their relative size rather than their actual size.  Would this be a percentage, or a ratio?
" Then what do we do when a new window is created?  Shrink them all by 10%?  Shrink them intelligently?

" Exposed to user
function! ForgetWindowSizes()
  let l:winnr = winnr()
  "" PROBLEM: windo will cause Leave and Enter events to fire!  Solved - we temporarily clear the events.
  "" Oh Perhaps noautocmd is the better solution to that.
  augroup WindowsRememberSizes
    autocmd!
  augroup END
  noautocmd windo silent! exec "unlet! w:widthWhenFocused"
  noautocmd windo silent! exec "unlet! w:widthWhenUnfocused"
  noautocmd windo silent! exec "unlet! w:heightWhenFocused"
  noautocmd windo silent! exec "unlet! w:heightWhenUnfocused"
  exec l:winnr." wincmd w"
  call s:InitEvents()
endfunction

" Some keybinds, entirely optional
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

"" == Old version: only stores when user changes size with key mapping. ==

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
