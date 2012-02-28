" Previous foldignore=# prevented folding of comment lines leading an indented section
setlocal foldignore=

setlocal comments=:##,:#

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
highlight! coffeeAssign ctermfg=darkblue cterm=bold gui=bold guifg=white

highlight! coffeeComment ctermfg=darkgrey cterm=bold gui=bold guifg=darkgrey

" highlight! coffeeAssignSymbols cterm=bold ctermfg=yellow gui=bold " guifg=yellow
" highlight! coffeeAssignSymbols cterm=bold ctermfg=cyan gui=bold guifg=cyan
" highlight! coffeeAssignSymbols cterm=bold ctermfg=white gui=bold guifg=white
highlight! coffeeAssignSymbols cterm=bold ctermfg=yellow gui=bold guifg=yellow

highlight! coffeeObject cterm=bold ctermfg=magenta gui=bold guifg=magenta

" highlight! coffeeDot cterm=bold ctermfg=white gui=bold guifg=white

syntax match coffeeJustDot /\./
highlight! coffeeJustDot cterm=bold ctermfg=white gui=bold guifg=white


"" Stolen from basic.vim!

syn match OperatorEquals /=/
highlight OperatorEquals ctermfg=yellow guifg=yellow

syn match OperatorPlus /+/
"" Interferes with coffeeFunction!
"syn match OperatorMinus /-/
syn match OperatorMultiply /*/
syn match OperatorDivide /\//
highlight OperatorPlus ctermfg=green guifg=green
"highlight OperatorMinus ctermfg=red guifg=red
highlight OperatorMultiply ctermfg=yellow guifg=yellow
highlight OperatorDivide ctermfg=red guifg=red

" I believe this should go upstream
" But it needs to come after our stupid OperatorDivide rule!
syn region  coffeeRegexpString     start=+/[^/*]+me=e-1 skip=+\\\\\|\\/+ end=+/[gi]\{0,2\}\s*$+ end=+/[gi]\{0,2\}\s*[;.,)\]}]+me=e-1 contains=@htmlPreproc oneline
hi coffeeRegexpString ctermfg=magenta guifg=magenta

