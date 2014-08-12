" Previous foldignore=# prevented folding of comment lines leading an indented section
setlocal foldignore=

setlocal comments=:##,:#

"" comment
":nmap <buffer> <F5> ^i# <Esc>j^
"" uncomment
":nmap <buffer> <F6> ^2xj^

" comment
:nmap <buffer> <F5> ^i#<Esc>j^
" uncomment
:nmap <buffer> <F6> ^1xj^

syntax match coffeeParens /[()]/
" highlight! link coffeeParens Function
" highlight! link coffeeParens coffeeStatement
highlight! coffeeParens cterm=bold ctermfg=cyan gui=bold guifg=#00b0b0
" highlight! coffeeParens cterm=bold ctermfg=cyan gui=bold guifg=#b0b000

" highlight! coffeeAssign ctermfg=cyan guifg=cyan
" highlight! coffeeAssign cterm=bold ctermfg=red gui=bold guifg=#886600
" highlight! coffeeAssign ctermfg=magenta guifg=#aa44aa
" highlight! coffeeAssign cterm=bold ctermfg=white gui=bold guifg=white
" highlight! coffeeAssign cterm=bold ctermfg=darkgrey gui=bold guifg=darkgrey
" highlight! coffeeAssign cterm=bold ctermfg=green gui=bold guifg=green
" highlight! coffeeAssign cterm=bold ctermfg=white gui=bold guifg=white
"" These days I only see coffeeAssign highlight properties in an object literal
highlight! coffeeAssign ctermfg=darkblue cterm=bold gui=bold guifg=#6666ff

" highlight! coffeeComment ctermfg=darkgrey cterm=bold gui=bold guifg=darkgrey
hi link coffeeComment Comment

" highlight! coffeeAssignSymbols cterm=bold ctermfg=yellow gui=bold " guifg=yellow
" highlight! coffeeAssignSymbols cterm=bold ctermfg=cyan gui=bold guifg=cyan
" highlight! coffeeAssignSymbols cterm=bold ctermfg=white gui=bold guifg=white
highlight! coffeeAssignSymbols cterm=bold ctermfg=yellow gui=bold guifg=yellow

highlight! coffeeObject cterm=bold ctermfg=magenta gui=bold guifg=magenta

" highlight! coffeeDot cterm=bold ctermfg=white gui=bold guifg=white

syntax match coffeeJustDot /\./
highlight! coffeeJustDot cterm=bold ctermfg=white gui=bold guifg=white


"" Stolen from basic.vim!

" We must prevent = and - from interfering with coffeeFunction -> and =>
" Should already fall under coffeeAssignSymbols
syn match OperatorEquals /=[^>]/he=e-1
highlight link OperatorEquals Operator

syn match OperatorPlus /+/
" BUG: despite the he, this check prevents the following char (e.g. a number) from being highlighted correctly.
syn match OperatorMinus /-[^>]/he=e-1
syn match OperatorMultiply /*/
syn match OperatorDivide /\//
highlight OperatorPlus ctermfg=green guifg=green
highlight OperatorMinus ctermfg=red guifg=red
highlight OperatorMultiply ctermfg=yellow guifg=yellow
highlight OperatorDivide ctermfg=red guifg=red

syn match OperatorOther /\(&&\|||\)/

" highlight link OperatorPlus Operator
" highlight link OperatorMinus Operator
" highlight link OperatorMultiply Operator
" highlight link OperatorDivide Operator
highlight link OperatorOther Operator

" I believe this should go upstream
" But it needs to come after our stupid OperatorDivide rule!
syn region  coffeeRegexpString     start=+/[^/*]+me=e-1 skip=+\\\\\|\\/+ end=+/[gi]\{0,2\}\s*$+ end=+/[gi]\{0,2\}\s*[;.,)\]}]+me=e-1 contains=@htmlPreproc oneline
hi coffeeRegexpString ctermfg=magenta guifg=magenta

