source ~/.vim/after/syntax/all.vim

" comment
:map <F5> ^i# <Esc>j^
" uncomment
:map <F6> ^2xj^
" indent
:map <F7> ^i  <Esc>j^
" undent
:map <F8> 02xj^

" Make these work for modifiable only
" :autocmd BufReadPost    *.* set ts=8 | set expandtab | retab | set ts=2 | set noexpandtab | retab!
" :autocmd BufWritePre,FilterWritePre    *.* set expandtab | retab!
" :set tabstop=2
" :set shiftwidth=2
