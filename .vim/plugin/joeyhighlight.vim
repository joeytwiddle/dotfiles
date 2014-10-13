:command! Joeyhighlight call Joeyhighlight()
if has("menu")
	amenu &Joey's\ Tools.&Joey's\ highlighting :call Joeyhighlight()<CR>
endif

augroup Joeyhighlight
	au!
	" My rules used to get overwritten by default vim scripts
	" Not any more bitches!
	autocmd BufReadPost * :Joeyhighlight
augroup END

function! Joeyhighlight()

	" :colors pablo
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-150-*-*-c-*-iso646.1991-irv
	" :set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1

	":syntax on

	"" == Dark Backgruond ==
	" You can disable this if you prefer a white background, but the later
	" rules are all too bright!
	if &background == "dark"
		":set background=dark   " moved to .vimrc
		"highlight Normal ctermbg=black ctermfg=grey guibg=Black guifg=#cccccc
		"highlight Normal ctermfg=grey guibg=Black guifg=#cccccc
		"highlight Normal ctermfg=lightgrey guibg=Black guifg=#cccccc
		" highlight Normal ctermfg=lightgrey guibg=#2b3735 guifg=#cccccc
		"highlight Normal ctermfg=LightGray guibg=#000000 guifg=LightGray
		"highlight Normal ctermfg=lightgrey guifg=#dddddd guibg=#000000
		highlight Normal ctermfg=lightgrey guifg=#eeeeee guibg=#000000

		"" Some slightly lighter (off-black) backgrounds:
		"" Can help *reduce* contrast if font is thin and appears faint
		" highlight Normal guibg=#081818	" Almost black background
		" highlight Normal guibg=#102020	" Almost black background
		" highlight Normal guibg=#182828	" Medium/compromise
		" highlight Normal guibg=#203030	" Lighter Faded background
		" highlight Normal guibg=#304040	" Not-so-dark grey
		" highlight Normal guibg=#223330	" Custom greeny/cyan, softer on my broken monitor
		highlight Normal guibg=#102626	" Match xterm, porridge
	endif

	highlight Title ctermbg=black ctermfg=green guibg=#000060 guifg=#00ff00

	" highlight WarningMsg ctermbg=black ctermfg=red cterm=bold
	highlight WarningMsg term=reverse,bold cterm=reverse,bold gui=reverse,bold ctermbg=red ctermfg=yellow guibg=red guifg=yellow
	" highlight ErrorMsg ctermbg=Red ctermfg=Yellow gui=bold guibg=Red guifg=Yellow
	highlight ErrorMsg term=reverse,bold cterm=bold gui=reverse,bold ctermfg=yellow ctermbg=darkred guibg=yellow guifg=#cc0000
	" Full red is too bright, dark red is too dark

	"highlight Search term=reverse,bold ctermbg=White guibg=White ctermfg=Black guifg=Black
	"highlight Search ctermbg=Blue ctermfg=White term=bold guibg=Blue guifg=White
	"highlight Search ctermbg=Blue ctermfg=Yellow term=bold guibg=Blue guifg=Yellow
	"highlight Search ctermbg=Blue ctermfg=Yellow term=bold guibg=#0000aa guifg=#ffee99 gui=bold
	"highlight Search ctermbg=Blue ctermfg=Yellow term=bold guibg=#005500 guifg=#ffbb66 gui=bold
	"highlight Search ctermbg=blue ctermfg=white term=bold guibg=#005500 guifg=#66ff88 gui=bold
	"highlight Search ctermbg=blue ctermfg=white term=bold guibg=#005500 guifg=#bbffbb gui=bold
	"highlight Search ctermbg=blue ctermfg=green term=bold guibg=#005544 guifg=#aaffaa gui=bold
	" In 256-color xterm, darkblue background looks the same as in 8-bit.  Just blue looks a bit lighter.
	" Now using reverse in GUI so that selected line shows up even if dim_inactive_windows.vim sets both colors of unfocused quickfix window.
	highlight Search term=bold cterm=bold ctermbg=darkblue ctermfg=green guifg=#005544 guibg=#aaffaa gui=bold,reverse
	" But using reverse in cterm sucks if we also want bold text, because the bold makes the background blue lighter.
	" An alternative: white on green
	"highlight Search term=reverse cterm=bold,reverse ctermfg=darkgreen ctermbg=white guifg=#005544 guibg=#aaffaa gui=bold,reverse
	"highlight Search term=reverse ctermfg=darkblue ctermbg=green cterm=reverse guifg=#005544 guibg=#aaffaa gui=bold,reverse
	" It also seems that reverse cancels bold in the GUI.
	" highlight Visual ctermfg=DarkMagenta ctermbg=White guifg=DarkMagenta guibg=White
	" highlight Visual ctermfg=DarkMagenta ctermbg=White gui=none guibg=#553355
	"" This actually gives us a dirty grey instead of white (in xterm):
	" highlight Visual ctermfg=DarkMagenta ctermbg=White gui=none guibg=#660066 guifg=white
	"" This is what I prefer, but I may have been using the above to ensure b/w terminals get reverse?
	highlight Visual ctermbg=Magenta ctermfg=White cterm=bold gui=none guibg=#660066 guifg=white
	"highlight Comment ctermfg=Magenta guifg=#80a080 " green-grey
	"highlight Comment ctermfg=DarkMagenta guifg=LightMagenta
	"highlight Comment ctermfg=DarkMagenta guifg=#d080d0
	"highlight Comment ctermfg=Magenta guifg=#d080d0
	"highlight Comment ctermfg=DarkCyan guifg=DarkCyan
	"highlight Comment term=none cterm=none ctermfg=DarkMagenta guifg=LightMagenta
	"" Previous was getting too dark for me, so ...
	"highlight Comment term=none cterm=bold ctermfg=Magenta guifg=LightMagenta
	" highlight Comment term=none cterm=none ctermfg=blue guifg=#7070ee
	" highlight Comment term=none cterm=none ctermfg=blue guifg=#88cccc
	" highlight Comment term=none cterm=none ctermfg=cyan guifg=#88bbbb   " for javascript, like cyan for terminal, but darker
	" highlight Comment cterm=none ctermfg=DarkCyan gui=none guifg=LightMagenta
	" highlight Comment cterm=bold ctermfg=blue gui=none guifg=#7070ee   " dark blue to match my xterm
	" highlight Comment cterm=bold ctermfg=magenta gui=none guifg=LightMagenta
	" highlight Comment cterm=bold ctermfg=darkcyan gui=none guifg=#80a0ff   " nice mid-light blue
	" highlight Comment cterm=bold ctermfg=darkgrey gui=bold guifg=#999999   " bold grey, nice with Lucida in xterm
	highlight Comment cterm=bold ctermfg=darkgrey gui=none guifg=#a0a0a0   " bold grey, nice with Lucida in xterm, light non-bold in GUI
	"" Unfortunately the following set white in 8-color xterm mode, so they require a check before using.
	" highlight Comment ctermfg=8 cterm=bold gui=none guifg=#a0a0a0   " bold grey, nice with Lucida in xterm, light non-bold in GUI.  =8 is a little lighter than darkgrey in 256-color-term mode
	" highlight Comment ctermfg=244 cterm=bold gui=none guifg=#a0a0a0   " bold grey, nice with Lucida in xterm, light non-bold in GUI.  =244 or 245 is an exact match to low-color xterm :P
	"if &t_Co >= 256
		"hi Comment ctermfg=60   " pretty dark blue
	"endif
	" highlight friendlyComment cterm=none ctermfg=cyan gui=none guifg=#80a0ff   " boring mid blue (just greyish)
	highlight friendlyComment ctermfg=darkblue cterm=bold gui=none guifg=#7777ff gui=bold
	hi link vimCommentTitle friendlyComment
	highlight def link confComment Comment
	"highlight link jComment Comment
	" highlight jComment ctermfg=DarkYellow guifg=DarkYellow
	" highlight jComment cterm=bold ctermfg=magenta gui=none guifg=lightmagenta
	highlight link jComment Comment
	highlight SpecialChar ctermfg=Red guifg=Red

	" Used for tabs (listchars)
	highlight SpecialKey ctermfg=darkblue cterm=none guifg=#2222aa gui=bold
	if &t_Co >= 250
		" Slightly darker
		highlight SpecialKey ctermfg=19
	endif
	" Used to broken line indentation (showbreak)
	highlight link NonText SpecialKey
	" highlight NonText cterm=none gui=none

	highlight String ctermfg=DarkGreen guifg=#80f080 cterm=NONE
	" vimTodo links to Todo
	highlight Todo term=reverse cterm=reverse ctermbg=black ctermfg=red guibg=red guifg=black
	"highlight jTodo term=reverse cterm=reverse ctermfg=black ctermbg=red guibg=red guifg=black
	" "highlight jNote ctermbg=yellow ctermfg=black guibg=yellow guifg=black
	"highlight jNote term=reverse cterm=reverse ctermbg=black ctermfg=yellow guibg=yellow guifg=black
	hi def link jTodo Todo
	hi def link jNote Todo

	" Code
	highlight Boolean ctermfg=LightBlue guifg=LightBlue
	"highlight Constant ctermfg=DarkYellow guifg=DarkYellow
	highlight Constant ctermfg=Magenta guifg=Magenta   " experiment

	" C
	highlight cType ctermfg=Cyan guifg=Cyan
	" highlight PreProc ctermfg=Red guifg=Red
	" highlight PreProc ctermfg=Blue guifg=Blue
	highlight PreProc ctermfg=cyan guifg=cyan

	" Java
	" It appears to ignore the contains, otherwise I could use start=/^/ =)
	"syntax region javaClassLine start=/class / end=/{/ contains=javaClassDecl
	highlight link javaClassLine javaClassDecl
	"highlight javaClassDecl term=bold ctermbg=DarkGreen ctermfg=White cterm=bold guibg=DarkGreen guifg=White gui=bold
	highlight javaClassDecl ctermbg=black ctermfg=green cterm=bold guibg=DarkGreen guifg=White gui=bold
	highlight javaStorageClass term=NONE ctermfg=Cyan cterm=NONE guifg=Cyan gui=NONE
	highlight javaType term=NONE cterm=NONE guifg=LightBlue gui=bold
	highlight link javaOperator SpecialChar
	" highlight Type ctermfg=Red guifg=Red
	highlight Type ctermfg=green guifg=green
	highlight Number ctermfg=LightBlue guifg=LightBlue
	" To bring first sentence of Java comments in line with Comments.
	highlight Special ctermfg=Magenta guifg=#d080d0

	" Shellscript
	"highlight link shDeref shVariable
	highlight shDeref term=underline cterm=none ctermfg=6 guifg=#30a0a0

	"" For vimdiff / diff mode
	"highlight DiffAdd ctermbg=Green cterm=bold guibg=DarkGreen
	"highlight DiffDelete ctermbg=Blue guibg=DarkBlue
	" Black and Yellow
	"highlight DiffAdd ctermbg=green ctermfg=white cterm=bold guibg=DarkGreen guifg=White gui=none
	"highlight DiffText ctermbg=yellow ctermfg=white cterm=bold guibg=DarkYellow guifg=White gui=bold
	"highlight DiffChange ctermfg=white ctermbg=black cterm=bold guifg=White guibg=#202020 gui=bold
	"highlight DiffDelete ctermbg=black ctermfg=red cterm=none gui=bold guifg=#600000 guibg=black
	"highlight DiffDelete ctermbg=blue ctermfg=blue cterm=none gui=bold guifg=#000060 guibg=#000060
	"highlight DiffDelete ctermbg=black ctermfg=black cterm=none gui=bold guifg=Black guibg=Black
	"highlight DiffAdd ctermbg=red ctermfg=white cterm=bold guibg=DarkRed guifg=White gui=bold
	"highlight DiffText ctermbg=green ctermfg=white cterm=bold guibg=DarkGreen guifg=White gui=bold
	" Strongly mark lines with changes (white bg):
	"highlight DiffChange ctermfg=black ctermbg=white cterm=bold gui=bold guifg=White guibg=Black
	"highlight DiffDelete term=none ctermbg=black ctermfg=blue cterm=none guifg=#000050 guibg=#000050 gui=none
	"highlight DiffChange ctermfg=black ctermbg=white cterm=bold gui=bold guifg=White guibg=Black
	"highlight DiffChange ctermfg=white ctermbg=black cterm=bold gui=bold guifg=White guibg=Black
	" Lines with changes only marked with brighter white fg, which doesn't always show:
	"highlight DiffChange ctermfg=white ctermbg=black cterm=bold gui=bold guifg=White guibg=Black
	"highlight DiffDelete term=none ctermbg=blue ctermfg=blue cterm=none guifg=DarkBlue guibg=DarkBlue gui=none
	"highlight DiffAdd ctermbg=green ctermfg=white cterm=bold guibg=DarkGreen guifg=White gui=bold
	"highlight DiffText ctermbg=red ctermfg=yellow cterm=bold guibg=red guifg=DarkRed gui=bold
	" Moved to traffic_lights_diff.vim

	""" For diff or patch files
	""highlight diffRemoved term=none ctermbg=red ctermfg=white cterm=none guifg=Grey guibg=DarkRed gui=none
	""highlight link diffAdded DiffAdd
	""highlight link diffChanged DiffChange
	"highlight diffRemoved term=bold ctermbg=black ctermfg=red    cterm=bold guibg=DarkRed    guifg=white gui=none
	"highlight diffAdded   term=bold ctermbg=black ctermfg=green  cterm=bold guibg=DarkGreen  guifg=white gui=none
	"highlight diffChanged term=bold ctermbg=black ctermfg=yellow cterm=bold guibg=DarkYellow guifg=white gui=none
	"highlight diffLine ctermbg=magenta ctermfg=white guibg=DarkMagenta guifg=white

	" For jfc diffs
	"syntax keyword difference jDiff @@>>
	highlight jDiff ctermbg=Magenta ctermfg=White

	" For Mason sources
	"highlight jComment ctermfg=Yellow guifg=#ffff00

	"" Might belong better in after/syntax/<lang>.vim

	" Haskell:
	highlight hsStructure ctermfg=DarkYellow
	highlight hsOperator ctermfg=DarkCyan

	" Prolog
	highlight prologClauseHead ctermfg=DarkCyan

	" Log4j:
	"highlight log4jDebug ctermfg=White
	"highlight log4jInfo  ctermfg=DarkGreen
	"highlight log4jWarn  ctermfg=Yellow
	"highlight log4jError ctermfg=Red
	highlight log4jDebug ctermfg=Grey
	highlight log4jInfo  ctermfg=White
	highlight log4jWarn  ctermfg=Yellow
	highlight log4jError ctermfg=Red

	"" For GNU diffs:
	"if &filetype == "diff" "" It appears that at this point we don't know the filetype
		"syntax match diffFileLine "^\(diff\|Index:\) "
		"highlight diffFileLine term=bold cterm=bold ctermbg=blue ctermfg=white guibg=DarkBlue guifg=White
		"highlight clear diffFile
		"highlight diffFile term=bold cterm=bold ctermbg=blue ctermfg=white gui=bold guibg=DarkBlue guifg=White
		"highlight diffFile term=bold cterm=bold ctermbg=white ctermfg=blue gui=bold guibg=White guifg=DarkBlue
		highlight link diffFile diffLine
	"fi

	":so /home/joey/linux/.vim/joeyfolding.vim

	"" For shellscript:
	highlight shOption ctermfg=blue cterm=bold
	highlight shCommandSub ctermfg=red
	highlight shOperator ctermfg=yellow " cterm=bold

	"" Highlight search (doesn't work if called at top of this file!)
	set hlsearch

	"" This was an attempt to colour syntax highlight only the current buffer, but
	"syn on/off appear to work globally!
	"function! SynOn()
	"  syn on
	"endfunction
	"function! SynOff()
	"  syn off
	"endfunction
	"autocmd BufEnter * call SynOn()
	"autocmd BufLeave * call SynOff()

	"highlight StatusLine term=bold,reverse cterm=bold,reverse ctermfg=green ctermbg=black
	"highlight StatusLineNC term=reverse cterm=reverse ctermfg=blue ctermbg=white
	"highlight StatusLine term=bold,reverse cterm=bold,reverse ctermfg=cyan ctermbg=black
	"highlight StatusLineNC term=reverse cterm=reverse ctermfg=grey ctermbg=black
	"" cterm=bold was showing hiddens chars - specifically "^^^^^^^"s I didn't like.
	" highlight StatusLine term=reverse cterm=none ctermfg=darkblue ctermbg=white gui=none,underline guifg=#000066 guibg=white
  " We get stronger white and blue in reverse!
	highlight StatusLine term=reverse cterm=reverse ctermfg=white ctermbg=blue gui=none,underline guifg=#000066 guibg=white
	" highlight StatusLineNC term=reverse,bold,italic,underline cterm=none,bold,italic,underline ctermfg=darkgrey ctermbg=black gui=none,italic,underline guifg=#222222 guibg=#bbbbbb " Looks wrong in Konsole
	" highlight StatusLineNC term=reverse,italic,underline cterm=none,italic,underline ctermfg=grey ctermbg=black gui=none,italic,underline guifg=#222222 guibg=#bbbbbb
	"" If we make it bold, in xterm the black writing appears faded grey, hinting disabled.
	"" Note that cterm=bold must come *after* setting the colors!
	highlight StatusLineNC term=reverse,italic,underline ctermbg=grey ctermfg=black cterm=bold,underline gui=none,italic,underline guifg=#222222 guibg=#bbbbbb
	"" Add underline to make it grey :f
	" highlight StatusLineNC term=reverse,italic,underline ctermbg=grey ctermfg=black cterm=bold,underline,italic gui=none,italic,underline guifg=#222222 guibg=#bbbbbb
	"" The underline is not normally noticeable, until we put two lines right
	"" next to each other, with minwinheight=0 - then it stops them merging!
	" highlight StatusLineNC ctermfg=darkgrey
	" highlight StatusLine ctermfg=darkred guifg=darkred
	" highlight StatusLineNC cterm=reverse,bold,underline ctermbg=black ctermfg=darkgrey " greyed out effect x-term
	"" This theme comes out nice in X-Term.  Somehow NC is always reversed!
	" hi StatusLine ctermbg=blue ctermfg=black
	" hi StatusLineNC ctermbg=black ctermfg=blue
	"" I want my VertSplit to be the same as StatusLineNC but without italics or underline!
	highlight VertSplit term=reverse cterm=none ctermbg=grey ctermfg=black gui=none guifg=#222222 guibg=#bbbbbb
	" Note: In xterm if you want bold black on white, you can only achieve it with reverse!  Without reverse you can only get bold dark grey or regular black on white.

	" Fold colours
	highlight Folded ctermbg=DarkBlue ctermfg=White guibg=#000080 guifg=White
	"highlight foldColumn ctermbg=Grey ctermfg=Blue cterm=none gui=bold guifg=Green guibg=#000060
	highlight FoldColumn ctermbg=DarkBlue ctermfg=White cterm=bold gui=bold guifg=White guibg=#000080

	"highlight Conceal term=reverse ctermbg=DarkBlue ctermfg=White cterm=bold guibg=Blue guifg=White gui=bold
	highlight Conceal ctermfg=cyan cterm=bold guifg=cyan gui=bold

	"" green
	"hi cursor guibg=#44ff44
	"hi cursor guibg=#66ff66
	"" peach
	"hi cursor guibg=#ffaa44
	"hi cursor guibg=#ffeecc
	hi cursor guibg=#ffcc44

	" hi MatchParen term=reverse ctermbg=red guibg=red
	" hi MatchParen term=reverse cterm=reverse ctermbg=black ctermfg=magenta guibg=black guifg=magenta
	" hi MatchParen term=reverse cterm=none ctermbg=magenta ctermfg=grey guibg=#880088 guifg=#eeeeee
	"" My terminal cursor flashes once (briefly disappears) when moving (possibly due to plugins and/or CursorHold events).
	"" This leads me to seeing two magenta boxes, which confuses me about where my cursor is.
	"" To reduce confusion, I would rather show no box, so let's highlight only the foreground, not the background:
	" hi MatchParen term=reverse cterm=none ctermbg=none ctermfg=magenta guibg=none guifg=#ff00ff
	hi MatchParen term=reverse cterm=none ctermbg=darkblue ctermfg=magenta guibg=darkblue guifg=#ff00ff

	" hi link Comma Function  ## cyan
	" hi link Comma Keyword   ## yellow
	" hi Comma cterm=bold ctermfg=white gui=bold guifg=white
	"hi Comma cterm=bold ctermfg=darkgrey gui=bold guifg=#777777

	" Ubuntu's Vim made the PMenu look naff, so I filled out all the colors
	"hi Pmenu ctermbg=magenta ctermfg=white cterm=bold guibg=#bb00bb guifg=white gui=bold
	hi Pmenu ctermbg=blue ctermfg=white cterm=bold guibg=#0000bb guifg=white gui=bold
	hi Pmenusel ctermbg=black ctermfg=white cterm=bold guibg=#000066 guifg=white gui=bold

	highlight CursorLine term=reverse cterm=none ctermbg=darkmagenta ctermfg=white guibg=darkmagenta guifg=white
	highlight clear CursorColumn
	highlight link CursorColumn CursorLine

	" highlight MyTagListFileName cterm=bold ctermbg=darkgray ctermfg=white gui=bold guibg=black guifg=white
	" highlight link MyTagListFileName MBENormal
	" highlight MyTagListFileName ctermbg=blue ctermfg=cyan cterm=bold guibg=blue guifg=cyan gui=none
	" highlight MyTagListFileName ctermbg=cyan ctermfg=white cterm=bold guibg=#00bbbb guifg=white gui=none
	" highlight MyTagListFileName ctermbg=cyan ctermfg=black cterm=none guibg=cyan guifg=black gui=none
	" highlight MyTagListFileName ctermbg=black ctermfg=cyan cterm=bold guibg=black guifg=cyan gui=bold
	" highlight MyTagListTagName cterm=bold ctermfg=magenta gui=bold guifg=magenta
	" highlight MyTagListTagName ctermbg=magenta ctermfg=white cterm=bold guibg=magenta guifg=white gui=bold
	" highlight MyTagListTagName term=reverse ctermbg=green ctermfg=white cterm=bold guibg=#00bb00 guifg=white gui=none
	" highlight MyTagListTagName term=reverse ctermbg=none ctermfg=green cterm=bold guibg=none guifg=green gui=bold
	"hi MyTagListTitle ctermfg=lightblue ctermbg=none
	"hi MyTagListTitle ctermfg=yellow ctermbg=none
	hi MyTagListTitle ctermfg=none ctermbg=none
	"hi MyTagListTagName cterm=bold ctermbg=green ctermfg=white guibg=#00cc00 guifg=white
	"hi MyTagListTagName cterm=bold ctermbg=green ctermfg=white gui=bold,reverse guibg=white guifg=#00cc00
	hi MyTagListTagName cterm=bold,reverse ctermbg=white ctermfg=green gui=bold,reverse guibg=white guifg=#00cc00
	" I think there was some reason why I shouldn't use reverse in cterm, but I forgot why!
	" I want it so that we get a strong highlight when using dim_inactive_windows.vim
	" hi MyTagListFileName ctermbg=black ctermfg=white
	hi MyTagListFileName ctermbg=black ctermfg=cyan guibg=black guifg=cyan

	" LightUpStatusLine has now moved to blinking_statusline.vim

	hi WildMenu ctermbg=green ctermfg=black guibg=green guifg=black


	"" Colors for file/folder explorers, trying to match jsh dark theme:

	" VTreeExplorer (vtreeexplorer.vim, :VSTreeExplore)
	hi Directory ctermfg=green cterm=none guifg=green gui=none
	hi TreeLnk ctermfg=green cterm=bold guifg=green gui=bold

	" NERD Tree (NERD_tree.vim, :NERDTree)
	hi link treeDirSlash Directory
	hi link treePart Normal
	hi link treePartFile Normal
	hi link treeOpenable Normal
	hi link treeClosable Normal
	hi link treeLink TreeLnk
	hi treeExecFile ctermfg=red cterm=bold guifg=red gui=bold

	" netrw (bundled netrwPlugin.vim, :vert split +:Explore)
	hi link netrwSymLink TreeLnk
	hi link netrwTreeBar treePart
	hi link netrwClassify treeDirSlash
	hi link netrwExe treeExecFile



	hi TabLine ctermbg=blue ctermfg=cyan cterm=none
	hi TabLineSel ctermfg=green ctermbg=blue cterm=bold,reverse


	hi LineNr ctermfg=darkmagenta guifg=magenta


	hi SignColumn guibg=black

	hi EchoMsg ctermfg=green guifg=green
	" BUG: This will not work for long.  echohl is set and unset at realtime by scripts.
	echohl EchoMsg
	" However I see no workaround.  Echo messages are highlighted as 'Normal' by default.
	" Actually that is not true...  They are highlighted as 'Normal' at startup, but then as 'None' after script has used :echohl and followed the advice in the help for :echohl !
	" Who knows what else is highlighted as None though...
	hi link None EchoMsg

	" I used to think I should take advantage of the GUI's wide colour range.
	" But these days I begin to prefer continuity between xterm and GUI.
	" Unfortunately I note that the GUI's Lucida Console 10 is not quite as heavy weight as xterm's lucidatypewriter-100, making me want to bold everything.
	" Lucida Console 8 and lucidatypewriter-80 are more similar in weight, but the former loses a little intensity to anti-aliasing.
	let highlight_gui_like_xterm = 1
	if highlight_gui_like_xterm
		hi Comment guifg=#777777 gui=bold
		hi String guifg=#00ff00
		hi Statement guifg=yellow gui=bold
		hi Identifier guifg=cyan gui=bold
		hi Special guifg=magenta gui=bold
		hi Search guifg=blue guibg=green gui=bold,reverse
		hi HLCurrentWord guifg=red gui=bold
		"hi Number guifg=cyan
		hi Normal guifg=#f7f7f7
	endif

endfun

" I had disabled this, to rely on autocmd above.
" But in some cases it didn't fire, e.g. when using `vim -` to read from stdin.
:Joeyhighlight

