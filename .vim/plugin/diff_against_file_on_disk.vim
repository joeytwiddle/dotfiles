"" Allows you to review changes between saved file and working buffer.
"" Write to a temp-file, then calls GNU diff.

:command! DiffAgainstFileOnDisk call DiffAgainstFileOnDisk()

function! DiffAgainstFileOnDisk()
  :w! /tmp/working_copy
  " :vert diffsplit %
  :!diff % /tmp/working_copy
  " :!diff % /tmp/working_copy | diffhighlight | more
endfunction

