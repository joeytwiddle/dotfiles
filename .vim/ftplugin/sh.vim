setlocal iskeyword-=.

command! Shebang normal ggO#!/usr/bin/env bash<Esc><C-O>

" Add a log command for the currently selected expression:
"vnoremap <buffer> <Leader>log yoecho "[log] <C-R>": $<C-R>""<Esc>

" Same, but display the filename instead of "log", with the extension stripped.
vnoremap <buffer> <Leader>log yoecho "[<C-R>=expand('%:t:r')<Enter>] <C-R>": $<C-R>""<Esc>

" When nothing is selected, select the word (or WORD) under the cursor, then invoke the vmap.
nmap <buffer> <Leader>log viw<Leader>log
nmap <buffer> <Leader>Log viW<Leader>log

" Indent with spaces (popular)
"set expandtab tabstop=2 shiftwidth=2
" Indent with tabs (correct: https://stackoverflow.com/a/33817423/99777)
set noexpandtab tabstop=3 shiftwidth=3

" comment
nnoremap <buffer> <F5> ^i#<Esc>j^
" uncomment
nnoremap <buffer> <F6> ^xj^
" indent
nnoremap <buffer> <F7> ^i<Tab><Esc>j^
" undent
nnoremap <buffer> <F8> 02xj^

" TODO: Below will be usable only if we check that we are at start of line / in whitespace, and ^ if not.
" comment
"nnoremap <buffer> <F5> i#<Esc>j
" uncomment
"nnoremap <buffer> <F6> ^xj^

"syntax clear shCaseCommandSub

" Make these work for modifiable only
"autocmd BufReadPost    *.* set ts=8 | set expandtab | retab | set ts=2 | set noexpandtab | retab!
"autocmd BufWritePre,FilterWritePre    *.* set expandtab | retab!

" Appears to be # by default which sucks for my shellscripts
set foldignore=

" I like to use ## comments in bash, so let's tell Vim about them.
" I just added the extra b:## rule to the defaults.
"set comments=s1:/*,mb:*,ex:*/,://,b:#,b:##,:%,:XCOMM,n:>,fb:-
" BUG: Breaks in the presence of "m:\ " because the \ gets lost!
"exec "set comments=" . &comments . ",b:##"
" Fixed:   :)
let &comments = &comments . ",b:##"

if exists("*SyntaxRange#Include")
  command! -buffer HereDocHighlightSh call SyntaxRange#Include('<< !$', '^!$', 'sh', 'shCmdSubRegion')
endif
