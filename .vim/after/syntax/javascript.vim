" cndent rule: Indent java anonymous classes correctly.
:set cinoptions=j1

" I ended up putting a bunch of things I wanted highlighted into this one type
syntax match javaScriptAssignment /\(=\|+=\|-=\|++\|--\|*=\|\/=\|;\|!=\)/
highlight link javaScriptAssignment javaScriptKeyword

" syntax match javaScriptStructure /\(,\|(\|)\)/
syntax match javaScriptStructure /\(,\)/
" highlight javaScriptStructure ctermfg=cyan guifg=cyan gui=bold
highlight link javaScriptStructure Function

highlight javascriptParens ctermfg=cyan gui=bold guifg=cyan
" highlight javascriptParens ctermfg=cyan gui=bold guifg=#44aaff
" highlight javascriptParens ctermfg=cyan gui=bold guifg=#ffff60

syntax match javaScriptDot /\./
" highlight link javaScriptDot Statement
highlight javaScriptDot ctermfg=lightblue guifg=lightblue gui=bold
highlight javaScriptDot cterm=bold ctermfg=white guifg=white gui=bold

highlight javaScriptNumber cterm=none ctermfg=cyan gui=none guifg=LightCyan

