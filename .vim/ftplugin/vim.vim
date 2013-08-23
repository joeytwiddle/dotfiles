" setlocal comments="sO:\" -,mO:\"  ,eO:\"\",:\""
" setlocal commentstring="\"%s"
"" I think this fails.  Too many quote marks!
" exec 'setlocal comments=' . &comments . ',:""'
" exec "setlocal comments=\"" . &comments . ",:\"\""
setlocal comments="sO:\" -,mO:\"  ,:\"\",:\""

" Comment
nnoremap <buffer> <F5> ^i"<Esc>j^
" Uncomment
nnoremap <buffer> <F6> ^1xj^
