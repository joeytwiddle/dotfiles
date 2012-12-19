" TODO: Refactor out the expand("<cword>") - maybe pass it into " HighlightWord().
" TODO: In fact <cword> isn't really what we want - it captures *nearest* word
" If we are over whitespace (desirable/not?), it includes '*' in the caught
" word (fiddly wrt C pointer vars).
" TODO: Can slow vim down.  if we are scrolling about the file, (if we've done
" HighlightWord three times in the last second, then skip highlighting until
" user has calmed down.
" BUG: Is often incapable of highlighting, because syntax has already matched
" the text, and that syntax rule does not allow sub-parsing (contains).
" NOTE: If we want to work independently of updatetime, we could use :sleep

" 20120618 - Switched to using match instead of a syntax rule, since I can't
"            see a way to do containedin=*.  This stops the temporary rule
"            from breaking the syntax parser and slowing vim down.
"
"            One disadvantage is that these matches will override and mask the
"            last hlsearch performed with /, so that may disappear and appear,
"            unlike the original behaviour.

" To disable the script, set g:hiword=0 in your .vimrc, or at runtime
if exists('g:hiword') && g:hiword == 0
  finish
endif

" if exists('*HighlightWord')

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
    let l:pattern = substitute(l:word,'\([.^$*\\/]\|\[\|\]\|\\\|\"\|\~\)','\\\1','g')
    if exists('g:hiword_partial') && g:hiword_partial != 0
      let l:pattern = l:pattern
    else
      let l:pattern = '\<' . l:pattern . '\>' " highlight only whole word matches
    endif

    " echo "got pattern: ".l:pattern

    " next line is a dummy to prevent the clear from complaining on the first run
    " execute 'syntax match HLCurrentWord "'.pattern.'"'
    " execute 'silent! syntax clear HLCurrentWord'
    " execute 'silent! syntax match HLCurrentWord "'.pattern.'"'
    execute "match HLCurrentWord /".pattern."/"
   "" Freezes vim: execute "sleep 5| call UnHighlightWord()"
  endif
endfunction

function! UnHighlightWord()
  " set nocul
  " execute "syntax match HLCurrentWord +blah+"
  " execute "silent! syntax clear HLCurrentWord"
  execute "match"
endfunction

function! HW_Cursor_Moved()
  if exists('g:hiword') && g:hiword == 0
    return
  endif
  " I rarely want to use this on plugin/help windows, it's usually a distraction.
  if !&modifiable
    return
  endif
  let l:word = expand("<cword>")
  if (l:word == s:lastWord) " e.g. user has moved 1 char in the word - hide highlighting now.
    " echo "User moved within word"
    " or we have just been called twice =/
    call UnHighlightWord()
    " TODO: Isn't this inefficient, causing syntax calls EVERY time we move?!
  else
    call HighlightWord()
    let s:lastWord = l:word
  endif
endfunction

augroup HighlightWordUnderCursor
  autocmd!
  "" We use autocmd! to clear any existing autocmds registered on that event.
  " autocmd CursorMoved * call UnHighlightWord()
  autocmd CursorHold * call HW_Cursor_Moved()
augroup END

" set updatetime=500
"" On rather long files with complex syntax, this operation can be rather
"" heavy, and lock vim up a bit.  So we run it less often that the ideal.
" set updatetime=1500
"" Do not set updatetime at all.  Use the user/default value.

let s:lastWord = ""

if !hlexists("HLCurrentWord")
  " highlight HLCurrentWord cterm=underline gui=underline   " Problem: The match blocks any existing highlighting, so ends up looking Normal.
  " highlight HLCurrentWord term=reverse cterm=none ctermbg=darkgreen ctermfg=white guibg=darkgreen guifg=white
  " highlight HLCurrentWord term=none cterm=none ctermbg=blue ctermfg=green guibg=darkblue guifg=green
  " highlight HLCurrentWord term=bold cterm=bold ctermfg=green guifg=green
  " highlight HLCurrentWord ctermfg=red guifg=red
  " 121=light green, 179=light orange
  " highlight HLCurrentWord ctermfg=180 guifg=orange
  " 130,166,172,173,203,208,214
  " highlight HLCurrentWord ctermfg=209 guifg=orange
  highlight HLCurrentWord ctermfg=red guifg=orange
endif

