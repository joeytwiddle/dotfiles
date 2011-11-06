" Highlights the line the cursor is on, but only after jumping multiple lines,
" and only for a short while.  Can use cursorline, or its own implementation.

if exists('g:hiline') && g:hiline == 0
  finish
endif

if !exists('g:hiline_use_cursorline')
  let g:hiline_use_cursorline = 1
endif

if !exists('g:hiline_min_lines')
  let g:hiline_min_lines = 2
endif

function! HighlightLine()
  if exists('g:hiline') && g:hiline == 0
    return
  endif
  " set cul
  let l:line = "FAIL"
  " let l:line = GetRegAfter('""yy')
  let l:line = getline(".")
  " When i checked output of :syn HLCurrentLine, we had a nasty trailing '^@' char:
  if l:line == "FAIL"
    echo "failed to get register got: ".l:line
    return
  endif
  " echo "got register: ".l:line
  " Sometimes we got back multiple lines, separated by ^@, which I think is one of the following:
  let l:line = substitute(l:line,'\(\r\|\n\|\0x0000\).*','','')
  " We still highlight empty lines, simply to ensure we unhighlight the
  " previous focused line.
  if 0 && l:line == ""
    " call UnHighlightLine()
  else
    " Convert String to regexp, by escaping regexp special chars:
    " let l:pattern = substitute(l:line,'\([.^$\\][)(]\|\*\|\\\|"\|\~\)','\\\1','g')
    " let l:pattern = substitute(l:line,'\([.^$\\][]\|\*\|\\\|\"\|\~\)','\\\1','g')
    "" BUG: Does not create a suitable regexp for all inputs.
    "" For example, the next line breaks the algorithm on the next line!
    let l:pattern = substitute(l:line,'\([.^$*\\][]\|\\\|\"\|\~\)','\\\1','g')
    let l:pattern = '^' . l:pattern . '$'

    " echo "got pattern: ".l:pattern

    if g:hiline_use_cursorline
      set cul
    else
      "" This line was a dummy to prevent the clear from complaining on the first run
      " execute 'syntax match HLCurrentLine "'.pattern.'" contains=ALL'
      "" But now we use silent!
      execute 'silent! syntax clear HLCurrentLine'
      "" Also use silent for the match, in case our pattern is invalid.
      execute 'silent! syntax match HLCurrentLine "'.pattern.'"'
      " I tried contains=ALL but this would kill the highlight beneath chars
      " which matched other rules.
      "" Freezes vim: execute "sleep 5| call UnHighlightLine()"
    endif
  endif
endfunction

function! UnHighlightLine()
  if g:hiline_use_cursorline
    set nocul
  endif
  execute "silent! syntax clear HLCurrentLine"
endfunction

function! HL_Cursor_Moved()
  "" Line on screen - activates when cursor has moved visually.
  let cur_pos = winline()
  "" Line in file - activates when position has moved within file.
  " let cur_pos = getpos(".")[1]
  " Note if we have just switched window, last_pos will be from the previous
  " window, so we also check last_win.
  let diff = s:last_pos - cur_pos
  " echo "Comparing: ".s:last_pos." ~ ".cur_pos
  " let diff=99
  " if diff != 0
  if s:last_win!=winnr() || diff>=g:hiline_min_lines || diff<=-g:hiline_min_lines
    call HighlightLine()
  else
    call UnHighlightLine()
  endif
  let s:last_pos = cur_pos
  let s:last_win = winnr()
endfunction

function! GetRegAfter(cmd)
  let l:save_reg = @"
  let @" = ""
  normal ""yy
  let l:retv = @"
  let @" = l:save_reg
  return l:retv
endfunction

augroup HighlightLineAfterJump
  autocmd!
  " autocmd CursorMoved,CursorMovedI * call HL_Cursor_Moved()
  autocmd CursorMoved * call HL_Cursor_Moved()
  autocmd CursorHold * call UnHighlightLine()
  " autocmd CursorHold * call s:HL_Cursor_Moved()
  autocmd WinLeave * call UnHighlightLine()
augroup END

set updatetime=1000

let s:last_pos = -1
let s:last_win = -1

" set updatetime=4000

highlight link HLCurrentLine CursorLine

