" Allows you to review changes between saved file and working buffer.
" Writes buffer to a temp-file, then calls GNU diff, or whatever is set in DAFOD_diffcmd.

" Could be useful if Vim says "File changed on disk. (L)oad or (O)k?" you can
" select OK then do :DiffAgainstFileOnDisk to decide whether to overwrite
" (:w!) or read (:e!) the file.

"" TOTEST: Accidentally running on unnamed buffer may give it name of tmpfile.  Bad?

command! DiffAgainstFileOnDisk call DiffAgainstFileOnDisk()

" Select a good default diffing program
if !exists("g:DAFOD_diffcmd")
  if executable("jdiffsimple")
    let g:DAFOD_diffcmd = 'jdiffsimple -fine'
  elseif executable("prettydiff")
    let g:DAFOD_diffcmd = 'prettydiff'
  else
    let g:DAFOD_diffcmd = 'diff'
  endif
endif

function! DiffAgainstFileOnDisk()
  :w! /tmp/working_copy
  " :vert diffsplit %
  " :!diff % /tmp/working_copy
  " :!diff % /tmp/working_copy | diffhighlight | more
  exec "!" . g:DAFOD_diffcmd . " % /tmp/working_copy"
endfunction

