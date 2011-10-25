" ToggleMaximize v1.0

" BUGS: Does not restore the originally shape of the layout entirely, e.g.
" windows open on the left of this one tend to remain squashed.

if !exists("g:ToggleMaximizeVertically")
	let g:ToggleMaximizeVertically = 1
endif
if !exists("g:ToggleMaximizeHorizontally")
	let g:ToggleMaximizeHorizontally = 1
endif

let s:isToggledVertically = 0
let s:oldHeight = -1
let s:oldwinheight = -1
let s:isToggledHorizontally = 0
let s:oldWidth = -1
let s:oldwinwidth = -1

function! ToggleMaximizeVertically()
	if s:isToggledVertically == 0
		let s:oldHeight = winheight(0)
		let s:oldwinheight = &winheight
		exec "set winheight=9999"
		let s:isToggledVertically = 1
	else
		exec "set winheight=".s:oldwinheight
		exec "resize ".s:oldHeight
		let s:isToggledVertically = 0
	endif
endfunction

function! ToggleMaximizeHorizontally()
	if s:isToggledHorizontally == 0
		let s:oldWidth = winwidth(0)
		let s:oldwinwidth = &winwidth
		exec "set winwidth=9999"
		let s:isToggledHorizontally = 1
	else
		exec "set winwidth=".s:oldwinwidth
		exec "vertical resize ".s:oldWidth
		let s:isToggledHorizontally = 0
	endif
endfunction

function! ToggleMaximize()

	if g:ToggleMaximizeVertically
		call ToggleMaximizeVertically()
	endif

	if g:ToggleMaximizeHorizontally
		call ToggleMaximizeHorizontally()
	endif

endfunction

noremap <C-F> :call ToggleMaximize()<Enter>
inoremap <C-F> <Esc>:call ToggleMaximize()<Enter>a
" noremap <C-G> :call ToggleMaximize()<Enter>
" inoremap <C-G> <Esc>:call ToggleMaximize()<Enter>a
noremap <C-\> :call ToggleMaximize()<Enter>
inoremap <C-\> <Esc>:call ToggleMaximize()<Enter>a
" noremap <C-Z> :call ToggleMaximize()<Enter>
" inoremap <C-Z> <Esc>:call ToggleMaximize()<Enter>a

noremap <C-V> :call ToggleMaximizeVertically()<Enter>
inoremap <C-V> <Esc>:call ToggleMaximizeVertically()<Enter>a
noremap <C-H> :call ToggleMaximizeHorizontally()<Enter>
inoremap <C-H> <Esc>:call ToggleMaximizeHorizontally()<Enter>a

"" Does not work:
" noremap <C-Enter> :call ToggleMaximize()<Enter>

