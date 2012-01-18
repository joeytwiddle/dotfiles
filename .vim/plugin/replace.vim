" Search for word under cursor and replace with prompted input in all open buffers
fun! Replace(...)
   let l:search = "\\<" . expand('<cword>') . "\\>"
   let l:replacement = ""
   if exists("a:1")
      let l:replacement = a:1
   endif
   let l:replacement = input("Replace " . l:search . " with: ",l:replacement)
   :exe 'bufdo! %s/' . l:search . '/' . l:replacement . '/gec'
   "" There is also windo and argdo
   " :unlet! s:word
endfun

map \r :call Replace()<CR>
" command! Replace call Replace(<f-args>)
command! -nargs=* Replace call Replace(<q-args>)

