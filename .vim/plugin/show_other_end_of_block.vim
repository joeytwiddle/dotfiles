" TODO: Check if % jump leaves us on the same line
" TODO: Store and restore original position, in case % doesn't quite.
" TODO: Suppress scroll caused by cursor jump if possible.  (Defer display update.)
" TODO: Auto-activate when arriving on a line/char deemed to be suitable, e.g. endif, fi, }, typedef, struct, ...

" :command! ShowOtherEnd call ShowOtherEnd()

map <silent> <F9> :call ShowOtherEnd()<Enter>

function! ShowOtherEnd()

  normal %
  " normal "syy
  normal 0"sy$
  normal %

  echo @s

endfunction

