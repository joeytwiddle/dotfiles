

" :so ~/.vim/joey/joey.vim



" >>> Options for plugins {{{

	let coffee_compile_on_save=1

	let g:miniBufExplorerMoreThanOne = 0
	" let g:miniBufExplMaxHeight = 6
	" let g:miniBufExplMapWindowNavVim = 1
	let g:miniBufExplMapWindowNavArrows = 1  " or use version in joeykeymap.vim
	let g:miniBufExplUseSingleClick = 1
	" let g:miniBufExplShowUnlistedBuffers = 0
	" let g:miniBufExplShowOtherBuffers = 1
	" let g:miniBufExplorerDebugLevel = 5

	" >>> For taglist.vim {{{

		" == Taglist Lag Issues ==
		" Taglist will enable Tlist_Auto_Update by default.
		" If Vim is being very slow, e.g. updating the taglist after writing a
		" big file, just do :TlistLock to disable refreshing and updating
		" entirely.
		" You can then do :TlistUpdate manually when required, or :TlistUnlock.

		let g:Tlist_Auto_Open            = 0
		let g:Tlist_Use_Right_Window     = 1
		let g:Tlist_Show_One_File        = 0
		let g:Tlist_File_Fold_Auto_Close = 1
		let g:Tlist_Compact_Format       = 0
		let g:Tlist_WinWidth             = 25
		let g:Tlist_Inc_Winwidth         = 0
		" Changing window width with Tlist_Inc_Winwidth doesn't seem to work properly
		" under compiz, it messes the window up, requiring a Ctrl-L to fix it.

		"" Taglist also needs to know about any custom tag types declared in ~/.ctags
		"
		" The second part of the varname is the Vim &filetype associated with the file.
		" In other words, :echo &filetype in order to generate the string below!
		" The first word of the string is the ctags language module used to parse the file.
		" Consult ctags --list-languages to obtain that string.
		" For the type entries, I don't know a good way to discover these.  I just run
		" ctags over a bunch of files, and look for the single-letter types at the end
		" of each line, then guess their names!
		"
		" My custom Javascript properties and exports tags kinda suck.
		" Exports might be nice if vim would only choose the functions over them!
		"
		"let tlist_javascript_settings = 'javascript;c:class;f:function;v:variable;p:property;e:export'
		"let tlist_coffee_settings = 'coffee;c:class;f:function;v:variable;p:property;e:export'
		"let tlist_javascript_settings = 'javascript;c:class;f:function;e:export'
		let tlist_javascript_settings = 'javascript;c:class;f:function;e:export;p:property'
		"
		let tlist_coffee_settings = 'coffee;c:class;f:function;e:export'
		"
		let tlist_uc_settings = 'c;c:class;v:variable;f:function;m:method'
		"
		" java,javascript,c all create tags for uc files, but c lists more!
		" Labels in asm are a big distraction from more fundamental constructs
		" l:label;
		let tlist_asm_settings = 'asm;c:context;m:macro;d:define'
		let tlist_ocaml_settings = 'ocaml;M:module;t:type;c:class;m:method;v:variable;e:exception'
		let tlist_python_settings = 'python;c:class;m:member;f:function'
		" BUG: It seems taglist won't even use it's own defined defaults.  I get
		" no tags for a language until I define it here.  That can't be right,
		" have I broken taglist?!
		"let tlist_vim_settings = 'vim;a:autocmds;v:variable;f:function;c:command'
		let tlist_dosini_settings = 'dosini;s:section'

	" }}}

	" >>> For vtreeexplorer.vim {{{
		let g:treeExplVertical = 1
		let g:treeExplWinSize = 24
		" let g:treeExplAutoClose = 0
	" }}}

	" let g:NERDTreeMinimalUI=1

	let g:Grep_OpenQuickfixWindow = 1

	let g:ConqueTerm_Color = 1
	" let g:ConqueTerm_CloseOnEnd = 1
	let g:ConqueTerm_CloseOnEndIfSplit = 1
	" let g:ConqueTerm_CloseOnSuccess = 1
	let g:ConqueTerm_InsertOnEnter = 1
	let g:ConqueTerm_ReadUnfocused = 1   " I fear this may be preventing me from leaving the window!

	let g:yaifa_max_lines = 80

	" Now I am using sessionman.vim
	" let sessionman_save_on_exit = 1   " default
	let g:session_autosave = 1
	let g:sessionlist_stay_open = 1
	let g:sessionman_preview_sessions = 1

	" Can't be set here.  Needs to be set late!
	" :set winheight 40

