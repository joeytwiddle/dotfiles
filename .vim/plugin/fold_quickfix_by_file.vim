" From http://vim.wikia.com/wiki/Fold_quickfix_list_on_directory_or_file_names

" DONE: Determine the previous line which *did not* start with '||', before doing the comparison.  Hence wrapped '||' lines get folded with the previous, and do not cause a break in the folding.
" Note that '||' lines appear when the line length exceeds the compile-time macro CMDBUFSIZE, which looks to be 1024 here.

let g:FoldByPath_SeparateFilesVisually = get(g:, "FoldByPath_SeparateFilesVisually", 1)

command! FoldByFiles :call s:FoldByFiles()
command! FoldByFolder :call s:FoldByFolder()
command! FoldByPath :call s:FoldByPath()

function! g:GetLastNonWrappedQFLine(startline)
	let curline = a:startline
	while curline >= 1
		let line = getline(curline)
		if line[0:2] != '|| '
			return line
		endif
		let curline -= 1
	endwhile
	return ''
endfunction

function! s:FoldByFiles()

	setlocal foldmethod=expr
	setlocal foldexpr=matchstr(g:GetLastNonWrappedQFLine(v:lnum),'^[^\|]\\+')==#matchstr(g:GetLastNonWrappedQFLine(v:lnum+1),'^[^\|]\\+')?1:'<1'
	"setlocal foldtext=substitute(getline(v:foldstart),'\|.*','','').'\ ['.(v:foldend-v:foldstart+1).'\ lines]'
	setlocal foldtext=substitute(getline(v:foldstart),'\|.*','','').'\ ----------['.(v:foldend-v:foldstart+1).'\ lines]'

	if foldclosedend(1) == line('$') || line("$") <= winheight(0)
		" When all matches come from a single file, do not close that single fold;
		" the user probably is interested in the contents.
		setlocal foldlevel=1
	else
		setlocal foldlevel=0
	endif

	if g:FoldByPath_SeparateFilesVisually | call g:SeparateFilesVisually() | endif

endfunction

function! s:FoldByFolder()

	setlocal foldmethod=expr
	" This actually folds by '/' count before the '|' and with bugs.
	"setlocal foldexpr=getline(v:lnum)[0:1]=='\|\|'?'=':strlen(substitute(substitute(getline(v:lnum),'\|.*','',''),'[^/]','','g'))
	" What we really need is to compare how many of the .../.../.../ blocks match the previous line.
	" (Yes this will set foldlevel 3 if all the files are in a 3-deep folder, but the alternative is to check every line in the buffer, and even that is not entirely correct; the correct solution is a horizontal scan!)
	"setlocal foldexpr=getline(v:lnum)[0:1]=='\|\|'?'=':strlen(substitute(substitute(getline(v:lnum),'\|.*','',''),'[^/]','','g'))
	" This is better.  It folds by everything up to the last / i.e. the folder but not the filename.
	" Without || support
	"setlocal foldexpr=matchstr(substitute(getline(v:lnum),'\|.*','',''),'^.*/')==#matchstr(substitute(getline(v:lnum+1),'\|.*','',''),'^.*/')?1:'<1'
	" With poor || support
	"setlocal foldexpr=matchstr(substitute(getline(v:lnum),'\|.*','',''),'^.*/')==#matchstr(substitute(getline(v:lnum+1),'\|.*','',''),'^.*/')?1:getline(v:lnum+1)[0:1]=='\|\|'?'=':'<1'
	" With good || support
	setlocal foldexpr=matchstr(substitute(g:GetLastNonWrappedQFLine(v:lnum),'\|.*','',''),'^.*/')==#matchstr(substitute(g:GetLastNonWrappedQFLine(v:lnum+1),'\|.*','',''),'^.*/')?1:'<1'
	"setlocal foldtext='['.(v:foldend-v:foldstart+1).']\ '.matchstr(substitute(getline(v:foldstart),'\|.*','',''),'^.*/')
	"setlocal foldtext=matchstr(substitute(getline(v:foldstart),'\|.*','',''),'^.*/').'\ ['.(v:foldend-v:foldstart+1).'\ lines]'
	setlocal foldtext=matchstr(substitute(getline(v:foldstart),'\|.*','',''),'^.*/').'\ ----------['.(v:foldend-v:foldstart+1).'\ lines]'

	if foldclosedend(1) == line('$') || line("$") <= winheight(0)
		" When all matches come from a single file, do not close that single fold;
		" the user probably is interested in the contents.
		setlocal foldlevel=1
	else
		setlocal foldlevel=0
	endif

	if g:FoldByPath_SeparateFilesVisually | call g:SeparateFilesVisually() | endif

