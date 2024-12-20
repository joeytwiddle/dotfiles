scriptencoding utf-8

" With many separate plugin folders but a slow HDD, vim may start up slowly.
" To speed it up, we can keep all the relevant files in the disk cache (in memory) by loading vim in the background now and then.
" Add this line to your cronjob to trigger vim to load and then close itself every 30 minutes.
" */30 *  *   *   6    yes "" | nice ionice vim -c ":qa!" >/dev/null 2>&1


" :so ~/.vim/joey/joey.vim


"" Vim 7.3 started making `w` jump over '.'s in a variety of languages, which I do not want.
autocmd BufReadPost,BufNewFile * setlocal iskeyword-=.
" However I have come to accept that I do need '-' to be part of a word when dealing with CSS classes and IDs.
autocmd BufReadPost,BufNewFile *.{html,svg,xml,css,scss,less,stylus,js,coffee,erb,jade,blade} setlocal iskeyword+=-
" Also $ can be part of a valid identifier in JS (in fact almost any unicode character can be!):
autocmd BufReadPost,BufNewFile *.{js,coffee} setlocal iskeyword+=$

" In package.json files, I quite like packages with '-' in their name to be whole words.
autocmd BufReadPost,BufNewFile *.json setlocal iskeyword+=-

autocmd BufReadPost,BufNewFile *.js command! -buffer -range=% JSB let b:winview = winsaveview() |
    \ execute <line1> . "," . <line2> . "!js-beautify -f - -j -t -s " . &shiftwidth |
    \ call winrestview(b:winview)

" I was getting error highlighting on valid braces in SCSS files, because minlines was defaulting to 10!  This should prevent that.
autocmd BufReadPost,BufNewFile *.{scss} syntax sync minlines=200

" If Vim can undo through file-reads, then I am happy for it to automatically reload any file that changes on disk, e.g. as a result of editing in a different editor, or from a git checkout.
if exists('&undoreload')
	" I have been dealing with some pretty huge files recently!
	if &undoreload < 50000
		let &undoreload = 50000
	endif

	" This is not entirely satisfactory, because I don't want autoread if the file length is less than 'undoreload'.
	" I would rather see a clear warning instead.
	" Perhaps an autocmd could check this at runtime.
	setglobal autoread
endif
" Also mildly related, Vim now has persistent_undo feature, which can be enabled by setting 'undofile'

" This makes it possible to leave Insert mode more quickly when pressing Escape.
" Although it does mess with other plugins that use timeoutlen, such as Emmet.
" A better solution might be to get more familiar with my Esc shortcut on £ (Shift-3), although that isn't an option on US keyboards.
" Another keybind that some people like to use for <Esc> is <Ctrl-[>.  In fact that works by default!
" TODO: If gui is not running, then we should add this setup to the autocommand GUIEnter.  (Probably need to put the setup into a function.)
"if ! has('gui_running')
"    set ttimeoutlen=10
"    augroup FastEscape
"        autocmd!
"        au InsertEnter * set timeoutlen=0
"        au InsertLeave * set timeoutlen=1000
"    augroup END
"endif



" Allows us to use Ctrl-s and Ctrl-q as keybinds
silent !stty -ixon
" Restore default behaviour when leaving Vim.
autocmd VimLeave * silent !stty ixon
" Restoring the "default" might suck if the user usually has it disabled!  We could check whether he has it enabled or not by looking at the exit code of:
"   stty -a | grep -q '\( \|^\)ixon\>'
" TODO: What if the user doesn't have an stty executable (Windows)?
"       We may need to try harder to fail silently in the general case.  Or is silent enough already?
"       It seems to work fine on Mac terminal and MacVim.



