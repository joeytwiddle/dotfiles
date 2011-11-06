" setlocal comments="sO:\" -,mO:\"  ,eO:\"\",:\""
" setlocal commentstring="\"%s"
"" I think this fails.  Too many quote marks!
" exec "setlocal comments=\"" . &comments . ",:\"\""
setlocal comments="sO:\" -,mO:\"  ,:\"\",:\""
