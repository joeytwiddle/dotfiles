" :Jhighlight <colour> <regexp>
"   will create a new syntax match with the regexp, and highlight matches with
"   the given background colour.

command! -nargs=1 Jhighlight call Jhighlight(<f-args>)

" map clear <C-H>
" map! <C-H> :call JrandomHighlight()<CR>
map <C-H> :call JrandomHighlight('\<'.expand("<cword>").'\>')<CR>

function! Jhighlight(colour, pattern)
	let name = "Jhighlight_".a:colour
	execute "syntax match ".name." +".a:pattern."+"
	execute "highlight ".name." ctermbg=".a:colour" ctermfg=White"
endfunction

let seed = localtime()

function! Jabs(num)
	if a:num < 0
		return -a:num
	else
		return a:num
endfunction

function! Jrandom(bottom,top)
	let g:seed = g:seed + localtime()
	let t = Jabs(g:seed)
	let x = a:bottom + t % (a:top - a:bottom)
	" echo x
	return x
endfunction

function! ToHex(i)
	return strpart("0123456789ABCDEF",a:i,1)
endfunction

function! JrandomHighlight(pat)
	" let pattern = JwordUnderCursor()
	" let pattern = '\<' . expand("<cword>") . '\>'
	let pattern = a:pat
	let colour = "#"
	let i = 0
	while i < 6
		let n = Jrandom(0, 16)
		" echo "n: " . n
		let colour = l:colour . ToHex(l:n)
		" echo "tohex(" . n . ") = " . ToHex(n)
		let i = l:i + 1
	endwhile
	" echo "colour = " . colour
	let name = "Jhighlight_" . pattern
	if exists(name)
		execute "highlight clear " . l:name
		execute "syntax clear " . l:name
	endif
	execute "syntax match " . l:name . " +" . l:pattern . "+"
	" execute "highlight " . l:name . " ctermbg=black ctermfg=" . l:colour . " guifg=" . l:colour . " gui=bold,italic"
	execute "highlight " . l:name . " guifg=" . l:colour . " gui=italic"
endfunction
