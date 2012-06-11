set ts=2
set sw=2
" set expandtab
set listchars=tab:\|\ ,trail:£

set wrap
" set showbreak=--------

set foldenable
set foldmethod=indent

highlight basicComment ctermfg=darkgrey guifg=#777777 gui=bold
" highlight basicLineNumber ctermfg=darkgrey
highlight basicLineNumber ctermfg=darkyellow guifg=darkyellow
" highlight Normal ctermfg=white
highlight Normal ctermfg=lightgrey guifg=lightgrey

" Syntax rules for BBC BASIC and assembler (with Joey's extensions):

" syntax region basicComment start="^[ \t0-9]*;" end="$" contains=basicTodo
" syntax region basicComment start="[ 	];" end="$" contains=basicTodo
syntax region basicComment start="[ 	];;*[ 	]" end="$" contains=basicTodo
syntax region basicComment start="^;;*" end="$" contains=basicTodo

exec "set comments=" . &comments . ",:REM,:;;,:;"

" syntax clear basicStatement   " basicStatement breaks many of the rules below =/
" " BBC BASIC
" syntax region basFunc start="\<DEF PROC" end="\<ENDPROC\>" transparent fold
" syntax clear basicMathsOperator   " basicMathsOperator breaks the next rule =/
" syntax region basFunc start="\<DEF FN" end="^\s*=" transparent fold
" syntax region basFunc start="^\s*\<FOR\>" end="\<NEXT\>" transparent fold   " Beware: QBasic has statement "OPEN file FOR INPUT"
" " QBasic
" syntax region basFunc start="^\s*\<SUB\>" end="^\s*\<END SUB\>" transparent fold
" syntax region basFunc start="^\s*\<FUNCTION\>" end="^\s*\<END FUNCTION\>" transparent fold
" set foldmethod=syntax
" set foldenable

let syntax_tmp="basic"
unlet b:current_syntax
source $VIMRUNTIME/syntax/a65.vim
let b:current_syntax=syntax_tmp
unlet syntax_tmp

" highlight Comment ctermfg=darkgrey guifg=darkgrey
" highlight basicFunction term=none ctermfg=darkyellow guifg=darkyellow
hi link basicFunction Function
" highlight a65Opcode term=none ctermfg=cyan gui=bold guifg=cyan
hi link a65Opcode Statement

syntax clear a65Comment
" We have most ; comment covered.  a65Comment actually mis-matches some valid
" code (e.g. "VDU 1;2;3;")

syn match basicSpecial	"\<OPT\($\|\s\)" nextgroup=a65Address
syn match a65PreProc	"\<LOAD_LABEL\>" nextgroup=a65Address
syn match a65PreProc	"\<SAVE_LABEL\>" nextgroup=a65Address

source ~/.vim/after/syntax/bbcbasic.vim

" syn match IntVar /%/
syn match IntVar /[a-zA-Z0-9]*%/
highlight IntVar ctermfg=cyan guifg=cyan

syn match OperatorEquals /=/
highlight OperatorEquals ctermfg=yellow guifg=yellow



"" Optional extras

syn match OperatorPlus /+/
syn match OperatorMinus /-/
syn match OperatorMultiply /*/
syn match OperatorDivide /\//
highlight OperatorPlus ctermfg=green guifg=green
highlight OperatorMinus ctermfg=red guifg=red
highlight OperatorMultiply ctermfg=yellow guifg=yellow
highlight OperatorDivide ctermfg=red guifg=red

