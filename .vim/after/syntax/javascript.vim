" cndent rule: Indent java anonymous classes correctly.
:set cinoptions=j1

"" Redefine defaults (added @todo) does appear in rules but does not work!
" syn keyword javaScriptCommentTodo      TODO FIXME XXX TBD @todo contained

" I ended up putting a bunch of things I wanted highlighted into this one type
syntax match javaScriptOperation /\(==\|===\|!=\|!==\|<\|>\|<=\|>=\|||\|&&\)/
highlight link javaScriptOperation javaScriptOperator
" highlight link javaScriptOperator javaScriptDot
highlight link javaScriptOperator Normal
syntax match javaScriptAssignment /\([ ]\|\>\)=\([ ]\|\<\)/
syntax match javaScriptAssignmentOther /\(++\|--\|+=\|-=\|*=\|\/=\)/
highlight link javaScriptAssignment Statement
highlight link javaScriptAssignmentOther javaScriptAssignment

" syntax match javaScriptStructure /\(,\|(\|)\)/
syntax match javaScriptStructure /\(,\|;\)/
" highlight javaScriptStructure ctermfg=cyan guifg=cyan gui=bold
" highlight link javaScriptStructure Function
highlight link javaScriptStructure Normal

highlight javascriptParens ctermfg=cyan gui=bold guifg=cyan
" highlight javascriptParens ctermfg=cyan gui=bold guifg=#44aaff
" highlight javascriptParens ctermfg=cyan gui=bold guifg=#ffff60

syntax match javaScriptDot /\./
" highlight link javaScriptDot Statement
highlight javaScriptDot ctermfg=lightblue guifg=lightblue gui=bold
highlight javaScriptDot cterm=bold ctermfg=white guifg=white gui=bold

highlight link javaScriptNull javaScriptNumber
highlight javaScriptNumber cterm=none ctermfg=cyan gui=none guifg=LightCyan

