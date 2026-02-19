" Detect whether the document uses single space after period or double spaces after periods, then enforce that by highlighting violations.

hi link txtProblematicSpacesAfterPeriod Error

command! EnforceSingleSpaceAfterPeriod let b:spaces_after_period_double = 0 | silent! syn clear txtProblematicSpacesAfterPeriod | syn match txtProblematicSpacesAfterPeriod /\.\zs  \+\ze/ containedin=ALL
command! EnforceDoubleSpaceAfterPeriod let b:spaces_after_period_double = 1 | silent! syn clear txtProblematicSpacesAfterPeriod | syn match txtProblematicSpacesAfterPeriod /\.\zs \ze[^ ]/ containedin=ALL

function! s:CountLinesMatching(pattern)
  let saved_view = winsaveview()
  let cnt = 0
  silent execute "g/" . a:pattern . "/let cnt += 1"
  "echo cnt . " matches for " . a:pattern
  call winrestview(saved_view)
  return cnt
endfunction

function! s:RestoreSpacesAfterPeriodSyntax()
  if !exists('b:spaces_after_period_double')
    " Detect: more lines with double space than single?
    if s:CountLinesMatching('\. \S') >= s:CountLinesMatching('\.  \S')
      :EnforceSingleSpaceAfterPeriod
    else
      :EnforceDoubleSpaceAfterPeriod
    endif
  else
    if get(b:, 'spaces_after_period_double', 0)
      :EnforceDoubleSpaceAfterPeriod
    else
      :EnforceSingleSpaceAfterPeriod
    endif
  endif
  "echo "b:spaces_after_period_double = " . b:spaces_after_period_double
endfunction

augroup SpacesAfterPeriod
  autocmd!
  " Run after filetype syntax so our matches take priority; BufReadPost for new buffers
  autocmd FileType * call s:RestoreSpacesAfterPeriodSyntax()
  autocmd BufReadPost,BufNewFile * call s:RestoreSpacesAfterPeriodSyntax()
  autocmd Colorscheme * call s:RestoreSpacesAfterPeriodSyntax()
augroup END

" In case the file has already been loaded
call s:RestoreSpacesAfterPeriodSyntax()
