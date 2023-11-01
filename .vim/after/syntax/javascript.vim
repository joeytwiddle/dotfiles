" cndent rule: Indent java anonymous classes correctly.
":set cinoptions=j1

" Reserving these variables doesn't make a lot of sense for NodeJS.
" (e.g. top, window, ... are not special words.)
silent! syntax clear javaScriptMember
silent! syntax clear javaScriptGlobal

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

syntax match javaScriptAssignment /\(\s\|\>\)=\(\s\|\<\)/
syntax match javaScriptAssignmentOther /\(++\|--\|+=\|-=\|*=\|\/=\|&=\||=\)/
highlight link javaScriptAssignment Statement
highlight link javaScriptAssignmentOther javaScriptAssignment

"syntax match javaScriptStructure /\(,\|;\)/
"highlight link javaScriptStructure Normal
" An experiment, de-emphasise semi-colons and commas
syntax match javaScriptSemicolon /;/
syntax match javaScriptComma /,/
hi javaScriptSemicolon ctermfg=white guifg=#999999
"hi javaScriptComma     ctermfg=cyan  guifg=#99ffff
if &t_Co >= 256
  hi javaScriptSemicolon ctermfg=248
  "hi javaScriptComma     ctermfg=123
endif

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
"syn match javaScriptColon /:/
"highlight javaScriptColon ctermfg=white guifg=white

"" Just use javaScriptStructure above
" syntax match javaScriptComma /,/
" highlight javaScriptComma cterm=bold ctermfg=white guifg=white gui=bold

highlight link javaScriptNull javaScriptNumber
" We shouldn't really be defining colors here.
if get(g:, 'colors_name', 'default') == 'default'
  highlight javaScriptNumber cterm=none ctermfg=cyan gui=none guifg=LightCyan
endif

" Like coffeeScript, highlight only the *last* property in an assignment
" Added optional \[.*\] to catch e.g. myList[i-1] = ""; but it can catch too much sometimes!
" silent syn clear javaScriptAssignVar
" This version caught the var/property before the [...]
"syn match javaScriptAssignVar /[A-Za-z_$][A-Za-z_$0-9]*\(\[.*\]\|\)\s]*\(=\([^=]\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther
" But we only really want the [...] itself
"syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)\s*\(=\([^=]\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther
" The =[^=] check ensures that we match 'a=b' but never 'a==b'.  Unfortunately it also selects and highlights the char after the '=', i.e. 'b'!
" In the following version we fix that using me=e-1 which works for 'a=b' but is not so helpful when '$' end-of-line is matched.
"syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)\s*\(=\|++\|--\|+=\|-=\|\*=\|\/=\)\([^=]\|$\)/me=e-1 contains=javaScriptAssignment,javaScriptAssignmentOther
" A better alternative to syn-pattern-offset is to use \@= which means "match preceding atom with 0 width"
"syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)\s*\(=\([^=]\@=\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther
" Another alternative is to use \ze which means "set match end here"
"syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)\s*\(=\(\ze[^=]\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther
"syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)\s*\(=\(\ze[^=>]\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther

" For the standard javascript syntax, we need to add ourselves into the large blocks
syn match javaScriptAssignVar /\([A-Za-z_$][A-Za-z_$0-9]*\|\[.*\]\)\s*\(=\(\ze[^=>]\|$\)\|++\|--\|+=\|-=\|\*=\|\/=\)/ contains=javaScriptAssignment,javaScriptAssignmentOther containedin=jsBlock,jsParen,jsObject,jsFuncBlock,jsIfElseBlock,jsVariableDef,jsObjectProp
" Note that this somewhat conflicts with my new blue jsObjectProp, which wants to highligh assigned _properties_ in blue

"highlight javaScriptAssignVar ctermfg=white cterm=bold guifg=white gui=bold
highlight javaScriptAssignVar ctermfg=254 cterm=bold guifg=#e4e4e4 gui=bold

" Pangloss's Javascript syntax destroys my tricks above, but fortunately he creates his own syntax groups we can use!
highlight link jsAssignExpIdent javaScriptAssignVar

" To match coffeeAssign's dark blue property names:
"syn match javaScriptPropertyName /[A-Za-z_$][A-Za-z_$0-9]*\ze\s*:/ contains=javaScriptColon
"highlight javaScriptPropertyName ctermfg=darkblue cterm=bold guifg=#6666ff gui=bold
" To make property declarations look like variable assignments:
"hi link javaScriptPropertyName javaScriptAssignVar


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

