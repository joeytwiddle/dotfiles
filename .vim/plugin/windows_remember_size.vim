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

" Options:
"
" New feature: Set a default height for newly split windows, as percentage of
" the size of the original window.  Without it Vim usually splits 50-50.
"
"let g:wrs_default_height_pct = 90
"
" We "detect" when a split is about to occur by mapping <Ctrl-W>s and :h
" below.  You may want to add more mappings for other splitting actions.

"let g:wrsDebug = 1

" Flash the text of the newly focused window whenever we change window.  This is rather ugly but can serve as an aid for anyone confused as to where the focus has now moved!
if !exists("g:wrs_flash_focused_window")
  let g:wrs_flash_focused_window = 0
endif
" DONE: In future make this use 'colorcolumn' which *can* highlight characters outside the text.

"highlight WRSFlash ctermbg=yellow guibg=#888800
highlight WRSFlash ctermbg=green guibg=#008800
highlight clear ColorColumn
highlight link ColorColumn WRSFlash

function! s:InitEvents()
  augroup WindowsRememberSizes
    autocmd!
    autocmd WinLeave * call s:Leaving()
    autocmd WinEnter * call s:Entering()
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

  if g:wrs_flash_focused_window
    call s:ClearFlash()
  endif

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

  if g:wrs_flash_focused_window
    call s:StartFlash()
  endif

endfunction

function! s:StartFlash()
  " I really wanted to highlight the whole window (I mean the blank characters after the end of each line of text) but the only way I have found to do this is to change `:hi Normal` which unfortunately applies to the whole Vim; I cannot get it to apply just to the current window.
  ":2match WRSFlash /.*/
  " Oooh there is a way ... colorcolumn!
  " If a line wraps into 3 lines, we will need to multiply the width by 3
  "let l:width = winwidth(0) * 30
  " Unfortunately this quickly reaches the max of 256
  let l:width = 256
  let l:range = join(range(1, l:width), ',')
  call setwinvar(0, '&colorcolumn', l:range)
  " BUG TODO: colorcolumn isn't working at all when opening a help window with :h
  autocmd!
    autocmd CursorHold <buffer> call s:ClearFlash()
    " This was triggering too often, so the flash was very often not appearing!
    "autocmd CursorMoved <buffer> call s:ClearFlash()
    autocmd WinLeave <buffer> call s:ClearFlash()
    autocmd InsertEnter <buffer> call s:ClearFlash()
    autocmd InsertLeave <buffer> call s:ClearFlash()
    " BUG TODO: For some reason none of these are being triggered after opening a help window with :h, although the flash itself is triggered.
  augroup END
endfunction

function! s:ClearFlash()
  augroup WRSFlash
    autocmd!
  augroup END
  ":2match none
  call setwinvar(0, '&colorcolumn', '')
endfunction

call s:InitEvents()

" Detect when we are about to split window vertically

let s:weAreAboutToSplit = 0

function! s:WeAreAboutToSplit()
  let s:weAreAboutToSplit = 1
endfunction

nnoremap <C-w>s :call <SID>WeAreAboutToSplit()<CR><C-w>s
"nnoremap <C-w>s :call <SID>WeAreAboutToSplit()<CR>:split<CR>
nnoremap :h<Space> :call <SID>WeAreAboutToSplit()<CR>:h<Space>
nnoremap :help<Space> :call <SID>WeAreAboutToSplit()<CR>:help<Space>

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

" BUGS:
" When we add a new window to the list, e.g. TagList, when switching to it, the old unfocused size of the previous window from the *old* layout is applied.
" I think we need to forget some things when layout changes?  Forget all unfocused sizes?
" Or perhaps when a new window enters the layout, we should quickly grab its dimensions and set those as its focused and unfocused size?

" OK I like this version a lot now.  With the exception of the major bugs, which is when new windows are made, sometimes a window will end up 0 height or 0 width.
" When we are thinking of restoring or saving values, we could check the number of windows (or even their names) to see if any change has occured.
" New windows should be encouraged to take 50% of the space I guess, as per Vim's default.

" Perhaps what we should do is have window remember their relative size rather than their actual size.  Would this be a percentage, or a ratio?
" Then what do we do when a new window is created?  Shrink them all by 10%?  Shrink them intelligently?

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

