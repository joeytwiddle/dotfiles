" The original used cul and nocul to underline the newly reached line.
" DONE: I would prefer to change the bg colour of the line
"       This could be done with a temporary syntax+highlight (altho only
"       really works if the line is unique!).
" TODO: Still errors when dealing with '+'s, whether I escape them or not!

if exists('g:hiline') && g:hiline == 0
else

function! HighlightLine()
  " set cul
  let l:line = "FAIL"
  let l:line = GetRegAfter('""yy')
  " When i checked output of :syn HLCurrentLine, we had a nasty trailing '^@' char:
  if l:line == "" || l:line == "FAIL"
    echo "failed to get register got: ".l:line
    return
  endif
  " echo "got register: ".l:line
  " Sometimes we got back multiple lines, separated by ^@, which I think is one of the following:
  let l:line = substitute(l:line,'\(\r\|\n\|\0x0000\).*','','')
  if l:line == ""
    " call UnHighlightLine()
  else
    " Convert String to regexp, by escaping regexp special chars:
    " let l:pattern = substitute(l:line,'\([.^$\\][)(]\|\*\|\\\|"\|\~\)','\\\1','g')
    let l:pattern = substitute(l:line,'\([.^$\\][]\|\*\|\\\|\"\|\~\)','\\\1','g')
    let l:pattern = '^' . l:pattern . '$'
    " next line is a dummy to prevent the clear from complaining on the first run
    echo "got pattern: ".l:pattern
    execute 'syntax match HLCurrentLine "'.pattern.'"'
    execute 'syntax clear HLCurrentLine'
    execute 'syntax match HLCurrentLine "'.pattern.'"'
    execute 'highlight HLCurrentLine term=reverse cterm=none ctermbg=darkmagenta ctermfg=white guibg=darkmagenta guifg=white'
    "" Freezes vim: execute "sleep 5| call UnHighlightLine()"
  endif
endfunction

function! UnHighlightLine()
  " set nocul
  execute "syntax match HLCurrentLine +blah+"
  execute "syntax clear HLCurrentLine"
endfunction

function! Cursor_Moved()
  let cur_pos = winline()
  if g:last_pos == 0
    call HighlightLine()
    let g:last_pos = cur_pos
    return
  endif
  let diff = g:last_pos - cur_pos
  " if diff != 0
  if diff>1 || diff<-1
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

" autocmd CursorMoved,CursorMovedI * call Cursor_Moved()
autocmd CursorMoved * call Cursor_Moved()
autocmd CursorHold * call UnHighlightLine()
" autocmd CursorHold * call s:Cursor_Moved()

let g:last_pos = 0

" set updatetime=4000

endif

