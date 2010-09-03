
"" F5 and F6 comment and uncomment the current line.
" echo &filetype
if "&filetype" == "xml" || "&filetype" == "xslt"
	map <F5> ^i<!--  --><Esc>j^
	map <F6> ^5x$xxxx^
else
	map <F5> ^i// <Esc>j^
	map <F6> ^3xj^
:endif

"" F7 and F8 indent or unindent the current line.
"" (Expects/requires ts=2 sw=2 and noexpandtabs!)
map <F7> ^i  <Esc>j^
map <F8> 0xj^

"" Shortcut for re-joining lines broken by \n.
"" BUG: Deletes next char if current line is empty!
" map <F7> Js<Return><Esc> 

" C "changes word under cursor" (replaces "change to end of line", c$)
nmap C \ bcw

nmap <C-X>x :vnew \| vimshell bash<CR>

"" Various failed shortcuts for the 'follow link' command.
" map <C-Enter> <C-]>
" map <C-.> <C-]>
" map <C-#> <C-]>
" map <C-'> <C-]>
" map <C-@> <C-]>
" map <C-;> <C-]>
" map <C-Minus> <C-]>
" map <C-Equals> <C-]>
" map <C-p> <C-]>
" map <C-O> <C-]>
" map <C-p> <C-LeftMouse>
" map <C-p> g<LeftMouse>
" map <C-p> :tag

"" Quick switching between files:
" map <C-Right> :n<Enter>
" map <C-Left> :N<Enter>
" map <C-PageDown> :n<Enter>
" map <C-PageUp> :N<Enter>
"" These two work best with MiniBufExplorer
noremap <C-PageDown> :bnext<Enter>
noremap <C-PageUp> :bprev<Enter>

" map <F8> :tabprev<Enter>
" map <F9> :tabnext<Enter>
" map <C-[> :tabprev<Enter>
" map <C-]> :tabnext<Enter>
" map <C-[> :N<Enter>
" map <C-]> :n<Enter>

"" I'm sure there must be a better way to do this.
"" I'm trying to make a new command, but really just catching the keys!
map :htab :tabnew<Enter>:h

" :noremap <C-Down>  10<C-w>-<C-W>j10<C-w>+
" :noremap <C-Up>    10<C-w>-<C-W>k10<C-w>+
" :noremap <C-Left>  10<C-w><<C-W>h10<C-w>>
" :noremap <C-Right> 10<C-w><<C-W>l10<C-w>>

nnoremap <C-Up> <C-w>k
nnoremap <C-Down> <C-w>j
nnoremap <C-Left> <C-w>h
nnoremap <C-Right> <C-w>l

"" Here is too early, our value gets dropped.
" :set winheight 40

"" Allow navigation on wrapped lines with arrows
nnoremap <Up> gk
nnoremap <Down> gj

"" For GVim
inoremap <S-Insert> <Esc>"*pa

"" These work for Eterm, provided we export TERM=xterm before we run vim:
nnoremap [6^ :bn<Enter>
nnoremap [5^ :bp<Enter>

"" Although these allow Ctrl-W Up/Down/Left/Right in Eterm, they break normal
"" Up/Down/Left/Right in xterm.
" nnoremap OA k
" nnoremap OB j
" nnoremap OD h
" nnoremap OC l

" nnoremap Oa k
" nnoremap Ob j
" nnoremap Od h
" nnoremap Oc l

