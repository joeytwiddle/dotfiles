highlight asmComment ctermfg=darkgrey gui=none guifg=#999999
highlight Normal ctermfg=lightgrey guifg=lightgrey

"" The default asmComment definition captures everything following a '#', which
"" breaks e.g.: lda %scrX : clc : adc #20 : asl a : sec : sbc #40 : sta px
"" We can work around this by capturing non-comment uses of #:
" syntax match asmHashThingy /#[^ 	:;][^ 	:;]*/
"" Yes this does mean some comments which look like command parameters will not be marked as comments!
" syntax match asmHashThingy /#[<>+-]\?[$%]\?[0-9a-fA-Fa-zA-Z_]\+/
syntax match asmHashThingy /#/
" he=e-1
" highlight link asmHashThingy Number
highlight asmHashThingy cterm=bold ctermfg=white gui=bold guifg=white

syn match hexNumber /\(0x\|\$\)[0-9A-Fa-f]\+/
highlight link hexNumber Number
highlight Number ctermfg=cyan cterm=none

syntax match asmPreCondit /#\(ifdef\|else\|endif\|if\|define\|undef\).*/
highlight asmPreCondit cterm=bold ctermfg=blue gui=bold guifg=blue

exec "set comments=" . &comments . ",:;;,:;"

"" Getting messy...
" syntax match asmCommand /\<[A-Za-z][A-Za-z][A-Za-z]\>/
" highlight link asmCommand Statement
highlight link a65Opcode Statement

" syn clear asmIdentifier
highlight asmIdentifier cterm=bold ctermfg=cyan gui=none guifg=cyan
" hi Normal ctermfg=cyan cterm=none

syn match asmString /"[^"]*"/
highlight asmString ctermfg=green guifg=green

" Pasta also has .var2
syn clear asmDirective
syn match asmDirective /\(^\| \|	\)\.[a-z][a-z0-9]\+/

" syn match pastaVar /%[A-Za-z0-9.]*/
" highlight link pastaVar Identifier