endfunction

function! g:CountSimilarBits(left,right)
	let leftBits = split(a:left, '/')
	let rightBits = split(a:right, '/')
	let i = 0
	while i < len(leftBits) && i < len(rightBits)
		if leftBits[i] != rightBits[i]
			echo i.": ".a:left." VS ".a:right
			return i
		endif
		let i += 1
	endwhile
	echo (i+1)."> ".a:left." VS ".a:right
	return i
endfunction

" Experiment; unfinished.
function! s:FoldByPath()

	for l in range(1,line("$"))
		"call g:CountSimilarBits(substitute(g:GetLastNonWrappedQFLine(l),'\|.*','',''),substitute(g:GetLastNonWrappedQFLine(l),'\|.*','',''))
	endfor

	setlocal foldmethod=expr
	" TODO: Unfinished, but getting there.  This needs to retain the last in a group:
	setlocal foldexpr=g:CountSimilarBits(substitute(g:GetLastNonWrappedQFLine(v:lnum),'\|.*','',''),substitute(g:GetLastNonWrappedQFLine(v:lnum+1),'\|.*','',''))
	" This is not the correct solution; it combines two folds of the same level which should be two separate folds
	"setlocal foldexpr=max([g:CountSimilarBits(substitute(g:GetLastNonWrappedQFLine(v:lnum-1),'\|.*','',''),substitute(g:GetLastNonWrappedQFLine(v:lnum),'\|.*','','')),g:CountSimilarBits(substitute(g:GetLastNonWrappedQFLine(v:lnum),'\|.*','',''),substitute(g:GetLastNonWrappedQFLine(v:lnum+1),'\|.*','',''))])
	setlocal foldtext='['.(v:foldend-v:foldstart+1).']\ '.join(split(substitute(getline(v:foldstart),'\|.*','',''),'/')[0:(v:foldlevel-1)],'/')

	if foldclosedend(1) == line('$')
		setlocal foldlevel=1
	else
		setlocal foldlevel=0
	endif

	if g:FoldByPath_SeparateFilesVisually | call g:SeparateFilesVisually() | endif

endfunction

" Underline the last line of results for each file.
function! g:SeparateFilesVisually()
	if !hlexists("QuickListLastLineOfFile")
		highlight QuickListLastLineOfFile term=underline cterm=underline gui=underline
	endif
	call clearmatches()
	let filename = ""
	for l in range(1,line("$"))
		let new_filename = substitute( getline(l), '|.*', '', '')
		if new_filename != filename
			let filename = new_filename
			let previous_line = l - 1
			if previous_line >= 1
				" Underline whole line
				"let m = matchadd("QuickListLastLineOfFile", '\%'.previous_line.'l.*')
				" Underline just the filename/path
				let m = matchadd("QuickListLastLineOfFile", '^\%'.previous_line.'l[^|]*')
			endif
		endif
	endfor
endfunction

" Shade the background of each block of results alternately.  Aka "zebra stripes".
"function! g:SeparateFilesVisually()
"	if !hlexists("QuickFix_Even_Rows")
"		highlight QuickFix_Even_Rows ctermbg=black guibg=#444444
"		if &t_Co >= 256
"			highlight QuickFix_Even_Rows ctermbg=234
"		endif
"	endif
"	if !hlexists("QuickFix_Odd_Rows")
"		highlight QuickFix_Odd_Rows ctermbg=none guibg=#555555
"		if &t_Co >= 256
"			highlight QuickFix_Odd_Rows ctermbg=236
"		endif
"	endif
"	call clearmatches()
"	let top_line_of_this_file = 1
"	let even = 0
"	let filename = ""
"	for current_line in range(1,line("$"))
"		let new_filename = substitute( getline(current_line), '|.*', '', '')
"		if new_filename != filename
"			let filename = new_filename
"			" Underline all lines for the previous file
"			let hl_class = even ? "QuickFix_Even_Rows" : "QuickFix_Odd_Rows"
"			let m = matchadd(hl_class, '\%>'.(top_line_of_this_file-1).'l\%<'.current_line.'l.*')
"			let even = 1 - even
"			let top_line_of_this_file = current_line
"		endif
"	endfor
"endfunction

