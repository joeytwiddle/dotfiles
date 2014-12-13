" Allows you to review changes between the file saved on the disk and the working buffer.
" Or using the new DiffSplitAgainstFileOnDisk command, compares the two versions using a split window.

" Can be useful if Vim says "File changed on disk. (L)oad or (O)k?" you can
" select OK then do :DiffAgainstFileOnDisk to decide whether to overwrite
" (:w!) or read (:e!) the file.

" Can also be useful if Vim says there is a swapfile: you can (R)ecover it,
" diff it against the file on disk, and then decide whether to keep it or :e!

" It works by writing the current buffer to a temp-file, then it calls GNU diff, or whatever is set in DAFOD_diffcmd.

" TOTEST: Accidentally running on an unnamed buffer may give it name of tmpfile.  Not really a problem, just inconsistent.

command! DiffAgainstFileOnDisk call DiffAgainstFileOnDisk()

" Select a good default diffing program
if !exists("g:DAFOD_diffcmd")
  if executable("jdiffsimple") && !has("gui_running")
    let g:DAFOD_diffcmd = 'jdiffsimple -fine'
  elseif executable("prettydiff") && !has("gui_running")
    let g:DAFOD_diffcmd = 'prettydiff'
  else
    let g:DAFOD_diffcmd = 'diff'
  endif
endif

function! DiffAgainstFileOnDisk()
  :w! /tmp/working_copy.$USER
  ":vert diffsplit %
  ":!diff % /tmp/working_copy.$USER
  ":!diff % /tmp/working_copy.$USER | diffhighlight | more
  "exec "!" . g:DAFOD_diffcmd . " % /tmp/working_copy.$USER"
  exec "!" . g:DAFOD_diffcmd . " % /tmp/working_copy.$USER && echo '---- File and buffer are identical ----'"
  " BUG: Many of my color diff commands don't return the correct exit code anyway!
  " This is annoying because it comes *after* the "Pres ENTER" message :P
  "if !v:shell_error
  "  echo "File and buffer are identical!"
  "endif
  " Oh sick.  We can actually skip the "Press ENTER" message by performing
  " :call feedkeys("\r") before doing the exec.  However we might not want to
  " do that: if the files do differ, want want to show the diff!
endfunction

"" Some similar yummies:

"" Shows differences between the current buffer and the file on disk (with a split diff window).
"" From the manual :h DiffOrig
" command! DiffSplitAgainstFileOnDisk vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
"" TOTEST, with caution:
" command! ShowChangesSinceStarting normal "9999u" | w | normal "9999<C-r>" | DiffAgainstFileSplit
"" My version:
command! DiffSplitAgainstFileOnDisk call s:DiffSplitAgainstFileOnDisk()

function! s:DiffSplitAgainstFileOnDisk()

  " A bit heavy, use manually only in emegencies: bufdo diffoff

  " Create a new buffer in a split window, read the "alternate" file contents,
  " and clear the messy blank line.
  vert new
  r #
  0d_

  " We don't want it to interact with the file, because 
  setlocal buftype=nofile

  " Give it a meaningful name
  let tmp_title="[Disk_view_".bufname('#')."]"
  silent exec "file " tmp_title

  " setlocal nobuflisted

  " Perhaps the following are not needed.  Although it doesn't auto-close, it
  " does let me close it without complaining that it was changed earlier.

  " I don't want this buffer to hang around; we will make it disappear as soon
  " as it is no longer visible (from closing window or switching buffer).
  setlocal bufhidden=delete

  " Because we are deleting on hide, we may lose any edits made.  We avoid
  " that by blocking edits.  We can't do this until after our init edits.
  setlocal nomodifiable

  diffthis
  wincmd p
  diffthis

endfunction

