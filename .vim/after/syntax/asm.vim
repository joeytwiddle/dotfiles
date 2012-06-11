" highlight asmComment ctermfg=darkgrey gui=none guifg=#999999
highlight link asmComment Comment
" highlight Comment ctermfg=darkgrey guifg=darkgrey

" highlight Normal ctermfg=lightgrey guifg=lightgrey

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
" highlight link asmHashThingy asmOperation

" Whilst it might seem that # and % should be similarly highlighted, they are
" easier to distinguish visually if one is bright bold and the other not!
" Visual recognition takes precedence over correctness/consistency.
syntax match asmPercentThing /%/
highlight asmPercentThing cterm=none ctermfg=grey gui=bold guifg=white

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

" I like to use camelCase, so must redefine this:
" Original: syn match asmLabel		"[a-z_][a-z0-9_]*:"he=e-1
syn clear asmLabel
syn match asmLabel		"[a-zA-Z_][a-zA-Z0-9_]*:"he=e-1
highlight asmLabel ctermfg=green cterm=bold

" syn clear asmIdentifier
highlight asmIdentifier cterm=bold ctermfg=cyan gui=none guifg=cyan
" highlight Normal ctermfg=cyan cterm=none

syn match asmString /"[^"]*"/
" highlight asmString cterm=none ctermfg=darkgreen gui=none guifg=green
highlight asmString cterm=bold ctermfg=green gui=bold guifg=green
" highlight asmString cterm=none ctermfg=grey gui=none guifg=grey

" Pasta also has .var2
syn clear asmDirective
syn match asmDirective /\(^\| \|	\)\.[a-z][a-z0-9]\+/

" syn match pastaVar /%[A-Za-z0-9.]*/
" highlight link pastaVar Identifier

"" This is often a CPP macro call.
" syn region asmBracketedCall start=/[A-Za-z_][A-Za-z_0-9]*(/ end=/)/ contains=a65Opcode,asmIdentifier
syn match asmBracketedCall /[A-Za-z_][A-Za-z_0-9]*(/he=e-1
" highlight asmBracketedCall ctermfg=magenta
highlight link asmBracketedCall Normal

" Checking for a word length 3 will match more than just asm instructions,
" e.g. it would match both words in "inc num".
" So we actively check for line start or ':'.
" We can't do ,he=e-1 because of the $ case, so we highlight the trailing space or tab.
syn match asmOperation /\(^\|:\)[ 	]*[a-z][a-z][a-z]\( \|	\|$\)/hs=e-3
highlight asmOperation ctermfg=yellow guifg=yellow

" In this case we lazily use \< \> and allow false-positives.
syn match asmExtendedOperation /\<[a-z][a-z][a-z]_implied\>/
highlight link asmExtendedOperation asmOperation

