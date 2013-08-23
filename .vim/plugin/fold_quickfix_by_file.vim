" From http://vim.wikia.com/wiki/Fold_quickfix_list_on_directory_or_file_names

" DONE: Determine the previous line which *did not* start with '||', before doing the comparison.  Hence wrapped '||' lines get folded with the previous, and do not cause a break in the folding.
" Note that '||' lines appear when the line length exceeds the compile-time macro CMDBUFSIZE, which looks to be 1024 here.

command! FoldByFiles :call s:FoldByFiles()<CR>
command! FoldByFolder :call s:FoldByFolder()<CR>

function! g:GetLastNonWrappedQFLine(startline)
	let curline = a:startline
	while 1
		let line = getline(curline)
		if line[0:2] != '|| '
			return line
		endif
		let curline -= 1
		if curline <= 1
			break
		endif
	endwhile
	return ''
endfunction

function! s:FoldByFiles()

	setlocal foldmethod=expr
	setlocal foldexpr=matchstr(g:GetLastNonWrappedQFLine(v:lnum),'^[^\|]\\+')==#matchstr(g:GetLastNonWrappedQFLine(v:lnum+1),'^[^\|]\\+')?1:'<1'
	setlocal foldtext='['.(v:foldend-v:foldstart+1).']\ '.substitute(getline(v:foldstart),'\|.*','','')

	if foldclosedend(1) == line('$')
		" When all matches come from a single file, do not close that single fold;
		" the user probably is interested in the contents.
		setlocal foldlevel=1
	else
		setlocal foldlevel=0
	endif

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
	"setlocal foldtext=matchstr(substitute(getline(v:foldstart),'\|.*','',''),'^.*/').'\ ['.(v:foldend-v:foldstart+1).'\ lines]'
	setlocal foldtext='['.(v:foldend-v:foldstart+1).']\ '.matchstr(substitute(getline(v:foldstart),'\|.*','',''),'^.*/')

	if foldclosedend(1) == line('$')
		" When all matches come from a single file, do not close that single fold;
		" the user probably is interested in the contents.
		setlocal foldlevel=1
	else
		setlocal foldlevel=0
	endif

endfunction

