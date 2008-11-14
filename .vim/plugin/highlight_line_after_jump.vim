" The original used cul and nocul to underline the newly reached line.
" DONE: I would prefer to change the bg colour of the line
"       This could be done with a temporary syntax+highlight (altho only
"       really works if the line is unique!).

function! HighlightLine()
  " set cul
  let l:line = GetRegAfter('""yy')
  " echo "line = ".l:line
  " checking :syn output, we have a nasty trailing '^@' char
  if l:line != ""
    let l:pattern = '^' . substitute(l:line,'.'.'$','','') . '$'
    " next line is a dummy to prevent the clear from complaining on the first run
    execute "syntax match HLCurrentLine +".pattern."+"
    execute "syntax clear HLCurrentLine"
    execute "syntax match HLCurrentLine +".pattern."+"
    execute "highlight HLCurrentLine term=reverse cterm=none ctermbg=magenta ctermfg=white guibg=magenta guifg=white"
    "" Freezes vim: execute "sleep 5| call UnHighlightLine()"
  endif
endfunction

function! UnHighlightLine()
  " set nocul
  execute "syntax match HLCurrentLine +blah+"
  execute "syntax clear HLCurrentLine"
endfunction

function s:Cursor_Moved()
  let cur_pos = winline()
  if g:last_pos == 0
    call HighlightLine()
    let g:last_pos = cur_pos
    return
  endif
  let diff = g:last_pos - cur_pos
  if diff > 1 || diff < -1
    call HighlightLine()
  else
    call UnHighlightLine()
  endif
  let g:last_pos = cur_pos
endfunction

function! GetRegAfter(cmd)
  let l:save_reg = @"
  let @" = ""
  normal ""yy
  let l:retv = @"
  let @" = l:save_reg
  return l:retv
endfunction

autocmd CursorMoved,CursorMovedI * call s:Cursor_Moved()
autocmd CursorHold * call UnHighlightLine()
" autocmd CursorHold * call s:Cursor_Moved()

let g:last_pos = 0

set updatetime=500