" }}}



" >>> Options for MY plugins {{{

	let g:hiline = 1
	let g:hiword = 1

	let g:search_centered = 0

	let g:blinking_statusline = 1

" }}}



" >>> Options for VIM itself {{{

	set updatetime=300

	" My defaults, which may be overridden later by filetype rules, plugins, or
	" modeline.
	set sw=3 "shiftwidth
	set ts=3 "tabstop

	" The default textwidth=0 will wrap to screen width, if screen width is
	" <79.  This seems undesirable to me.  If we are wrapping, let's wrap to
	" "the standard".
	set textwidth=79

	"" If you need to fix backspace, try one of these:
	" :fixdel
	" :set t_kD=^V<Delete>
	" :!echo "keycode 14 = BackSpace" | loadkeys
	"" All from the manual: :h :fixdel

	"" See help for 'statusline' and %{eval_expr}
	" :set titlestring=[VIM]\ %m\ %F
	"" Had to use BufEnter to act after other plugins using BufEnter!
	"" Might not work here in .vimrc - I was testing from command line.
	" :auto BufEnter * set titlestring=(VIM)\ %m\ %F
	" :auto BufEnter * set titlestring=(VIM)\ %q%w%m\ %F\ %a
	" :auto BufEnter * set titlestring=[VIM]\ %q%w%m\ %F\ %y\ %a
	"" This number does not increase if we flip through with :bn instead of :n
	" :set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
	" :auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
	"" OTOH, it is pretty darn useful to see the arg count even if the buffer number is wrong.
	"" Inaccurate but interesting:
	" :auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ (%n/%{bufnr('$')})%)
	" :auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ (%n/%{argc()})%)
	"" Accurate:
	:auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ (%{bufnr('$')}\ buffers)%)
	"" Percentage through file instead:
	" :auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ [%P]%)

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
	"" Nice small font (a little bit like clean at this size) Works on Debian
	" :set guifont=DejaVu\ Sans\ Mono\ 7
	" :set guifont=Monospace\ 7
	"" Less tall:
	" :set guifont=Liberation\ Mono\ Bold\ 7
	"" Less tall again.  Looks like LucidaTypewriter, which is not visible on Debian.  (Semi-Condensed appears to be the same as the default!)
	" :set guifont=Lucida\ Console\ Semi-Condensed\ 7
	:set guifont=Lucida\ Console\ Semi-Condensed\ 8
	"" Very small and clear; quite like Teletext font
	" :set guifont=MonteCarlo\ Fixed\ 12\ 11
	if $SHORTHOST == "pod"
		:set guifont=Monospace\ 10
	endif


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

	"" Minimal/informative foldline:
	" :set foldtext=v:folddashes.'['.(v:foldend-v:foldstart+1).']'.getline(v:foldstart)
	"" Append this to hide leading /*
	" .substitute(getline(v:foldstart),'\/\*','','g')
	"" Trim any leading whitespace
	" :set foldtext=v:folddashes.'['.(v:foldend-v:foldstart+1).']\ '.substitute(getline(v:foldstart),'^[\ \	]*','','')

	"" Retain current line's indent, but replace with dashes
	"" BUG: each tab is replaced with one '-' but should be replaced with tabstop of them!
	" :set foldtext=substitute(substitute(getline(v:foldstart),'[^\ \	].*','',''),'[\ \	]','-','g').'['.(v:foldend-v:foldstart+1).']\ '.substitute(getline(v:foldstart),'^[\ \	]*','','')
	"" Fixed version:
	:set foldtext=substitute(substitute(substitute(getline(v:foldstart),'[^\ \	].*','',''),'[\ ]','-','g'),'[\	]',repeat('-',\&tabstop),'g').'['.(v:foldend-v:foldstart+1).']\ '.substitute(getline(v:foldstart),'^[\ \	]*','','')
	"" Alternative version:
	" :set foldtext=substitute(substitute(substitute(getline(v:foldstart),'[^\ \	].*','',''),'[\ ]','-','g'),'[\	]',repeat('-',\&tabstop),'g').substitute(getline(v:foldstart),'^[\ \	]*','','').'\ \ \ ['.(v:foldend-v:foldstart+1).'\ lines]\ '

	" I find groups of windows clearer/easier to navigate when they squash up.
	set winminheight=0

	set formatoptions+=n            " Better indent numbered lists in comments
	set formatoptions+=l            " Don't wrap lines that were already long
	if version >= 703
		set formatoptions+=j            " Remove comment leaders when joining
	end

	if version >= 703
		set colorcolumn=+1
	end

	" Add a few custom filetypes:
	au BufRead,BufNewFile {*.shlib}              set ft=sh
	au BufRead,BufNewFile {*.json}               set ft=javascript
	au BufRead            {*/xchatlogs/*.log}    set ft=irclog readonly
	" From web:
	au BufRead,BufNewFile {/usr/share/X11/xkb/*} set ft=c
	" au BufRead,BufNewFile {*.lecnote}            set ft=lecnote
	" au BufRead,BufNewFile {*.selfml}             set ft=selfml

	"" I need to update some of my highlights for 256 color mode, so I'm not
	"" using it at the moment.
	" if $TERM != "linux" && $TERM != "screen"
		" set t_Co=256
	" end


" }}}



" >>> Key mappings / Key bindings {{{

	" Most of my good keybinds are stored in ~/.vim/plugins/joeykeymap.vim
	" What follows are bindings I am testing before sharing.

	" Fix broken Backspace under gentoo:
	" :imap  <Left><Del>

	" I never need to use this key, and my Escape key is a bit tempramental.
	map £ <Esc>
	imap £ <Esc>

	command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

	" BUG TODO: Sometimes saves a file called session.vim in my .vim/plugins folder!
	"           In fact many folders under ~/.vim/ hold auto executing .vim scripts!
	" Sometimes I quit a vim session when I only really meant to quit the current
	" file.  These intercepts save a session file whenever quitting, so if I want
	" to get the vim session back I can just reload it!
	" When quitting vim in a hurry, save a brief cache of the session:
	" FIXED I HOPE: If you cannot write the file (e.g. you piped to vi -) then these
	"               fail, and prevent the user from quitting!
	"        FIXED: Actually I think that may have been because :qa! mapped only to :qa
	" WINDOWID is the closest we have to a unique session id for now.
	"nnoremap :q<Enter> :mksession! ~/.vim/sessions/session-$WINDOWID.vim<Enter>:q<Enter>
	"nnoremap :qa<Enter> :mksession! ~/.vim/sessions/session-$WINDOWID.vim<Enter>:qa<Enter>
	"nnoremap :qa!<Enter> :mksession! ~/.vim/sessions/session-$WINDOWID.vim<Enter>:qa!<Enter>
	"nnoremap :wq<Enter> :mksession! ~/.vim/sessions/session-$WINDOWID.vim<Enter>:wq<Enter>
	"nnoremap :wqa<Enter> :mksession! ~/.vim/sessions/session-$WINDOWID.vim<Enter>:wqa<Enter>
	"nnoremap :wqa!<Enter> :mksession! ~/.vim/sessions/session-$WINDOWID.vim<Enter>:wqa!<Enter>
	" If you need to avoid using these, just do ::wqa
	" TODO: I also want this to run if I close Vim accidentally, e.g. with Ctrl-w c
	" TODO: Put the above in a loop.

" }}}


"" I build the list, rather than declare it, so lines can be easily added/removed.
let vamAddons = []
" call add(vamAddons,"vim-haxe")
call add(vamAddons,'github:jdonaldson/vaxe')

set runtimepath+=$HOME/.vim-addon-manager/vim-addon-manager/
call vam#ActivateAddons(vamAddons, {'auto_install' : 0})
" or
"call scriptmanager#Activate(["vim-haxe"])



"" Plugins
"" CVS leaves old versions in ~/.vim/plugins/CVS/Base/*.vim
"" These get loaded by Vim!
"" But we can disable auto-loading, and load them manually ourself, without
"" the subdirectories.  This could cause problems, but at time of writing, I
"" could not find any .vim files in subdirs of standard Vim plugin folders.
set noloadplugins
" Original: runtime! plugin/**/*.vim
runtime! plugin/*.vim

