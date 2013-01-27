" Echo the declaration line for the tag under the cursor
" With the default mapping, when you press <Space>
"
" Thanks clipon and osse

nnoremap <silent><Space> <space>:call <SID>ShowTagDecl()<CR>

function! s:ShowTagDecl()
  redir => output
  silent! exec "tselect ".expand("<cword>")
  redir END
  let fname = '???'
  for line in split(output, "\n")
    " None of the lines contains a line number
    "echo line
    if match(line,'^        ') != -1
      redraw
      let prototype = substitute(line,'^ *','','')
      "echo fname.": ".prototype
      echo prototype."   [".fname."]"
      return 0
    else
      let bits = split(line,' ')
      let lastbit = bits[len(bits)-1]
      let fname = lastbit
    endif
  endfor
endfunction

