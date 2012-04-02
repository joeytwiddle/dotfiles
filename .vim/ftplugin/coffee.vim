" Language:    CoffeeScript
" Maintainer:  Mick Koch <kchmck@gmail.com>
" URL:         http://github.com/kchmck/vim-coffee-script
" License:     WTFPL

if exists("b:did_coffee_ftpluginn")
  finish
endif

let b:did_coffee_ftplugin = 1

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=s:###,m:\ ,e:###,:#
setlocal commentstring=#\ %s

" Compile the current file on write.
" Problem: it does not release us back to vim cleanly and quickly.
" Sometimes keys are swallowed, and crap appears in the text!
if exists("coffee_compile_on_save")
  "autocmd BufWritePost,FileWritePost *.coffee silent !coffee -c <afile> &
  " Joey's attempt at improvement:
  autocmd BufWritePost,FileWritePost *.coffee silent !/bin/sh -c "coffee -c <afile>" &
endif

"" Added by Joey (perhaps futilely trying to undo my config which has not yet run!):
:set ts=2
:set sw=2
:set expandtab
let &comments=":##,".&comments

