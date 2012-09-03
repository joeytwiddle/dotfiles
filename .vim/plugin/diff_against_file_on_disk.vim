"" Allows you to review changes between saved file and working buffer.
"" Writes to a temp-file, then calls GNU diff, or whatever is set in DAFOD_diffcmd.

"" TOTEST: Accidentally running on unnamed buffer will give it name of tmpfile.  Bad?

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