" I was running isRuslan/vim-es6 and vim-jsx and also polyglot.  In the monokai theme my arrow functions were getting half highlighted as an = operator by isRuslan.  This was to fix it:
syn match jsArrowFunctionJoey /=>/
highlight link jsArrowFunctionJoey jsFunction

"" Added some more, getting silly now!
"syn match ComparatorPositive /\(>\|>=\|===\|==\)/
"syn match ComparatorNegative /\(<\|<=\|!==\|!=\)/
"highlight ComparatorPositive ctermfg=green guifg=green
"highlight ComparatorNegative ctermfg=red guifg=red

"" Make JS colors a bit more like CS colors
syntax keyword javascriptThis this
highlight link javascriptThis Type

"" Perform more detailed matching on function headers, so we can highlight more like Sublime Text does :-p
silent! syn clear javascriptFunction javascriptFunctionDeclaration javascriptFunctionName javascriptFunctionArgs
syn match javascriptFunctionDeclaration /\<function\>\s*[A-Za-z0-9_$]*\s*([^)]*)/ contains=javascriptFunctionName,javascriptFunctionArgs,javascriptFunction
"syn region javascriptFunctionDeclaration start=/\<function\>/ end=/{/ contains=javascriptFunctionName,javascriptFunctionArgs
syn keyword javascriptFunction function contained containedin=javascriptFunctionDeclaration
syn match javascriptFunctionName /\(\<function\>\s*\)\@<=[A-Za-z0-9_$]*/ contained containedin=javascriptFunctionDeclaration
" Matching this ( didn't work on anonymous functions, although it can work if the javascriptFunctionName match stops one char earlier.  O_o
"syn match javascriptFunctionArgs /(\zs[^)]*\ze)/ ...
syn match javascriptFunctionArgs /\zs[^()]*\ze)/ contained containedin=javascriptFunctionDeclaration

" TODO: If we really want to match Sublime Text closely, then beware that properties get highlighted like function names too, but for anonymous functions only.
"
"   foo: function () { ... },
"   ^^^ orange
"
"   foo: function bar() { ... },
"   ^^^ normal    ^^^ orange

" For pangloss's highlighting (make 'var' and 'function' cyan like they used to be)
" This should give us close to what we had before pangloss!
"let usingPanglossSyntax = index(vamAddons, 'github:pangloss/vim-javascript') >= 0
let usingPanglossSyntax = exists('*IsScriptLoaded') && IsScriptLoaded('pangloss')
let current_colorscheme = get(g:, 'colors_name', 'default')
let usingDefaultColorscheme = current_colorscheme == 'default'
if usingPanglossSyntax && usingDefaultColorscheme
  silent! hi link javascriptFunction Identifier
  silent! hi link jsStorageClass Identifier
  silent! hi link jsFunction Identifier
  silent! hi link jsFuncName Normal
  silent! hi link jsFuncParens Normal
  silent! hi link jsFuncBraces Identifier
  silent! hi link jsParens Identifier
  silent! hi link jsBraces Identifier
endif

" Then I started using isRuslan/vim-es6, with monokai

" isRuslan's syntax does not have any rule to match object properties which are functions.
" So I stole this one from pangloss, and tweaked it:
"syntax match javascriptFunctionKey /\<[a-zA-Z_$][0-9a-zA-Z_$]*\>\ze\(\s*:\s*function\s*\)/
" Now it can detect arrow functions too:
syntax match javascriptFunctionKey /\<[a-zA-Z_$][0-9a-zA-Z_$]*\>\ze\s*:\s*\(function\>\|(.*)\s*=>\|\w*\s*=>\)/
silent! hi link javascriptFunctionKey Function

" Also missing from isRuslan's:
syntax match javascriptFunction "=>"

" Also anything before a ( is a function call
syntax match jsFunctionCall /\<[a-zA-Z_$][0-9a-zA-Z_$]*\>\ze\s*(/ contains=javascriptFunctionDeclaration
hi link jsFunctionCall Function
" Except the word "function"!
"syntax keyword javascriptFunction function
syntax match javascriptFunction /\<function\>/ contains=javascriptFunctionDeclaration
hi clear javaScriptGlobalObjects
hi link javaScriptGlobalObjects jsBuiltins
" We need the contains=javascriptFunctionDeclaration above, or the args won't turn orange!

