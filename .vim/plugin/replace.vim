" TODO: Escape word and replace's '/'s, (and '\'s, etc.?)
" TODO: Check the unique word replace is not already present in target
" TODO: Confirm action beforehand if /c not enabled.  Allows user to check <cword> worked suitably.

" Search for word under cursor and replace with prompted input in all open buffers
function! s:ReplaceInAllBuffers(...)
   let l:search = "\\<" . expand('<cword>') . "\\>"
   let l:replacement = ""
   if exists("a:1")
      let l:replacement = a:1
   endif
   let l:replacement = input("ReplaceInAllBuffers " . l:search . " with: ",l:replacement)
   :exe 'bufdo! %s/' . l:search . '/' . l:replacement . '/gec'
   " Flag 'e' continues if no changes were made in one of the buffers, or if an error occurred.
   "" There is also windo and argdo
   " :unlet! s:word
endfun

" Search for word under cursor and replace with prompted input in this buffer
function! s:ReplaceInThisBuffer(...)
   let word = expand("<cword>")
   let l:search = "\\<" . expand('<cword>') . "\\>"
   let l:replacement = ""
   if exists("a:1")
      let l:replacement = a:1
   endif
   let l:replacement = input("ReplaceInThisBuffer " . l:search . " with: ",l:replacement)
   execute "%s/\\<" . l:search . "\\>/" . l:replacement . "/gc"
endfunction

nnoremap \R :call <SID>ReplaceInAllBuffers()<CR>
" command! ReplaceInAllBuffers call ReplaceInAllBuffers(<f-args>)
command! -nargs=* ReplaceInAllBuffers call ReplaceInAllBuffers(<q-args>)

nnoremap \r :call <SID>ReplaceInThisBuffer()<CR>
command! -nargs=* ReplaceInThisBuffer call ReplaceInThisBuffer(<q-args>)

