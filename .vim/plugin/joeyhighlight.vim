:command! Joeyhighlight call Joeyhighlight()
if has("menu")
	amenu &Joey's\ Tools.&Joey's\ highlighting :call Joeyhighlight()<CR>
endif

function! Joeyhighlight()

	" :colors pablo
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv
	" :set guifont=-schumacher-clean-medium-r-normal-*-*-150-*-*-c-*-iso646.1991-irv
	" :set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1

	":syntax on

	"" Light on dark
	:set background=dark
	"highlight Normal ctermbg=black ctermfg=grey guibg=Black guifg=#cccccc
	"highlight Normal ctermfg=grey guibg=Black guifg=#cccccc
	"highlight Normal ctermfg=lightgrey guibg=Black guifg=#cccccc
	" highlight Normal ctermfg=lightgrey guibg=#2b3735 guifg=#cccccc
	"highlight Normal ctermfg=LightGray guibg=#000000 guifg=LightGray
	highlight Normal ctermfg=lightgrey guifg=#dddddd guibg=#000000

	"" Some slightly lighter (off-black) backgrounds:
	"" Can help *reduce* contrast if font is thin and appears faint
	" highlight Normal guibg=#081818	" Almost black background
	" highlight Normal guibg=#102020	" Almost black background
	" highlight Normal guibg=#182828	" Medium/compromise
	" highlight Normal guibg=#203030	" Lighter Faded background
	highlight Normal guibg=#223330	" Custom greeny/cyan, softer on my broken monitor
	" highlight Normal guibg=#304040	" Not-so-dark grey

	highlight Title ctermbg=black ctermfg=green guibg=#000060 guifg=#00ff00

	" highlight WarningMsg ctermbg=black ctermfg=red cterm=bold
	highlight WarningMsg term=reverse,bold cterm=reverse,bold gui=reverse,bold ctermbg=red ctermfg=yellow guibg=red guifg=yellow
	" highlight ErrorMsg ctermbg=Red ctermfg=Yellow gui=bold guibg=Red guifg=Yellow
	highlight ErrorMsg term=reverse,bold cterm=bold gui=reverse,bold ctermfg=yellow ctermbg=darkred guibg=yellow guifg=#cc0000
	" Full red is too bright, dark red is too dark

	highlight DiffLine ctermbg=Magenta ctermfg=White
	"highlight Search term=reverse,bold ctermbg=White guibg=White ctermfg=Black guifg=Black
	"highlight Search ctermbg=Blue ctermfg=White term=bold guibg=Blue guifg=White
	"highlight Search ctermbg=Blue ctermfg=Yellow term=bold guibg=Blue guifg=Yellow
	"highlight Search ctermbg=Blue ctermfg=Yellow term=bold guibg=#0000aa guifg=#ffee99 gui=bold
	"highlight Search ctermbg=Blue ctermfg=Yellow term=bold guibg=#005500 guifg=#ffbb66 gui=bold
	"highlight Search ctermbg=blue ctermfg=white term=bold guibg=#005500 guifg=#66ff88 gui=bold
	"highlight Search ctermbg=blue ctermfg=white term=bold guibg=#005500 guifg=#bbffbb gui=bold
	highlight Search ctermbg=blue ctermfg=green term=bold guibg=#005544 guifg=#aaffaa gui=bold
	" highlight Visual ctermfg=DarkMagenta ctermbg=White guifg=DarkMagenta guibg=White
	" highlight Visual ctermfg=DarkMagenta ctermbg=White gui=none guibg=#553355
	highlight Visual ctermfg=DarkMagenta ctermbg=White gui=none guibg=#445555
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
	highlight Comment cterm=bold ctermfg=darkcyan gui=none guifg=#80a0ff   " nice mid-light blue
	" highlight Comment cterm=bold ctermfg=magenta gui=none guifg=LightMagenta
	highlight friendlyComment cterm=none ctermfg=cyan gui=none guifg=#80a0ff   " nice mid-light blue
	highlight def link confComment Comment
	"highlight link jComment Comment
	" highlight jComment ctermfg=DarkYellow guifg=DarkYellow
	" highlight jComment cterm=bold ctermfg=magenta gui=none guifg=lightmagenta
	highlight link jComment Comment
	highlight SpecialChar ctermfg=Red guifg=Red
	highlight SpecialKey cterm=bold ctermfg=darkblue gui=bold guifg=#2222aa
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
	highlight Constant ctermfg=DarkYellow guifg=DarkYellow

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

	" For vimdiffs
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
	highlight DiffAdd ctermbg=green ctermfg=white cterm=bold guibg=DarkGreen guifg=White gui=bold
	highlight DiffText ctermbg=red ctermfg=yellow cterm=bold guibg=red guifg=DarkRed gui=bold
	"highlight DiffChange ctermfg=black ctermbg=white cterm=bold gui=bold guifg=White guibg=Black
	"highlight DiffChange ctermfg=white ctermbg=black cterm=bold gui=bold guifg=White guibg=Black
	" Lines with changes only marked with brighter white fg, which doesn't always show:
	highlight DiffChange ctermfg=white ctermbg=black cterm=bold gui=bold guifg=White guibg=Black
	highlight DiffDelete term=none ctermbg=blue ctermfg=blue cterm=none guifg=DarkBlue guibg=DarkBlue gui=none

	"highlight diffRemoved term=none ctermbg=red ctermfg=white cterm=none guifg=Grey guibg=DarkRed gui=none
	"highlight link diffAdded DiffAdd
	"highlight link diffChanged DiffChange
	highlight diffRemoved term=bold ctermbg=black ctermfg=red cterm=bold guifg=Grey guibg=DarkRed gui=none
	highlight diffAdded   term=bold ctermbg=black ctermfg=green cterm=bold guifg=Grey guibg=DarkRed gui=none
	highlight diffChanged term=bold ctermbg=black ctermfg=yellow cterm=bold guifg=Grey guibg=DarkRed gui=none

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

	" Fold colours
	highlight Folded ctermbg=DarkBlue ctermfg=White guibg=#000080 guifg=White
	"highlight foldColumn ctermbg=Grey ctermfg=Blue cterm=none gui=bold guifg=Green guibg=#000060
	highlight FoldColumn ctermbg=DarkBlue ctermfg=White cterm=bold gui=bold guifg=White guibg=#000080

	"" Green
	"hi Cursor guibg=#44ff44
	"hi Cursor guibg=#66ff66
	"" Peach
	"hi Cursor guibg=#ffaa44
	hi Cursor guibg=#ffeecc

	" hi MatchParen term=reverse ctermbg=red guibg=red
	" hi MatchParen term=reverse cterm=reverse ctermbg=black ctermfg=magenta guibg=black guifg=magenta
	hi MatchParen term=reverse cterm=none ctermbg=magenta ctermfg=grey guibg=#880088 guifg=#eeeeee

	" hi link Comma Function  ## cyan
	" hi link Comma Keyword   ## yellow
	" hi Comma cterm=bold ctermfg=white gui=bold guifg=white
	hi Comma cterm=bold ctermfg=darkgrey gui=bold guifg=#777777

	hi Pmenu cterm=bold guibg=#bb00bb gui=bold
	hi Pmenusel gui=bold guifg=white guibg=#660066

	highlight CursorLine term=reverse cterm=none ctermbg=darkmagenta ctermfg=white guibg=darkmagenta guifg=white

	highlight TagListTagName cterm=bold ctermfg=magenta gui=bold guifg=magenta
	highlight TagListFileName cterm=bold ctermbg=darkgray ctermfg=white gui=bold guibg=black guifg=white

  if exists("g:blinking_statusline") && g:blinking_statusline>0
    " Make StatusLine light up temporarily when we switch window
    augroup LightUpStatusLine
      autocmd!
      " autocmd WinEnter * hi StatusLine ctermbg=green ctermfg=white
      " autocmd WinEnter * hi StatusLine ctermbg=white ctermfg=red
      "" We must use reverse to get thick black on white:
      " autocmd CursorHold * hi StatusLine ctermbg=black ctermfg=white cterm=reverse,bold
      " autocmd WinEnter * hi StatusLine ctermbg=white ctermfg=green
      " autocmd WinEnter   * hi StatusLine cterm=none ctermbg=green ctermfg=black
      "" Green bar for non-reversed cterm:
      "autocmd WinEnter   * hi StatusLine ctermbg=green ctermfg=darkblue gui=none guibg=green guifg=blue
      "autocmd BufEnter   * hi StatusLine ctermbg=green ctermfg=darkblue gui=none guibg=green guifg=blue
      "autocmd CursorHold * hi StatusLine ctermbg=white ctermfg=blue     gui=none guibg=white guifg=blue
      "" Green and blue bar for reversed cterm:
      "autocmd WinEnter   * hi StatusLine ctermfg=green ctermbg=darkblue gui=none guifg=green guibg=blue
      "autocmd BufEnter   * hi StatusLine ctermfg=green ctermbg=darkblue gui=none guifg=green guibg=blue
      "autocmd CursorHold * hi StatusLine ctermfg=white ctermbg=blue     gui=none guifg=white guibg=blue
      "" Green and white bar for reversed cterm:  (can't get bright white grr!)
      "autocmd WinEnter   * hi StatusLine ctermfg=green ctermbg=white gui=none guifg=green guibg=white
      "autocmd BufEnter   * hi StatusLine ctermfg=green ctermbg=white gui=none guifg=green guibg=white
      "autocmd CursorHold * hi StatusLine ctermfg=white ctermbg=blue     gui=none guifg=white guibg=blue
      "" Green and bright-white bar for non-reversed cterm:
      "autocmd WinEnter   * hi StatusLine cterm=bold ctermfg=white ctermbg=green gui=none guifg=green guibg=white
      "autocmd BufEnter   * hi StatusLine cterm=bold ctermfg=white ctermbg=green gui=none guifg=green guibg=white
      "autocmd CursorHold * hi StatusLine cterm=bold ctermfg=blue ctermbg=white     gui=none guifg=white guibg=blue
      "" Yellow bar for reversed cterm:
      autocmd WinEnter   * hi StatusLine ctermfg=yellow ctermbg=darkblue gui=none guibg=yellow guifg=blue
      autocmd BufEnter   * hi StatusLine ctermfg=yellow ctermbg=darkblue gui=none guibg=yellow guifg=blue
      autocmd CursorHold * hi StatusLine ctermfg=white  ctermbg=blue     gui=none guibg=white  guifg=blue
    augroup END
    set updatetime=600
  endif



  "" Colors for file/folder explore, to match jsh dark:

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



endfun

:Joeyhighlight
