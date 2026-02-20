" Detect whether the document uses single space after period or double spaces after periods, then highlights violations of that style.

hi link ProblematicSpacesAfterPeriod Error

command! OneSpaceAfterPeriod let b:spaces_after_period = 1 | silent! syn clear ProblematicSpacesAfterPeriod | syn match ProblematicSpacesAfterPeriod /\.\zs  \+\ze/ containedin=ALL
command! TwoSpacesAfterPeriod let b:spaces_after_period = 2 | silent! syn clear ProblematicSpacesAfterPeriod | syn match ProblematicSpacesAfterPeriod /\.\zs \ze[^ ]/ containedin=ALL

function! s:CountLinesMatching(pattern)
  let saved_view = winsaveview()
  let cnt = 0
  silent execute "g/" . a:pattern . "/let cnt += 1"
  "echo cnt . " matches for " . a:pattern
  call winrestview(saved_view)
  return cnt
endfunction

function! s:RestoreConsistentSpacesAfterPeriodSyntax()
  if !exists('b:spaces_after_period')
    " Detect: more lines with double space than single?
    if s:CountLinesMatching('\. \S') > s:CountLinesMatching('\.  \S')
      :OneSpaceAfterPeriod
    else
      :TwoSpacesAfterPeriod
    endif
  else
    " Restore
    if b:spaces_after_period == 2
      :TwoSpacesAfterPeriod
    else
      :OneSpaceAfterPeriod
    endif
  endif
  "echo "b:spaces_after_period = " . b:spaces_after_period
endfunction

augroup ConsistentSpacesAfterPeriod
  autocmd!
  " Run after filetype syntax so our matches take priority; BufReadPost for new buffers
  autocmd FileType * call s:RestoreConsistentSpacesAfterPeriodSyntax()
  autocmd BufReadPost,BufNewFile * call s:RestoreConsistentSpacesAfterPeriodSyntax()
  autocmd Colorscheme * call s:RestoreConsistentSpacesAfterPeriodSyntax()
augroup END

" For the current buffer
call s:RestoreConsistentSpacesAfterPeriodSyntax()
