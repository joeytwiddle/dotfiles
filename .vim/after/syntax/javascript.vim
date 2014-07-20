" cndent rule: Indent java anonymous classes correctly.
":set cinoptions=j1

" Reserving these variables don't make a lot of sense for NodeJS:
" (e.g. top, window, ...)
syntax clear javaScriptMember
syntax clear javaScriptGlobal

"" TODO: Some of the below slow down Vim a lot.  Look in the distribution's files to see if there may be a way to make them more efficient.

"" Redefine defaults (added @todo) does appear in rules but does not work!
" syn keyword javaScriptCommentTodo      TODO FIXME XXX TBD @todo contained

"highlight javaScriptOperator ctermfg=white cterm=bold guifg=white gui=bold
highlight link javaScriptOperator Normal

" I ended up putting a bunch of things I wanted highlighted into this one type
" We could separate into: javaScriptComparison and javaScriptOperatorOther
syntax match javaScriptOperation /\(===\|==\|!==\|!=\|<=\|>=\|<\|>\|&&\|||\|&\||\|!\)/
"highlight link javaScriptOperation javaScriptOperator
"highlight javascriptOperation ctermfg=white cterm=bold guifg=white gui=bold
"highlight javascriptOperation ctermfg=yellow cterm=none guifg=yellow gui=none
highlight link javaScriptOperation Normal

syntax match javaScriptAssignment /\([ ]\|\>\)=\([ ]\|\<\)/
syntax match javaScriptAssignmentOther /\(++\|--\|+=\|-=\|*=\|\/=\|&=\||=\)/
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

" Some of the following rules mess with jade syntax, so we skip them.
if &filetype == 'jade' || &filetype == 'blade'
  finish
endif

syntax match javaScriptDot /\./
" highlight link javaScriptDot Statement
highlight javaScriptDot ctermfg=lightblue guifg=lightblue gui=bold
highlight javaScriptDot cterm=bold ctermfg=white guifg=white gui=bold

"" Just use javaScriptStructure above
" syntax match javaScriptComma /,/
" highlight javaScriptComma cterm=bold ctermfg=white guifg=white gui=bold

highlight link javaScriptNull javaScriptNumber
highlight javaScriptNumber cterm=none ctermfg=cyan gui=none guifg=LightCyan

" Like coffeeScript, highlight only the *last* property in an assignment
" Added optional \[.*\] to catch e.g. myList[i-1] = ""; but it can catch too much sometimes!
" silent syn clear javaScriptAssignVar
" This version caught the var/property before the [...]
"syn match javaScriptAssignVar /[A-Za-z_$][A-Za-z_$0-9]*\(\[.*\]\|\)[ 	]*\(=\([^=]\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther
" But we only really want the [...] itself
"syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)[ 	]*\(=\([^=]\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther
" The =[^=] check ensures that we match 'a=b' but never 'a==b'.  Unfortunately it also selects and highlights the char after the '=', i.e. 'b'!
" In the following version we fix that using me=e-1 which works for 'a=b' but is not so helpful when '$' end-of-line is matched.
"syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)[ 	]*\(=\|++\|--\|+=\|-=\|\*=\|\/=\)\([^=]\|$\)/me=e-1 contains=javaScriptAssignment,javaScriptAssignmentOther
" A better alternative to syn-pattern-offset is to use \@= which means "match preceding atom with 0 width"
"syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)[ 	]*\(=\([^=]\@=\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther
" Another alternative is to use \ze which means "set match end here"
syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)[ 	]*\(=\(\ze[^=]\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther
highlight javaScriptAssignVar ctermfg=white cterm=bold guifg=white gui=bold

"syn match javaScriptAssignProperty /[A-Za-z_$][A-Za-z_$0-9]*\s*:/ contains=javaScriptColon
"" To match Coffeescript's dark blue properties (although I think that was a bug):
"highlight javaScriptAssignProperty ctermfg=darkblue cterm=bold guifg=#6666ff gui=bold
"" To make property declarations look like variable assignments:
""hi link javaScriptAssignProperty javaScriptAssignVar
"syn match javaScriptColon /:/
"highlight javaScriptColon ctermfg=white guifg=white


"" Stolen from basic.vim!

" syn match OperatorEquals /=/
" highlight OperatorEquals ctermfg=yellow guifg=yellow

syn match OperatorPlus /+/
syn match OperatorMinus /-/
syn match OperatorMultiply /*/
"" Gah - affects // comments
" syn match OperatorDivide /\//
highlight OperatorPlus ctermfg=green guifg=green
"highlight OperatorMinus ctermfg=red guifg=red
highlight OperatorMultiply ctermfg=yellow guifg=yellow
highlight OperatorDivide ctermfg=red guifg=red

"" Added some more, getting silly now!
"syn match ComparatorPositive /\(>\|>=\|===\|==\)/
"syn match ComparatorNegative /\(<\|<=\|!==\|!=\)/
"highlight ComparatorPositive ctermfg=green guifg=green
"highlight ComparatorNegative ctermfg=red guifg=red

"" Make JS colors a bit more like CS colors
syntax keyword javascriptThis this
highlight link javascriptThis Type

