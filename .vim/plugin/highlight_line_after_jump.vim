" TODO: I would prefer to change the bg colour of the line
"       This could be done with a temporary syntax+highlight (altho only
"       really works if the line is unique!).

" From: http://vim.wikia.com/wiki/Highlight_cursor_line_after_cursor_jump

function s:Cursor_Moved()
  let cur_pos = winline()
  if g:last_pos == 0
    set cul
    let g:last_pos = cur_pos
    return
  endif
  let diff = g:last_pos - cur_pos
  if diff > 1 || diff < -1
    set cul
  else
    set nocul
  endif
  let g:last_pos = cur_pos
endfunction
autocmd CursorMoved,CursorMovedI * call s:Cursor_Moved()
let g:last_pos = 0
