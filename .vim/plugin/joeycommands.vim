""""""""""""""""""""""""""""""" Jhighlight """""""""""""""""""""""""""""""

" :Jhighlight <colour> <regexp>
"   will create a new syntax match with the regexp, and highlight matches with
"   the given background colour.

command! -nargs=1 Jhighlight call Jhighlight(<f-args>)

function! Jhighlight(colour, pattern)
	let name = "Jhighlight_".a:colour
	execute "syntax match ".name." +".a:pattern."+"
	execute "highlight ".name." ctermbg=".a:colour" ctermfg=White"
endfunction

"""""""""""""""""""""""""""" JrandomHighlight """"""""""""""""""""""""""""

" map clear <C-H>
" map! <C-H> :call JrandomHighlight()<CR>
map <C-H> :call JrandomHighlight('\<'.expand("<cword>").'\>')<CR>

if has("menu")
	amenu &Joey's\ Tools.&Colour\ current\ word\ <C-H> :call JrandomHighlight('\<'.expand("<cword>").'\>')<CR>
endif

function! JrandomHighlight(pat)
	" let pattern = JwordUnderCursor()
	" let pattern = '\<'.expand("<cword>").'\>'
	let pattern = a:pat
	let truecolour = "#"
	let i = 0
	while i < 6
		let n = Jrandom(0, 16)
		let truecolour .= ToHex(n)
		let i = i + 1
	endwhile
	let numcolour = Jrandom(1,8)
	let name = "JrandomHighlight_".pattern
	"" This next line prevents clear from complaining on the first run.
	execute "syntax match ".name." +".pattern."+"
	execute "syntax clear ".name
	execute "syntax match ".name." +".pattern."+"
	execute "highlight ".name." ctermfg=".numcolour." guifg=".truecolour." gui=italic"
endfunction

""""""""""""""""""""""""""""""" Jrefactor """""""""""""""""""""""""""""""

command! -nargs=1 Jrefactor call Jrefactor(<f-args>)

if has("menu")
	amenu &Joey's\ Tools.&Refactor\ word\ under\ cursor :call JrefactorDialog()<CR>
endif

"" TODO: function! JrefactorDialog()

function! Jrefactor(replace)
	let word = expand("<cword>")
	"" TODO: Escape word and replace's '/'s, (and '\'s, etc.?)
	"" TODO: Check the unique word replace is not already present in target
	"" TODO: Allow all buffers to be targeted
	"" TODO: Confirm action beforehand if /c not enabled.  Allows user to check <cword> worked suitably.
	" execute "%s/\\<" . l:word . "\\>/" . a:replace . "/c"
	execute "%s/\\<" . l:word . "\\>/" . a:replace . "/gc"
endfunction

""""""""""""""""""""""""""" Library functions """""""""""""""""""""""""""

function! Jabs(num)
	if a:num < 0
		return -a:num
	else
		return a:num
endfunction

let seed = localtime()

function! Jrandom(bottom,top)
	let g:seed = g:seed + localtime()
	let t = Jabs(g:seed)
	let x = a:bottom + t % (a:top - a:bottom)
	" echo x
	return x
endfunction

function! ToHex(i) " only one digit ie. 0-15!
	return strpart("0123456789ABCDEF",a:i,1)
endfunction

