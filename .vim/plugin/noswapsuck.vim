" Vim swapfiles tend to become more of a hindrance than a feature.  If you set
" swapfile and hidden, and don't close your vim properly, then there will be a
" swapfile created for every buffer you had opened.  You may end up with a
" lots of swapfiles on your system, and be unsure which hold old versions,
" up-to-date versions, or new versions of the file.
"
" This plugin only enables the swapfile when we start modifying a buffer.
"
" After saving a buffer, the swapfile will be removed if you unfocus the
" buffer via a BufLeave or BufWinLeave event.
"
" Issues:
"
" - If you prefer to remove the swapfile immediately after each save, do this
"   before loading:
"
"     let g:NoSwapSuck_CloseSwapfileOnWrite = 0
"
"   But if your workflow involves an edit-save-edit-save loop, this setting
"   will keep creating and destroying the swapfile.
"
"   That behaviour may be undesirable in the following situations:
"
"   - your files are very large,
"   - your drive is very slow (perhaps saving over a network), or
"   - you are trying to preserve battery.
"
" - Because the script sets 'swapfile' in the middle of editing, that is the
"   moment when it will prompt you if it finds an old swapfile.  Ideally it
"   will prompt earlier, but that is not always the case.

" TODO:
" - All options should work at runtime, including Enable and CloseSwapfileOnWrite.

" Options:

" Allows plugin to be enabled/disabled from config and also at runtime.
let g:NoSwapSuck_Enabled = get(g:, 'NoSwapSuck_Enabled', 1)

if g:NoSwapSuck_Enabled == 0
  finish
endif

" When opening a file for the first time, will `:set swapfile` to force Vim to
" check if there is a swapfile present for that file.
let g:NoSwapSuck_CheckSwapfileOnLoad = get(g:, 'NoSwapSuck_CheckSwapfileOnLoad', 1)

" Create a swapfile immediately before entering Insert mode.
"
" Advantages: If you do a long edit without leaving insert mode, your changes
" will be safely stored in the swapfile, protected from powerloss / reset.
"
" Disadvantages: If a swapfile is present, you will be interrupted while
" entering insert mode.  (That is not actually true!  It only tells you after
" the edit.)
let g:NoSwapSuck_CreateSwapfileOnInsert = get(g:, 'NoSwapSuck_CreateSwapfileOnInsert', 1)

" Close (and remove) the swapfile every time the file is written
let g:NoSwapSuck_CloseSwapfileOnWrite = get(g:, 'NoSwapSuck_CloseSwapfileOnWrite', 0)

" Doing this here to prevent the initial message "Setting NO swapfile" from
" triggering a "Press ENTER to continue" message.  If you remove this, you may
" want an alternative solution for that.
setglobal noswapfile

augroup NoSwapSuck
  autocmd!

  " Turn swapfile off by default, for any newly opened buffer
  "autocmd BufReadPre * call s:ConsiderClosingSwapfile()
  if g:NoSwapSuck_CheckSwapfileOnLoad
    " No, turn it on, then off again, to check for existing swapfile :P
    "autocmd BufReadPre * set swapfile noswapfile
    autocmd BufReadPre * call s:SetSwapfileToCheck()
    autocmd BufReadPost * call s:ConsiderClosingSwapfile()
    " OK that would be good, except it interferes with the recover.vim plugin
    " which I am using.  So for me, I prefer to disable swapfile, and have
    " modified recover.vim to check anyway.
  else
    autocmd BufReadPost * call s:ConsiderClosingSwapfile()
    "autocmd BufReadPost * set swapfile | call s:ConsiderClosingSwapfile()
    " Hmmm that didn't work either.  :P  Because recover.vim needs 'swapfile' to
    " work.
    "
    " Gah this is difficult!  Can't set swapfile on old buffer, or we will write
    " an unwanted swapfile.  Can't set it on new buffer, cos it will popup the
    " message before recover.vim can do its magic!
    " Best solution: munge recover.vim to work without 'swapfile' set.
    " Alternatively, stop using recover.vim?!
    "
    " TODO: Perhaps we can handle the what-to-do-with-swap prompt ourself, by
    " listening for SwapExists, and setting 'r' or perhaps 'e'.  Will this be
    " enough to invoke recover.vim, or to inform the user what is going on?
  endif

  " Turn swapfile on when we actually start editing
  " CursorHold is a catch all; it will check quite often.
  autocmd CursorHold * call s:ConsiderCreatingSwapfile()
  "autocmd CursorHoldI * call s:ConsiderCreatingSwapfile()

  " It can be rather disruptive to enable the swapfile when we enter Insert
  " mode, because if an existing swapfile is found, editing will be
  " interrupted while Vim asks what to do next.
  "
  " (There is also a danger that the user will be typing characters to insert,
  " and these will get passed to the swapfile recovery prompt.)
  " (Although it seems the recover prompt does not show when we are in insert
  " mode, although it does interrupt the user a little!)
  "
  " But this is less of an issue since we started using CheckSwapfileOnLoad,
  " so we now enable it by default.
  "
  " Previously we only checked on InsertLeave, and never on InsertEnter.  The
  " disadvantage with that was that you might make a significant edit before
  " discovering the swapfile contains a more recent version of the file.
  if g:NoSwapSuck_CreateSwapfileOnInsert
    autocmd InsertEnter * call s:ConsiderCreatingSwapfile(1)
  endif

  " We always check when leaving Insert mode.
  " If the buffer was modified, a swapfile will be created.
  autocmd InsertLeave * call s:ConsiderCreatingSwapfile()

  " Since it's a global we have to keep switching it on/off when we switch
  " between buffers/windows, or we will end up creating swapfiles for buffers
  " which don't need them.
  "
  " Actually it is documented as a local but it seems to act as a global.
  "
  " (Or perhaps it is only when we open a new file, the last local value for
  " &swapfile is re-used...?)
  autocmd WinEnter * call s:ConsiderCreatingSwapfile()
  autocmd BufEnter * call s:ConsiderCreatingSwapfile()
  autocmd WinLeave * call s:ConsiderClosingSwapfile()
  autocmd BufLeave * call s:ConsiderClosingSwapfile()

  " If enabling these, exercise a little caution:
  " % is alleged to be inaccurate, <afile> is better.
  "autocmd BufWinLeave * call s:ConsiderClosingSwapfile()
  "autocmd BufWipeout * call s:ConsiderClosingSwapfile()

  if g:NoSwapSuck_CloseSwapfileOnWrite
    autocmd BufWritePost * call s:ConsiderClosingSwapfile()
  endif

augroup END

function! s:ConsiderClosingSwapfile()
  if g:NoSwapSuck_Enabled
    if &l:swapfile && !&modified
      echo "Setting NO swapfile"
      setlocal noswapfile
    endif
  endif
endfunction

function! s:ConsiderCreatingSwapfile(...)
  if g:NoSwapSuck_Enabled
    let about_to_be_modified = a:0 ? a:1 : 0
    if !&l:swapfile && ( &modified || about_to_be_modified )
      echo "Setting swapfile"
      setlocal swapfile
    endif
  endif
endfunction

function! s:SetSwapfileToCheck()
  if g:NoSwapSuck_Enabled
    echo "Checking swapfile for ".bufname('%')
    setlocal swapfile
  endif
endfunction

