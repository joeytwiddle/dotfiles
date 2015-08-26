source ~/.vim/after/syntax/all.vim

:set tabstop=2
:set shiftwidth=2
" :set expandtab
"" Dot-space is hard to see.  Stick with defaults!
" :set listchars=tab:.\ ,trail:$

"" comment
":nnoremap <buffer> <F5> ^i# <Esc>j^
"" uncomment
":nnoremap <buffer> <F6> ^2xj^
"" comment
:nnoremap <buffer> <F5> ^i#<Esc>j^
"" uncomment
:nnoremap <buffer> <F6> ^xj^
" indent
:nnoremap <buffer> <F7> ^i  <Esc>j^
" undent
:nnoremap <buffer> <F8> 02xj^

"" TODO: Below will be usable only if we check that we are at start of line / in whitespace, and ^ if not.
" comment
":nnoremap <buffer> <F5> i#<Esc>j
" uncomment
":nnoremap <buffer> <F6> ^xj^

" :syntax clear shCaseCommandSub

" Make these work for modifiable only
" :autocmd BufReadPost    *.* set ts=8 | set expandtab | retab | set ts=2 | set noexpandtab | retab!
" :autocmd BufWritePre,FilterWritePre    *.* set expandtab | retab!
" :set tabstop=2
" :set shiftwidth=2

" Appears to be # by default which sucks for my shellscripts
:set foldignore=

" I like to use ## comments in bash, so let's tell Vim about them.
" I just added the extra b:## rule to the defaults.
" :set comments=s1:/*,mb:*,ex:*/,://,b:#,b:##,:%,:XCOMM,n:>,fb:-
"" BUG: Breaks in the presence of "m:\ " because the \ gets lost!
" exec "set comments=" . &comments . ",b:##"
"" Fixed:   :)
let &comments = &comments . ",b:##"

" :hi PreProc term=bold ctermfg=magenta gui=bold guifg=magenta

" syn link shTodo Todo contained=XXX FIXME TODO COMBAK

"" See also the jTodo rule in plugin/joeysyntax.vim
" Original: syn keyword	shTodo	contained		COMBAK FIXME TODO XXX
syn clear	shTodo
syn keyword	shTodo	contained		COMBAK FIXME TODO XXX NOTE CONSIDER TEST TESTING TOTEST DONE
syn keyword	shImportantComment	contained		BUG ERROR
hi link shImportantComment shTodo
syn cluster	shCommentGroup	contains=shTodo,@Spell,shImportantComment

