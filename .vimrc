" :so ~/.vim/joey/joey.vim



" == Vim Options ==

"" See help for 'statusline' and %{eval_expr}
" :set titlestring=[VIM]\ %m\ %F
"" Had to use BufEnter to act after other plugins using BufEnter!
"" Might not work here in .vimrc - I was testing from command line.
" :auto BufEnter * set titlestring=(VIM)\ %m\ %F
" :auto BufEnter * set titlestring=(VIM)\ %q%w%m\ %F\ %a
" :auto BufEnter * set titlestring=[VIM]\ %q%w%m\ %F\ %y\ %a
:set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
:auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)

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
"" Very small and clear; quite like Teletext font
" :set guifont=MonteCarlo\ Fixed\ 12\ 11


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

" Fix broken Backspace under gentoo:
" :imap  <Left><Del>

command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

" When quitting vim in a hurry, save a brief cache of the session:
" TODO BUG: If you cannot write the file (e.g. you piped to vi -) then these
"           fail, and prevent the user from quitting!
nnoremap :q<Enter> :mksession! ~/last_session.vim<Enter>:qa<Enter>
nnoremap :qa<Enter> :mksession! ~/last_session.vim<Enter>:qa<Enter>
nnoremap :qa!<Enter> :mksession! ~/last_session.vim<Enter>:qa<Enter>



" == Options for plugins ==

let g:Tlist_Use_Right_Window = 1

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

let g:ConqueTerm_Color = 1

" dammit these two don't work together!
let g:hiline = 0
let g:hiword = 1

