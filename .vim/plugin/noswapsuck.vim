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

" Couldn't get it working well with recover.vim =(
"finish

" Doing this here to prevent the initial message "Setting NO swapfile" from
" triggering a "Press ENTER to continue" message.  If you remove this, you may
" want an alternative solution for that.
set noswapfile

if !exists("g:NoSwapSuck_CheckSwapfileOnLoad")
  let g:NoSwapSuck_CheckSwapfileOnLoad = 1
endif

augroup NoSwapSuck
  autocmd!

  " Turn swapfile off by default, for any newly opened buffer
  "autocmd BufReadPre * call s:ConsiderClosingSwapfile()
  if g:NoSwapSuck_CheckSwapfileOnLoad
    " No, turn it on, then off again, to check for existing swapfile :P
    "autocmd BufReadPre * set swapfile noswapfile
    autocmd BufReadPre * set swapfile
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
  autocmd CursorHold * call s:ConsiderCreatingSwapfile()
  "autocmd CursorHoldI * call s:ConsiderCreatingSwapfile()
  "autocmd InsertEnter * call s:ConsiderCreatingSwapfile()
  autocmd InsertLeave * call s:ConsiderCreatingSwapfile()
  " Since it's a global (yeah great) we have to keep switching it on/off
  " when we switch between buffers/windows.
  autocmd WinLeave * call s:ConsiderClosingSwapfile()
  autocmd WinEnter * call s:ConsiderCreatingSwapfile()
  autocmd BufLeave * call s:ConsiderClosingSwapfile()
  autocmd BufEnter * call s:ConsiderCreatingSwapfile()

augroup END

function! s:ConsiderClosingSwapfile()
  if &swapfile && !&modified
    echo "Setting NO swapfile"
    setlocal noswapfile
  endif
endfunction

function! s:ConsiderCreatingSwapfile()
  if !&swapfile && &modified
    echo "Setting swapfile"
    setlocal swapfile
  endif
endfunction

