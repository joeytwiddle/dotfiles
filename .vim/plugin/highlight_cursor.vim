" Highlights the cursor so that it appear as a reverse block (oldskool!)
" Especially useful if for some reason your normal cursor
" disappears or is missing/invisible/hidden or intermittent.
" Ctrl-C or Ctrl-H to toggle on/off

" Not needed but keep cursor centered
" set scrolloff=999

function! HighlightCursorRefresh()
	if exists("g:highlightcursor")
		call HighlightCursorOff()
		call HighlightCursorOn()
	endif
endfunction

function! HighlightCursorOff()
	match None
endfunction

function! HighlightCursorOn()
	"" Intended to cycle colours constantly, but event only fired on keypress.
	"" Tried while loop with sleep but no user interaction allowed :-(
	"" We could try using getchar(0) and if it exists, send it to the keyboard!
	" " while 1
	" let g:highlightcursor=g:highlightcursor+1
	" if g:highlightcursor > 7
		" let g:highlightcursor=1
	" endif
	" exe 'highlight JCursor ctermfg=black ctermbg=' . g:highlightcursor
	" " sleep 200m
	" " endwhile
	match JCursor /\%#/
endfunction

function! HighlightCursorToggle()
	if exists("g:highlightcursor")
		unlet g:highlightcursor
		" Clear autocmds etc.
		call HighlightCursorOff()
	else
		let g:highlightcursor=1
		set updatetime=10
		autocmd CursorHold * :call HighlightCursorRefresh()
		autocmd BufEnter * :call HighlightCursorRefresh()
		" highlight JCursor ctermfg=black ctermbg=white
		highlight JCursor ctermfg=black ctermbg=green term=reverse
		call HighlightCursorRefresh()
	endif
endfunction

map <C-C> :call HighlightCursorToggle()<CR>
map <C-H> :call HighlightCursorToggle()<CR>
