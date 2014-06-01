" When searching, shows the total count of matching lines, and the position of the current line within that search.
" Inspired by 
" (Note that the total count of matching lines is not as be the same as the number of occurrences, because one line could contain more than one match!)

" If the current file contains more lines than this, do not display the summary (it may be too slow!).
" TODO: Buffer's total size may be more relevant than line count.
if !exists('g:ShowSearchOccurrences_MaxLines')
	let g:ShowSearchOccurrences_MaxLines = 20000
endif

augroup ShowSearchOccurrences
	autocmd!
	autocmd CursorHold * call s:CheckSearchStatus()
augroup END

function! s:CheckSearchStatus()
	let this_line = getline('.')
	" TODO: To trigger only when at the start of a match (rather than anywhere on a matching line), discard the part of the line before the cursor, and require match()==0
	if &hlsearch && match(this_line, @/) >= 0
		let this_lnum = line('.')
		let count_matches = 0
		let this_index = -1
		let line_count = line("$")
		if line_count > g:ShowSearchOccurrences_MaxLines
			return
		endif
		let lnum = 1
		while lnum <= line_count
			let line = getline(lnum)
			if match(line, @/) >= 0
				let count_matches += 1
				if lnum == this_lnum
					let this_index = count_matches
				end
			endif
			let lnum += 1
		endwhile
		" TODO: Echoing should be optional.  We could instead set some global variables for other scripts to use, and/or change the display on the statusline.
		echo "Search result (".this_index."/".count_matches.") for ".@/
	endif
endfunction

