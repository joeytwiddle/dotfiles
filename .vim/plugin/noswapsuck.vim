" Creating a swapfile for every FUCKING file we open just sucks major balls.
" I have a zillion swapfiles on my system, 99% of which are identical to the
" file, and 0.9% of which are OLD fucking versions of the file.
" If I am lucky, 1 in 1000 times I am asked to recover a swapfile, it actually
" contains unwritten text which could have been lost zomg.

" Anyway rant over.
" This plugin only enables the swapfile when we start modifying a buffer.
" Like duh.

" Disadvantages / BUGs:
" Because it sets swapfile in the middle of editing, that is the moment when
" it will prompt you if it finds an old swapfile.
" To work around this, perhaps we should check for a swapfile the first time
" we open a file?
" For the moment, disabling on InsertEnter and CursorHoldI.  That means we
" might not create a swapfile during the first edit.  Gah.

" To easily see whether a swapfile is currently being used, add an indicator to your statusline.
"
"   let &statusline = substitute(&statusline, '%=', '%{ \&swapfile ? " swap" : "" }%=', '')
"
" This does not work yet:
"
"   set statusline.=%{\&swapfile?"swap":""}

" Allows plugin to be enabled/disabled from config and also at runtime.
let g:NoSwapSuck_Enabled = get(g:, 'NoSwapSuck_Enabled', 1)

" When opening a file for the first time, will `:set swapfile` to force Vim to
" check if there is a swapfile present for that file.
let g:NoSwapSuck_CheckSwapfileOnLoad = get(g:, 'NoSwapSuck_CheckSwapfileOnLoad', 1)

" Create a swapfile immediately before entering Insert mode.
" Advantages: If you do a long edit without leaving insert mode, your changes
" will be safely stored in the swapfile.
" Disadvantages: If a swapfile is present, you will be interrupted while
" entering insert mode.
let g:NoSwapSuck_CreateSwapfileOnInsert = get(g:, 'NoSwapSuck_CreateSwapfileOnInsert', 1)

if !g:NoSwapSuck_Enabled
  finish
endif

" Doing this here to prevent the initial message "Setting NO swapfile" from
" triggering a "Press ENTER to continue" message.  If you remove this, you may
" want an alternative solution for that.
set noswapfile

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
    " Gah this is difficult!  Can't set swapfile on old buffer, or we will write
    " an unwanted swapfile.  Can't set it on new buffer, cos it will popup the
    " message before recover.vim can do its magic!
    " Best solution: munge recover.vim to work without 'swapfile' set.
    " Alternatively, stop using recover.vim?!
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

  " Since it's a global (yeah great) we have to keep switching it on/off
  " when we switch between buffers/windows.
  autocmd WinLeave * call s:ConsiderClosingSwapfile()
  autocmd WinEnter * call s:ConsiderCreatingSwapfile()
  autocmd BufLeave * call s:ConsiderClosingSwapfile()
  autocmd BufEnter * call s:ConsiderCreatingSwapfile()

augroup END

function! s:ConsiderClosingSwapfile()
  if g:NoSwapSuck_Enabled
    if &swapfile && !&modified
      echo "Setting NO swapfile"
      setlocal noswapfile
    endif
  endif
endfunction

function! s:ConsiderCreatingSwapfile(...)
  if g:NoSwapSuck_Enabled
    let about_to_be_modified = a:0 ? a:1 : 0
    if !&swapfile && ( &modified || about_to_be_modified )
      echo "Setting swapfile"
      setlocal swapfile
    endif
  endif
endfunction

function! s:SetSwapfileToCheck()
  if g:NoSwapSuck_Enabled
    set swapfile
  endif
endfunction

