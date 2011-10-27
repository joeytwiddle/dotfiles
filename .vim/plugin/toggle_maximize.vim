" ToggleMaximize v1.2.1 by joey.neuralyte.org
"
" Press Ctrl-F or Ctrl-\ to maximize the size of the current window, press
" again to restore the original window layout.
"
" Ctrl-V and Ctrl-H toggle maximize in horizontal/vertical direction only.
"
" Maximization respects the winminwidth and winminheight of other windows.
"
" Additional feature: If you mess up your layout and want to restore it to
" something like what you had the last time you maximized, you can:
"   :call RestoreLayout()

" FEATURE: If the user changes the size of any windows after maximizing, the
" script still thinks the toggle is ON, so next time it is used it will
" restore, rather than re-maximize.

" ISSUES: We had problems accurately restoring the window layout, because
" windows would interfere with each other while we were restoring their
" settings.  Hopefully WinDoBothWays() has fixed this in most cases.

" BUG: Frequently restores windows which were height 0 with height winheight,
" (and likewise for width) due to the fact that they are visited by windo, and
" resize 0 does nothing on the window you occupy!
" Presumably most earlier versions had this issue also?
" Gawd I suppose in the long term we could somehow mark windows which were
" height 0 and try not to revisit them when restoring, hoping the other
" windows will keep them as small as they should be!

" TOTEST: Large values of winwidth/height may cause problems restoring layout.

let s:isToggledVertically = 0
let s:isToggledHorizontally = 0

function! ToggleMaximize()
	" We can't call them directly, because they both use windo to collect info,
	" the second one may re-expand vertically windows we have hidden already
	" squished!
	" OK so solution: do horizontal first?
	"call ToggleMaximizeHorizontally()
	"call ToggleMaximizeVertically()
	" This will sometimes leave a 1-char wide (or &winwidth) window, which
	" should have been 0, usually on the left side.
	" To avoid it entirely, we should do our own WinDos here

	if s:isToggledVertically == 1 && s:isToggledHorizontally == 1
		" If both axes are maximized, we restore layout
		call s:WinDoBothWays("call WinRestoreHeight()")
		call s:WinDoBothWays("call WinRestoreWidth()")
		let s:isToggledVertically = 0
		let s:isToggledHorizontally = 0
	else
		" Otherwise we maximize one or both axes

		" Get data before re-arranging windows
		if s:isToggledVertically == 0
			call s:WinDo("call WinStoreHeight()")
		endif
		if s:isToggledHorizontally == 0
			call s:WinDo("call WinStoreWidth()")
		endif

		" Maximize
		if s:isToggledVertically == 0
			let s:isToggledVertically = 1
			resize 9999
		endif
		if s:isToggledHorizontally == 0
			let s:isToggledHorizontally = 1
			vertical resize 9999
		endif

	endif
endfunction

function! ToggleMaximizeVertically()
	if s:isToggledVertically == 0
		call s:WinDo("call WinStoreHeight()")
		let s:isToggledVertically = 1
		resize 9999
	else
		call s:WinDoBothWays("call WinRestoreHeight()")
		let s:isToggledVertically = 0
	endif
endfunction

function! ToggleMaximizeHorizontally()
	if s:isToggledHorizontally == 0
		call s:WinDo("call WinStoreWidth()")
		let s:isToggledHorizontally = 1
		vertical resize 9999
	else
		call s:WinDoBothWays("call WinRestoreWidth()")
		let s:isToggledHorizontally = 0
	endif
endfunction

function! WinStoreHeight()
	let w:oldHeight = winheight(0)
endfunction

function! WinStoreWidth()
	let w:oldWidth = winwidth(0)
endfunction

function! WinRestoreHeight()
	if exists("w:oldHeight")
		exec "resize ".w:oldHeight
	endif
endfunction

function! WinRestoreWidth()
	if exists("w:oldWidth")
		exec "vertical resize ".w:oldWidth
	endif
endfunction

" Deprecated
function! StoreLayout()
	call s:WinDo("call WinStoreHeight()")
	call s:WinDo("call WinStoreWidth()")
endfunction

" Deprecated
function! RestoreLayout()
	" When we resize one window, We do not have much control over which side
	" moves, and what other windows expand or shrink as a result.  So sometimes
	" the above will leave a window crushed by others.  Running it a second
	" time in reverse can often fix the layout if the first attempt failed.
	call s:WinDoBothWays("call WinRestoreHeight()")
	call s:WinDoBothWays("call WinRestoreWidth()")
	"" The focus window is the most important window, so let's give him a final check:
	" call WinRestoreWidth()
	" call WinRestoreHeight()
endfunction

" Like :windo but returns to start window when finished.
function! s:WinDo(expr)
	let l:winnr = winnr()
	windo exec a:expr
	exec l:winnr." wincmd w"
endfunction

" Like WinDo but traverses windows in reverse order.
function! s:WinDoReverse(expr)
	let l:winnr = winnr()
	wincmd b   " Move to last window
	let l:firstwinnr = winnr()
	let l:safety = 0
	while l:safety < 99
		let l:safety += 1
		let l:lastwinnr = winnr()   " Do not move this down one line!
		windo exec a:expr
		wincmd W   " Move to next window
		" Check if we have stalled or looped back to start
		if winnr() == l:lastwinnr || winnr() == l:firstwinnr
			break
		endif
	endwhile
	exec l:winnr." wincmd w"
endfunction

" Calls WinDo then WinDoReverse, to help deal with windows that are not
" re-assuming their correct positions!
function! s:WinDoBothWays(expr)
	call s:WinDo(a:expr)
	call s:WinDoReverse(a:expr)
endfunction

" == Keymaps ==

noremap <C-F> :call ToggleMaximize()<Enter>
inoremap <C-F> <Esc>:call ToggleMaximize()<Enter>a
noremap <C-\> :call ToggleMaximize()<Enter>
inoremap <C-\> <Esc>:call ToggleMaximize()<Enter>a
"noremap <C-G> :call ToggleMaximize()<Enter>
"inoremap <C-G> <Esc>:call ToggleMaximize()<Enter>a
"noremap <C-Z> :call ToggleMaximize()<Enter>
"inoremap <C-Z> <Esc>:call ToggleMaximize()<Enter>a

noremap <C-V> :call ToggleMaximizeVertically()<Enter>
noremap <C-H> :call ToggleMaximizeHorizontally()<Enter>
" We will not override Ctrl-V or Ctrl-H in Insert mode; Ctrl-V is too useful,
" and Ctrl-H might be what some systems see when the user presses Backspace.
"inoremap <C-V> <Esc>:call ToggleMaximizeVertically()<Enter>a
"inoremap <C-H> <Esc>:call ToggleMaximizeHorizontally()<Enter>a

"" Does not work:
"noremap <C-Enter> :call ToggleMaximize()<Enter>

