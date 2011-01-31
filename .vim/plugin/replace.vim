" Search for <cword> and replace with input() in all open buffers
fun! Replace(replacement)
   let l:search = "\\<" . expand('<cword>') . "\\>"
   let a:replacement = input("Replace " . l:search . " with: ",a:replacement)
   :exe 'bufdo! %s/' . l:search . '/' . a:replacement . '/gec'
   "" There is also windo and argdo
   " :unlet! s:word
endfun
map \r :call Replace()<CR>
command! Replace call Replace(<f-args>)
