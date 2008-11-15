echo &filetype
if "&filetype" == "xml" || "&filetype" == "xslt"
	:map <F5> ^i<!--  --><Esc>j^
	:map <F6> ^5x$xxxx^
else
	" comment
	:map <F5> ^i// <Esc>j^
	" uncomment
	:map <F6> ^3xj^
:endif
" indent
:map <F7> ^i  <Esc>j^
" undent
:map <F8> 0xj^
:map <F7> Js<Return><Esc> 

" C "changes word under cursor" (replaces "change to end of line", c$)
:nmap C \ bcw

:nmap <C-X>x :vnew \| vimshell bash<CR>

" :map <C-Enter> <C-]>
" :map <C-.> <C-]>
" :map <C-#> <C-]>
" :map <C-'> <C-]>
" :map <C-@> <C-]>
" :map <C-;> <C-]>
" :map <C-Minus> <C-]>
" :map <C-Equals> <C-]>
" :map <C-p> <C-]>
" :map <C-O> <C-]>
" :map <C-p> <C-LeftMouse>
" :map <C-p> g<LeftMouse>
" :map <C-p> :tag

" :map <C-Right> :n<Enter>
" :map <C-Left> :N<Enter>
:map <C-PageDown> :n<Enter>
:map <C-PageUp> :N<Enter>
" :map <F8> :tabprev<Enter>
" :map <F9> :tabnext<Enter>
" :map <C-[> :tabprev<Enter>
" :map <C-]> :tabnext<Enter>
" :map <C-[> :N<Enter>
" :map <C-]> :n<Enter>

" I'm sure there must be a better way to do this.
:map :htab :tabnew<Enter>:h

