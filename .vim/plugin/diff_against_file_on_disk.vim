" Allows you to review changes between saved file and working buffer.
" Writes buffer to a temp-file, then calls GNU diff, or whatever is set in DAFOD_diffcmd.

" Can be useful if Vim says "File changed on disk. (L)oad or (O)k?" you can
" select OK then do :DiffAgainstFileOnDisk to decide whether to overwrite
" (:w!) or read (:e!) the file.

" Can also be useful if Vim says there is a swapfile: you can (R)ecover it,
" diff it against the file on disk, and then decide whether to keep it or :e!

"" TOTEST: Accidentally running on unnamed buffer may give it name of tmpfile.  Not really a problem, just inconsistent.

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

"" Some similar yummies:

"" Shows differences between the current buffer and the file on disk (with a split diff window).
command! DiffAgainstFileSplit vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
"" TOTEST:
" command! ShowChangesSinceStarting normal "9999u" | w | normal "9999<C-r>" | DiffAgainstFileSplit

