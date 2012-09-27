" ShowOtherEnd by Joey
" Prints the line at the opposite end of % without actually going there, so in
" long files you can check the context of closing lines, such as:
"   endif  fi  }  struct  typedef  ]  )  }}}  ...

" TODO: Check if % jump leaves us on the same line
" TODO: Store and restore original position, in case % doesn't quite.
" TODO: Suppress scroll caused by cursor jump if possible.  (Defer display update.)
" TODO: Auto-activate when arriving on a line/char deemed to be suitable (see
"       list above).
" CONSIDER: For fun, also show number of lines in the block.

" :command! ShowOtherEnd call ShowOtherEnd()

map <silent> <F9> :call ShowOtherEnd()<Enter>

function! ShowOtherEnd()

  let startx = wincol()
  let starty = winline()

  normal %
  let fary = winline()
  " normal "syy
  normal 0"sy$
  "" This is not guaranteed to take us back, some structures have more than 2
  "" visitable nodes.
  " normal %
  call cursor(starty,startx)

  echo @s

endfunction

