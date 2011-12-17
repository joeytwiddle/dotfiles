source ~/.vim/after/syntax/all.vim

:set tabstop=2
:set shiftwidth=2
" :set expandtab
"" Dot-space is hard to see.  Stick with defaults!
" :set listchars=tab:.\ ,trail:$

" comment
:map <F5> ^i# <Esc>j^
" uncomment
:map <F6> ^2xj^
" indent
:map <F7> ^i  <Esc>j^
" undent
:map <F8> 02xj^

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
exec "set comments=" . &comments . ",b:##"

" :hi PreProc term=bold ctermfg=magenta gui=bold guifg=magenta

