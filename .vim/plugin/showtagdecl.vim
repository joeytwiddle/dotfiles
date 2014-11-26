" Echo the declaration line for the tag under the cursor
" With the default mapping, when you press <Space>
"
" Thanks clipon and osse

" TODO: If there are matches in multiple files, it might be nice to display the count (and filenames).
"       Unfortunately `tselect` does not seem to offer us any line numbers.
" TODO: We may need to trim the end of the output line if it is larger than screen_width*&ch, to avoid "Press Enter" messages.

" I considered putting <Space> at the end of the RHS, but this causes e.g. 5<Space> to break.
nnoremap <silent> <Space> <Space>:call <SID>ShowTagDecl()<CR>
" BUG: 999<Space> will force sexyscroller to break out early

" I put this feature on CursorHold now, to fix the error above.
" However we may find it annoying (it might hide output from other more important plugins which also echo on CursorHold).
"augroup ShowTagDecl
"  autocmd!
"  autocmd CursorHold * call s:ShowTagDecl()
"augroup END

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
      "let message = fname.": ".prototype
      let message = prototype."   [".fname."]"
      if len(message) >= &columns - 12
        let message = strpart(message, 0, &columns - 12)
      endif
      let oldRuler = &ruler
      let &ruler = 0
      echo message
      let &ruler = oldRuler
      return 0
    else
      let bits = split(line,' ')
      let lastbit = bits[len(bits)-1]
      let fname = lastbit
    endif
  endfor
endfunction

