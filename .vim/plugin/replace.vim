" Simple tool for renaming a word (e.g. a variable or function name)

" TODO: Escape search word for regexp, for special chars like '^', '$', '[', ']', '\'
" TODO: Check the replacement word is unique (not already present in the buffer)

" Search for word under cursor and replace with prompted input in this buffer, or in all open buffers
function! s:Replace(in_all_buffers, ...)
   let word = expand("<cword>")
   let search = "\\<" . word . "\\>"
   if exists("a:2")
      let replacement = a:2
   else
      let replacement = input("ReplaceInAllBuffers " . search . " with: ", word)
   endif
   if a:in_all_buffers
      exec 'bufdo! %s/' . search . '/' . replacement . '/gec'
      " Flag 'e' continues if no changes were made in one of the buffers, or if an error occurred.
   else
      exec "%s/" . search . "/" . replacement . "/gc"
   endif
endfun

nnoremap <silent> \r :call <SID>Replace(0)<CR>
command! -nargs=* ReplaceInThisBuffer call <SID>Replace(0,<q-args>)

nnoremap <silent> \R :call <SID>Replace(1)<CR>
command! -nargs=* ReplaceInAllBuffers call <SID>Replace(1,<q-args>)

