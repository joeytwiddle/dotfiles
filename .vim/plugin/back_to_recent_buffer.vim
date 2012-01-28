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

" A bit much to override an important key?
"nnoremap <silent> <C-O> :call GoBackToRecentBuffer()<Enter>
" You can always use <C-I> if you need to go forwards again.
" I never use this one:
nnoremap <silent> <C-U> :call GoBackToRecentBuffer()<Enter>
" You can use g; and g, to move between recent change points.
"" Only in GVim:
"nnoremap <silent> <C-BS> :call GoBackToRecentBuffer()<Enter>
