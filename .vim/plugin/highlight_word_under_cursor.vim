" TODO: Refactor out the expand("<cword>") - maybe pass it into " HighlightWord().
" TODO: In fact <cword> isn't really what we want - it captures *nearest* word
" If we are over whitespace (desirable/not?), it includes '*' in the caught
" word (fiddly wrt C pointer vars).
" TODO: Can slow vim down.  if we are scrolling about the file, (if we've done
" HighlightWord three times in the last second, then skip highlighting until
" user has calmed down.

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
    let l:pattern = substitute(l:word,'\([.^$*\\]\|\[\|\]\|\\\|\"\|\~\)','\\\1','g')
    if exists('g:hiword_partial') && g:hiword_partial != 0
      let l:pattern = l:pattern
    else
      let l:pattern = '\<' . l:pattern . '\>' " highlight only whole word matches
    endif

    " echo "got pattern: ".l:pattern

    " next line is a dummy to prevent the clear from complaining on the first run
    execute 'syntax match HLCurrentWord "'.pattern.'"'
    execute 'syntax clear HLCurrentWord'
    execute 'syntax match HLCurrentWord "'.pattern.'"'
    " execute 'highlight HLCurrentWord term=reverse cterm=none ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white'
    " execute 'highlight HLCurrentWord term=none cterm=none ctermbg=blue ctermfg=green guibg=darkblue guifg=green'
    " execute 'highlight HLCurrentWord term=bold cterm=bold ctermfg=green guifg=green'
    " execute 'highlight HLCurrentWord ctermfg=red guifg=red'
    " 121=light green, 179=light orange
    " execute 'highlight HLCurrentWord ctermfg=180 guifg=orange'
    " 130,166,172,173,203,208,214
    " execute 'highlight HLCurrentWord ctermfg=209 guifg=orange'
    execute 'highlight HLCurrentWord ctermfg=red guifg=orange'
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
    " TODO: Isn't this inefficient, causing syntax calls EVERY time we move?!
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

" " autocmd CursorMoved,CursorMovedI * call Cursor_Moved()
" autocmd CursorMoved * call Cursor_Moved()
" autocmd CursorHold * call UnHighlightWord()
" " autocmd CursorHold * call s:Cursor_Moved()
" " set updatetime=4000

" autocmd CursorMoved * call UnHighlightWord()
autocmd CursorHold * call Cursor_Moved()
" autocmd CursorMoved * call UnHighlightWord()
set updatetime=500

let g:last_pos = 0
let s:lastWord = ""

endif

