" ShowOtherEnd by Joey
" Prints the line at the opposite end of % without actually going there, so in
" long files you can check the context of closing lines, such as:
"   endif  fi  }  struct  typedef  ]  )  }}}  ...

" TODO: Check if % jump leaves us on the same line
" DONE: Store and restore original position, in case % doesn't quite.
" TODO: Suppress scroll caused by cursor jump if possible.  (Defer display update.)
"       Failing suppression, just store scroll pos before and restore it after.
" TODO: Auto-activate when arriving on a line/char deemed to be suitable (see
"       list above).
" TODO: If auto-activating, then also trim length of message string, to avoid
"       "Press ENTER" message.  (See EchoShort in taglist.vim)
" CONSIDER: For fun, also show number of lines in the block.

" :command! ShowOtherEnd call ShowOtherEnd()

map <silent> <F9> :call ShowOtherEnd()<Enter>

function! ShowOtherEnd()

  let starty = getpos('.')[1]
  let startx = getpos('.')[2]

  normal %

  let fary = winline()
  if fary != starty

    " normal "syy
    normal 0"sy$

    let numlines = starty - fary
    echo @s . "   [".numlines." lines]"

  endif

  "" Another % is not guaranteed to take us back, some structures have more
  "" than 2 visitable nodes.
  " normal %
  " call setpos('.',[??,starty,startx,??])
  call cursor(starty,startx)

endfunction

