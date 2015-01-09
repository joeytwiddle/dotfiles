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
nmap <C-H> :call JrandomHighlight(expand("<cword>"))<CR>
command! JrandomHighlight call JrandomHighlight(expand("<cword>"))

if has("menu")
	amenu &Joey's\ Tools.&Colour\ current\ word\ <C-H> :call JrandomHighlight(expand("<cword>"))<CR>
endif

" See also: :match and matchadd()
function! JrandomHighlight(pat)
	let name = "JrandomHighlight_".a:pat
	let pattern = '\<'.substitute(a:pat,'+','\\+','g').'\>'
	let truecolour = "#"
	let i = 0
	while i < 6
		let n = Jrandom(0, 16)
		let truecolour .= ToHex(n)
		let i = i + 1
	endwhile
	let numcolour = Jrandom(1,8)
	" TODO: We can generate more "colours" by setting italic/bold/reverse/background!
	echo "Highlighting ".a:pat." in ".numcolour."/".truecolour." (".name.")"
	"" This next line prevents clear from complaining on the first run.
	execute "syntax match ".name." +".pattern."+"
	execute "syntax clear ".name
	execute "syntax match ".name." +".pattern."+"
	execute "highlight ".name." ctermfg=".numcolour." guifg=".truecolour." gui=italic"
endfunction

""""""""""""""""""""""""""""""" Jrefactor """""""""""""""""""""""""""""""

" PLEASE NOTE that Jrefactor is now deprecated in favour of \r and \R in replace.vim

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



function! JExecVimCommand()
	let command = input(":", "", "command")
	execute command
endfunction

if has("menu")
	amenu &Joey's\ Tools.&Execute\ VIM\ Command :call JExecVimCommand()<CR>
endif

"" TODO: This does not work!  It inserts the string, rather than running the command :P
"" BUG: Also <C-h> triggers on Backspace in Eterm.
" inoremap <C-h> :call JExecVimCommand()<CR>
"" Perhaps the idea was to allow user breakout during gVim-Easy sessions?  But
"" that already exists on Ctrl-O.
" inoremap <C-o> <Esc>:call JExecVimCommand()<CR>



" Runs the given Ex command and pipes the output to the given shell command.
" For example: :PipeToShell syn | grep 'Declaration'
" I considered other names: CmdOut, PipeToShell
command! -nargs=+ -complete=command PipeCmd call s:PassVimCommandOutputToShellCommand(<q-args>)

function! s:PassVimCommandOutputToShellCommand(line)
	let vim_cmd = substitute(a:line, '\s*|.*', '', '')
	let shell_cmd = substitute(a:line, '^[^|]*|\s*', '', '')
	" TODO: We could redir to a local variable, to avoid clobbering the 'l' register.
	redir @l
		silent exe vim_cmd
	redir END
	" To pipe to a shell, the only way I thought of was to put the data into a fresh buffer, and then do :w !...
	new
	normal "lP
	exe 'w !'.shell_cmd
	" Undo the paste so bwipeout can drop the buffer without complaint
	normal u
	exe "bwipeout"
endfunction

" Runs the given Ex command and pastes the output
command! -nargs=+ -complete=command PasteCmd call s:PasteCommandOutput(<q-args>)

function! s:PasteCommandOutput(line)
	let vim_cmd = a:line
	" TODO: We could redir to a local variable, to avoid clobbering the 'l' register.
	redir @l
		silent exe vim_cmd
	redir END
	normal "lp
endfunction

" Runs the given Ex command and copies/yanks the output into the unnamed register
command! -nargs=+ -complete=command CopyCmd call s:CopyCommandOutput(<q-args>)

function! s:CopyCommandOutput(line)
	let vim_cmd = a:line
	redir @"
		silent exe vim_cmd
	redir END
endfunction

" I don't find this particularly useful for CSS files, but it is a nice example of advanced :g usage!
command! SortCSS :g#\({\n\)\@<=#.,/}/sort

" You can use this to get rid of pesky trailing `^M`s
command! Dos2Unix :e ++ff=dos | :set ff=unix

" Performs a normal bufdo but then returns to the buffer you were on initially.
command! -nargs=+ -complete=command BufDo :call s:BufDoAndReturn(<q-args>)
function! s:BufDoAndReturn(command)
	let initial_bufnr = bufnr('%')
	execute 'bufdo ' . a:command
	execute initial_bufnr . 'b'
endfunction

" Performs a normal windo but then returns to the window you were on initially.
command! -nargs=+ -complete=command WinDo :call s:WinDoAndReturn(<q-args>)
function! s:WinDoAndReturn(command)
	let initial_winnr = winnr()
	execute 'windo ' . a:command
	execute initial_winnr . 'wincmd w'
endfunction

" Create a new buffer "without splitting"
" (Actually does split, but closes the old window)
command! New :new | wincmd p | wincmd c