" >>> Options for plugins {{{

	let g:miniBufExplorerMoreThanOne = 0
	" let g:miniBufExplMaxHeight = 6
	" let g:miniBufExplMapWindowNavVim = 1
	" Disabled because they use noremap which breaks navigation_enhancer.vim
	"let g:miniBufExplMapWindowNavArrows = 1  " Use versions in joeykeymap.vim instead.
	let g:miniBufExplUseSingleClick = 1
	" let g:miniBufExplShowUnlistedBuffers = 0
	"" Hide the Location List (which ALE brings up)
	"" If we find a better way to detect the Location List buffer, we could turn this back to 1
	"" I have turned this back on because it's needed to show unnamed buffers I create with :new
	let g:miniBufExplShowOtherBuffers = 1
	" let g:miniBufExplorerDebugLevel = 995

	" >>> For taglist.vim {{{

		" TODO: Consider using cscope and an "overview" plugin instead of ctags/tlist

		" == Taglist Lag Issues ==
		" Taglist will enable Tlist_Auto_Update by default.
		" If Vim is being very slow, e.g. updating the taglist after writing a
		" big file, just do :TlistLock to disable refreshing and updating
		" entirely.
		" You can then do :TlistUpdate manually when required, or :TlistUnlock.

		let g:Tlist_Auto_Open            = 0
		let g:Tlist_Use_Right_Window     = 1
		let g:Tlist_Show_One_File        = 0
		let g:Tlist_File_Fold_Auto_Close = 0
		let g:Tlist_Compact_Format       = 0
		let g:Tlist_WinWidth             = 30
		let g:Tlist_Inc_Winwidth         = 0
		" Changing window width with Tlist_Inc_Winwidth doesn't seem to work properly
		" under compiz, it messes the window up, requiring a Ctrl-L to fix it.

		" Macs come with the original ctags, not exuberant-ctags, so we need to 'brew install ctags'
		if executable('/usr/local/bin/ctags')
			let g:Tlist_Ctags_Cmd = '/usr/local/bin/ctags'
		endif

		"" Taglist needs to know about any custom tag types declared in ~/.ctags
		"
		" The second part of the varname is the Vim &filetype associated with the file.
		" In other words, :echo "tlist_".&filetype."_settings" in order to generate the string below!
		" The first word of the string is the ctags language module used to parse the file.
		" Consult ctags --list-languages to obtain that string.
		" For the type entries, I don't know a good way to discover these.  I just run
		" ctags over a bunch of files, and look for the single-letter types at the end
		" of each line, then guess their names!
		"
		" My custom Javascript properties and exports tags kinda suck.
		" Exports might be nice if vim would only choose the functions over them!
		"
		" v:variable
		" p:property;a:assigned
		" m:method       <-- It catches these itself, but they often show up as functions anyway.
		let tlist_javascript_settings = 'javascript;c:class;M:classmethod;f:function;e:export;r:route;u:publication'
		" v:variable
		" p:property;a:assigned
		let tlist_coffee_settings = 'coffee;c:class;f:function;e:export'
		"
		let tlist_uc_settings = 'c;c:class;s:state;v:variable;f:function;m:method'
		"
		" java,javascript,c all create tags for uc files, but c lists more!
		" Labels in asm are a big distraction from more fundamental constructs
		let tlist_asm_settings = 'asm;c:context;m:macro;d:define' " l:label;
		let tlist_ocaml_settings = 'ocaml;M:module;t:type;c:class;m:method;v:variable;e:exception'
		let tlist_python_settings = 'python;c:class;m:member;f:function'
		" BUG: It seems taglist won't even use it's own defined defaults.  I get no tags for a language until I define it here.  That can't be right, have I broken taglist?!
		" BUG: If I enable m:map for vim files, it detects "import" lines as a "map".
		" I guess "map" must be a built-in ctags rule, because the rule I created myself in ~/.ctags is called "mapping".
		let tlist_vim_settings = 'vim;a:autocmds;v:variable;f:function;c:command;m:mapping' " ;h:htag ;m:map
		let tlist_dosini_settings = 'dosini;s:section'
		let tlist_haxe_settings = 'haxe;p:package;d:typedef;e:enum;t:enum_field;c:class;i:interface;f:function;v:variable'
		let tlist_grm_settings = 'joeygrammar;r:rule'
		let tlist_haskell_settings = 'haskell;d:data;t:type;s:signature;f:function' " ;p:pattern
		"let tlist_markdown_settings = 'markdown;1:level1;2:level2;3:level3'
		" Ubuntu started detected .md files as filetype 'mkd' not 'markdown'
		" I will try out their syntax for a while...
		let tlist_mkd_settings = 'mkd;1:level1;2:level2;3:level3'
		let tlist_help_settings = 'help;s:section;h:heading;m:marker'
		let tlist_scala_settings = 'scala;p:package;i:include;c:class;o:object;t:trait;r:cclass;a:aclass;m:method;T:type' " V:value;v:variable;
		let tlist_man_settings = 'man;s:section'
		let tlist_html_settings = 'html;t:template;a:anchor;f:javascript function;i:id'
		let tlist_opa_settings = 'opa;m:module;t:type;d:database;g:global;f:function'
		let tlist_php_settings = 'php;c:class;d:constant;f:function' " ;v:variable

	" }}}

	" >>> For vtreeexplorer.vim {{{
		let g:treeExplVertical = 1
		let g:treeExplWinSize = 24
		" let g:treeExplAutoClose = 0
		let g:treeExplNoList = 1
	" }}}

	let g:Grep_OpenQuickfixWindow = 1
	let g:Grep_Default_Filelist = ". -r -I"
	" Note that g:Grep_Default_Filelist should be kept in sync with g:asyncfinder_ignore_dirs below.
	" General exclude folders:
	let g:Grep_Default_Filelist .= " --exclude-dir=CVS --exclude-dir=.git --exclude-dir=bin --exclude-dir=build"
	" General exclude files:
	let g:Grep_Default_Filelist .= " --exclude=tags --exclude=\'.*\\.sw?\' --exclude=\\*.min.js --exclude=\\*.min.css --exclude=\'*.log\'"
	" General exclude non-text files:
	" grep skips binary files by default, with the -I flag.  However it has to read the first few bytes of them, to guess if they are binary or not.
	" If there are a lot of those files, that can still cause a slowdown.  So skipping them by extension is faster.
	" Realistically we can probably remove the larger filetypes from this list.
	" I experimented {for,a,while} (with|patterns) but I could not \(find\|any\|way\) to use them, so we have one per line.
	let g:Grep_Default_Filelist .= " --exclude=\'*.jpg\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.png\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.gif\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.wav\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.mp3\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.ogg\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.m4a\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.mp4\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.avi\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.mkv\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.zip\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.tar\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.tgz\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.bz2\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.gz\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.rar\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.7z\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.deb\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.rpm\'"
	" Javascript:
	let g:Grep_Default_Filelist .= " --exclude-dir=node_modules --exclude-dir=\'node_modules*\'"
	let g:Grep_Default_Filelist .= " --exclude-dir=dist --exclude-dir=build --exclude-dir=.build --exclude-dir=_build"
	let g:Grep_Default_Filelist .= " --exclude-dir=coverage --exclude=bundle.js"
	" Tags files built by ctags, and by CTags plugin for Sublime Text
	let g:Grep_Default_Filelist .= " --exclude=.tags --exclude=.tags_sorted_by_file"
	" For ~/.vim/sessions:
	let g:Grep_Default_Filelist .= " --exclude-dir=sessions"
	" Assets compiled by Ruby
	let g:Grep_Default_Filelist .= " --exclude-dir=tmp"
	" This was not working on my Mac - using (BSD grep) 2.5.1-FreeBSD
	"let g:Grep_Default_Filelist .= " --exclude-dir=public/assets"   " Precompiled assets (e.g. images)
	" However this works fine there!
	let g:Grep_Default_Filelist .= " --exclude-dir=./public/assets"   " Precompiled assets (e.g. images)
	" Of course 'public' or 'assets' on its own should work fine, but we don't want that!
	" For Meteor:
	" bundler-cache and plugin-cache and other folders sit below here
	"let g:Grep_Default_Filelist .= " --exclude-dir=./.meteor/local"
	" On Linux, I could not get a two-folder exclude working
	" The only thing I could do was this:
	let g:Grep_Default_Filelist .= " --exclude-dir=.meteor"
	" For UL:
	let g:Grep_Default_Filelist .= " --exclude-dir=deploy_TMP"
	" For MCan:
	let g:Grep_Default_Filelist .= " --exclude-dir=private"
	" Sourcemaps
	let g:Grep_Default_Filelist .= " --exclude=\'.*.map\'"
	" Non-code folders in WordPress
	let g:Grep_Default_Filelist .= " --exclude-dir=wp-content/uploads"
	let g:Grep_Default_Filelist .= " --exclude=\'*.mo\'"
	let g:Grep_Default_Filelist .= " --exclude=\'*.po\'"
	" For Dwitter:
	let g:Grep_Default_Filelist .= " --exclude-dir=venv"

	let g:ConqueTerm_Color = 1
	" let g:ConqueTerm_CloseOnEnd = 1
	let g:ConqueTerm_CloseOnEndIfSplit = 1
	" let g:ConqueTerm_CloseOnSuccess = 1
	let g:ConqueTerm_InsertOnEnter = 1
	let g:ConqueTerm_ReadUnfocused = 1   " I fear this may be preventing me from leaving the window!
	" Instead of ConqueTerm, split-term is quite popular (although it might only work in nvim)

	let g:yaifa_max_lines = 400   " taglist.vim needs at least 100, minibufexpl.vim needs 312!

	"" Now I am using sessionman.vim
	"" Balls am I.  I am using my own, simplesession.vim !
	"" For sessionman.vim:
	let g:sessionman_save_on_exit = 0     " disabled for now
	let g:sessionlist_stay_open = 1
	let g:sessionman_preview_sessions = 1
	"" For session.vim:
	let g:session_autosave = 1

	" Can't be set here.  Needs to be set late!
	" :set winheight 40

	" SkyBison
	cnoremap <c-k> <c-r>=SkyBison("")<cr><cr>
	" TODO: Would rather do this later so we can check if SkyBison is present.

	let g:recover_always_choose = 1   " diff
	let g:recover_delete_swapfile_if_identical = 1
	let g:recover_delete_swapfile_when_diffing = 1

	let g:ctrlp_map = '<c-t>'
	let g:ctrlp_custom_ignore = {
		\ 'dir':  '\v[\/](CVS|\.git|\.hg|\.svn|node_modules|node_modules.*)$',
		\ 'file': '\v\.(exe|so|dll)$'
	\ }
		"\ 'file': '\..*\.sw.$',
		"\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',

	" Neither of these really worked how I wanted.  How about SkyBison?
	nmap <C-d> :e **/*<C-k>
	" This becomes a nice tool for selection but it is slow at the root of deep trees, especially since we have no way to exclude folders.

" }}}



" >>> Options for MY plugins {{{

	let g:hiline = 1
	let g:hiword = 1

	let g:search_centered = 0

	let g:blinking_statusline = 1

	let g:RepeatLast_Enabled = 0
	let g:RepeatLast_TriggerCursorHold = 3
	let g:RepeatLast_SaveToRegister = 'l'
	let g:RepeatLast_Show_Debug_Info = 0
	let &ch += g:RepeatLast_Enabled + g:RepeatLast_Show_Debug_Info

	let g:coffeeAutoCompileAll = 1
	let g:coffeeShowJSChanges = 1

	let g:breakindent_char = ' '
	let g:breakindent_never_shallow = 1

	" let coffee_compile_on_save=1

	let g:ToggleMaximize_RestoreWhenSwitchingWindow = 1

	"let g:NoSwapSuck_Debug = 1
	"let g:NoSwapSuck_CheckSwapfileOnLoad = 0
	"let g:NoSwapSuck_CreateSwapfileOnInsert = 0
	"let g:NoSwapSuck_CloseSwapfileOnWrite = 0
	" This was not sufficient to solve the problem when opening a file (although it might have helped when editing a file)
	if has('mac') || has('macunix')
		" It appears that MacVim does not actually delete the swapfile when we "close" it, which means it complains as soon as we start editing again, or open a new file.  Until we have debugged this, let's just not ever use the swapfile.
		let g:NoSwapSuck_Enabled = 0
		set noswapfile
	endif

	" recover.vim works better if 'swapfile' is enabled when it runs.
	"set swapfile

	" But in fact, 'swapfile' is unset by noswapfile.vim!

	let g:wrs_default_height_pct = 99

	let g:JBS_Show_Buffer_List_First = 0

" }}}



" >>> Options for VIM itself {{{

	set background=dark

	set updatetime=300

	" My defaults, which may be overridden later by filetype rules, plugins, or
	" modeline.
	"set sw=3 "shiftwidth
	"set ts=3 "tabstop
	" I find these are better defaults given that I am often editing markdown.
	set ts=4 sw=4 expandtab

	" Links vim's unnamed register with the desktop's clipboard, no more "* needed!
	" This seems like a nice idea, but it's actually not.  If you do `cw<Paste>` then the `cw` will have clobbered the desktop clipboard before you get the chance paste.
	"set clipboard^=unnamed

	" The default textwidth=0 will wrap to screen width, if screen width is <79.  This seems undesirable to me.  If we are wrapping, let's wrap to "the standard width" 80.
	"set textwidth=79
	" On second thought, being a significant whitespace nazi, I don't actually want auto-wrapping when I am typing.  Leaving it at 0 helps to achieve this.

	"" If you need to fix backspace, try one of these:
	" :fixdel
	" :set t_kD=^V<Delete>
	" :!echo "keycode 14 = BackSpace" | loadkeys
	"" All from the manual: :h :fixdel

	" Make searches case-sensitive only if they contain an uppercase character
	set ignorecase smartcase

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
	"" The BufEnter hook is no longer working.
	" :auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ (%n/%{bufnr('$')})%)
	" :auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ (%n/%{argc()})%)
	"" Accurate:
	" :auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ (%{bufnr('$')}\ buffers)%)
	"" Percentage through file instead:
	" :auto BufEnter * set titlestring=[VIM]%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ [%P]%)

	"" Now prepending all Vim title's with "= " so they are clearly grouped in task list.
	" :set titlestring=\=%(\ %M%)\ %t%(\ (%{expand(\"%:~:.:h\")})%)%(\ [%P]%)
	"" It will only make things worse.  :p

	"" Show working folder, filename, path to file, and server name
	" set titlestring=%{ShortenIfNeeded(fnamemodify(getcwd(),':~'))}\ (\ \ \ %t\ \ \ )\ %<%{ShortenIfNeeded(fnamemodify(bufname('%'),':p:~:.:h'))}
	" \ \ \ %{v:servername}
	function! ShortenIfNeeded(_path)
		let path = a:_path
		let maxlen = &columns / 3
		if len(path) > maxlen
			"return shortenpath(path)
			return "<" . path[len(path) - maxlen - 1 : len(path)]
		else
			return path
		endif
	endfunction
	"" Show working folder name only, and the filename
	" set titlestring=%{fnamemodify(getcwd(),':t')}\ %<(%{ShortenIfNeeded(fnamemodify(bufname('%'),':p:~:.'))})
	"" The last two parts of the working folder's path
	"set titlestring=%{fnamemodify(getcwd(),':s+.*/\\([^/]*/[^/]*\\)+\\1+g')}/\ %<(%{ShortenIfNeeded(fnamemodify(bufname('%'),':p:~:.'))})
	"set titlestring=[%{fnamemodify(getcwd(),':s+.*/\\([^/]*/[^/]*\\)+\\1+g')}]\ %<%{ShortenIfNeeded(fnamemodify(bufname('%'),':p:~:.'))}
	set titlestring=%<%{ShortenIfNeeded(fnamemodify(bufname('%'),':p:~:.'))}\ —\ %{ShortenIfNeeded(fnamemodify(getcwd(),':s+.*/\\([^/]*/[^/]*\\)+\\1+g'))}
    " \ %{get(v:,'servername','')?'\ ['.v:servername.']':''}

	"" NOTE: To keep the netrw file listing open, open the first file with 'v' and subsequent files with 'P'
	"" Default to tree view
	let g:netrw_liststyle = 3
	"" Make `v` open the file on the right rather than the left
	let g:netrw_altv = 1
	"" Make the split use more space for editor than for the tree
	let g:netrw_winsize = 80

	"" I have disabled the following settings because:
	""
	"" 1. When using MinBufExplorer, we always get a horizontal split, not the vertical split we wanted.
	"" 2. Sometimes I just want to open one file, so I really do want to open it in the current pane.
	"" 3. These settings won't help me to learn how to use vanilla Vim.
	""
	"" When hitting enter, open the file in the previous window instead of the current (or split)
	" let g:netrw_browse_split = 4
	"" When first opening the preview/previous window, use a vertical split
	" let g:netrw_preview = 1


	" if has("gui_kde")
	" 	set guifont=Courier\ 10\ Pitch/10/-1/5/50/0/0/0/1/0
	" endif

	if has('gui')
		" Hide the menu and toolbar which I never use.
		set guioptions-=m
		set guioptions-=T
        "" Remove the right scrollbar
		"set guioptions-=r
        " Remove the left scrollbar
		set guioptions-=L
	endif


	" Before choosing which font to use, we need to know which OS we are running on.
	" See: http://vi.stackexchange.com/questions/2572/detect-os-in-vimscript
	" We stopped using g:os because later VAM sets g:os using a different method.
	" (It appears to set the first X it can find for which has(X) responds positively.)
	if !exists('s:operating_system')
		" This doesn't work for the default /usr/bin/vim on macOS, but I don't need to detect that
		if has('mac') || has('macunix')
			let s:operating_system = "Darwin"
		elseif has('win16') || has('win95') || has('win32') || has('win64')
			let s:operating_system = "Windows"
		elseif has('unix')
			let s:operating_system = "Linux"
		else
			let s:operating_system = "other"
		endif
		" If we can't trust 'has()' then this is an alternative for Unixes:
		" Possible results: "Darwin", "Linux"
		"let s:operating_system = substitute(system('uname'), '\n', '', '')
	endif


	if s:operating_system ==# 'Linux' && system('which open_in_current_browser >/dev/null && echo -n found') ==# 'found'
		let g:netrw_browsex_viewer = 'open_in_current_browser'
	endif


	"" Select font!
	"" These are some old methods I used to select the font

	" if has("gui_kde")
	" 	set guifont=Courier\ 10\ Pitch/10/-1/5/50/0/0/0/1/0
	" 	set guifont=Lucida\ Console/8/-1/5/50/0/0/0/1/0
	" endif
	" if has("gui_kde") || has("gui_x")
    " 	set guifont=Bitstream\ Vera\ Sans\ Mono/10/-1/5/50/0/0/0/1/0
	" endif

	"" Medium for any linux:
	" :set guifont=-*-lucidatypewriter-*-*-*-*-*-80-*-*-*-*-*-*   "" fail
	"" Small for any linux:
	" :set guifont=-*-fixed-*-*-*-*-*-80-*-*-*-*-*-*

	" :set guifont=Fixed\ Semi-Condensed\ 7
	" :set guifont=Fixed\ Semi-Condensed\ 9
	" :set guifont=Beeb\ Mode\ One\ 6

	"" Clean is a small fine font for low-res displays:
	"" It is a bitmap font, so it looks pixelated above 17px or 160pt.
	"" Sadly in modern Ubuntu, this font is not available/enabled by default.
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-150-*-*-c-*-iso646.1991-irv
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
	" :set guifont=Lucida\ Console\ Semi-Condensed\ 8
	"" On pod Semi-Condensed was actually wider!  So:
	" :set guifont=Lucida\ Console\ 8
	"" Very small and clear; quite like Teletext font
	" :set guifont=MonteCarlo\ Fixed\ 12\ 11

	"" In Vim 800 on Mac OS X, if I was in GVim (Mac Vim) and loaded this file, and tried to select a font that did not exist on the system, then I got interrupted by an error message.

	if exists("&guifont") && s:operating_system == "Linux"
		if $SHORTHOST == "pod"
			"" Most Linux offer Mono but it's a little tall
			" :set guifont=Monospace\ 8
			"" I usually prefer Liberation but some days I prefer this:
			":set guifont=Dejavu\ Sans\ Mono\ 8
			"" On Ubuntu Liberation is slightly shorter
			:set guifont=Liberation\ Mono\ 8
		elseif $SHORTHOST == "porridge" || $SHORTHOST == "ubuntu"
			"" Another Ubuntu, with more pixels
			":set guifont=Monospace\ 11
			":set guifont=Liberation\ Mono\ 11
			"" Screen font; brighter:
			":set guifont=Liberation\ Mono\ 10
			"" Rounded but not so bright, same size boxes but smaller chars!
			":set guifont=Andale\ Mono\ 9
			"" At size 10 this is shorter than Andale.  In fact it is shorter than my xterm 100, although it doesn't look it!
			"" :set guifont=Lucida\ Console\ 10
			"" Actually it's shorter than Andale at size 9 also, although it doesn't look it!
			":set guifont=Lucida\ Console\ 7
			"" And it's quite readable (and short) at size 7, although small.
			"" I know you have come back here to switch away from Lucida Console.  Don't!
			"" Now I have stopped using lightdm, all my fonts are appearing differently.  Lucida looks how I want it in GVim yay!
			:set guifont=Lucida\ Console\ 8
		elseif $SHORTHOST == "tomato"
			" Under Unity WM:
			":set guifont=Lucida\ Console\ 10
			" Under Fluxbox WM:
			call system("pgrep -f gnome-settings-daemon")
			if v:shell_error == 0
				" If gnome-settings-daemon has been run, these fonts look good, whilst Lucida has weird proportions.
				:set guifont=Envy\ Code\ S11\ 10
				" Smaller
				":set guifont=Envy\ Code\ S12\ 9
				" Nice thin
				":set guifont=Envy\ Code\ S11\ 13
				" First thick
				":set guifont=Envy\ Code\ S11\ 17
			else
				" If gnome-settings-daemon has not been run, Lucida looks better.
				:set guifont=Lucida\ Console\ 8
				" Although this is pretty good, and a bit smaller, provided we don't use bold too much
				":set guifont=Envy\ Code\ S12\ 9
				" This looks very flat, it looks like it is fitting a lot of rows onto the screen!  (Fluxbox)
				" However Lucida Console 6 is still clearer and smaller!
				":set guifont=Envy\ Code\ S11\ 8
			endif
		elseif $SHORTHOST == "tomato" || $SHORTHOST == "dumpling"
			:set guifont=Lucida\ Console\ 9
		else
			"" A good default for all Linux systems?
			" :set guifont=Lucida\ Console\ 8
			"" Set nothing.  Use the real default!
		endif
		"" If I want to go smaller than Lucida 8...
		"" Droid Sans Mono can go very small; it is rather fuzzy, but it is even smaller than Clean!
		" :set guifont=Droid\ Sans\ Mono\ 6
		"" If I screen fonts are available, there is "Schumacher Clean", which is the same height as Lucida Console 8, but narrower:
		" :set guifont=Clean\ 8
		"" Also with screen fonts, you have the option of using LucidaTypewriter, like Console but with sharp edges.  The only problem is that at size 8 its bold is weak: the chars are very slightly wider but no thicker.  At size 10 it is quite passable.
		" :set guifont=LucidaTypewriter\ Medium\ 8
	endif
	if exists("&guifont") && s:operating_system != "Linux"
		if s:operating_system == "Darwin"
			" Popular default for many Mac editors, "the Comic Sans of monospaced fonts" @codinghorror
			":set guifont=Monaco:h11
			" But I prefer the shorter fatter one.  Less elegant.
			:set guifont=Menlo\ Regular:h11
			" Manually installed fonts...
			" Better check we are on a known machine first
			if $SHORTHOST == "sinonets-MacBook-Pro"
				" Lucida Sans Typewriter is finer and cleaner than Menlo:
				:set guifont=Lucida\ Sans\ Typewriter\ Regular:h11
				" Lucida console is fat again, but a bit too squat in GVim
				":set guifont=Lucida\ Console:h11
				" On Mac, S11 and S12 are both quite short, but Squat is just about right.
				":silent! :set guifont=Envy\ Code\ Squat:h13
			endif
			" My 2023 settings
			"set guifont=HasklugNerdFontCompleteNerdFontM-Regular:h13 linespace=-1
			"if has('gui_running')	
				"winpos 200 38
				"set columns=137 lines=48
			"endif
			" My 2024 settings
			set guifont=Lucida\ Sans\ Typewriter\ Regular:h13
			if has('gui_running')	
				winpos 200 38
				set columns=137 lines=50
			endif
		elseif s:operating_system == "Windows"
			:set guifont=LucidaTypewriter\ 8
		endif
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
	":set guicursor=a:blinkoff0

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

	" formatoptions is local to buffer, and some builtin scripts (e.g. vim.vim) override any options we set here, so we set them on BufReadPost instead.
	" +j only joined formatoptions in version 7.3.541.  v:version is not fine-grained enough to detect it.  We avoid potential errors in earlier versions of Vim by wrapping in try-catch.
	" Although +=nl worked, for some reason -=ct did not, so I split them up into separate lines.
	au BufReadPost,BufNewFile * set formatoptions+=n   " Better indent numbered lists in comments
	au BufReadPost,BufNewFile * set formatoptions+=l   " Don't wrap lines that were already long
	au BufReadPost,BufNewFile * set formatoptions-=c   " Don't auto-wrap comments
	au BufReadPost,BufNewFile * set formatoptions-=t   " Don't auto-wrap in general
	"au BufReadPost,BufNewFile * set formatoptions+=o   " When hitting O or o on a comment line, start the new empty line with a comment.
	" BUG: This was breaking joeyhighlight!
	"au BufReadPost,BufNewFile * try | set formatoptions+=j | catch e | endtry
	" Workaround: Try it now; if it works then setup the autocmd
	try
		set formatoptions+=j
		au BufReadPost,BufNewFile * set formatoptions+=j
	catch
	endtry

	" To show the margin column
	"if v:version >= 703
		"set colorcolumn=+1
	"end

	" Add a few custom filetypes:
	au BufReadPost,BufNewFile {*.shlib}              set ft=sh
	au BufReadPost,BufNewFile {*.grm}                set ft=grm
	" From web:
	au BufReadPost,BufNewFile {/usr/share/X11/xkb/*} set ft=c
	au BufReadPost,BufNewFile {*.md}                 set ft=markdown

	" Do not use a swapfile when editing files in Dropbox
	autocmd BufNewFile,BufRead {$HOME/Dropbox/*} setlocal noswapfile | let b:NoSwapSuck_NoSwapfile = 1

	" View (and save) rich document files in Vim:
	"autocmd BufReadPost *.odt :%!odt2txt %
	autocmd BufReadPost  *.docx :%!pandoc -f docx     -t markdown | set readonly
	autocmd BufWritePost *.docx :!pandoc  -f markdown -t docx     % > /tmp/tmp.docx
	autocmd BufReadPost  *.odt  :%!pandoc -f odt      -t markdown | set readonly
	autocmd BufWritePost *.odt  :!pandoc  -f markdown -t odt      % > /tmp/tmp.odt

	"" I need to update some of my highlights for 256 color mode, so I'm not using it at the moment.
	"" Re-enabled for dim_inactive_windows
	if $TERM != "linux" && $TERM != "screen"
		set t_Co=256
	end

	"" Recognise Node stack-traces:
	"" Basic:
	"let &errorformat .= ',' . '%*[\ ]%m (%f:%l:%c)'
	"" Full:
	" Error: bar
	"     at Object.foo [as _onTimeout] (/Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2:9)
	let &errorformat  = '%AError: %m' . ','
	let &errorformat .= '%Z%*[\ ]%m (%f:%l:%c)' . ','
	"     at Object.foo [as _onTimeout] (/Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2:9)
	let &errorformat .= '%*[\ ]%m (%f:%l:%c)' . ','
	" /Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2
	"   throw new Error('bar');
	"         ^
	let &errorformat .= '%A%f:%l,%Z%p%m' . ','
	" Ignore everything else
	"let &errorformat .= '%-G%.%#'
	" If not working, see project: https://github.com/felixge/vim-nodejs-errorformat/blob/master/ftplugin/javascript.vim

	"" Thought this would make Vim swapfile messages smaller, but it didn't.  :P
	" set shortmess+=A

	"" For the autocompleter:
	"" longest won't select the first result if there are many; it will let you type more to narrow the list.
	"" menuone will display the menu even if there is only one possibility; this allows you to see any meta-info (e.g. the filename containing this word)
	"set completeopt+=longest,menuone
	"" This is pretty nice, but the autocompleter is so great, it often places the thing I want first in the list.  So I can just press <Tab> once.  This seems more of a time-saver.  Use the above only if the thing you want keeps appearing far down a list of many items.
	"" So I am sticking with the default now:
	"set completeopt=menu,preview

	set winwidth=1

	" Change cursor color for Normal/Insert mode
	if &term =~ "xterm"
		"let &t_EI = "\<Esc>]12;#ffdd22\x7" " Normal Mode = Yellow/cream
		"let &t_EI = "\<Esc>]12;#ff9911\x7" " Normal Mode = Rich orange
		let &t_EI = "\<Esc>]12;#ffbb44\x7"  " Normal Mode = Creamy orange
		"let &t_SI = "\<Esc>]12;#ff4411\x7" " Insert Mode = Reddish-orange
		"let &t_SI = "\<Esc>]12;#22ff22\x7" " Insert Mode = Bright green
		let &t_SI = "\<Esc>]12;#44ff77\x7"  " Insert Mode = Aqua
	endif

	" When opening a file (e.g. from the quicklist), if the file exists in a window already, jump to that window.
	set switchbuf+=useopen
	" You can get quickfix actions on various keys using https://github.com/mileszs/ack.vim#keyboard-shortcuts or https://github.com/yssl/QFEnter

	" So that fugitive's :Gdiff will split left/right
	" Although the recommended way to achieve that is to call :Gvdiff
	set diffopt+=vertical

	" Prevent $(...) from being marked as an error.
	let g:is_bash = 1

" }}}



" >>> Key mappings / Key bindings {{{

	" Most of my good keybinds are stored in ~/.vim/plugins/joeykeymap.vim
	" What follows are bindings I am testing before sharing.

	" Fix broken Backspace under gentoo:
	" :imap  <Left><Del>

	" I never need to use this key, and my Escape key (on pod) is a bit tempramental.
	map £ <Esc>
	imap £ <Esc>

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

	"" Fix for the external keyboard when I plug it into this UK layout MacBook
	"if has('mac') || has('macunix')
	"	nmap £ #
	"	imap £ #
	"endif

" }}}




" >>> Custom Plugin Loader (ignore scripts in CVS folders) {{{

	" Plugins
	" CVS leaves old versions in ~/.vim/plugins/CVS/Base/*.vim
	" These get loaded by Vim!
	" But we can disable auto-loading, and load them manually ourself, without
	" the subdirectories.  This could cause problems, but at time of writing, I
	" could not find any .vim files in subdirs of standard Vim plugin folders.
	"set noloadplugins
	" Original behaviour: runtime! plugin/**/*.vim
	"runtime! plugin/*.vim

	augroup ForbidCVS
		autocmd!
		autocmd SourceCmd */CVS/* :" Do nothing
		"autocmd SourceCmd */CVS/* echo "Not sourcing CVS script: ".expand("<afile>")
	augroup END

" }}}



" Sometimes we want to load lightweight, without all the extra plugins
" At the moment, only when git is prompting us for a commit message.
" CONSIDER: For a truly minimal vim, we should skip everything else in this file, and convince Vim not to load plugins from our .vim folder too.
if argc() == 0 || argv(0) != ".git/COMMIT_EDITMSG"

" >>> Addons (the neat way) {{{

	" At present we are using: https://github.com/MarcWeber/vim-addon-manager.git
	" If you want to switch to an alternative manager, Plug looks quite powerful.
	" Here we see Plug can activate only when a certain filetype is opened: https://github.com/ap/vim-css-color/issues/79#issuecomment-372142928
	" But lazy loading is now possible with vim-add-manager too!  https://github.com/MarcWeber/vim-addon-manager#lazily-loading-plugins--tag-plugins-by-topic--pass-dictionaries-for-adding-arbitrary-options

	" Note that vim-addon-manager clones shallow git history, which is faster and saves disk space, but can make a mess of merges.
	" To expand a repository to full history, simply: git fetch --depth=999999
	" Git seems to be better at managing merges from shallow clones now.

	" TODO: In my next reincarnation, I might try using vim-plug: https://github.com/junegunn/vim-plug#on-demand-loading-of-plugins

	" >>> Plugins from the Cloud {{{

	"" A nice searchable plugin repository: https://vimawesome.com/

	"" TODO: All these plugins increase vim's startup time.
	"" This is not just about Vim processing the scripts, a significant cost is the traversal of all the filesystem folders for the following plugins.  (To demonstrate this, try opening vim twice in a row - only the first time is slow!)
	"" Tactics:
	"" - Separate into essential and optional plugins.  On very slow machines, only load the former.
	""   (I also want to separate out "must-try" plugins for sharing with others, from those plugins which I suspect not so many people will enjoy.)
	"" - Lazy-load plugins which are only sometimes needed.  E.g. rare language-specific plugins like 'vaxe' and 'jade' could be loaded differently.  (Well they aren't actually loaded now, but their tree is added to runtimepath, slowing startup.)

	"" We are using VAM.  http://github.com/MarcWeber/vim-addon-manager
	"" Note that this is NOT Debian's vim-addon-manager package!  Nor is it pathogen.
	"" I build the list, rather than declare it, so lines can be easily added/removed.
	let vamAddons = []

	" Note that one of the biggest changes for my config is that 8-color terminals will upgrade to 16-color, with the result that cterm highlights marked bold will actually display as bright and not as bold or bold-and-bright.
	call add(vamAddons,"github:tpope/vim-sensible")      " Good defaults

	" call add(vamAddons,"vim-haxe")                       " Haxe syntax
	" call add(vamAddons,'github:jdonaldson/vim-haxe')     " Haxe syntax
	" call add(vamAddons,'github:jdonaldson/vaxe')           " Haxe syntax (preferred)

	" call add(vamAddons,'github:derekwyatt/vim-scala')      " Scala syntax and more
	" call add(vamAddons,'/stuff/joey/projects/scala/scala-dist-vim') " Older but does not load this way!

	call add(vamAddons,'github:mbbill/undotree')           " Allows you to view undos.  I need a newer Vim for this!
	"call add(vamAddons,'github:majutsushi/tagbar')         " Nests tags in some languages.  Don't actually try using this with custom .ctags settings.  It will explode until you have configured it correctly.
	" call add(vamAddons,"VOoM")                           " Another outliner
	" call add(vamAddons,'github:xolox/vim-easytags')      " Runs ctags automatic for you, to update them
	"call add(vamAddons,'github:ervandew/supertab')         " Seems a lot like another_tabcompletion.vim but the list appears backwards! =/
	call add(vamAddons,'github:joeytwiddle/vim-foist')     " Complete a partial line, by looking for the longest match in history
	                                                       " If they are not taken, we could use <C-X><C-P> for a partial line and <C-X><C-S> for a sentence

	" asyncfinder wants python 2 (aka python), UltiSnips wants python3.
	" So let's try:
	"   brew reinstall macvim --with-python --with-python3
	" Optional: --without-python
	" Actually no matter what arguments I try giving it, it always says:
	"   MacVim can no longer be brewed with dynamic support for both Python versions.
	"   Only Python 3 support has been provided.

	let g:UltiSnipsJumpForwardTrigger="<tab>"
	let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
	" With MacVim, UltiSnips picks python3 by default, which stops Asyncfinder from working.  Specifying python2 here prevents that problem.
	" DISABLED: That fix has stopped working now that python2 is no longer installed
	"let g:UltiSnipsUsePythonVersion = 2
	"call add(vamAddons,'UltiSnips')                        " Breaks my usual Tab-completion!  (But is compatible with SuperTab)
	call add(vamAddons,'github:joeytwiddle/ultisnips')     " Fix that restores my usual Tab-completion.

	call add(vamAddons,'github:bootleq/LargeFile')       " Disable some things when loading a huge file

	" call add(vamAddons,'github:troydm/easybuffer.vim')
	" call add(vamAddons,'github:chrisbra/NrrwRgn')

	" call add(vamAddons,'github:vim-scripts/YankRing.vim')   " Vim's 1-9 registers provide limited support for this already
	"" DISABLED: YankRing blocks 'P' (paste) from being a repeatable action with '.' - I cannot have that!  (Is it supported with Repeat.vim present?)
	"" Instead of how YankRing does it, I'd quite like to have "2p to paste the second-to-last yank.  Oh Vim does that already!  xD
	"call add(vamAddons,"github:the-isz/MinYankRing.vim") " Minimalist yank ring.  Suffers the same issue!
	"let g:MYR_NextMap = '\<C-n>'
	"let g:MYR_PrevMap = '\<C-p>'

	" call add(vamAddons,'github:michaelficarra/vim-coffee-script')   " Coffeescript syntax
	" call add(vamAddons,'github:kchmck/vim-coffee-script") " An alternative: syntax, indenting, compiling, and more
	"call add(vamAddons,"github:paradigm/SkyBison")          " Immediate feedback on the cmdline.  I never use this, Tab-completion is pretty fine for me.
	"call add(vamAddons,"github:gokcehan/vim-yacom")      " Toggle comments with <Leader>c.  I never got around to trying it.
	"call add(vamAddons,"github:digitaltoad/vim-jade")    " Jade/Pug syntax
	"call add(vamAddons,"github:FredKSchott/CoVim")       " Collaborative editing with vim!
	" call add(vamAddons,"github:Raimondi/YAIFA")          " Indent Finder
	"call add(vamAddons,"github:vim-scripts/yaifa.vim")   " Indent Finder
	call add(vamAddons,"github:joeytwiddle/YAIFA")   " Indent Finder

	" call add(vamAddons,"github:vim-scripts/vtreeexplorer.vim")   " File Manager (I have this in plugin/ already)

	call add(vamAddons,"github:scrooloose/nerdtree")
	"let g:NERDTreeMinimalUI=1
	" This fixes the bug of Vim starting with MBE focused (or not focused)
	" But also I don't want it to hijack netrw anyway!
	let g:NERDTreeHijackNetrw = 0

	" call add(vamAddons,"github:kien/ctrlp.vim")          " Quick file finder (I mapped it to Ctrl-T).  Docs: http://kien.github.io/ctrlp.vim/
	call add(vamAddons,"github:guns/xterm-color-table.vim")   " Useful for picking colours

	" On my VMO2 MacBook, the presence of any error messages or echo-es, combined with the presence of some of these vamAddons, sometimes (but not always) causes what appears to be a ""P happen when the file first opens.
	"call add(vamAddons,"github:joeytwiddle/asyncfinder.vim")   " Another quick file finder (I mapped it to Ctrl-A).
	"nmap <C-a> :AsyncFinder<Enter>
	" I usually have RepeatLast enabled.  If so, this works much better:
	"nmap <C-a> q:AsyncFinder<Enter>
	" Or the following is smart enough to decide for us.  BUG: The `normal q` part fails on an empty buffer with error: "E749: empty buffer"
	nnoremap <silent> <C-a> :if exists("g:RepeatLast_Enabled") && g:RepeatLast_Enabled <Bar> :normal q<Enter> <Bar> :endif <Bar> :AsyncFinder<Enter>
	let g:asyncfinder_initial_pattern = '**'
	" Note that g:asyncfinder_ignore_dirs should be kept in sync with g:Grep_Default_Filelist above.
	let g:asyncfinder_ignore_dirs = "['.AppleDouble', '.DS_Store', '.git', '.hg', '.bzr', 'CVS', '.svn', 'node_modules', 'node_modules*', 'dist', 'build', 'tmp', './public/assets', '*/.meteor/local/*', 'deploy_TMP', 'private', '.ccache', 'venv']"
	" I thought this builtin might be a nice simple alternative but I could not get it to find deep and shallow files (** loses the head dir, */** misses shallow files):
	"nmap <C-a> :find *

	call add(vamAddons,"github:tpope/vim-fugitive")      " Git helper uses copen a lot, and allows editing indexes.  :Glog :Ggrep
	call add(vamAddons,"github:gregsexton/gitv")         " Addon to fugitive, with range :Gitv!
	" For some reason, gitgutter is somehow affecting my statusline highlight.  (Seen on MacVim and Linux vim and gvim)
	" BUG: It seems that the first %#HighlightGroup# works ok, but the next one turns us to white-on-black.
	" This can be fixed by opening plugin/gitgutter.vim and removing the BufEnter autocmd event.
	" If you get into a mess, here is a quick way to clear all highlights from the statusline:
	"   let &statusline = substitute(&statusline, '%#[A-Za-z]*#', '', 'g')
	call add(vamAddons,"github:airblade/vim-gitgutter")  " Git meta-info about each line (in left-hand signs column (the gutter), or the background color of each line)
	"let g:gitgutter_diff_args = '-w "master@{1 week ago}"'
	" Jump between changed hunks
	nmap ]g <Plug>GitGutterNextHunk
	nmap [g <Plug>GitGutterPrevHunk
	"call add(vamAddons,"github:mhinz/vim-signify")       " Similar but supports more VCSs!  BUT was pretty slow on some files, and completely locking up vim on some others (e.g.: j/tools/wine and ~/.vim/ftplugin/sh.vim).  Even turning it off with :SignifyToggle took ages!
	"call add(vamAddons,"github:chrisbra/changesPlugin")  " Another gutter plugin to indicate buffer edits (not git).  Requires Vim8
	"call add(vamAddons,"github:terryma/vim-expand-region")   " Grow the visual block easily
	"call add(vamAddons,"github:vim-scripts/ScreenShot")  " Take HTML screenshots of your Vim
	call add(vamAddons,"github:tpope/vim-repeat")        " Helps `.` to work with plugins (including fanfingtastic)
	call add(vamAddons,"github:dahu/vim-fanfingtastic")  " multi-line f,t,F,T - works well for me.
	"call add(vamAddons,"github:chrisbra/improvedft")     " Another one to try
	"call add(vamAddons,"github:vim-scripts/SearchComplete") " Tab-completion in the / search interface.  This breaks <Up> and intereferes with :b and and :Grep.
	"call add(vamAddons,"github:goldfeld/vim-seek")       " Quickly seek new position by 2 chars, on `s`
	"call add(vamAddons,"github:dahu/vimple")             " Get the buffers as a list
	"call add(vamAddons,"github:Raimondi/vim-buffalo")    " Buffer switcher - requires vimple
	call add(vamAddons,"surround")                        " Change dict(mykey) to dict[mykey] with cs([ delete with ds( or create with csw[ or ysiw[ or viwS[
	call add(vamAddons,"vim-indent-object")                        " Change dict(mykey) to dict[mykey] with cs([ delete with ds( or create with csw[ or ysiw[ or viwS[

	"call add(vamAddons,"github:tpope/vim-markdown")       " More recent version of the syntax file bundled with Vim.
	"call add(vamAddons,"github:jtratner/vim-flavored-markdown")   " Provides syntax highlighting on recognised blocks
	" The last time I tried, both of the above had trouble with lone '_'s which GitHub markdown was not interpreting as italics.
	" - tpope's highlighted them as errors (red)
	" - jtratner's interpreted them as italics even when GitHub did not!
	" plasticboy's has no such issue.
	" Maybe it is better to be warned, for general flavours of markdown.  But many of the popular ones are being kind to intra-word and lone _s now.
	" Now disabled in favour of whatever polyglot gives us
	"call add(vamAddons,"github:plasticboy/vim-markdown")  " Fix some bugs with the markdown syntax distributed with Vim (2010 May 21)
	"let g:vim_markdown_folding_disabled=1
	"silent! hi link mkdCode Preproc
	" Enable folding for markdown files (now in default vim files)
	let g:markdown_folding = 1

	" This will start a new browser window for realtime markdown preview: https://github.com/vim-scripts/instant-markdown.vim

	"call add(vamAddons,"github:dahu/bisectly")            " Wow!  A useful and light-hearted way to track down a bug to a specific plugin

	call add(vamAddons,"unimpaired")                      " Various next/previous keybinds on ]<key> and [<key>

	" Expand Zen/Jade/Emmet-like snippets into HTML
	"call add(vamAddons,"github:tristen/vim-sparkup")     " Deprecated version
	"call add(vamAddons,"github:rstacruz/sparkup")        " Up-to-date version
	"let g:sparkupExecuteMapping = '<C-]>'
	"let g:sparkupNextMapping = '<C-]>n'   " The default <C-n> messes with my <Tab> mappings
	"let g:sparkupMappingInsertModeOnly = 1

	" A different implementation, by chrisgeo.  Default key is <C-e>
	"call add(vamAddons,"sparkup")
	"" Note that these configs will break rstacruz's sparkup!
	"let g:sparkup = {}
	"let g:sparkup.lhs_expand = '<C-]>'

	" Or use Emmet itself
	" Press `<C-y>,` to expand the shortcut under the cursor
	" Example syntax: ul>(li>.foo>a.menu-item[data-toggle=menu]{Text here})*5
	call add(vamAddons,"github:mattn/emmet-vim")
	"let g:user_emmet_leader_key='<C-y>'
	"let g:user_emmet_mode='i'   " Only in insert mode

	" Interesting: source folder's vimrc file for different settings in specific projects
	" I rarely use this, and it slows me down more often than I use it (when it prompts to load my rc_files/.vimrc)
	" http://www.vim.org/scripts/script.php?script_id=727#local_vimrc.vim
	"call add(vamAddons,"github:MarcWeber/vim-addon-local-vimrc")   " Create .local-vimrc settings per-project
	" An alternative is ".lvimrc":
	" http://www.vim.org/scripts/script.php?script_id=441

	call add(vamAddons,"github:vim-scripts/Align")        " Line up words across lines with :Align <character>
	call add(vamAddons,"github:vim-scripts/Tabular")      " Line up words across lines with :Tab /<regexp>
	" To align by spaces, the best I have found so far is:
	"   :Tab /[^ ][^ ]*
	" but that creates a gap of two spaces.  This CANNOT be fixed by appending /l0 or /l1 or /l2
	" Tabularise by spaces, right-align first column, left-align second column (I don't know why but I needed l1 twice!)
	"   :Tab / /r1l1l1
	" Left align the second column (leave the rest of the line untouched, don't mind leading spaces):
	"   :Tab /^ *[^ ]* *[^ ]*\zs /l1
	" Right align the first column (leave the rest of the line untouched):
	"   :Tab /^[^ ]*\zs /r1l1l1
	"  :Tab /^[^ ]*\zs /r1l1l1
	"  :Tab /^ *[^ ]* *[^ ]*\zs /l1

	" Javascript
	" Some suggestions for Node: https://github.com/joyent/node/wiki/Vim-Plugins
	" Some suggestions for Meteor: were recommended at: https://github.com/Slava/vimrc/
	" Improved indent and syntax for Javascript
	"call add(vamAddons,"github:vim-scripts/JavaScript-Indent") " Improved indent and syntax for Javascript and HTML (OLD, apparently buggy)
	" pangloss has more types for colorschemes like monokai.
	"call add(vamAddons,"github:pangloss/vim-javascript")
	"call add(vamAddons,"github:jelera/vim-javascript-syntax") " Even more comprehensive syntax
	"call add(vamAddons,"github:othree/yajs.vim")         " Fork of jelera's with almost as many stars
	" Conceals ""s until we are focused on them:
	"call add(vamAddons,"github:elzr/vim-json")
	" ES6 syntax highlighting and UltiSnips snippets
	"call add(vamAddons,"github:isRuslan/vim-es6")
	" JSX syntax highlighting (disabled now polyglot is providing highlighting)
	"call add(vamAddons,"github:mxw/vim-jsx")
	" This will turn all ft=javascript files into ft=javascript.jsx, which might be nice for syntax highlighting, but not for ctags!
	"let g:jsx_ext_required = 0
	" Linter: https://github.com/ruanyl/vim-fixmyjs
	"call add(vamAddons,"github:ruanyl/vim-fixmyjs")
	" For a good while, isRuslan offered more than pangloss
	" But the last time I checked, pangloss was more suitable for gentlemary than isRuslan was.
	" Anyway, right now we are using what polyglot provides.
	call add(vamAddons,"github:styled-components/vim-styled-components")

	" Switch between single-line and multi-line statement using gS or gJ.
	" Supports a bunch of languages.
	" But it interferes with my move_to_next_char on gJ, so disabled for now
	"call add(vamAddons,"github:AndrewRadev/splitjoin.vim")

	" Javascript beautification:
	"call add(vamAddons,"github:maksimr/vim-jsbeautify")    " Just a wrapper for jsbeautify
	" More options and can handle promise chains: https://github.com/millermedeiros/esformatter

	" For Meteor development
	" (One or both of these conflict with django-plus)
	" Now disabled.  I used to run both at the same time, but either one of them triggers css-color too often
	" I believe polyglot is now loading handlebars for us anyway
	"call add(vamAddons,"github:mustache/vim-mustache-handlebars")
	"let g:mustache_abbreviations = 1
	"call add(vamAddons,"github:slava/vim-spacebars")
	"call add(vamAddons,"github:leafgarland/typescript-vim")
	" Actually does much more than syntax highlighting but that's overkill for me
	"call add(vamAddons,"github:hdima/python-syntax")

	"call add(vamAddons,"github:groenewege/vim-less")

	call add(vamAddons,"github:joeytwiddle/repmo.vim")    " Allows you to repeat the previous motion with ';' or ','
	let g:repmo_mapmotions = "j|k h|l zh|zl g;|g, <C-w>w|<C-w>W"
	" Experimenting:
	let g:repmo_mapmotions .= " <C-w>+|<C-w>- <C-w>>|<C-w><"
	" Works but interferes with navigation_enhancer.vim: " <C-w>j|<C-w>k"
	" Do not work (presumably because they are non-standard mappings): " [w|]w [W|]W"
	let g:repmo_key = ";"
	let g:repmo_revkey = ","

	au BufReadPost,BufNewFile {*.json}               set ft=javascript
	"au BufReadPost,BufNewFile {*.json}               set ft=json
	" vim-json provides syntax for json, and automatically assigns filetype:
	"call add(vamAddons,"github:elzr/vim-json")
	" Dependencies for sourcebeautify:
	"call add(vamAddons,"github:michalliu/jsruntime.vim")
	"call add(vamAddons,"github:michalliu/jsoncodecs.vim")
	" sourcebeautify offers <Leader>sb
	" But so far it has just been giving me 'undefined'
	"call add(vamAddons,"github:michalliu/sourcebeautify.vim")

	" NOTE: For the tern plugin to work, you need to cd into the folder and do `npm install`
	"       You also need to create a .tern-project file for each project!
	call add(vamAddons,"github:marijnh/tern_for_vim")     " Static analysis of JS files
	"let g:tern_show_argument_hints = 'on_hold'
	let g:tern_show_argument_hints = 'never'              " Disabled because it keeps locking up Vim until tern times out (our codebase is large)
	let g:tern_show_signature_in_pum = 1
	" Curiously the documentation pops up in a Scratch window when I use <Tab> to complete a word, even if both of the above are set to off (defaults).
	" I also manually installed this: https://github.com/Slava/tern-meteor
	" When editing a JS or CS file, make K lookup documentation with Tern
	autocmd BufReadPost,BufNewFile *.{js,coffee} nnoremap <buffer> K :TernDoc<CR>

	" Here is a minimal alternative to EasyMotion: https://github.com/vim-scripts/PreciseJump
	"call add(vamAddons,"github:Lokaltog/vim-easymotion")  " Let's use the latest EasyMotion
	call add(vamAddons,"github:joeytwiddle/vim-easymotion") " My dev copy
	"map <Leader><Leader>l <Plug>(easymotion-lineforward)
	"map <Leader><Leader>j <Plug>(easymotion-j)
	"map <Leader><Leader>k <Plug>(easymotion-k)
	"map <Leader><Leader>h <Plug>(easymotion-linebackward)
	let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion
	" These work fine with map but I only really want them in normal and visual modes
	" Although we could apply them in operator-pending mode.  The problem is when the user does `dt;` or `ct;` then there is a flash pause before the chars are deleted, which does not feel/look responsive to the user.  Ideally we would remove the chars before flashing (perhaps easier for `d` than for `c`.)

	let force_remap_of_semicolon_and_comma = 1

	if !force_remap_of_semicolon_and_comma
		map ; <Plug>(easymotion-next-in-dir)
		map , <Plug>(easymotion-prev-in-dir)
		nmap f <Plug>(easymotion-flash-f)
		nmap F <Plug>(easymotion-flash-F)
		nmap t <Plug>(easymotion-flash-t)
		nmap T <Plug>(easymotion-flash-T)
		vmap f <Plug>(easymotion-flash-f)
		vmap F <Plug>(easymotion-flash-F)
		vmap t <Plug>(easymotion-flash-t)
		vmap T <Plug>(easymotion-flash-T)
	else
		" Repmo remaps `;` and `,` to itself, and I like it doing that.
		" But when I use `f` and friends, I want to remap ';' and ',' back to the "original" easymotion repeat mappings.
		nnoremap <silent> <Plug>(remap-semicolon-and-comma) :map ; <Plug>(easymotion-next-in-dir)<CR>:map , <Plug>(easymotion-prev-in-dir)<CR>
		vnoremap <silent> <Plug>(remap-semicolon-and-comma) <Esc>:map ; <Plug>(easymotion-next-in-dir)<CR>:map , <Plug>(easymotion-prev-in-dir)<CR>gv
		nmap <silent> f <Plug>(remap-semicolon-and-comma)<Plug>(easymotion-flash-f)
		nmap <silent> F <Plug>(remap-semicolon-and-comma)<Plug>(easymotion-flash-F)
		nmap <silent> t <Plug>(remap-semicolon-and-comma)<Plug>(easymotion-flash-t)
		nmap <silent> T <Plug>(remap-semicolon-and-comma)<Plug>(easymotion-flash-T)
		vmap <silent> f <Plug>(remap-semicolon-and-comma)<Plug>(easymotion-flash-f)
		vmap <silent> F <Plug>(remap-semicolon-and-comma)<Plug>(easymotion-flash-F)
		vmap <silent> t <Plug>(remap-semicolon-and-comma)<Plug>(easymotion-flash-t)
		vmap <silent> T <Plug>(remap-semicolon-and-comma)<Plug>(easymotion-flash-T)
	endif

	"map ; <Plug>(easymotion-flash-next-in-dir)
	"map , <Plug>(easymotion-flash-prev-in-dir)
	"map n <Plug>(easymotion-n)
	"map N <Plug>(easymotion-N)
	"map n <Plug>(easymotion-flash-n)
	"map N <Plug>(easymotion-flash-N)
	" I am happy using Vim's default / but EasyMotion has one too.  (It only searches the screen though, and there is no equivalent ?)
	"map  / <Plug>(easymotion-flash-sn)
	"omap / <Plug>(easymotion-flash-tn)
	function s:InitEasyMotionHighlights()
		" When I must type two chars, I want it to be clear which is the first one I must type!
		" This is useful when using (easymotion-jumptoanywhere)
		highlight EasyMotionTarget        cterm=bold ctermbg=0 ctermfg=red    gui=bold guifg=#ff3333
		highlight EasyMotionTarget2First  cterm=bold ctermbg=0 ctermfg=yellow gui=bold guifg=#ffff00
		"highlight EasyMotionTarget2Second cterm=bold ctermbg=0 ctermfg=darkyellow gui=bold guifg=#bbbb00
		highlight EasyMotionTarget2Second cterm=bold ctermbg=0 ctermfg=blue   gui=bold guifg=#6666ff
		" The default green move highlight made it hard to see where my cursor was.  Something darker contrasts better.
		"hi link EasyMotionMoveHL EasyMotionTarget
		"highlight EasyMotionMoveHL ctermbg=darkblue guibg=darkblue
		"hi EasyMotionMoveHL ctermfg=green guifg=#00ff00
		"hi EasyMotionMoveHL ctermfg=106 guifg=#7fbf00
		hi EasyMotionMoveHL ctermfg=yellow guifg=#ffff00
	endfunction
	call s:InitEasyMotionHighlights()
	" Default: All standard QWERTY keys, prefer 'f' 'j' and ';' for grouping.
	"let g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfj;'
	" Home row keys only, again with the keys which are easiest to type last.
	let g:EasyMotion_keys = 'asdghklfj;'
	" Other keys I feel might be easy to type: R, T, U, Q, M and C
	" Space could also be an option, but it should probably be rendered as `_` so we can see it!
	"let g:EasyMotion_do_shade = 1             " Without this I confuse yellow/green syntax with yellow/green targets
	"let g:EasyMotion_do_shade_for_flash = 0   " But it's too slow and disruptive when we are just flashing
	"let g:EasyMotion_move_highlight = 0
	"let g:EasyMotion_landing_highlight = g:EasyMotion_move_highlight
	let g:EasyMotion_flash_time_ms = 500

	"call add(vamAddons,"github:Raimondi/delimitMate")     " Mirrors (s and 's for you, but doesn't mind if you type over them.  I still had occasional issues with this (e.g. adding "s inside "s, deleting back over an end ").  But the worst issue was that things became unrepeatable with '.'.  (ysiw' repeats but inserting code with 's does not.)
	let g:delimitMate_matchpairs = "(:),[:]"
	" I took these out because they can be annoying when manually introducing new curlies at the top and bottom of a block.  (It gives me '{}' at the top and just '}' at the bottom.)
	" {:},
	" ,<:>         Might be OK for HTML, but sucks when doing math.
	" Also BEWARE, delimitMate appears to interrupt recording of '.' actions (at least with RepeatLast enabled), so repeating things where it acted will only repeat what occurred *after* it acted.  I guess it should make use of vim-repeat, but doesn't.
	let g:delimitMate_expand_cr = 1
	let g:delimitMate_expand_space = 1
	" Issues: When adding a comment in Vim, DLM thinks I am adding a String.  When adding a " at the start of a line, DLM should not pair it.
	" Issues: Weird things happen when building up a String like "text "+var+" text".  I sometimes end up with  " " at the end of the line!

	"call add(vamAddons,"github:felixr/vim-multiedit")      " Edit multiple selections live (mark words with ,w then edit all with ,i or ,a)
	"call add(vamAddons,"github:hlissner/vim-multiedit")    " Edit multiple selections v2 (mark words with \mm then edit all with \M or \C) - but this was not doing live updates for me
	"call add(vamAddons,"github:vim-scripts/vim-multiedit") " Older clone of hlissner's
	"call add(vamAddons,"github:osyo-manga/vim-over")       " Specifically just for previewing search/replace - works well.

	""call add(vamAddons,"github:terryma/vim-multiple-cursors")    " Looks promising
	""call add(vamAddons,"github:kris89/vim-multiple-cursors")     " More recently maintained
	""call add(vamAddons,"github:jrhorn424/vim-multiple-cursors")  " Even more recently maintained!
	""call add(vamAddons,"github:joeytwiddle/vim-multiple-cursors") " My version attempts to avoid losing keystrokes
	""call add(vamAddons,"github:eapache/multi-char-maps")         " Doing some nice work on it
	"call add(vamAddons,"github:kristijanhusak/vim-multiple-cursors") " Doing some nice work on it
	"let g:multi_cursor_start_key='<F2>'
	"nnoremap \\r :exec 'MultipleCursorsFind \<'.expand("<cword>").'\>'v
	" Setting this means the first <Esc> will not exit multiple cursor mode
	"let g:multi_cursor_exit_from_insert_mode = 0
	" Note: multiple-cursors appears to conflict with many of my plugins.  But it appears to work if I do the following:
	"   1. move my .vim/ folder away (May not be needed.)
	"   2. do not load all of the plugins below (airline.vim grep.vim taglist.vim zoom.vim and sexyscroller.vim)
	"   3. also remove everything in this file above the line let vamAddons = []
	" It would be nice to further track down which of those plugins are actually conflicting.

	"call add(vamAddons,"github:mhinz/vim-startify")       " Session manager and MRU, on start page or on demand

	"call add(vamAddons, "github:koron/nyancat-vim")       " You might need this, but you probably won't

	let linter = v:version < 800 ? 'syntastic' : 'ale'
	"let linter = 'coala'

	if linter == 'syntastic'
		" Syntastic supports a lot of languages, but it was never refactored to run linters asynchronously.
		call add(vamAddons, "github:scrooloose/syntastic")    " Checks syntax as you are working.  Needs syntax checker for relevant language to be installed separately: https://github.com/scrooloose/syntastic/wiki/Syntax-Checkers
		set statusline+=%#warningmsg#
		set statusline+=%{SyntasticStatuslineFlag()}
		set statusline+=%*
		let g:syntastic_always_populate_loc_list = 1
		"let g:syntastic_auto_loc_list = 1
		"let g:syntastic_check_on_open = 1
		"let g:syntastic_check_on_wq = 0
		let g:syntastic_javascript_checkers = ['standard']
		"let g:syntastic_check_on_open = 1
		let g:syntastic_warning_symbol = '--'
		"let g:syntastic_auto_jump = 2
		"let g:syntastic_auto_loc_list = 1
		"let g:syntastic_ignore_files = ['\m^/usr/include/', '\m\c\.h$']
	endif
	if linter == 'ale'
		call add(vamAddons, "github:w0rp/ale")
		let g:ale_echo_msg_format = '[%linter%] %severity%: %s (%code%)'
		"let g:ale_set_quickfix = 1
		let g:ale_set_loclist = 1
		let g:ale_open_list = 0
		"let g:ale_lint_on_text_changed = 'never'
		" The default delay of 200 causes the error list to pop up when I am typing slowly.  It should wait for a significant pause.  (Or I could disable auto list popup.)
		let g:ale_lint_delay = 800
		" If prettier or standard are installed, don't use them by default, just use the nearest .eslintrc
		let g:ale_linters = {
		\   'javascript': ['standard', 'eslint'],
		\}
		"let g:ale_linters = {
		"\   'javascript': ['eslint', 'flow', 'jscs', 'jshint', 'standard', 'xo'],
		"\}
		" Use :ALEInfo to see which linters are available and which are being used
	endif
	if linter == 'coala'
		call add(vamAddons, "github:coala/coala-vim")
	endif

	" Airline https://github.com/bling/vim-airline
	"call add(vamAddons, "github:bling/vim-airline")        " Cool statusline
	let g:airline_section_b = "[%{airline#util#wrap(airline#extensions#branch#get_head(),0)}]"
	"let g:airline_section_x = "(%{airline#util#wrap(airline#parts#filetype(),0)})"
	let g:airline_section_z = "%{GetSearchStatus()}%3P (%02c%{g:airline_symbols.linenr}%#__accent_bold#%l%#__restore__#) \#%02B"
	"let g:airline_left_sep  = '⡿⠋'
	"let g:airline_right_sep = '⣠⣾'
	"let g:airline_left_sep  = '⣷⣄'
	"let g:airline_right_sep = '⠙⢿'
	"let g:airline_left_sep  = '║'
	"let g:airline_left_sep  = '𝄛'
	"let g:airline_left_sep  = '◆'
	"let g:airline_left_sep  = '╳'
	"let g:airline_left_sep  = '▶'
	"let g:airline_right_sep = '◀'
	"let g:airline_left_sep  = '╱'
	"let g:airline_right_sep = '╲'
	"let g:airline_left_sep  = '◤'
	"let g:airline_right_sep = '◥'
	" None of the above worked on Ubuntu 12.04's Lucida Console under Fluxbox.
	"let g:airline_left_sep  = '>'
	"let g:airline_right_sep = '<'
	"let g:airline_left_sep  = '|'
	"let g:airline_right_sep = '|'
	"let g:airline_left_sep  = '|-'
	"let g:airline_right_sep = '-|'
	"let g:airline_left_sep  = '\'
	"let g:airline_right_sep = '/'
	"let g:airline_left_sep  = '⑉'
	"let g:airline_right_sep = '⑊'
	"let g:airline_left_sep  = '|'
	"let g:airline_right_sep = '|'
	"let g:airline_left_sep = '‖'
	"let g:airline_right_sep = '‖'
	" Powerline when using NerdFont
	let g:airline_left_sep  = ""
	let g:airline_right_sep = ""
	"let g:airline_left_sep  = ""
	"let g:airline_right_sep = ""
	"let g:airline_powerline_fonts = 1
	"set noshowmode
	let g:airline_symbols = get(g:, 'airline_symbols', {})
	let g:airline_symbols.branch = ''
	"let g:airline#extensions#tabline#enabled = 1    # alernative to MBE - uses vim's built-in 'tabline'
	let s:joeys_airline_theme_file = $HOME . "/.vim/autoload/airline/themes/joeys.vim"
	if filereadable(s:joeys_airline_theme_file)
		let g:airline_theme="joeys"
	endif
	" TODO: Airline whitespace option slows down Vim on large files, between every keystroke!  We should ensure it is never automatically enabled when we open a large file.
	"silent! call airline#extensions#whitespace#disable()
	" For now we just disable it entirely
	let g:airline#extensions#whitespace#enabled = 0

	" Alternative to Airline:
	"call add(vamAddons, "github:itchyny/lightline.vim")
	"let g:lightline = { 'colorscheme': 'Tomorrow_Night_Blue' }
	" To switch colorscheme:
	" :let g:lightline.colorscheme = 'Tomorrow' | call lightline#init() | call lightline#update()

	call add(vamAddons, "github:Shougo/vimproc.vim")       " Used by unite for async; requires `make` after install!
	call add(vamAddons, "github:Shougo/unite.vim")         " Buffer and file explorer, all in one plugin
	let g:unite_source_history_yank_enable = 1
	nmap <silent> <Leader>u* :Unite source<CR>A*
	nmap <silent> <Leader>uu :Unite<CR>A*
	nmap <silent> <Leader>ub :Unite buffer<CR>A
	nmap <silent> <Leader>uf :Unite file_point file file/new<CR>A
	nmap <silent> <Leader>ua :Unite file_point file_rec file/new<CR>A
	"nmap <silent> <Leader>ua :Unite find<CR>A   " Requires vimproc
	nmap <silent> <Leader>ug :Unite file_rec/git<CR>A
	nmap <silent> <Leader>ud :Unite directory directory/new<CR>A
	nmap <silent> <Leader>uj :<C-u>Unite -buffer-name=jumps change jump<CR>A
	nmap <silent> <Leader>uc :Unite command<CR>A
	nmap <silent> <Leader>ul :Unite line<CR>A
	nmap <silent> <Leader>up :Unite process<CR>A
	nmap <silent> <Leader>ur :Unite runtimepath<CR>A
	nmap <silent> <Leader>us :Unite runtimepath<CR>A
	nmap <silent> <Leader>uh :Unite history/yank register<CR>A
	nmap <silent> <Leader>uy :Unite history/yank<CR>A
	nmap <silent> <Leader>ue :Unite launcher<CR>A
	nmap <silent> <Leader>uH :Unite output:highlight<CR>A
	nmap <silent> <Leader>uS :Unite output:syntax<CR>A
	nmap <silent> <Leader>uM :Unite output:mapping<CR>A
	nmap <silent> <Leader>uA :Unite output:autocmd<CR>A
	"nmap <silent> <Leader>uF :Unite output:function<CR>A   " more colorful than function but does not offer 'call' action
	nmap <silent> <Leader>uF :Unite function<CR>A
	" We cannot do these until after it has loaded!
	"call unite#filters#matcher_default#use(['matcher_fuzzy'])
	"call unite#custom#profile('default', 'context', { 'winheight': 50, })
	" These are the settings the guy who had the bug used (and the two above):
	"let g:unite_enable_ignore_case         = 1
	"let g:unite_enable_smart_case          = 1
	"let g:unite_enable_start_insert        = 1
	"let g:unite_source_history_yank_enable = 1
	"let g:unite_winheight                  = 10
	"let g:unite_split_rule                 = 'botright'
	"let g:unite_cursor_line_highlight      = 'Statusline'
	"let g:unite_prompt                     = '➤ '
	"let g:unite_data_directory             = $HOME.'/tmp/unite'
	"au BufEnter unite imap <buffer> <Tab>   <Plug>(unite_loop_cursor_down)
	"au BufEnter unite imap <buffer> <S-Tab> <Plug>(unite_loop_cursor_up)
	" Paste from the yank history (may need unite_source_history_yank_enable)
	nmap <silent> <leader>P :Unite -start-insert history/yank<CR>
	" Trigger the git menu
	nmap <silent> <leader>g :Unite -silent -start-insert menu:git<CR>
	" Open all menus with useful stuff (WIP?)
	nmap <silent> <leader>j :Unite -silent -start-insert menu:all menu:git<CR>

	" Shougo has stopped work on Unite and moved to Denite instead, for neovim and Vim8
	"call add(vamAddons, "github:Shougo/denite.nvim")

	"call add(vamAddons,"github:dahu/vimple")             " ...
	"call add(vamAddons,"github:dahu/VimFindsMe")         " Edit args, edit options containing lists, cd into relevant folders


	" >>> Plugins related to colors and colorschemes {{{

	call add(vamAddons,"github:ap/vim-css-color")        " Colour the backgrounds of colour codes in CSS and Vim files
	" You can also check out this alternative, which may or may not be faster: https://github.com/chrisbra/Colorizer

	" Some colorschemes:
	"call add(vamAddons,"github:altercation/vim-colors-solarized") " Popular
	"call add(vamAddons,"github:lifepillar/vim-solarized8") " Simplified, with fewer bugs
	call add(vamAddons,"github:davidkariuki/sexy-railscasts-256-theme") " Nice colors
	" CodePen uses a theme a bit like sexy-railscasts.  We can use some of CodePen's extra colours by adding:
	"hi jsFuncCall guifg=#aa88aa
	"hi link jsFuncArgs Constant
	"call add(vamAddons,"github:shawncplus/skittles_berry") " Cute and colorful
	" Molokai (Monokai) was originally a theme for Text Mate, and is the default theme for Sublime Text
	call add(vamAddons,"github:sickill/vim-monokai")     " Forces t_Co=256, appears more faithful to Sublime
	"call add(vamAddons,"github:tomasr/molokai")          " Supports 256 colors when available, less faithful to Sublime
	"call add(vamAddons,"github:crusoexia/vim-monokai")   " An alternative
	"let g:molokai_original = 0                           " Makes some changes, but does not help much.
	"call add(vamAddons,"github:29decibel/codeschool-vim-theme") " Clear, clean pastels
	"call add(vamAddons,"github:Lokaltog/vim-distinguished") " Understated, a bit more earthy/dirty compared to codeschool
	"call add(vamAddons,"github:Slava/vim-colors-tomorrow") " Solarized options but with tomorrow theme
	"call add(vamAddons,"github:romainl/Apprentice")      "  A colorscheme as subtle, gentle and pleasant as its creator isn't.  Like Solarized and codeschool, I find it a bit too subtle.
	"call add(vamAddons,"git:https://gitlab.com/davidogg/vim-dichromatic.git") " A dark colorscheme for color blind vimmers (white background = broken?)
	"call add(vamAddons,"github:jacoborus/tender.vim")    " Nice and gentle, could be good for presentations
	"call add(vamAddons,"github:raphamorim/lucario")      " Note sure about the rusty red.  Available for lots of apps!  https://github.com/raphamorim/lucario
	"call add(vamAddons,"github:AlessandroYorba/Despacio") " Very brown, coffee focus
	call add(vamAddons,"github:chriskempson/vim-tomorrow-theme") " For Tomorrow-Night or Tomorrow-Night-Eighties (brighter).  This is no longer updated; it has moved into base16 (see below)
	call add(vamAddons,"github:YorickPeterse/happy_hacking.vim") " Rich browny-red, yellow and greens
	call add(vamAddons,"github:tyrannicaltoucan/vim-quantum") " Nice range of colours, based on the Material Design palette.  reactjs docs uses something like this.
	call add(vamAddons,"github:kaicataldo/material.vim") " Fork of quantum with brighter colours.  Similar to Atom's One Dark, but not quite the same
	"call add(vamAddons,"github:Heorhiy/VisualStudioDark.vim") " Similar to VSCode's "Dark (Visual Studio), with some minor differences
	call add(vamAddons,"github:tomasiser/vim-code-dark") " codedark: Similar to VSCode's "Dark+ (default)"
	"call add(vamAddons,"github:")

	"call add(vamAddons,"github:flazz/vim-colorschemes")  " A large collection, includes codeschool
	"call add(vamAddons,"github:rodnaph/vim-color-schemes") " A collection, includes leo
	                                                        " leo is based on primary colors; it is a bit strong.  version 1 .0 here: http://www.vim.org/scripts/script.php?script_id=2156
	" Multi-target (editors) color scheme generator: https://github.com/daylerees/colour-schemes
	" Base16 is an architecture for building themes.  I think it might also support multiple editors.
	"call add(vamAddons,"github:chriskempson/base16-vim")

	" Rules I want to load after every colorscheme
	augroup Joeys_After_Colorscheme
		autocmd!
		autocmd ColorScheme * call g:Joeys_After_Colorscheme()
	augroup END
	"
	function! g:Joeys_After_Colorscheme()
		highlight SpecialKey ctermfg=239 guifg=#4c4c4c
		highlight Comment ctermfg=242 gui=none guifg=#777777
		" This restores my preferred statusline and MiniBufExplorer colors
		so ~/.vim/mac_colors.vim
		" Various plugins lose their highlighting.  Let's restore them here:
		if exists(':AirlineRefresh')
			AirlineRefresh
		endif
		if exists('*lightline#enable')
			call lightline#enable()
		endif
		call s:InitEasyMotionHighlights()
	endfunction
	"
	" TODO: Turn this into a plugin that automatically finds and sources post-colorscheme settings?
	"     globpath(&runtimepath, "after/colors/all.vim", 0, 1)
	"     globpath(&runtimepath, "after/colors/%colorscheme%.vim", 0, 1)
	" Oh but wait: that's not what I need.  I want my own custom rules that run after a specific *syntax* plugin is chosen.
	" E.g. I need different things for isRuslan or pangloss.  Or ... is it a combination that I need?

	" Vim is not very good at switching colorscheme, there are lots of problems.
	" This plugin can help with some of them:
	"call add(vamAddons,"github:xolox/vim-colorscheme-switcher")
	" This addon provides an important missing command for that plugin: :SwitchToColorScheme
	"call add(vamAddons,"github:Taverius/vim-colorscheme-manager")

	" Automatically reload plugins while you are editing them
	"call add(vamAddons,"github:xolox/vim-misc")
	"call add(vamAddons,"github:xolox/vim-reload")

	" Autocompletion plugins
	"call add(vamAddons,'github:neoclide/coc.nvim')       " Intellisense engine for vim8 & neovim (seems to be very popular)
	""set pyxversion=3
	"call add(vamAddons,'github:Shougo/deoplete.nvim')
	"if !has('nvim')
	"	call add(vamAddons,'github:roxma/nvim-yarp')
	"	" See: https://github.com/roxma/vim-hug-neovim-rpc#requirements
	"	call add(vamAddons,'github:roxma/vim-hug-neovim-rpc')
	"endif
	"let g:deoplete#enable_at_startup = 1

	" }}}


	"call add(vamAddons,"github:coderifous/textobj-word-column.vim") " vic to select whole column

	"call add(vamAddons,"github:kana/vim-textobj-user")   " Dependency for...
	"call add(vamAddons,"github:kana/vim-textobj-function") " vif and vaf to select in and around function

	"call add(vamAddons,"github:henrik/vim-indexed-search") " Show search progress

	"call add(vamAddons,"github:itchyny/vim-qfedit")      " Allows you to edit the quickfix list.

	" :AnsiEsc interprets any ANSI escape sequences in the current file, conceals them, and uses them for highlighting
	" Beware that vimpager exposes its own version of AnsiEsc !
	" There are also some forks:
	" - https://github.com/kaylynb/AnsiEsc
	" - https://github.com/my-vim-plugin-mirrors/AnsiEscPlugin
	" Although last I checked, neither of those forks could handle a colour code, followed later by a bold code.  (We always end up with bold white, instead of bold colour.)
	call add(vamAddons,"github:powerman/vim-plugin-AnsiEsc")
	" Includes executables vimpager and vimcat (which pretty-print files using Vim's syntax highlighting!)
	call add(vamAddons,"github:rkitover/vimpager")

	call add(vamAddons, 'github:sheerun/vim-polyglot')   " Syntax and ftplugins for various languages

	"call add(vamAddons, 'github:dag/vim-fish')           " Friendly interactive shell support
	" There is also a different syntax-only plugin: https://github.com/vim-scripts/fish-syntax

	"call add(vamAddons, 'github:tpope/vim-scriptease')   " Assist with vim scripting

	" Minimap made from Braille dots
	call add(vamAddons,"github:severin-lemaignan/vim-minimap")
	" Minimap in a new Vim instance with tiny font size
	"call add(vamAddons,"github:koron/minimap-vim")

	" Comment toggle on gcc, works in embedded languages
	call add(vamAddons,"github:tomtom/tcomment_vim")
	" Another comment toggle on gcc, set commentstring for unsupported languages
	" Toggle comments with gc[motion] or gcc for the current line  Supports multiple languages via commentstring.
	"call add(vamAddons,"github:tpope/vim-commentary")

	" Allow us to modify syntax highlighting for specified lines in a file
	" Use [range]:SyntaxIgnore and [range]:SyntaxInclude [filetype]
	" Can also be configured to automatically detect start-end of regions and set syntax for them
	" Ingo is a required dependency
	call add(vamAddons,"ingo-library")
	call add(vamAddons,"SyntaxRange")

	" Use :NarrowRegion or <Leader>nr to edit the selected lines in a scratch buffer
	" Can be useful to restrict a file-wide operation to only those lines.
	"call add(vamAddons,"NrrwRgn")

	call add(vamAddons,"github:tweekmonster/django-plus.vim")

	" Diff sometimes presents a mess instead of detecting that some lines has moved in the file.  Run `:EnhancedDiff histogram` or `:PatienceDiff` and it might fix it!
	if v:version >= 704
		call add(vamAddons,"github:chrisbra/vim-diff-enhanced")
	endif

	" Vim highlights all the text between the first and last different characters on a changed line.
	" But this plugin will find and display the exact differences, character by character.
	" It can slow down Vim somewhat, especially when opening git mergetool, and then maximizing the window!
	" https://github.com/rickhowe/diffchar.vim
	" Its default key mappings conflict with Unimpaired's [b and ]b, so we set our own mappings instead:
	noremap <silent> <Leader><Leader>dc<F7> <Plug>ToggleDiffCharAllLines
	noremap <silent> <Leader><Leader>dc<F8> <Plug>ToggleDiffCharCurrentLine
	nnoremap <silent> <Leader><Leader>dc[b <Plug>JumpDiffCharPrevStart
	nnoremap <silent> <Leader><Leader>dc]b <Plug>JumpDiffCharNextStart
	nnoremap <silent> <Leader><Leader>dc[e <Plug>JumpDiffCharPrevEnd
	nnoremap <silent> <Leader><Leader>dc]e <Plug>JumpDiffCharNextEnd
	"call add(vamAddons,"github:rickhowe/diffchar.vim")

	"call add(vamAddons,"github:jpalardy/vim-slime")      " Paste commands from buffer to a REPL open in another screen window

	"call add(vamAddons,"github:Yggdroot/indentLine")     " Displays indent symbols even in files with spaces

	" >>> For NeoVim only
	
	" Recommended as it can speed up other plugins: github:neomake/neomake

	call add(vamAddons,"github:joeytwiddle/quickr-preview.vim")
	let g:quickr_preview_keymaps = 0
	autocmd BufReadPost quickfix nmap <buffer> p <plug>(quickr_preview)
	let g:quickr_preview_line_hl = "Search"
	"let g:quickr_preview_position = 'below'
	let g:quickr_preview_position = 'right'
	" Alternatively, try one of these keybinds instead: https://github.com/svermeulen/vim-quickfix-custom

	" Recommended by https://medium.com/@huntie/10-essential-vim-plugins-for-2018-39957190b7a9
	call add(vamAddons,"github:tpope/vim-eunuch")
	call add(vamAddons,"github:editorconfig/editorconfig-vim")

	" FZF requires some extra setup on your local environment: https://github.com/junegunn/fzf.vim#installation
	if has('mac') || has('macunix')
		" These used to work, but don't seem to work now
		"call add(vamAddons, {'activate_this_rtp': '/usr/local/opt/fzf'})
		"call add(vamAddons, {'activate_this_rtp': '/opt/homebrew/bin/fzf'})
		"
		" This is the recommended way (using VimPlug)
		"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
		"
		" Our way
		call add(vamAddons, "github:junegunn/fzf")
		" TODO: We may need to call fzf#install() through VAM or manually
		"       (Although it doesn't seem to be needed if you already have fzf installed locally)
	endif
	call add(vamAddons,"github:junegunn/fzf.vim")
	" CTRL-A CTRL-Q to select all and build quickfix list
	" From: https://github.com/junegunn/fzf.vim/issues/185#issuecomment-322120216
	function! s:build_quickfix_list(lines)
		call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
		copen
		cc
	endfunction
	let g:fzf_action = {
		\ 'ctrl-q': function('s:build_quickfix_list'),
		\ 'ctrl-t': 'tab split',
		\ 'ctrl-x': 'split',
		\ 'ctrl-v': 'vsplit' }
	let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

	" }}}

	" >>> My Plugins from the Cloud (modified versions of other plugins) {{{
	call add(vamAddons,"github:joeytwiddle/grep.vim")    " With support for csearch and SetQuickfixTitle.
	call add(vamAddons,"github:joeytwiddle/taglist.vim") " Joey's taglist.vim with vague indentation mode and other madness
	call add(vamAddons,"github:joeytwiddle/zoom.vim")    " Change font size easily

	call add(vamAddons, 'github:joeytwiddle/vtreeexplorer') " File (tree) explorer

	"call add(vamAddons,"github:joeytwiddle/vim-seek")    " Two char search (I added multi-line support).  But I never use it; prefer EasyMotion.
	let g:seek_multi_line = 1
	let g:SeekKey = 'l'
	let g:SeekBackKey = 'L'
	let g:seek_subst_disable = 1
	" }}}

	" >>> My Plugins from the Cloud (all by me!) {{{
	call add(vamAddons,"github:joeytwiddle/vim-diff-traffic-lights-colors")
	call add(vamAddons,"github:joeytwiddle/sexy_scroller.vim")   " Smooth animation when scrolling
	"let g:SexyScroller_MaxTime = 200
	call add(vamAddons,"github:joeytwiddle/git_shade.vim") " Colors lines in different intensities according to their age in git's history
	call add(vamAddons,"github:joeytwiddle/RepeatLast.vim") " Easily repeat groups of previous actions
	" }}}

	" Devicons introduce some filetype icons to NERDTree, Airline, etc.
	" Requires https://github.com/ryanoasis/nerd-fonts
	" Should be loaded last
	call add(vamAddons,"github:ryanoasis/vim-devicons")

	if filereadable($HOME."/.vimrc.local")
		source $HOME/.vimrc.local
	endif

	" This test would work if VAM was already on the runtimepath, but it isn't.
	"if exists("*vam#ActivateAddons") || 1
	" I keep VAM in this folder.  It needs to be loaded into the runtimepath!
	let vam_found_dir = $HOME . "/.vim-addon-manager/vim-addon-manager/"
	if isdirectory(vam_found_dir)
		"set runtimepath+=$HOME/.vim-addon-manager/vim-addon-manager/
		let &runtimepath = &runtimepath . "," . vam_found_dir

		call vam#ActivateAddons(vamAddons, {'auto_install' : 1})

		" Or activate addons while showing progress
		" The conclusion was that this completed very quickly!
		" Probably the actual loading of scripts happens after this file has finished, and that is why we observe no delay here.
		" But after testing, that does not appear to be the case.  It appears any new git clones are performed before this file completes.
		"let len = len(vamAddons)
		"let i = 0
		"while i < len
			"let plugin = vamAddons[i]
			"echon "\rSourcing plugin ".(i+1)."/".len.": ".plugin."                    "
			"call vam#ActivateAddons([plugin], {'auto_install' : 1})
			"let i += 1
		"endwhile

	endif

	" Apparently many of the popular plugin managers are slow, so Plug or Dein are recommended: https://stackoverflow.com/a/54121000/99777

	" Detect large files or files with long lines, and disable this module with :call css_color#disable()
	augroup DisableSomePluginsForLargeFiles
		autocmd!
		autocmd BufReadPost * if line2byte(line("$") + 1) > 1024 * 1024 && exists(':ALEDisableBuffer') | echo "Disabling ALE for this large buffer" | ALEDisableBuffer | endif
		" Trying to disable it in during loading didn't work, because css_color continues to init after this runs!
		"autocmd BufReadPost * if line2byte(line("$") + 1) > 1024 * 1024 && exists('*css_color#disable') | echo "Disabling css_color for this large buffer" | let b:css_color_off = 1 | endif
		autocmd CursorHold *
		  \   if exists('*css_color#disable') && get(b:, 'done_css_color_check', 0) == 0
		  \ |   let b:done_css_color_check = 1
		  \ |   if line2byte(line("$") + 1) > 1024 * 1024
		  \ |     silent! call css_color#disable()
		  \ |     echo "Disabled css_color for this large buffer"
		  \ |   endif
		  \ | endif
	augroup END

	command! CSSColorToggle call css_color#toggle() | echo "CSS Color is now " . (b:css_color_off ? 'disabled' : 'enabled')

	command! ProfileVim profile start /tmp/vimprofile.out | profile file * | profile func * | echo 'Test, optionally do `:profile pause`, then quit vim, then read the bottom of /tmp/vimprofile.out'

" }}}

endif


" vim: foldmethod=marker foldenable colorcolumn=57 textwidth=0
