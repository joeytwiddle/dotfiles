let s:oldHeight = -1       " This is the marker: -1 === toggled off
let s:oldwinheight = -1

function! ToggleMaximize()
	if s:oldHeight == -1
		let s:oldHeight = winheight(0)
		let s:oldwinheight = &winheight
		exec "set winheight=9999"
	else
		exec "set winheight=".s:oldwinheight
		exec "resize ".s:oldHeight
		let s:oldHeight = -1
	endif
endfunction

"" I failed to get it working on Ctrl-\,Z,V and Enter!
" noremap! <C-\> :call ToggleMaximize()<Enter>
" noremap!  :call ToggleMaximize()<Enter>
" noremap! <C-Z> :call ToggleMaximize()<Enter>
" noremap!  :call ToggleMaximize()<Enter>
" noremap! <C-V> :call ToggleMaximize()<Enter>
" noremap!  :call ToggleMaximize()<Enter>
" noremap! <C-Enter> :call ToggleMaximize()<Enter>
"" It does work on Ctrl-G:
noremap! <C-G> :call ToggleMaximize()<Enter>
inoremap <C-G> <Esc>:call ToggleMaximize()<Enter>a

