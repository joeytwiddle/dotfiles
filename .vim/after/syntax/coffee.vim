syntax match coffeeParens /[()]/
" highlight! link coffeeParens Function
" highlight! link coffeeParens coffeeStatement
highlight! coffeeParens cterm=bold ctermfg=cyan gui=bold guifg=#00b0b0
" highlight! coffeeParens cterm=bold ctermfg=cyan gui=bold guifg=#b0b000

" highlight! coffeeAssign ctermfg=cyan guifg=cyan
" highlight! coffeeAssign cterm=bold ctermfg=red gui=bold guifg=#886600
" highlight! coffeeAssign ctermfg=magenta guifg=#aa44aa
" highlight! coffeeAssign cterm=bold ctermfg=white gui=bold guifg=white

" highlight! coffeeAssignSymbols cterm=bold ctermfg=yellow gui=bold " guifg=yellow
highlight! coffeeAssignSymbols cterm=bold ctermfg=white gui=bold guifg=white
" highlight! coffeeAssignSymbols cterm=bold ctermfg=cyan gui=bold guifg=cyan

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

