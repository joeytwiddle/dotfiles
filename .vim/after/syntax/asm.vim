highlight asmComment ctermfg=darkgrey guifg=#999999 gui=none
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
highlight asmHashThingy ctermfg=white cterm=bold

syn match hexNumber /\(0x\|\$\)[0-9A-Fa-f]\+/
highlight link hexNumber Number
highlight Number ctermfg=cyan cterm=none

syntax match asmPreCondit /#\(ifdef\|else\|endif\|if\).*/
highlight asmPreCondit ctermfg=darkblue cterm=bold

exec "set comments=" . &comments . ",:;;,:;"

"" Getting messy...
syntax match asmCommand /\<[A-Za-z][A-Za-z][A-Za-z]\>/
highlight link asmCommand Statement

" syn clear asmIdentifier
highlight asmIdentifier ctermfg=cyan cterm=bold
" hi Normal ctermfg=cyan cterm=none

syn match asmString /"[^"]*"/
highlight asmString ctermfg=green

" Pasta also has .var2
syn clear asmDirective
syn match asmDirective /\.[a-z][a-z0-9]\+/
