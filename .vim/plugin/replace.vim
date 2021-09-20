" Simple tool for renaming a word (e.g. a variable or function name)

" See also: https://vi.stackexchange.com/questions/13689/is-there-a-better-method-for-find-and-replace-in-vim
" There is a one-liner there which does pretty much the same as our ReplaceInThisBuffer command:
"nnoremap <Leader>r :%s/\<<C-r><C-w>\>//g<left><left>

" DONE: Escape search word for regexp, for special chars like '^', '$', '[', ']', '\'
" TODO: Check the replacement word is unique (not already present in the buffer)

function! s:escape_for_regexp(str)
  return escape(a:str, '^$.*?/\[]')
endfunction

" Search for word under cursor and replace with prompted input in this buffer, or in all open buffers
function! s:Replace(in_all_buffers, whole_word, search, ...)
   let iab = a:in_all_buffers ? 'in all buffers ' : ''
   let escaped_search = s:escape_for_regexp(a:search)
   if a:whole_word
      let escaped_search = '\<' . escaped_search . '\>'
   endif
   if exists('a:4')
      let replacement = a:4
   else
      let suggested_replacement = escape(a:search, '\')
      let replacement = input('Replace ' . iab . escaped_search . ' with: ', suggested_replacement)
   endif
   let escaped_replacement = escape(replacement, '/')
   if a:in_all_buffers
      exec 'bufdo! %s/' . escaped_search . '/' . escaped_replacement . '/gec'
      " Flag 'e' continues if no changes were made in one of the buffers, or if an error occurred.
   else
      exec '%s/' . escaped_search . '/' . escaped_replacement . '/gc'
   endif
endfun

" Adapted from http://vim.wikia.com/wiki/Search_for_visually_selected_text
function! s:GetVisualSelection()
   let old_reg = getreg('"')
   let old_regtype = getregtype('"')
   normal! gvy
   let pat = @@
   "let pat = escape(@@, '\')
   "let pat = substitute(pat, '^\_s\+', '\\s\\+', '')
   "let pat = substitute(pat, '\_s\+$', '\\s\\*', '')
   "let pat = substitute(pat, '\_s\+', '\\_s\\+', 'g')
   "let pat = '\V'.pat
   normal! gV
   call setreg('"', old_reg, old_regtype)
   return pat
endfun

nnoremap <silent> \r :call <SID>Replace(0, 1, expand("<cword>"))<CR>
vnoremap <silent> \r :<C-U>call <SID>Replace(0, 0, <SID>GetVisualSelection())<CR>
command! -nargs=* ReplaceInThisBuffer call <SID>Replace(0, 1, expand("<cword>"), <q-args>)

nnoremap <silent> \R :call <SID>Replace(1, 1, expand("<cword>"))<CR>
vnoremap <silent> \R :<C-U>call <SID>Replace(1, 0, <SID>GetVisualSelection())<CR>
command! -nargs=* ReplaceInAllBuffers call <SID>Replace(1, 1, expand("<cword>"), <q-args>)

