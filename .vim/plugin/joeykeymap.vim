" comment
:map <F5> ^i// <Esc>j^
" uncomment
:map <F6> ^3xj^
" indent
:map <F7> ^i  <Esc>j^
" undent
:map <F8> 0xj^
:map <F7> Js<Return><Esc> 

" C "changes word under cursor" (replaces "change to end of line", c$)
:nmap C \ bcw
