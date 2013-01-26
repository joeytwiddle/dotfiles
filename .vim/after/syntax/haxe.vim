
"" Joey likes to make all classes look like known classes:
" syntax UpperCaseWord /\<[A-Z][A-Za-z0-9_$]*\>/
" highlight link UpperCaseWord haxeLangClass

if expand("%:e") == "sws"
	syn match swsHaxeFunctionSymbol "=>\|->"
	" hi link swsHaxeFunctionSymbol Function
	hi swsHaxeFunctionSymbol ctermfg=green ctermbg=none
	" TODO: -> is not getting lit - it is seen as haxeParenT, presumably because it was inside a function call.
endif

