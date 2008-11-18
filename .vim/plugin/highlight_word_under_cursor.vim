" The original used cul and nocul to underline the newly reached line.
" DONE: I would prefer to change the bg colour of the line
"       This could be done with a temporary syntax+highlight (altho only
"       really works if the line is unique!).

if exists('g:hiword') && g:hiword == 0
else

function! HighlightWord()
  " set cul
  let l:word = "FAIL"
  " let l:word = GetRegAfter('""yy')
  " let l:word = '\<'.expand("<cword>").'\>'
  let l:word = expand("<cword>")
  " When i checked output of :syn HLCurrentWord, we had a nasty trailing '^@' char:
  if l:word == "FAIL" || l:word == ""
    " echo "failed to get register got: ".l:word
    call UnHighlightWord()
    return
  endif
  " echo "got register: ".l:word
  let l:word = substitute(l:word,'\0x0000$','','')
  if l:word != ""
    " Convert String to regexp, by escaping regexp special chars:
    " let l:pattern = substitute(l:word,'\([.^$\\+][)(]\|\*\)','\\\1','g')
    " let l:pattern = substitute(l:word,'\([.^$]\|\*\|\\\|\"\|\~\|\[\|\]\|+\)','\\\1','g')
    let l:pattern = substitute(l:word,'\([.^$\\]\|\[\|\]\*\|\\\|\"\|\~\)','\\\1','g')
    " let l:pattern = '^' . l:pattern . '$'
    " let l:pattern = '\<' . l:pattern . '\>'
    let l:pattern = l:pattern
    " echo "got pattern: ".l:pattern
    " next line is a dummy to prevent the clear from complaining on the first run
    execute 'syntax match HLCurrentWord "'.pattern.'"'
    execute 'syntax clear HLCurrentWord'
    execute 'syntax match HLCurrentWord "'.pattern.'"'
    execute 'highlight HLCurrentWord term=reverse cterm=none ctermbg=red ctermfg=white guibg=darkred guifg=white'
    "" Freezes vim: execute "sleep 5| call UnHighlightWord()"
  endif
endfunction

function! UnHighlightWord()
  " set nocul
  execute "syntax match HLCurrentWord +blah+"
  execute "syntax clear HLCurrentWord"
endfunction

function! Cursor_Moved()
  let l:word = expand("<cword>")
  if (l:word == s:lastWord) " e.g. user has moved 1 char in the word - hide highlighting now.
    call UnHighlightWord()
  else
    call HighlightWord()
    let s:lastWord = l:word
  endif
  " let cur_pos = winline()
  " if g:last_pos == 0
    " call HighlightWord()
    " let g:last_pos = cur_pos
    " return
  " endif
  " let diff = g:last_pos - cur_pos
  " " let diff = -100
  " " if diff > 1 || diff < -1
  " " if diff != 0
    " call HighlightWord()
  " " else
    " " call UnHighlightWord()
  " " endif
  " let g:last_pos = cur_pos
endfunction

" function! GetRegAfter(cmd)
  " let l:save_reg = @"
  " let @" = ""
  " normal ""yy
  " let l:retv = @"
  " let @" = l:save_reg
  " return l:retv
" endfunction

" autocmd CursorMoved,CursorMovedI * call Cursor_Moved()
autocmd CursorMoved * call Cursor_Moved()
autocmd CursorHold * call UnHighlightWord()
" autocmd CursorHold * call s:Cursor_Moved()

let g:last_pos = 0
let s:lastWord = ""

" set updatetime=4000

endif

