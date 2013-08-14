" From http://vim.wikia.com/wiki/Fold_quickfix_list_on_directory_or_file_names

command! FoldByFiles :call s:FoldByFiles()<CR>
command! FoldByFolder :call s:FoldByFolder()<CR>

function! s:FoldByFiles()

	setlocal foldmethod=expr
	setlocal foldexpr=matchstr(getline(v:lnum),'^[^\|]\\+')==#matchstr(getline(v:lnum+1),'^[^\|]\\+')?1:'<1'

	" I wanted to fold || lines into the previous fold, but they end up starting the *next* fold!  (Swallowing whatever lines come after the || block).
	"setlocal foldexpr=getline(v:lnum)[0:1]=='\|\|'?1:matchstr(getline(v:lnum),'^[^\|]\\+')==#matchstr(getline(v:lnum+1),'^[^\|]\\+')?1:'<1'

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
	setlocal foldexpr=matchstr(substitute(getline(v:lnum),'\|.*','',''),'^.*/')==#matchstr(substitute(getline(v:lnum+1),'\|.*','',''),'^.*/')?1:'<1'
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

