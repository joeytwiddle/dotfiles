" :so ~/.vim/joey/joey.vim



" == Vim Options ==

" if has("gui_kde")
" 	set guifont=Courier\ 10\ Pitch/10/-1/5/50/0/0/0/1/0
" endif

" if has("gui_kde")
" set guifont=Lucida\ Console/8/-1/5/50/0/0/0/1/0
" endif

" if has("gui_kde") || has("gui_x")
	" set guifont=Bitstream\ Vera\ Sans\ Mono/10/-1/5/50/0/0/0/1/0
" endif

"" Medium for any linux:
" :set guifont=-*-lucidatypewriter-*-*-*-*-*-80-*-*-*-*-*-*   "" fail
"" Small for any linux:
" :set guifont=-*-fixed-*-*-*-*-*-80-*-*-*-*-*-*

" :set guifont=Fixed\ Semi-Condensed\ 7
" :set guifont=Fixed\ Semi-Condensed\ 9
" :set guifont=Beeb\ Mode\ One\ 6

"" Good for Debian, a bit naff on Gentoo:
" :set guifont=Monospace\ 8
"" Good for Gentoo, missing on Debian:
" :set guifont=LucidaTypewriter\ 8
"" Nice small font (similar to clean at this size) Works on Debian
" :set guifont=DejaVu\ Sans\ Mono\ 7
" :set guifont=Monospace\ 7
"" Less tall:
" :set guifont=Liberation\ Mono\ Bold\ 7
"" Less tall again.  This is an MS TrueType/Screen font (Win98).
" :set guifont=Lucida\ Console\ Semi-Condensed\ 7
"" Shortest on Debian:
:set guifont=Lucida\ Console\ Semi-Condensed\ 8

" set tabline=%!MyTabLine()
" set showtabline=2 " 2=always
" autocmd GUIEnter * hi! TabLineFill term=underline cterm=underline gui=underline
" autocmd GUIEnter * hi! TabLineSel term=bold,reverse,underline \ ctermfg=11 ctermbg=12 guifg=#ffff00 guibg=#0000ff gui=underline

" ATM If we edit a textfile with wrap set from here, and write a long line, it will auto-newline.  With nowrap it is fine.
" :set wrap
:set linebreak
" :set nolist
" There is :set list in joey.vim :P
:set sidescroll=5
" listchars and showbreak now defined in joey.vim

" Flashing cursor means lag for gaming!
:set guicursor=a:blinkoff0



" == Keybinds ==

" Joey's little trick - really lives elsewhere.
" :e usually clears undo history, so we don't really do :e any more.
" We delete the contents of the buffer, then read the file in, which
" is an operation we can undo.  We must delete the top (empty) line also.
" :map :e<Enter> :%d<Enter>:r<Enter>:0<Enter>dd
" BUG: vim still thinks the file is out of sync with the buffer, so if you
" quit without writing the file, vim complains, which is not how :e behaved.
:map :e<Enter> :%d<Enter>:r<Enter>:0<Enter>dd:w!<Enter>

" Fix broken Backspace under gentoo:
" :imap  <Left><Del>

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis



" == Options for plugins ==

let g:miniBufExplorerMoreThanOne = 1
let g:miniBufExplMaxHeight = 6
" let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1  " or use version in joeykeymap.vim
" Can't be set here.  Needs to be set late!
" :set winheight 40
let g:miniBufExplUseSingleClick = 1

let g:treeExplVertical = 1
let g:treeExplWinSize = 24
" let g:treeExplAutoClose = 0

" dammit these two don't work together!
let g:hiline = 0
let g:hiword = 1

let g:ConqueTerm_Color = 1

