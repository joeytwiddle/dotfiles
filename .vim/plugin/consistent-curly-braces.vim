" Detect whether the file uses curly braces at the end of the line, or on a new line, then highlights violations of that style.

hi link ProblematicCurlyBrace Error

command! DisallowTrailingCurly let b:allow_trailing_curlies = 0 | silent! syn clear ProblematicCurlyBrace | syn match ProblematicCurlyBrace /^.*\S\s*{\s*$/
command! AllowTrailingCurly    let b:allow_trailing_curlies = 1 | silent! syn clear ProblematicCurlyBrace | syn match ProblematicCurlyBrace /^\zs\s*{\s*$/

function! s:CountLinesMatching(pattern)
  let saved_view = winsaveview()
  let cnt = 0
  silent execute "g/" . a:pattern . "/let cnt += 1"
  "echo cnt . " matches for " . a:pattern
  call winrestview(saved_view)
  return cnt
endfunction

function! s:RestoreConsistentCurlyBracesSyntax()
  if !exists('b:allow_trailing_curlies')
    " Detect: more lines with trailing curlies than own-line curlies
    if s:CountLinesMatching('\S\s*{') >= s:CountLinesMatching('^\s*{\s*$')
      :AllowTrailingCurly
    else
      :DisallowTrailingCurly
    endif
  else
    " Restore
    if b:allow_trailing_curlies
      :AllowTrailingCurly
    else
      :DisallowTrailingCurly
    endif
  endif
  "echo "b:allow_trailing_curlies = " . b:allow_trailing_curlies
endfunction

augroup ConsistentCurlyBraces
  autocmd!
  " Run after filetype syntax so our matches take priority; BufReadPost for new buffers
  autocmd FileType * call s:RestoreConsistentCurlyBracesSyntax()
  autocmd BufReadPost,BufNewFile * call s:RestoreConsistentCurlyBracesSyntax()
  autocmd Colorscheme * call s:RestoreConsistentCurlyBracesSyntax()
augroup END

" For the current buffer
call s:RestoreConsistentCurlyBracesSyntax()
