source ~/.vim/after/syntax/all.vim

" :hi PreProc term=bold ctermfg=magenta gui=bold guifg=magenta

" syn link shTodo Todo contained=XXX FIXME TODO COMBAK

"" See also the jTodo rule in plugin/joeysyntax.vim
" Original: syn keyword	shTodo	contained		COMBAK FIXME TODO XXX
syn clear	shTodo
syn keyword	shTodo	contained		COMBAK FIXME TODO XXX NOTE CONSIDER TEST TESTING TOTEST DONE
syn keyword	shImportantComment	contained		BUG ERROR
hi link shImportantComment shTodo
syn cluster	shCommentGroup	contains=shTodo,@Spell,shImportantComment

