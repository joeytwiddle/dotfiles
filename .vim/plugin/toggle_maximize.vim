" ToggleMaximize v1.1
"
" Press Ctrl-F to maximize the size of the current window, press again to
" restore the original window layout.
"
" Additional feature: If you mess up your layout and want to restore it to
" something like what you had the last time you maximized, you can:
"   :call RestoreLayout()

" TACKLING: Does not restore the originally shape of the layout entirely, e.g.
" windows open on the left of this one tend to remain squashed.

" Now it tries pretty hard to restore the windows to their previous sizes.
" Unfortunately, telling all the windows in order what size they should be
" does not always result in the original layout.  Sometimes later windows
" resize earlier ones when their command is seen.  (E.g. layout 1,3,1.)
" Ooh somehow the "final check" fixed 1,3,1!

" BUG/FEATURE: Unlike a modern X window manager, if the user changes the size
" of any windows after maximizing, the script still thinks the toggle is ON,
" so next time it is used it will restore, rather than re-maximize.

" == Options ==
if !exists("g:ToggleMaximizeVertically")
	let g:ToggleMaximizeVertically = 1
endif
if !exists("g:ToggleMaximizeHorizontally")
	let g:ToggleMaximizeHorizontally = 1
endif

let s:isToggledVertically = 0
let s:oldHeight = -1
let s:oldwinheight = -1

function! ToggleMaximizeVertically()
	if s:isToggledVertically == 0
		" let s:oldHeight = winheight(0)
		let s:isToggledVertically = 1
		resize 9999
	else
		" exec "resize ".s:oldHeight
		let s:isToggledVertically = 0
	endif
endfunction

let s:isToggledHorizontally = 0
let s:oldWidth = -1
let s:oldwinwidth = -1

function! ToggleMaximizeHorizontally()
	if s:isToggledHorizontally == 0
		" let s:oldWidth = winwidth(0)
		let s:isToggledHorizontally = 1
		vertical resize 9999
	else
		" exec "vertical resize ".s:oldWidth
		let s:isToggledHorizontally = 0
	endif
endfunction

function! ToggleMaximize()
	if s:isToggledHorizontally == 0 && s:isToggledVertically == 0
		call StoreLayout()
	endif
	if g:ToggleMaximizeVertically
		call ToggleMaximizeVertically()
	endif
	if g:ToggleMaximizeHorizontally
		call ToggleMaximizeHorizontally()
	endif
	if s:isToggledHorizontally == 0 && s:isToggledVertically == 0
		call RestoreLayout()
	endif
endfunction

" New technique to restore layout accurately when un-maximizing.
function! StoreLayout()
	let l:winnr = winnr()
	windo exec "call WinStoreLayout()"
	exec l:winnr." wincmd w"
endfunction

function! RestoreLayout()
	" When we resize one window, We do not have much control over which side
	" moves, and what other windows expand or shrink as a result.
	let l:winnr = winnr()
	windo exec "call WinRestoreLayout()"
	" Running it twice can help!
	" That fixed a complex 1, 1[1,2,1,1,1]1, 1, 1 layout!
	windo exec "call WinRestoreLayout()"
	exec l:winnr." wincmd w"
	" This is the most important window, so let's give him a final check:
	call WinRestoreLayout()
endfunction

function! WinStoreLayout()
	let w:oldWidth = winwidth(0)
	let w:oldHeight = winheight(0)
endfunction

function! WinRestoreLayout()
	" echo "Doing resize to ".w:oldWidth."x".w:oldHeight." for win number ".winnr()." aka ".bufname('%')
	if exists("w:oldWidth")
		exec "vertical resize ".w:oldWidth
		" exec "setlocal winwidth=".w:oldWidth
		" exec "setlocal winminwidth=".w:oldWidth
	endif
	if exists("w:oldHeight")
		exec "resize ".w:oldHeight
		" exec "setlocal winheight=".w:oldHeight
		" exec "setlocal winminheight=".w:oldHeight
	endif
endfunction

" == Keymaps ==

noremap <C-F> :call ToggleMaximize()<Enter>
inoremap <C-F> <Esc>:call ToggleMaximize()<Enter>a
noremap <C-\> :call ToggleMaximize()<Enter>
inoremap <C-\> <Esc>:call ToggleMaximize()<Enter>a
" noremap <C-G> :call ToggleMaximize()<Enter>
" inoremap <C-G> <Esc>:call ToggleMaximize()<Enter>a
" noremap <C-Z> :call ToggleMaximize()<Enter>
" inoremap <C-Z> <Esc>:call ToggleMaximize()<Enter>a

noremap <C-V> :call ToggleMaximizeVertically()<Enter>
inoremap <C-V> <Esc>:call ToggleMaximizeVertically()<Enter>a
noremap <C-H> :call ToggleMaximizeHorizontally()<Enter>
inoremap <C-H> <Esc>:call ToggleMaximizeHorizontally()<Enter>a

"" Does not work:
" noremap <C-Enter> :call ToggleMaximize()<Enter>

