" Echo the declaration line for the tag under the cursor
" With the default mapping, when you press <Space>
"
" Thanks clipon and osse

nnoremap <silent><Space> <space>:call <SID>ShowTagDecl()<CR>

function! s:ShowTagDecl()
  redir => output
  silent! exec "tselect ".expand("<cword>")
  redir END
  for line in split(output, "\n")
    if match(line, '^        ') != -1
      redraw | echo line
      return 0
    endif
  endfor
endfunction

