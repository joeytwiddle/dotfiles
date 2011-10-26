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

let s:isToggledVertically = 0
let s:oldHeight = -1
let s:oldwinheight = -1

function! s:WinDo(expr)
	let l:winnr = winnr()
	windo exec a:expr
	exec l:winnr." wincmd w"
endfunction

function! ToggleMaximizeVertically()
	if s:isToggledVertically == 0
		call s:WinDo("call WinStoreHeight()")
		let s:isToggledVertically = 1
		resize 9999
	else
		call s:WinDo("call WinRestoreHeight()")
		let s:isToggledVertically = 0
	endif
endfunction

let s:isToggledHorizontally = 0
let s:oldWidth = -1
let s:oldwinwidth = -1

function! ToggleMaximizeHorizontally()
	if s:isToggledHorizontally == 0
		call s:WinDo("call WinStoreWidth()")
		let s:isToggledHorizontally = 1
		vertical resize 9999
	else
		call s:WinDo("call WinRestoreWidth()")
		let s:isToggledHorizontally = 0
	endif
endfunction

function! ToggleMaximize()
	" if s:isToggledHorizontally == 0 && s:isToggledVertically == 0
		" call StoreLayout()
	" endif
	call ToggleMaximizeVertically()
	call ToggleMaximizeHorizontally()
	" if s:isToggledHorizontally == 0 && s:isToggledVertically == 0
		" call RestoreLayout()
	" endif
endfunction

" New technique to restore layout accurately when un-maximizing.
function! StoreLayout()
	" let l:winnr = winnr()
	" windo exec "call WinStoreHeight()"
	" windo exec "call WinStoreWidth()"
	" exec l:winnr." wincmd w"
	call s:WinDo("call WinStoreHeight()")
	call s:WinDo("call WinStoreWidth()")
endfunction

function! WinStoreWidth()
	let w:oldWidth = winwidth(0)
endfunction
function! WinStoreHeight()
	let w:oldHeight = winheight(0)
endfunction

function! RestoreLayout()
	"" When we resize one window, We do not have much control over which side
	"" moves, and what other windows expand or shrink as a result.
	" let l:winnr = winnr()
	" windo exec "call WinRestoreWidth()"
	" windo exec "call WinRestoreHeight()"
	call s:WinDo("call WinRestoreWidth()")
	call s:WinDo("call WinRestoreHeight()")
	"" So sometimes the above will leave a window crushed by others.
	"" Running it a second time will often fix the layout if the first attempt
	"" did not.
	" windo exec "call WinRestoreWidth()"
	" windo exec "call WinRestoreHeight()"
	" exec l:winnr." wincmd w"
	call s:WinDo("call WinRestoreWidth()")
	call s:WinDo("call WinRestoreHeight()")
	"" The focus window is the most important window, so let's give him a final check:
	call WinRestoreWidth()
	call WinRestoreHeight()
endfunction

function! WinRestoreWidth()
	if exists("w:oldWidth")
		exec "vertical resize ".w:oldWidth
	endif
endfunction

function! WinRestoreHeight()
	if exists("w:oldHeight")
		exec "resize ".w:oldHeight
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

