" From http://vim.wikia.com/wiki/Fold_quickfix_list_on_directory_or_file_names

" DONE: Determine the previous line which *did not* start with '||', before doing the comparison.  Hence wrapped '||' lines get folded with the previous, and do not cause a break in the folding.
" Note that '||' lines appear when the line length exceeds the compile-time macro CMDBUFSIZE, which looks to be 1024 here.

let g:FoldByPath_SeparateFilesVisually = get(g:, "FoldByPath_SeparateFilesVisually", 1)

command! FoldByFiles :call s:FoldByFiles()
command! FoldByFolder :call s:FoldByFolder()
command! FoldByPath :call s:FoldByPath()

command! QFAlign :call s:QFAlign()

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

" When filenames happen to have the same length it can be difficult to see when one file ends and the next begins in the quicklist.
" To assist with this problem, SeparateFilesVisually() tries to separate each file block visually.
"
" It might be considered overkill, since we already have a technique to fold by filename, which can be visualised by setting `fdc=2`.
"
" Disadvantage:
" Both of the additional highlights below use matchadd() and as such will override the Search highlight used to indicate the most recently selected quickfix line.  But at least if we highlight only the filename, the rest of the line will show the Search highlight.

" Emphasize the first or last line of the results for each file.
function! g:SeparateFilesVisually()
	" I was using hlexists checks, but they prevent the highlight from reloading if they get cleared for some reason.  Although :hi says they are "cleared", they still "exist"!
	"if !hlexists("QuickFixFirstLineOfFile")

	" Brighten/embolden the first line of each matched file.
	highlight QuickFixFirstLineOfFile term=bold cterm=bold gui=bold
	" Slightly yellowy green, stands out from normal green as a bit "brighter"
	highlight QuickFixFirstLineOfFile ctermfg=82 guifg=#44ff00
	" Since we have a special highlight group for the first line, we could actually hide all the other duplicate filenames below it.  (In that case, we really need to set, not inherit, the colour for the first line highlight!)
	"highlight qfFileName ctermfg=black guifg=black
	"highlight QuickFixFirstLineOfFile ctermfg=green guifg=green

	" Underline the last line of each matched file, to mark the end.
	highlight QuickFixLastLineOfFile term=underline cterm=underline gui=underline

	" But actually, we only want one of the above highlights, not both.  So we disable one!
	highlight clear QuickFixLastLineOfFile

	" If we are doing FirstLine highlighting, then we can hide all the filenames below it:
	highlight qfFileName ctermfg=235 guifg=#102626

	call clearmatches()
	let filename = ""
	for current_line in range(1,line("$"))
		let new_filename = substitute( getline(current_line), '|.*', '', '')
		if new_filename != filename
			let filename = new_filename
			let previous_line = current_line - 1
			" This prevents highlighting on overflow lines which begin with `|| `
			if filename == ''
				continue
			endif
			let n = matchadd("QuickFixFirstLineOfFile", '^\%'.current_line.'l[^|]*')
			if previous_line >= 1
				" Underline whole line
				"let m = matchadd("QuickFixLastLineOfFile", '\%'.previous_line.'l.*')
				" Underline just the filename/path
				let m = matchadd("QuickFixLastLineOfFile", '^\%'.previous_line.'l[^|]*')
			endif
		endif
	endfor
endfunction

" Shade the background of each block of results alternately.  Aka "zebra stripes".
" Not currently available in 8-color xterm (although we could go for black, blue background stripes).
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

function! s:QFAlign()
	if &ft != 'qf'
		echo "Must be run on quickfix window"
		return
	endif
	let line_before = line('.')
	" Will invariably be 0
	let modifiable_before = &modifiable
	set modifiable
	" Convert all Tabs to 4 spaces
	silent! %s/\t/    /g
	silent! %s/|  */|	/
	let lines = getline(2, line('$'))
	let lengths = map(lines, 'match(v:val, "|	")')
	let max = max(lengths)
	execute "setlocal ts=" . (max + 2)
	let &modifiable = modifiable_before
	execute "".line_before
endfunction
