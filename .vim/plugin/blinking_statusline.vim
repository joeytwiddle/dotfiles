" Flashes the status line of the focused window whenever you change window.

if exists("g:blinking_statusline") && g:blinking_statusline>0
	" Make StatusLine light up temporarily when we switch window
	augroup BlinkingStatusLine
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
		" autocmd WinEnter   * hi StatusLine ctermfg=yellow ctermbg=darkblue gui=none guibg=yellow guifg=blue
		" autocmd BufEnter   * hi StatusLine ctermfg=yellow ctermbg=darkblue gui=none guibg=yellow guifg=blue
		" autocmd CursorHold * hi StatusLine ctermfg=white  ctermbg=blue     gui=none guibg=white  guifg=blue
		"" New implementation:  Don't overwrite StatusLine explicitly, instead link
		"" it to one of StatusLineLit/Unlit, which can be edited by user at
		"" runtime.
		hi StatusLineLit   ctermfg=yellow ctermbg=darkblue cterm=reverse,bold gui=none guibg=yellow guifg=blue
		hi StatusLineUnlit ctermfg=white  ctermbg=blue     cterm=reverse,bold gui=none guibg=white  guifg=blue
		autocmd WinEnter   * hi clear StatusLine | hi link StatusLine StatusLineLit
		autocmd BufEnter   * hi clear StatusLine | hi link StatusLine StatusLineLit
		autocmd CursorHold * hi clear StatusLine | hi link StatusLine StatusLineUnlit
	augroup END
	set updatetime=600
endif

