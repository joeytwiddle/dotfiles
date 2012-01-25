function GoBackToRecentBuffer()
  let startName = bufname('%')
  while 1
    normal! 
    let nowName = bufname('%')
    if nowName != startName
      break
    endif
  endwhile
endfunction

nnoremap <silent> <C-O> :call GoBackToRecentBuffer()<Enter>
